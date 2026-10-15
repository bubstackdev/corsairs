use corsairs_abi::native::{
    FUNCTION_METADATA, MODEL_METADATA, NDARRAY_METADATA, Runtime, SCALAR_METADATA,
};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<_> = std::env::args().skip(1).collect();
    match args.first().map(String::as_str) {
        Some("metadata") if args.len() == 1 => metadata(),
        Some("infer") if (2..=3).contains(&args.len()) => {
            let cycles = args.get(2).map_or(Ok(1), |s| s.parse::<usize>())?;
            // SAFETY: Explicit local fixture and fixed experimental native ABI.
            let runtime = unsafe { Runtime::open()? };
            // SAFETY: Known float32 fixture; every native value lives through completion.
            let report = unsafe { runtime.inference_probe(std::path::Path::new(&args[1]), cycles)? };
            println!("{{\"cycles\":{},\"completed\":{},\"output_shape\":{:?},\"output_strides\":{:?},\"is_float32\":{},\"output_bits\":{:?},\"exact_bytes_match\":{},\"output_count\":{},\"remaining_outputs\":{}}}", report.cycles, report.completed, report.shape, report.strides, report.is_float32, report.output_bits, report.exact_bytes_match, report.output_count, report.remaining_outputs);
            Ok(())
        }
        Some("model") if (2..=3).contains(&args.len()) => {
            let cycles = args.get(2).map_or(Ok(1), |s| s.parse::<usize>())?;
            // SAFETY: Explicit local asset and fixed experimental native ABI.
            let runtime = unsafe { Runtime::open()? };
            // SAFETY: Blocking model probe retains all storage until completion.
            let report = unsafe { runtime.model_probe(std::path::Path::new(&args[1]), cycles)? };
            let names = report.function_names.iter().map(|name| json_string(name)).collect::<Vec<_>>().join(",");
            println!("{{\"cycles\":{},\"loaded\":{},\"destroyed\":{},\"caught\":{},\"errors_released\":{},\"function_names\":[{}],\"error_type\":{},\"native_completions\":{}}}", report.cycles, report.loaded, report.destroyed, report.caught, report.errors_released, names, json_string(&report.error_type), report.native_completions);
            Ok(())
        }
        Some("suspend") if args.len() <= 2 => {
            let cycles = args.get(1).map_or(Ok(1), |s| s.parse::<usize>())?;
            // SAFETY: Fixed native yield callee, owned state, documented ABI.
            let runtime = unsafe { Runtime::open()? };
            // SAFETY: Probe exposes no borrowed captures or arbitrary callees.
            let report = unsafe { runtime.suspension_probe(cycles)? };
            println!("{{\"cycles\":{},\"resumes\":{},\"task_identity_matches\":{},\"resumed_on_other_thread\":{},\"native_completions\":{},\"tls_restored\":{}}}", report.cycles, report.resumes, report.task_identity_matches, report.resumed_on_other_thread, report.native_completions, report.tls_restored);
            Ok(())
        }
        Some("task") if args.len() <= 2 => {
            let cycles = args.get(1).map_or(Ok(1), |s| s.parse::<usize>())?;
            // SAFETY: Known nonsuspending task body and recorded runtime ABI.
            let runtime = unsafe { Runtime::open()? };
            // SAFETY: No user-supplied task or borrowed captures can be passed.
            let report = unsafe { runtime.task_probe(cycles)? };
            println!("{{\"cycles\":{},\"bodies_executed\":{},\"task_identity_matches\":{},\"tls_restored\":{}}}", report.cycles, report.bodies_executed, report.task_identity_matches, report.tls_restored);
            Ok(())
        }
        Some("bookmark-error") if args.len() <= 2 => {
            let cycles = args.get(1).map_or(Ok(1), |s| s.parse::<usize>())?;
            // SAFETY: Deliberate native error experiment on documented platform.
            let runtime = unsafe { Runtime::open()? };
            // SAFETY: Verified Data/throwing ownership and x21 contracts.
            let report = unsafe { runtime.bookmark_error_probe(cycles)? };
            println!("{{\"attempts\":{},\"caught\":{},\"released\":{},\"error_type\":{}}}", report.attempts, report.caught, report.released, json_string(&report.error_type));
            Ok(())
        }
        Some("tensor" | "buffer") if args.len() <= 2 => {
            let cycles = args.get(1).map_or(Ok(1), |s| s.parse::<usize>())?;
            // SAFETY: Deliberate native experiment against the documented OS ABI.
            let runtime = unsafe { Runtime::open()? };
            // SAFETY: Fixed public symbols and valid [2, 2] dimensions in probe.
            let report = unsafe {
                if args[0] == "buffer" {
                    runtime.buffer_probe(cycles)?
                } else {
                    runtime.tensor_probe(cycles)?
                }
            };
            println!(
                "{{\"cycles\":{},\"shape\":{:?},\"scalar_tag\":{},\"initialized\":{},\"destroyed\":{},\"content_bits\":{:?}}}",
                report.cycles,
                report.shape,
                report.scalar_tag,
                report.initialized,
                report.destroyed,
                report.content_bits,
            );
            Ok(())
        }
        _ => Err(
            "usage: cargo run -p corsairs-lab -- metadata | tensor [cycles] | buffer [cycles] | bookmark-error [cycles] | task [cycles] | suspend [cycles] | model PATH [cycles] | infer PATH [cycles]"
                .into(),
        ),
    }
}

fn json_string(value: &str) -> String {
    use std::fmt::Write;
    let mut output = String::from("\"");
    for character in value.chars() {
        match character {
            '"' => output.push_str("\\\""),
            '\\' => output.push_str("\\\\"),
            c if c <= '\u{1f}' => write!(output, "\\u{:04x}", c as u32).unwrap(),
            c => output.push(c),
        }
    }
    output.push('"');
    output
}

fn metadata() -> Result<(), Box<dyn std::error::Error>> {
    // SAFETY: This executable deliberately runs the documented native experiment
    // against fixed known metadata symbols on the investigated platform.
    let runtime = unsafe { Runtime::open()? };
    println!("[");
    for (index, (name, symbol)) in [
        ("NDArray", NDARRAY_METADATA),
        ("ScalarType", SCALAR_METADATA),
        ("AIModel", MODEL_METADATA),
        ("InferenceFunction", FUNCTION_METADATA),
    ]
    .into_iter()
    .enumerate()
    {
        // SAFETY: These are non-generic metadata accessors verified by Swift IR.
        let metadata = unsafe { runtime.metadata(symbol)? };
        println!(
            "{}{{\"name\":\"{name}\",\"size\":{},\"stride\":{},\"alignment\":{},\"kind\":{},\"address\":{}}}",
            if index == 0 { "" } else { "," },
            metadata.layout.size,
            metadata.layout.stride,
            metadata.layout.alignment,
            metadata.kind,
            metadata.address(),
        );
    }
    println!("]");
    Ok(())
}
