# Synchronous Swift throw ownership

The [native run](../../v0.2-function-throw-oracle-native.json) completed 200
invocations in 25 observed and 25 abandoned four-call batches. Each batch mixed
two genuine Core AI function loads with two deliberate Swift throws. The
observed batches reported 50 `FunctionThrowOracle.DeliberateFailure` errors;
100 payload objects were created and all 100 were destroyed. Every invocation
joined, and the observed peak was three outstanding native calls.

The [retained manifest](retained-manifest.json) binds the native executable,
report, compiler IR, and exact tested source snapshots. The original build
manifest is retained unchanged, including its historical pre-run pending label.
The newer retained manifest records the completed run. Its
[adapter comparison](current-production-adapter-equality.json) checks that the
current production pending-call implementation is byte-identical, that the sync
task adapter differs only in its module description, and that the completion,
preparation and join/drop guards are identical.

The Swift method's compiler lowering matches the synchronous nonmutating
`AIModel.loadFunction(named:)` call shape: indirect optional result, borrowed
String words, borrowed model self, and an owned synchronous Error. A deliberate
throw replaces the model load only for a reserved oracle name. The payload's
Swift `deinit` counter verifies release on both observed error projection and
abandoned batch cleanup. Missing function names returning `nil` exercise a
different path.

These files are test-only evidence snapshots from an isolated source copy. The
injection method and dynamic oracle loader are absent from production. The
oracle dylib is pinned for process lifetime to preserve Swift code and metadata;
the balanced payload counters concern Error ownership. This run does not claim
to reproduce a real Core AI model-materialization throw, and it predates the
later BF16/drain additions.
