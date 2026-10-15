# Native Python floating-point observations

This records a difference between the published Python runtime and the independent mathematical expectation. It is not a relaxed Rust comparison tolerance.

The `float_edges` fixture evaluates `x + x` for six float32 bit patterns:

| Element | Input bits | CPU/math output bits | GPU-preferred output bits |
| --- | --- | --- | --- |
| Positive zero | `00000000` | `00000000` | `00000000` |
| Negative zero | `80000000` | `80000000` | `80000000` |
| Positive infinity | `7f800000` | `7f800000` | `7f800000` |
| Negative infinity | `ff800000` | `ff800000` | `ff800000` |
| Quiet NaN with payload | `7fc12345` | `7fc12345` | `7fc00000` |
| Minimum positive subnormal | `00000001` | `00000002` | `00000000` |

CPU output SHA-256: `cebc55884945964a49d2b3cca4635eef1ee7f97f6a142b155fb809a3a042d1a8`.

GPU-preferred output SHA-256: `21d5209e8fc24ba7377db28f1433405693130086705058bd606a601e530f43d7`.

The initial Python-to-math comparison checks NaN class rather than payload, so the failing element was the subnormal becoming zero. The observed NaN payload canonicalization is an additional byte-level difference. The independent expected binary and original failed report remain unchanged. Frozen backend goldens include both differences; Rust-to-Python comparison uses exact bytes, including the observed NaN bits.

Apple's [Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf), edition 2026-06-04, section 8.1 (page 368), permits subnormal arithmetic inputs/results to become zero. Section 8.5 (pages 375–376) describes such handling and leaves the resulting zero's sign unspecified. This explains a possible mechanism consistent with the observation; it does not establish the actual CoreAI delegate used. The downloaded specification SHA-256 was `41538b30d2f1140a5b2a0c84ce0a9f7b67bf0c707e224cfea0bfe5a44aa26cf5`.

The GPU-preferred options allowed Neural Engine, GPU, and CPU and selected GPU as preferred. No delegate trace was collected. Therefore this evidence establishes behavior of that configuration on the recorded host, rather than a guarantee for every Apple GPU or OS. NaN canonicalization is an observed result, not a payload guarantee inferred from Metal documentation.

An [independent repeated Python invocation](python-results-float_edges-gpu-preferred.json) produced the identical output SHA-256 `21d5209e8fc24ba7377db28f1433405693130086705058bd606a601e530f43d7`. [The stability record](float-edges-stability.json) compares the initial report, repeat report, current payload and frozen golden identities. The repeated process still reports the expected independent-math mismatch; its return code 1 is preserved. This establishes repeat agreement for these bytes on this host, without implying universal backend determinism. The retained safe Rust debug and release differential reports also match the exact frozen GPU-preferred bytes.
