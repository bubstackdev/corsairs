# Core AI direct Rust binding: ABI preflight

Research date: 2026-10-15. This supplements the [original research](../../docs/coreai-rust-bindings-research.md).

Follow-up: [Experiment 004](experiment-004.md) demonstrates direct asynchronous model loading and exact tiny-model inference using stable Rust ARM64 assembly, with native error cleanup and owned completion state. The findings below preserve the earlier compiler preflight; they describe what was unresolved at that stage. General Swift interoperability remains outside this experiment.

## Decision

Begin with an ABI feasibility experiment before designing the production crate. The installed Rust compiler cannot directly express the complete demonstrated Core AI call path through ordinary `extern "Swift"` declarations. Merely selecting a nightly compiler would not resolve the argument classification and special parameter issues observed below.

The architecture constraint remains direct Rust calls into Apple's implementation, with no embedded Python or custom Swift application wrapper. Swift source in this directory is a compiler reference used to determine native signatures. It is not an application runtime component.

## Environment and evidence

| Component | Observed value |
| --- | --- |
| Operating system | macOS 27.0.1, build 26A434 |
| Rust | Homebrew rustc 1.99.0, commit b940084d7eb6a299eb4bfeb8e34901bc051e7ac4 |
| Rust LLVM | 23.1.2 |
| Rust host | aarch64-apple-darwin |
| Swift | Apple Swift 6.4, swiftlang-6.4.0.34.1 |
| Swift default target | arm64-apple-macosx27.0.0 |
| SDK | MacOSX27.0.sdk |
| SDK Core AI module version | 3600.83.2.14.1 |
| Cached Python reference | coreai-core 1.0.0b2 |

Compiler diagnostics, reference sources, IR excerpts, and source hashes are retained in [evidence/abi](evidence/abi/). The [manifest](evidence/abi/manifest.json) also records the inspected SDK interface hashes.

The Swift Core AI reference compiled to LLVM IR and linked successfully as an ordinary arm64 library. REA inspected that derived library without executing it: Evidence ID `ev_9267999708fea2b6af4a030b4feb4672ff76e47a4c26549d9ca00a7e46518785`, SHA-256 `323c20efce96f9c66d9932652d69aba4914fc0232f41b970e34449db7bb8883f`. The [complete static inspection](evidence/sdk-reference-macho.json) records linkage to the public CoreAI framework and its imported symbols. The REA session was closed afterward.

No reference function or native Core AI inference call was executed. Successful compilation and linkage establish neither runtime correctness nor safe Rust access.

## Findings

### 1. The installed stable compiler rejects Swift ABI declarations

An ordinary `unsafe extern "Swift"` declaration fails with E0658. Adding `#![feature(abi_swift)]` fails with E0554 because this compiler is stable. See [recorded diagnostics](evidence/abi/compiler-observations.json).

Rust lists `Swift` as a calling convention, but this does not imply stable support or full Swift interoperability. The [upstream tracking issue](https://github.com/rust-lang/rust/issues/156481) explicitly leaves layout and argument classification unresolved; the [initial implementation](https://github.com/rust-lang/rust/pull/155815) is a language experiment.

A temporary process-local `RUSTC_BOOTSTRAP=1` diagnostic invocation allowed inspection of the experimental code generation. This was a compiler investigation, not a proposed build configuration. No toolchain was installed or reconfigured.

### 2. Calling convention selection does not recover Swift aggregate lowering

For three UInt64/u64 fields, the experimental Rust declaration using `#[repr(C)]` and the Swift reference produce different native signatures:

```llvm
; Rust call declaration, rust-lowering.ll
declare swiftcc void @aggregate3(
    ptr sret([24 x i8]) align 8, ptr align 8)

; Swift reference, shortened symbol name
define swiftcc { i64, i64, i64 } @aggregate3(i64, i64, i64)
```

The memory representation can look simple while argument and result passing remain incompatible. Rust `repr(C)` is not a general mapping to Swift's ABI. This example rules out declaring arbitrary Swift values as similarly shaped Rust structs and assuming `extern "Swift"` will handle the rest. It does not establish that all manually lowered declarations fail.

### 3. The public Core AI path requires special parameter lowering and async support

Compiling [CoreAIReference.swift](evidence/abi/CoreAIReference.swift) against the installed SDK establishes these call shapes in [the retained declarations](evidence/abi/coreai-declarations.txt):

| Operation | Observed LLVM requirements |
| --- | --- |
| NDArray construction | swiftcc, opaque indirect result, Swift array and scalar enum values |
| AIModel.loadFunction(named:) | swiftcc, indirect optional result, Swift String words, swiftself, swifterror |
| AIModel(contentsOf:options:) | swifttailcc, swiftasync context, opaque URL/options/result storage |
| InferenceFunction.run(inputs:states:outputViews:) | swifttailcc, swiftasync, Swift dictionary, consumed view storage, swiftself |
| Outputs.count | swiftcc with swiftself |

A plain Rust pointer argument in the diagnostic probe does not acquire `swiftself`. The installed compiler does not accept `SwiftAsync`, `SwiftTail`, or `swiftasync` as Rust ABI spellings. `swiftasync` is an LLVM parameter attribute, while the asynchronous calls above use `swifttailcc`. See the [LLVM language reference](https://llvm.org/docs/LangRef.html#calling-conventions) and [Swift calling convention](https://github.com/swiftlang/swift/blob/main/docs/ABI/CallingConvention.rst).

A verified method to reproduce those complete call shapes from the chosen direct binding implementation remains unresolved. A Rust Future alone does not construct a Swift task or continuation context.

### 4. Use the current public SDK to select targets

The public umbrella module reexports CoreAIDelegates, which reexports CoreAIRuntime, CoreAIAsset, CoreAICommon, and CoreAICompiler. Public `AIModel.loadFunction(named:)` takes one explicit argument. The older Python extension imports a different overload with profiler, dependencies, and logger arguments.

The public overload compiled and linked through CoreAI successfully. The Python symbol inventory remains useful implementation evidence, but is not a substitute for the current public API contract. The attempted use of the Python-imported `ScalarType.bitCount` also failed Swift public API type checking; that member is absent from the inspected public interface.

The arm64 Swift reference linked successfully even though the SDK's supplied Apple Silicon textual interfaces and the older Python binary identify arm64e. Thus those files do not, by themselves, justify making the Rust application an arm64e target. Runtime execution and any pointer authentication requirements remain untested.

### 5. A small fixture has an official recipe

Apple's [construct-a-graph notebook](https://github.com/apple/coreai-torch/blob/main/docs/coreai-core/tutorials/construct-a-graph.ipynb) authors a function named `main`, with float32 input `x` of shape [2, 3], and output `y = x + x`. Its [runtime notebook](https://github.com/apple/coreai-torch/blob/main/docs/coreai-core/tutorials/run-an-aimodel.ipynb) provides the corresponding loading and execution reference. The notebook code was read through GitHub's contents API.

Use that operation as the initial proposed fixture, with explicit expected values and metadata checks. Prepare the asset separately using Apple's authoring tools; record their versions, the asset digest, and reference outputs. This preparation is compatible with a Rust-only application runtime. No existing .aimodel was found in the bounded local source-tree inventory, and no fixture has been generated or validated yet.

### 6. The newer wheel remains an optional evidence gap

[PyPI](https://pypi.org/project/coreai-core/) still lists 1.0.0b3. PyPI's JSON metadata was retrieved, but the wheel download failed DNS resolution for files.pythonhosted.org. The b3 extension was not inspected. Its macOS wheel tag is not evidence of the minimum operating system supported by every contained extension.

Resolve this when practical, but the installed SDK and OS framework provide a direct path for the initial ABI experiment without waiting for a newer Python reference.

## Initial implementation gates

1. **Establish the call mechanism.** Pin a reproducible toolchain and demonstrate direct/indirect results, ownership, self, errors, and asynchronous context lowering against the Swift compiler reference. Compare emitted IR and assembly. If Rust declarations cannot express a requirement, record the precise gap and evaluate a minimal assembly or LLVM mechanism separately; neither is implemented or proven here.
2. **Call a simple existing entry point.** Choose a verified nonthrowing metadata/accessor operation with a known signature. Run it from Rust and validate its result without introducing an application Swift wrapper.
3. **Construct and destroy a tensor.** Recover runtime metadata and value witness contracts instead of hardcoding resilient value layouts. Confirm shape, dtype, contents, and repeated cleanup. Keep buffer access unsafe until its lifetime contract is established.
4. **Prove async and failure handling early.** Demonstrate actual task completion, returned errors, and resource retention before designing a safe inference facade. Keep inputs, outputs, model resources, and task contexts alive through native completion. Treat cancellation as a separate behavior requiring evidence.
5. **Execute the tiny model.** Validate x -> x + x, missing assets/functions, and repeated load/run/drop cycles. Verify output shape, dtype, and exact expected values. Account for specialization/cache writes when isolating the fixture.
6. **Measure and expand.** Separate loading/specialization, submission, execution, and synchronization costs using the same assets and compute settings as a native reference. Investigate shared Metal buffers and state only after correctness. Make no speedup or zero-copy claim before measurement.

## Documentation to maintain during implementation

Keep one ABI contract ledger beside the low-level code. For each callable symbol record its public declaration, lowered signature, metadata requirements, ownership, success/error behavior, completion rule, platform versions, evidence source, and executable verification. Unverified entries remain unsafe research material.

Record the fixed architecture constraints and the first model acceptance criteria before adding a broad safe API. Defer crate-wide ergonomics, graph authoring, model conversion, and decode-loop design until these gates yield runtime evidence.
