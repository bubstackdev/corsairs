; ModuleID = '/private/tmp/corsairs-owned-api/owned.ll'
source_filename = "/private/tmp/corsairs-owned-api/owned.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.opaque = type opaque
%swift.metadata_response = type { ptr, i64 }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%TSS = type <{ %Ts11_StringGutsV }>
%Ts11_StringGutsV = type <{ %Ts13_StringObjectV }>
%Ts13_StringObjectV = type <{ %Ts6UInt64V, ptr }>
%Ts6UInt64V = type <{ i64 }>

@"$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC" = external constant i32, align 4
@"$s13CoreAIRuntime14InferenceValueV10DescriptorO7ndArrayyAeA07NDArrayE0VcAEmFWC" = external constant i32, align 4
@"$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC" = external constant i32, align 4
@"_swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [35 x ptr] [ptr @"$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF", ptr @"$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF", ptr @"$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF", ptr @"$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF", ptr @"$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF", ptr @"$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF", ptr @"$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF", ptr @"$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF", ptr @"$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF", ptr @"$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF", ptr @"$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF", ptr @"$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF", ptr @"$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF", ptr @"$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF", ptr @"$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF", ptr @"$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF", ptr @"$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF", ptr @"$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF", ptr @"$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI", ptr @__swift_reflection_version], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF"(ptr noalias sret(%swift.opaque) %0) #0 {
entry:
  %1 = call swiftcc %swift.metadata_response @"$s15CoreAIDelegates15ComputeUnitKindOMa"(i64 0) #4
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds ptr, ptr %2, i64 -1
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !51, !dereferenceable !52
  %4 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %4, align 8, !invariant.load !51
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %5)
  %6 = load i32, ptr @"$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC", align 4
  %7 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 13
  %DestructiveInjectEnumTag = load ptr, ptr %7, align 8, !invariant.load !51
  call void %DestructiveInjectEnumTag(ptr noalias %5, i32 %6, ptr %2) #5
  call swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC"(ptr noalias sret(%swift.opaque) %0, ptr noalias %5)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %5)
  ret void
}

declare swiftcc %swift.metadata_response @"$s15CoreAIDelegates15ComputeUnitKindOMa"(i64) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #2

declare swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC"(ptr noalias sret(%swift.opaque), ptr noalias) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %f.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %f.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %1, ptr %f.debug, align 8
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV10descriptorAA0cD10DescriptorVvg"(ptr noalias sret(%swift.opaque) %0, ptr noalias swiftself %1)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #3

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV10descriptorAA0cD10DescriptorVvg"(ptr noalias sret(%swift.opaque), ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc { i64, ptr } @"$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF"(ptr noalias %0) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %0, ptr %d.debug, align 8
  %1 = call swiftcc { i64, ptr } @"$s13CoreAIRuntime27InferenceFunctionDescriptorV4nameSSvg"(ptr noalias swiftself %0)
  %2 = extractvalue { i64, ptr } %1, 0
  %3 = extractvalue { i64, ptr } %1, 1
  %4 = insertvalue { i64, ptr } undef, i64 %2, 0
  %5 = insertvalue { i64, ptr } %4, ptr %3, 1
  ret { i64, ptr } %5
}

declare swiftcc { i64, ptr } @"$s13CoreAIRuntime27InferenceFunctionDescriptorV4nameSSvg"(ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc ptr @"$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF"(ptr noalias %0) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %0, ptr %d.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime27InferenceFunctionDescriptorV10inputNamesSaySSGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime27InferenceFunctionDescriptorV10inputNamesSaySSGvg"(ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc ptr @"$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF"(ptr noalias %0) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %0, ptr %d.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime27InferenceFunctionDescriptorV11outputNamesSaySSGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime27InferenceFunctionDescriptorV11outputNamesSaySSGvg"(ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc ptr @"$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF"(ptr noalias %0) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %0, ptr %d.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime27InferenceFunctionDescriptorV10stateNamesSaySSGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime27InferenceFunctionDescriptorV10stateNamesSaySSGvg"(ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1, i64 %2, ptr %3) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %n.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %n.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %1, ptr %d.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %n.debug)
  %n.debug._guts = getelementptr inbounds nuw %TSS, ptr %n.debug, i32 0, i32 0
  %n.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %n.debug._guts, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %n.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %n.debug._guts._object._countAndFlagsBits._value, align 8
  %n.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %n.debug._guts._object._object, align 8
  call swiftcc void @"$s13CoreAIRuntime27InferenceFunctionDescriptorV05inputE02ofAA0C5ValueV0E0OSgSS_tF"(ptr noalias sret(%swift.opaque) %0, i64 %2, ptr %3, ptr noalias swiftself %1)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime27InferenceFunctionDescriptorV05inputE02ofAA0C5ValueV0E0OSgSS_tF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1, i64 %2, ptr %3) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %n.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %n.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %1, ptr %d.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %n.debug)
  %n.debug._guts = getelementptr inbounds nuw %TSS, ptr %n.debug, i32 0, i32 0
  %n.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %n.debug._guts, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %n.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %n.debug._guts._object._countAndFlagsBits._value, align 8
  %n.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %n.debug._guts._object._object, align 8
  call swiftcc void @"$s13CoreAIRuntime27InferenceFunctionDescriptorV06outputE02ofAA0C5ValueV0E0OSgSS_tF"(ptr noalias sret(%swift.opaque) %0, i64 %2, ptr %3, ptr noalias swiftself %1)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime27InferenceFunctionDescriptorV06outputE02ofAA0C5ValueV0E0OSgSS_tF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1, i64 %2, ptr %3) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %n.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %n.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %1, ptr %d.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %n.debug)
  %n.debug._guts = getelementptr inbounds nuw %TSS, ptr %n.debug, i32 0, i32 0
  %n.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %n.debug._guts, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %n.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %2, ptr %n.debug._guts._object._countAndFlagsBits._value, align 8
  %n.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 1
  store ptr %3, ptr %n.debug._guts._object._object, align 8
  call swiftcc void @"$s13CoreAIRuntime27InferenceFunctionDescriptorV05stateE02ofAA0C5ValueV0E0OSgSS_tF"(ptr noalias sret(%swift.opaque) %0, i64 %2, ptr %3, ptr noalias swiftself %1)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime27InferenceFunctionDescriptorV05stateE02ofAA0C5ValueV0E0OSgSS_tF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %d.debug3 = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug3, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %2 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17NDArrayDescriptorVMa"(i64 0) #4
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds ptr, ptr %3, i64 -1
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !51, !dereferenceable !52
  %5 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %5, align 8, !invariant.load !51
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  store ptr %6, ptr %d.debug, align 8
  %7 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime14InferenceValueV10DescriptorOMa"(i64 0) #4
  %8 = extractvalue %swift.metadata_response %7, 0
  %9 = getelementptr inbounds ptr, ptr %8, i64 -1
  %.valueWitnesses1 = load ptr, ptr %9, align 8, !invariant.load !51, !dereferenceable !52
  %10 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %10, align 8, !invariant.load !51
  %11 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  %12 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  store ptr %12, ptr %d.debug3, align 8
  br label %13

13:                                               ; preds = %entry
  %14 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 4
  %InitializeWithTake = load ptr, ptr %14, align 8, !invariant.load !51
  %15 = call ptr %InitializeWithTake(ptr noalias %12, ptr noalias %1, ptr %8) #5
  %16 = call ptr %InitializeWithTake(ptr noalias %11, ptr noalias %12, ptr %8) #5
  %17 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 11
  %GetEnumTag = load ptr, ptr %17, align 8, !invariant.load !51
  %18 = call i32 %GetEnumTag(ptr noalias %11, ptr %8) #5
  %19 = load i32, ptr @"$s13CoreAIRuntime14InferenceValueV10DescriptorO7ndArrayyAeA07NDArrayE0VcAEmFWC", align 4
  %20 = icmp eq i32 %18, %19
  br i1 %20, label %24, label %21

21:                                               ; preds = %13
  %22 = load i32, ptr @"$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC", align 4
  %23 = icmp eq i32 %18, %22
  br i1 %23, label %32, label %39

24:                                               ; preds = %13
  %25 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 12
  %DestructiveProjectEnumData7 = load ptr, ptr %25, align 8, !invariant.load !51
  call void %DestructiveProjectEnumData7(ptr noalias %11, ptr %8) #5
  %26 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 4
  %InitializeWithTake8 = load ptr, ptr %26, align 8, !invariant.load !51
  %27 = call ptr %InitializeWithTake8(ptr noalias %6, ptr noalias %11, ptr %3) #5
  store ptr %6, ptr %d.debug, align 8
  %28 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 2
  %InitializeWithCopy = load ptr, ptr %28, align 8, !invariant.load !51
  %29 = call ptr %InitializeWithCopy(ptr noalias %0, ptr noalias %6, ptr %3) #5
  %30 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload9 = load ptr, ptr %30, align 8, !invariant.load !51
  call void %StoreEnumTagSinglePayload9(ptr noalias %0, i32 0, i32 1, ptr %3) #5
  %31 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 1
  %Destroy10 = load ptr, ptr %31, align 8, !invariant.load !51
  call void %Destroy10(ptr noalias %6, ptr %3) #5
  br label %42

32:                                               ; preds = %21
  %33 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 12
  %DestructiveProjectEnumData = load ptr, ptr %33, align 8, !invariant.load !51
  call void %DestructiveProjectEnumData(ptr noalias %11, ptr %8) #5
  %34 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload4 = load ptr, ptr %34, align 8, !invariant.load !51
  call void %StoreEnumTagSinglePayload4(ptr noalias %0, i32 1, i32 1, ptr %3) #5
  %35 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime15ImageDescriptorVMa"(i64 0) #4
  %36 = extractvalue %swift.metadata_response %35, 0
  %37 = getelementptr inbounds ptr, ptr %36, i64 -1
  %.valueWitnesses5 = load ptr, ptr %37, align 8, !invariant.load !51, !dereferenceable !52
  %38 = getelementptr inbounds ptr, ptr %.valueWitnesses5, i32 1
  %Destroy6 = load ptr, ptr %38, align 8, !invariant.load !51
  call void %Destroy6(ptr noalias %11, ptr %36) #5
  br label %42

39:                                               ; preds = %21
  %40 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 7
  %StoreEnumTagSinglePayload = load ptr, ptr %40, align 8, !invariant.load !51
  call void %StoreEnumTagSinglePayload(ptr noalias %0, i32 1, i32 1, ptr %3) #5
  %41 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 1
  %Destroy = load ptr, ptr %41, align 8, !invariant.load !51
  call void %Destroy(ptr noalias %11, ptr %8) #5
  br label %42

42:                                               ; preds = %24, %32, %39
  call void @llvm.lifetime.end.p0(i64 -1, ptr %12)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %11)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %6)
  ret void
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17NDArrayDescriptorVMa"(i64) #1

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime14InferenceValueV10DescriptorOMa"(i64) #1

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime15ImageDescriptorVMa"(i64) #1

; Function Attrs: noinline
define swiftcc ptr @"$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF"(ptr noalias %0) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %0, ptr %d.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime17NDArrayDescriptorV5shapeSaySiGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime17NDArrayDescriptorV5shapeSaySiGvg"(ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1) #0 {
entry:
  %d.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %d.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  store ptr %1, ptr %d.debug, align 8
  call swiftcc void @"$s13CoreAIRuntime17NDArrayDescriptorV10scalarTypeAA0C0V06ScalarF0Ovg"(ptr noalias sret(%swift.opaque) %0, ptr noalias swiftself %1)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime17NDArrayDescriptorV10scalarTypeAA0C0V06ScalarF0Ovg"(ptr noalias sret(%swift.opaque), ptr noalias swiftself) #1

; Function Attrs: noinline
define swiftcc void @"$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF"(ptr %0, i64 %1, ptr %2) #0 {
entry:
  %array.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %array.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %n.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %n.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !53
  %views.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %views.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !53
  %3 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa"(i64 0) #4
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = getelementptr inbounds ptr, ptr %4, i64 -1
  %.valueWitnesses = load ptr, ptr %5, align 8, !invariant.load !51, !dereferenceable !52
  %6 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %6, align 8, !invariant.load !51
  %7 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %7)
  %8 = call swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa"(i64 0) #4
  %9 = extractvalue %swift.metadata_response %8, 0
  %10 = getelementptr inbounds ptr, ptr %9, i64 -1
  %.valueWitnesses1 = load ptr, ptr %10, align 8, !invariant.load !51, !dereferenceable !52
  %11 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %11, align 8, !invariant.load !51
  %12 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  store ptr %0, ptr %array.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %n.debug)
  %n.debug._guts = getelementptr inbounds nuw %TSS, ptr %n.debug, i32 0, i32 0
  %n.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %n.debug._guts, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 0
  %n.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %n.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %1, ptr %n.debug._guts._object._countAndFlagsBits._value, align 8
  %n.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %n.debug._guts._object, i32 0, i32 1
  store ptr %2, ptr %n.debug._guts._object._object, align 8
  store ptr %12, ptr %views.debug, align 8
  br label %13

13:                                               ; preds = %entry
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque) %12)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF"(ptr noalias sret(%swift.opaque) %7, ptr swiftself %0)
  call swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryAA7NDArrayV0E7RawViewVn_SStF"(ptr noalias %7, i64 %1, ptr %2, ptr swiftself %12)
  %14 = getelementptr inbounds ptr, ptr %.valueWitnesses1, i32 1
  %Destroy = load ptr, ptr %14, align 8, !invariant.load !51
  call void %Destroy(ptr noalias %12, ptr %9) #5
  call void @llvm.lifetime.end.p0(i64 -1, ptr %12)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %7)
  ret void
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa"(i64) #1

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa"(i64) #1

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC"(ptr noalias sret(%swift.opaque)) #1

declare swiftcc void @"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF"(ptr noalias sret(%swift.opaque), ptr swiftself) #1

declare swiftcc void @"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryAA7NDArrayV0E7RawViewVn_SStF"(ptr noalias, i64, ptr, ptr swiftself) #1

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nounwind memory(none) }
attributes #5 = { nounwind }

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
!13 = !{!"-framework", !"CoreAI"}
!14 = !{!"-lswiftCore"}
!15 = !{!"-lswift_StringProcessing"}
!16 = !{!"-lswift_Concurrency"}
!17 = !{!"-framework", !"CoreAIDelegates"}
!18 = !{!"-lswiftFoundation"}
!19 = !{!"-framework", !"Foundation"}
!20 = !{!"-lswift_DarwinFoundation3"}
!21 = !{!"-lswift_DarwinFoundation1"}
!22 = !{!"-lswift_Builtin_float"}
!23 = !{!"-lswift_DarwinFoundation2"}
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
!51 = !{}
!52 = !{i64 88}
!53 = !{!"true"}
