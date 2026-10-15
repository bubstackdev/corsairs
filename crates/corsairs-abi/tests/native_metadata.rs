use corsairs::native::{NDARRAY_METADATA, Runtime};

#[test]
fn repeated_metadata_has_canonical_identity() {
    // SAFETY: Fixed investigated OS framework and verified metadata symbols.
    let runtime = unsafe { Runtime::open().expect("Core AI must be available") };
    // SAFETY: NDArray's non-generic metadata accessor was verified in Swift IR.
    let first = unsafe { runtime.metadata(NDARRAY_METADATA).unwrap() };
    for _ in 0..64 {
        // SAFETY: Same verified accessor, framework handle remains alive.
        let next = unsafe { runtime.metadata(NDARRAY_METADATA).unwrap() };
        assert_eq!(first.address(), next.address());
        assert_eq!(first.layout, next.layout);
    }
}

#[test]
fn missing_symbol_is_an_error_without_invocation() {
    // SAFETY: Fixed investigated OS framework.
    let runtime = unsafe { Runtime::open().unwrap() };
    // SAFETY: An intentionally absent name cannot reach a native ABI call.
    let result = unsafe { runtime.metadata(c"corsairs_intentionally_missing_metadata_symbol") };
    assert!(result.is_err());
}
