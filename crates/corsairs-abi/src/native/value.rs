use super::{Error, Metadata};
use std::alloc::{Layout, alloc_zeroed, dealloc};
use std::ffi::c_void;
use std::mem;
use std::ptr::NonNull;

/// Raw allocation and native initialization are tracked separately. A consumed
/// input relinquishes its native value but still owns the Rust allocation.
pub(crate) struct Value<'metadata, 'runtime> {
    pub(crate) storage: NonNull<c_void>,
    allocation: Layout,
    metadata: &'metadata Metadata<'runtime>,
    pub(crate) initialized: bool,
}

/// Move a known `Optional<Payload>` into separate payload storage through the
/// payload's published single-payload enum witnesses, without layout guesses.
pub(crate) unsafe fn take_optional<'metadata, 'runtime>(
    optional: &mut Value<'_, '_>,
    payload: &'metadata Metadata<'runtime>,
) -> Result<Option<Value<'metadata, 'runtime>>, Error> {
    // SAFETY: Caller supplies matching Optional and payload metadata. VWT slot6
    // takes optional storage, number of empty cases (1), and payload metadata.
    let tag = unsafe {
        let get: unsafe extern "C" fn(*mut c_void, u32, *mut c_void) -> u32 =
            mem::transmute(payload.witness(6));
        get(optional.storage.as_ptr(), 1, payload.pointer.as_ptr())
    };
    match tag {
        1 => Ok(None),
        0 => {
            let mut result = Value::allocate(payload)?;
            // SAFETY: Some contains an initialized payload. Slot4 moves it into
            // separate correctly sized storage, consuming the Optional payload.
            unsafe {
                let take: unsafe extern "C" fn(
                    *mut c_void,
                    *mut c_void,
                    *mut c_void,
                ) -> *mut c_void = mem::transmute(payload.witness(4));
                take(
                    result.storage.as_ptr(),
                    optional.storage.as_ptr(),
                    payload.pointer.as_ptr(),
                );
            }
            optional.initialized = false;
            result.initialized = true;
            Ok(Some(result))
        }
        _ => Err(Error("invalid Optional single-payload tag".into())),
    }
}

impl<'metadata, 'runtime> Value<'metadata, 'runtime> {
    pub(crate) fn allocate(metadata: &'metadata Metadata<'runtime>) -> Result<Self, Error> {
        let allocation =
            Layout::from_size_align(metadata.layout.stride.max(1), metadata.layout.alignment)
                .map_err(|e| Error(e.to_string()))?;
        // SAFETY: Valid, nonzero allocation. Bytes are not a native value yet.
        let storage = unsafe { alloc_zeroed(allocation) }.cast::<c_void>();
        Ok(Self {
            storage: NonNull::new(storage)
                .ok_or_else(|| Error("native storage allocation failed".into()))?,
            allocation,
            metadata,
            initialized: false,
        })
    }
}

impl Drop for Value<'_, '_> {
    fn drop(&mut self) {
        if self.initialized {
            // SAFETY: Slot 1 is the C-ABI destroy witness. This value was
            // initialized exactly once, has not been consumed, and remains live.
            unsafe {
                let destroy: unsafe extern "C" fn(*mut c_void, *mut c_void) =
                    mem::transmute(self.metadata.witness(1));
                destroy(self.storage.as_ptr(), self.metadata.pointer.as_ptr());
            }
        }
        // SAFETY: Always free the original allocation, including after native
        // destruction or ownership transfer. Witness destroy does not free it.
        unsafe { dealloc(self.storage.as_ptr().cast(), self.allocation) };
    }
}
