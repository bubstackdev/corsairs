#![forbid(unsafe_code)]
use corsairs::{
    Compute, DType, FunctionLoadRequest, ModelLoadRequest, Runtime, Tensor, TensorHandleMap,
};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let assets = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("models");
    let runtime = Runtime::new()?;
    let models = runtime
        .load_models(
            ["accumulator.aimodel", "feedforward.aimodel"]
                .map(|name| ModelLoadRequest {
                    path: assets.join(name),
                    options: Compute::CpuOnly.into(),
                })
                .into(),
        )
        .wait()?;
    let functions = runtime
        .load_functions(
            models
                .iter()
                .map(|model| FunctionLoadRequest {
                    model: model.clone(),
                    name: "main".into(),
                })
                .collect(),
        )
        .wait()?;
    let accumulator = &functions[0];
    let feedforward = &functions[1];
    let x = runtime
        .upload(Tensor::from_vec([2, 3], vec![1f32, -2., 3., 0., 5., -1.])?)
        .wait()?;
    let state = runtime
        .upload(Tensor::zeros(DType::Float32, [2, 3])?)
        .wait()?;
    let first = accumulator
        .run_native([("x", x)].into(), [("accumulator", state)].into())
        .wait()?;
    let carry = first.outputs.get("y").ok_or("missing carry")?.clone();
    drop(first);
    // The intermediate stays in native storage across the function boundary.
    let result = feedforward
        .run_native([("x", carry)].into(), TensorHandleMap::new())
        .wait()?;
    let y = result
        .outputs
        .get("y")
        .ok_or("missing y")?
        .download()
        .wait()?;
    assert_eq!(y.to_vec::<f32>()?, [6., 5., 2., 0.]);
    println!("native chain: {:?}", y.to_vec::<f32>()?);
    Ok(())
}
