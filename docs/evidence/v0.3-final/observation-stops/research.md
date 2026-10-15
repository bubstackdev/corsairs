# Bounded audit of outer debugger stops

2026-10-15. This audit inspected retained observations and files; it did not execute a target, launch LLDB, or modify the checkers, native binaries, or original reports. `static-manifest.json` pins the inputs, commands, complete segment maps, symbol tables, and selected disassembly.

The nonzero exception addresses are consistent with debugger breakpoints. This does **not** establish the cause of every stop, and the zero-subcode entries remain unresolved.

| Retained address | Static evidence | Classification |
| --- | --- | --- |
| `0x100000460` | Exactly the C parent's `_main`, and exactly the requested breakpoint's resolved file/load address in `h3-hidden-cpu-parent-native.json` | Requested-breakpoint address match. The observer put it in `other_stops` with no entry event. |
| `0x100059940` | C parent highest segment end `0x10000c000` + installed **arm64e** dyld notifier offset `0x4d940` | Exact arithmetic match under the inferred adjacent dyld mapping. Live dyld base/slice was not retained. |
| `0x101191940` | CPython highest segment end `0x101144000` + the same `0x4d940` | Same inference, independently matching the different executable's layout. |
| `0x0` | No PC, image identity, registers, backtrace, or breakpoint ID accompanies these strings | Unclassified. Pairing with notifier/main stops suggests an observer/debugger relationship, but proves neither benignity nor the cause. |

The image end calculations include `__LINKEDIT`; the shorter `dyld_info -segments` display omits that segment. Both executable digests match the original observation identities. The C parent UUID is `80174D0A-8850-340E-94E3-A2F6C79941EA`; CPython is `4C4C4443-5555-3144-A1DF-64FEFA96526F`.

The installed `/usr/lib/dyld` universal-file SHA-256 is `be8904b70f95adeb9d244308ca470f939bb89bd32a9b1b05e3f65ac92579e226`. Its arm64e UUID is `D341DDCB-7969-3A9C-8E03-0CF4751398A9`; `_lldb_image_notifier` starts at `0x4d940` and contains `ret`. The next symbol, `_lldb_image_notifier_sim_trap`, starts at `0x4d944` and also contains `ret`. The preceding unrelated code includes a `brk`, but that is **not** the notifier instruction. The arm64e.x1 slice has UUID `8831382F-3800-372B-99C1-B23F876C0DA9` and a different notifier offset, `0x4acb8`, also `ret`. The address inference therefore concerns the arm64e slice specifically; it must not be generalized to all slices or to shared-cache dyld.

Apple's public [ExternallyViewableState.cpp](https://github.com/apple-oss-distributions/dyld/blob/main/dyld/ExternallyViewableState.cpp) defines the notifier as an empty, non-inlined function for LLDB and publishes its pointer in the image-information structure. LLVM's [DynamicLoaderMacOS.cpp](https://raw.githubusercontent.com/llvm/llvm-project/main/lldb/source/Plugins/DynamicLoader/MacOSX-DYLD/DynamicLoaderMacOS.cpp) installs an internal software breakpoint at that function, labels it `shared-library-event`, and uses its callback to update loaded images. These explain a plausible instrumentation mechanism; they are not version-matched proof of the installed Apple LLDB's behavior.

[LLDB's SBThread contract](https://lldb.llvm.org/python_api/lldb.SBThread.html#lldb.SBThread.GetStopReasonDataAtIndex) distinguishes breakpoint ID/location pairs from exception data. A textual `EXC_BREAKPOINT` description is insufficient to recover that distinction. The retained REA records have no structured stop reason, thread/PC, live dyld mapping, raw instruction bytes, or callback IDs for `other_stops`. Their coverage says complete, but their requested-entry event arrays are empty. This is complete process observation within the provider's stated scope, not proof of complete breakpoint classification.

The original CPU-hidden observations are:

- `h3-hidden-cpu-native.json`: `ev_803ff8324e1a0d588f0f07f216fdcdc479e0ad134aeaf552c108b1137bbbb61f`.
- `h3-hidden-cpu-retry-native.json`: `ev_9247fb88096e9534312c011ca39bca1a63112dc6c9002b694f5887be17022380`.
- `h3-hidden-cpu-parent-native.json`: `ev_8ca17e0d09259c6448af8f13ce4d7d2b041c75e59af941312cd9396fe720569f`.

All three root observations exited 0 with complete, untruncated success output and empty stderr. The separately retained `h3-hidden-cpu-first-report.json` records Swift and Rust child exit 0, no deadline, and all seven Rust paths' full-byte/hash checks passing. Those are positive child-result observations, while the outer unclassified stops remain a separate diagnostic. It would be inaccurate either to label the aggregate free of anomalous stops or to infer a child crash solely from these outer strings.

The smallest discriminating control, if the root elects to run one, is the same unchanged C observation parent with a module-scoped `dyld` / `lldb_image_notifier` requested breakpoint and a caller backtrace. REA supports that request. The returned resolved load address can establish or refute the inferred notifier mapping even if entry recording again fails; a recorded notifier event/backtrace would strengthen it. Use an event limit high enough not to terminate the checker. This control would still not classify zero-subcode entries without per-stop PC/reason data. Preserve all originals and classify only directly matched stops; never blanket-ignore breakpoint exceptions or any child error, timeout, or incomplete output.
