# v0.3 archive checker handoff

`scripts/check_package_v03.py` is an explicitly authorized test-only workflow.
The v0.2 checker and historical evidence are unchanged. After the source/version
freeze and current core gates, the release owner authorized the author to run
offline preparation. It passed; native qualification remains owner work.

Preparation (offline packaging, complete archive/source checks and isolated
builds; no native examples/framework calls):

```sh
python3 -B scripts/check_package_v03.py --allow-dirty --expected-version 0.3.0 --dist-dir dist/v0.3.0-candidate
```

In the native coordinator, using those exact prepared files and binaries:

```sh
python3 -B scripts/check_package_v03.py --native --no-build --expected-version 0.3.0 --dist-dir dist/v0.3.0-candidate
```

`--timeout` defaults to 180 seconds and rejects values above 300. Preserve the
preparation and native reports separately if desired with `--report`. The
prepared manifest retains the preparation commands. `--core-manifest` and
`--core-checks` select a retained current native core snapshot; defaults are
`target/v02-check/{build-manifest,checks}.json`, whose checker is version-neutral.

For the clean release archive, omit `--allow-dirty` and `--dist-dir`; the default
destination derives from the manifest as `dist/corsairs-0.3.0`. Use a separate
`--output` and `--report` to preserve the dirty candidate's preparation. Repeat
the native stage against that clean preparation. An existing differently hashed
candidate is never overwritten. A VCS metadata change therefore requires fresh
archive qualification rather than silent checksum reuse.

The checker derives the package archive name and prefix from the current final
`0.3.x` manifest. It compares Cargo's complete member list, rejects duplicate,
traversing, noncanonical, sparse and nonregular members, reads every payload and
writes a fresh extracted tree without tar's extraction routines. It checks every
source-backed member, including `Cargo.toml.orig`, the package README, licenses,
all source/example/model/test files and model provenance. It checks normalized
metadata/MSRV, empty defaults, the isolated research feature and no dependencies.
Every production source must belong to the passing native core source freeze.

It builds the archive and a distinct consumer whose exact-version path
dependency points to that extraction. The copied examples forbid unsafe code;
the normal feature tree must exclude `abi-research`. All Cargo targets are
isolated from the core test's `target/{debug,release}/libcorsairs.rlib` aliases.

The optional native stage runs four output-asserting examples from each of the
archive and external consumer (eight successful exits), packaged CLI version,
help and GPU inspection, the safe consumer's 65,536-encoding BF16 host roundtrip,
and exact-output CPU/GPU BF16 CLI runs. The latter use a separately frozen/copy-
verified tiny fixture; the report explicitly says it is outside the archive.
Complete archive/extraction/consumer/binary/core/fixture hashes are checked before
and after native execution. A preparation-only success is marked
`native_validated: false`. No phase contacts a registry, uploads a package or
claims a registry preflight succeeded.

## Preparation observation

The first owner-run attempt failed because the extracted package lived inside
the repository's Cargo workspace. Its full failure is preserved in
[`preparation-first.json`](../v0.3/preparation-first.json). The checker now puts
the entire disposable session in `/private/tmp`; it never edits the archived
manifest to add a workspace override. The authorized preparation rerun passed:

- Report: [`package-preparation.json`](../v0.3/package-preparation.json),
  `passed: true`, `native_validated: false`.
- Candidate: `dist/v0.3.0-candidate/corsairs-0.3.0.crate`, 103,084 bytes, 53 files.
- Archive SHA-256:
  `b486a51612ca351f807c3f622d977988f75215e005328b43acdd20a5525bb391`.
- Checker SHA-256:
  `c6a3e58ca9faf6de3b87c27ab70da366cee4ba85bcd81c2b6d3f095f7775c5ec`.
- Disposable session: `/private/tmp/corsairs-0.3.0-p9w9rz11`.
- Prepared manifest: `target/package-check-v03/prepared.json`.

The archive digest and member count were reread independently after preparation.
No native executable/framework call or upload was performed by this agent.
