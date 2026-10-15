#![forbid(unsafe_code)]
//! Native handle ownership/alias integration driver; development tooling only.
use corsairs::{Compute, DType, Error, Runtime, Tensor, TensorHandleMap};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<_> = std::env::args_os().skip(1).collect();
    if args.len() != 2 {
        return Err("usage: native-handles DOUBLE_MODEL ACCUMULATOR_MODEL".into());
    }
    let runtime = Runtime::new()?;
    let model = runtime.load_model(&args[0], Compute::CpuOnly).wait()?;
    let first = model.load_function("main").wait()?;
    let second = model.load_function("main").wait()?;
    let original = runtime
        .upload(Tensor::from_vec([2, 3], vec![1f32; 6])?)
        .wait()?;
    let retained = original.clone();
    drop(original);
    assert_eq!(retained.download().wait()?.to_vec::<f32>()?, [1.; 6]);
    let result = first
        .run_native(
            TensorHandleMap::from([("x", retained)]),
            TensorHandleMap::new(),
        )
        .wait()?;
    let next = result.outputs.get("y").ok_or("missing first y")?.clone();
    drop(result);
    let result = second
        .run_native(TensorHandleMap::from([("x", next)]), TensorHandleMap::new())
        .wait()?;
    assert_eq!(
        result
            .outputs
            .get("y")
            .ok_or("missing second y")?
            .download()
            .wait()?
            .to_vec::<f32>()?,
        [4.; 6]
    );
    println!("{{\"event\":\"chain_two_functions\",\"passed\":true}}");

    let other = Runtime::new()?;
    let foreign = other
        .upload(Tensor::from_vec([2, 3], vec![1f32; 6])?)
        .wait()?;
    assert!(matches!(
        runtime.download(&foreign).wait(),
        Err(Error::Unsupported(_))
    ));
    assert!(matches!(
        first
            .run_native(
                TensorHandleMap::from([("x", foreign)]),
                TensorHandleMap::new()
            )
            .wait(),
        Err(Error::Unsupported(_))
    ));
    println!("{{\"event\":\"cross_runtime\",\"passed\":true}}");

    let accumulator = runtime
        .load_model(&args[1], Compute::CpuOnly)
        .wait()?
        .load_function("main")
        .wait()?;
    let state = runtime
        .upload(Tensor::zeros(DType::Float32, [2, 3])?)
        .wait()?;
    let state_clone = state.clone();
    let ones = runtime
        .upload(Tensor::from_vec([2, 3], vec![1f32; 6])?)
        .wait()?;
    for expected in 1..=2 {
        let result = accumulator
            .run_native(
                TensorHandleMap::from([("x", ones.clone())]),
                TensorHandleMap::from([("accumulator", state.clone())]),
            )
            .wait()?;
        assert_eq!(
            result
                .outputs
                .get("y")
                .ok_or("missing accumulator y")?
                .download()
                .wait()?
                .to_vec::<f32>()?,
            vec![expected as f32; 6]
        );
        assert_eq!(
            state_clone.download().wait()?.to_vec::<f32>()?,
            vec![expected as f32; 6]
        );
    }
    drop(accumulator.run_native(
        TensorHandleMap::from([("x", ones)]),
        TensorHandleMap::from([("accumulator", state.clone())]),
    ));
    runtime.flush().wait()?;
    runtime.flush().wait()?;
    assert_eq!(state_clone.download().wait()?.to_vec::<f32>()?, [3.; 6]);
    println!("{{\"event\":\"shared_state_and_dropped_future\",\"passed\":true}}");

    assert!(
        accumulator
            .run_native(
                TensorHandleMap::from([("x", state.clone())]),
                TensorHandleMap::from([("accumulator", state.clone())])
            )
            .wait()
            .is_err()
    );
    let derived = first
        .run_native(
            TensorHandleMap::from([("x", state.clone())]),
            TensorHandleMap::new(),
        )
        .wait()?;
    let derived = derived.outputs.get("y").ok_or("missing derived y")?.clone();
    assert!(
        accumulator
            .run_native(
                TensorHandleMap::from([("x", derived)]),
                TensorHandleMap::from([("accumulator", state)])
            )
            .wait()
            .is_err()
    );
    assert_eq!(state_clone.download().wait()?.to_vec::<f32>()?, [3.; 6]);
    println!("{{\"event\":\"mutable_alias_rejection\",\"passed\":true}}");
    println!("{{\"event\":\"complete\",\"passed\":true}}");
    Ok(())
}
