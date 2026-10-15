//! Test-only foreign buffer boundary. Storage is library-owned, initialized and
//! accessed exclusively through one fenced queue; no external GPU/CPU access.
use corsairs::{BFloat16, DType, MAX_TENSOR_BYTES, Runtime, Tensor};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let runtime = Runtime::new()?;
    let queue = runtime.metal_queue().wait()?;
    let backing = queue
        .buffer(DType::Float32, [MAX_TENSOR_BYTES / 4])
        .wait()?;
    // SAFETY: No external work is submitted. All access uses this same queue,
    // and the exported owner plus imports retain the initialized shared backing.
    let object = unsafe { backing.export_buffer() }.wait()?;
    let cases = [
        (1 << 30, Tensor::from_vec([4], vec![1f32, 2., 3., 4.])?),
        (
            1usize << 31,
            Tensor::from_vec(
                [8],
                [
                    0x0001, 0x7f81, 0xff81, 0x8000, 0x3f80, 0xbf80, 0x7f80, 0xff80,
                ]
                .map(BFloat16::from_bits)
                .to_vec(),
            )?,
        ),
        (
            MAX_TENSOR_BYTES - 16,
            Tensor::from_vec([4], vec![91f32, -12., 0., -0.])?,
        ),
    ];
    let mut retained = Vec::new();
    for (offset, expected) in cases {
        // SAFETY: The live exported MTLBuffer is initialized, shared, mapped and
        // nonpurgeable. Bounds/alignment are checked; all accesses are serialized.
        let view = unsafe {
            queue.import_buffer(
                object.as_raw(),
                offset,
                expected.dtype(),
                expected.shape().to_vec(),
            )
        }
        .wait()?;
        assert_eq!(view.byte_offset(), offset);
        view.write(expected.clone()).wait()?;
        assert_eq!(view.download().wait()?, expected);
        retained.push((view, expected));
    }
    for (offset, shape) in [
        (1, vec![1]),
        (MAX_TENSOR_BYTES, vec![1]),
        (MAX_TENSOR_BYTES - 16, vec![5]),
        (usize::MAX - 3, vec![1]),
        (0, vec![MAX_TENSOR_BYTES / 4 + 1]),
        (0, vec![0, MAX_TENSOR_BYTES / 4 + 1]),
    ] {
        // SAFETY: Same valid, initialized, retained object; these requests test
        // the API's promised bounds/alignment rejection before native access.
        assert!(
            unsafe { queue.import_buffer(object.as_raw(), offset, DType::Float32, shape) }
                .wait()
                .is_err()
        );
    }
    drop((backing, object));
    runtime.drain().wait()?;
    for (view, expected) in &retained {
        assert_eq!(view.download().wait()?, *expected);
    }
    drop(retained);
    queue.fence().wait()?;
    drop(queue);
    runtime.drain().wait()?;
    println!(
        "{{\"passed\":true,\"backing_bytes\":{MAX_TENSOR_BYTES},\"large_offsets\":3,\"rejected_extents\":6,\"owners_dropped_before_download\":true}}"
    );
    Ok(())
}
