#![forbid(unsafe_code)]
use corsairs::{Compute, DType, Runtime, Tensor, TensorMap};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args_os()
        .nth(1)
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|| {
            std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("models/accumulator.aimodel")
        });
    let runtime = Runtime::new()?;
    let model = runtime.load_model(path, Compute::CpuOnly).wait()?;
    let function = model.load_function("main").wait()?;
    let mut states = TensorMap::from([("accumulator", Tensor::zeros(DType::Float32, [2, 3])?)]);
    let steps = [vec![1f32; 6], vec![2f32; 6], vec![0f32, 1., 2., 3., 4., 5.]];
    for (step, values) in steps.into_iter().enumerate() {
        let input = TensorMap::from([("x", Tensor::from_vec([2, 3], values)?)]);
        let result = function.run(input, states).wait()?;
        let values = result
            .outputs
            .get("y")
            .ok_or("missing y")?
            .to_vec::<f32>()?;
        let expected = match step {
            0 => vec![1.; 6],
            1 => vec![3.; 6],
            _ => vec![3., 4., 5., 6., 7., 8.],
        };
        assert_eq!(values, expected);
        assert_eq!(
            result
                .states
                .get("accumulator")
                .ok_or("missing state")?
                .to_vec::<f32>()?,
            expected
        );
        println!("step{step}: {values:?}");
        states = result.states;
    }
    Ok(())
}
