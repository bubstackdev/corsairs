#![forbid(unsafe_code)]
//! Mechanical capacity qualification; no H3 graph/generation equivalence claim.
use corsairs::{Compute, DType, MetalBufferMap, Runtime, Tensor, TensorHandleMap, TensorMap};
use std::io::Write;
use std::process::{Command, Stdio};

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;
const BLOCK: usize = 1 << 20;

fn pattern(index: usize, dtype: DType, factor: f32) -> Vec<u8> {
    let seed = (1 + index % 251) as f32;
    let mut period = Vec::new();
    for value in [seed, -seed, 1., -1., 2., -2., 64., -64.] {
        let bits = (value * factor).to_bits();
        if dtype == DType::BFloat16 {
            period.extend_from_slice(&((bits >> 16) as u16).to_le_bytes());
        } else {
            period.extend_from_slice(&bits.to_le_bytes());
        }
    }
    let mut block = vec![0u8; BLOCK];
    for row in block.chunks_exact_mut(period.len()) {
        row.copy_from_slice(&period);
    }
    block
}
fn tensor(dtype: DType, shape: &[usize]) -> Result<Tensor> {
    let bytes = shape.iter().product::<usize>() * dtype.byte_width();
    let mut data = vec![0; bytes];
    for (index, chunk) in data.chunks_mut(BLOCK).enumerate() {
        chunk.copy_from_slice(&pattern(index, dtype, 1.)[..chunk.len()]);
    }
    Ok(Tensor::from_bytes(dtype, shape.to_vec(), data)?)
}
fn digest(bytes: &[u8]) -> Result<String> {
    let mut child = Command::new("/usr/bin/shasum")
        .args(["-a", "256"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;
    child.stdin.take().ok_or("hash stdin")?.write_all(bytes)?;
    let output = child.wait_with_output()?;
    if !output.status.success() {
        return Err("hash failed".into());
    }
    Ok(String::from_utf8(output.stdout)?
        .split_whitespace()
        .next()
        .ok_or("digest")?
        .to_string())
}
fn verify(value: Tensor, dtype: DType, shape: &[usize], factor: f32, label: &str) -> Result<()> {
    if value.dtype() != dtype || value.shape() != shape {
        return Err("tensor metadata".into());
    }
    for (index, chunk) in value.as_bytes().chunks(BLOCK).enumerate() {
        if chunk != &pattern(index, dtype, factor)[..chunk.len()] {
            return Err(format!("{label}: block {index} differs").into());
        }
    }
    println!(
        "{{\"event\":\"value\",\"label\":\"{label}\",\"bytes\":{},\"factor\":{factor},\"sha256\":\"{}\",\"passed\":true}}",
        value.as_bytes().len(),
        digest(value.as_bytes())?
    );
    Ok(())
}
fn main() -> Result<()> {
    let args: Vec<_> = std::env::args().collect();
    if args.len() != 5 {
        return Err("MODEL DTYPE SHAPE COMPUTE".into());
    }
    let dtype = match args[2].as_str() {
        "bfloat16" => DType::BFloat16,
        "float32" => DType::Float32,
        _ => return Err("dtype".into()),
    };
    let shape = args[3]
        .split(',')
        .map(str::parse::<usize>)
        .collect::<std::result::Result<Vec<_>, _>>()?;
    let compute = match args[4].as_str() {
        "cpu" => Compute::CpuOnly,
        "gpu-preferred" => Compute::GpuPreferred,
        _ => return Err("compute".into()),
    };
    let runtime = Runtime::new()?;
    let model = runtime.load_model(&args[1], compute).wait()?;
    let function = model.load_function("main").wait()?;
    let bytes = shape.iter().product::<usize>() * dtype.byte_width();
    println!(
        "{{\"event\":\"begin\",\"bytes\":{bytes},\"compute\":\"{}\"}}",
        args[4]
    );
    let mut owned = function
        .run(
            TensorMap::from([("x", tensor(dtype, &shape)?)]),
            TensorMap::new(),
        )
        .wait()?;
    verify(
        owned.outputs.remove("y").ok_or("owned y")?,
        dtype,
        &shape,
        2.,
        "owned",
    )?;
    drop(owned);
    runtime.drain().wait()?;
    {
        let input = runtime.upload(tensor(dtype, &shape)?).wait()?;
        let first = function
            .run_native([("x", input.clone())].into(), TensorHandleMap::new())
            .wait()?;
        let y = first.outputs.get("y").ok_or("native y")?.clone();
        verify(y.download().wait()?, dtype, &shape, 2., "native")?;
        let second = function
            .run_native([("x", y)].into(), TensorHandleMap::new())
            .wait()?;
        verify(
            second
                .outputs
                .get("y")
                .ok_or("chain y")?
                .download()
                .wait()?,
            dtype,
            &shape,
            4.,
            "native-chain",
        )?;
        drop((first, second));
        drop(function.run_native([("x", input.clone())].into(), TensorHandleMap::new()));
        runtime.drain().wait()?;
        verify(
            input.download().wait()?,
            dtype,
            &shape,
            1.,
            "native-after-abandoned",
        )?;
    }
    runtime.drain().wait()?;
    {
        let queue = runtime.metal_queue().wait()?;
        let input = queue.upload(tensor(dtype, &shape)?).wait()?;
        let binding = queue.buffer(dtype, shape.clone()).wait()?;
        let first = function
            .encode(
                &queue,
                [("x", input.clone())].into(),
                MetalBufferMap::new(),
                [("y", binding)].into(),
            )
            .wait()?;
        let y = first.outputs.get("y").ok_or("Metal y")?.clone();
        verify(y.download().wait()?, dtype, &shape, 2., "metal-bound")?;
        let second = function
            .encode(
                &queue,
                [("x", y)].into(),
                MetalBufferMap::new(),
                MetalBufferMap::new(),
            )
            .wait()?;
        verify(
            second
                .outputs
                .get("y")
                .ok_or("Metal chain y")?
                .download()
                .wait()?,
            dtype,
            &shape,
            4.,
            "metal-auto-chain",
        )?;
        drop((first, second));
        drop(function.encode(
            &queue,
            [("x", input.clone())].into(),
            MetalBufferMap::new(),
            MetalBufferMap::new(),
        ));
        queue.fence().wait()?;
        runtime.drain().wait()?;
        verify(
            input.download().wait()?,
            dtype,
            &shape,
            1.,
            "metal-after-abandoned",
        )?;
    }
    drop((function, model));
    runtime.drain().wait()?;
    println!("{{\"event\":\"complete\",\"values\":7,\"bytes\":{bytes},\"passed\":true}}");
    Ok(())
}
