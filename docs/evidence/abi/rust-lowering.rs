#![feature(abi_swift)]
#[repr(C)] pub struct Triple { pub a:u64, pub b:u64, pub c:u64 }
unsafe extern "Swift" {
    fn instance(x:u64, context:*mut u8)->u64;
    fn aggregate3(x:Triple)->Triple;
}
#[unsafe(no_mangle)] pub unsafe extern "C" fn call_instance(x:u64, context:*mut u8)->u64 { unsafe {instance(x,context)} }
#[unsafe(no_mangle)] pub unsafe extern "C" fn call_aggregate3(x:Triple)->Triple { unsafe {aggregate3(x)} }
