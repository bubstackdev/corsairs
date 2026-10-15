# Review of a 2 GiB GPU accepted-tensor policy

Read-only design review; no production edit or native launch. The proposed boundary is a library support policy, not a discovered hardware/SDK limit. Boundary qualification is pending the root's coordinated runs.

Suggested public wording:

> Storage and CPU execution retain the 4 GiB checked tensor boundary. GPU-preferred inference accepts tensors/results only when both logical payload and required referenced span are at most 2 GiB. Concrete inputs/bindings and fixed signatures are checked before dispatch; dynamic outputs are checked after actual stream completion and throwing readiness. This limits accepted API values, not executed internal tensors, graph working set, GPU allocation or runtime duration. An oversized dynamic output can execute before typed rejection. Stateful convenience GPU calls retain their tighter fixed-signature 1 GiB envelope.

The dynamic-output distinction is material: a small input does not prove a small output, and fixed external output dimensions do not bound graph intermediates. Preserving dynamic GPU APIs is compatible with an accepted-result cap, provided it is not described as a predispatch execution/memory guarantee. Timeouts remain native execution outcomes; dropping a future must retain resources through actual completion, rather than implement cancellation by releasing them.

Concrete implementation checks:

- For retained inputs and ready outputs, check **both** packed byte count and nonnegative-stride referenced extent. A small logical tensor can span a large padded backing; a broadcast can have a small span but a large logical count. Reuse checked PackingPlan arithmetic, with the GPU policy limit applied separately from the shared 4 GiB storage limit. Reject unsupported negative-stride addressing where that span cannot be established.
- Keep the existing checked nonzero-dimension guard for empty shapes consistent across descriptors and concrete tensors; otherwise an empty axis can evade a product-based admission rule. Unit axes with arbitrary strides do not increase the touched span. Empty tensors touch zero bytes.
- Define span as the required byte range relative to the logical origin, not an entire backing object's allocation length. Independently check byte-offset addition and that the referenced range lies inside the actual buffer. A large backing/small view is a separate condition from an oversized tensor.
- Check known oversize fixed descriptors and actual inputs/bindings before encode, including CPU-produced handles reused in GPU functions. For a dynamic result, check ready shape/strides/dtype **before** public ID insertion or any owned host-copy allocation. Keep the post-readiness fence before every size/metadata error can destroy a result or owned native error.
- On oversized-result rejection, remove every transaction-private input/output ID and retain the persistent queue intentionally. Dropped/ignored error futures must still permit drain and later valid inference. Private stream ownership must stay separate from public queue leak counts.

If exact flat 2 GiB and near-boundary RGB173 pass the same-Runtime seven-path lifecycle, plus hidden/RGB124 and existing dtype/dynamic/state regressions, **2 GiB is a defensible tested support boundary**. A 1.5 GiB value has no independently stronger general safety evidence; lowering the number alone does not prove graph fit or avoid every layout-dependent defect. Neither number qualifies all shapes/graphs. Include repeated abandoned calls/drain at the selected boundary, since that is where the repaired 4.27 GB combined diagnostic remained unqualified. Preserve that failed observation rather than presenting the isolated single/chain pass as complete large-GPU qualification.
