#![forbid(unsafe_code)]
//! Pure public-API float conversion probe; no Core AI calls or native tensors.
use corsairs::Float16;
use std::fs::{self, File};
use std::io::{BufWriter, Write};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let arguments: Vec<_> = std::env::args_os().collect();
    if arguments.len() != 4 {
        return Err("usage: float16-conversion INPUT.f32le OUTPUT.f16le WIDENED.f32le".into());
    }
    let inputs = fs::read(&arguments[1])?;
    if !inputs.len().is_multiple_of(4) {
        return Err("input length is not a whole number of binary32 scalars".into());
    }
    let mut half = BufWriter::new(File::create(&arguments[2])?);
    let mut widened = BufWriter::new(File::create(&arguments[3])?);
    for bytes in inputs.chunks_exact(4) {
        let bits = u32::from_le_bytes(bytes.try_into()?);
        let value = Float16::from_f32(f32::from_bits(bits));
        half.write_all(&value.to_bits().to_le_bytes())?;
        widened.write_all(&value.to_f32().to_bits().to_le_bytes())?;
    }
    half.flush()?;
    widened.flush()?;
    println!("{{\"converted\":{}}}", inputs.len() / 4);
    Ok(())
}
