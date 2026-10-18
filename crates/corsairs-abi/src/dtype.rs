//! Owned contiguous tensors. Conversion never reinterprets unaligned byte slices.
use crate::api_error::Error;
use std::fmt;

/// Maximum supported tensor rank.
pub const MAX_TENSOR_RANK: usize = 64;
/// Maximum tensor storage size (four GiB). For empty tensors, the same
/// bound applies to the product of nonzero dimensions to reject stride overflow.
pub const MAX_TENSOR_BYTES: usize = 1usize << 32;
/// Maximum accepted GPU-preferred inference tensor bytes/referenced span (2 GiB).
/// Raw storage and CPU-only calls retain the 4 GiB boundary. Dynamic outputs
/// are checked after readiness; this does not bound graph intermediates or
/// promise that a model fits GPU memory. Stateful owned/native GPU calls have
/// the narrower fixed-signature boundary described on `Function::run`.
pub const MAX_GPU_INFERENCE_TENSOR_BYTES: usize = 1usize << 31;

/// Scalar types supported by Corsairs.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[non_exhaustive]
pub enum DType {
    Float16,
    BFloat16,
    Float32,
    Float64,
    Float8E4M3Fn,
    Float8E5M2,
    Int8,
    Int16,
    Int32,
    Int64,
    UInt8,
    UInt16,
    UInt32,
    UInt64,
    Bool,
}

const SUPPORTED: [DType; 15] = [
    DType::Float16,
    DType::BFloat16,
    DType::Float32,
    DType::Float64,
    DType::Float8E4M3Fn,
    DType::Float8E5M2,
    DType::Int8,
    DType::Int16,
    DType::Int32,
    DType::Int64,
    DType::UInt8,
    DType::UInt16,
    DType::UInt32,
    DType::UInt64,
    DType::Bool,
];

impl DType {
    /// Every supported scalar type, in declaration order. Later releases may
    /// add types, so this is a slice rather than a fixed-length array.
    pub const fn all() -> &'static [Self] {
        &SUPPORTED
    }
    /// The 13 scalar types of v0.4.0, kept so this array's type does not change.
    #[deprecated(
        since = "0.4.1",
        note = "omits newer types such as float8; use `DType::all()`"
    )]
    pub const ALL: [Self; 13] = [
        Self::Float16,
        Self::BFloat16,
        Self::Float32,
        Self::Float64,
        Self::Int8,
        Self::Int16,
        Self::Int32,
        Self::Int64,
        Self::UInt8,
        Self::UInt16,
        Self::UInt32,
        Self::UInt64,
        Self::Bool,
    ];
    /// Number of bytes in one scalar.
    pub const fn byte_width(self) -> usize {
        match self {
            Self::Float8E4M3Fn | Self::Float8E5M2 | Self::Int8 | Self::UInt8 | Self::Bool => 1,
            Self::Float16 | Self::BFloat16 | Self::Int16 | Self::UInt16 => 2,
            Self::Float32 | Self::Int32 | Self::UInt32 => 4,
            Self::Float64 | Self::Int64 | Self::UInt64 => 8,
        }
    }
    /// Native scalar name, also used by the Python reference.
    pub const fn name(self) -> &'static str {
        match self {
            Self::Float16 => "float16",
            Self::BFloat16 => "bfloat16",
            Self::Float32 => "float32",
            Self::Float64 => "float64",
            Self::Float8E4M3Fn => "float8_e4m3fn",
            Self::Float8E5M2 => "float8_e5m2",
            Self::Int8 => "int8",
            Self::Int16 => "int16",
            Self::Int32 => "int32",
            Self::Int64 => "int64",
            Self::UInt8 => "uint8",
            Self::UInt16 => "uint16",
            Self::UInt32 => "uint32",
            Self::UInt64 => "uint64",
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
element!(f64, Float64, 8);
element!(i8, Int8, 1);
element!(i16, Int16, 2);
element!(i32, Int32, 4);
element!(i64, Int64, 8);
element!(u8, UInt8, 1);
element!(u16, UInt16, 2);
element!(u32, UInt32, 4);
element!(u64, UInt64, 8);
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

/// Exact minifloat decoding and round-to-nearest-even encoding shared by the
/// float8 types. Positive finite encodings `0..=MAX` are strictly increasing;
/// `MAX + 1` is the overflow encoding (NaN for e4m3fn, infinity for e5m2).
macro_rules! float8 {
    ($(#[$doc:meta])* $name:ident, $exponent:expr, $mantissa:expr, $bias:expr, $max:expr, $nan:expr, $inf:expr) => {
        $(#[$doc])*
        #[derive(Clone, Copy, Default, PartialEq, Eq, Hash)]
        #[repr(transparent)]
        pub struct $name(u8);

        impl $name {
            /// Construct without changing the bit representation.
            pub const fn from_bits(bits: u8) -> Self {
                Self(bits)
            }
            /// Return the exact 8-bit representation.
            pub const fn to_bits(self) -> u8 {
                self.0
            }
            /// Whether this encoding is a NaN.
            pub const fn is_nan(self) -> bool {
                let magnitude = self.0 & 0x7f;
                match $inf {
                    Some(inf) => magnitude > inf,
                    None => magnitude == $nan,
                }
            }
            /// Convert exactly into binary32, preserving signed zero. NaN
            /// becomes a quiet binary32 NaN with the same sign.
            pub fn to_f32(self) -> f32 {
                let sign = if self.0 & 0x80 != 0 { -1.0f32 } else { 1.0 };
                let magnitude = self.0 & 0x7f;
                if self.is_nan() {
                    return f32::from_bits(((self.0 as u32 & 0x80) << 24) | 0x7fc0_0000);
                }
                if $inf == Some(magnitude) {
                    return sign * f32::INFINITY;
                }
                let exponent = (magnitude >> $mantissa) as i32;
                let fraction = (magnitude & ((1 << $mantissa) - 1)) as u32;
                // Every float8 value is a small integer times a power of two,
                // so both products are exact in binary32.
                let (significand, power) = if exponent == 0 {
                    (fraction, 1 - $bias - $mantissa)
                } else {
                    (fraction | (1 << $mantissa), exponent - $bias - $mantissa)
                };
                sign * significand as f32 * f32::from_bits(((power + 127) as u32) << 23)
            }
            /// Convert binary32 with round-to-nearest, ties-to-even, matching
            /// ml_dtypes: values beyond the largest finite value round to
            /// the overflow encoding, and NaN becomes the canonical NaN with
            /// the same sign.
            pub fn from_f32(value: f32) -> Self {
                let sign = ((value.to_bits() >> 24) & 0x80) as u8;
                if value.is_nan() {
                    return Self(sign | $nan);
                }
                let target = f64::from(value.abs());
                let magnitude = |bits: u8| -> f64 {
                    if bits > $max {
                        // The virtual next step above the largest finite value.
                        2.0 * f64::from(Self($max).to_f32()) - f64::from(Self($max - 1).to_f32())
                    } else {
                        f64::from(Self(bits).to_f32())
                    }
                };
                // Largest encoding in 0..=MAX + 1 whose value is <= target.
                let (mut low, mut high) = (0u8, $max + 1);
                if target >= magnitude(high) {
                    return Self(sign | ($max + 1));
                }
                while high - low > 1 {
                    let middle = low + (high - low) / 2;
                    if magnitude(middle) <= target {
                        low = middle;
                    } else {
                        high = middle;
                    }
                }
                let below = target - magnitude(low);
                let above = magnitude(high) - target;
                let nearest = if below < above || (below == above && low & 1 == 0) { low } else { high };
                Self(sign | nearest)
            }
        }
        impl fmt::Debug for $name {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                write!(f, "{}({:?}, 0x{:02x})", stringify!($name), self.to_f32(), self.0)
            }
        }
        impl sealed::Sealed for $name {}
        impl TensorElement for $name {
            const DTYPE: DType = DType::$name;
            fn encode(self, bytes: &mut Vec<u8>) {
                bytes.push(self.0);
            }
            fn decode(bytes: &[u8]) -> Self {
                Self(bytes[0])
            }
        }
    };
}
float8!(
    /// An OCP FP8 E4M3 "fn" scalar: four exponent bits (bias 7), three fraction
    /// bits, no infinities, and NaN only at `0x7f`/`0xff`. Largest finite: 448.
    Float8E4M3Fn, 4, 3, 7, 0x7e, 0x7f, None
);
float8!(
    /// An OCP FP8 E5M2 scalar: IEEE-like with five exponent bits (bias 15), two
    /// fraction bits, infinities at `0x7c`/`0xfc`. Largest finite: 57344.
    Float8E5M2, 5, 2, 15, 0x7b, 0x7e, Some(0x7c)
);

/// An owned, contiguous tensor in row-major order. Cloning makes an independent
/// byte copy. Inputs are copied into native storage when a request executes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Tensor {
    dtype: DType,
    shape: Vec<usize>,
    bytes: Vec<u8>,
}

pub(crate) fn element_count(shape: &[usize], width: usize) -> Result<usize, Error> {
    element_count_with_limit(shape, width, MAX_TENSOR_BYTES)
}

pub(crate) fn element_count_with_limit(
    shape: &[usize],
    width: usize,
    limit: usize,
) -> Result<usize, Error> {
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
            if nonzero > limit {
                return Err(Error::TensorLimit(format!(
                    "storage or nonzero dimensions exceed {limit} bytes"
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
    fn float8_encodings_roundtrip_and_match_ocp_boundaries() {
        for bits in 0..=u8::MAX {
            let e4 = Float8E4M3Fn::from_bits(bits);
            if !e4.is_nan() {
                assert_eq!(
                    Float8E4M3Fn::from_f32(e4.to_f32()),
                    e4,
                    "E4M3FN 0x{bits:02x}"
                );
            }
            let e5 = Float8E5M2::from_bits(bits);
            if !e5.is_nan() {
                assert_eq!(Float8E5M2::from_f32(e5.to_f32()), e5, "E5M2 0x{bits:02x}");
            }
        }
        // E4M3FN: no infinity; the max/overflow midpoint ties to even (max).
        assert_eq!(Float8E4M3Fn::from_bits(0x7e).to_f32(), 448.0);
        assert_eq!(Float8E4M3Fn::from_f32(464.0).to_bits(), 0x7e);
        assert_eq!(Float8E4M3Fn::from_f32(480.0).to_bits(), 0x7f);
        assert_eq!(Float8E4M3Fn::from_f32(f32::NEG_INFINITY).to_bits(), 0xff);
        assert_eq!(Float8E4M3Fn::from_bits(0x01).to_f32(), 2f32.powi(-9));
        assert_eq!(
            Float8E4M3Fn::from_f32(2f32.powi(-10)).to_bits(),
            0,
            "tie to even zero"
        );
        // E5M2: IEEE-like; the max/overflow midpoint ties to even (infinity).
        assert_eq!(Float8E5M2::from_bits(0x7b).to_f32(), 57344.0);
        assert_eq!(Float8E5M2::from_f32(61440.0).to_bits(), 0x7c);
        assert_eq!(Float8E5M2::from_bits(0xfc).to_f32(), f32::NEG_INFINITY);
        assert_eq!(Float8E5M2::from_f32(-f32::NAN).to_bits(), 0xfe);
        assert!(
            Float8E5M2::from_bits(0x7d).to_f32().is_nan() && !Float8E5M2::from_bits(0x7c).is_nan()
        );
        assert_eq!(Float8E5M2::from_f32(-0.0).to_bits(), 0x80);
        let tensor = Tensor::from_vec(
            [2],
            vec![Float8E5M2::from_bits(0x7d), Float8E5M2::from_bits(0x01)],
        )
        .unwrap();
        assert_eq!(
            tensor.as_bytes(),
            [0x7d, 0x01],
            "storage keeps every encoding"
        );
        assert_eq!(tensor.dtype(), DType::Float8E5M2);
    }

    #[test]
    fn byte_aligned_integer_and_float64_elements_roundtrip_extremes() {
        fn roundtrip<T: TensorElement + Copy + PartialEq + fmt::Debug>(values: [T; 3]) {
            let tensor = Tensor::from_vec([3], values.to_vec()).unwrap();
            assert_eq!(tensor.dtype(), T::DTYPE);
            assert_eq!(tensor.as_bytes().len(), 3 * T::DTYPE.byte_width());
            assert_eq!(tensor.to_vec::<T>().unwrap(), values);
            let raw = Tensor::from_bytes(T::DTYPE, [3], tensor.as_bytes().to_vec()).unwrap();
            assert_eq!(raw, tensor);
        }
        roundtrip([i8::MIN, 0, i8::MAX]);
        roundtrip([i16::MIN, -1, i16::MAX]);
        roundtrip([0u8, 1, u8::MAX]);
        roundtrip([0u16, 1, u16::MAX]);
        roundtrip([0u32, 1, u32::MAX]);
        roundtrip([0u64, 1, u64::MAX]);
        roundtrip([f64::MIN_POSITIVE, -0.0, f64::MAX]);
        // Little-endian storage, independent of host order.
        let wide = Tensor::from_vec([1], vec![0x0102_0304_0506_0708u64]).unwrap();
        assert_eq!(wide.as_bytes(), [8, 7, 6, 5, 4, 3, 2, 1]);
        let nan = f64::from_bits(0x7ff4_0000_0000_0001);
        let bits = Tensor::from_vec([1], vec![nan])
            .unwrap()
            .to_vec::<f64>()
            .unwrap()[0]
            .to_bits();
        assert_eq!(bits, nan.to_bits(), "NaN payloads are stored verbatim");
        let names: std::collections::HashSet<_> = DType::all().iter().map(|d| d.name()).collect();
        assert_eq!(names.len(), DType::all().len());
        #[allow(deprecated, reason = "the v0.4.0 array keeps its published contents")]
        let published = DType::ALL;
        assert_eq!(published.len(), 13);
        assert!(published.iter().all(|dtype| DType::all().contains(dtype)));
        assert!(
            !published.contains(&DType::Float8E4M3Fn) && !published.contains(&DType::Float8E5M2)
        );
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
