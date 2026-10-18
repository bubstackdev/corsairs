//! Choose a completion contract before dispatch, not by inspecting output bytes.
use super::*;

// The previous release's bounded convenience-run envelope. This is a support
// policy for stateful GPU calls, not an inferred universal framework/GPU limit.
const STATEFUL_GPU_BYTES: usize = 1 << 30;

pub(super) fn gpu_shape(dtype: NativeDType, shape: &[usize]) -> Result<()> {
    crate::dtype::element_count_with_limit(
        shape,
        dtype.byte_width(),
        crate::dtype::MAX_GPU_INFERENCE_TENSOR_BYTES,
    )
    .map(|_| ())
    .map_err(|error| {
        NativeFailure::Unsupported(format!(
            "GPU-preferred tensor exceeds the 2 GiB inference boundary: {error}"
        ))
    })
}

pub(super) fn gpu_span(bytes: usize) -> Result<()> {
    if bytes > crate::dtype::MAX_GPU_INFERENCE_TENSOR_BYTES {
        Err(NativeFailure::Unsupported(
            "GPU-preferred tensor referenced span exceeds the 2 GiB inference boundary".into(),
        ))
    } else {
        Ok(())
    }
}

pub(super) fn gpu_descriptors(descriptor: &NativeFunctionDescriptor) -> Result<()> {
    for tensor in descriptor
        .inputs
        .iter()
        .chain(&descriptor.states)
        .chain(&descriptor.outputs)
    {
        if tensor.shape.iter().all(|dimension| *dimension >= 0) {
            gpu_shape(
                tensor.dtype,
                &tensor
                    .shape
                    .iter()
                    .map(|dimension| *dimension as usize)
                    .collect::<Vec<_>>(),
            )?;
        }
        // Unknown outputs cannot be bounded from input shapes. Their actual
        // shape/span are checked after fenced readiness and before publication.
    }
    Ok(())
}

fn uses_stream(compute: NativeCompute, descriptor: &NativeFunctionDescriptor) -> Result<bool> {
    if compute == NativeCompute::CpuOnly {
        return Ok(false);
    }
    gpu_descriptors(descriptor)?;
    let images = descriptor.has_images();
    if descriptor.states.is_empty() && !images {
        return Ok(true);
    }
    // Stateful and image calls use the plain run(inputs:states:outputViews:)
    // path. The image oracle measured it byte-exact under GPU and Neural Engine
    // preference (docs/image-io.md); the stream's pixel-buffer AsyncValue
    // constructors are not bound. Both keep the fixed one-GiB envelope.
    let limit = if images { image_limit } else { stateful_limit };
    for tensor in descriptor
        .inputs
        .iter()
        .chain(&descriptor.states)
        .chain(&descriptor.outputs)
    {
        let mut extent = tensor.dtype.byte_width();
        for &dimension in &tensor.shape {
            if dimension < 0 {
                return Err(limit());
            }
            // Include nonzero extents of empty shapes, matching the checked
            // stride guard used by the previous one-GiB release boundary.
            extent = extent
                .checked_mul((dimension as usize).max(1))
                .filter(|bytes| *bytes <= STATEFUL_GPU_BYTES)
                .ok_or_else(limit)?;
        }
    }
    for image in descriptor
        .image_inputs
        .iter()
        .chain(&descriptor.image_outputs)
    {
        // Unsupported formats are rejected per call, before any buffer exists.
        if let Ok((_, bytes)) =
            super::image::tight_extent(image.pixel_format, image.width, image.height)
            && bytes > STATEFUL_GPU_BYTES
        {
            return Err(limit());
        }
    }
    Ok(false)
}

fn image_limit() -> NativeFailure {
    NativeFailure::Unsupported(
        "accelerated image runs require fixed tensor signatures and images within 1 GiB per value; use CPU-only execution".into(),
    )
}

fn stateful_limit() -> NativeFailure {
    NativeFailure::Unsupported(
        "stateful GPU run requires fixed input/state/output signatures within 1 GiB per tensor; use CPU-only execution or explicit Metal state bindings".into(),
    )
}

impl NativeSession {
    pub(super) fn function_compute(&self, function: u64) -> Result<NativeCompute> {
        let function = self
            .functions
            .get(&function)
            .ok_or(NativeFailure::InvalidHandle {
                kind: "function",
                id: function,
            })?;
        Ok(self
            .models
            .get(&function.model)
            .ok_or(NativeFailure::InvalidHandle {
                kind: "model",
                id: function.model,
            })?
            .compute)
    }
    pub(super) fn uses_owned_stream(&self, function: u64) -> Result<bool> {
        let function = self
            .functions
            .get(&function)
            .ok_or(NativeFailure::InvalidHandle {
                kind: "function",
                id: function,
            })?;
        let model = self
            .models
            .get(&function.model)
            .ok_or(NativeFailure::InvalidHandle {
                kind: "model",
                id: function.model,
            })?;
        uses_stream(model.compute, &function.descriptor)
    }

    /// # Safety
    /// Called only on the owning worker for a stateless GPU function.
    pub(super) unsafe fn run_owned_on_stream(
        &mut self,
        function: u64,
        inputs: Vec<(String, NativeTensor)>,
        states: Vec<(String, NativeTensor)>,
    ) -> Result<NativeRunResult> {
        let descriptor = &self.functions[&function].descriptor;
        validate_group(&inputs, &descriptor.inputs, true)?;
        validate_group(&states, &descriptor.states, true)?;
        for (_, input) in &inputs {
            gpu_shape(input.dtype, &input.shape)?;
        }
        let mut temporaries = Vec::new();
        // SAFETY: Every temporary stays in the session through submission and
        // true completion. Remove all input and output records on every Result.
        let result = unsafe {
            (|| {
                let mut handles = Vec::new();
                for (name, tensor) in inputs {
                    let handle = self.upload_tensor(tensor)?;
                    temporaries.push(handle.id);
                    handles.push((name, handle.id));
                }
                let result = self.run_native(function, handles, Vec::new())?;
                temporaries.extend(result.outputs.iter().map(|(_, handle)| handle.id));
                let outputs = result
                    .outputs
                    .into_iter()
                    .map(|(name, handle)| {
                        self.download_tensor(handle.id).map(|tensor| (name, tensor))
                    })
                    .collect::<Result<Vec<_>>>()?;
                Ok(NativeRunResult {
                    outputs,
                    states: Vec::new(),
                    images: Vec::new(),
                })
            })()
        };
        for id in temporaries {
            self.tensors.remove(&id);
        }
        result
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn descriptor() -> NativeFunctionDescriptor {
        let tensor = NativeTensorDescriptor {
            name: "x".into(),
            dtype: NativeDType::F32,
            shape: vec![2, 3],
        };
        NativeFunctionDescriptor {
            name: "main".into(),
            inputs: vec![tensor.clone()],
            states: Vec::new(),
            outputs: vec![tensor],
            image_inputs: Vec::new(),
            image_outputs: Vec::new(),
        }
    }

    #[test]
    fn gpu_stateless_calls_use_stream_even_for_dynamic_outputs() {
        let mut d = descriptor();
        assert!(uses_stream(NativeCompute::GpuPreferred, &d).unwrap());
        d.outputs[0].shape = vec![-1, 3];
        assert!(uses_stream(NativeCompute::GpuPreferred, &d).unwrap());
        assert!(!uses_stream(NativeCompute::CpuOnly, &d).unwrap());
    }

    #[test]
    fn gpu_inference_boundary_covers_all_widths_and_empty_overflow_without_allocating() {
        let limit = crate::dtype::MAX_GPU_INFERENCE_TENSOR_BYTES;
        for dtype in [
            NativeDType::Bool,
            NativeDType::F16,
            NativeDType::Bf16,
            NativeDType::F32,
            NativeDType::I32,
            NativeDType::I64,
        ] {
            let scalars = limit / dtype.byte_width();
            assert!(gpu_shape(dtype, &[scalars]).is_ok());
            assert!(matches!(
                gpu_shape(dtype, &[scalars + 1]),
                Err(NativeFailure::Unsupported(_))
            ));
            assert!(gpu_shape(dtype, &[0, scalars + 1]).is_err());
            assert!(gpu_shape(dtype, &[usize::MAX, 2]).is_err());
        }
        assert!(gpu_span(limit).is_ok());
        assert!(gpu_span(limit + 1).is_err());
        let mut d = descriptor();
        d.outputs[0].shape = vec![limit as isize / 4 + 1];
        assert!(uses_stream(NativeCompute::GpuPreferred, &d).is_err());
        assert!(!uses_stream(NativeCompute::CpuOnly, &d).unwrap());
        // A dynamic result is checked after readiness, not inferred from input.
        d.outputs[0].shape = vec![-1];
        assert!(uses_stream(NativeCompute::GpuPreferred, &d).unwrap());
    }

    #[test]
    fn image_signatures_use_the_plain_run_path_within_the_envelope() {
        let mut d = descriptor();
        d.image_outputs.push(NativeImageDescriptor {
            name: "image".into(),
            width: 4,
            height: 2,
            pixel_format: super::super::image::BGRA32,
        });
        for compute in [
            NativeCompute::GpuPreferred,
            NativeCompute::NeuralEnginePreferred,
        ] {
            assert!(!uses_stream(compute, &d).unwrap());
        }
        assert!(!uses_stream(NativeCompute::CpuOnly, &d).unwrap());
        let mut dynamic = d.clone();
        dynamic.inputs[0].shape = vec![-1, 3];
        assert!(uses_stream(NativeCompute::GpuPreferred, &dynamic).is_err());
        d.image_outputs[0].width = STATEFUL_GPU_BYTES / 4 / 2 + 1;
        assert!(matches!(
            uses_stream(NativeCompute::GpuPreferred, &d),
            Err(NativeFailure::Unsupported(_))
        ));
        assert!(!uses_stream(NativeCompute::CpuOnly, &d).unwrap());
    }

    #[test]
    fn stateful_gpu_preserves_fixed_envelope_and_rejects_unbounded_dispatch() {
        let mut d = descriptor();
        d.states = d.inputs.clone();
        assert!(!uses_stream(NativeCompute::GpuPreferred, &d).unwrap());
        for group in 0..3 {
            for shape in [
                vec![-1, 3],
                vec![STATEFUL_GPU_BYTES as isize / 4 + 1],
                vec![0, STATEFUL_GPU_BYTES as isize],
            ] {
                let mut bad = d.clone();
                [&mut bad.inputs, &mut bad.states, &mut bad.outputs][group][0].shape = shape;
                assert!(matches!(
                    uses_stream(NativeCompute::GpuPreferred, &bad),
                    Err(NativeFailure::Unsupported(_))
                ));
                assert!(!uses_stream(NativeCompute::CpuOnly, &bad).unwrap());
            }
        }
        d.states[0].shape = vec![STATEFUL_GPU_BYTES as isize / 4];
        assert!(!uses_stream(NativeCompute::GpuPreferred, &d).unwrap());
    }
}
