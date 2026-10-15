//! Owned contiguous tensors. Conversion never reinterprets unaligned byte slices.
use crate::api_error::Error;
use std::fmt;

/// Maximum supported tensor rank.
pub const MAX_TENSOR_RANK: usize = 64;
/// Maximum tensor storage size (four GiB). For empty tensors, the same
/// bound applies to the product of nonzero dimensions to reject stride overflow.
pub const MAX_TENSOR_BYTES: usize = 1usize << 32;

/// Scalar types supported by Corsairs.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum DType {
    Float16,
    BFloat16,
    Float32,
    Int32,
    Int64,
    Bool,
}

impl DType {
    /// Number of bytes in one scalar.
    pub const fn byte_width(self) -> usize {
        match self {
            Self::Float16 | Self::BFloat16 => 2,
            Self::Float32 | Self::Int32 => 4,
            Self::Int64 => 8,
            Self::Bool => 1,
        }
    }
    /// Native scalar name, also used by the Python reference.
    pub const fn name(self) -> &'static str {
        match self {
            Self::Float16 => "float16",
            Self::BFloat16 => "bfloat16",
            Self::Float32 => "float32",
            Self::Int32 => "int32",
            Self::Int64 => "int64",
            Self::Bool => "bool",
        }
    }
}
impl fmt::Display for DType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

/// An IEEE 754 binary16 scalar. Construction from bits preserves every bit.
#[derive(Clone, Copy, Default, PartialEq, Eq, Hash)]
#[repr(transparent)]
pub struct Float16(u16);

impl Float16 {
    /// Construct without changing the bit representation.
    pub const fn from_bits(bits: u16) -> Self {
        Self(bits)
    }
    /// Return the exact binary16 representation.
    pub const fn to_bits(self) -> u16 {
        self.0
    }
    /// Convert binary32 with round-to-nearest, ties-to-even. NaN sign and the
    /// representable high payload bits are preserved; a NaN remains a NaN.
    pub fn from_f32(value: f32) -> Self {
        let bits = value.to_bits();
        let sign = ((bits >> 16) & 0x8000) as u16;
        let exponent = ((bits >> 23) & 0xff) as i32;
        let fraction = bits & 0x7f_ffff;
        if exponent == 255 {
            return Self(
                sign | 0x7c00
                    | if fraction == 0 {
                        0
                    } else {
                        ((fraction >> 13) as u16).max(1)
                    },
            );
        }
        let exponent = exponent - 127 + 15;
        if exponent >= 31 {
            return Self(sign | 0x7c00);
        }
        if exponent < -10 {
            return Self(sign);
        }
        let round = |number: u32, shift: u32| {
            let retained = number >> shift;
            let discarded = number & ((1 << shift) - 1);
            let halfway = 1 << (shift - 1);
            retained + u32::from(discarded > halfway || (discarded == halfway && retained & 1 != 0))
        };
        if exponent <= 0 {
            return Self(sign | round(fraction | 0x80_0000, (14 - exponent) as u32) as u16);
        }
        Self(sign | (((exponent as u32) << 10) + round(fraction, 13)) as u16)
    }
    /// Convert exactly into binary32, preserving signed zero and NaN payload bits.
    pub fn to_f32(self) -> f32 {
        let sign = ((self.0 & 0x8000) as u32) << 16;
        let exponent = (self.0 >> 10) & 31;
        let mut fraction = (self.0 & 1023) as u32;
        let bits = match exponent {
            0 if fraction == 0 => sign,
            0 => {
                let mut exponent = -14i32;
                while fraction & 1024 == 0 {
                    fraction <<= 1;
                    exponent -= 1;
                }
                sign | (((exponent + 127) as u32) << 23) | ((fraction & 1023) << 13)
            }
            31 => sign | 0x7f80_0000 | (fraction << 13),
            _ => sign | (((exponent as u32) + 112) << 23) | (fraction << 13),
        };
        f32::from_bits(bits)
    }
}
impl fmt::Debug for Float16 {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Float16({:?}, 0x{:04x})", self.to_f32(), self.0)
    }
}

/// A bfloat16 scalar: one sign bit, eight exponent bits and seven fraction bits.
/// Construction from bits preserves all encodings, including NaN payloads.
#[derive(Clone, Copy, Default, PartialEq, Eq, Hash)]
#[repr(transparent)]
pub struct BFloat16(u16);

impl BFloat16 {
    /// Construct without changing the bit representation.
    pub const fn from_bits(bits: u16) -> Self {
        Self(bits)
    }
    /// Return the exact bfloat16 representation.
    pub const fn to_bits(self) -> u16 {
        self.0
    }
    /// Narrow binary32 with round-to-nearest, ties-to-even. NaNs retain their
    /// sign and representable high payload bits; a discarded-only payload is
    /// replaced by one so a NaN never becomes infinity. This bit conversion
    /// preserves signaling encodings and does not raise floating-point flags.
    pub fn from_f32(value: f32) -> Self {
        let bits = value.to_bits();
        let upper = (bits >> 16) as u16;
        if bits & 0x7fff_ffff > 0x7f80_0000 {
            return Self(upper | u16::from(upper & 0x7f == 0));
        }
        let bias = 0x7fff + u32::from(upper & 1 != 0);
        Self((bits.wrapping_add(bias) >> 16) as u16)
    }
    /// Widen exactly to binary32, preserving signed zero and every NaN bit.
    pub fn to_f32(self) -> f32 {
        f32::from_bits(u32::from(self.0) << 16)
    }
}
impl fmt::Debug for BFloat16 {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "BFloat16({:?}, 0x{:04x})", self.to_f32(), self.0)
    }
}

mod sealed {
    pub trait Sealed {}
}

/// A scalar with a supported, fixed tensor encoding. This trait is sealed.
pub trait TensorElement: sealed::Sealed + Copy + Send + Sync + 'static {
    /// The scalar's tensor type.
    const DTYPE: DType;
    #[doc(hidden)]
    fn encode(self, bytes: &mut Vec<u8>);
    #[doc(hidden)]
    fn decode(bytes: &[u8]) -> Self;
}
macro_rules! element {
    ($ty:ty, $dtype:ident, $n:expr) => {
        impl sealed::Sealed for $ty {}
        impl TensorElement for $ty {
            const DTYPE: DType = DType::$dtype;
            fn encode(self, bytes: &mut Vec<u8>) {
                bytes.extend_from_slice(&self.to_le_bytes());
            }
            fn decode(bytes: &[u8]) -> Self {
                let mut word = [0u8; $n];
                word.copy_from_slice(bytes);
                Self::from_le_bytes(word)
            }
        }
    };
}
element!(f32, Float32, 4);
element!(i32, Int32, 4);
element!(i64, Int64, 8);
impl sealed::Sealed for Float16 {}
impl TensorElement for Float16 {
    const DTYPE: DType = DType::Float16;
    fn encode(self, bytes: &mut Vec<u8>) {
        bytes.extend_from_slice(&self.0.to_le_bytes());
    }
    fn decode(bytes: &[u8]) -> Self {
        Self(u16::from_le_bytes([bytes[0], bytes[1]]))
    }
}
impl sealed::Sealed for BFloat16 {}
impl TensorElement for BFloat16 {
    const DTYPE: DType = DType::BFloat16;
    fn encode(self, bytes: &mut Vec<u8>) {
        bytes.extend_from_slice(&self.0.to_le_bytes());
    }
    fn decode(bytes: &[u8]) -> Self {
        Self(u16::from_le_bytes([bytes[0], bytes[1]]))
    }
}
impl sealed::Sealed for bool {}
impl TensorElement for bool {
    const DTYPE: DType = DType::Bool;
    fn encode(self, bytes: &mut Vec<u8>) {
        bytes.push(u8::from(self));
    }
    fn decode(bytes: &[u8]) -> Self {
        bytes[0] != 0
    }
}

/// An owned, contiguous tensor in row-major order. Cloning makes an independent
/// byte copy. Inputs are copied into native storage when a request executes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Tensor {
    dtype: DType,
    shape: Vec<usize>,
    bytes: Vec<u8>,
}

pub(crate) fn element_count(shape: &[usize], width: usize) -> Result<usize, Error> {
    if shape.len() > MAX_TENSOR_RANK {
        return Err(Error::TensorLimit(format!(
            "rank exceeds {MAX_TENSOR_RANK}"
        )));
    }
    let mut nonzero = width;
    for &dimension in shape {
        if dimension > isize::MAX as usize {
            return Err(Error::ShapeOverflow);
        }
        if dimension != 0 {
            nonzero = nonzero.checked_mul(dimension).ok_or(Error::ShapeOverflow)?;
            if nonzero > MAX_TENSOR_BYTES {
                return Err(Error::TensorLimit(format!(
                    "storage or nonzero dimensions exceed {MAX_TENSOR_BYTES} bytes"
                )));
            }
        }
    }
    let count = shape
        .iter()
        .try_fold(1usize, |count, &dimension| {
            if dimension > isize::MAX as usize {
                return None;
            }
            count.checked_mul(dimension)
        })
        .ok_or(Error::ShapeOverflow)?;
    let bytes = count.checked_mul(width).ok_or(Error::ShapeOverflow)?;
    if bytes > isize::MAX as usize {
        return Err(Error::ShapeOverflow);
    }
    Ok(count)
}

impl Tensor {
    /// Construct from typed scalars. An empty shape denotes a scalar (one value).
    pub fn from_vec<T: TensorElement>(
        shape: impl Into<Vec<usize>>,
        values: Vec<T>,
    ) -> Result<Self, Error> {
        let shape = shape.into();
        let expected = element_count(&shape, T::DTYPE.byte_width())?;
        if expected != values.len() {
            return Err(Error::ElementCount {
                expected,
                actual: values.len(),
            });
        }
        let mut bytes = Vec::with_capacity(expected * T::DTYPE.byte_width());
        for value in values {
            value.encode(&mut bytes);
        }
        Ok(Self {
            dtype: T::DTYPE,
            shape,
            bytes,
        })
    }
    /// Construct from exact little-endian scalar bytes. Boolean bytes must be 0/1.
    pub fn from_bytes(
        dtype: DType,
        shape: impl Into<Vec<usize>>,
        bytes: Vec<u8>,
    ) -> Result<Self, Error> {
        let shape = shape.into();
        let expected = element_count(&shape, dtype.byte_width())?;
        if bytes.len() != expected * dtype.byte_width() {
            if !bytes.len().is_multiple_of(dtype.byte_width()) {
                return Err(Error::DescriptorMismatch {
                    name: "tensor".into(),
                    reason: "byte length is not a whole number of scalars".into(),
                });
            }
            return Err(Error::ElementCount {
                expected,
                actual: bytes.len() / dtype.byte_width(),
            });
        }
        if dtype == DType::Bool
            && let Some((index, &value)) = bytes.iter().enumerate().find(|(_, value)| **value > 1)
        {
            return Err(Error::InvalidBoolean { index, value });
        }
        Ok(Self {
            dtype,
            shape,
            bytes,
        })
    }
    /// Allocate a tensor initialized to zero (false for booleans).
    pub fn zeros(dtype: DType, shape: impl Into<Vec<usize>>) -> Result<Self, Error> {
        let shape = shape.into();
        let count = element_count(&shape, dtype.byte_width())?;
        Ok(Self {
            dtype,
            shape,
            bytes: vec![0; count * dtype.byte_width()],
        })
    }
    /// Tensor scalar type.
    pub fn dtype(&self) -> DType {
        self.dtype
    }
    /// Dimensions in row-major order.
    pub fn shape(&self) -> &[usize] {
        &self.shape
    }
    /// Row-major strides in scalar elements. Empty tensors use zero strides.
    pub fn strides(&self) -> Vec<usize> {
        if self.is_empty() {
            return vec![0; self.shape.len()];
        }
        let mut strides = vec![0; self.shape.len()];
        let mut stride = 1;
        for index in (0..self.shape.len()).rev() {
            strides[index] = stride;
            stride *= self.shape[index];
        }
        strides
    }
    /// Scalar count, including one for rank-zero tensors.
    pub fn len(&self) -> usize {
        self.bytes.len() / self.dtype.byte_width()
    }
    /// Whether this tensor contains no scalars.
    pub fn is_empty(&self) -> bool {
        self.bytes.is_empty()
    }
    /// Exact contiguous little-endian scalar bytes.
    pub fn as_bytes(&self) -> &[u8] {
        &self.bytes
    }
    /// Copy tensor contents into typed Rust values after checking the dtype.
    pub fn to_vec<T: TensorElement>(&self) -> Result<Vec<T>, Error> {
        if T::DTYPE != self.dtype {
            return Err(Error::DTypeMismatch {
                expected: T::DTYPE,
                actual: self.dtype,
            });
        }
        Ok(self
            .bytes
            .chunks_exact(self.dtype.byte_width())
            .map(T::decode)
            .collect())
    }
    pub(crate) fn into_parts(self) -> (DType, Vec<usize>, Vec<u8>) {
        (self.dtype, self.shape, self.bytes)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn large_tensor_capacity_and_overflow_are_checked_without_allocating() {
        for (shape, width, bytes) in [
            (vec![1, 102816, 5376], 2, 1_105_477_632),
            (vec![124, 1344, 768, 3], 4, 1_535_901_696),
            (vec![345, 1344, 768, 3], 4, 4_273_274_880),
        ] {
            assert_eq!(element_count(&shape, width).unwrap() * width, bytes);
        }
        for dtype in [
            DType::Bool,
            DType::Float16,
            DType::BFloat16,
            DType::Float32,
            DType::Int32,
            DType::Int64,
        ] {
            let width = dtype.byte_width();
            let maximum = MAX_TENSOR_BYTES / width;
            assert_eq!(element_count(&[maximum], width).unwrap(), maximum);
            assert!(element_count(&[maximum + 1], width).is_err());
            assert!(Tensor::zeros(dtype, [0, maximum + 1]).is_err());
            assert!(element_count(&[isize::MAX as usize, 2], width).is_err());
            assert!(element_count(&[1; MAX_TENSOR_RANK + 1], width).is_err());
        }
    }
    #[test]
    fn bfloat16_all_encodings_widen_and_roundtrip_exactly() {
        let values: Vec<_> = (0..=u16::MAX).map(BFloat16::from_bits).collect();
        for (bits, value) in (0..=u16::MAX).zip(&values) {
            assert_eq!(value.to_bits(), bits);
            assert_eq!(value.to_f32().to_bits(), u32::from(bits) << 16);
            assert_eq!(BFloat16::from_f32(value.to_f32()).to_bits(), bits);
        }
        let tensor = Tensor::from_vec([values.len()], values.clone()).unwrap();
        assert_eq!(tensor.dtype(), DType::BFloat16);
        assert_eq!(tensor.to_vec::<BFloat16>().unwrap(), values);
        assert!(matches!(
            tensor.to_vec::<Float16>(),
            Err(Error::DTypeMismatch { .. })
        ));
        assert_eq!(tensor.as_bytes()[2..6], [1, 0, 2, 0]);
    }
    #[test]
    fn bfloat16_rounds_ties_boundaries_and_keeps_nan_class() {
        for (single, expected) in [
            (0x0000_0000, 0x0000),
            (0x8000_0000, 0x8000),
            (0x0000_8000, 0x0000),
            (0x0000_8001, 0x0001),
            (0x0001_8000, 0x0002),
            (0x007f_8000, 0x0080),
            (0x3f80_8000, 0x3f80),
            (0x3f80_8001, 0x3f81),
            (0x3f81_8000, 0x3f82),
            (0xbf81_8000, 0xbf82),
            (0x7f7f_7fff, 0x7f7f),
            (0x7f7f_8000, 0x7f80),
            (0xff7f_8000, 0xff80),
            (0x7f80_0000, 0x7f80),
            (0xff80_0000, 0xff80),
            (0x7f80_0001, 0x7f81),
            (0x7fc5_1234, 0x7fc5),
            (0xff80_0001, 0xff81),
        ] {
            assert_eq!(
                BFloat16::from_f32(f32::from_bits(single)).to_bits(),
                expected,
                "{single:#010x}"
            );
        }
        assert_eq!(
            element_count(&[MAX_TENSOR_BYTES / 2], 2).unwrap(),
            MAX_TENSOR_BYTES / 2
        );
        assert!(element_count(&[MAX_TENSOR_BYTES / 2 + 1], 2).is_err());
        assert!(element_count(&[0, MAX_TENSOR_BYTES / 2 + 1], 2).is_err());
    }
    #[test]
    fn half_exhaustive_bit_roundtrip() {
        for bits in 0..=u16::MAX {
            assert_eq!(
                Float16::from_f32(Float16::from_bits(bits).to_f32()).to_bits(),
                bits,
                "{bits:#06x}"
            );
        }
    }
    #[test]
    fn half_ieee_boundaries_and_ties() {
        for (single, half) in [
            (0x0000_0000, 0),
            (0x8000_0000, 0x8000),
            (0x3f80_0000, 0x3c00),
            (0x3f80_1000, 0x3c00),
            (0x3f80_1001, 0x3c01),
            (0x3f80_3000, 0x3c02),
            (0x3380_0000, 1),
            (0x3300_0000, 0),
            (0x3300_0001, 1),
            (0x3880_0000, 0x0400),
            (0x477f_e000, 0x7bff),
            (0x477f_f000, 0x7c00),
            (0x7f80_0000, 0x7c00),
        ] {
            assert_eq!(
                Float16::from_f32(f32::from_bits(single)).to_bits(),
                half,
                "{single:#010x}"
            );
        }
    }
    #[test]
    fn tensor_rejects_invalid_storage_before_native_calls() {
        assert!(matches!(
            Tensor::from_vec([2, 3], vec![1f32]),
            Err(Error::ElementCount {
                expected: 6,
                actual: 1
            })
        ));
        assert_eq!(
            Tensor::zeros(DType::Int64, [usize::MAX]),
            Err(Error::ShapeOverflow)
        );
        assert_eq!(
            Tensor::from_bytes(DType::Bool, [1], vec![2]),
            Err(Error::InvalidBoolean { index: 0, value: 2 })
        );
        assert!(Tensor::from_bytes(DType::Float32, [1], vec![0; 3]).is_err());
        let integers = Tensor::from_vec([2], vec![i64::MIN, i64::MAX]).unwrap();
        assert_eq!(integers.to_vec::<i64>().unwrap(), [i64::MIN, i64::MAX]);
        assert!(matches!(
            integers.to_vec::<f32>(),
            Err(Error::DTypeMismatch { .. })
        ));
    }
    #[test]
    fn scalar_and_empty_shapes_have_consistent_counts() {
        assert_eq!(Tensor::from_vec([], vec![true]).unwrap().len(), 1);
        assert!(Tensor::zeros(DType::Float32, [2, 0, 3]).unwrap().is_empty());
        assert!(matches!(
            Tensor::zeros(DType::Float32, [0, 1usize << 40]),
            Err(Error::TensorLimit(_))
        ));
        assert!(matches!(
            Tensor::zeros(DType::Bool, vec![1; 65]),
            Err(Error::TensorLimit(_))
        ));
    }
}
