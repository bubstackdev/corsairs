# Published coreai-core 1.0.0b3 API inventory

Wheel SHA-256: `8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9`.

Each row marks planned v0.1 scope. Passing Rust evidence is tracked separately; this inventory does not claim full parity.

All graph authoring is deferred. Runtime support is limited to owned contiguous Bytes tensors (f16/f32/i32/i64/bool), named inputs/outputs/state, descriptors, model/function loading, CPU-only and GPU-preferred choices. NumPy/DLPack interop, image/storage variants, diagnostics, cancellation, Neural Engine, and the other members below remain deferred.

The pinned Python reference executed all 32 positive configurations and reported 16 expected negative errors. 31 configurations matched independent math expectations; GPU-preferred `float_edges` flushed a subnormal and canonicalized a NaN payload. Backend-specific exact-byte goldens preserve these observations. Rust safe-API validation is recorded separately below.

The bounded safe Rust subset passed all 32 positive and 16 typed negative configurations in debug, release, plus 10,000 stateless and 10,000 stateful calls per backend/profile, 100 load/drop cycles, and 100 abandoned futures of each tested kind. Retained source/binary snapshots: [checks-debug.json](../../docs/evidence/v0.1/checks-debug.json), [checks-release.json](../../docs/evidence/v0.1/checks-release.json). These results establish the tested v0.1 subset on the recorded host; they do not establish full Python class/argument behavior, authoring parity, or other OS/SDK support.

## runtime

18 top-level exports; 98 entries including class members.

| Entry | Kind | v0.1 | Verification | Signature |
| --- | --- | --- | --- | --- |
| `AIModel` | class | supported | tested subset (debug, release) | `() -> None` |
| `AIModel.__init__` | method | deferred | deferred | `(self) -> None` |
| `AIModel.function_names` | property | supported | tested subset (debug, release) | `(self: Self) -> list[str]` |
| `AIModel.load` | method | supported | tested subset (debug, release) | `(cls, path: pathlib.Path \| str, specialization_options: coreai.runtime._specialization_options.SpecializationOptions \| None = None) -> 'AIModel'` |
| `AIModel.load_function` | method | supported | tested subset (debug, release) | `(self: Self, function_name: str, intermediate_logger: _coreai_runtime_os.IntermediateLogger \| None = None, profiler: _coreai_runtime_os.Profiler \| None = None) -> coreai.runtime._inference_function.InferenceFunction` |
| `AIModel.specialization_options` | property | deferred | deferred | `(self: Self) -> coreai.runtime._specialization_options.SpecializationOptions \| None` |
| `AIModelAssetMetadata` | class | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.__init__` | method | deferred | deferred | `(self, /, *args, **kwargs)` |
| `AIModelAssetMetadata.author` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.creation_date` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.creator_defined_metadata` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.license` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.model_description` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.remove_custom` | method | deferred | deferred | `native/unavailable` |
| `AIModelAssetMetadata.set_custom` | method | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary` | class | deferred | deferred | `()` |
| `AIModelAssetSummary.compute_types` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary.function_inputs` | method | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary.function_names` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary.function_outputs` | method | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary.function_states` | method | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary.operation_distribution` | property | deferred | deferred | `native/unavailable` |
| `AIModelAssetSummary.storage_types` | property | deferred | deferred | `native/unavailable` |
| `CompileIdentifiers` | class | deferred | deferred | `native/unavailable` |
| `CompileIdentifiers.__init__` | method | deferred | deferred | `(self, /, *args, **kwargs)` |
| `CompileIdentifiers.delegate_id` | property | deferred | deferred | `native/unavailable` |
| `CompileIdentifiers.id` | property | deferred | deferred | `native/unavailable` |
| `ComputeUnitKind` | class | supported | tested subset (debug, release) | `()` |
| `ComputeUnitKind.available_kinds` | method | deferred | deferred | `native/unavailable` |
| `ComputeUnitKind.cpu` | method | supported | tested subset (debug, release) | `native/unavailable` |
| `ComputeUnitKind.gpu` | method | supported | tested subset (debug, release) | `native/unavailable` |
| `ComputeUnitKind.neural_engine` | method | deferred | deferred | `native/unavailable` |
| `HAS_IMAGE_SUPPORT` | value | deferred | deferred | `native/unavailable` |
| `ImageDescriptor` | class | deferred | deferred | `()` |
| `ImageDescriptor.height` | property | deferred | deferred | `native/unavailable` |
| `ImageDescriptor.pixel_format_type` | property | deferred | deferred | `native/unavailable` |
| `ImageDescriptor.width` | property | deferred | deferred | `native/unavailable` |
| `InferenceFunction` | class | supported | tested subset (debug, release) | `() -> None` |
| `InferenceFunction.__call__` | method | supported | tested subset (debug, release) | `(self: Self, inputs: dict[str, coreai.runtime._ndarray.NDArray \| PIL.Image.Image] \| None = None, state: dict[str, coreai.runtime._ndarray.NDArray] \| None = None) -> dict[str, coreai.runtime._ndarray.NDArray \| PIL.Image.Image]` |
| `InferenceFunction.__init__` | method | deferred | deferred | `(self) -> None` |
| `InferenceFunction.desc` | property | supported | tested subset (debug, release) | `(self: Self) -> 'InferenceFunctionDescriptor'` |
| `InferenceFunctionDescriptor` | class | supported | tested subset (debug, release) | `()` |
| `InferenceFunctionDescriptor.input_descriptor` | method | supported | tested subset (debug, release) | `native/unavailable` |
| `InferenceFunctionDescriptor.input_names` | property | supported | tested subset (debug, release) | `native/unavailable` |
| `InferenceFunctionDescriptor.name` | property | supported | tested subset (debug, release) | `native/unavailable` |
| `InferenceFunctionDescriptor.output_descriptor` | method | supported | tested subset (debug, release) | `native/unavailable` |
| `InferenceFunctionDescriptor.output_names` | property | supported | tested subset (debug, release) | `native/unavailable` |
| `InferenceFunctionDescriptor.state_descriptor` | method | supported | tested subset (debug, release) | `native/unavailable` |
| `InferenceFunctionDescriptor.state_names` | property | supported | tested subset (debug, release) | `native/unavailable` |
| `IntermediateLogger` | class | deferred | deferred | `native/unavailable` |
| `IntermediateLogger.__init__` | method | deferred | deferred | `(self, /, *args, **kwargs)` |
| `IntermediateLogger.is_enabled` | property | deferred | deferred | `native/unavailable` |
| `IntermediateLogger.requested_intermediates` | property | deferred | deferred | `native/unavailable` |
| `LogEvent` | class | deferred | deferred | `()` |
| `LogEvent.compile_ids` | property | deferred | deferred | `native/unavailable` |
| `LogEvent.data` | property | deferred | deferred | `native/unavailable` |
| `LogEvent.encoded_data` | property | deferred | deferred | `native/unavailable` |
| `LogEvent.event_id` | property | deferred | deferred | `native/unavailable` |
| `LogEvent.metadata` | property | deferred | deferred | `native/unavailable` |
| `LogEvent.phase` | property | deferred | deferred | `native/unavailable` |
| `LogEvent.timestamp` | property | deferred | deferred | `native/unavailable` |
| `NDArray` | class | supported | tested subset (debug, release) | `(data: 'np.ndarray[Any, Any] \| list[Any]', backing: 'StorageKind' = <StorageKind.BYTES: 'bytes'>) -> 'None'` |
| `NDArray.__init__` | method | supported | tested subset (debug, release) | `(self: 'Self', data: 'np.ndarray[Any, Any] \| list[Any]', backing: 'StorageKind' = <StorageKind.BYTES: 'bytes'>) -> 'None'` |
| `NDArray.dtype` | property | supported | tested subset (debug, release) | `(self: 'Self') -> 'str'` |
| `NDArray.from_descriptor` | method | deferred | deferred | `(cls, descriptor: 'NDArrayDescriptor') -> 'Self'` |
| `NDArray.numpy` | method | deferred | deferred | `(self: 'Self') -> 'np.ndarray[Any, Any]'` |
| `NDArray.shape` | property | supported | tested subset (debug, release) | `(self: 'Self') -> 'tuple[int, ...]'` |
| `NDArray.strides` | property | supported | tested subset (debug, release) | `(self: 'Self') -> 'tuple[int, ...]'` |
| `NDArrayDescriptor` | class | supported | tested subset (debug, release) | `()` |
| `NDArrayDescriptor.dtype` | property | supported | tested subset (debug, release) | `native/unavailable` |
| `NDArrayDescriptor.rank` | property | deferred | deferred | `native/unavailable` |
| `NDArrayDescriptor.shape` | property | supported | tested subset (debug, release) | `native/unavailable` |
| `NDArrayDescriptor.storage_kind` | property | deferred | deferred | `native/unavailable` |
| `Profiler` | class | deferred | deferred | `native/unavailable` |
| `Profiler.__init__` | method | deferred | deferred | `(self, /, *args, **kwargs)` |
| `SpecializationOptions` | class | supported | tested subset (debug, release) | `() -> 'None'` |
| `SpecializationOptions.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `SpecializationOptions.allowed_compute_unit_kinds` | property | deferred | deferred | `(self: 'Self') -> 'list[ComputeUnitKind]'` |
| `SpecializationOptions.cpu_only` | method | supported | tested subset (debug, release) | `(cls) -> 'SpecializationOptions'` |
| `SpecializationOptions.default` | method | deferred | deferred | `(cls) -> 'SpecializationOptions'` |
| `SpecializationOptions.from_preferred_compute_unit_kind` | method | supported | tested subset (debug, release) | `(cls, compute_unit_kind: 'ComputeUnitKind') -> 'SpecializationOptions'` |
| `SpecializationOptions.is_debug_enabled` | property | deferred | deferred | `(self: 'Self') -> 'bool'` |
| `SpecializationOptions.is_supported` | method | deferred | deferred | `() -> 'bool'` |
| `SpecializationOptions.preferred_compute_unit_kind` | property | deferred | deferred | `(self: 'Self') -> 'ComputeUnitKind \| None'` |
| `SpecializationOptions.with_debug` | method | deferred | deferred | `(self: 'Self', *, enabled: 'bool') -> 'SpecializationOptions'` |
| `StorageKind` | class | supported | tested subset (debug, release) | `(*values)` |
| `StorageKind.BYTES` | attribute | supported | tested subset (debug, release) | `native/unavailable` |
| `StorageKind.IO_SURFACE` | attribute | deferred | deferred | `native/unavailable` |
| `StorageKind.METAL` | attribute | deferred | deferred | `native/unavailable` |

## authoring

174 top-level exports; 305 entries including class members.

| Entry | Kind | v0.1 | Verification | Signature |
| --- | --- | --- | --- | --- |
| `AIModelAsset` | class | deferred | deferred | `() -> 'None'` |
| `AIModelAsset.__init__` | method | deferred | deferred | `(self: 'Self') -> 'None'` |
| `AIModelAsset.executable` | method | deferred | deferred | `(self: 'Self', specialization_options: 'SpecializationOptions \| None' = None) -> 'AsyncGenerator[AIModel]'` |
| `AIModelAsset.is_valid` | method | deferred | deferred | `(path: 'Path \| str') -> 'bool'` |
| `AIModelAsset.load` | method | deferred | deferred | `(cls, path: 'Path \| str') -> 'AIModelAsset'` |
| `AIModelAsset.metadata` | property | deferred | deferred | `(self: 'Self') -> 'AIModelAssetMetadata'` |
| `AIModelAsset.path` | property | deferred | deferred | `(self: 'Self') -> 'Path'` |
| `AIModelAsset.program` | property | deferred | deferred | `(self: 'Self') -> 'AIProgram'` |
| `AIModelAsset.summary` | method | deferred | deferred | `(self: 'Self', *, include_statistics: 'bool' = True) -> 'AIModelAssetSummary \| None'` |
| `AIModelAsset.update_metadata` | method | deferred | deferred | `(self: 'Self', updates: 'Callable[[AIModelAssetMetadata], None]') -> 'None'` |
| `AIProgram` | class | deferred | deferred | `(module: 'Module') -> 'None'` |
| `AIProgram.__init__` | method | deferred | deferred | `(self: 'Self', module: 'Module') -> 'None'` |
| `AIProgram.save_asset` | method | deferred | deferred | `(self: 'Self', path: 'Path', metadata: 'AIModelAssetMetadata \| None' = None, minimum_os: 'OSVersion' = <OSVersion.v27: 'v27'>) -> 'AIModelAsset'` |
| `AIProgram.set_hardware_constraints` | method | deferred | deferred | `(self, entrypoint: 'str', hw_constraint_config: 'dict[str, HardwareConstraints]') -> 'None'` |
| `AIProgram.set_static_shape_config` | method | deferred | deferred | `(self: 'Self', entrypoint: 'str', shapes_config: 'dict[str, dict[str, tuple[int, ...]]]') -> 'None'` |
| `AllocationType` | class | deferred | deferred | `(*values)` |
| `AllocationType.Heap` | attribute | deferred | deferred | `native/unavailable` |
| `AllocationType.IOSurface` | attribute | deferred | deferred | `native/unavailable` |
| `AllocationType.MTLBuffer` | attribute | deferred | deferred | `native/unavailable` |
| `AllocationType.__getitem__` | method | deferred | deferred | `(cls, name)` |
| `CompileUnitScope` | class | deferred | deferred | `(file: 'FileInfo', source_language: 'str' = 'DW_LANG_Python', producer: 'str' = 'ODIE', optimized: 'bool' = False, flags: 'str' = '') -> None` |
| `CompileUnitScope.__init__` | method | deferred | deferred | `(self, file: 'FileInfo', source_language: 'str' = 'DW_LANG_Python', producer: 'str' = 'ODIE', optimized: 'bool' = False, flags: 'str' = '') -> None` |
| `CompileUnitScope.flags` | attribute | deferred | deferred | `native/unavailable` |
| `CompileUnitScope.optimized` | attribute | deferred | deferred | `native/unavailable` |
| `CompileUnitScope.producer` | attribute | deferred | deferred | `native/unavailable` |
| `CompileUnitScope.source_language` | attribute | deferred | deferred | `native/unavailable` |
| `ContainerType` | class | deferred | deferred | `(*values)` |
| `ContainerType.CVPixelBuffer` | attribute | deferred | deferred | `native/unavailable` |
| `ContainerType.MTLTexture` | attribute | deferred | deferred | `native/unavailable` |
| `ContainerType.__getitem__` | method | deferred | deferred | `(cls, name)` |
| `Context` | class | deferred | deferred | `() -> 'None'` |
| `Context.__enter__` | method | deferred | deferred | `(self) -> 'Self'` |
| `Context.__exit__` | method | deferred | deferred | `(self, exc_type: 'type[BaseException] \| None', exc_value: 'BaseException \| None', traceback: 'TracebackType \| None') -> 'None'` |
| `Context.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `CustomMetalKernel` | class | deferred | deferred | `(name: str, input_names: list[str], result_names: list[str], src: str, metal_params: list[coreai.authoring.metal.MetalParameter] \| None = None, helper_src: str \| None = None, template_dtypes: dict[str, str] \| None = None) -> None` |
| `CustomMetalKernel.__init__` | method | deferred | deferred | `(self: Self, name: str, input_names: list[str], result_names: list[str], src: str, metal_params: list[coreai.authoring.metal.MetalParameter] \| None = None, helper_src: str \| None = None, template_dtypes: dict[str, str] \| None = None) -> None` |
| `CustomMetalKernel.metal_type_mappings` | attribute | deferred | deferred | `native/unavailable` |
| `CustomMetalKernel.template_kernel_src` | method | deferred | deferred | `(self: Self, kernel_id: str, input_metadata: list[coreai.authoring.metal.TensorMeta], result_metadata: list[coreai.authoring.metal.TensorMeta]) -> str` |
| `CustomMetalKernel.validate_and_set_dtype_templates` | method | deferred | deferred | `(self: Self, templates: dict[str, str], input_names: list[str]) -> None` |
| `DType` | class | deferred | deferred | `() -> 'None'` |
| `DType.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `DType.numpy` | property | deferred | deferred | `(self) -> 'np.dtype[Any] \| None'` |
| `DebugInfo` | class | deferred | deferred | `() -> 'None'` |
| `DebugInfo.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `DebugInfo.activate` | method | deferred | deferred | `(self) -> 'Generator[None, None, None]'` |
| `DebugInfo.col` | property | deferred | deferred | `(self) -> 'int \| None'` |
| `DebugInfo.current` | method | deferred | deferred | `(cls) -> 'DebugInfo \| None'` |
| `DebugInfo.end` | property | deferred | deferred | `(self) -> 'tuple[int, int] \| None'` |
| `DebugInfo.file` | method | deferred | deferred | `(cls, filename: 'str', line: 'int', col: 'int' = 0, *, end: 'tuple[int, int] \| None' = None, scope: 'Scope \| None' = None) -> 'Self'` |
| `DebugInfo.filename` | property | deferred | deferred | `(self) -> 'str \| None'` |
| `DebugInfo.inlined_at` | property | deferred | deferred | `(self) -> 'DebugInfo \| None'` |
| `DebugInfo.is_unknown` | property | deferred | deferred | `(self) -> 'bool'` |
| `DebugInfo.line` | property | deferred | deferred | `(self) -> 'int \| None'` |
| `DebugInfo.metadata_only` | method | deferred | deferred | `(cls, names: 'Sequence[str]') -> 'Self'` |
| `DebugInfo.scope` | property | deferred | deferred | `(self) -> 'Scope \| None'` |
| `DebugInfo.unknown` | method | deferred | deferred | `(cls) -> 'Self'` |
| `DebugInfo.with_inlined_at` | method | deferred | deferred | `(self, loc: 'DebugInfo') -> 'Self'` |
| `DebugInfo.with_metadata` | method | deferred | deferred | `(self, name: 'str') -> 'Self'` |
| `DebugInfo.with_op_id` | method | deferred | deferred | `(self, dialect: 'str', value: 'int') -> 'Self'` |
| `DebugInfo.with_scope` | method | deferred | deferred | `(self, scope: 'Scope') -> 'Self'` |
| `DebugInfo.with_subprogram` | method | deferred | deferred | `(self, name: 'str', *, mlir_type_str: 'str \| None' = None, linkage_name: 'str' = '') -> 'Self'` |
| `FileInfo` | class | deferred | deferred | `(filename: 'str', directory: 'str' = '', sha256_sum: 'str' = '') -> None` |
| `FileInfo.__init__` | method | deferred | deferred | `(self, filename: 'str', directory: 'str' = '', sha256_sum: 'str' = '') -> None` |
| `FileInfo.directory` | attribute | deferred | deferred | `native/unavailable` |
| `FileInfo.sha256_sum` | attribute | deferred | deferred | `native/unavailable` |
| `FourCC` | class | deferred | deferred | `(*values)` |
| `FourCC.RGBA` | attribute | deferred | deferred | `native/unavailable` |
| `FourCC.__getitem__` | method | deferred | deferred | `(cls, name)` |
| `HandleType` | class | deferred | deferred | `(inner_type: 'Type') -> 'None'` |
| `HandleType.__init__` | method | deferred | deferred | `(self, inner_type: 'Type') -> 'None'` |
| `HandleType.inner_type` | property | deferred | deferred | `(self) -> 'Type'` |
| `HardwareConstraints` | class | deferred | deferred | `(allocation_type: 'AllocationType', alignments: 'tuple[int, ...]', interleave: 'tuple[int, ...]') -> None` |
| `HardwareConstraints.__init__` | method | deferred | deferred | `(self, allocation_type: 'AllocationType', alignments: 'tuple[int, ...]', interleave: 'tuple[int, ...]') -> None` |
| `ImageConstraints` | class | deferred | deferred | `(backing: 'ContainerType', row_alignments_per_plane: 'tuple[int, ...]', *, four_cc: 'FourCC \| None' = None) -> None` |
| `ImageConstraints.__init__` | method | deferred | deferred | `(self, backing: 'ContainerType', row_alignments_per_plane: 'tuple[int, ...]', *, four_cc: 'FourCC \| None' = None) -> None` |
| `ImageConstraints.four_cc` | attribute | deferred | deferred | `native/unavailable` |
| `ImageSpec` | class | deferred | deferred | `(fourcc: 'FourCC', height: 'int', width: 'int', name: 'str \| None' = None, constraints: 'ImageConstraints \| None' = None) -> 'None'` |
| `ImageSpec.__init__` | method | deferred | deferred | `(self, fourcc: 'FourCC', height: 'int', width: 'int', name: 'str \| None' = None, constraints: 'ImageConstraints \| None' = None) -> 'None'` |
| `ImageSpec.constraints` | property | deferred | deferred | `(self) -> 'ImageConstraints \| None'` |
| `ImageSpec.fourcc` | property | deferred | deferred | `(self) -> 'FourCC'` |
| `ImageSpec.height` | property | deferred | deferred | `(self) -> 'int'` |
| `ImageSpec.is_materialized` | property | deferred | deferred | `(self) -> 'bool'` |
| `ImageSpec.name` | property | deferred | deferred | `(self) -> 'str \| None'` |
| `ImageSpec.width` | property | deferred | deferred | `(self) -> 'int'` |
| `ImageSpec.with_constraints` | method | deferred | deferred | `(self, constraints: 'ImageConstraints \| None') -> 'ImageType'` |
| `ImageSpec.with_name` | method | deferred | deferred | `(self, name: 'str \| None') -> 'ImageType'` |
| `ImageType` | class | deferred | deferred | `(fourcc: 'FourCC', height: 'int', width: 'int', name: 'str \| None' = None, constraints: 'ImageConstraints \| None' = None) -> 'None'` |
| `ImageType.__init__` | method | deferred | deferred | `(self, fourcc: 'FourCC', height: 'int', width: 'int', name: 'str \| None' = None, constraints: 'ImageConstraints \| None' = None) -> 'None'` |
| `ImageType.constraints` | property | deferred | deferred | `(self) -> 'ImageConstraints \| None'` |
| `ImageType.fourcc` | property | deferred | deferred | `(self) -> 'FourCC'` |
| `ImageType.height` | property | deferred | deferred | `(self) -> 'int'` |
| `ImageType.is_materialized` | property | deferred | deferred | `(self) -> 'bool'` |
| `ImageType.name` | property | deferred | deferred | `(self) -> 'str \| None'` |
| `ImageType.width` | property | deferred | deferred | `(self) -> 'int'` |
| `ImageType.with_constraints` | method | deferred | deferred | `(self, constraints: 'ImageConstraints \| None') -> 'ImageType'` |
| `ImageType.with_name` | method | deferred | deferred | `(self, name: 'str \| None') -> 'ImageType'` |
| `MetalParameter` | class | deferred | deferred | `(name: str, dtype: str, attr: str) -> None` |
| `MetalParameter.__init__` | method | deferred | deferred | `(self, name: str, dtype: str, attr: str) -> None` |
| `Module` | class | deferred | deferred | `() -> 'None'` |
| `Module.__enter__` | method | deferred | deferred | `(self) -> 'Self'` |
| `Module.__exit__` | method | deferred | deferred | `(self, exc_type: 'type[BaseException] \| None', exc_val: 'BaseException \| None', exc_tb: 'TracebackType \| None') -> 'None'` |
| `Module.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `Module.as_string` | method | deferred | deferred | `(self) -> 'str'` |
| `Module.create` | method | deferred | deferred | `(cls) -> 'Self'` |
| `Module.debug_info` | property | deferred | deferred | `(self) -> 'DebugInfo'` |
| `Module.dump` | method | deferred | deferred | `(self) -> 'None'` |
| `Module.verify` | method | deferred | deferred | `(self) -> 'None'` |
| `OSVersion` | class | deferred | deferred | `(*values)` |
| `OSVersion.__getitem__` | method | deferred | deferred | `(cls, name)` |
| `OSVersion.v27` | attribute | deferred | deferred | `native/unavailable` |
| `Operation` | class | deferred | deferred | `() -> 'None'` |
| `Operation.__getitem__` | method | deferred | deferred | `(self, key: 'str') -> 'AttrValue'` |
| `Operation.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `Operation.__setitem__` | method | deferred | deferred | `(self, key: 'str', value: 'AttrConvertible') -> 'None'` |
| `Operation.debug_info` | property | deferred | deferred | `(self) -> 'DebugInfo'` |
| `Operation.name` | property | deferred | deferred | `(self) -> 'str'` |
| `Operation.operands` | property | deferred | deferred | `(self) -> 'Sequence[Value]'` |
| `Operation.results` | property | deferred | deferred | `(self) -> 'Sequence[Value]'` |
| `SubprogramScope` | class | deferred | deferred | `(name: 'str', file: 'FileInfo', compile_unit: 'CompileUnitScope \| str', linkage_name: 'str' = '', mlir_type_str: 'str \| None' = None) -> None` |
| `SubprogramScope.__init__` | method | deferred | deferred | `(self, name: 'str', file: 'FileInfo', compile_unit: 'CompileUnitScope \| str', linkage_name: 'str' = '', mlir_type_str: 'str \| None' = None) -> None` |
| `SubprogramScope.linkage_name` | attribute | deferred | deferred | `native/unavailable` |
| `SubprogramScope.mlir_type_str` | attribute | deferred | deferred | `native/unavailable` |
| `SymbolRefScope` | class | deferred | deferred | `(symbol: 'str') -> None` |
| `SymbolRefScope.__init__` | method | deferred | deferred | `(self, symbol: 'str') -> None` |
| `TensorSpec` | class | deferred | deferred | `(shape: 'Sequence[int] \| None' = None, dtype: '_DTypeLike \| None' = None, name: 'str \| None' = None, encoding: '_Encoding \| None' = None) -> 'None'` |
| `TensorSpec.__init__` | method | deferred | deferred | `(self, shape: 'Sequence[int] \| None' = None, dtype: '_DTypeLike \| None' = None, name: 'str \| None' = None, encoding: '_Encoding \| None' = None) -> 'None'` |
| `TensorSpec.constraints` | property | deferred | deferred | `(self) -> '_Encoding \| None'` |
| `TensorSpec.dtype` | property | deferred | deferred | `(self) -> 'DType \| MLIRType \| None'` |
| `TensorSpec.encoding` | property | deferred | deferred | `(self) -> '_Encoding \| None'` |
| `TensorSpec.is_materialized` | property | deferred | deferred | `(self) -> 'bool'` |
| `TensorSpec.is_static` | property | deferred | deferred | `(self) -> 'bool'` |
| `TensorSpec.name` | property | deferred | deferred | `(self) -> 'str \| None'` |
| `TensorSpec.rank` | property | deferred | deferred | `(self) -> 'int \| None'` |
| `TensorSpec.shape` | property | deferred | deferred | `(self) -> 'tuple[int, ...] \| None'` |
| `TensorSpec.with_default_mtl_constraints` | method | deferred | deferred | `(self) -> 'TensorType'` |
| `TensorSpec.with_encoding` | method | deferred | deferred | `(self, encoding: '_Encoding \| None') -> 'TensorType'` |
| `TensorSpec.with_name` | method | deferred | deferred | `(self, name: 'str \| None') -> 'TensorType'` |
| `TensorType` | class | deferred | deferred | `(shape: 'Sequence[int] \| None' = None, dtype: '_DTypeLike \| None' = None, name: 'str \| None' = None, encoding: '_Encoding \| None' = None) -> 'None'` |
| `TensorType.__init__` | method | deferred | deferred | `(self, shape: 'Sequence[int] \| None' = None, dtype: '_DTypeLike \| None' = None, name: 'str \| None' = None, encoding: '_Encoding \| None' = None) -> 'None'` |
| `TensorType.constraints` | property | deferred | deferred | `(self) -> '_Encoding \| None'` |
| `TensorType.dtype` | property | deferred | deferred | `(self) -> 'DType \| MLIRType \| None'` |
| `TensorType.encoding` | property | deferred | deferred | `(self) -> '_Encoding \| None'` |
| `TensorType.is_materialized` | property | deferred | deferred | `(self) -> 'bool'` |
| `TensorType.is_static` | property | deferred | deferred | `(self) -> 'bool'` |
| `TensorType.name` | property | deferred | deferred | `(self) -> 'str \| None'` |
| `TensorType.rank` | property | deferred | deferred | `(self) -> 'int \| None'` |
| `TensorType.shape` | property | deferred | deferred | `(self) -> 'tuple[int, ...] \| None'` |
| `TensorType.with_default_mtl_constraints` | method | deferred | deferred | `(self) -> 'TensorType'` |
| `TensorType.with_encoding` | method | deferred | deferred | `(self, encoding: '_Encoding \| None') -> 'TensorType'` |
| `TensorType.with_name` | method | deferred | deferred | `(self, name: 'str \| None') -> 'TensorType'` |
| `TokenType` | class | deferred | deferred | `() -> 'None'` |
| `TokenType.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `Type` | class | deferred | deferred | `() -> 'None'` |
| `Type.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `Value` | class | deferred | deferred | `() -> 'None'` |
| `Value.__init__` | method | deferred | deferred | `(self) -> 'None'` |
| `Value.defining_op` | property | deferred | deferred | `(self) -> 'Operation \| None'` |
| `Value.type` | property | deferred | deferred | `(self) -> 'Type'` |
| `abs_` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `acos` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `acosh` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `add` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, y: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `all_` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `and_` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, y: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `any_` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `argmax` | function | deferred | deferred | `(x: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `argsort` | function | deferred | deferred | `(x: 'Value \| ConstLike', dim: 'Value \| ConstLike', descending: 'Value \| ConstLike', stable: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `asin` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `asinh` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `asymmetric_quant_stats` | function | deferred | deferred | `(x: 'Value \| ConstLike', value_range: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'list[Value]'` |
| `atan` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `atanh` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `batch_matmul` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `bfloat16` | value | deferred | deferred | `native/unavailable` |
| `bitwise_and` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `bitwise_or` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `bitwise_xor` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `blockwise_shift_scale` | function | deferred | deferred | `(data: 'Value \| ConstLike', scale: 'Value \| ConstLike', offset1: 'Value \| ConstLike', offset2: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `bool_` | value | deferred | deferred | `native/unavailable` |
| `broadcast_in_dims` | function | deferred | deferred | `(x: 'Value \| ConstLike', dim_sizes: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcast_shapes` | function | deferred | deferred | `(shape_1: 'Value \| ConstLike', shape_2: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcast_to` | function | deferred | deferred | `(x: 'Value \| ConstLike', shape: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_add` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_and` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_batch_matmul` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_bitwise_and` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_bitwise_or` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_bitwise_xor` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_divide` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_equal` | function | deferred | deferred | `(x: 'Value \| ConstLike', other: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_floor_divide` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_greater` | function | deferred | deferred | `(x: 'Value \| ConstLike', other: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_maximum` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_minimum` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_modulo` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_mul` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_not_equal` | function | deferred | deferred | `(x: 'Value \| ConstLike', other: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_or` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_pow` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_sub` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_where` | function | deferred | deferred | `(condition: 'Value \| ConstLike', x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `broadcasting_xor` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `build_sparse_with_bitmask` | function | deferred | deferred | `(values: 'Value \| ConstLike', bitmask: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `cast` | function | deferred | deferred | `(x: 'Value \| ConstLike', dtype: 'DType \| type[np.generic] \| TensorType', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `complex128` | value | deferred | deferred | `native/unavailable` |
| `complex64` | value | deferred | deferred | `native/unavailable` |
| `concat` | function | deferred | deferred | `(dimension: 'Value \| ConstLike', inputs: 'list[Value \| ConstLike]', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `conv2d` | function | deferred | deferred | `(x: 'Value \| ConstLike', weight: 'Value \| ConstLike', stride: 'Value \| ConstLike', dilation: 'Value \| ConstLike', groups: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `conv3d` | function | deferred | deferred | `(x: 'Value \| ConstLike', weight: 'Value \| ConstLike', stride: 'Value \| ConstLike', dilation: 'Value \| ConstLike', groups: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `conv_transpose2d` | function | deferred | deferred | `(x: 'Value \| ConstLike', weight: 'Value \| ConstLike', stride: 'Value \| ConstLike', padding: 'Value \| ConstLike', dilation: 'Value \| ConstLike', output_pad: 'Value \| ConstLike', groups: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `conv_transpose3d` | function | deferred | deferred | `(x: 'Value \| ConstLike', weight: 'Value \| ConstLike', stride: 'Value \| ConstLike', padding: 'Value \| ConstLike', dilation: 'Value \| ConstLike', output_pad: 'Value \| ConstLike', groups: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `cos` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `cosh` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `create_complex` | function | deferred | deferred | `(real: 'Value \| ConstLike', imaginary: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `dequantize` | function | deferred | deferred | `(x: 'Value \| ConstLike', scale: 'Value \| ConstLike', offset1: 'Value \| ConstLike', offset2: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `divide` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `equal` | function | deferred | deferred | `(x: 'Value \| ConstLike', other: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `erf` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `exp` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `expand_dims` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `float16` | value | deferred | deferred | `native/unavailable` |
| `float32` | value | deferred | deferred | `native/unavailable` |
| `float4_e2m1fn` | value | deferred | deferred | `native/unavailable` |
| `float64` | value | deferred | deferred | `native/unavailable` |
| `float8_e4m3fn` | value | deferred | deferred | `native/unavailable` |
| `float8_e5m2` | value | deferred | deferred | `native/unavailable` |
| `float8_e8m0fnu` | value | deferred | deferred | `native/unavailable` |
| `floor_divide` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `gather_along_axis` | function | deferred | deferred | `(x: 'Value \| ConstLike', indices: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `gather_nd` | function | deferred | deferred | `(x: 'Value \| ConstLike', indices: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `gelu` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, approximate: 'str' = 'none', loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `get_shape` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `graph` | function | deferred | deferred | `(fn: 'Callable[..., Any] \| None' = None, *, private: 'bool' = False, externalize: 'bool' = False, no_inline: 'bool' = False, provided_name: 'str \| None' = None, composite_decl: 'Attribute \| None' = None) -> '_FacadeGraph \| Callable[[Callable[..., Any]], _FacadeGraph]'` |
| `greater` | function | deferred | deferred | `(x: 'Value \| ConstLike', other: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `image_to_tensor` | function | deferred | deferred | `(source: 'Value', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `imaginary_part` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `index` | value | deferred | deferred | `native/unavailable` |
| `int16` | value | deferred | deferred | `native/unavailable` |
| `int2` | value | deferred | deferred | `native/unavailable` |
| `int32` | value | deferred | deferred | `native/unavailable` |
| `int4` | value | deferred | deferred | `native/unavailable` |
| `int64` | value | deferred | deferred | `native/unavailable` |
| `int8` | value | deferred | deferred | `native/unavailable` |
| `interpolate` | function | deferred | deferred | `(x: 'Value \| ConstLike', output_shape: 'Value \| ConstLike', scale: 'Value \| ConstLike', offset: 'Value \| ConstLike', interpolation_mode: 'str', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `interpolate_coordinates` | function | deferred | deferred | `(x: 'Value \| ConstLike', coords: 'Value \| ConstLike', interpolation_mode: 'str', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `log` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `lut_to_dense` | function | deferred | deferred | `(indices: 'Value \| ConstLike', lut: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `lut_to_sparse_with_bitmask` | function | deferred | deferred | `(sparse_indices: 'Value \| ConstLike', lut: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `maximum` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `maxpool2d` | function | deferred | deferred | `(output: 'TensorType', x: 'Value \| ConstLike', kernel_size: 'Value \| ConstLike', stride: 'Value \| ConstLike', dilation: 'Value \| ConstLike', ceil_mode: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `maxpool3d` | function | deferred | deferred | `(output: 'TensorType', x: 'Value \| ConstLike', kernel_size: 'Value \| ConstLike', stride: 'Value \| ConstLike', dilation: 'Value \| ConstLike', ceil_mode: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `minimum` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `modulo` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `mul` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, y: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `non_zero` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `not_` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `not_equal` | function | deferred | deferred | `(x: 'Value \| ConstLike', other: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `or_` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `pad` | function | deferred | deferred | `(x: 'Value \| ConstLike', padding: 'Value \| ConstLike', padding_value: 'Value \| ConstLike', padding_mode: 'str' = 'constant', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `pow_` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `quantize` | function | deferred | deferred | `(x: 'Value \| ConstLike', scale: 'Value \| ConstLike', offset1: 'Value \| ConstLike', offset2: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `range_` | function | deferred | deferred | `(start: 'Value \| ConstLike', stop: 'Value \| ConstLike', step: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `real_part` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reduce_max` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reduce_mean` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reduce_min` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reduce_product` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reduce_sum` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `relu` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reshape` | function | deferred | deferred | `(x: 'Value \| ConstLike', new_shape: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `reverse` | function | deferred | deferred | `(x: 'Value \| ConstLike', dims: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `round_` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `rsqrt` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `scan` | function | deferred | deferred | `(x: 'Value \| ConstLike', axis: 'Value \| ConstLike', reverse: 'Value \| ConstLike', combiner: 'str' = 'sum', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `scatter_along_axis` | function | deferred | deferred | `(output: 'TensorType', x: 'Value \| ConstLike', indices: 'Value \| ConstLike', updates: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, scatter_mode: 'str \| None' = None, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `scatter_nd` | function | deferred | deferred | `(x: 'Value \| ConstLike', indices: 'Value \| ConstLike', updates: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `shrink_dims` | function | deferred | deferred | `(x: 'Value \| ConstLike', axes: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `sigmoid` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `silu` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `sin` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `sinh` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `slice_` | function | deferred | deferred | `(x: 'Value \| ConstLike', start_indices: 'Value \| ConstLike', end_indices: 'Value \| ConstLike', strides: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `slice_update` | function | deferred | deferred | `(x: 'Value \| ConstLike', start_indices: 'Value \| ConstLike', end_indices: 'Value \| ConstLike', strides: 'Value \| ConstLike', update: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `softmax` | function | deferred | deferred | `(x: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `sort` | function | deferred | deferred | `(x: 'Value \| ConstLike', dim: 'Value \| ConstLike', descending: 'Value \| ConstLike', stable: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `sparse_with_bitmask_to_dense` | function | deferred | deferred | `(sparse_value: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `split` | function | deferred | deferred | `(x: 'Value \| ConstLike', split_size_or_sections: 'Value \| ConstLike', dim: 'Value \| ConstLike', *, result_types: 'Sequence[TensorType] \| None' = None, loc: 'DebugInfo \| None' = None) -> 'list[Value]'` |
| `sqrt` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `sub` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, y: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `sumpool2d` | function | deferred | deferred | `(x: 'Value \| ConstLike', kernel_size: 'Value \| ConstLike', strides: 'Value \| ConstLike', dilation: 'Value \| ConstLike \| None' = None, *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `sumpool3d` | function | deferred | deferred | `(x: 'Value \| ConstLike', kernel_size: 'Value \| ConstLike', strides: 'Value \| ConstLike', dilation: 'Value \| ConstLike \| None' = None, *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `symmetric_quant_stats` | function | deferred | deferred | `(x: 'Value \| ConstLike', value_range: 'Value \| ConstLike', axis: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `tan` | function | deferred | deferred | `(x: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `tanh` | function | deferred | deferred | `(x: coreai.authoring.operation.Value \| bool \| int \| float \| range \| list[bool \| int \| float] \| numpy.ndarray[tuple[typing.Any, ...], numpy.dtype[numpy.number[typing.Any]]] \| yuvio.core.yuv.YUVFrame \| PIL.Image.Image, *, loc: coreai.authoring.debuginfo.DebugInfo \| None = None) -> coreai.authoring.operation.Value` |
| `tensor_to_image` | function | deferred | deferred | `(result: 'ImageType', source: 'Value', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `tile` | function | deferred | deferred | `(x: 'Value \| ConstLike', dims: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `transpose` | function | deferred | deferred | `(x: 'Value \| ConstLike', permutation: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `uint16` | value | deferred | deferred | `native/unavailable` |
| `uint2` | value | deferred | deferred | `native/unavailable` |
| `uint32` | value | deferred | deferred | `native/unavailable` |
| `uint4` | value | deferred | deferred | `native/unavailable` |
| `uint64` | value | deferred | deferred | `native/unavailable` |
| `uint8` | value | deferred | deferred | `native/unavailable` |
| `where` | function | deferred | deferred | `(condition: 'Value \| ConstLike', x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
| `xor_` | function | deferred | deferred | `(x: 'Value \| ConstLike', y: 'Value \| ConstLike', *, loc: 'DebugInfo \| None' = None) -> 'Value'` |
