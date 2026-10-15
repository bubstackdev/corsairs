#![forbid(unsafe_code)]
//! Raw native storage capacity only: no model, inference, Metal queue, or arithmetic.
use corsairs::{DType, Error, MAX_TENSOR_BYTES, Runtime, Tensor};
use std::io::Write;
use std::process::{Command, Stdio};
use std::time::Instant;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;
const BLOCK_BYTES: usize = 1 << 20;
const SCALARS_PER_PERIOD: usize = 64;
const DTYPES: [DType; 6] = [
    DType::Bool,
    DType::Float16,
    DType::BFloat16,
    DType::Float32,
    DType::Int32,
    DType::Int64,
];

fn require(condition: bool, reason: &str) -> Result<()> {
    if condition {
        Ok(())
    } else {
        Err(reason.into())
    }
}

fn quoted(text: &str) -> String {
    let mut result = String::from("\"");
    for c in text.chars() {
        match c {
            '"' => result.push_str("\\\""),
            '\\' => result.push_str("\\\\"),
            '\n' => result.push_str("\\n"),
            '\r' => result.push_str("\\r"),
            '\t' => result.push_str("\\t"),
            c if c < ' ' => result.push_str(&format!("\\u{:04x}", c as u32)),
            c => result.push(c),
        }
    }
    result.push('"');
    result
}

fn flush() -> Result<()> {
    std::io::stdout().flush()?;
    Ok(())
}

fn pattern(index: usize, dtype: DType) -> Vec<u8> {
    let width = dtype.byte_width();
    let block_word = (index as u64 + 1).wrapping_mul(0x9e37_79b9_7f4a_7c15);
    let mut period = Vec::with_capacity(SCALARS_PER_PERIOD * width);
    for lane in 0..SCALARS_PER_PERIOD {
        if dtype == DType::Bool {
            // All 64 seed bits appear in a period; every Boolean byte is valid.
            period.push(((block_word >> lane) & 1) as u8);
        } else {
            // Raw scalar bits include arbitrary integer/float encodings. There
            // is no floating conversion, arithmetic, or NaN canonicalization.
            let word = block_word.wrapping_add((lane as u64).wrapping_mul(0xd1b5_4a32_d192_ed03));
            period.extend_from_slice(&word.to_le_bytes()[..width]);
        }
    }
    let mut block = vec![0; BLOCK_BYTES];
    for destination in block.chunks_exact_mut(period.len()) {
        destination.copy_from_slice(&period);
    }
    block
}

fn input(dtype: DType) -> Result<Tensor> {
    let mut bytes = Vec::new();
    bytes.try_reserve_exact(MAX_TENSOR_BYTES)?;
    for index in 0..MAX_TENSOR_BYTES / BLOCK_BYTES {
        bytes.extend_from_slice(&pattern(index, dtype));
    }
    Tensor::from_bytes(dtype, [MAX_TENSOR_BYTES / dtype.byte_width()], bytes).map_err(Into::into)
}

fn digest(bytes: &[u8]) -> Result<String> {
    let mut child = Command::new("/usr/bin/shasum")
        .args(["-a", "256"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;
    child.stdin.take().ok_or("hash stdin")?.write_all(bytes)?;
    let output = child.wait_with_output()?;
    require(output.status.success(), "shasum failed")?;
    let value = String::from_utf8(output.stdout)?;
    let hash = value.split_whitespace().next().ok_or("missing digest")?;
    require(
        hash.len() == 64 && hash.bytes().all(|b| b.is_ascii_hexdigit()),
        "invalid digest",
    )?;
    Ok(hash.to_owned())
}

fn reject_before_native(dtype: DType) -> Result<()> {
    let maximum = MAX_TENSOR_BYTES / dtype.byte_width();
    for (constructor, result) in [
        (
            "from_bytes",
            Tensor::from_bytes(dtype, [0, maximum + 1], Vec::new()),
        ),
        ("zeros", Tensor::zeros(dtype, [0, maximum + 1])),
    ] {
        require(
            matches!(result, Err(Error::TensorLimit(_))),
            "expected typed TensorLimit before native",
        )?;
        println!(
            "{{\"event\":\"value\",\"label\":\"empty-over-limit\",\"phase\":\"before-runtime\",\"constructor\":\"{constructor}\",\"dtype\":\"{dtype}\",\"shape\":[0,{}],\"bytes\":0,\"error\":\"TensorLimit\",\"passed\":true}}",
            maximum + 1
        );
        flush()?;
    }
    Ok(())
}

fn empty_round_trip(runtime: &Runtime, dtype: DType) -> Result<()> {
    let shape = [0, MAX_TENSOR_BYTES / dtype.byte_width()];
    let host = Tensor::from_bytes(dtype, shape, Vec::new())?;
    let native = runtime.upload(host).wait()?;
    require(
        native.dtype() == dtype && native.shape() == shape,
        "empty native metadata",
    )?;
    let downloaded = native.download().wait()?;
    require(
        downloaded.dtype() == dtype
            && downloaded.shape() == shape
            && downloaded.as_bytes().is_empty()
            && downloaded.strides() == [0, 0],
        "empty downloaded metadata/storage",
    )?;
    println!(
        "{{\"event\":\"value\",\"label\":\"empty-upload-download\",\"dtype\":\"{dtype}\",\"shape\":{shape:?},\"bytes\":0,\"sha256\":\"{}\",\"mismatch_bytes\":0,\"passed\":true}}",
        digest(downloaded.as_bytes())?
    );
    flush()?;
    drop((downloaded, native));
    Ok(())
}

fn full_round_trip(runtime: &Runtime, dtype: DType) -> Result<()> {
    let shape = [MAX_TENSOR_BYTES / dtype.byte_width()];
    let started = Instant::now();
    let host = input(dtype)?;
    let expected_hash = digest(host.as_bytes())?;
    println!(
        "{{\"event\":\"value\",\"label\":\"host-input\",\"dtype\":\"{dtype}\",\"shape\":{shape:?},\"bytes\":{MAX_TENSOR_BYTES},\"sha256\":\"{expected_hash}\",\"passed\":true}}"
    );
    flush()?;
    // Upload consumes the only 4 GiB host input. No host clone or model exists.
    let native = runtime.upload(host).wait()?;
    require(
        native.dtype() == dtype && native.shape() == shape,
        "full native metadata",
    )?;
    let downloaded = native.download().wait()?;
    require(
        downloaded.dtype() == dtype
            && downloaded.shape() == shape
            && downloaded.as_bytes().len() == MAX_TENSOR_BYTES
            && downloaded.strides() == [1],
        "full downloaded metadata/storage",
    )?;
    let actual_hash = digest(downloaded.as_bytes())?;
    let mut mismatch_bytes = 0usize;
    let mut first = None;
    for (index, actual) in downloaded.as_bytes().chunks(BLOCK_BYTES).enumerate() {
        let expected = pattern(index, dtype);
        if actual != expected {
            for (offset, (&actual, &expected)) in actual.iter().zip(&expected).enumerate() {
                if actual != expected {
                    mismatch_bytes += 1;
                    first.get_or_insert((index * BLOCK_BYTES + offset, expected, actual));
                }
            }
        }
    }
    let passed = mismatch_bytes == 0 && actual_hash == expected_hash;
    let first = first.map_or_else(
        || "null".to_owned(),
        |(offset, expected, actual)| {
            format!("{{\"byte_offset\":{offset},\"expected\":{expected},\"actual\":{actual}}}")
        },
    );
    println!(
        "{{\"event\":\"value\",\"label\":\"full-upload-download\",\"dtype\":\"{dtype}\",\"shape\":{shape:?},\"bytes\":{MAX_TENSOR_BYTES},\"sha256\":\"{actual_hash}\",\"expected_sha256\":\"{expected_hash}\",\"mismatch_bytes\":{mismatch_bytes},\"first_mismatch\":{first},\"seconds\":{},\"passed\":{passed}}}",
        started.elapsed().as_secs_f64()
    );
    flush()?;
    drop((downloaded, native));
    require(passed, "full storage bytes differ")
}

fn run() -> Result<()> {
    require(
        MAX_TENSOR_BYTES == 4_294_967_296,
        "probe requires the frozen four-GiB capacity",
    )?;
    let args: Vec<_> = std::env::args().collect();
    require(
        args.len() <= 2,
        "usage: large-storage [all|bool|float16|bfloat16|float32|int32|int64]",
    )?;
    let selection = args.get(1).map(String::as_str).unwrap_or("all");
    let dtypes: Vec<_> = DTYPES
        .into_iter()
        .filter(|d| selection == "all" || selection == d.name())
        .collect();
    require(!dtypes.is_empty(), "unknown dtype")?;
    // Every invalid empty shape is rejected before Runtime::new or any upload.
    for &dtype in &dtypes {
        reject_before_native(dtype)?;
    }
    println!(
        "{{\"event\":\"begin\",\"dtypes\":{},\"maximum_bytes\":{MAX_TENSOR_BYTES},\"models\":0,\"queues\":0,\"pattern_version\":1}}",
        dtypes.len()
    );
    flush()?;
    let runtime = Runtime::new()?;
    let mut full_passed = 0;
    let mut empty_passed = 0;
    for &dtype in &dtypes {
        for label in ["empty", "full"] {
            let result = if label == "empty" {
                empty_round_trip(&runtime, dtype)
            } else {
                full_round_trip(&runtime, dtype)
            };
            match result {
                Ok(()) => {
                    if label == "full" {
                        full_passed += 1;
                    } else {
                        empty_passed += 1;
                    }
                }
                Err(error) => {
                    println!(
                        "{{\"event\":\"error\",\"label\":\"{label}\",\"dtype\":\"{dtype}\",\"message\":{},\"passed\":false}}",
                        quoted(&error.to_string())
                    );
                    flush()?;
                }
            }
            runtime.drain().wait()?;
            println!("{{\"event\":\"drained\",\"dtype\":\"{dtype}\",\"label\":\"{label}\"}}");
            flush()?;
        }
    }
    let passed = full_passed == dtypes.len() && empty_passed == dtypes.len();
    println!(
        "{{\"event\":\"complete\",\"selected_dtypes\":{},\"full_round_trips\":{full_passed},\"empty_round_trips\":{empty_passed},\"typed_negative_cases\":{},\"passed\":{passed}}}",
        dtypes.len(),
        dtypes.len() * 2
    );
    flush()?;
    require(passed, "raw-storage qualification incomplete")
}

fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
