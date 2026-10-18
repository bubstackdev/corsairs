//! Worker-confined native tensor storage for chaining without host round trips.
use super::*;

/// Metadata only; the native allocation stays in its creating session.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeTensorHandle {
    pub id: u64,
    pub dtype: NativeDType,
    pub shape: Vec<usize>,
    pub strides: Vec<isize>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeHandleRunResult {
    pub outputs: Vec<(String, NativeTensorHandle)>,
    pub states: Vec<(String, NativeTensorHandle)>,
}

pub(super) struct TensorRecord {
    pub(super) value: NativeValue,
    pub(super) info: NativeTensorHandle,
    // Conservative possible-alias origins, never native pointer identities.
    lineage: Rc<HashSet<u64>>,
}

impl NativeSession {
    /// # Safety
    /// The session and its native values remain confined to their owning worker.
    pub unsafe fn upload_tensor(&mut self, tensor: NativeTensor) -> Result<NativeTensorHandle> {
        // SAFETY: Validation precedes creation; this is the sole host-to-native copy.
        let value = unsafe { self.tensor(&tensor)? };
        // SAFETY: Fully initialized native NDArray; only metadata is inspected.
        let mut info = unsafe { self.tensor_handle_info(&value)? };
        info.id = self.id()?;
        self.tensors.insert(
            info.id,
            TensorRecord {
                value,
                info: info.clone(),
                lineage: Rc::new(HashSet::from([info.id])),
            },
        );
        Ok(info)
    }

    /// # Safety
    /// Called on the owner after all earlier native work has completed.
    pub unsafe fn download_tensor(&self, id: u64) -> Result<NativeTensor> {
        let record = self
            .tensors
            .get(&id)
            .ok_or(NativeFailure::InvalidHandle { kind: "tensor", id })?;
        // SAFETY: The retained record outlives the scoped packed download.
        unsafe { self.read_packed(&record.value) }
    }

    /// Copy a ready NDArray through the shared checked nonnegative-stride plan.
    ///
    /// # Safety
    /// The initialized array remains live and immutable throughout this copy.
    pub(super) unsafe fn read_packed(&self, value: &NativeValue) -> Result<NativeTensor> {
        // SAFETY: The record and immutable view outlive all pointer reads below.
        unsafe {
            let info = self.tensor_handle_info(value)?;
            let plan = PackingPlan::new(&info.shape, &info.strides, info.dtype.byte_width())?;
            let mut view =
                NativeValue::allocate(self.metadata(c"$s13CoreAIRuntime7NDArrayV7RawViewVMa")?)?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF",
                [0; 3],
                view.ptr(),
                value.address(),
            )?;
            view.initialized = true;
            let (start, count) = self.pair(
                c"$s13CoreAIRuntime7NDArrayV7RawViewV5bytess0D4SpanVvg",
                [0; 3],
                ptr::null_mut(),
                view.address(),
            )?;
            plan.validate_span(count)?;
            if plan.output_bytes != 0 && (start == 0 || start.checked_add(plan.extent).is_none()) {
                return Err(NativeFailure::Binding(
                    "nonempty native tensor has null storage".into(),
                ));
            }
            let mut bytes = vec![0; plan.output_bytes];
            if plan.output_bytes != 0 && plan.contiguous() {
                // SAFETY: The checked row-major layout covers exactly the
                // validated span, and Rust owns a separate destination buffer.
                ptr::copy_nonoverlapping(start as *const u8, bytes.as_mut_ptr(), plan.output_bytes);
            } else {
                for (element, offset) in plan.offsets().enumerate() {
                    // SAFETY: Each byte range was checked against the native span;
                    // nonnegative strides use its logical origin. No typed aliases.
                    ptr::copy_nonoverlapping(
                        (start as *const u8).add(offset),
                        bytes.as_mut_ptr().add(element * plan.width),
                        plan.width,
                    );
                }
            }
            Ok(NativeTensor {
                dtype: info.dtype,
                shape: info.shape,
                bytes,
            })
        }
    }

    /// # Safety
    /// No queued job may release its retained public handle before completion.
    pub unsafe fn drop_tensor(&mut self, id: u64) -> Result<()> {
        self.tensors
            .remove(&id)
            .map(drop)
            .ok_or(NativeFailure::InvalidHandle { kind: "tensor", id })
    }

    #[cfg(test)]
    pub(crate) fn live_tensor_count(&self) -> usize {
        self.tensors.len()
    }

    pub(super) unsafe fn tensor_handle_info(
        &self,
        value: &NativeValue,
    ) -> Result<NativeTensorHandle> {
        // SAFETY: Borrowing public NDArray getters on an initialized native value.
        unsafe {
            let shape = self.call(
                c"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg",
                [0; 3],
                ptr::null_mut(),
                value.address(),
            )?;
            let shape = self.integers(shape)?;
            if shape.iter().any(|d| *d < 0) {
                return Err(NativeFailure::Unsupported(
                    "native tensor has unresolved dimensions".into(),
                ));
            }
            let shape: Vec<_> = shape.into_iter().map(|d| d as usize).collect();
            let strides = self.call(
                c"$s13CoreAIRuntime7NDArrayV7stridesSaySiGvg",
                [0; 3],
                ptr::null_mut(),
                value.address(),
            )?;
            let strides = self.integers(strides)?;
            if shape.len() != strides.len() {
                return Err(NativeFailure::Binding(
                    "native shape/stride rank mismatch".into(),
                ));
            }
            let mut scalar = NativeValue::allocate(self.metadata(super::super::SCALAR_METADATA)?)?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg",
                [0; 3],
                scalar.ptr(),
                value.address(),
            )?;
            scalar.initialized = true;
            let dtype = self.dtype(&scalar)?;
            crate::dtype::element_count(&shape, dtype.byte_width())
                .map_err(|e| NativeFailure::Unsupported(e.to_string()))?;
            Ok(NativeTensorHandle {
                id: 0,
                dtype,
                shape,
                strides,
            })
        }
    }

    /// Execute directly from retained native NDArrays. States mutate in place;
    /// outputs remain native and no payload bytes are copied into Rust storage.
    ///
    /// # Safety
    /// All IDs refer to this session. Calls remain serialized on its owner.
    pub unsafe fn run_native(
        &mut self,
        function: u64,
        inputs: Vec<(String, u64)>,
        states: Vec<(String, u64)>,
    ) -> Result<NativeHandleRunResult> {
        if self
            .functions
            .get(&function)
            .is_some_and(|f| f.descriptor.has_images())
        {
            return Err(NativeFailure::Unsupported(
                "tensor handle runs do not carry image values; use Function::run_with_images"
                    .into(),
            ));
        }
        let use_stream = self.uses_owned_stream(function)?;
        let descriptor = self
            .functions
            .get(&function)
            .ok_or(NativeFailure::InvalidHandle {
                kind: "function",
                id: function,
            })?
            .descriptor
            .clone();
        for group in [&descriptor.inputs, &descriptor.states, &descriptor.outputs] {
            let mut names = HashSet::new();
            if group.iter().any(|item| !names.insert(&item.name)) {
                return Err(NativeFailure::Binding(
                    "duplicate name in native function descriptor".into(),
                ));
            }
        }
        self.validate_handle_group(&inputs, &descriptor.inputs)?;
        self.validate_handle_group(&states, &descriptor.states)?;
        let gpu = self.function_compute(function)?.accelerated();
        if gpu {
            for (_, id) in inputs.iter().chain(&states) {
                validate_gpu_handle(&self.tensors[id].info)?;
            }
        }
        let mut input_lineage = HashSet::new();
        for (_, id) in &inputs {
            input_lineage.extend(self.tensors[id].lineage.iter().copied());
        }
        let mut state_lineage = HashSet::new();
        for (_, id) in &states {
            let lineage = &self.tensors[id].lineage;
            if lineage
                .iter()
                .any(|origin| input_lineage.contains(origin) || state_lineage.contains(origin))
            {
                return Err(NativeFailure::InvalidData(
                    "mutable state may alias an input or another state handle".into(),
                ));
            }
            state_lineage.extend(lineage.iter().copied());
        }
        let output_lineage = inference_lineage(input_lineage, state_lineage);
        // Remove mutable records so exclusive references never alias the store.
        // Restore them after every Result path, including native errors.
        let mut native_states: Vec<_> = states
            .iter()
            .map(|(name, id)| {
                (
                    name.clone(),
                    *id,
                    self.tensors.remove(id).expect("validated tensor ID"),
                )
            })
            .collect();
        // SAFETY: Validated inputs are immutable; distinct removed states are
        // exclusively owned here. All containers are dropped before restoration.
        let result = if use_stream {
            // SAFETY: Stateless inputs have passed full handle/alias validation.
            // The helper returns owned, ready arrays after actual stream fences.
            unsafe { self.encode_native_arrays(function, &inputs) }
        } else {
            // SAFETY: Validated immutable inputs and distinct removed states
            // outlive every dependent view and the awaited native call.
            unsafe {
                (|| -> Result<Vec<(String, NativeValue, NativeTensorHandle)>> {
                    let function = &self.functions[&function];
                    let mut input_views = NativeValue::allocate(
                        self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV6InputsVMa")?,
                    )?;
                    self.call(
                        c"$s13CoreAIRuntime17InferenceFunctionV6InputsVAEycfC",
                        [0; 3],
                        input_views.ptr(),
                        0,
                    )?;
                    input_views.initialized = true;
                    for (name, id) in &inputs {
                        self.insert_input(&mut input_views, &self.tensors[id].value, name)?;
                    }
                    let md =
                        self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa")?;
                    let mut state_views = NativeValue::allocate(md)?;
                    let mut output_views = NativeValue::allocate(md)?;
                    self.call(
                        c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC",
                        [0; 3],
                        state_views.ptr(),
                        0,
                    )?;
                    state_views.initialized = true;
                    self.call(
                        c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC",
                        [0; 3],
                        output_views.ptr(),
                        0,
                    )?;
                    output_views.initialized = true;
                    for (name, _, record) in &mut native_states {
                        self.insert_mutable(&mut state_views, &mut record.value, name)?;
                    }
                    let mut outputs = NativeValue::allocate(
                        self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV7OutputsVMa")?,
                    )?;
                    let outcome = self.runtime.await_native(c"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu", [outputs.address(), input_views.address(), state_views.address(), output_views.address()], function.value.address(), true)?;
                    state_views.initialized = false;
                    output_views.initialized = false;
                    if outcome.error != 0 {
                        return Err(self.failure(outcome.error, "run_native"));
                    }
                    outputs.initialized = true;
                    Self::lifecycle(&outcome)?;
                    // All immutable/mutable views end before returned arrays are stored
                    // or any later operation can request another view of their storage.
                    drop(input_views);
                    let value_md = self.metadata(c"$s13CoreAIRuntime14InferenceValueVMa")?;
                    let optional_value_md = self.optional(value_md)?;
                    let tensor_md = self.metadata(super::super::NDARRAY_METADATA)?;
                    let optional_tensor_md = self.optional(tensor_md)?;
                    let mut returned = Vec::new();
                    for expected in &descriptor.outputs {
                        let key = self.string(&expected.name)?;
                        let mut optional = NativeValue::allocate(optional_value_md)?;
                        self.call(
                        c"$s13CoreAIRuntime17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF",
                        [key.words[0], key.words[1], 0],
                        optional.ptr(),
                        outputs.address(),
                    )?;
                        optional.initialized = true;
                        let mut value = optional.take_optional(value_md)?.ok_or_else(|| {
                            NativeFailure::Binding(format!(
                                "native run omitted output {}",
                                expected.name
                            ))
                        })?;
                        let mut array = NativeValue::allocate(optional_tensor_md)?;
                        self.call(
                            c"$s13CoreAIRuntime14InferenceValueV7ndArrayAA7NDArrayVSgvg",
                            [0; 3],
                            array.ptr(),
                            value.address(),
                        )?;
                        value.initialized = false;
                        array.initialized = true;
                        let array = array.take_optional(tensor_md)?.ok_or_else(|| {
                            NativeFailure::Unsupported(format!(
                                "output {} is not NDArray",
                                expected.name
                            ))
                        })?;
                        let info = self.tensor_handle_info(&array)?;
                        if gpu {
                            validate_gpu_handle(&info)?;
                        }
                        validate_handle_against(&info, expected)?;
                        returned.push((expected.name.clone(), array, info));
                    }
                    if self.call(
                        c"$s13CoreAIRuntime17InferenceFunctionV7OutputsV5countSivg",
                        [0; 3],
                        ptr::null_mut(),
                        outputs.address(),
                    )? != 0
                    {
                        return Err(NativeFailure::Unsupported(
                            "native run returned undescribed outputs".into(),
                        ));
                    }
                    Ok(returned)
                })()
            }
        };
        let returned_states: Vec<_> = native_states
            .iter()
            .map(|(name, _, record)| (name.clone(), record.info.clone()))
            .collect();
        for (_, id, record) in native_states {
            self.tensors.insert(id, record);
        }
        let values = result?;
        // Allocate every ID before committing any output, so an allocation/ID
        // error cannot orphan a native record without a corresponding handle.
        let mut prepared = Vec::with_capacity(values.len());
        for (name, value, mut info) in values {
            info.id = self.id()?;
            prepared.push((name, value, info));
        }
        let mut outputs = Vec::with_capacity(prepared.len());
        for (name, value, info) in prepared {
            self.tensors.insert(
                info.id,
                TensorRecord {
                    value,
                    info: info.clone(),
                    lineage: Rc::clone(&output_lineage),
                },
            );
            outputs.push((name, info));
        }
        Ok(NativeHandleRunResult {
            outputs,
            states: returned_states,
        })
    }

    fn validate_handle_group(
        &self,
        tensors: &[(String, u64)],
        descriptors: &[NativeTensorDescriptor],
    ) -> Result<()> {
        let mut names = HashSet::new();
        for (name, id) in tensors {
            if !names.insert(name) {
                return Err(NativeFailure::InvalidData(format!(
                    "duplicate tensor name {name}"
                )));
            }
            let expected = descriptors
                .iter()
                .find(|d| d.name == *name)
                .ok_or_else(|| NativeFailure::InvalidData(format!("unexpected tensor {name}")))?;
            let record = self.tensors.get(id).ok_or(NativeFailure::InvalidHandle {
                kind: "tensor",
                id: *id,
            })?;
            validate_handle_against(&record.info, expected)?;
        }
        for expected in descriptors {
            if !names.contains(&expected.name) {
                return Err(NativeFailure::InvalidData(format!(
                    "missing tensor {}",
                    expected.name
                )));
            }
        }
        Ok(())
    }
}

pub(super) fn validate_gpu_handle(info: &NativeTensorHandle) -> Result<()> {
    super::run_stream::gpu_shape(info.dtype, &info.shape)?;
    let plan = PackingPlan::new(&info.shape, &info.strides, info.dtype.byte_width())?;
    super::run_stream::gpu_span(plan.extent)
}

fn inference_lineage(mut inputs: HashSet<u64>, states: HashSet<u64>) -> Rc<HashSet<u64>> {
    // Preserve uploaded source origins for mutable-alias checks. Reserved origin
    // zero already ties all inference outputs together, including no-input calls
    // and unrelated models that may share constants or backend storage. A fresh
    // per-call origin would only accumulate redundant history in native chains.
    inputs.extend(states);
    inputs.insert(0);
    Rc::new(inputs)
}

fn validate_handle_against(
    info: &NativeTensorHandle,
    descriptor: &NativeTensorDescriptor,
) -> Result<()> {
    if info.dtype != descriptor.dtype
        || info.shape.len() != descriptor.shape.len()
        || info
            .shape
            .iter()
            .zip(&descriptor.shape)
            .any(|(actual, expected)| *expected >= 0 && *actual != *expected as usize)
    {
        return Err(NativeFailure::InvalidData(format!(
            "native tensor does not match descriptor {}",
            descriptor.name
        )));
    }
    Ok(())
}

/// Checked nonnegative-stride byte addressing, independent of native pointers.
struct PackingPlan {
    shape: Vec<usize>,
    strides: Vec<usize>,
    width: usize,
    output_bytes: usize,
    extent: usize,
}
impl PackingPlan {
    fn new(shape: &[usize], strides: &[isize], width: usize) -> Result<Self> {
        if shape.len() != strides.len() || width == 0 {
            return Err(NativeFailure::Binding(
                "invalid tensor packing metadata".into(),
            ));
        }
        if strides.iter().any(|s| *s < 0) {
            return Err(NativeFailure::Unsupported(
                "negative tensor strides need an established storage-origin contract".into(),
            ));
        }
        let elements = crate::dtype::element_count(shape, width)
            .map_err(|e| NativeFailure::Unsupported(e.to_string()))?;
        let strides: Vec<usize> = strides.iter().map(|s| *s as usize).collect();
        let extent = if elements == 0 {
            0
        } else {
            shape
                .iter()
                .zip(&strides)
                .try_fold(0usize, |offset, (size, stride)| {
                    (size - 1)
                        .checked_mul(*stride)
                        .and_then(|delta| offset.checked_add(delta))
                })
                .and_then(|offset| offset.checked_mul(width))
                .and_then(|offset| offset.checked_add(width))
                .filter(|n| *n <= crate::dtype::MAX_TENSOR_BYTES)
                .ok_or_else(|| {
                    NativeFailure::Unsupported("native strided storage extent exceeds limit".into())
                })?
        };
        Ok(Self {
            shape: shape.to_vec(),
            strides,
            width,
            output_bytes: elements * width,
            extent,
        })
    }
    fn validate_span(&self, bytes: usize) -> Result<()> {
        if self.extent > bytes {
            return Err(NativeFailure::Binding(
                "tensor strides exceed the native storage span".into(),
            ));
        }
        Ok(())
    }
    fn contiguous(&self) -> bool {
        let mut expected = 1usize;
        for (&size, &stride) in self.shape.iter().zip(&self.strides).rev() {
            if size > 1 && stride != expected {
                return false;
            }
            expected *= size;
        }
        true
    }
    fn offsets(&self) -> impl Iterator<Item = usize> + '_ {
        (0..self.output_bytes / self.width).map(|mut index| {
            let mut offset = 0;
            for (&size, &stride) in self.shape.iter().zip(&self.strides).rev() {
                offset += (index % size) * stride;
                index /= size;
            }
            offset * self.width
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn gpu_referenced_span_is_bounded_independently_of_packed_bytes() {
        let limit = crate::dtype::MAX_GPU_INFERENCE_TENSOR_BYTES;
        let mut info = NativeTensorHandle {
            id: 0,
            dtype: NativeDType::F32,
            shape: vec![2],
            strides: vec![(limit / 4 - 1) as isize],
        };
        assert!(validate_gpu_handle(&info).is_ok());
        info.strides[0] += 1;
        assert!(matches!(
            validate_gpu_handle(&info),
            Err(NativeFailure::Unsupported(_))
        ));
    }
    fn pack(bytes: &[u8], shape: &[usize], strides: &[isize]) -> Result<Vec<u8>> {
        let plan = PackingPlan::new(shape, strides, 1)?;
        plan.validate_span(bytes.len())?;
        Ok(plan.offsets().map(|offset| bytes[offset]).collect())
    }
    #[test]
    fn packs_padding_transpose_and_broadcast() {
        assert_eq!(
            pack(&[1, 2, 99, 3, 4], &[2, 2], &[3, 1]).unwrap(),
            [1, 2, 3, 4]
        );
        assert_eq!(
            pack(&[1, 2, 3, 4, 5, 6], &[3, 2], &[1, 3]).unwrap(),
            [1, 4, 2, 5, 3, 6]
        );
        assert_eq!(pack(&[7, 8], &[3, 2], &[0, 1]).unwrap(), [7, 8, 7, 8, 7, 8]);
    }
    #[test]
    fn handles_scalar_empty_and_rejects_bad_extents() {
        assert_eq!(pack(&[9], &[], &[]).unwrap(), [9]);
        assert!(pack(&[], &[0, 2], &[2, 1]).unwrap().is_empty());
        assert!(pack(&[1, 2, 3], &[2, 2], &[2, 1]).is_err());
        assert!(pack(&[1, 2], &[2], &[-1]).is_err());
        assert!(PackingPlan::new(&[2], &[isize::MAX], 8).is_err());
        assert!(PackingPlan::new(&[2, 2], &[isize::MAX, isize::MAX], 1).is_err());
    }
    #[test]
    fn offsets_are_bytes_for_multibyte_elements() {
        let plan = PackingPlan::new(&[2, 2], &[3, 1], 4).unwrap();
        assert_eq!(plan.extent, 20);
        assert_eq!(plan.offsets().collect::<Vec<_>>(), [0, 4, 12, 16]);
        assert!(plan.validate_span(19).is_err());
        plan.validate_span(20).unwrap();
    }

    #[test]
    fn contiguous_copy_distinguishes_transpose_padding_and_broadcast() {
        for (shape, strides, contiguous) in [
            (vec![], vec![], true),
            (vec![2, 3], vec![3, 1], true),
            (vec![2, 1, 3], vec![3, 99, 1], true),
            (vec![3, 2], vec![1, 3], false),
            (vec![2, 3], vec![4, 1], false),
            (vec![2, 3], vec![0, 1], false),
        ] {
            let plan = PackingPlan::new(&shape, &strides, 2).unwrap();
            assert_eq!(plan.contiguous(), contiguous, "{shape:?} {strides:?}");
            if contiguous {
                assert_eq!(plan.extent, plan.output_bytes);
            }
        }
    }

    #[test]
    fn strided_extents_cross_gib_boundaries_but_stop_at_the_shared_limit() {
        let boundary = crate::dtype::MAX_TENSOR_BYTES;
        let plan = PackingPlan::new(&[2], &[(boundary / 2 - 1) as isize], 2).unwrap();
        assert_eq!(plan.output_bytes, 4);
        assert_eq!(plan.extent, boundary);
        assert_eq!(plan.offsets().collect::<Vec<_>>(), [0, boundary - 2]);
        assert!(!plan.contiguous());
        plan.validate_span(boundary).unwrap();
        assert!(plan.validate_span(boundary - 1).is_err());
        assert!(PackingPlan::new(&[2], &[(boundary / 2) as isize], 2).is_err());
        assert!(PackingPlan::new(&[0, boundary], &[0, 1], 2).is_err());
    }

    #[test]
    fn unrelated_inference_outputs_remain_possible_aliases() {
        let first = inference_lineage(HashSet::new(), HashSet::new());
        let second = inference_lineage(HashSet::new(), HashSet::new());
        assert!(!first.is_disjoint(&second));
        assert!(HashSet::from([1]).is_disjoint(&HashSet::from([2])));
        assert!(HashSet::from([1]).is_disjoint(&first));
    }

    #[test]
    fn native_chain_lineage_stays_bounded_and_preserves_source_aliases() {
        let input = HashSet::from([1]);
        let state = HashSet::from([2]);
        let independent_upload = HashSet::from([3]);
        let mut lineage = inference_lineage(input.clone(), state.clone());
        let mut history = Vec::new();
        for _ in 0..16_000 {
            assert_eq!(*lineage, HashSet::from([0, 1, 2]));
            assert!(!lineage.is_disjoint(&input));
            assert!(!lineage.is_disjoint(&state));
            assert!(lineage.is_disjoint(&independent_upload));
            history.push(Rc::clone(&lineage));
            lineage = inference_lineage((*lineage).clone(), HashSet::new());
        }
        assert_eq!(
            history.iter().map(|origins| origins.len()).sum::<usize>(),
            48_000
        );
    }
}
