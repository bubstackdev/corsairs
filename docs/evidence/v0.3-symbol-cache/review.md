# Focused loader review

An independent review of loader SHA-256
`5ab928127646ee2ef9aea3f698ad3fc0da8df344a74506d3752f44296f6df3da`
found no concrete safety/correctness defect. This is a bounded static review,
not proof for arbitrary external native libraries.

Checked: per-library cache ownership; CString keys and content equality;
successful non-null address caching; exposed-provenance reconstruction; fresh
thread-local error retrieval on retried failures; no new Library Send/Sync;
PendingCall's borrowed Runtime and join/drop boundary; NativeSession destruction
of native stores before closing the framework.

Holding the cache mutex through dlsym has no identified reentrant path for the
fixed system symbols used here. Calls occur after symbol resolution releases
the lock, and native async callbacks use pre-resolved addresses. A custom
reentrant resolver could deadlock but is outside these investigated call paths.

The source snapshot and build manifest match. The reviewer performed no native
execution or source changes. Root independently ran the exact-output before/
after benchmark and the focused cache, workspace and clippy checks.
