# Current v0.3 native regressions

All production sources remain at the frozen v0.3 development identities.

- `v02-checks.json`: debug and release dynamic signatures, native-handle
  lifetime/cancellation, 32 native parity cases and 64 Metal parity cases per
  profile; all pass.
- `h3-checks.json`: exact original BF16 Swift modulation/live/cached hashes for
  the 128-row block, explicit reshape hint true; passes. Its independent CPU
  relative-error metric remains separate from the exact GPU gate.
- `krea-checks.json`: 32 retained segment calls, eight float32 latent steps,
  first carry hashes, final latent and decoded pixel hashes; all pass. The
  four denoisers use reshape true, the dynamic decoder false. Large output
  payloads remain in `/private/tmp/corsairs-v03-krea-native-regression`.

`h3-krea-native.json` and `h3-krea-retry-native.json` retain earlier controller
observations: the first rejected the H3 generated-data identity; the second
passed H3 and rejected Krea's generated-data identity. Only the generated
`data.rs` entries differed from their source manifests; library sources and
the existing binary bytes matched. Each driver
was rebuilt with its current generated references and its source/binary/library
manifest was rechecked. `h3-preflight-*` and `krea-preflight-*` preserve the
rejected snapshots. `krea-retry-native.json` retains the successful Krea run.

These regressions do not turn the separate largest-RGB Swift GPU failure into
a passing result. They do not establish full H3 video generation equivalence.
