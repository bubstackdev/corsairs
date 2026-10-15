//! Unintegrated child of native::owned, compiled only in a disposable copy.
//! All signatures come from experiments/swift/MetalReference.swift.
use super::*;
use std::arch::asm;

type ObjcRetain = unsafe extern "C" fn(*mut c_void) -> *mut c_void;
type ObjcRelease = unsafe extern "C" fn(*mut c_void);
type Message0 = unsafe extern "C" fn(*mut c_void, *mut c_void) -> usize;
type Message2 = unsafe extern "C" fn(*mut c_void, *mut c_void, usize, usize) -> usize;

struct ObjcObject {
    value: NonNull<c_void>,
    retain: ObjcRetain,
    release: ObjcRelease,
}
struct AutoreleasePool {
    token: *mut c_void,
    pop: unsafe extern "C" fn(*mut c_void),
}
impl Drop for AutoreleasePool {
    fn drop(&mut self) {
        // SAFETY: Pops this thread's pool after its scoped native objects drop.
        unsafe { (self.pop)(self.token) };
    }
}
impl ObjcObject {
    fn owned(value: *mut c_void, retain: ObjcRetain, release: ObjcRelease) -> Result<Self> {
        Ok(Self {
            value: NonNull::new(value)
                .ok_or_else(|| NativeFailure::Binding("Metal returned nil".into()))?,
            retain,
            release,
        })
    }
    unsafe fn extra_reference(&self) -> usize {
        // SAFETY: This live Objective-C object supplies one new owned reference.
        unsafe { (self.retain)(self.value.as_ptr()) as usize }
    }
}
impl Drop for ObjcObject {
    fn drop(&mut self) {
        // SAFETY: Balances precisely this guard's +1 Objective-C reference.
        unsafe { (self.release)(self.value.as_ptr()) };
    }
}

/// Explicitly lowered Swift call with six ordinary words and a word result.
/// For throwing targets, x21 is empty on entry and owns the returned error.
unsafe fn call6(
    target: *mut c_void,
    arguments: [usize; 6],
    out: *mut c_void,
    receiver: usize,
) -> (usize, usize, usize) {
    let first: usize;
    let second: usize;
    let error: usize;
    // SAFETY: Each caller supplies the compiler-established register contract.
    unsafe {
        asm!(
            "blr x16",
            in("x16") target,
            inlateout("x0") arguments[0] => first,
            inlateout("x1") arguments[1] => second,
            inlateout("x2") arguments[2] => _,
            inlateout("x3") arguments[3] => _,
            inlateout("x4") arguments[4] => _,
            inlateout("x5") arguments[5] => _,
            inlateout("x8") out => _,
            inlateout("x20") receiver => _,
            inlateout("x21") 0usize => error,
            lateout("x22") _,
            clobber_abi("C"),
        );
    }
    (first, second, error)
}

impl NativeSession {
    /// # Safety
    /// Native development proof on macOS27 arm64; never a public safe entry.
    /// On an impossible-to-establish post-encode fence, abort rather than free
    /// storage potentially still used by native work.
    pub unsafe fn metal_proof(&mut self, path: &Path, cycles: usize) -> Result<String> {
        // SAFETY: Explicit proof accepts the independently compiled contracts.
        unsafe {
            let model = self.load_model(path, NativeCompute::GpuPreferred)?;
            let function = self.load_function(model.id, "main")?;
            let outcome = self.metal_proof_inner(function.id, cycles);
            // Every non-aborting inner return has either not encoded or drained.
            let released_function = self.drop_function(function.id);
            let released_model = self.drop_model(model.id);
            outcome.and_then(|report| {
                released_function?;
                released_model?;
                Ok(report)
            })
        }
    }

    unsafe fn metal_proof_inner(&self, function: u64, cycles: usize) -> Result<String> {
        // SAFETY: All handles, buffers and native values remain local until all
        // submitted work, including a deliberate encode error, has drained.
        unsafe {
            let record = self
                .functions
                .get(&function)
                .ok_or(NativeFailure::InvalidHandle {
                    kind: "function",
                    id: function,
                })?;
            if record.descriptor.inputs
                != [NativeTensorDescriptor {
                    name: "x".into(),
                    shape: vec![2, 3],
                    dtype: NativeDType::F32,
                }]
                || record.descriptor.outputs
                    != [NativeTensorDescriptor {
                        name: "y".into(),
                        shape: vec![2, 3],
                        dtype: NativeDType::F32,
                    }]
                || !record.descriptor.states.is_empty()
            {
                return Err(NativeFailure::Unsupported(
                    "proof requires main(x:float32[2,3])->y:float32[2,3], without state".into(),
                ));
            }
            // Libraries are declared before objects so their symbol addresses
            // remain valid throughout all reference destruction.
            let metal = super::super::loader::Library::open(
                c"/System/Library/Frameworks/Metal.framework/Versions/A/Metal",
            )?;
            let objc = super::super::loader::Library::open(c"/usr/lib/libobjc.A.dylib")?;
            let retain: ObjcRetain = mem::transmute(objc.symbol(c"objc_retain")?.as_ptr());
            let release: ObjcRelease = mem::transmute(objc.symbol(c"objc_release")?.as_ptr());
            let selector: unsafe extern "C" fn(*const std::ffi::c_char) -> *mut c_void =
                mem::transmute(objc.symbol(c"sel_registerName")?.as_ptr());
            let message0: Message0 = mem::transmute(objc.symbol(c"objc_msgSend")?.as_ptr());
            let message2: Message2 = mem::transmute(objc.symbol(c"objc_msgSend")?.as_ptr());
            let create_device: unsafe extern "C" fn() -> *mut c_void =
                mem::transmute(metal.symbol(c"MTLCreateSystemDefaultDevice")?.as_ptr());
            let push_pool: unsafe extern "C" fn() -> *mut c_void =
                mem::transmute(objc.symbol(c"objc_autoreleasePoolPush")?.as_ptr());
            let pop_pool: unsafe extern "C" fn(*mut c_void) =
                mem::transmute(objc.symbol(c"objc_autoreleasePoolPop")?.as_ptr());
            let _pool = AutoreleasePool {
                token: push_pool(),
                pop: pop_pool,
            };
            let device = ObjcObject::owned(create_device(), retain, release)?;
            let queue = ObjcObject::owned(
                message0(device.value.as_ptr(), selector(c"newCommandQueue".as_ptr())) as _,
                retain,
                release,
            )?;
            let input = ObjcObject::owned(
                message2(
                    device.value.as_ptr(),
                    selector(c"newBufferWithLength:options:".as_ptr()),
                    24,
                    0,
                ) as _,
                retain,
                release,
            )?;
            let output = ObjcObject::owned(
                message2(
                    device.value.as_ptr(),
                    selector(c"newBufferWithLength:options:".as_ptr()),
                    24,
                    0,
                ) as _,
                retain,
                release,
            )?;
            let input_start =
                message0(input.value.as_ptr(), selector(c"contents".as_ptr())) as *mut u8;
            let output_start =
                message0(output.value.as_ptr(), selector(c"contents".as_ptr())) as *mut u8;
            if input_start.is_null()
                || output_start.is_null()
                || !(input_start as usize).is_multiple_of(4)
                || !(output_start as usize).is_multiple_of(4)
                || message0(input.value.as_ptr(), selector(c"length".as_ptr())) != 24
                || message0(output.value.as_ptr(), selector(c"length".as_ptr())) != 24
            {
                return Err(NativeFailure::Binding(
                    "invalid shared Metal buffer mapping".into(),
                ));
            }
            let input_bytes: Vec<_> = [1f32, -2., 0.5, 7., 0., -1.]
                .into_iter()
                .flat_map(f32::to_le_bytes)
                .collect();
            let expected: Vec<_> = [2f32, -4., 1., 14., 0., -2.]
                .into_iter()
                .flat_map(f32::to_le_bytes)
                .collect();
            ptr::copy_nonoverlapping(input_bytes.as_ptr(), input_start, 24);

            let stream_md = self.metadata(c"$s13CoreAIRuntime13ComputeStreamCMa")?;
            let stream_init = self.symbol(
                c"$s13CoreAIRuntime13ComputeStreamC12commandQueueACSo010MTLCommandF0_p_tcfC",
            )?;
            let swift_release = self.release(c"swift_release")?;
            let stream = OwnedWord {
                word: arm64::call_sync(
                    stream_init,
                    [queue.extra_reference(), 0, 0],
                    ptr::null_mut(),
                    stream_md.pointer,
                ),
                release: swift_release,
            };
            if stream.word == 0 {
                return Err(NativeFailure::Binding("ComputeStream returned null".into()));
            }
            let input_md =
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa")?;
            let mutable_md =
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVMa")?;
            let views_md =
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa")?;
            let scalar_md = self.metadata(super::super::SCALAR_METADATA)?;
            let tensor_md = self.metadata(super::super::NDARRAY_METADATA)?;
            let optional_tensor_md = self.optional(tensor_md)?;
            let interleave_md =
                self.metadata(c"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa")?;
            let optional_interleave_md = self.optional(interleave_md)?;
            let string_md =
                NativeMetadata::copy(&Metadata::from_response(self.symbol(c"$sSSN")?, 0)?);
            let string_hash = self.symbol(c"$sSSSHsWP")? as usize;
            let (dictionary_pointer, dictionary_state, _) = call6(
                self.symbol(c"$sSDMa")?,
                [0, string_md.pointer, input_md.pointer, string_hash, 0, 0],
                ptr::null_mut(),
                0,
            );
            let dictionary_md = NativeMetadata::copy(&Metadata::from_response(
                dictionary_pointer as _,
                dictionary_state,
            )?);
            let optional_input_md = self.optional(input_md)?;
            if dictionary_md.layout.size != 8
                || input_md.layout.size != 8
                || string_md.layout.size != 16
            {
                return Err(NativeFailure::Binding(
                    "unexpected lowered dictionary/class/String size".into(),
                ));
            }
            let input_init = self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfC")?;
            let output_init = self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfC")?;
            let views_init =
                self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC")?;
            let insert_view = self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF")?;
            let dictionary_init = self.symbol(c"$sS2Dyxq_GycfC")?;
            let dictionary_insert = self.symbol(c"$sSDyq_Sgxcis")?;
            let encode = self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF")?;
            let store_none: unsafe extern "C" fn(*mut c_void, u32, u32, *mut c_void) =
                mem::transmute(interleave_md.witness(7));
            let store_some: unsafe extern "C" fn(*mut c_void, u32, u32, *mut c_void) =
                mem::transmute(input_md.witness(7));
            let copy_input: unsafe extern "C" fn(
                *mut c_void,
                *mut c_void,
                *mut c_void,
            ) -> *mut c_void = mem::transmute(input_md.witness(2));
            let errors = ErrorSupport::load(&self.runtime)?;
            let fence = c"$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaFTu";
            let ready = c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu";
            // Preflight the exact fence machinery and readiness descriptor before
            // any encode can submit work. This does not prove future success.
            let _ = self.symbol(ready)?;
            Self::lifecycle(
                &self
                    .runtime
                    .await_native(fence, [0; 4], stream.word, false)?,
            )?;
            let mut completed = 0usize;
            let mut rejected = 0usize;
            let mut error_type = String::new();
            for iteration in 0..=cycles {
                let deliberately_bad = iteration == cycles;
                ptr::write_bytes(output_start, 0xa5, 24);
                let mut async_input = NativeValue::allocate(input_md)?;
                let mut async_output = NativeValue::allocate(mutable_md)?;
                for (object, result, constructor, receiver) in [
                    (&input, &mut async_input, input_init, input_md.pointer),
                    (&output, &mut async_output, output_init, 0),
                ] {
                    let mut scalar = NativeValue::allocate(scalar_md)?;
                    self.inject(&mut scalar, NativeDType::F32.case())?;
                    let mut shape = self.int_array(&[2, 3])?;
                    let mut strides = self.int_array(&[])?;
                    let mut interleave = NativeValue::allocate(optional_interleave_md)?;
                    store_none(interleave.ptr(), 1, 1, interleave_md.pointer as _);
                    interleave.initialized = true;
                    let ordinary = [
                        object.extra_reference(),
                        0,
                        scalar.address(),
                        shape.word,
                        strides.word,
                        interleave.address(),
                    ];
                    let (returned, _, _) = call6(constructor, ordinary, result.ptr(), receiver);
                    shape.word = 0;
                    strides.word = 0;
                    scalar.initialized = false;
                    interleave.initialized = false;
                    if receiver != 0 {
                        if returned == 0 {
                            return Err(NativeFailure::Binding("AsyncValue returned null".into()));
                        }
                        result.ptr().cast::<usize>().write(returned);
                    }
                    result.initialized = true;
                }
                let mut dictionary = NativeValue::allocate(dictionary_md)?;
                let word = arm64::call_sync(
                    dictionary_init,
                    [string_md.pointer, input_md.pointer, string_hash],
                    ptr::null_mut(),
                    0,
                );
                dictionary.ptr().cast::<usize>().write(word);
                dictionary.initialized = true;
                let mut optional_input = NativeValue::allocate(optional_input_md)?;
                copy_input(
                    optional_input.ptr(),
                    async_input.ptr(),
                    input_md.pointer as _,
                );
                store_some(optional_input.ptr(), 0, 1, input_md.pointer as _);
                optional_input.initialized = true;
                let input_name = self.string(if deliberately_bad {
                    "missing_input"
                } else {
                    "x"
                })?;
                let mut key = NativeValue::allocate(string_md)?;
                ptr::copy_nonoverlapping(input_name.words.as_ptr(), key.ptr().cast::<usize>(), 2);
                mem::forget(input_name);
                key.initialized = true;
                arm64::call_sync(
                    dictionary_insert,
                    [
                        optional_input.address(),
                        key.address(),
                        dictionary_md.pointer,
                    ],
                    ptr::null_mut(),
                    dictionary.address(),
                );
                optional_input.initialized = false;
                key.initialized = false;
                let mut states = NativeValue::allocate(views_md)?;
                let mut outputs = NativeValue::allocate(views_md)?;
                arm64::call_sync(views_init, [0; 3], states.ptr(), 0);
                states.initialized = true;
                arm64::call_sync(views_init, [0; 3], outputs.ptr(), 0);
                outputs.initialized = true;
                let output_name = self.string("y")?;
                arm64::call_sync(
                    insert_view,
                    [
                        async_output.address(),
                        output_name.words[0],
                        output_name.words[1],
                    ],
                    ptr::null_mut(),
                    outputs.address(),
                );
                let mut returned = NativeValue::allocate(dictionary_md)?;
                let mut ready_result = NativeValue::allocate(optional_tensor_md)?;
                // No fallible operation intervenes between encode and its fence.
                let (word, _, error) = call6(
                    encode,
                    [
                        dictionary.ptr().cast::<usize>().read(),
                        states.address(),
                        outputs.address(),
                        stream.word,
                        0,
                        0,
                    ],
                    ptr::null_mut(),
                    record.value.address(),
                );
                states.initialized = false;
                outputs.initialized = false;
                if error == 0 {
                    returned.ptr().cast::<usize>().write(word);
                    returned.initialized = true;
                }
                let error = if error == 0 {
                    None
                } else {
                    Some(errors.take(error as _))
                };
                let drained = match self.runtime.await_native(fence, [0; 4], stream.word, false) {
                    Ok(result) => result,
                    Err(problem) => {
                        eprintln!(
                            "cannot fence pending Metal work: {problem}; aborting to retain all native storage"
                        );
                        std::process::abort();
                    }
                };
                Self::lifecycle(&drained)?;
                if let Some(error) = error {
                    let name = errors.name(&error)?;
                    if !deliberately_bad {
                        return Err(NativeFailure::Native {
                            operation: "metal_encode",
                            type_name: name,
                        });
                    }
                    error_type = name;
                    rejected += 1;
                    continue;
                }
                if deliberately_bad {
                    return Err(NativeFailure::Binding(
                        "invalid Metal input unexpectedly encoded".into(),
                    ));
                }
                let result = self.runtime.await_native(
                    ready,
                    [ready_result.address(), 0, 0, 0],
                    async_output.address(),
                    true,
                )?;
                async_output.initialized = false;
                if result.error != 0 {
                    return Err(self.failure(result.error, "metal_output_ready"));
                }
                ready_result.initialized = true;
                Self::lifecycle(&result)?;
                let array = ready_result
                    .take_optional(tensor_md)?
                    .ok_or_else(|| NativeFailure::Binding("Metal output was not NDArray".into()))?;
                let downloaded = self.read_tensor(&array)?;
                let direct = std::slice::from_raw_parts(output_start, 24);
                if downloaded.shape != [2, 3]
                    || downloaded.dtype != NativeDType::F32
                    || downloaded.bytes != expected
                    || direct != expected
                {
                    return Err(NativeFailure::Binding(format!(
                        "Metal output mismatch: shape={:?}, bytes={:02x?}, shared={:02x?}",
                        downloaded.shape, downloaded.bytes, direct
                    )));
                }
                completed += 1;
            }
            // Error names are copied runtime identifiers, escaped independently
            // of the native error object's lifetime.
            let escaped = error_type.replace('\\', "\\\\").replace('"', "\\\"");
            Ok(format!(
                "{{\"completed\":{completed},\"fenced_encode_errors\":{rejected},\"error_type\":\"{escaped}\",\"shared_output_exact\":true,\"ready_ndarray_exact\":true,\"persistent_queue\":true,\"production_integrated\":false}}"
            ))
        }
    }
}
