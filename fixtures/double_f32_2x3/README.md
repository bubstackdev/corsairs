# Tiny Core AI parity fixture

`double_f32_2x3.aimodel` contains `main(x: float32[2,3]) -> y: float32[2,3]`, computing `x + x`. The MLIR source, exact input/expected bytes, package/native-library identities, and asset hashes are retained alongside it.

`build_fixture.py` uses Apple's published Python authoring tools to prepare the asset offline. `run_python_reference.py` loads and executes it through the published OS-backed Python runtime with CPU-only specialization. They are development tools and are never called by the Rust application. Their explicit cached import roots record this machine's reference environment; they are not a portable package installation. No new package installation is needed to use the retained asset.

The preparation/reference package is **coreai-core 1.0.0b2**, with CPython 3.12.14. This is older than the desired b3 parity baseline. See [manifest.json](manifest.json), [the successful Python result](python-reference.json), and [native execution evidence](../../docs/evidence/experiment-004/python-reference-observation.json). Asset metadata contains a creation time, so rebuilding can change container hashes even for an equivalent graph.

Run the fixed Rust comparison from the repository root:

```sh
cargo run --offline -p corsairs-lab -- infer fixtures/double_f32_2x3/double_f32_2x3.aimodel 1000
```

It checks `[2,-4,0,1,200,-0.5]` exactly, shape `[2,3]`, float32, and element strides `[3,1]`. `scripts/check.py --native` also checks the output-byte hash against the retained Python reference and compares the independent Swift executable. Native execution requires Core AI allocation/cache access; the development sandbox can prevent it.
