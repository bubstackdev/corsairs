//! Each call shape is explicit. No Swift values are classified by Rust's ABI.

use std::arch::asm;
use std::ffi::c_void;

pub(crate) unsafe fn metadata_accessor(
    function: *mut c_void,
    request: usize,
) -> (*mut c_void, usize) {
    let pointer: *mut c_void;
    let state: usize;
    // SAFETY: Caller verifies the target's signature. The ordinary word request
    // is in x0; Swift's two-word MetadataResponse is returned in x0/x1.
    // clobber_abi accounts for a real call (including LR and caller-saved SIMD).
    // x20/x21/x22 are also declared clobbered for Swift-specific context roles.
    unsafe {
        asm!(
            "blr x16",
            in("x16") function,
            inlateout("x0") request => pointer,
            lateout("x1") state,
            lateout("x20") _,
            lateout("x21") _,
            lateout("x22") _,
            clobber_abi("C"),
        );
    }
    (pointer, state)
}

/// An already-lowered synchronous call, with at most three ordinary word
/// arguments, an optional indirect result in x8, and an optional self in x20.
/// This intentionally does not classify Rust types or support throwing/async.
pub(crate) unsafe fn call_sync(
    function: *mut c_void,
    arguments: [usize; 3],
    indirect_result: *mut c_void,
    context: usize,
) -> usize {
    // SAFETY: Caller establishes the same register contract as call_sync_pair.
    unsafe { call_sync_pair(function, arguments, indirect_result, context).0 }
}

pub(crate) unsafe fn call_sync_pair(
    function: *mut c_void,
    arguments: [usize; 3],
    indirect_result: *mut c_void,
    context: usize,
) -> (usize, usize) {
    let first: usize;
    let second: usize;
    // SAFETY: Caller verifies this exact register contract for the target.
    // No `nomem`, `readonly`, or `nostack`: native calls can allocate and mutate.
    unsafe {
        asm!(
            "blr x16",
            in("x16") function,
            inlateout("x0") arguments[0] => first,
            inlateout("x1") arguments[1] => second,
            inlateout("x2") arguments[2] => _,
            inlateout("x8") indirect_result => _,
            inlateout("x20") context => _,
            lateout("x21") _,
            lateout("x22") _,
            clobber_abi("C"),
        );
    }
    (first, second)
}

/// A synchronous throw returns an owned error object in x21, not an out-pointer.
pub(crate) unsafe fn call_throwing(
    function: *mut c_void,
    arguments: [usize; 3],
    indirect_result: *mut c_void,
    context: usize,
) -> *mut c_void {
    let error: *mut c_void;
    // SAFETY: Caller establishes argument and ownership contracts. x21 must be
    // empty on entry. Async completion has a different contract and is excluded.
    unsafe {
        asm!(
            "blr x16",
            in("x16") function,
            inlateout("x0") arguments[0] => _,
            inlateout("x1") arguments[1] => _,
            inlateout("x2") arguments[2] => _,
            inlateout("x8") indirect_result => _,
            inlateout("x20") context => _,
            inlateout("x21") 0usize => error,
            lateout("x22") _,
            clobber_abi("C"),
        );
    }
    error
}
