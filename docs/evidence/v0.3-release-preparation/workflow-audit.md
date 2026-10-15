# v0.3 release workflow preparation

Read-only source audit; no builds, native calls, staging, publication or external
communication were performed. Commands below are handoff instructions for the
release owner. Production cache/RGB changes and final version remain owner work.

## Required version and workflow changes

- Choose final `0.3.0` before source-pinned qualification. Current
  [package version](../../../crates/corsairs-abi/Cargo.toml#L3) and
  [lock entry](../../../Cargo.lock#L7) are `0.3.0-dev`. Rebuild after the final
  bump: the core and v0.1 manifests hash both files.
- Create a v0.3 package workflow or parameterize a new shared checker. Preserve
  the historical v0.2 checker/evidence. Its hardcodes are:

  | Source | Current value to replace/derive |
  | --- | --- |
  | [Lines 19–20](../../../scripts/check_package_v02.py#L19) | `target/package-check-v02`, `docs/evidence/v0.2/package-verification.json` |
  | [Lines 51–52](../../../scripts/check_package_v02.py#L51) | Archive/extracted root `corsairs-0.2.0` |
  | [Line 58](../../../scripts/check_package_v02.py#L58) | Allowed archive prefix `corsairs-0.2.0` |
  | [Line 90](../../../scripts/check_package_v02.py#L90) | Consumer version `=0.2.0` |
  | [Line 119](../../../scripts/check_package_v02.py#L119) | Distribution directory `dist/v0.2.0` |
  | [Lines 75–82](../../../scripts/check_package_v02.py#L75) | Core prerequisite remains `target/v02-check`; this is version-neutral code but must bind the final v0.3 sources |

- **Close the stale-archive/version gap:** the checker runs Cargo for the current
  manifest but then opens a hardcoded old archive. Its
  [current-source comparison](../../../scripts/check_package_v02.py#L70) omits
  `Cargo.toml.orig`. After a version-only bump, an old archive with otherwise
  identical source can therefore be mistaken for the new package. Derive the
  archive/prefix/version from the current manifest, compare `Cargo.toml.orig`
  byte-for-byte with it, and parse the normalized manifest to assert package
  name/version, empty defaults, no unexpected dependencies and the chosen
  license/MSRV. Compare the entire member set and every file hash.
- Keep `.cargo_vcs_info.json` distinct from source-content equality. The v0.2
  [publication record](../../v0.2-release.md#publication) documents the changed
  metadata member between its dirty candidate and clean-commit archive. The
  artifact uploaded for v0.3 must itself have a retained digest/member manifest;
  do not silently reuse a pre-commit checksum.
- Update current installation/workflow guidance in
  [README lines 20, 82, 92–95](../../../README.md#L20), the package README's
  [API version](../../../crates/corsairs-abi/README.md#L7) and
  [capacity statement](../../../crates/corsairs-abi/README.md#L67), plus current
  [safety](../../safety.md#L11), [compatibility](../../compatibility.md#L30),
  [large-tensor](../../v0.3-large-tensors.md) and
  [benchmark](../../v0.3-benchmarks.md) text. Add a v0.3 release record; retain
  v0.1/v0.2 publication history and pre-cache benchmark evidence unchanged.
  Replace the current tiny-call lookup-cost statement with a source/binary-pinned
  post-cache result. State the actual RGB outcome or exact safe bound.

## Existing preparation and package commands

These are the exact commands used by the current workflow, with v0.3 paths
shown only where the new checker must substitute them. Run from repository root.

1. Finish source/manifest/package-README edits, then freeze them. Complete static
   checks before the final default-feature builds:

   ```sh
   cargo fmt --all --check
   cargo clippy --offline -p corsairs --all-targets --no-default-features -- -D warnings
   cargo clippy --offline --workspace --all-targets --all-features -- -D warnings
   cargo test --offline --workspace --all-features
   RUSTDOCFLAGS=-Dwarnings cargo doc --offline --workspace --all-features --no-deps
   ```

   The all-feature metadata tests invoke native framework metadata. The owner
   should execute that test command in the permitted native environment.

2. Prepare default core binaries with `python3 -B scripts/check_v02.py`, then
   execute `python3 -B scripts/check_v02.py --native --no-build` in the permitted
   native environment. Both profiles are default. The
   [source/binary checks](../../../scripts/check_v02.py#L78) reject changed
   sources or overwritten `target/{debug,release}/libcorsairs.rlib` aliases.
   Other all-feature builds must not replace those aliases between pinning and
   native execution. Keep new retained reports in v0.3 directories.

3. The archive preparation commands are already
   [explicit in the checker](../../../scripts/check_package_v02.py#L49):

   ```sh
   cargo package --offline --locked -p corsairs --list --allow-dirty
   cargo package --offline --locked -p corsairs --allow-dirty
   ```

   They verify/build the package but upload nothing. `--allow-dirty` is the
   current candidate policy, not evidence of a clean release commit. When a
   clean release snapshot is available, package it without that flag and bind
   the resulting archive too.

4. For version `0.3.0`, the extracted package is
   `target/package/corsairs-0.3.0`. The isolated consumer should contain:

   ```toml
   [package]
   name = "corsairs-release-consumer"
   version = "0.0.0"
   edition = "2024"

   [dependencies]
   corsairs = { version = "=0.3.0", path = "/Users/zakkeown/Code/aether/lab/corsairs/target/package/corsairs-0.3.0" }

   [workspace]
   ```

   Copy all four archived examples and their models into that consumer, then
   follow the existing [feature/build checks](../../../scripts/check_package_v02.py#L97):

   ```sh
   cargo generate-lockfile --offline --manifest-path target/package-check-v03/consumer/Cargo.toml
   cargo tree --offline --locked --edges features --manifest-path target/package-check-v03/consumer/Cargo.toml
   CARGO_TARGET_DIR=target/package-check-v03/consumer-target cargo build --offline --locked --release --examples --manifest-path target/package-check-v03/consumer/Cargo.toml
   CARGO_TARGET_DIR=target/package-check-v03/package-target cargo build --offline --locked --release --examples --bin corsairs --manifest-path target/package/corsairs-0.3.0/Cargo.toml
   ```

   Require no `abi-research` in the ordinary consumer feature tree. Native-run
   `release/examples/{feedforward,stateful,native_chain,metal_chain}` from **both**
   target directories: eight runs. Then native-run the packaged CLI:

   ```text
   target/package-check-v03/package-target/release/corsairs inspect target/package/corsairs-0.3.0/models/feedforward.aimodel --compute gpu-preferred
   ```

   These are the current checker's exact native coverage at
   [lines 112–118](../../../scripts/check_package_v02.py#L112). They do not replace
   the new cache/large-RGB qualification. Copy the final archive, checksum and
   source/member manifest to `dist/v0.3.0`, preserving pre-/post-commit identities
   if they differ.

## Minimum final native regression after symbol caching

Rebuild each Rust driver against the final cache implementation. Existing
uncached observations cannot qualify the new artifact. Reuse unchanged,
SHA-pinned Swift goldens instead of recompiling every independent oracle.

1. **Cache ownership/error invariants:** exercise repeated successful and missing
   lookups; multiple runtimes concurrently; dropping one runtime while another
   uses cached symbols; dropping all and opening another. If the cache is global,
   its key must preserve library/resolution identity and every cached pointer
   must retain valid code lifetime. Current
   [metadata tests](../../../crates/corsairs-abi/tests/native_metadata.rs#L3)
   cover repeated canonical metadata and one missing lookup, but not this complete
   global-lifetime matrix. Add focused coverage in the owner's production patch.
   Current [Library::drop](../../../crates/corsairs-abi/src/native/loader.rs#L47)
   closes its handle, so lifetime cannot be inferred from a raw pointer alone.
2. **Core grid, debug and release:** `check_v02.py --native --no-build` covers
   dynamic signatures/options, handles, all 32 native-storage parity cases and
   all 64 Metal cases per profile. Add v0.1 parity/typed negatives with
   `check_v01.py --native --no-build --skip-stress`; it covers 32 positive and
   16 negative cases per profile. Existing drivers can provide reduced repeated
   load/drop counts; the historical 80,000-call run need not be repeated solely
   to prove a pointer lookup cache if these focused paths pass.
3. **Five native lifecycle tests on final release code:** the ignored facade
   tests cover model batches, synchronous function batches, retained chaining,
   Metal import/export, native errors, abandoned futures, and transitive drain.
   Build a release/default test binary, retain its digest, and run it with
   `--ignored --nocapture --test-threads=1` and `CORSAIRS_TEST_MODEL` set to the
   float32 `[2,3]` double fixture. Preserve at least one direct owned Swift-error
   release observation after repeated lookup hits; the missing-asset path is a
   real native throw, while missing function names can be optional-none.
4. **BF16:** rebuild `scripts/check_bfloat16_native.py build`, run the emitted
   debug/release commands under the native coordinator, then use its `check`
   subcommand against the retained Swift outputs. Preserve the 46 configurations,
   104 values, and native/Metal 65,536-encoding checks. The build script writes a
   historical v0.2 evidence path: route/copy the final report to a v0.3 directory
   rather than overwriting release history.
5. **New v0.3 capacity/RGB behavior:** qualify the chosen fix or safe bound on
   every API entry it changes, with CPU-only/GPU-preferred distinguished. Retain
   the long-RGB independent Swift failure. A safe rejection must happen before
   the problematic native call, preserve a usable runtime, and document its exact
   applicability; a flat 4 GiB GPU pass does not prove long RGB. Rerun the passing
   hidden, short RGB and flat-limit paths affected by the patch and the bound's
   edge/overflow/stride cases. The existing
   [large checker](../../../scripts/check_large_tensors.py#L107) compares seven
   Rust paths against an immediate Swift snapshot; its shape flags are
   `h3-hidden`, `h3-rgb124`, `h3-rgb345`, `limit-f32`.
6. **Representative real graph and performance:** on final cached code, execute
   one current H3 functional 19,333-row exact-output case through retained and
   Metal boundaries, plus the eight-step Krea Metal + parallel-load regression
   if that path is part of the release claim. Repeat matched tiny phase timings
   to demonstrate lookup-cache effect; preserve samples, output checks and
   source/binary pins. No repeated full synthetic backbone or full H3 generation
   is needed to establish a symbol cache alone.
7. **Qualified archive and post-publication consumer:** eight example runs and
   packaged CLI above are the minimum artifact gate. After the owner's authorized
   upload, independently download the exact registry version, compare checksum
   with the qualified archive, and run a fresh version-only default-feature
   consumer with unsafe code forbidden. The v0.2
   [publication and consumer records](../../v0.2-release.md#publication) establish
   the prior protocol. A blocked connected Cargo dry run is not a passing
   registry check; the v0.2 record explicitly documents that distinction.

## Publication handoff

The normal owner-run command is `cargo publish --locked -p corsairs --dry-run`,
followed by the separately authorized `cargo publish --locked -p corsairs`.
Neither was executed in this audit. Resolve any DNS limitation without changing
the identity of the archive being qualified/uploaded. v0.2 used the Cargo Registry
Web API and retained an independently matching registry archive/checksum; that
historical fallback is described in its publication record, not assumed to be a
current successful preflight. Never include credential contents in command logs
or release evidence.
