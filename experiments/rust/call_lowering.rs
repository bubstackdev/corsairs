// Code-generation diagnostic only. No declaration in this file is ever called.
#![feature(abi_swift)]

#[repr(C)]
pub struct Triple {
    pub a: u64,
    pub b: u64,
    pub c: u64,
}

unsafe extern "Swift" {
    fn aggregate3(value: Triple) -> Triple;
    fn instance(value: u64, context: *mut u8) -> u64;
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn aggregate_probe(value: Triple) -> Triple {
    unsafe { aggregate3(value) }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn context_probe(value: u64, context: *mut u8) -> u64 {
    unsafe { instance(value, context) }
}
