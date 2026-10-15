#![forbid(unsafe_code)]
use corsairs::{Compute, Error, Runtime};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut arguments = std::env::args().skip(1);
    let valid = arguments.next().ok_or("valid model path required")?;
    let paths: Vec<_> = arguments.collect();
    assert!(!paths.is_empty());
    for compute in [Compute::CpuOnly, Compute::GpuPreferred] {
        let runtime = Runtime::new()?;
        for path in &paths {
            match runtime.load_model(path, compute).wait() {
                Err(Error::Native {
                    operation,
                    type_name,
                }) => {
                    assert!(!type_name.is_empty());
                    println!(
                        "{{\"event\":\"malformed_asset\",\"compute\":\"{compute:?}\",\"path\":{path:?},\"operation\":{operation:?},\"error_type\":{type_name:?},\"passed\":true}}"
                    );
                }
                Err(error) => return Err(format!("unexpected error for {path}: {error:?}").into()),
                Ok(_) => return Err(format!("malformed model loaded: {path}").into()),
            }
        }
        let model = runtime.load_model(&valid, compute).wait()?;
        let function = model.load_function("main").wait()?;
        assert!(!function.descriptor().inputs.is_empty());
        println!("{{\"event\":\"recovery\",\"compute\":\"{compute:?}\",\"passed\":true}}");
    }
    println!("{{\"event\":\"complete\",\"passed\":true}}");
    Ok(())
}
