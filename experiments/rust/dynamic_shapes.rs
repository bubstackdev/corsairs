#![forbid(unsafe_code)]
use corsairs::{Compute, DType, Error, LoadOptions, Runtime, Tensor, TensorHandleMap, TensorMap};
use std::{fs, path::PathBuf};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let directory = PathBuf::from(std::env::args_os().nth(1).ok_or("fixture path required")?);
    for compute in [Compute::CpuOnly, Compute::GpuPreferred] {
        for setting in [None, Some(false), Some(true)] {
            let options = setting.map_or(LoadOptions::from(compute), |value| {
                LoadOptions::from(compute).with_expect_frequent_reshapes(value)
            });
            let runtime = Runtime::new()?;
            let model = runtime
                .load_model_with_options(directory.join("model.aimodel"), options)
                .wait()?;
            assert_eq!(model.load_options(), options);
            let function = model.load_function("main").wait()?;
            assert_eq!(function.descriptor().inputs[0].shape, [None, Some(3)]);
            assert_eq!(function.descriptor().outputs[0].shape, [None, Some(3)]);
            for (index, rows) in [1, 4, 2, 1].into_iter().enumerate() {
                let x = Tensor::from_bytes(
                    DType::Float32,
                    [rows, 3],
                    fs::read(directory.join(format!("{index}-x.f32")))?,
                )?;
                let native = runtime.upload(x.clone()).wait()?;
                let result = function
                    .run(TensorMap::from([("x", x)]), TensorMap::new())
                    .wait()?;
                let y = result.outputs.get("y").ok_or("missing y")?;
                assert_eq!(y.shape(), [rows, 3]);
                assert_eq!(y.dtype(), DType::Float32);
                assert_eq!(
                    y.as_bytes(),
                    fs::read(directory.join(format!("{index}-expected-y.f32")))?
                );
                let result = function
                    .run_native(
                        TensorHandleMap::from([("x", native)]),
                        TensorHandleMap::new(),
                    )
                    .wait()?;
                let y = result.outputs.get("y").ok_or("missing native y")?;
                assert_eq!(y.shape(), [rows, 3]);
                assert_eq!(y.dtype(), DType::Float32);
                assert_eq!(
                    y.download().wait()?.as_bytes(),
                    fs::read(directory.join(format!("{index}-expected-y.f32")))?
                );
            }
            for (dtype, shape) in [
                (DType::Float32, vec![1, 4]),
                (DType::Float32, vec![3]),
                (DType::Int32, vec![1, 3]),
            ] {
                let tensor = Tensor::zeros(dtype, shape)?;
                let native = runtime.upload(tensor.clone()).wait()?;
                assert!(matches!(
                    function
                        .run(TensorMap::from([("x", tensor)]), TensorMap::new())
                        .wait(),
                    Err(Error::DescriptorMismatch { .. })
                ));
                assert!(matches!(
                    function
                        .run_native(
                            TensorHandleMap::from([("x", native)]),
                            TensorHandleMap::new()
                        )
                        .wait(),
                    Err(Error::DescriptorMismatch { .. })
                ));
            }
            println!(
                "{{\"compute\":\"{compute:?}\",\"frequent_reshapes\":\"{setting:?}\",\"owned_dynamic_calls\":4,\"native_dynamic_calls\":4,\"owned_negative_calls\":3,\"native_negative_calls\":3,\"passed\":true}}"
            );
        }
    }
    println!("{{\"event\":\"complete\",\"passed\":true}}");
    Ok(())
}
