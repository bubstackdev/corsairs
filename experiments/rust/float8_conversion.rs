#![forbid(unsafe_code)]
//! Convert binary32 inputs to both float8 types and widen every encoding.
use corsairs::{Float8E4M3Fn, Float8E5M2};
use std::{env, fs};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<_> = env::args().collect();
    let [_, input, output] = args.as_slice() else {
        return Err("usage: float8-conversion INPUT.f32le OUTPUT_DIR".into());
    };
    let bytes = fs::read(input)?;
    let inputs: Vec<f32> = bytes
        .chunks_exact(4)
        .map(|word| f32::from_le_bytes(word.try_into().unwrap()))
        .collect();
    let narrow_e4 = inputs.iter().map(|&v| Float8E4M3Fn::from_f32(v).to_bits()).collect::<Vec<_>>();
    let narrow_e5 = inputs.iter().map(|&v| Float8E5M2::from_f32(v).to_bits()).collect::<Vec<_>>();
    let widen = |f: fn(u8) -> f32| (0..=255u8).flat_map(|b| f(b).to_le_bytes()).collect::<Vec<_>>();
    fs::write(format!("{output}/e4m3fn-narrow.u8"), narrow_e4)?;
    fs::write(format!("{output}/e5m2-narrow.u8"), narrow_e5)?;
    fs::write(format!("{output}/e4m3fn-widen.f32le"), widen(|b| Float8E4M3Fn::from_bits(b).to_f32()))?;
    fs::write(format!("{output}/e5m2-widen.f32le"), widen(|b| Float8E5M2::from_bits(b).to_f32()))?;
    println!("{{\"converted\":{}}}", inputs.len());
    Ok(())
}
