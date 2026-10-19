#![forbid(unsafe_code)]
//! Image I/O parity driver for fixtures/parity-v05/images.
//!
//! `image_parity PLAN OUT_DIR` reads the line plan written by
//! scripts/check_images.py, runs every case through the public API on the
//! requested backends, writes each output's bytes to
//! OUT_DIR/BACKEND/CASE/VARIANT/NAME.bin and prints one JSON object. The
//! checker compares those bytes with the frozen goldens; this driver judges
//! only error variants, descriptors and soak/drop behavior.
//!
//! Plan lines (whitespace-separated; paths contain no spaces):
//!   backend NAME
//!   case NAME MODEL
//!   image NAME OS_TYPE WIDTH HEIGHT FILE
//!   tensor NAME SHAPE FILE            (SHAPE: comma-separated, uint8)
//!   negative NAME MODEL EXPECTED
//!   request NAME OS_TYPE WIDTH HEIGHT (zero-filled image for a negative)
//!   soak MODEL ITERATIONS
//!   drop MODEL ITERATIONS
use corsairs::{
    Compute, DType, Error, Function, Image, ImageMap, MetalBufferMap, MetalValueMap, PixelFormat,
    RunResult, Runtime, Tensor, TensorHandleMap, TensorMap,
};
use std::fmt::Write as _;
use std::path::{Path, PathBuf};
use std::time::Instant;

type Result<T = ()> = std::result::Result<T, Box<dyn std::error::Error>>;

#[derive(Default)]
struct Case {
    name: String,
    model: String,
    images: Vec<(String, u32, usize, usize, Option<PathBuf>)>,
    tensors: Vec<(String, Vec<usize>, PathBuf)>,
    expected: Option<String>,
    negative: bool,
}
#[derive(Default)]
struct Plan {
    backends: Vec<String>,
    cases: Vec<Case>,
    soak: Option<(String, usize)>,
    drop: Option<(String, usize)>,
}

fn quoted(text: &str) -> String {
    let mut output = String::from("\"");
    for ch in text.chars() {
        match ch {
            '"' => output.push_str("\\\""),
            '\\' => output.push_str("\\\\"),
            '\n' => output.push_str("\\n"),
            c if (c as u32) < 0x20 => {
                let _ = write!(output, "\\u{:04x}", c as u32);
            }
            c => output.push(c),
        }
    }
    output.push('"');
    output
}

fn parse(path: &Path) -> Result<Plan> {
    let mut plan = Plan::default();
    for line in std::fs::read_to_string(path)?.lines() {
        let words: Vec<&str> = line.split_whitespace().collect();
        let Some((&kind, rest)) = words.split_first() else {
            continue;
        };
        let current = || -> Result<usize> { Ok(plan.cases.len().checked_sub(1).ok_or("no case")?) };
        match (kind, rest) {
            ("backend", [name]) => plan.backends.push((*name).into()),
            ("case", [name, model]) => plan.cases.push(Case {
                name: (*name).into(),
                model: (*model).into(),
                ..Case::default()
            }),
            ("negative", [name, model, expected]) => plan.cases.push(Case {
                name: (*name).into(),
                model: (*model).into(),
                expected: Some((*expected).into()),
                negative: true,
                ..Case::default()
            }),
            ("image", [name, os_type, width, height, file]) => {
                let index = current()?;
                plan.cases[index].images.push((
                    (*name).into(),
                    os_type.parse()?,
                    width.parse()?,
                    height.parse()?,
                    Some(file.into()),
                ));
            }
            ("request", [name, os_type, width, height]) => {
                let index = current()?;
                plan.cases[index].images.push((
                    (*name).into(),
                    os_type.parse()?,
                    width.parse()?,
                    height.parse()?,
                    None,
                ));
            }
            ("tensor", [name, shape, file]) => {
                let index = current()?;
                let shape = shape
                    .split(',')
                    .map(str::parse)
                    .collect::<std::result::Result<_, _>>()?;
                plan.cases[index]
                    .tensors
                    .push(((*name).into(), shape, file.into()));
            }
            ("soak", [model, n]) => plan.soak = Some(((*model).into(), n.parse()?)),
            ("drop", [model, n]) => plan.drop = Some(((*model).into(), n.parse()?)),
            _ => return Err(format!("bad plan line {line:?}").into()),
        }
    }
    Ok(plan)
}

fn compute(name: &str) -> Result<Compute> {
    Ok(match name {
        "cpu" => Compute::CpuOnly,
        "gpu-preferred" => Compute::GpuPreferred,
        "neural-engine-preferred" => Compute::NeuralEnginePreferred,
        _ => return Err(format!("unknown backend {name}").into()),
    })
}

fn variant(error: &Error) -> &'static str {
    match error {
        Error::Unsupported(_) => "Unsupported",
        Error::DescriptorMismatch { .. } => "DescriptorMismatch",
        Error::MissingTensor { .. } => "MissingTensor",
        Error::UnexpectedTensor { .. } => "UnexpectedTensor",
        Error::InvalidImage(_) => "InvalidImage",
        Error::Native { .. } => "Native",
        Error::Binding(_) => "Binding",
        _ => "Other",
    }
}

fn format(os_type: u32) -> Result<PixelFormat> {
    Ok(PixelFormat::from_os_type(os_type).ok_or("unsupported fixture format")?)
}

/// Copy tight rows into rows padded by `pad` bytes of 0xEE, which Core AI must ignore.
fn padded(image: &Image, pad: usize) -> Result<Image> {
    let row = image.width() * image.format().bytes_per_pixel();
    let mut bytes = Vec::new();
    for y in 0..image.height() {
        bytes.extend_from_slice(image.row(y));
        bytes.resize(bytes.len() + pad, 0xEE);
    }
    Ok(Image::with_bytes_per_row(
        image.format(),
        image.width(),
        image.height(),
        row + pad,
        bytes,
    )?)
}

fn inputs(root: &Path, case: &Case) -> Result<(TensorMap, ImageMap)> {
    let mut tensors = TensorMap::new();
    for (name, shape, file) in &case.tensors {
        tensors.insert(
            name.clone(),
            Tensor::from_bytes(DType::UInt8, shape.clone(), std::fs::read(root.join(file))?)?,
        );
    }
    let mut images = ImageMap::new();
    for (name, os_type, width, height, file) in &case.images {
        let image = match file {
            Some(file) => Image::new(format(*os_type)?, *width, *height, std::fs::read(root.join(file))?)?,
            None => Image::zeros(format(*os_type)?, *width, *height)?,
        };
        images.insert(name.clone(), image);
    }
    Ok((tensors, images))
}

fn save(directory: &Path, result: &RunResult) -> Result<Vec<String>> {
    std::fs::create_dir_all(directory)?;
    let mut names = Vec::new();
    for (name, tensor) in result.outputs.iter() {
        std::fs::write(directory.join(format!("{name}.bin")), tensor.as_bytes())?;
        names.push(format!(
            "{{\"name\":{},\"kind\":\"tensor\",\"dtype\":{},\"shape\":{:?}}}",
            quoted(name),
            quoted(tensor.dtype().name()),
            tensor.shape()
        ));
    }
    for (name, image) in result.images.iter() {
        if image.bytes_per_row() != image.width() * image.format().bytes_per_pixel() {
            return Err("output image rows are not tight".into());
        }
        std::fs::write(directory.join(format!("{name}.bin")), image.as_bytes())?;
        names.push(format!(
            "{{\"name\":{},\"kind\":\"image\",\"os_type\":{},\"width\":{},\"height\":{}}}",
            quoted(name),
            image.format().os_type(),
            image.width(),
            image.height()
        ));
    }
    Ok(names)
}

fn descriptor_json(function: &Function) -> String {
    let d = function.descriptor();
    let images = |group: &[corsairs::ImageDescriptor]| {
        group
            .iter()
            .map(|i| {
                format!(
                    "{{\"name\":{},\"os_type\":{},\"width\":{},\"height\":{},\"supported\":{}}}",
                    quoted(&i.name),
                    i.pixel_format_type,
                    i.width,
                    i.height,
                    i.format().is_some()
                )
            })
            .collect::<Vec<_>>()
            .join(",")
    };
    let tensors = |group: &[corsairs::TensorDescriptor]| {
        group
            .iter()
            .map(|t| quoted(&t.name))
            .collect::<Vec<_>>()
            .join(",")
    };
    format!(
        "{{\"inputs\":[{}],\"outputs\":[{}],\"image_inputs\":[{}],\"image_outputs\":[{}]}}",
        tensors(&d.inputs),
        tensors(&d.outputs),
        images(&d.image_inputs),
        images(&d.image_outputs)
    )
}

fn rss_kib() -> Result<u64> {
    let output = std::process::Command::new("/bin/ps")
        .args(["-o", "rss=", "-p", &std::process::id().to_string()])
        .output()?;
    Ok(String::from_utf8(output.stdout)?.trim().parse()?)
}

fn main() -> Result {
    let args: Vec<String> = std::env::args().collect();
    let [_, plan, out] = &args[..] else {
        return Err("usage: image_parity PLAN OUT_DIR".into());
    };
    let plan_path = Path::new(plan);
    let root = plan_path.parent().ok_or("plan has no directory")?;
    let fixtures = PathBuf::from(std::fs::read_to_string(root.join("fixtures-root"))?.trim());
    let plan = parse(plan_path)?;
    let out = Path::new(out);
    let runtime = Runtime::new()?;
    let mut runs = Vec::new();
    let mut checks = Vec::new();
    for backend in &plan.backends {
        let compute = compute(backend)?;
        for case in &plan.cases {
            let model = runtime.load_model(fixtures.join(&case.model), compute).wait()?;
            let function = model.load_function("main").wait()?;
            let descriptor = descriptor_json(&function);
            let (tensors, images) = inputs(&fixtures, case)?;
            if case.negative {
                let outcome = function.run_with_images(tensors, images, TensorMap::new()).wait();
                let actual = match &outcome {
                    Ok(_) => "Ok".to_owned(),
                    Err(error) => variant(error).to_owned(),
                };
                checks.push(format!(
                    "{{\"check\":\"negative\",\"case\":{},\"backend\":{},\"expected\":{},\"actual\":{},\"message\":{},\"descriptor\":{descriptor},\"passed\":{}}}",
                    quoted(&case.name),
                    quoted(backend),
                    quoted(case.expected.as_deref().unwrap_or("")),
                    quoted(&actual),
                    quoted(&outcome.err().map(|e| e.to_string()).unwrap_or_default()),
                    Some(actual.as_str()) == case.expected.as_deref()
                ));
                continue;
            }
            let mut variants = vec![("tight", images.clone())];
            if !images.is_empty() {
                let mut padded_images = ImageMap::new();
                for (name, image) in images.iter() {
                    padded_images.insert(name, padded(image, 13)?);
                }
                variants.push(("padded", padded_images));
            }
            for (label, images) in variants {
                let started = Instant::now();
                // Tensor-only inputs exercise `run`, which carries no images.
                let result = if images.is_empty() {
                    function.run(tensors.clone(), TensorMap::new()).wait()
                } else {
                    function
                        .run_with_images(tensors.clone(), images, TensorMap::new())
                        .wait()
                };
                let (outcome, outputs) = match result {
                    Ok(result) => (
                        "\"completed\"".to_owned(),
                        save(&out.join(backend).join(&case.name).join(label), &result)?.join(","),
                    ),
                    Err(error) => (
                        format!("{{\"error\":{},\"variant\":{}}}", quoted(&error.to_string()), quoted(variant(&error))),
                        String::new(),
                    ),
                };
                runs.push(format!(
                    "{{\"case\":{},\"backend\":{},\"variant\":\"{label}\",\"outcome\":{outcome},\"outputs\":[{outputs}],\"descriptor\":{descriptor},\"seconds\":{}}}",
                    quoted(&case.name),
                    quoted(backend),
                    started.elapsed().as_secs_f64()
                ));
            }
        }
        // Paths without image support reject image signatures before dispatch.
        if let Some(case) = plan.cases.iter().find(|c| !c.negative && c.images.is_empty() && !c.tensors.is_empty()) {
            let model = runtime.load_model(fixtures.join(&case.model), compute).wait()?;
            let function = model.load_function("main").wait()?;
            let (tensors, _) = inputs(&fixtures, case)?;
            let mut handles = TensorHandleMap::new();
            for (name, tensor) in tensors.iter() {
                handles.insert(name, runtime.upload(tensor.clone()).wait()?);
            }
            let native = function.run_native(handles, TensorHandleMap::new()).wait();
            let queue = runtime.metal_queue().wait()?;
            let encode = function
                .encode(&queue, MetalValueMap::new(), MetalBufferMap::new(), MetalBufferMap::new())
                .wait();
            for (check, outcome) in [("run_native", native.err()), ("encode", encode.err())] {
                let actual = outcome.as_ref().map(variant).unwrap_or("Ok");
                checks.push(format!(
                    "{{\"check\":\"{check}_rejects_images\",\"case\":{},\"backend\":{},\"actual\":{},\"passed\":{}}}",
                    quoted(&case.name),
                    quoted(backend),
                    quoted(actual),
                    actual == "Unsupported"
                ));
            }
        }
        // Invalid strides fail at construction, before any request exists.
        let stride = Image::with_bytes_per_row(PixelFormat::Bgra32, 4, 2, 15, vec![0; 30]);
        checks.push(format!(
            "{{\"check\":\"short_stride\",\"backend\":{},\"actual\":{},\"passed\":{}}}",
            quoted(backend),
            quoted(stride.as_ref().err().map(variant).unwrap_or("Ok")),
            matches!(stride, Err(Error::InvalidImage(_)))
        ));
    }
    let mut soaks = Vec::new();
    if let Some((model_path, iterations)) = &plan.soak {
        for backend in &plan.backends {
            let model = runtime.load_model(fixtures.join(model_path), compute(backend)?).wait()?;
            let function = model.load_function("main").wait()?;
            let d = function.descriptor();
            let (input, output) = (&d.image_inputs[0], &d.image_outputs[0]);
            let input_format = input.format().ok_or("soak input format")?;
            let mut samples = Vec::new();
            let mut mismatches = 0usize;
            let started = Instant::now();
            for i in 0..=*iterations {
                if i % (iterations / 10).max(1) == 0 {
                    samples.push(format!("{{\"iteration\":{i},\"rss_kib\":{}}}", rss_kib()?));
                }
                if i == *iterations {
                    break;
                }
                // A fresh, iteration-dependent image and output view each call.
                let bytes: Vec<u8> = (0..input.width * input.height * input_format.bytes_per_pixel())
                    .map(|j| ((i * 7 + j * 13) % 251) as u8)
                    .collect();
                let image = Image::new(input_format, input.width, input.height, bytes.clone())?;
                let result = function
                    .run_with_images(TensorMap::new(), ImageMap::from([(input.name.as_str(), image)]), TensorMap::new())
                    .wait()?;
                if result.images.get(&output.name).map(Image::as_bytes) != Some(&bytes[..]) {
                    mismatches += 1;
                }
            }
            soaks.push(format!(
                "{{\"backend\":{},\"model\":{},\"iterations\":{iterations},\"mismatches\":{mismatches},\"seconds\":{},\"rss_samples\":[{}]}}",
                quoted(backend),
                quoted(model_path),
                started.elapsed().as_secs_f64(),
                samples.join(",")
            ));
        }
    }
    let mut drops = Vec::new();
    if let Some((model_path, iterations)) = &plan.drop {
        for backend in &plan.backends {
            let model = runtime.load_model(fixtures.join(model_path), compute(backend)?).wait()?;
            let function = model.load_function("main").wait()?;
            let input = function.descriptor().image_inputs[0].clone();
            let image = Image::zeros(input.format().ok_or("drop format")?, input.width, input.height)?;
            let request = || ImageMap::from([(input.name.as_str(), image.clone())]);
            let before = rss_kib()?;
            let (mut prevented, mut too_late) = (0usize, 0usize);
            for _ in 0..*iterations {
                // An abandoned future: the worker still owns and completes it.
                drop(function.run_with_images(TensorMap::new(), request(), TensorMap::new()));
                let task = function.run_with_images(TensorMap::new(), request(), TensorMap::new());
                match task.cancel_handle().cancel() {
                    corsairs::Cancel::Prevented => prevented += 1,
                    corsairs::Cancel::TooLate => too_late += 1,
                }
                drop(task);
            }
            runtime.drain().wait()?;
            let after = function
                .run_with_images(TensorMap::new(), request(), TensorMap::new())
                .wait()?;
            drops.push(format!(
                "{{\"backend\":{},\"iterations\":{iterations},\"cancel_prevented\":{prevented},\"cancel_too_late\":{too_late},\"rss_before_kib\":{before},\"rss_after_kib\":{},\"run_after_drain\":{}}}",
                quoted(backend),
                rss_kib()?,
                after.images.get(&function.descriptor().image_outputs[0].name).is_some()
            ));
        }
    }
    println!(
        "{{\"runs\":[{}],\"checks\":[{}],\"soak\":[{}],\"drop\":[{}]}}",
        runs.join(","),
        checks.join(","),
        soaks.join(","),
        drops.join(",")
    );
    Ok(())
}
