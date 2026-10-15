#![forbid(unsafe_code)]
use corsairs::{Compute, DType, MetalBufferMap, Runtime, Tensor};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let assets = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("models");
    let runtime = Runtime::new()?;
    let accumulator = runtime
        .load_model(assets.join("accumulator.aimodel"), Compute::GpuPreferred)
        .wait()?
        .load_function("main")
        .wait()?;
    let feedforward = runtime
        .load_model(assets.join("feedforward.aimodel"), Compute::GpuPreferred)
        .wait()?
        .load_function("main")
        .wait()?;
    let queue = runtime.metal_queue().wait()?;
    let x = queue
        .upload(Tensor::from_vec([2, 3], vec![1f32, -2., 3., 0., 5., -1.])?)
        .wait()?;
    let state = queue.buffer(DType::Float32, vec![2, 3]).wait()?;
    let carry = queue.buffer(DType::Float32, vec![2, 3]).wait()?;
    let y = queue.buffer(DType::Float32, vec![2, 2]).wait()?;
    let first = accumulator
        .encode(
            &queue,
            [("x", x)].into(),
            [("accumulator", state)].into(),
            [("y", carry)].into(),
        )
        .wait()?;
    let input = first.outputs.get("y").ok_or("missing carry")?.clone();
    drop(first);
    let result = feedforward
        .encode(
            &queue,
            [("x", input)].into(),
            MetalBufferMap::new(),
            [("y", y)].into(),
        )
        .wait()?;
    let result = result
        .outputs
        .get("y")
        .ok_or("missing y")?
        .download()
        .wait()?;
    assert_eq!(result.to_vec::<f32>()?, [6., 5., 2., 0.]);
    println!("Metal chain: {:?}", result.to_vec::<f32>()?);
    Ok(())
}
