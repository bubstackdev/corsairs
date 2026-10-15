; ModuleID = '/private/tmp/corsairs-inference-gate/inference.ll'
source_filename = "/private/tmp/corsairs-inference-gate/inference.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.async_func_pointer = type <{ i32, i32 }>
%swift.type_descriptor = type opaque
%swift.type = type { i64 }
%swift.opaque = type opaque
%TSS = type <{ %Ts11_StringGutsV }>
%Ts11_StringGutsV = type <{ %Ts13_StringObjectV }>
%Ts13_StringObjectV = type <{ %Ts6UInt64V, ptr }>
%Ts6UInt64V = type <{ i64 }>
%"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame" = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr }
%swift.metadata_response = type { ptr, i64 }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame" = type { %TSS, ptr, ptr, ptr, ptr, ptr, ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr }
%swift.tuple_type = type { %swift.type, i64, ptr, [0 x %swift.tuple_element_type] }
%swift.tuple_element_type = type { ptr, i32 }
%TSa = type <{ %Ts12_ArrayBufferV }>
%Ts12_ArrayBufferV = type <{ %Ts14_BridgeStorageV }>
%Ts14_BridgeStorageV = type <{ ptr }>
%TSi = type <{ i64 }>

@"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTu" = global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF" to i64), i64 ptrtoint (ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTu" to i64)) to i32), i32 96 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKFTu" = external global %swift.async_func_pointer, align 8
@"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTu" = global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF" to i64), i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTu" to i64)) to i32), i32 176 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu" = external global %swift.async_func_pointer, align 8
@"$s13CoreAIRuntime7NDArrayVMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime7NDArrayVMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime7NDArrayVMn"
@"symbolic SS______t 13CoreAIRuntime7NDArrayV" = linkonce_odr hidden constant <{ [3 x i8], i8, i32, [1 x i8], i8 }> <{ [3 x i8] c"SS_", i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime7NDArrayVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ [3 x i8], i8, i32, [1 x i8], i8 }>, ptr @"symbolic SS______t 13CoreAIRuntime7NDArrayV", i32 0, i32 2) to i64)) to i32), [1 x i8] c"t", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sSS_13CoreAIRuntime7NDArrayVtMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$sSS_13CoreAIRuntime7NDArrayVtMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic SS______t 13CoreAIRuntime7NDArrayV" to i64), i64 ptrtoint (ptr @"$sSS_13CoreAIRuntime7NDArrayVtMR" to i64)) to i32), i32 9 }, align 8
@"$sSSN" = external global %swift.type, align 8
@"$sSSSHsWP" = external global ptr, align 8
@"symbolic _____Sg 13CoreAIRuntime7NDArrayV" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime7NDArrayVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg 13CoreAIRuntime7NDArrayV", i32 0, i32 1) to i64)) to i32), [2 x i8] c"Sg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s13CoreAIRuntime7NDArrayVSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$s13CoreAIRuntime7NDArrayVSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg 13CoreAIRuntime7NDArrayV" to i64), i64 ptrtoint (ptr @"$s13CoreAIRuntime7NDArrayVSgMR" to i64)) to i32), i32 7 }, align 8
@"symbolic SDySS_____G 13CoreAIRuntime7NDArrayV" = linkonce_odr hidden constant <{ [5 x i8], i8, i32, [1 x i8], i8 }> <{ [5 x i8] c"SDySS", i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime7NDArrayVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ [5 x i8], i8, i32, [1 x i8], i8 }>, ptr @"symbolic SDySS_____G 13CoreAIRuntime7NDArrayV", i32 0, i32 2) to i64)) to i32), [1 x i8] c"G", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sSDySS13CoreAIRuntime7NDArrayVGMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$sSDySS13CoreAIRuntime7NDArrayVGMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic SDySS_____G 13CoreAIRuntime7NDArrayV" to i64), i64 ptrtoint (ptr @"$sSDySS13CoreAIRuntime7NDArrayVGMR" to i64)) to i32), i32 11 }, align 8
@"$sSiN" = external global %swift.type, align 8
@"symbolic SaySiG" = linkonce_odr hidden constant <{ [6 x i8], i8 }> <{ [6 x i8] c"SaySiG", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sSaySiGMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$sSaySiGMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic SaySiG" to i64), i64 ptrtoint (ptr @"$sSaySiGMR" to i64)) to i32), i32 6 }, align 8
@"$s13CoreAIRuntime17InferenceFunctionVMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime17InferenceFunctionVMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime17InferenceFunctionVMn"
@"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime17InferenceFunctionVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV", i32 0, i32 1) to i64)) to i32), [2 x i8] c"Sg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s13CoreAIRuntime17InferenceFunctionVSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$s13CoreAIRuntime17InferenceFunctionVSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV" to i64), i64 ptrtoint (ptr @"$s13CoreAIRuntime17InferenceFunctionVSgMR" to i64)) to i32), i32 7 }, align 8
@".str.41.InferenceGateABI/InferenceReference.swift" = private unnamed_addr constant [42 x i8] c"InferenceGateABI/InferenceReference.swift\00"
@".str.11.Fatal error" = private unnamed_addr constant [12 x i8] c"Fatal error\00"
@".str.16.missing function" = private unnamed_addr constant [17 x i8] c"missing function\00"
@"$s13CoreAIRuntime14InferenceValueVMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime14InferenceValueVMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime14InferenceValueVMn"
@"symbolic _____Sg 13CoreAIRuntime14InferenceValueV" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime14InferenceValueVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg 13CoreAIRuntime14InferenceValueV", i32 0, i32 1) to i64)) to i32), [2 x i8] c"Sg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s13CoreAIRuntime14InferenceValueVSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$s13CoreAIRuntime14InferenceValueVSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg 13CoreAIRuntime14InferenceValueV" to i64), i64 ptrtoint (ptr @"$s13CoreAIRuntime14InferenceValueVSgMR" to i64)) to i32), i32 7 }, align 8
@".str.14.missing output" = private unnamed_addr constant [15 x i8] c"missing output\00"
@".str.11.not NDArray" = private unnamed_addr constant [12 x i8] c"not NDArray\00"
@"_swift_FORCE_LOAD_$_swiftFoundation_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_InferenceGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@__swift_async_entry_functlets = internal constant [2 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF" to i64), i64 ptrtoint (ptr @__swift_async_entry_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF" to i64), i64 ptrtoint (ptr getelementptr inbounds ([2 x i32], ptr @__swift_async_entry_functlets, i32 0, i32 1) to i64)) to i32)], section "__TEXT,__swift_as_entry, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_ret_functlets = internal constant [2 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTQ1_" to i64), i64 ptrtoint (ptr @__swift_async_ret_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTQ1_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([2 x i32], ptr @__swift_async_ret_functlets, i32 0, i32 1) to i64)) to i32)], section "__TEXT,__swift_as_ret, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_cont_functlets = internal constant [5 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTY0_" to i64), i64 ptrtoint (ptr @__swift_async_cont_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTY2_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([5 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY0_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([5 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY2_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([5 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY3_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([5 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 4) to i64)) to i32)], section "__TEXT,__swift_as_cont, coalesced, no_dead_strip", no_sanitize_address, align 4
@llvm.used = appending global [35 x ptr] [ptr @"$s16InferenceGateABI12loadFunctiony13CoreAIRuntime0aE0VSgAC7AIModelV_SStKF", ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF", ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTu", ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF", ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTu", ptr @"$s16InferenceGateABI13oneDictionaryySDySS13CoreAIRuntime7NDArrayVGSS_AEtF", ptr @"$s16InferenceGateABI15emptyDictionarySDySS13CoreAIRuntime7NDArrayVGyF", ptr @"$s16InferenceGateABI16dictionaryUpdateyySDySS13CoreAIRuntime7NDArrayVGz_SSAEtF", ptr @"$s16InferenceGateABI12removeOutputy13CoreAIRuntime0A5ValueVSgAC0A8FunctionV7OutputsVz_SStF", ptr @"$s16InferenceGateABI11outputArrayy13CoreAIRuntime7NDArrayVSgAC0A5ValueVnF", ptr @"$s16InferenceGateABI11outputCountySi13CoreAIRuntime0A8FunctionV7OutputsVF", ptr @"$s16InferenceGateABI7shape23SaySiGyF", ptr @"$s16InferenceGateABI7shapeOfySaySiG13CoreAIRuntime7NDArrayVF", ptr @"$s16InferenceGateABI9stridesOfySaySiG13CoreAIRuntime7NDArrayVF", ptr @"$s16InferenceGateABI8scalarOfy13CoreAIRuntime7NDArrayV10ScalarTypeOAEF", ptr @"$s16InferenceGateABI14unwrapFunctiony13CoreAIRuntime0aE0VAESgnF", ptr @"$s16InferenceGateABI11unwrapValuey13CoreAIRuntime0aE0VAESgnF", ptr @"$s16InferenceGateABI11unwrapArrayy13CoreAIRuntime7NDArrayVAESgnF", ptr @"$s16InferenceGateABI23emptyDictionaryCapacitySDySS13CoreAIRuntime7NDArrayVGyF", ptr @"$s16InferenceGateABI17dictionaryReplacey13CoreAIRuntime7NDArrayVSgSDySSAEGz_SSnAEntF", ptr @"$s16InferenceGateABI16dictionaryLookupy13CoreAIRuntime7NDArrayVSgSDySSAEG_SStF", ptr @"$s16InferenceGateABI17consumeDictionaryyySDySS13CoreAIRuntime7NDArrayVGnF", ptr @"$s16InferenceGateABI14dictionaryTypeyypXpxm_q_mtSHRzr0_lF", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_InferenceGateABI", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_InferenceGateABI", ptr @__swift_reflection_version, ptr @__swift_async_entry_functlets, ptr @__swift_async_ret_functlets, ptr @__swift_async_cont_functlets], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI12loadFunctiony13CoreAIRuntime0aE0VSgAC7AIModelV_SStKF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1, i64 %2, ptr %3, ptr swiftself %4, ptr noalias swifterror captures(none) dereferenceable(8) %5) #0 {
entry:
  %model.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %model.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %1, ptr %model.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %name.debug._guts._object._object, align 8
  call swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque) %0, i64 %2, ptr %3, ptr noalias swiftself %1, ptr noalias swifterror captures(none) dereferenceable(8) %5)
  %6 = load ptr, ptr %5, align 8
  %7 = icmp ne ptr %6, null
  %8 = ptrtoint ptr %6 to i64
  br i1 %7, label %10, label %9

9:                                                ; preds = %entry
  ret void

10:                                               ; preds = %entry
  %11 = phi ptr [ %6, %entry ]
  store ptr null, ptr %5, align 8
  store ptr %11, ptr %5, align 8
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #2

declare swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr noalias swiftself, ptr noalias swifterror captures(none) dereferenceable(8)) #3

; Function Attrs: noinline
define swifttailcc void @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF"(ptr noalias %0, ptr swiftasync %1, ptr noalias %2, ptr %3) #4 {
entry:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %1, i32 16
  %4 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %inputs.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.spill.addr19 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  store ptr %3, ptr %.spill.addr19, align 8
  %.spill.addr8 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  store ptr %2, ptr %.spill.addr8, align 8
  %.spill.addr = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  store ptr %0, ptr %.spill.addr, align 8
  store ptr %1, ptr %4, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %inputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %5 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa"(i64 0) #13
  %6 = extractvalue %swift.metadata_response %5, 0
  %7 = getelementptr inbounds ptr, ptr %6, i64 -1
  %.valueWitnesses = load ptr, ptr %7, align 8, !invariant.load !52, !dereferenceable !53
  %8 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %8, align 8, !invariant.load !52
  %9 = add i64 %size, 15
  %10 = and i64 %9, -16
  %11 = call swiftcc ptr @swift_task_alloc(i64 %10) #7
  %.spill.addr30 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  store ptr %11, ptr %.spill.addr30, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  %12 = add i64 %size, 15
  %13 = and i64 %12, -16
  %14 = call swiftcc ptr @swift_task_alloc(i64 %13) #7
  %.spill.addr39 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  store ptr %14, ptr %.spill.addr39, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %14)
  store ptr %2, ptr %function.debug, align 8
  call void asm sideeffect "", "r"(ptr %function.debug)
  store ptr %3, ptr %inputs.debug, align 8
  call void asm sideeffect "", "r"(ptr %inputs.debug)
  %15 = load ptr, ptr %4, align 8
  %16 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %16, ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTY0_", i64 0, i64 0) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTY0_"(ptr swiftasync %0) #5 {
entryresume.0:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %inputs.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload.addr46 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload47 = load ptr, ptr %.reload.addr46, align 8
  %.reload.addr37 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload38 = load ptr, ptr %.reload.addr37, align 8
  %.reload.addr28 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload29 = load ptr, ptr %.reload.addr28, align 8
  %.reload.addr17 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload18 = load ptr, ptr %.reload.addr17, align 8
  store ptr %0, ptr %1, align 8
  store ptr %.reload29, ptr %inputs.debug, align 8
  call void asm sideeffect "", "r"(ptr %inputs.debug)
  store ptr %.reload18, ptr %function.debug, align 8
  call void asm sideeffect "", "r"(ptr %function.debug)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKFfA0_"(ptr noalias sret(%swift.opaque) %.reload47)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKFfA1_"(ptr noalias sret(%swift.opaque) %.reload38)
  %2 = load i32, ptr getelementptr inbounds nuw (%swift.async_func_pointer, ptr @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKFTu", i32 0, i32 1), align 4
  %3 = zext i32 %2 to i64
  %4 = call swiftcc ptr @swift_task_alloc(i64 %3) #7
  %.spill.addr48 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 8
  store ptr %4, ptr %.spill.addr48, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %4)
  %5 = load ptr, ptr %1, align 8
  %6 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %4, i32 0, i32 0
  store ptr %5, ptr %6, align 8
  %7 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %4, i32 0, i32 1
  store ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTQ1_", ptr %7, align 8
  %.reload.addr44 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload45 = load ptr, ptr %.reload.addr44, align 8
  %.reload.addr35 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload36 = load ptr, ptr %.reload.addr35, align 8
  %.reload.addr26 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload27 = load ptr, ptr %.reload.addr26, align 8
  %.reload.addr15 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload16 = load ptr, ptr %.reload.addr15, align 8
  %.reload.addr = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %.reload = load ptr, ptr %.reload.addr, align 8
  musttail call swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKF"(ptr noalias %.reload, ptr swiftasync %4, ptr %.reload27, ptr noalias %.reload45, ptr noalias %.reload36, ptr noalias swiftself %.reload16) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTQ1_"(ptr swiftasync %0, ptr swiftself %1) #6 {
entryresume.1:
  %2 = load ptr, ptr %0, align 8
  %3 = call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %2, i32 16
  %4 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %inputs.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload.addr49 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 8
  %.reload50 = load ptr, ptr %.reload.addr49, align 8
  %5 = load ptr, ptr %0, align 8
  store ptr %5, ptr %4, align 8
  %.spill.addr51 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  store ptr %1, ptr %.spill.addr51, align 8
  call swiftcc void @swift_task_dealloc(ptr %.reload50) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload50)
  %6 = icmp ne ptr %1, null
  %7 = ptrtoint ptr %1 to i64
  br i1 %6, label %CoroSuspend3, label %MustTailCall.Before.CoroEnd

MustTailCall.Before.CoroEnd:                      ; preds = %entryresume.1
  %.reload.addr40 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload41 = load ptr, ptr %.reload.addr40, align 8
  %.reload.addr31 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload32 = load ptr, ptr %.reload.addr31, align 8
  %.reload.addr20 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload21 = load ptr, ptr %.reload.addr20, align 8
  %.reload.addr9 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload10 = load ptr, ptr %.reload.addr9, align 8
  store ptr %.reload21, ptr %inputs.debug, align 8
  call void asm sideeffect "", "r"(ptr %inputs.debug)
  store ptr %.reload10, ptr %function.debug, align 8
  call void asm sideeffect "", "r"(ptr %function.debug)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload41)
  call swiftcc void @swift_task_dealloc(ptr %.reload41) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload32)
  call swiftcc void @swift_task_dealloc(ptr %.reload32) #7
  %8 = load ptr, ptr %4, align 8
  %9 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %8, i32 0, i32 1
  %10 = load ptr, ptr %9, align 8
  %11 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %10(ptr swiftasync %11, ptr swiftself null) #8
  ret void

CoroSuspend3:                                     ; preds = %entryresume.1
  %12 = phi ptr [ %1, %entryresume.1 ]
  %.reload.addr24 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload25 = load ptr, ptr %.reload.addr24, align 8
  %.reload.addr13 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload14 = load ptr, ptr %.reload.addr13, align 8
  store ptr %.reload25, ptr %inputs.debug, align 8
  call void asm sideeffect "", "r"(ptr %inputs.debug)
  store ptr %.reload14, ptr %function.debug, align 8
  call void asm sideeffect "", "r"(ptr %function.debug)
  %13 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %13, ptr @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTY2_", i64 0, i64 0) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKFTY2_"(ptr swiftasync %0) #5 {
entryresume.2:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %inputs.debug = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload.addr42 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload43 = load ptr, ptr %.reload.addr42, align 8
  %.reload.addr33 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload34 = load ptr, ptr %.reload.addr33, align 8
  %.reload.addr22 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload23 = load ptr, ptr %.reload.addr22, align 8
  %.reload.addr11 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload12 = load ptr, ptr %.reload.addr11, align 8
  store ptr %0, ptr %1, align 8
  store ptr %.reload23, ptr %inputs.debug, align 8
  call void asm sideeffect "", "r"(ptr %inputs.debug)
  store ptr %.reload12, ptr %function.debug, align 8
  call void asm sideeffect "", "r"(ptr %function.debug)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload43)
  call swiftcc void @swift_task_dealloc(ptr %.reload43) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload34)
  call swiftcc void @swift_task_dealloc(ptr %.reload34) #7
  %2 = load ptr, ptr %1, align 8
  %3 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %2, i32 0, i32 1
  %4 = load ptr, ptr %3, align 8
  %5 = load ptr, ptr %1, align 8
  %.reload.addr52 = getelementptr inbounds %"$s16InferenceGateABI13runDictionaryy13CoreAIRuntime0A8FunctionV7OutputsVAE_SDySSAC7NDArrayVGtYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  %.reload53 = load ptr, ptr %.reload.addr52, align 8
  musttail call swifttailcc void %4(ptr swiftasync %5, ptr swiftself %.reload53) #8
  ret void
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa"(i64) #3

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc ptr @swift_task_alloc(i64) #7

; Function Attrs: nounwind
declare swifttailcc void @swift_task_switch(ptr, ptr, i64, i64) #8

; Function Attrs: nounwind
declare ptr @llvm.swift.async.context.addr() #8

define linkonce_odr hidden swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKFfA0_"(ptr noalias sret(%swift.opaque) %0) #3 {
entry:
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %0)
  ret void
}

define linkonce_odr hidden swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKFfA1_"(ptr noalias sret(%swift.opaque) %0) #3 {
entry:
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %0)
  ret void
}

declare swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVSDySSAA7NDArrayVG_AC07MutableI0VnANntYaKF"(ptr noalias, ptr swiftasync, ptr, ptr noalias, ptr noalias, ptr noalias swiftself) #3

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc void @swift_task_dealloc(ptr) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: noinline
define swifttailcc void @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF"(ptr noalias %0, ptr swiftasync %1, ptr noalias %2, ptr noalias %3, i64 %4, ptr %5) #4 {
entry:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %1, i32 16
  %6 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %array.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %name.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %.spill.addr32 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 8
  store ptr %5, ptr %.spill.addr32, align 8
  %.spill.addr29 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  store i64 %4, ptr %.spill.addr29, align 8
  %.spill.addr18 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  store ptr %3, ptr %.spill.addr18, align 8
  %.spill.addr15 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  store ptr %2, ptr %.spill.addr15, align 8
  %.spill.addr = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  store ptr %0, ptr %.spill.addr, align 8
  %7 = load %TSS, ptr %name.debug, align 1
  %8 = load %TSS, ptr %name.debug, align 1
  %9 = load %TSS, ptr %name.debug, align 1
  %10 = load %TSS, ptr %name.debug, align 1
  %11 = load %TSS, ptr %name.debug, align 1
  store ptr %1, ptr %6, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %12 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa"(i64 0) #13
  %13 = extractvalue %swift.metadata_response %12, 0
  %14 = getelementptr inbounds ptr, ptr %13, i64 -1
  %.valueWitnesses = load ptr, ptr %14, align 8, !invariant.load !52, !dereferenceable !53
  %15 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %15, align 8, !invariant.load !52
  %16 = add i64 %size, 15
  %17 = and i64 %16, -16
  %18 = call swiftcc ptr @swift_task_alloc(i64 %17) #7
  %.spill.addr35 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  store ptr %18, ptr %.spill.addr35, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %18)
  %19 = add i64 %size, 15
  %20 = and i64 %19, -16
  %21 = call swiftcc ptr @swift_task_alloc(i64 %20) #7
  %.spill.addr44 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 10
  store ptr %21, ptr %.spill.addr44, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %21)
  %22 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV7RawViewVMa"(i64 0) #13
  %23 = extractvalue %swift.metadata_response %22, 0
  %24 = getelementptr inbounds ptr, ptr %23, i64 -1
  %.valueWitnesses1 = load ptr, ptr %24, align 8, !invariant.load !52, !dereferenceable !53
  %25 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %25, align 8, !invariant.load !52
  %26 = add i64 %size2, 15
  %27 = and i64 %26, -16
  %28 = call swiftcc ptr @swift_task_alloc(i64 %27) #7
  %.spill.addr53 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 11
  store ptr %28, ptr %.spill.addr53, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %28)
  %29 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV6InputsVMa"(i64 0) #13
  %30 = extractvalue %swift.metadata_response %29, 0
  %.spill.addr60 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 12
  store ptr %30, ptr %.spill.addr60, align 8
  %31 = getelementptr inbounds ptr, ptr %30, i64 -1
  %.valueWitnesses3 = load ptr, ptr %31, align 8, !invariant.load !52, !dereferenceable !53
  %.valueWitnesses3.spill.addr = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 13
  store ptr %.valueWitnesses3, ptr %.valueWitnesses3.spill.addr, align 8
  %32 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses3, i32 0, i32 8
  %size4 = load i64, ptr %32, align 8, !invariant.load !52
  %33 = add i64 %size4, 15
  %34 = and i64 %33, -16
  %35 = call swiftcc ptr @swift_task_alloc(i64 %34) #7
  %.spill.addr73 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 14
  store ptr %35, ptr %.spill.addr73, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %35)
  %36 = add i64 %size4, 15
  %37 = and i64 %36, -16
  %38 = call swiftcc ptr @swift_task_alloc(i64 %37) #7
  %.spill.addr84 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 15
  store ptr %38, ptr %.spill.addr84, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %38)
  store ptr %2, ptr %function.debug, align 8
  call void asm sideeffect "", "r"(ptr %function.debug)
  store ptr %3, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %4, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %5, ptr %name.debug._guts._object._object, align 8
  call void asm sideeffect "", "r"(ptr %name.debug)
  %39 = load ptr, ptr %6, align 8
  %40 = load ptr, ptr %6, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %40, ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY0_", i64 0, i64 0) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY0_"(ptr swiftasync %0) #5 {
entryresume.0:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %array.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %name.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %.reload.addr89 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 15
  %.reload90 = load ptr, ptr %.reload.addr89, align 8
  %.reload.addr82 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 14
  %.reload83 = load ptr, ptr %.reload.addr82, align 8
  %.valueWitnesses3.reload.addr71 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 13
  %.valueWitnesses3.reload72 = load ptr, ptr %.valueWitnesses3.reload.addr71, align 8
  %.reload.addr67 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 12
  %.reload68 = load ptr, ptr %.reload.addr67, align 8
  %.reload.addr58 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 11
  %.reload59 = load ptr, ptr %.reload.addr58, align 8
  %.reload.addr51 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 10
  %.reload52 = load ptr, ptr %.reload.addr51, align 8
  %.reload.addr42 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  %.reload43 = load ptr, ptr %.reload.addr42, align 8
  %.reload.addr33 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 8
  %.reload34 = load ptr, ptr %.reload.addr33, align 8
  %.reload.addr30 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload31 = load i64, ptr %.reload.addr30, align 8
  %.reload.addr27 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload28 = load ptr, ptr %.reload.addr27, align 8
  store ptr %0, ptr %1, align 8
  store ptr %.reload28, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV6InputsVAEycfC"(ptr noalias sret(%swift.opaque) %.reload90)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF"(ptr noalias sret(%swift.opaque) %.reload59, ptr noalias swiftself %.reload28)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryAA7NDArrayV7RawViewVn_SStF"(ptr noalias %.reload59, i64 %.reload31, ptr %.reload34, ptr swiftself %.reload90)
  %2 = getelementptr inbounds ptr, ptr %.valueWitnesses3.reload72, i32 2
  %InitializeWithCopy = load ptr, ptr %2, align 8, !invariant.load !52
  %3 = call ptr %InitializeWithCopy(ptr noalias %.reload83, ptr noalias %.reload90, ptr %.reload68) #8
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFfA0_"(ptr noalias sret(%swift.opaque) %.reload52)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFfA1_"(ptr noalias sret(%swift.opaque) %.reload43)
  %4 = load i32, ptr getelementptr inbounds nuw (%swift.async_func_pointer, ptr @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu", i32 0, i32 1), align 4
  %5 = zext i32 %4 to i64
  %6 = call swiftcc ptr @swift_task_alloc(i64 %5) #7
  %.spill.addr91 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 16
  store ptr %6, ptr %.spill.addr91, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  %7 = load ptr, ptr %1, align 8
  %8 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %6, i32 0, i32 0
  store ptr %7, ptr %8, align 8
  %9 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %6, i32 0, i32 1
  store ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTQ1_", ptr %9, align 8
  %.reload.addr80 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 14
  %.reload81 = load ptr, ptr %.reload.addr80, align 8
  %.reload.addr49 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 10
  %.reload50 = load ptr, ptr %.reload.addr49, align 8
  %.reload.addr40 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  %.reload41 = load ptr, ptr %.reload.addr40, align 8
  %.reload.addr16 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload17 = load ptr, ptr %.reload.addr16, align 8
  %.reload.addr = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload = load ptr, ptr %.reload.addr, align 8
  musttail call swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKF"(ptr noalias %.reload, ptr swiftasync %6, ptr noalias %.reload81, ptr noalias %.reload50, ptr noalias %.reload41, ptr noalias swiftself %.reload17) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTQ1_"(ptr swiftasync %0, ptr swiftself %1) #6 {
entryresume.1:
  %2 = load ptr, ptr %0, align 8
  %3 = call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %2, i32 16
  %4 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %array.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %name.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %.reload.addr92 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 16
  %.reload93 = load ptr, ptr %.reload.addr92, align 8
  %5 = load ptr, ptr %0, align 8
  store ptr %5, ptr %4, align 8
  %.spill.addr94 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 17
  store ptr %1, ptr %.spill.addr94, align 8
  call swiftcc void @swift_task_dealloc(ptr %.reload93) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload93)
  %6 = icmp ne ptr %1, null
  %7 = ptrtoint ptr %1 to i64
  br i1 %6, label %CoroSuspend10, label %CoroSuspend8

CoroSuspend8:                                     ; preds = %entryresume.1
  %.reload.addr76 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 14
  %.reload77 = load ptr, ptr %.reload.addr76, align 8
  %.valueWitnesses3.reload.addr = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 13
  %.valueWitnesses3.reload = load ptr, ptr %.valueWitnesses3.reload.addr, align 8
  %.reload.addr63 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 12
  %.reload64 = load ptr, ptr %.reload.addr63, align 8
  %.reload.addr21 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload22 = load ptr, ptr %.reload.addr21, align 8
  store ptr %.reload22, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  %8 = getelementptr inbounds ptr, ptr %.valueWitnesses3.reload, i32 1
  %Destroy5 = load ptr, ptr %8, align 8, !invariant.load !52
  %Destroy5.spill.addr = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 18
  store ptr %Destroy5, ptr %Destroy5.spill.addr, align 8
  call void %Destroy5(ptr noalias %.reload77, ptr %.reload64) #8
  %9 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %9, ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY2_", i64 0, i64 0) #8
  ret void

CoroSuspend10:                                    ; preds = %entryresume.1
  %10 = phi ptr [ %1, %entryresume.1 ]
  %.reload.addr25 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload26 = load ptr, ptr %.reload.addr25, align 8
  store ptr %.reload26, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  %11 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %11, ptr @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY3_", i64 0, i64 0) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY2_"(ptr swiftasync %0) #5 {
entryresume.2:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %array.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %name.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %Destroy5.reload.addr = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 18
  %Destroy5.reload = load ptr, ptr %Destroy5.reload.addr, align 8
  %.reload.addr85 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 15
  %.reload86 = load ptr, ptr %.reload.addr85, align 8
  %.reload.addr74 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 14
  %.reload75 = load ptr, ptr %.reload.addr74, align 8
  %.reload.addr61 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 12
  %.reload62 = load ptr, ptr %.reload.addr61, align 8
  %.reload.addr54 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 11
  %.reload55 = load ptr, ptr %.reload.addr54, align 8
  %.reload.addr45 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 10
  %.reload46 = load ptr, ptr %.reload.addr45, align 8
  %.reload.addr36 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  %.reload37 = load ptr, ptr %.reload.addr36, align 8
  %.reload.addr19 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload20 = load ptr, ptr %.reload.addr19, align 8
  store ptr %0, ptr %1, align 8
  store ptr %.reload20, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  store ptr %.reload20, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  call void %Destroy5.reload(ptr noalias %.reload86, ptr %.reload62) #8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload86)
  call swiftcc void @swift_task_dealloc(ptr %.reload86) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload75)
  call swiftcc void @swift_task_dealloc(ptr %.reload75) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload55)
  call swiftcc void @swift_task_dealloc(ptr %.reload55) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload46)
  call swiftcc void @swift_task_dealloc(ptr %.reload46) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload37)
  call swiftcc void @swift_task_dealloc(ptr %.reload37) #7
  %2 = load ptr, ptr %1, align 8
  %3 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %2, i32 0, i32 1
  %4 = load ptr, ptr %3, align 8
  %5 = load ptr, ptr %1, align 8
  musttail call swifttailcc void %4(ptr swiftasync %5, ptr swiftself null) #8
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKFTY3_"(ptr swiftasync %0) #5 {
entryresume.3:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %function.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %array.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %name.debug = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %.reload.addr87 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 15
  %.reload88 = load ptr, ptr %.reload.addr87, align 8
  %.reload.addr78 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 14
  %.reload79 = load ptr, ptr %.reload.addr78, align 8
  %.valueWitnesses3.reload.addr69 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 13
  %.valueWitnesses3.reload70 = load ptr, ptr %.valueWitnesses3.reload.addr69, align 8
  %.reload.addr65 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 12
  %.reload66 = load ptr, ptr %.reload.addr65, align 8
  %.reload.addr56 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 11
  %.reload57 = load ptr, ptr %.reload.addr56, align 8
  %.reload.addr47 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 10
  %.reload48 = load ptr, ptr %.reload.addr47, align 8
  %.reload.addr38 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  %.reload39 = load ptr, ptr %.reload.addr38, align 8
  %.reload.addr23 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.reload24 = load ptr, ptr %.reload.addr23, align 8
  store ptr %0, ptr %1, align 8
  store ptr %.reload24, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  store ptr %.reload24, ptr %array.debug, align 8
  call void asm sideeffect "", "r"(ptr %array.debug)
  %2 = getelementptr inbounds ptr, ptr %.valueWitnesses3.reload70, i32 1
  %Destroy = load ptr, ptr %2, align 8, !invariant.load !52
  call void %Destroy(ptr noalias %.reload79, ptr %.reload66) #8
  call void %Destroy(ptr noalias %.reload88, ptr %.reload66) #8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload88)
  call swiftcc void @swift_task_dealloc(ptr %.reload88) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload79)
  call swiftcc void @swift_task_dealloc(ptr %.reload79) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload57)
  call swiftcc void @swift_task_dealloc(ptr %.reload57) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload48)
  call swiftcc void @swift_task_dealloc(ptr %.reload48) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload39)
  call swiftcc void @swift_task_dealloc(ptr %.reload39) #7
  %3 = load ptr, ptr %1, align 8
  %4 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %3, i32 0, i32 1
  %5 = load ptr, ptr %4, align 8
  %6 = load ptr, ptr %1, align 8
  %.reload.addr95 = getelementptr inbounds %"$s16InferenceGateABI7runViewy13CoreAIRuntime0A8FunctionV7OutputsVAE_AC7NDArrayVSStYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 17
  %.reload96 = load ptr, ptr %.reload.addr95, align 8
  musttail call swifttailcc void %5(ptr swiftasync %6, ptr swiftself %.reload96) #8
  ret void
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV7RawViewVMa"(i64) #3

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV6InputsVMa"(i64) #3

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV6InputsVAEycfC"(ptr noalias sret(%swift.opaque)) #3

declare swiftcc void @"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF"(ptr noalias sret(%swift.opaque), ptr noalias swiftself) #3

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryAA7NDArrayV7RawViewVn_SStF"(ptr noalias, i64, ptr, ptr swiftself) #3

define linkonce_odr hidden swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFfA0_"(ptr noalias sret(%swift.opaque) %0) #3 {
entry:
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %0)
  ret void
}

define linkonce_odr hidden swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFfA1_"(ptr noalias sret(%swift.opaque) %0) #3 {
entry:
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %0)
  ret void
}

declare swifttailcc void @"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKF"(ptr noalias, ptr swiftasync, ptr noalias, ptr noalias, ptr noalias, ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI13oneDictionaryySDySS13CoreAIRuntime7NDArrayVGSS_AEtF"(i64 %0, ptr %1, ptr noalias %2) #0 {
entry:
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %3 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = getelementptr inbounds ptr, ptr %4, i64 -1
  %.valueWitnesses = load ptr, ptr %5, align 8, !invariant.load !52, !dereferenceable !53
  %6 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %6, align 8, !invariant.load !52
  %7 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %7)
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %0, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %1, ptr %name.debug._guts._object._object, align 8
  store ptr %2, ptr %array.debug, align 8
  %8 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSS_13CoreAIRuntime7NDArrayVtMd", ptr @"$sSS_13CoreAIRuntime7NDArrayVtMR") #14
  %9 = call swiftcc { ptr, ptr } @"$ss27_allocateUninitializedArrayySayxG_BptBwlF"(i64 1, ptr %8)
  %10 = extractvalue { ptr, ptr } %9, 0
  %11 = extractvalue { ptr, ptr } %9, 1
  %12 = getelementptr inbounds ptr, ptr %8, i64 -1
  %.valueWitnesses1 = load ptr, ptr %12, align 8, !invariant.load !52, !dereferenceable !53
  %13 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 10
  %flags = load i32, ptr %13, align 8, !invariant.load !52
  %14 = zext i32 %flags to i64
  %flags.alignmentMask = and i64 %14, 255
  %15 = add i64 32, %flags.alignmentMask
  %16 = xor i64 %flags.alignmentMask, -1
  %17 = and i64 %15, %16
  %18 = getelementptr inbounds i8, ptr %10, i64 %17
  %.elt = getelementptr inbounds nuw <{ %TSS }>, ptr %18, i32 0, i32 0
  %19 = getelementptr inbounds %swift.tuple_type, ptr %8, i64 0, i32 3, i64 1, i32 1
  %.1.offset = load i32, ptr %19, align 8
  %20 = getelementptr inbounds i8, ptr %18, i32 %.1.offset
  %21 = call ptr @swift_bridgeObjectRetain(ptr returned %1) #8
  %.elt._guts = getelementptr inbounds nuw %TSS, ptr %.elt, i32 0, i32 0
  %.elt._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %.elt._guts, i32 0, i32 0
  %.elt._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %.elt._guts._object, i32 0, i32 0
  %.elt._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %.elt._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %0, ptr %.elt._guts._object._countAndFlagsBits._value, align 8
  %.elt._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %.elt._guts._object, i32 0, i32 1
  store ptr %1, ptr %.elt._guts._object._object, align 8
  %22 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 2
  %InitializeWithCopy = load ptr, ptr %22, align 8, !invariant.load !52
  %23 = call ptr %InitializeWithCopy(ptr noalias %7, ptr noalias %2, ptr %4) #8
  %24 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %24, align 8, !invariant.load !52
  %25 = call ptr %InitializeWithTake(ptr noalias %20, ptr noalias %7, ptr %4) #8
  %26 = call swiftcc ptr @"$ss27_finalizeUninitializedArrayySayxGABnlF"(ptr %10, ptr %8)
  %27 = call swiftcc ptr @"$sSD17dictionaryLiteralSDyxq_Gx_q_td_tcfC"(ptr %26, ptr @"$sSSN", ptr %4, ptr @"$sSSSHsWP")
  call void @llvm.lifetime.end.p0(i64 -1, ptr %7)
  ret ptr %27
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64) #3

declare swiftcc { ptr, ptr } @"$ss27_allocateUninitializedArrayySayxG_BptBwlF"(i64, ptr) #3

; Function Attrs: noinline nounwind willreturn memory(read)
define linkonce_odr hidden ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr %0, ptr %1) #9 {
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
  %18 = call swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr %17, i64 %12, ptr null, ptr null) #15
  store atomic ptr %18, ptr %0 monotonic, align 8
  br label %8
}

; Function Attrs: nounwind memory(argmem: readwrite)
declare swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr, i64, ptr, ptr) #10

; Function Attrs: nounwind
declare ptr @swift_bridgeObjectRetain(ptr returned) #8

define linkonce_odr hidden swiftcc ptr @"$ss27_finalizeUninitializedArrayySayxGABnlF"(ptr %0, ptr %Element) #3 {
entry:
  %Element1 = alloca ptr, align 8
  %1 = alloca %TSa, align 8
  store ptr %Element, ptr %Element1, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr %1)
  %._buffer = getelementptr inbounds nuw %TSa, ptr %1, i32 0, i32 0
  %._buffer._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer, i32 0, i32 0
  %._buffer._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer._storage, i32 0, i32 0
  store ptr %0, ptr %._buffer._storage.rawValue, align 8
  %2 = call swiftcc %swift.metadata_response @"$sSaMa"(i64 0, ptr %Element) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  call swiftcc void @"$sSa12_endMutationyyF"(ptr %3, ptr swiftself captures(none) dereferenceable(8) %1)
  %._buffer2 = getelementptr inbounds nuw %TSa, ptr %1, i32 0, i32 0
  %._buffer2._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer2, i32 0, i32 0
  %._buffer2._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer2._storage, i32 0, i32 0
  %4 = load ptr, ptr %._buffer2._storage.rawValue, align 8
  call void @llvm.lifetime.end.p0(i64 8, ptr %1)
  ret ptr %4
}

declare swiftcc ptr @"$sSD17dictionaryLiteralSDyxq_Gx_q_td_tcfC"(ptr, ptr, ptr, ptr) #3

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI15emptyDictionarySDySS13CoreAIRuntime7NDArrayVGyF"() #0 {
entry:
  %0 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSS_13CoreAIRuntime7NDArrayVtMd", ptr @"$sSS_13CoreAIRuntime7NDArrayVtMR") #14
  %1 = call swiftcc { ptr, ptr } @"$ss27_allocateUninitializedArrayySayxG_BptBwlF"(i64 0, ptr %0)
  %2 = extractvalue { ptr, ptr } %1, 0
  %3 = extractvalue { ptr, ptr } %1, 1
  %4 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %5 = extractvalue %swift.metadata_response %4, 0
  %6 = call swiftcc ptr @"$sSD17dictionaryLiteralSDyxq_Gx_q_td_tcfC"(ptr %2, ptr @"$sSSN", ptr %5, ptr @"$sSSSHsWP")
  ret ptr %6
}

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI16dictionaryUpdateyySDySS13CoreAIRuntime7NDArrayVGz_SSAEtF"(ptr captures(none) dereferenceable(8) %0, i64 %1, ptr %2, ptr noalias %3) #0 {
entry:
  %dictionary.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %dictionary.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %4 = alloca %TSS, align 8
  %5 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %6 = extractvalue %swift.metadata_response %5, 0
  %7 = getelementptr inbounds ptr, ptr %6, i64 -1
  %.valueWitnesses = load ptr, ptr %7, align 8, !invariant.load !52, !dereferenceable !53
  %8 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %8, align 8, !invariant.load !52
  %9 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %9)
  %10 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime7NDArrayVSgMd", ptr @"$s13CoreAIRuntime7NDArrayVSgMR") #14
  %11 = getelementptr inbounds ptr, ptr %10, i64 -1
  %.valueWitnesses1 = load ptr, ptr %11, align 8, !invariant.load !52, !dereferenceable !53
  %12 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %12, align 8, !invariant.load !52
  %13 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %13)
  store ptr %0, ptr %dictionary.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %1, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %2, ptr %name.debug._guts._object._object, align 8
  store ptr %3, ptr %array.debug, align 8
  %14 = call ptr @swift_bridgeObjectRetain(ptr returned %2) #8
  %15 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 2
  %InitializeWithCopy = load ptr, ptr %15, align 8, !invariant.load !52
  %16 = call ptr %InitializeWithCopy(ptr noalias %9, ptr noalias %3, ptr %6) #8
  %17 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %17, align 8, !invariant.load !52
  %18 = call ptr %InitializeWithTake(ptr noalias %13, ptr noalias %9, ptr %6) #8
  %19 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %19, align 8, !invariant.load !52
  call void %StoreEnumTagSinglePayload(ptr noalias %13, i32 0, i32 1, ptr %6) #8
  call void @llvm.lifetime.start.p0(i64 16, ptr %4)
  %._guts = getelementptr inbounds nuw %TSS, ptr %4, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 0
  %._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %1, ptr %._guts._object._countAndFlagsBits._value, align 8
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  store ptr %2, ptr %._guts._object._object, align 8
  %20 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSDySS13CoreAIRuntime7NDArrayVGMd", ptr @"$sSDySS13CoreAIRuntime7NDArrayVGMR") #14
  call swiftcc void @"$sSDyq_Sgxcis"(ptr noalias %13, ptr noalias %4, ptr %20, ptr swiftself captures(none) dereferenceable(8) %0)
  call void @llvm.lifetime.end.p0(i64 16, ptr %4)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %13)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %9)
  ret void
}

declare swiftcc void @"$sSDyq_Sgxcis"(ptr noalias, ptr noalias, ptr, ptr swiftself captures(none) dereferenceable(8)) #3

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI12removeOutputy13CoreAIRuntime0A5ValueVSgAC0A8FunctionV7OutputsVz_SStF"(ptr noalias sret(%swift.opaque) %0, ptr %1, i64 %2, ptr %3) #0 {
entry:
  %outputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %outputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %1, ptr %outputs.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %name.debug._guts._object._object, align 8
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF"(ptr noalias sret(%swift.opaque) %0, i64 %2, ptr %3, ptr swiftself %1)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr swiftself) #3

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI11outputArrayy13CoreAIRuntime7NDArrayVSgAC0A5ValueVnF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %value.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime14InferenceValueVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %5, align 8, !invariant.load !52
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  store ptr %6, ptr %value.debug, align 8
  br label %7

7:                                                ; preds = %entry
  %8 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %8, align 8, !invariant.load !52
  %9 = call ptr %InitializeWithTake(ptr noalias %6, ptr noalias %1, ptr %3) #8
  call void asm sideeffect "nop", ""()
  call swiftcc void @"$s13CoreAIRuntime14InferenceValueV7ndArrayAA7NDArrayVSgvg"(ptr noalias sret(%swift.opaque) %0, ptr noalias swiftself %6)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %6)
  ret void
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime14InferenceValueVMa"(i64) #3

declare swiftcc void @"$s13CoreAIRuntime14InferenceValueV7ndArrayAA7NDArrayVSgvg"(ptr noalias sret(%swift.opaque), ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc i64 @"$s16InferenceGateABI11outputCountySi13CoreAIRuntime0A8FunctionV7OutputsVF"(ptr noalias %0) #0 {
entry:
  %outputs.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %outputs.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %outputs.debug, align 8
  %1 = call swiftcc i64 @"$s13CoreAIRuntime17InferenceFunctionV7OutputsV5countSivg"(ptr noalias swiftself %0)
  ret i64 %1
}

declare swiftcc i64 @"$s13CoreAIRuntime17InferenceFunctionV7OutputsV5countSivg"(ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI7shape23SaySiGyF"() #0 {
entry:
  %0 = alloca %TSa, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %0, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %1 = alloca %TSi, align 8
  %2 = alloca [32 x i8], align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr %0)
  call void @llvm.lifetime.start.p0(i64 8, ptr %1)
  %._value = getelementptr inbounds nuw %TSi, ptr %1, i32 0, i32 0
  store i64 2, ptr %._value, align 8
  %3 = call swiftcc ptr @"$sSa9repeating5countSayxGx_SitcfC"(ptr noalias %1, i64 2, ptr @"$sSiN")
  call void @llvm.lifetime.end.p0(i64 8, ptr %1)
  %._buffer = getelementptr inbounds nuw %TSa, ptr %0, i32 0, i32 0
  %._buffer._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer, i32 0, i32 0
  %._buffer._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer._storage, i32 0, i32 0
  store ptr %3, ptr %._buffer._storage.rawValue, align 8
  %4 = getelementptr inbounds nuw [32 x i8], ptr %2, i32 0, i32 0
  call void @llvm.lifetime.start.p0(i64 32, ptr %4)
  %5 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSaySiGMd", ptr @"$sSaySiGMR") #14
  %6 = call swiftcc { ptr, ptr } @"$sSayxSiciM"(ptr noalias dereferenceable(32) %4, i64 1, ptr %5, ptr swiftself captures(none) dereferenceable(8) %0)
  %7 = extractvalue { ptr, ptr } %6, 0
  %8 = extractvalue { ptr, ptr } %6, 1
  %._value1 = getelementptr inbounds nuw %TSi, ptr %8, i32 0, i32 0
  store i64 3, ptr %._value1, align 8
  call swiftcc void %7(ptr noalias dereferenceable(32) %4, i1 false)
  call void @llvm.lifetime.end.p0(i64 32, ptr %4)
  %._buffer2 = getelementptr inbounds nuw %TSa, ptr %0, i32 0, i32 0
  %._buffer2._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer2, i32 0, i32 0
  %._buffer2._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer2._storage, i32 0, i32 0
  %9 = load ptr, ptr %._buffer2._storage.rawValue, align 8
  %10 = call ptr @swift_bridgeObjectRetain(ptr returned %9) #8
  %11 = call ptr @"$sSaySiGWOh"(ptr %0)
  call void @llvm.lifetime.end.p0(i64 8, ptr %0)
  ret ptr %9
}

declare swiftcc ptr @"$sSa9repeating5countSayxGx_SitcfC"(ptr noalias, i64, ptr) #3

declare swiftcc { ptr, ptr } @"$sSayxSiciM"(ptr noalias dereferenceable(32), i64, ptr, ptr swiftself captures(none) dereferenceable(8)) #3

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$sSaySiGWOh"(ptr %0) #11 {
entry:
  %._buffer = getelementptr inbounds nuw %TSa, ptr %0, i32 0, i32 0
  %._buffer._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer, i32 0, i32 0
  %._buffer._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer._storage, i32 0, i32 0
  %toDestroy = load ptr, ptr %._buffer._storage.rawValue, align 8
  call void @swift_bridgeObjectRelease(ptr %toDestroy) #8
  ret ptr %0
}

; Function Attrs: nounwind
declare void @swift_bridgeObjectRelease(ptr) #8

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI7shapeOfySaySiG13CoreAIRuntime7NDArrayVF"(ptr noalias %0) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %array.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg"(ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI9stridesOfySaySiG13CoreAIRuntime7NDArrayVF"(ptr noalias %0) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %array.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime7NDArrayV7stridesSaySiGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime7NDArrayV7stridesSaySiGvg"(ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI8scalarOfy13CoreAIRuntime7NDArrayV10ScalarTypeOAEF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %1, ptr %array.debug, align 8
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg"(ptr noalias sret(%swift.opaque) %0, ptr noalias swiftself %1)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg"(ptr noalias sret(%swift.opaque), ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI14unwrapFunctiony13CoreAIRuntime0aE0VAESgnF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %function.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %value.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %function.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %5, align 8, !invariant.load !52
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  store ptr %6, ptr %function.debug, align 8
  %7 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime17InferenceFunctionVSgMd", ptr @"$s13CoreAIRuntime17InferenceFunctionVSgMR") #14
  %8 = getelementptr inbounds ptr, ptr %7, i64 -1
  %.valueWitnesses1 = load ptr, ptr %8, align 8, !invariant.load !52, !dereferenceable !53
  %9 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %9, align 8, !invariant.load !52
  %10 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %10)
  %11 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  store ptr %11, ptr %value.debug, align 8
  br label %12

12:                                               ; preds = %entry
  %13 = call ptr @"$s13CoreAIRuntime17InferenceFunctionVSgWOb"(ptr %1, ptr %11)
  %14 = call ptr @"$s13CoreAIRuntime17InferenceFunctionVSgWOb"(ptr %11, ptr %10)
  %15 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 6
  %GetEnumTagSinglePayload = load ptr, ptr %15, align 8, !invariant.load !52
  %16 = call i32 %GetEnumTagSinglePayload(ptr noalias %10, i32 1, ptr %3) #14
  %17 = icmp ne i32 %16, 1
  br i1 %17, label %19, label %25

18:                                               ; No predecessors!
  unreachable

19:                                               ; preds = %12
  %20 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %20, align 8, !invariant.load !52
  %21 = call ptr %InitializeWithTake(ptr noalias %6, ptr noalias %10, ptr %3) #8
  store ptr %6, ptr %function.debug, align 8
  %22 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 2
  %InitializeWithCopy = load ptr, ptr %22, align 8, !invariant.load !52
  %23 = call ptr %InitializeWithCopy(ptr noalias %0, ptr noalias %6, ptr %3) #8
  %24 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 1
  %Destroy = load ptr, ptr %24, align 8, !invariant.load !52
  call void %Destroy(ptr noalias %6, ptr %3) #8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %11)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %10)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %6)
  ret void

25:                                               ; preds = %12
  call void asm sideeffect "nop", ""()
  %26 = call swiftcc { i64, ptr } @"$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC"(ptr @".str.16.missing function", i64 16, i1 true)
  %27 = extractvalue { i64, ptr } %26, 0
  %28 = extractvalue { i64, ptr } %26, 1
  call swiftcc void @"$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_SSAHSus6UInt32VtF"(i64 ptrtoint (ptr @".str.11.Fatal error" to i64), i64 11, i8 2, i64 %27, ptr %28, i64 ptrtoint (ptr @".str.41.InferenceGateABI/InferenceReference.swift" to i64), i64 41, i8 2, i64 40, i32 1)
  unreachable
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionVMa"(i64) #3

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$s13CoreAIRuntime17InferenceFunctionVSgWOb"(ptr %0, ptr %1) #11 {
entry:
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 6
  %GetEnumTagSinglePayload = load ptr, ptr %5, align 8, !invariant.load !52
  %6 = call i32 %GetEnumTagSinglePayload(ptr noalias %0, i32 1, ptr %3) #14
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %8, label %12

8:                                                ; preds = %entry
  %9 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %9, align 8, !invariant.load !52
  %10 = call ptr %InitializeWithTake(ptr noalias %1, ptr noalias %0, ptr %3) #8
  %11 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %11, align 8, !invariant.load !52
  call void %StoreEnumTagSinglePayload(ptr noalias %1, i32 0, i32 1, ptr %3) #8
  br label %16

12:                                               ; preds = %entry
  %13 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime17InferenceFunctionVSgMd", ptr @"$s13CoreAIRuntime17InferenceFunctionVSgMR") #14
  %14 = getelementptr inbounds ptr, ptr %13, i64 -1
  %.valueWitnesses1 = load ptr, ptr %14, align 8, !invariant.load !52, !dereferenceable !53
  %15 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size = load i64, ptr %15, align 8, !invariant.load !52
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr align 1 %0, i64 %size, i1 false)
  br label %16

16:                                               ; preds = %12, %8
  ret ptr %1
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #12

declare swiftcc { i64, ptr } @"$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC"(ptr, i64, i1) #3

; Function Attrs: noinline
declare swiftcc void @"$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_SSAHSus6UInt32VtF"(i64, i64, i8, i64, ptr, i64, i64, i8, i64, i32) #0

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI11unwrapValuey13CoreAIRuntime0aE0VAESgnF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %value.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %output.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %output.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %output.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime14InferenceValueVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %5, align 8, !invariant.load !52
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  %7 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime14InferenceValueVSgMd", ptr @"$s13CoreAIRuntime14InferenceValueVSgMR") #14
  %8 = getelementptr inbounds ptr, ptr %7, i64 -1
  %.valueWitnesses1 = load ptr, ptr %8, align 8, !invariant.load !52, !dereferenceable !53
  %9 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %9, align 8, !invariant.load !52
  %10 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %10)
  %11 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  store ptr %11, ptr %value.debug, align 8
  br label %12

12:                                               ; preds = %entry
  %13 = call ptr @"$s13CoreAIRuntime14InferenceValueVSgWOb"(ptr %1, ptr %11)
  %14 = call ptr @"$s13CoreAIRuntime14InferenceValueVSgWOb"(ptr %11, ptr %10)
  %15 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 6
  %GetEnumTagSinglePayload = load ptr, ptr %15, align 8, !invariant.load !52
  %16 = call i32 %GetEnumTagSinglePayload(ptr noalias %10, i32 1, ptr %3) #14
  %17 = icmp ne i32 %16, 1
  br i1 %17, label %19, label %24

18:                                               ; No predecessors!
  unreachable

19:                                               ; preds = %12
  store ptr %6, ptr %output.debug, align 8
  br label %20

20:                                               ; preds = %19
  %21 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %21, align 8, !invariant.load !52
  %22 = call ptr %InitializeWithTake(ptr noalias %6, ptr noalias %10, ptr %3) #8
  store ptr %6, ptr %output.debug, align 8
  call void asm sideeffect "nop", ""()
  %23 = call ptr %InitializeWithTake(ptr noalias %0, ptr noalias %6, ptr %3) #8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %11)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %10)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %6)
  ret void

24:                                               ; preds = %12
  call void asm sideeffect "nop", ""()
  %25 = call swiftcc { i64, ptr } @"$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC"(ptr @".str.14.missing output", i64 14, i1 true)
  %26 = extractvalue { i64, ptr } %25, 0
  %27 = extractvalue { i64, ptr } %25, 1
  call swiftcc void @"$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_SSAHSus6UInt32VtF"(i64 ptrtoint (ptr @".str.11.Fatal error" to i64), i64 11, i8 2, i64 %26, ptr %27, i64 ptrtoint (ptr @".str.41.InferenceGateABI/InferenceReference.swift" to i64), i64 41, i8 2, i64 46, i32 1)
  unreachable
}

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$s13CoreAIRuntime14InferenceValueVSgWOb"(ptr %0, ptr %1) #11 {
entry:
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime14InferenceValueVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 6
  %GetEnumTagSinglePayload = load ptr, ptr %5, align 8, !invariant.load !52
  %6 = call i32 %GetEnumTagSinglePayload(ptr noalias %0, i32 1, ptr %3) #14
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %8, label %12

8:                                                ; preds = %entry
  %9 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %9, align 8, !invariant.load !52
  %10 = call ptr %InitializeWithTake(ptr noalias %1, ptr noalias %0, ptr %3) #8
  %11 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %11, align 8, !invariant.load !52
  call void %StoreEnumTagSinglePayload(ptr noalias %1, i32 0, i32 1, ptr %3) #8
  br label %16

12:                                               ; preds = %entry
  %13 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime14InferenceValueVSgMd", ptr @"$s13CoreAIRuntime14InferenceValueVSgMR") #14
  %14 = getelementptr inbounds ptr, ptr %13, i64 -1
  %.valueWitnesses1 = load ptr, ptr %14, align 8, !invariant.load !52, !dereferenceable !53
  %15 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size = load i64, ptr %15, align 8, !invariant.load !52
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr align 1 %0, i64 %size, i1 false)
  br label %16

16:                                               ; preds = %12, %8
  ret ptr %1
}

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI11unwrapArrayy13CoreAIRuntime7NDArrayVAESgnF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %value.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %5, align 8, !invariant.load !52
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  store ptr %6, ptr %array.debug, align 8
  %7 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime7NDArrayVSgMd", ptr @"$s13CoreAIRuntime7NDArrayVSgMR") #14
  %8 = getelementptr inbounds ptr, ptr %7, i64 -1
  %.valueWitnesses1 = load ptr, ptr %8, align 8, !invariant.load !52, !dereferenceable !53
  %9 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %9, align 8, !invariant.load !52
  %10 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %10)
  %11 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  store ptr %11, ptr %value.debug, align 8
  br label %12

12:                                               ; preds = %entry
  %13 = call ptr @"$s13CoreAIRuntime7NDArrayVSgWOb"(ptr %1, ptr %11)
  %14 = call ptr @"$s13CoreAIRuntime7NDArrayVSgWOb"(ptr %11, ptr %10)
  %15 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 6
  %GetEnumTagSinglePayload = load ptr, ptr %15, align 8, !invariant.load !52
  %16 = call i32 %GetEnumTagSinglePayload(ptr noalias %10, i32 1, ptr %3) #14
  %17 = icmp ne i32 %16, 1
  br i1 %17, label %19, label %25

18:                                               ; No predecessors!
  unreachable

19:                                               ; preds = %12
  %20 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %20, align 8, !invariant.load !52
  %21 = call ptr %InitializeWithTake(ptr noalias %6, ptr noalias %10, ptr %3) #8
  store ptr %6, ptr %array.debug, align 8
  %22 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 2
  %InitializeWithCopy = load ptr, ptr %22, align 8, !invariant.load !52
  %23 = call ptr %InitializeWithCopy(ptr noalias %0, ptr noalias %6, ptr %3) #8
  %24 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 1
  %Destroy = load ptr, ptr %24, align 8, !invariant.load !52
  call void %Destroy(ptr noalias %6, ptr %3) #8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %11)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %10)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %6)
  ret void

25:                                               ; preds = %12
  call void asm sideeffect "nop", ""()
  %26 = call swiftcc { i64, ptr } @"$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC"(ptr @".str.11.not NDArray", i64 11, i1 true)
  %27 = extractvalue { i64, ptr } %26, 0
  %28 = extractvalue { i64, ptr } %26, 1
  call swiftcc void @"$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_SSAHSus6UInt32VtF"(i64 ptrtoint (ptr @".str.11.Fatal error" to i64), i64 11, i8 2, i64 %27, ptr %28, i64 ptrtoint (ptr @".str.41.InferenceGateABI/InferenceReference.swift" to i64), i64 41, i8 2, i64 52, i32 1)
  unreachable
}

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$s13CoreAIRuntime7NDArrayVSgWOb"(ptr %0, ptr %1) #11 {
entry:
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !52, !dereferenceable !53
  %5 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 6
  %GetEnumTagSinglePayload = load ptr, ptr %5, align 8, !invariant.load !52
  %6 = call i32 %GetEnumTagSinglePayload(ptr noalias %0, i32 1, ptr %3) #14
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %8, label %12

8:                                                ; preds = %entry
  %9 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %9, align 8, !invariant.load !52
  %10 = call ptr %InitializeWithTake(ptr noalias %1, ptr noalias %0, ptr %3) #8
  %11 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %11, align 8, !invariant.load !52
  call void %StoreEnumTagSinglePayload(ptr noalias %1, i32 0, i32 1, ptr %3) #8
  br label %16

12:                                               ; preds = %entry
  %13 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$s13CoreAIRuntime7NDArrayVSgMd", ptr @"$s13CoreAIRuntime7NDArrayVSgMR") #14
  %14 = getelementptr inbounds ptr, ptr %13, i64 -1
  %.valueWitnesses1 = load ptr, ptr %14, align 8, !invariant.load !52, !dereferenceable !53
  %15 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size = load i64, ptr %15, align 8, !invariant.load !52
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr align 1 %0, i64 %size, i1 false)
  br label %16

16:                                               ; preds = %12, %8
  ret ptr %1
}

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI23emptyDictionaryCapacitySDySS13CoreAIRuntime7NDArrayVGyF"() #0 {
entry:
  %0 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %1 = extractvalue %swift.metadata_response %0, 0
  %2 = call swiftcc ptr @"$sSD15minimumCapacitySDyxq_GSi_tcfC"(i64 0, ptr @"$sSSN", ptr %1, ptr @"$sSSSHsWP")
  ret ptr %2
}

declare swiftcc ptr @"$sSD15minimumCapacitySDyxq_GSi_tcfC"(i64, ptr, ptr, ptr) #3

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI17dictionaryReplacey13CoreAIRuntime7NDArrayVSgSDySSAEGz_SSnAEntF"(ptr noalias sret(%swift.opaque) %0, ptr captures(none) dereferenceable(8) %1, i64 %2, ptr %3, ptr noalias %4) #0 {
entry:
  %dictionary.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %dictionary.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %5 = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %5, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %6 = alloca %TSS, align 8
  %7 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %8 = extractvalue %swift.metadata_response %7, 0
  %9 = getelementptr inbounds ptr, ptr %8, i64 -1
  %.valueWitnesses = load ptr, ptr %9, align 8, !invariant.load !52, !dereferenceable !53
  %10 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %10, align 8, !invariant.load !52
  %11 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  %12 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  store ptr %1, ptr %dictionary.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %5)
  %._guts = getelementptr inbounds nuw %TSS, ptr %5, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 0
  %._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %._guts._object._countAndFlagsBits._value, align 8
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  store ptr %3, ptr %._guts._object._object, align 8
  store ptr %12, ptr %array.debug, align 8
  br label %13

13:                                               ; preds = %entry
  %14 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake = load ptr, ptr %14, align 8, !invariant.load !52
  %15 = call ptr %InitializeWithTake(ptr noalias %12, ptr noalias %4, ptr %8) #8
  %16 = call ptr %InitializeWithTake(ptr noalias %11, ptr noalias %12, ptr %8) #8
  %._guts1 = getelementptr inbounds nuw %TSS, ptr %5, i32 0, i32 0
  %._guts1._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts1, i32 0, i32 0
  %._guts1._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts1._object, i32 0, i32 0
  %._guts1._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts1._object._countAndFlagsBits, i32 0, i32 0
  %17 = load i64, ptr %._guts1._object._countAndFlagsBits._value, align 8
  %._guts1._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts1._object, i32 0, i32 1
  %18 = load ptr, ptr %._guts1._object._object, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %6)
  %._guts2 = getelementptr inbounds nuw %TSS, ptr %6, i32 0, i32 0
  %._guts2._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts2, i32 0, i32 0
  %._guts2._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts2._object, i32 0, i32 0
  %._guts2._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts2._object._countAndFlagsBits, i32 0, i32 0
  store i64 %17, ptr %._guts2._object._countAndFlagsBits._value, align 8
  %._guts2._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts2._object, i32 0, i32 1
  store ptr %18, ptr %._guts2._object._object, align 8
  %19 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr @"$sSDySS13CoreAIRuntime7NDArrayVGMd", ptr @"$sSDySS13CoreAIRuntime7NDArrayVGMR") #14
  call swiftcc void @"$sSD11updateValue_6forKeyq_Sgq_n_xtF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %11, ptr noalias %6, ptr %19, ptr swiftself captures(none) dereferenceable(8) %1)
  %20 = call ptr @"$sSSWOh"(ptr %6)
  call void @llvm.lifetime.end.p0(i64 16, ptr %6)
  call void @llvm.lifetime.end.p0(i64 16, ptr %5)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %12)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %11)
  ret void
}

declare swiftcc void @"$sSD11updateValue_6forKeyq_Sgq_n_xtF"(ptr noalias sret(%swift.opaque), ptr noalias, ptr noalias, ptr, ptr swiftself captures(none) dereferenceable(8)) #3

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$sSSWOh"(ptr %0) #11 {
entry:
  %._guts = getelementptr inbounds nuw %TSS, ptr %0, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  %toDestroy = load ptr, ptr %._guts._object._object, align 8
  call void @swift_bridgeObjectRelease(ptr %toDestroy) #8
  ret ptr %0
}

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI16dictionaryLookupy13CoreAIRuntime7NDArrayVSgSDySSAEG_SStF"(ptr noalias sret(%swift.opaque) %0, ptr %1, i64 %2, ptr %3) #0 {
entry:
  %dictionary.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %dictionary.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %name.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %name.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  %4 = alloca %TSS, align 8
  store ptr %1, ptr %dictionary.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %name.debug)
  %name.debug._guts = getelementptr inbounds nuw %TSS, ptr %name.debug, i32 0, i32 0
  %name.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %name.debug._guts, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 0
  %name.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %name.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %name.debug._guts._object._countAndFlagsBits._value, align 8
  %name.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %name.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %name.debug._guts._object._object, align 8
  %5 = call ptr @swift_bridgeObjectRetain(ptr returned %3) #8
  call void @llvm.lifetime.start.p0(i64 16, ptr %4)
  %._guts = getelementptr inbounds nuw %TSS, ptr %4, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 0
  %._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %._guts._object._countAndFlagsBits._value, align 8
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  store ptr %3, ptr %._guts._object._object, align 8
  %6 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayVMa"(i64 0) #13
  %7 = extractvalue %swift.metadata_response %6, 0
  call swiftcc void @"$sSDyq_Sgxcig"(ptr noalias sret(%swift.opaque) %0, ptr noalias %4, ptr %1, ptr @"$sSSN", ptr %7, ptr @"$sSSSHsWP")
  %8 = call ptr @"$sSSWOh"(ptr %4)
  call void @llvm.lifetime.end.p0(i64 16, ptr %4)
  ret void
}

declare swiftcc void @"$sSDyq_Sgxcig"(ptr noalias sret(%swift.opaque), ptr noalias, ptr, ptr, ptr, ptr) #3

; Function Attrs: noinline
define swiftcc void @"$s16InferenceGateABI17consumeDictionaryyySDySS13CoreAIRuntime7NDArrayVGnF"(ptr %0) #0 {
entry:
  %dictionary.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %dictionary.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %dictionary.debug, align 8
  call void @swift_bridgeObjectRelease(ptr %0) #8
  ret void
}

; Function Attrs: noinline
define swiftcc ptr @"$s16InferenceGateABI14dictionaryTypeyypXpxm_q_mtSHRzr0_lF"(ptr %0, ptr %1, ptr %K, ptr %V, ptr %K.Hashable) #0 {
entry:
  %K1 = alloca ptr, align 8
  %V2 = alloca ptr, align 8
  %_0.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %_0.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %_1.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %_1.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %K, ptr %K1, align 8
  store ptr %V, ptr %V2, align 8
  store ptr %0, ptr %_0.debug, align 8
  store ptr %1, ptr %_1.debug, align 8
  %2 = call swiftcc %swift.metadata_response @"$sSDMa"(i64 0, ptr %K, ptr %V, ptr %K.Hashable) #13
  %3 = extractvalue %swift.metadata_response %2, 0
  ret ptr %3
}

declare swiftcc %swift.metadata_response @"$sSDMa"(i64, ptr, ptr, ptr) #3

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

define linkonce_odr hidden swiftcc void @"$sSa12_endMutationyyF"(ptr %"Array<Element>", ptr swiftself captures(none) dereferenceable(8) %0) #3 {
entry:
  %._buffer = getelementptr inbounds nuw %TSa, ptr %0, i32 0, i32 0
  %._buffer._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer, i32 0, i32 0
  %._buffer._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer._storage, i32 0, i32 0
  %1 = load ptr, ptr %._buffer._storage.rawValue, align 8
  %._buffer1 = getelementptr inbounds nuw %TSa, ptr %0, i32 0, i32 0
  %._buffer1._storage = getelementptr inbounds nuw %Ts12_ArrayBufferV, ptr %._buffer1, i32 0, i32 0
  %._buffer1._storage.rawValue = getelementptr inbounds nuw %Ts14_BridgeStorageV, ptr %._buffer1._storage, i32 0, i32 0
  store ptr %1, ptr %._buffer1._storage.rawValue, align 8
  ret void
}

declare swiftcc %swift.metadata_response @"$sSaMa"(i64, ptr) #3

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque)) #3

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { noinline "async_entry" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { noinline "async_continuation" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { noinline "async_ret" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #7 = { nounwind memory(inaccessiblemem: readwrite) }
attributes #8 = { nounwind }
attributes #9 = { noinline nounwind willreturn memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #10 = { nounwind memory(argmem: readwrite) }
attributes #11 = { noinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #12 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #13 = { nounwind memory(none) }
attributes #14 = { nounwind memory(read) }
attributes #15 = { nounwind memory(argmem: read) }

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
!13 = !{!"-lswiftFoundation"}
!14 = !{!"-framework", !"Foundation"}
!15 = !{!"-lswiftCore"}
!16 = !{!"-lswift_DarwinFoundation3"}
!17 = !{!"-lswift_DarwinFoundation1"}
!18 = !{!"-lswift_Builtin_float"}
!19 = !{!"-lswift_DarwinFoundation2"}
!20 = !{!"-lswift_StringProcessing"}
!21 = !{!"-lswift_Concurrency"}
!22 = !{!"-lswiftSystem"}
!23 = !{!"-lswiftDarwin"}
!24 = !{!"-lswiftObservation"}
!25 = !{!"-lswiftObjectiveC"}
!26 = !{!"-lswiftCoreFoundation"}
!27 = !{!"-framework", !"CoreFoundation"}
!28 = !{!"-lswiftDispatch"}
!29 = !{!"-framework", !"Combine"}
!30 = !{!"-framework", !"CoreServices"}
!31 = !{!"-framework", !"Security"}
!32 = !{!"-lswiftXPC"}
!33 = !{!"-framework", !"CFNetwork"}
!34 = !{!"-framework", !"DiskArbitration"}
!35 = !{!"-lswiftIOKit"}
!36 = !{!"-framework", !"IOKit"}
!37 = !{!"-framework", !"CoreAI"}
!38 = !{!"-framework", !"CoreAIDelegates"}
!39 = !{!"-framework", !"CoreAIRuntime"}
!40 = !{!"-lswiftMetal"}
!41 = !{!"-framework", !"Metal"}
!42 = !{!"-framework", !"IOSurface"}
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
