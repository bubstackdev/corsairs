# Codebase review

Reviewed 2026-10-16 against `f4c2264` (`Record clean v0.3 qualification and registry network blocker`).

Four actionable findings were verified: three Medium and one Low. No Critical or High finding was verified. This is a source and contract review with bounded reproductions, not a proof of memory safety or a new native qualification run.

Follow-up remediation (2026-10-16): all four findings are addressed in the current source with regression tests. The findings below retain the original audit evidence and locations at `f4c2264`. Native lineage construction now preserves source alias checks without per-call history; waker clone/drop callbacks run outside the result mutex. Reference collection and freezing require OS backing and matching process exits, including exit 1 only for a digest-reviewed mismatch when freezing. Tests cover chained provenance, reentrant waker callbacks/cleanup, abnormal child exits, inherited framework overrides, and temporary freezing of the retained reference grid. Run Rust tests with `cargo test --offline -p corsairs --no-default-features` and Python regressions with `python3 -B -m unittest discover -s scripts/reference/tests -v`. Native re-check of the remediated source (2026-10-18): all 50 library tests pass with `--include-ignored` (including the six native lifecycle tests), `scripts/check_v02.py --native` passes debug/release native (32) and Metal (64) parity plus dynamic-shape and handle drivers, and `scripts/check_v01.py --native --cycles 10000 --loads 100 --dropped 100` passes 80,000 checked stress inferences. These reports were written under `target/`; tracked release evidence was not regenerated.

## Medium

### M1. Native chaining accumulates redundant alias origins on every inference

**Location:** `crates/corsairs-abi/src/native/owned/handles.rs:213–239`, especially line 234; publication at lines 385–393.

**Evidence and trigger:** `run_native` copies all input/state lineage into a new set, adds a fresh ID, and attaches that set to every output. Feeding an output into the next invocation repeats this process. After N calls starting from one uploaded tensor, the current output retains N+2 origins even if every predecessor handle has been dropped. The fresh origins are redundant because reserved origin `0` already makes all inference-derived handles possible aliases of one another, including outputs of calls without tensor inputs.

**Consequence:** A long native chain incurs O(N) provenance storage in its latest result and O(N²) cumulative hashing/copying work. Retaining the intermediate results also retains O(N²) provenance storage. This undermines the native chaining path even when tensor shapes and the number of live tensors stay fixed.

**Verification:** An optimized standalone Rust probe mirrored the production lineage block without invoking Core AI and dropped each predecessor. At 1,000 / 2,000 / 4,000 / 8,000 / 16,000 calls, it retained 1,002 / 2,002 / 4,002 / 8,002 / 16,002 origins and took approximately 5 / 20 / 82 / 327 / 1,329 ms on this run. Removing only the fresh per-call origin kept two origins after 16,000 calls and completed in under 1 ms. These are bookkeeping measurements, not inference latency measurements. The growth also follows directly from the source.

**Suggested fix:** Remove the per-call `output_lineage.insert(self.id()?)`. Preserve inherited upload IDs, which are needed to detect upload/output overlap, and reserved origin `0`, which covers output/output overlap. Add a focused regression that repeatedly propagates provenance and asserts that a fixed-source chain has bounded lineage while existing mutable-alias rejections still hold.

### M2. A reference child can crash after printing success and still pass validation

**Location:** `scripts/reference/run_suite.py:141–155`; related acceptance in `scripts/reference/freeze_goldens.py:29–41`.

**Evidence and trigger:** The suite parses the final stdout line, stores `completed.returncode`, and computes its aggregate result solely from JSON `status`. If a child prints `passed` or `expected_error` and then exits abnormally during native/Python teardown, the suite returns success. The golden freezer likewise does not check the recorded process exit before accepting a row.

**Consequence:** A lifecycle failure can be represented as a successful reference observation, defeating the script's stated rule that native traps remain failures. In a fresh or explicitly reviewed regeneration, the freezer can also label such an observation as completed native execution. Its existing immutable-original check prevents silently replacing the currently checked-in snapshot with changed observations; it does not validate process completion when establishing a baseline.

**Verification:** Called the actual `suite_main` with a mocked child result containing `returncode=-11` and a final JSON line with `status="passed"`. No native code ran and report writes were mocked. The checker returned 0 and produced `passed=true` while retaining the negative child exit code.

**Suggested fix:** Enforce the process-status contract independently of JSON status. `passed` and `expected_error` must require exit 0; signals and unexpected exits must fail the suite and freezing. Preserve the intentional exit 1 for the explicitly digest-reviewed `mismatch` accepted by the freezer. Retain stderr for abnormal exits even when stdout contains valid JSON, and cover this teardown-failure case with a subprocess-result test.

### M3. Reference regeneration accepts the wheel's alternate framework as OS parity

**Location:** `scripts/reference/run_suite.py:50–56,104–115,154–155`; `scripts/reference/freeze_goldens.py:14–37`.

**Evidence and trigger:** The child records `_use_os_coreai` as `os_backed` but never requires it to be true. Neither aggregate success nor golden freezing checks this field. The locally cached pinned wheel's framework selector confirms a concrete trigger: inherited `USE_LOCAL_COREAI` selects its bundled implementation on the supported macOS version when `USE_OS_COREAI` is absent. The selector tests presence, so even `USE_LOCAL_COREAI=0` requests that alternate backing. On older macOS it also selects the bundled implementation. Isolated Python mode does not remove these application-specific environment variables.

**Consequence:** The purported OS differential reference can pass against a different native implementation than Corsairs uses. A fresh/reviewed golden regeneration can therefore freeze backend behavior from the bundled framework while still satisfying the wheel identity check. This is a validation-contract defect; it does not establish any numerical difference between the two implementations.

**Verification:** Inspected the pinned selector at `.local/reference/coreai-b3/coreai/runtime/__init__.py:44–100` without importing native bindings. A separate mocked call to the actual suite accepted a successful child row with `os_backed=false`, returning 0 and `passed=true`. The current benchmark already demonstrates the intended protection in `scripts/reference/benchmark_v03.py:123–132`: set `USE_OS_COREAI`, remove `USE_LOCAL_COREAI`, then explicitly reject alternate backing.

**Suggested fix:** Apply that explicit OS selection before importing the reference runtime, and reject `os_backed is not True` in the child, parent aggregation, and freezer. Keep the backing identity in the report and add a regression for an inherited local-framework override.

**Existing reference evidence for M2/M3:** Both retained full-suite reports, `fixtures/parity-v01/python-results.json` and `python-results.initial.json`, contain 31 `passed` observations with exit 0, 16 `expected_error` observations with exit 0, and one intentionally reviewed GPU float-edge `mismatch` with exit 1. Every observation records `os_backed=true`. These reproductions do not show that the retained goldens are corrupted.

## Low

### L1. Replacing a waker can deadlock the worker through its destructor

**Location:** `crates/corsairs-abi/src/worker.rs:54–65`; completion acquires the same mutex at lines 77–83.

**Evidence and trigger:** `Task::poll` replaces `state.waker` while holding the result mutex. This drops the previous waker under that lock. A safe custom executor/waker can own cleanup whose destructor submits a runtime fence and synchronously waits for it. If that cleanup runs during replacement on the polling thread, the worker can finish the original request but block publishing its result on the mutex still held by `poll`; it consequently cannot execute the cleanup's queued fence. The `ReentrantWait` guard only detects waits from the worker thread and does not break this cycle.

**Consequence:** The polling thread and this runtime's worker can remain blocked indefinitely. Severity is Low because it requires a custom waker with synchronously waiting cleanup; the ordinary tested wait/wake paths do not trigger it.

**Verification:** A standalone safe Rust probe imported the unchanged `worker.rs` with a minimal error-type stub. It polled once with a custom `Wake` object, released the caller's waker reference, and polled again with a different waker. The old `Wake` object's destructor queued a second request and waited. The first request returned, but replacement did not finish before the probe's two-second timeout (exit 2). The identical probe completed against a temporary copy that moved waker cloning/destruction outside the result lock. No application source was modified.

**Suggested fix:** Clone the prospective replacement before acquiring the mutex; extract the previous waker while locked, then release the mutex before dropping it. User-controlled raw-waker clone/drop callbacks should not execute under the result mutex. Retain the existing rule that wake callbacks run outside the lock, and add a bounded regression for destructor reentrancy.

## Scope, methods, and limitations

- Reviewed the public API, tensor encodings and limits, task/worker lifecycle, default CLI, examples, native ABI shims, dynamic loading and symbol cache, metadata/value witnesses, errors, async/synchronous completion, owned/native tensor execution, Metal ownership and fencing, and model/function batches. Three review agents covered coherent areas; findings were checked against callers and the current source before inclusion.
- Reviewed Cargo manifests/lockfile, repository configuration, package/release contracts, fixtures and reference acceptance, current v0.3 qualification/package/aggregate workflows, H3/Krea and dtype/capacity drivers, research CLI, metadata tests, and relevant ABI/safety/compiler evidence. Historical scripts and experimental diagnostics received lighter inspection. No applicable `AGENTS.md` or pre-existing worktree changes were present, and no untracked source was found.
- Compared unsafe call/ownership assumptions with the repository's ABI ledgers and retained compiler IR. No additional concrete ABI, lifetime, batch-join, or Metal-fencing defect was verified. Existing evidence was treated as supporting material, not as a newly executed test or a guarantee for other OS builds.
- Excluded generated build/cache contents under `target/`, the cached reference dependency implementation from a general audit (its backing selector alone was inspected for M3), binary model/fixture payload internals, and historical distribution archives from independent native requalification. Generated compiler dumps and historical evidence copies were consulted selectively rather than exhaustively rereviewed as active source. External Krea/H3 assets and registry publication were not exercised.
- Did not execute Core AI/Metal inference, native ignored tests, reference bindings, publication, or qualification commands that overwrite tracked evidence. Native traps, device behavior, leak freedom, hostile-model handling, and performance beyond the isolated provenance bookkeeping probe remain unverified by this review.

## Verification performed

- `cargo test --offline -p corsairs --no-default-features`: 41 library tests, one CLI test, and one doctest passed; six native-environment tests were ignored.
- `cargo clippy --offline --workspace --all-targets --all-features -- -D warnings`: passed.
- `cargo fmt --all -- --check`: passed.
- Isolated lineage-growth probe, mocked reference acceptance checks, retained reference status/backing inspection, and bounded worker-waker deadlock reproduction as described above. Reproductions used temporary files and did not alter tracked implementation or evidence.

The original audit commit changed only this report. Subsequent remediation is described above; retained native qualification evidence was not regenerated.
