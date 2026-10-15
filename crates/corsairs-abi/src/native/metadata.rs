use super::Error;
use std::ffi::c_void;
use std::marker::PhantomData;
use std::ptr::NonNull;

/// Layout read from Swift's value witness table, never from a Rust type guess.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct TypeLayout {
    pub size: usize,
    pub stride: usize,
    pub alignment: usize,
    pub flags: u32,
}

pub struct Metadata<'runtime> {
    pub(crate) pointer: NonNull<c_void>,
    pub(crate) witnesses: NonNull<c_void>,
    pub layout: TypeLayout,
    #[cfg_attr(not(feature = "abi-research"), allow(dead_code))]
    pub kind: usize,
    _runtime: PhantomData<&'runtime super::Runtime>,
}

impl<'runtime> Metadata<'runtime> {
    pub(crate) unsafe fn from_response(pointer: *mut c_void, state: usize) -> Result<Self, Error> {
        if state != 0 {
            return Err(Error(format!("metadata is incomplete: state {state:#x}")));
        }
        let pointer = NonNull::new(pointer).ok_or_else(|| Error("null metadata".into()))?;
        // SAFETY: A verified complete metadata response has a VWT pointer at -1
        // machine word and a kind at 0. Runtime stays loaded through the borrow.
        let (witnesses, kind) = unsafe {
            let words = pointer.as_ptr().cast::<usize>();
            (words.sub(1).read() as *mut c_void, words.read())
        };
        let witnesses =
            NonNull::new(witnesses).ok_or_else(|| Error("null value witnesses".into()))?;
        // SAFETY: Standard 64-bit Swift VWT has 8 function slots, size at 64,
        // stride at 72, and 32-bit flags at 80. Source/IR evidence in the ledger.
        let (size, stride, flags) = unsafe {
            let bytes = witnesses.as_ptr().cast::<u8>();
            (
                bytes.add(64).cast::<usize>().read(),
                bytes.add(72).cast::<usize>().read(),
                bytes.add(80).cast::<u32>().read(),
            )
        };
        let alignment = ((flags & 0xff) + 1) as usize;
        if flags & 0x0040_0000 != 0
            || !alignment.is_power_of_two()
            || stride < size
            || stride % alignment != 0
            || size > 1 << 20
        {
            return Err(Error(format!(
                "unexpected value layout: {size}/{stride}/{alignment}"
            )));
        }
        Ok(Self {
            pointer,
            witnesses,
            layout: TypeLayout {
                size,
                stride,
                alignment,
                flags,
            },
            kind,
            _runtime: PhantomData,
        })
    }

    pub fn address(&self) -> usize {
        self.pointer.as_ptr() as usize
    }

    pub fn witnesses_address(&self) -> usize {
        self.witnesses.as_ptr() as usize
    }

    #[cfg(feature = "abi-research")]
    pub(crate) unsafe fn witness(&self, index: usize) -> *mut c_void {
        // SAFETY: Caller selects a function slot established by the ABI ledger.
        unsafe {
            self.witnesses
                .as_ptr()
                .cast::<*mut c_void>()
                .add(index)
                .read()
        }
    }
}
