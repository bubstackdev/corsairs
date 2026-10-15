; ModuleID = '/private/tmp/corsairs-metal-v02/metal.ll'
source_filename = "/private/tmp/corsairs-metal-v02/metal.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%struct._SwiftEmptyArrayStorage = type { %struct.HeapObject, %struct._SwiftArrayBodyStorage }
%struct.HeapObject = type { ptr, %struct.InlineRefCountsPlaceholder }
%struct.InlineRefCountsPlaceholder = type { i64 }
%struct._SwiftArrayBodyStorage = type { i64, i64 }
%swift.type_descriptor = type opaque
%swift.async_func_pointer = type <{ i32, i32 }>
%swift.type = type { i64 }
%TSo15MTLCommandQueueP = type { ptr }
%swift.metadata_response = type { ptr, i64 }
%TSo9MTLBufferP = type { ptr }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%swift.opaque = type opaque
%TSS = type <{ %Ts11_StringGutsV }>
%Ts11_StringGutsV = type <{ %Ts13_StringObjectV }>
%Ts13_StringObjectV = type <{ %Ts6UInt64V, ptr }>
%Ts6UInt64V = type <{ i64 }>
%"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame" = type { ptr, ptr, ptr }
%"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame" = type { ptr, ptr, ptr }
%"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame" = type { ptr, ptr, ptr, ptr, ptr, ptr }
%T13CoreAIRuntime17InferenceFunctionV10AsyncValueCSg = type <{ [8 x i8] }>
%TSD = type <{ %TSD8_VariantV }>
%TSD8_VariantV = type <{ %Ts14_BridgeStorageV }>
%Ts14_BridgeStorageV = type <{ ptr }>
%Ts28__ContiguousArrayStorageBaseC = type <{ %swift.refcounted, %Ts10_ArrayBodyV }>
%swift.refcounted = type { ptr, i64 }
%Ts10_ArrayBodyV = type <{ %TSo22_SwiftArrayBodyStorageV }>
%TSo22_SwiftArrayBodyStorageV = type <{ %TSi, %TSu }>
%TSi = type <{ i64 }>
%TSu = type <{ i64 }>

@_swiftEmptyArrayStorage = external global %struct._SwiftEmptyArrayStorage, align 8
@"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMn"
@"symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV", i32 0, i32 1) to i64)) to i32), [2 x i8] c"Sg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV" to i64), i64 ptrtoint (ptr @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR" to i64)) to i32), i32 7 }, align 8
@"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu" = global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF" to i64), i64 ptrtoint (ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu" to i64)) to i32), i32 48 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaFTu" = external global %swift.async_func_pointer, align 8
@"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu" = global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF" to i64), i64 ptrtoint (ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu" to i64)) to i32), i32 48 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvgTu" = external global %swift.async_func_pointer, align 8
@"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu" = global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF" to i64), i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu" to i64)) to i32), i32 64 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu" = external global %swift.async_func_pointer, align 8
@"$sSSN" = external global %swift.type, align 8
@"$sSSSHsWP" = external global ptr, align 8
@"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMn"
@"symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC" = linkonce_odr hidden constant <{ [5 x i8], i8, i32, [1 x i8], i8 }> <{ [5 x i8] c"SDySS", i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ [5 x i8], i8, i32, [1 x i8], i8 }>, ptr @"symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC", i32 0, i32 2) to i64)) to i32), [1 x i8] c"G", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC" to i64), i64 ptrtoint (ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR" to i64)) to i32), i32 11 }, align 8
@"_swift_FORCE_LOAD_$_swiftMetal_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@".str.36.Can't construct Array with count < 0" = private unnamed_addr constant [37 x i8] c"Can't construct Array with count < 0\00"
@".str.39.Swift/arm64e-apple-macos.swiftinterface" = private unnamed_addr constant [40 x i8] c"Swift/arm64e-apple-macos.swiftinterface\00"
@".str.11.Fatal error" = private unnamed_addr constant [12 x i8] c"Fatal error\00"
@"$sSiN" = external global %swift.type, align 8
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@__swift_async_entry_functlets = internal constant [3 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF" to i64), i64 ptrtoint (ptr @__swift_async_entry_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_entry_functlets, i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_entry_functlets, i32 0, i32 2) to i64)) to i32)], section "__TEXT,__swift_as_entry, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_ret_functlets = internal constant [3 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_" to i64), i64 ptrtoint (ptr @__swift_async_ret_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_ret_functlets, i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_ret_functlets, i32 0, i32 2) to i64)) to i32)], section "__TEXT,__swift_as_ret, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_cont_functlets = internal constant [3 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_" to i64), i64 ptrtoint (ptr @__swift_async_cont_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 2) to i64)) to i32)], section "__TEXT,__swift_as_cont, coalesced, no_dead_strip", no_sanitize_address, align 4
@llvm.used = appending global [37 x ptr] [ptr @"$s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF", ptr @"$s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF", ptr @"$s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF", ptr @"$s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF", ptr @"$s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF", ptr @"$s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF", ptr @"$s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF", ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF", ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu", ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF", ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu", ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF", ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu", ptr @"$s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF", ptr @"$s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF", ptr @"$s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF", ptr @"$s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF", ptr @"$s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF", ptr @"$s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF", ptr @"$s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF", ptr @"$s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF", ptr @"$s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF", ptr @"$s8MetalABI8contentsySvSo9MTLBuffer_pF", ptr @"$s8MetalABI6lengthySiSo9MTLBuffer_pF", ptr @"$s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_MetalABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI", ptr @__swift_reflection_version, ptr @__swift_async_entry_functlets, ptr @__swift_async_ret_functlets, ptr @__swift_async_cont_functlets], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF"(ptr %0) #0 {
entry:
  %1 = alloca %TSo15MTLCommandQueueP, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr %1)
  %2 = getelementptr inbounds nuw %TSo15MTLCommandQueueP, ptr %1, i32 0, i32 0
  store ptr %0, ptr %2, align 8
  %3 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime13ComputeStreamCMa"(i64 0) #15
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = getelementptr inbounds nuw %TSo15MTLCommandQueueP, ptr %1, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8
  %7 = call swiftcc ptr @"$s13CoreAIRuntime13ComputeStreamC12commandQueueACSo010MTLCommandF0_p_tcfC"(ptr %6, ptr swiftself %4)
  call void @llvm.lifetime.end.p0(i64 8, ptr %1)
  ret ptr %7
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime13ComputeStreamCMa"(i64) #2

declare swiftcc ptr @"$s13CoreAIRuntime13ComputeStreamC12commandQueueACSo010MTLCommandF0_p_tcfC"(ptr, ptr swiftself) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF"(ptr %0, ptr noalias %1, ptr %2) #0 {
entry:
  %3 = alloca %TSo9MTLBufferP, align 8
  %scalar.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %scalar.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %shape.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %shape.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %4 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd", ptr @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR") #16
  %5 = getelementptr inbounds ptr, ptr %4, i64 -1
  %.valueWitnesses = load ptr, ptr %5, align 8, !invariant.load !52, !dereferenceable !53
  %6 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %6, align 8, !invariant.load !52
  %7 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %7)
  %8 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa"(i64 0) #15
  %9 = extractvalue %swift.metadata_response %8, 0
  %10 = getelementptr inbounds ptr, ptr %9, i64 -1
  %.valueWitnesses1 = load ptr, ptr %10, align 8, !invariant.load !52, !dereferenceable !53
  %11 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %11, align 8, !invariant.load !52
  %12 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  call void @llvm.lifetime.start.p0(i64 8, ptr %3)
  %13 = getelementptr inbounds nuw %TSo9MTLBufferP, ptr %3, i32 0, i32 0
  store ptr %0, ptr %13, align 8
  store ptr %12, ptr %scalar.debug, align 8
  br label %14

14:                                               ; preds = %entry
  %15 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 4
  %InitializeWithTake = load ptr, ptr %15, align 8, !invariant.load !52
  %16 = call ptr %InitializeWithTake(ptr noalias %12, ptr noalias %1, ptr %9) #6
  store ptr %2, ptr %shape.debug, align 8
  %17 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa"(i64 0) #15
  %18 = extractvalue %swift.metadata_response %17, 0
  %19 = call ptr @swift_bridgeObjectRetain(ptr returned %2) #6
  %20 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa"(i64 0) #15
  %21 = extractvalue %swift.metadata_response %20, 0
  %22 = getelementptr inbounds ptr, ptr %21, i64 -1
  %.valueWitnesses3 = load ptr, ptr %22, align 8, !invariant.load !52, !dereferenceable !53
  %23 = getelementptr inbounds ptr, ptr %.valueWitnesses3, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %23, align 8, !invariant.load !52
  call void %StoreEnumTagSinglePayload(ptr noalias %7, i32 1, i32 1, ptr %21) #6
  %24 = getelementptr inbounds nuw %TSo9MTLBufferP, ptr %3, i32 0, i32 0
  %25 = load ptr, ptr %24, align 8
  %26 = call swiftcc i64 @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_"()
  %27 = call swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_"()
  %28 = call swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfC"(ptr %25, i64 %26, ptr noalias %12, ptr %2, ptr %27, ptr noalias %7, ptr swiftself %18)
  call void @llvm.lifetime.end.p0(i64 8, ptr %3)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %12)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %7)
  ret ptr %28
}

; Function Attrs: noinline nounwind willreturn memory(read)
define linkonce_odr hidden ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr %0, ptr %1) #3 {
entry:
  %2 = load atomic ptr, ptr %0 monotonic, align 8
  %3 = icmp eq ptr %2, null
  %4 = ptrtoint ptr %2 to i64
  %5 = and i64 %4, 1
  %6 = icmp eq i64 %5, 1
  %7 = or i1 %6, %3
  br i1 %7, label %10, label %8

8:                                                ; preds = %10, %entry
  %9 = phi ptr [ %2, %entry ], [ %18, %10 ]
  ret ptr %9

10:                                               ; preds = %entry
  %11 = load i64, ptr %1, align 8
  %12 = ashr i64 %11, 32
  %13 = trunc i64 %11 to i32
  %14 = sext i32 %13 to i64
  %15 = ptrtoint ptr %1 to i64
  %16 = add i64 %15, %14
  %17 = inttoptr i64 %16 to ptr
  %18 = call swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr %17, i64 %12, ptr null, ptr null) #17
  store atomic ptr %18, ptr %0 monotonic, align 8
  br label %8
}

; Function Attrs: nounwind memory(argmem: readwrite)
declare swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr, i64, ptr, ptr) #4

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa"(i64) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #5

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa"(i64) #2

; Function Attrs: nounwind
declare ptr @swift_bridgeObjectRetain(ptr returned) #6

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa"(i64) #2

define linkonce_odr hidden swiftcc i64 @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_"() #2 {
entry:
  ret i64 0
}

define linkonce_odr hidden swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_"() #2 {
entry:
  %0 = call swiftcc { ptr, ptr } @"$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5"(i64 0)
  %1 = extractvalue { ptr, ptr } %0, 0
  %2 = extractvalue { ptr, ptr } %0, 1
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfC"(ptr, i64, ptr noalias, ptr, ptr, ptr noalias, ptr swiftself) #2

; Function Attrs: noinline
define swiftcc void @"$s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF"(ptr noalias sret(%swift.opaque) %0, ptr %1, ptr noalias %2, ptr %3) #0 {
entry:
  %4 = alloca %TSo9MTLBufferP, align 8
  %scalar.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %scalar.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %shape.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %shape.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %5 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd", ptr @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR") #16
  %6 = getelementptr inbounds ptr, ptr %5, i64 -1
  %.valueWitnesses = load ptr, ptr %6, align 8, !invariant.load !52, !dereferenceable !53
  %7 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %7, align 8, !invariant.load !52
  %8 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %8)
  %9 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa"(i64 0) #15
  %10 = extractvalue %swift.metadata_response %9, 0
  %11 = getelementptr inbounds ptr, ptr %10, i64 -1
  %.valueWitnesses1 = load ptr, ptr %11, align 8, !invariant.load !52, !dereferenceable !53
  %12 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %12, align 8, !invariant.load !52
  %13 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %13)
  call void @llvm.lifetime.start.p0(i64 8, ptr %4)
  %14 = getelementptr inbounds nuw %TSo9MTLBufferP, ptr %4, i32 0, i32 0
  store ptr %1, ptr %14, align 8
  store ptr %13, ptr %scalar.debug, align 8
  br label %15

15:                                               ; preds = %entry
  %16 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 4
  %InitializeWithTake = load ptr, ptr %16, align 8, !invariant.load !52
  %17 = call ptr %InitializeWithTake(ptr noalias %13, ptr noalias %2, ptr %10) #6
  store ptr %3, ptr %shape.debug, align 8
  %18 = call ptr @swift_bridgeObjectRetain(ptr returned %3) #6
  %19 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa"(i64 0) #15
  %20 = extractvalue %swift.metadata_response %19, 0
  %21 = getelementptr inbounds ptr, ptr %20, i64 -1
  %.valueWitnesses3 = load ptr, ptr %21, align 8, !invariant.load !52, !dereferenceable !53
  %22 = getelementptr inbounds ptr, ptr %.valueWitnesses3, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %22, align 8, !invariant.load !52
  call void %StoreEnumTagSinglePayload(ptr noalias %8, i32 1, i32 1, ptr %20) #6
  %23 = getelementptr inbounds nuw %TSo9MTLBufferP, ptr %4, i32 0, i32 0
  %24 = load ptr, ptr %23, align 8
  %25 = call swiftcc i64 @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_"()
  %26 = call swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_"()
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfC"(ptr noalias sret(%swift.opaque) %0, ptr %24, i64 %25, ptr noalias %13, ptr %3, ptr %26, ptr noalias %8)
  call void @llvm.lifetime.end.p0(i64 8, ptr %4)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %13)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %8)
  ret void
}

define linkonce_odr hidden swiftcc i64 @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_"() #2 {
entry:
  ret i64 0
}

define linkonce_odr hidden swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_"() #2 {
entry:
  %0 = call swiftcc { ptr, ptr } @"$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5"(i64 0)
  %1 = extractvalue { ptr, ptr } %0, 0
  %2 = extractvalue { ptr, ptr } %0, 1
  ret ptr %1
}

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfC"(ptr noalias sret(%swift.opaque), ptr, i64, ptr noalias, ptr, ptr, ptr noalias) #2

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF"(ptr noalias %0) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %1 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #15
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds ptr, ptr %2, i64 -1
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !52, !dereferenceable !53
  %4 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %4, align 8, !invariant.load !52
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %5)
  store ptr %5, ptr %array.debug, align 8
  br label %6

6:                                                ; preds = %entry
  %7 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %7, align 8, !invariant.load !52
  %8 = call ptr %InitializeWithTake(ptr noalias %5, ptr noalias %0, ptr %2) #6
  %9 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa"(i64 0) #15
  %10 = extractvalue %swift.metadata_response %9, 0
  %11 = call swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCyAeA7NDArrayVcfC"(ptr noalias %5, ptr swiftself %10)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %5)
  ret ptr %11
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64) #2

declare swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCyAeA7NDArrayVcfC"(ptr noalias, ptr swiftself) #2

; Function Attrs: noinline
define swiftcc void @"$s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #15
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %5, align 8, !invariant.load !52
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  store ptr %6, ptr %array.debug, align 8
  br label %7

7:                                                ; preds = %entry
  %8 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %8, align 8, !invariant.load !52
  %9 = call ptr %InitializeWithTake(ptr noalias %6, ptr noalias %1, ptr %3) #6
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVyAeA7NDArrayVcfC"(ptr noalias sret(%swift.opaque) %0, ptr noalias %6)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %6)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVyAeA7NDArrayVcfC"(ptr noalias sret(%swift.opaque), ptr noalias) #2

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF"(ptr noalias %0, ptr %1, ptr %2, i64 %3, ptr %4, ptr %5, ptr swiftself %6, ptr noalias swifterror captures(none) dereferenceable(8) %7) #0 {
entry:
  %function.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %inputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %output.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %output.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %stream.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %stream.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %views.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %views.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %8 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa"(i64 0) #15
  %9 = extractvalue %swift.metadata_response %8, 0
  %10 = getelementptr inbounds ptr, ptr %9, i64 -1
  %.valueWitnesses = load ptr, ptr %10, align 8, !invariant.load !52, !dereferenceable !53
  %11 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %11, align 8, !invariant.load !52
  %12 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  %13 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %13)
  store ptr %0, ptr %function.debug, align 8
  store ptr %1, ptr %inputs.debug, align 8
  store ptr %2, ptr %output.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %3, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %4, ptr %name.debug._guts._object._object, align 8
  store ptr %5, ptr %stream.debug, align 8
  store ptr %13, ptr %views.debug, align 8
  br label %14

14:                                               ; preds = %entry
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %13)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF"(ptr %2, i64 %3, ptr %4, ptr swiftself %13)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_"(ptr noalias sret(%swift.opaque) %12)
  %15 = call swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF"(ptr %1, ptr noalias %12, ptr noalias %13, ptr %5, ptr noalias swiftself %0, ptr noalias swifterror captures(none) dereferenceable(8) %7)
  %16 = load ptr, ptr %7, align 8
  %17 = icmp ne ptr %16, null
  %18 = ptrtoint ptr %16 to i64
  br i1 %17, label %21, label %19

19:                                               ; preds = %14
  %20 = phi ptr [ %15, %14 ]
  call void @llvm.lifetime.end.p0(i64 -1, ptr %13)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %12)
  ret ptr %20

21:                                               ; preds = %14
  %22 = phi ptr [ %16, %14 ]
  store ptr null, ptr %7, align 8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %13)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %12)
  store ptr %22, ptr %7, align 8
  ret ptr undef
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa"(i64) #2

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC"(ptr noalias sret(%swift.opaque)) #2

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF"(ptr, i64, ptr, ptr swiftself) #2

define linkonce_odr hidden swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_"(ptr noalias sret(%swift.opaque) %0) #2 {
entry:
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %0)
  ret void
}

declare swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF"(ptr, ptr noalias, ptr noalias, ptr, ptr noalias swiftself, ptr noalias swifterror captures(none) dereferenceable(8)) #2

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF"(ptr noalias %0, ptr %1, ptr %2, i64 %3, ptr %4, ptr %5, i64 %6, ptr %7, ptr %8, ptr swiftself %9, ptr noalias swifterror captures(none) dereferenceable(8) %10) #0 {
entry:
  %function.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %inputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %state.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %state.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %stateName.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %stateName.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %output.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %output.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %outputName.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %outputName.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %stream.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %stream.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %states.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %states.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %outputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %outputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %11 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa"(i64 0) #15
  %12 = extractvalue %swift.metadata_response %11, 0
  %13 = getelementptr inbounds ptr, ptr %12, i64 -1
  %.valueWitnesses = load ptr, ptr %13, align 8, !invariant.load !52, !dereferenceable !53
  %14 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %14, align 8, !invariant.load !52
  %15 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %15)
  %16 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %16)
  store ptr %0, ptr %function.debug, align 8
  store ptr %1, ptr %inputs.debug, align 8
  store ptr %2, ptr %state.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %stateName.debug)
  %stateName.debug._guts = getelementptr inbounds nuw %TSS, ptr %stateName.debug, i32 0, i32 0
  %stateName.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %stateName.debug._guts, i32 0, i32 0
  %stateName.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %stateName.debug._guts._object, i32 0, i32 0
  %stateName.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %stateName.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %3, ptr %stateName.debug._guts._object._countAndFlagsBits._value, align 8
  %stateName.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %stateName.debug._guts._object, i32 0, i32 1
  store ptr %4, ptr %stateName.debug._guts._object._object, align 8
  store ptr %5, ptr %output.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %outputName.debug)
  %outputName.debug._guts = getelementptr inbounds nuw %TSS, ptr %outputName.debug, i32 0, i32 0
  %outputName.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %outputName.debug._guts, i32 0, i32 0
  %outputName.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %outputName.debug._guts._object, i32 0, i32 0
  %outputName.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %outputName.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %6, ptr %outputName.debug._guts._object._countAndFlagsBits._value, align 8
  %outputName.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %outputName.debug._guts._object, i32 0, i32 1
  store ptr %7, ptr %outputName.debug._guts._object._object, align 8
  store ptr %8, ptr %stream.debug, align 8
  store ptr %16, ptr %states.debug, align 8
  br label %17

17:                                               ; preds = %entry
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %16)
  store ptr %15, ptr %outputs.debug, align 8
  br label %18

18:                                               ; preds = %17
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %15)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF"(ptr %2, i64 %3, ptr %4, ptr swiftself %16)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF"(ptr %5, i64 %6, ptr %7, ptr swiftself %15)
  %19 = call swiftcc ptr @"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF"(ptr %1, ptr noalias %16, ptr noalias %15, ptr %8, ptr noalias swiftself %0, ptr noalias swifterror captures(none) dereferenceable(8) %10)
  %20 = load ptr, ptr %10, align 8
  %21 = icmp ne ptr %20, null
  %22 = ptrtoint ptr %20 to i64
  br i1 %21, label %25, label %23

23:                                               ; preds = %18
  %24 = phi ptr [ %19, %18 ]
  call void @llvm.lifetime.end.p0(i64 -1, ptr %16)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %15)
  ret ptr %24

25:                                               ; preds = %18
  %26 = phi ptr [ %20, %18 ]
  store ptr null, ptr %10, align 8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %16)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %15)
  store ptr %26, ptr %10, align 8
  ret ptr undef
}

; Function Attrs: noinline
define swifttailcc void @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF"(ptr swiftasync %0, ptr %1) #7 {
entry:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %2 = getelementptr inbounds %"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %stream.debug = getelementptr inbounds %"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  store ptr %0, ptr %2, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %stream.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %1, ptr %stream.debug, align 8
  call void asm sideeffect "", "r"(ptr %stream.debug)
  %3 = load i32, ptr getelementptr inbounds nuw (%swift.async_func_pointer, ptr @"$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaFTu", i32 0, i32 1), align 4
  %4 = zext i32 %3 to i64
  %5 = call swiftcc ptr @swift_task_alloc(i64 %4) #9
  %.spill.addr = getelementptr inbounds %"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  store ptr %5, ptr %.spill.addr, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %5)
  %6 = load ptr, ptr %2, align 8
  %7 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %5, i32 0, i32 0
  store ptr %6, ptr %7, align 8
  %8 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %5, i32 0, i32 1
  store ptr @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_", ptr %8, align 8
  musttail call swifttailcc void @"$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaF"(ptr swiftasync %5, ptr swiftself %1) #6
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_"(ptr swiftasync %0) #8 {
entryresume.0:
  %1 = load ptr, ptr %0, align 8
  %2 = call ptr @llvm.swift.async.context.addr()
  store ptr %1, ptr %2, align 8
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %1, i32 16
  %3 = getelementptr inbounds %"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %stream.debug = getelementptr inbounds %"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr = getelementptr inbounds %"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload = load ptr, ptr %.reload.addr, align 8
  %4 = load ptr, ptr %0, align 8
  store ptr %4, ptr %3, align 8
  call swiftcc void @swift_task_dealloc(ptr %.reload) #9
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload)
  %5 = load ptr, ptr %3, align 8
  %6 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %5, i32 0, i32 1
  %7 = load ptr, ptr %6, align 8
  %8 = load ptr, ptr %3, align 8
  musttail call swifttailcc void %7(ptr swiftasync %8) #6
  ret void
}

declare swifttailcc void @"$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaF"(ptr swiftasync, ptr swiftself) #2

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc ptr @swift_task_alloc(i64) #9

; Function Attrs: nounwind
declare ptr @llvm.swift.async.context.addr() #6

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc void @swift_task_dealloc(ptr) #9

; Function Attrs: noinline
define swifttailcc void @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF"(ptr noalias %0, ptr swiftasync %1, ptr %2) #7 {
entry:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %1, i32 16
  %3 = getelementptr inbounds %"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  store ptr %1, ptr %3, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %2, ptr %value.debug, align 8
  call void asm sideeffect "", "r"(ptr %value.debug)
  %4 = load i32, ptr getelementptr inbounds nuw (%swift.async_func_pointer, ptr @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvgTu", i32 0, i32 1), align 4
  %5 = zext i32 %4 to i64
  %6 = call swiftcc ptr @swift_task_alloc(i64 %5) #9
  %.spill.addr = getelementptr inbounds %"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  store ptr %6, ptr %.spill.addr, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  %7 = load ptr, ptr %3, align 8
  %8 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %6, i32 0, i32 0
  store ptr %7, ptr %8, align 8
  %9 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %6, i32 0, i32 1
  store ptr @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_", ptr %9, align 8
  musttail call swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvg"(ptr noalias %0, ptr swiftasync %6, ptr swiftself %2) #6
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_"(ptr swiftasync %0, ptr swiftself %1) #8 {
entryresume.0:
  %2 = load ptr, ptr %0, align 8
  %3 = call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %2, i32 16
  %4 = getelementptr inbounds %"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr = getelementptr inbounds %"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload = load ptr, ptr %.reload.addr, align 8
  %5 = load ptr, ptr %0, align 8
  store ptr %5, ptr %4, align 8
  call swiftcc void @swift_task_dealloc(ptr %.reload) #9
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload)
  %6 = icmp ne ptr %1, null
  %7 = ptrtoint ptr %1 to i64
  br i1 %6, label %MustTailCall.Before.CoroEnd2, label %MustTailCall.Before.CoroEnd

MustTailCall.Before.CoroEnd:                      ; preds = %entryresume.0
  %8 = load ptr, ptr %4, align 8
  %9 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %8, i32 0, i32 1
  %10 = load ptr, ptr %9, align 8
  %11 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %10(ptr swiftasync %11, ptr swiftself null) #6
  ret void

MustTailCall.Before.CoroEnd2:                     ; preds = %entryresume.0
  %12 = phi ptr [ %1, %entryresume.0 ]
  %13 = load ptr, ptr %4, align 8
  %14 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %13, i32 0, i32 1
  %15 = load ptr, ptr %14, align 8
  %16 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %15(ptr swiftasync %16, ptr swiftself %1) #6
  ret void
}

declare swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvg"(ptr noalias, ptr swiftasync, ptr swiftself) #2

; Function Attrs: noinline
define swifttailcc void @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF"(ptr noalias %0, ptr swiftasync %1, ptr noalias %2) #7 {
entry:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %1, i32 16
  %3 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.spill.addr = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  store ptr %0, ptr %.spill.addr, align 8
  store ptr %1, ptr %3, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %4 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVMa"(i64 0) #15
  %5 = extractvalue %swift.metadata_response %4, 0
  %6 = getelementptr inbounds ptr, ptr %5, i64 -1
  %.valueWitnesses = load ptr, ptr %6, align 8, !invariant.load !52, !dereferenceable !53
  %7 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %7, align 8, !invariant.load !52
  %8 = add i64 %size, 15
  %9 = and i64 %8, -16
  %10 = call swiftcc ptr @swift_task_alloc(i64 %9) #9
  %.spill.addr10 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  store ptr %10, ptr %.spill.addr10, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %10)
  store ptr %10, ptr %value.debug, align 8
  call void asm sideeffect "", "r"(ptr %value.debug)
  %11 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %11, align 8, !invariant.load !52
  %12 = call ptr %InitializeWithTake(ptr noalias %10, ptr noalias %2, ptr %5) #6
  %13 = load ptr, ptr %3, align 8
  %14 = load ptr, ptr %3, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %14, ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_", i64 0, i64 0) #6
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_"(ptr swiftasync %0) #10 {
entryresume.0:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr17 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %.reload18 = load ptr, ptr %.reload.addr17, align 8
  store ptr %0, ptr %1, align 8
  store ptr %.reload18, ptr %value.debug, align 8
  call void asm sideeffect "", "r"(ptr %value.debug)
  call void asm sideeffect "nop", ""()
  %2 = load i32, ptr getelementptr inbounds nuw (%swift.async_func_pointer, ptr @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu", i32 0, i32 1), align 4
  %3 = zext i32 %2 to i64
  %4 = call swiftcc ptr @swift_task_alloc(i64 %3) #9
  %.spill.addr19 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  store ptr %4, ptr %.spill.addr19, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %4)
  %5 = load ptr, ptr %1, align 8
  %6 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %4, i32 0, i32 0
  store ptr %5, ptr %6, align 8
  %7 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %4, i32 0, i32 1
  store ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_", ptr %7, align 8
  %.reload.addr15 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %.reload16 = load ptr, ptr %.reload.addr15, align 8
  %.reload.addr = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload = load ptr, ptr %.reload.addr, align 8
  musttail call swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvg"(ptr noalias %.reload, ptr swiftasync %4, ptr noalias swiftself %.reload16) #6
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_"(ptr swiftasync %0, ptr swiftself %1) #8 {
entryresume.1:
  %2 = load ptr, ptr %0, align 8
  %3 = call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %2, i32 16
  %4 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr20 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload21 = load ptr, ptr %.reload.addr20, align 8
  %5 = load ptr, ptr %0, align 8
  store ptr %5, ptr %4, align 8
  %.spill.addr22 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  store ptr %1, ptr %.spill.addr22, align 8
  call swiftcc void @swift_task_dealloc(ptr %.reload21) #9
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload21)
  %6 = icmp ne ptr %1, null
  %7 = ptrtoint ptr %1 to i64
  br i1 %6, label %CoroSuspend5, label %CoroSuspend3

CoroSuspend3:                                     ; preds = %entryresume.1
  %8 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %8, ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_", i64 0, i64 0) #6
  ret void

CoroSuspend5:                                     ; preds = %entryresume.1
  %9 = phi ptr [ %1, %entryresume.1 ]
  %10 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %10, ptr @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_", i64 0, i64 0) #6
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_"(ptr swiftasync %0) #10 {
entryresume.2:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr11 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %.reload12 = load ptr, ptr %.reload.addr11, align 8
  store ptr %0, ptr %1, align 8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload12)
  call swiftcc void @swift_task_dealloc(ptr %.reload12) #9
  %2 = load ptr, ptr %1, align 8
  %3 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %2, i32 0, i32 1
  %4 = load ptr, ptr %3, align 8
  %5 = load ptr, ptr %1, align 8
  musttail call swifttailcc void %4(ptr swiftasync %5, ptr swiftself null) #6
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_"(ptr swiftasync %0) #10 {
entryresume.3:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %value.debug = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr13 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %.reload14 = load ptr, ptr %.reload.addr13, align 8
  store ptr %0, ptr %1, align 8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload14)
  call swiftcc void @swift_task_dealloc(ptr %.reload14) #9
  %2 = load ptr, ptr %1, align 8
  %3 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %2, i32 0, i32 1
  %4 = load ptr, ptr %3, align 8
  %5 = load ptr, ptr %1, align 8
  %.reload.addr23 = getelementptr inbounds %"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload24 = load ptr, ptr %.reload.addr23, align 8
  musttail call swifttailcc void %4(ptr swiftasync %5, ptr swiftself %.reload24) #6
  ret void
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVMa"(i64) #2

; Function Attrs: nounwind
declare swifttailcc void @swift_task_switch(ptr, ptr, i64, i64) #6

declare swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvg"(ptr noalias, ptr swiftasync, ptr noalias swiftself) #2

; Function Attrs: nounwind willreturn memory(read)
declare ptr @swift_getObjectType(ptr) #11

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF"() #0 {
entry:
  %0 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa"(i64 0) #15
  %1 = extractvalue %swift.metadata_response %0, 0
  %2 = call swiftcc ptr @"$sS2Dyxq_GycfC"(ptr @"$sSSN", ptr %1, ptr @"$sSSSHsWP")
  ret ptr %2
}

declare swiftcc ptr @"$sS2Dyxq_GycfC"(ptr, ptr, ptr) #2

; Function Attrs: noinline
define swiftcc void @"$s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF"(ptr captures(none) dereferenceable(8) %0, ptr %1, i64 %2, ptr %3) #0 {
entry:
  %inputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %value.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %4 = alloca %T13CoreAIRuntime17InferenceFunctionV10AsyncValueCSg, align 8
  %5 = alloca %TSS, align 8
  store ptr %0, ptr %inputs.debug, align 8
  store ptr %1, ptr %value.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %name.debug._guts._object._object, align 8
  %6 = call ptr @swift_bridgeObjectRetain(ptr returned %3) #6
  %7 = call ptr @swift_retain(ptr returned %1) #12
  %8 = ptrtoint ptr %1 to i64
  call void @llvm.lifetime.start.p0(i64 8, ptr %4)
  store i64 %8, ptr %4, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %5)
  %._guts = getelementptr inbounds nuw %TSS, ptr %5, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 0
  %._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %._guts._object._countAndFlagsBits._value, align 8
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  store ptr %3, ptr %._guts._object._object, align 8
  %9 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd", ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR") #16
  call swiftcc void @"$sSDyq_Sgxcis"(ptr noalias %4, ptr noalias %5, ptr %9, ptr swiftself captures(none) dereferenceable(8) %0)
  call void @llvm.lifetime.end.p0(i64 16, ptr %5)
  call void @llvm.lifetime.end.p0(i64 8, ptr %4)
  ret void
}

; Function Attrs: nounwind willreturn
declare ptr @swift_retain(ptr returned) #12

declare swiftcc void @"$sSDyq_Sgxcis"(ptr noalias, ptr noalias, ptr, ptr swiftself captures(none) dereferenceable(8)) #2

; Function Attrs: noinline
define swiftcc i64 @"$s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF"(ptr captures(none) dereferenceable(8) %0, i64 %1, ptr %2) #0 {
entry:
  %outputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %outputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %3 = alloca %T13CoreAIRuntime17InferenceFunctionV10AsyncValueCSg, align 8
  %4 = alloca %TSS, align 8
  store ptr %0, ptr %outputs.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %1, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %2, ptr %name.debug._guts._object._object, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr %3)
  call void @llvm.lifetime.start.p0(i64 16, ptr %4)
  %._guts = getelementptr inbounds nuw %TSS, ptr %4, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 0
  %._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %1, ptr %._guts._object._countAndFlagsBits._value, align 8
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  store ptr %2, ptr %._guts._object._object, align 8
  %5 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd", ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR") #16
  call swiftcc void @"$sSD11removeValue6forKeyq_Sgx_tF"(ptr noalias sret(%swift.opaque) %3, ptr noalias %4, ptr %5, ptr swiftself captures(none) dereferenceable(8) %0)
  call void @llvm.lifetime.end.p0(i64 16, ptr %4)
  %6 = load i64, ptr %3, align 8
  call void @llvm.lifetime.end.p0(i64 8, ptr %3)
  ret i64 %6
}

declare swiftcc void @"$sSD11removeValue6forKeyq_Sgx_tF"(ptr noalias sret(%swift.opaque), ptr noalias, ptr, ptr swiftself captures(none) dereferenceable(8)) #2

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF"(ptr %0, ptr %1, ptr %Key, ptr %Value, ptr %Key.Hashable) #0 {
entry:
  %Key1 = alloca ptr, align 8
  %Value2 = alloca ptr, align 8
  %key.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %key.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %value.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %Key, ptr %Key1, align 8
  store ptr %Value, ptr %Value2, align 8
  store ptr %0, ptr %key.debug, align 8
  store ptr %1, ptr %value.debug, align 8
  %2 = call swiftcc %swift.metadata_response @"$sSDMa"(i64 0, ptr %Key, ptr %Value, ptr %Key.Hashable) #15
  %3 = extractvalue %swift.metadata_response %2, 0
  ret ptr %3
}

declare swiftcc %swift.metadata_response @"$sSDMa"(i64, ptr, ptr, ptr) #2

; Function Attrs: noinline
define swiftcc void @"$s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF"(ptr %0) #0 {
entry:
  %1 = alloca %TSD, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %1, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.lifetime.start.p0(i64 8, ptr %1)
  %._variant = getelementptr inbounds nuw %TSD, ptr %1, i32 0, i32 0
  %._variant.object = getelementptr inbounds nuw %TSD8_VariantV, ptr %._variant, i32 0, i32 0
  %._variant.object.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._variant.object, i32 0, i32 0
  store ptr %0, ptr %._variant.object.rawValue, align 8
  %2 = call ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh"(ptr %1)
  call void @llvm.lifetime.end.p0(i64 8, ptr %1)
  ret void
}

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh"(ptr %0) #13 {
entry:
  %._variant = getelementptr inbounds nuw %TSD, ptr %0, i32 0, i32 0
  %._variant.object = getelementptr inbounds nuw %TSD8_VariantV, ptr %._variant, i32 0, i32 0
  %._variant.object.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._variant.object, i32 0, i32 0
  %toDestroy = load ptr, ptr %._variant.object.rawValue, align 8
  call void @swift_bridgeObjectRelease(ptr %toDestroy) #6
  ret ptr %0
}

; Function Attrs: nounwind
declare void @swift_bridgeObjectRelease(ptr) #6

; Function Attrs: noinline
define swiftcc i64 @"$s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF"() #0 {
entry:
  %0 = call ptr @MTLCreateSystemDefaultDevice()
  %1 = ptrtoint ptr %0 to i64
  ret i64 %1
}

declare ptr @MTLCreateSystemDefaultDevice() #2

; Function Attrs: noinline
define swiftcc i64 @"$s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF"(ptr %0) #0 {
entry:
  %device.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %device.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %device.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #11
  %1 = call ptr @"objc_msgSend$newCommandQueue"(ptr %0, ptr undef)
  %2 = ptrtoint ptr %1 to i64
  ret i64 %2
}

declare void @"objc_msgSend$newCommandQueue"()

; Function Attrs: noinline
define swiftcc i64 @"$s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF"(ptr %0, i64 %1) #0 {
entry:
  %device.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %device.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %count.debug = alloca i64, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %count.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %device.debug, align 8
  store i64 %1, ptr %count.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #11
  %2 = call ptr @"objc_msgSend$newBufferWithLength:options:"(ptr %0, ptr undef, i64 %1, i64 0)
  %3 = ptrtoint ptr %2 to i64
  ret i64 %3
}

declare void @"objc_msgSend$newBufferWithLength:options:"()

; Function Attrs: noinline
define swiftcc i64 @"$s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF"(ptr %0) #0 {
entry:
  %queue.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %queue.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %queue.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #11
  %1 = call ptr @"objc_msgSend$commandBuffer"(ptr %0, ptr undef)
  call void asm sideeffect "mov\09fp, fp\09\09// marker for objc_retainAutoreleaseReturnValue", ""()
  %2 = call ptr @llvm.objc.retainAutoreleasedReturnValue(ptr %1)
  %3 = ptrtoint ptr %2 to i64
  ret i64 %3
}

declare void @"objc_msgSend$commandBuffer"()

; Function Attrs: nounwind
declare ptr @llvm.objc.retainAutoreleasedReturnValue(ptr) #6

; Function Attrs: noinline
define swiftcc ptr @"$s8MetalABI8contentsySvSo9MTLBuffer_pF"(ptr %0) #0 {
entry:
  %buffer.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %buffer.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %buffer.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #11
  %1 = call ptr @swift_unknownObjectRetain(ptr returned %0) #6
  %2 = call ptr @"objc_msgSend$contents"(ptr %0, ptr undef)
  %3 = call ptr @llvm.objc.autorelease(ptr %0)
  ret ptr %2
}

; Function Attrs: nounwind
declare ptr @swift_unknownObjectRetain(ptr returned) #6

declare void @"objc_msgSend$contents"()

; Function Attrs: nounwind
declare ptr @llvm.objc.autorelease(ptr returned) #6

; Function Attrs: noinline
define swiftcc i64 @"$s8MetalABI6lengthySiSo9MTLBuffer_pF"(ptr %0) #0 {
entry:
  %buffer.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %buffer.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %buffer.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #11
  %1 = call ptr @swift_unknownObjectRetain(ptr returned %0) #6
  %2 = call i64 @"objc_msgSend$length"(ptr %0, ptr undef)
  call void @swift_unknownObjectRelease(ptr %0) #6
  ret i64 %2
}

declare void @"objc_msgSend$length"()

; Function Attrs: nounwind
declare void @swift_unknownObjectRelease(ptr) #6

; Function Attrs: noinline
define swiftcc void @"$s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF"(ptr %0) #0 {
entry:
  %command.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %command.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %command.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #11
  call void @"objc_msgSend$commit"(ptr %0, ptr undef)
  %.Type1 = call ptr @swift_getObjectType(ptr %0) #11
  call void @"objc_msgSend$waitUntilCompleted"(ptr %0, ptr undef)
  ret void
}

declare void @"objc_msgSend$commit"()

declare void @"objc_msgSend$waitUntilCompleted"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

define linkonce_odr hidden swiftcc { ptr, ptr } @"$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5"(i64 %0) #2 {
entry:
  %1 = icmp sge i64 %0, 0
  %2 = call i1 @llvm.expect.i1(i1 %1, i1 true)
  br i1 %2, label %4, label %3

3:                                                ; preds = %entry
  call swiftcc void @"$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF"(i64 ptrtoint (ptr @".str.11.Fatal error" to i64), i64 11, i8 2, i64 ptrtoint (ptr @".str.36.Can't construct Array with count < 0" to i64), i64 36, i8 2, i64 ptrtoint (ptr @".str.39.Swift/arm64e-apple-macos.swiftinterface" to i64), i64 39, i8 2, i64 903, i32 1)
  unreachable

4:                                                ; preds = %entry
  %5 = call ptr @swift_retain(ptr returned @_swiftEmptyArrayStorage) #12
  %6 = icmp slt i64 0, %0
  br i1 %6, label %8, label %7

7:                                                ; preds = %4
  br label %12

8:                                                ; preds = %4
  call void @swift_release(ptr @_swiftEmptyArrayStorage) #6
  %9 = call swiftcc ptr @"$sSa28_allocateBufferUninitialized15minimumCapacitys06_ArrayB0VyxGSi_tFZ"(i64 %0, ptr @"$sSiN")
  %10 = call ptr @swift_bridgeObjectRetain(ptr returned %9) #6
  %11 = getelementptr inbounds nuw %Ts28__ContiguousArrayStorageBaseC, ptr %9, i32 0, i32 1
  %._storage = getelementptr inbounds nuw %Ts10_ArrayBodyV, ptr %11, i32 0, i32 0
  %._storage.count = getelementptr inbounds nuw %TSo22_SwiftArrayBodyStorageV, ptr %._storage, i32 0, i32 0
  %._storage.count._value = getelementptr inbounds nuw %TSi, ptr %._storage.count, i32 0, i32 0
  store i64 %0, ptr %._storage.count._value, align 8
  call void @swift_release(ptr %9) #6
  br label %12

12:                                               ; preds = %8, %7
  %13 = phi ptr [ @_swiftEmptyArrayStorage, %7 ], [ %9, %8 ]
  %14 = getelementptr inbounds i8, ptr %13, i64 32
  %15 = insertvalue { ptr, ptr } undef, ptr %13, 0
  %16 = insertvalue { ptr, ptr } %15, ptr %14, 1
  ret { ptr, ptr } %16
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i1 @llvm.expect.i1(i1, i1) #14

; Function Attrs: noinline
declare swiftcc void @"$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF"(i64, i64, i8, i64, i64, i8, i64, i64, i8, i64, i32) #0

; Function Attrs: nounwind
declare void @swift_release(ptr) #6

; Function Attrs: noinline
declare swiftcc ptr @"$sSa28_allocateBufferUninitialized15minimumCapacitys06_ArrayB0VyxGSi_tFZ"(i64, ptr) #0

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { noinline nounwind willreturn memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { nounwind memory(argmem: readwrite) }
attributes #5 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #6 = { nounwind }
attributes #7 = { noinline "async_entry" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #8 = { noinline "async_ret" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { nounwind memory(inaccessiblemem: readwrite) }
attributes #10 = { noinline "async_continuation" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #11 = { nounwind willreturn memory(read) }
attributes #12 = { nounwind willreturn }
attributes #13 = { noinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #14 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #15 = { nounwind memory(none) }
attributes #16 = { nounwind memory(read) }
attributes #17 = { nounwind memory(argmem: read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"Objective-C Version", i32 2}
!2 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!3 = !{i32 1, !"Objective-C Image Info Section", !"__DATA,__objc_imageinfo,regular,no_dead_strip"}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Objective-C Class Properties", i32 64}
!6 = !{i32 1, !"Objective-C Enforce ClassRO Pointer Signing", i8 0}
!7 = !{i32 1, !"wchar_size", i32 4}
!8 = !{i32 8, !"PIC Level", i32 2}
!9 = !{i32 7, !"uwtable", i32 1}
!10 = !{i32 7, !"frame-pointer", i32 1}
!11 = !{i32 1, !"Swift Version", i32 7}
!12 = !{!"standard-library", i1 false}
!13 = !{!"-lswiftMetal"}
!14 = !{!"-lswiftCore"}
!15 = !{!"-lswift_StringProcessing"}
!16 = !{!"-lswift_Concurrency"}
!17 = !{!"-framework", !"Metal"}
!18 = !{!"-lswift_DarwinFoundation2"}
!19 = !{!"-lswift_DarwinFoundation1"}
!20 = !{!"-lswift_Builtin_float"}
!21 = !{!"-lswiftFoundation"}
!22 = !{!"-framework", !"Foundation"}
!23 = !{!"-lswift_DarwinFoundation3"}
!24 = !{!"-lswiftSystem"}
!25 = !{!"-lswiftDarwin"}
!26 = !{!"-lswiftObservation"}
!27 = !{!"-lswiftObjectiveC"}
!28 = !{!"-lswiftCoreFoundation"}
!29 = !{!"-framework", !"CoreFoundation"}
!30 = !{!"-lswiftDispatch"}
!31 = !{!"-framework", !"Combine"}
!32 = !{!"-framework", !"CoreServices"}
!33 = !{!"-framework", !"Security"}
!34 = !{!"-lswiftXPC"}
!35 = !{!"-framework", !"CFNetwork"}
!36 = !{!"-framework", !"DiskArbitration"}
!37 = !{!"-lswiftIOKit"}
!38 = !{!"-framework", !"IOKit"}
!39 = !{!"-framework", !"IOSurface"}
!40 = !{!"-framework", !"CoreAI"}
!41 = !{!"-framework", !"CoreAIDelegates"}
!42 = !{!"-framework", !"CoreAIRuntime"}
!43 = !{!"-framework", !"CoreVideo"}
!44 = !{!"-framework", !"CoreGraphics"}
!45 = !{!"-framework", !"OpenGL"}
!46 = !{!"-framework", !"CoreAICommon"}
!47 = !{!"-framework", !"CoreAICompiler"}
!48 = !{!"-framework", !"CoreAIAsset"}
!49 = !{!"-lswiftSwiftOnoneSupport"}
!50 = !{!"-lobjc"}
!51 = !{!"true"}
!52 = !{}
!53 = !{i64 88}
