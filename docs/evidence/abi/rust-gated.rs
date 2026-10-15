#![feature(abi_swift)]
unsafe extern "Swift" { fn target(x: u64) -> u64; }
#[unsafe(no_mangle)]
pub unsafe extern "C" fn probe(x: u64) -> u64 { unsafe { target(x) } }
