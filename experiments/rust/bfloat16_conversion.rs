#![forbid(unsafe_code)]
//! Public-API conversion probe. It never opens Core AI or creates native values.
use corsairs::BFloat16;
use std::fs::{self, File};
use std::io::{BufWriter, Write};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let arguments: Vec<_> = std::env::args_os().collect();
    if arguments.len() != 4 {
        return Err("usage: bfloat16-conversion INPUT.f32le OUTPUT.bf16le WIDENED.f32le".into());
    }
    let inputs = fs::read(&arguments[1])?;
    if !inputs.len().is_multiple_of(4) {
        return Err("incomplete binary32 scalar".into());
    }
    let mut narrow = BufWriter::new(File::create(&arguments[2])?);
    let mut wide = BufWriter::new(File::create(&arguments[3])?);
    for bytes in inputs.chunks_exact(4) {
        let bits = u32::from_le_bytes(bytes.try_into()?);
        let value = BFloat16::from_f32(f32::from_bits(bits));
        narrow.write_all(&value.to_bits().to_le_bytes())?;
        wide.write_all(&value.to_f32().to_bits().to_le_bytes())?;
    }
    narrow.flush()?;
    wide.flush()?;
    println!("{{\"converted\":{}}}", inputs.len() / 4);
    Ok(())
}
