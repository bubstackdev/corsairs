# Initial signed-zero capacity probe

The first pattern included -0. The large CPU-only BF16 Swift add canonicalized -0 to +0, so its strict mathematical pattern check failed before Rust ran. The diagnostic retains exact bytes: factor2 lane5 was 0x0000 instead of 0x8000. GPU-preferred hidden and exact4GiB probes had passed.

These observations and original harness sources remain unchanged. Pattern version2 uses finite nonzero values to isolate capacity. Its Rust comparisons still require exact independent Swift hashes; no tolerance or production code was relaxed.
