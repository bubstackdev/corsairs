#![forbid(unsafe_code)]
//! Mechanical capacity qualification; no H3 graph/generation equivalence claim.
use corsairs::{Compute, DType, Runtime, Tensor, TensorHandleMap, TensorMap};
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
fn inspect(value: Tensor, dtype: DType, shape: &[usize], factor: f32, label: &str) -> Result<()> {
    assert_eq!(value.dtype(),dtype); assert_eq!(value.shape(),shape);
    let mut bad = 0;
    let mut last = 0;
    for (i,c) in value.as_bytes().chunks(BLOCK).enumerate() {
        let expected=pattern(i,dtype,factor);
        if c != &expected[..c.len()] {
            bad+=1; last=i;
            if bad<=4 {
                let j=c.iter().zip(&expected).position(|(a,b)|a!=b).unwrap();
                let start=j.saturating_sub(16); let end=(j+64).min(c.len());
                println!("{label} block={i} byte={j} actual={:02x?} expected={:02x?}", &c[start..end],&expected[start..end]);
            }
        }
    }
    println!("{label} bytes={} bad_blocks={bad} last_bad={last} sha256={}",value.as_bytes().len(),digest(value.as_bytes())?);
    Ok(())
}
fn main() -> Result<()> {
    let shape=[345,1344,768,3]; let dtype=DType::Float32;
    let runtime=Runtime::new()?;
    let model=runtime.load_model("fixtures/parity-v03/large-tensors/h3-rgb345/model.aimodel",Compute::GpuPreferred).wait()?;
    let f=model.load_function("main").wait()?;
    inspect(tensor(dtype,&shape)?,dtype,&shape,1.,"host")?;
    let input=runtime.upload(tensor(dtype,&shape)?).wait()?;
    inspect(input.download().wait()?,dtype,&shape,1.,"upload-download")?;
    let first=f.run_native([("x",input.clone())].into(),TensorHandleMap::new()).wait()?;
    let y=first.outputs.get("y").ok_or("y")?;
    inspect(y.download().wait()?,dtype,&shape,2.,"native-first")?;
    inspect(y.download().wait()?,dtype,&shape,2.,"native-again")?;
    drop(first); drop(input); runtime.drain().wait()?;
    let mut owned=f.run(TensorMap::from([("x",tensor(dtype,&shape)?)]),TensorMap::new()).wait()?;
    inspect(owned.outputs.remove("y").ok_or("y")?,dtype,&shape,2.,"owned")?;
    drop((owned,f,model)); runtime.drain().wait()?;
    Ok(())
}
