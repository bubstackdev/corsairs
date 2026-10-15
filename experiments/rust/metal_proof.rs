//! Standalone development driver; build with scripts/build_metal_proof.py.
//! This is deliberately outside the production API and requires native access.
use corsairs::native::NativeSession;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut arguments = std::env::args().skip(1);
    let path = arguments
        .next()
        .ok_or("expected x+x float32[2,3] model path")?;
    let cycles = arguments
        .next()
        .map_or(Ok(1), |value| value.parse::<usize>())?;
    if !(1..=100_000).contains(&cycles) || arguments.next().is_some() {
        return Err("expected MODEL [CYCLES], cycles 1..100000".into());
    }
    // SAFETY: Explicit standalone ABI proof, restricted to recorded macOS27
    // arm64 contracts. All objects remain on this thread through native cleanup.
    let report = unsafe {
        let mut session = NativeSession::open()?;
        session.metal_proof(Path::new(&path), cycles)?
    };
    println!("{report}");
    Ok(())
}
