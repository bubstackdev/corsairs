#![forbid(unsafe_code)]
use corsairs::{Compute, Runtime, Tensor, TensorMap};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args_os()
        .nth(1)
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|| {
            std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("models/feedforward.aimodel")
        });
    let runtime = Runtime::new()?;
    let model = runtime.load_model(path, Compute::CpuOnly).wait()?;
    let function = model.load_function("main").wait()?;
    let x = Tensor::from_vec([2, 3], vec![1f32, -2., 3., 0., 5., -1.])?;
    let result = function
        .run(TensorMap::from([("x", x)]), TensorMap::new())
        .wait()?;
    let y = result.outputs.get("y").ok_or("missing y")?;
    assert_eq!(y.shape(), [2, 2]);
    assert_eq!(y.to_vec::<f32>()?, [6., 5., 2., 0.]);
    println!("feedforward: {:?}", y.to_vec::<f32>()?);
    Ok(())
}
