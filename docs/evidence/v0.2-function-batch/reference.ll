; ModuleID = 'docs/evidence/v0.2-function-batch/reference.ll'
source_filename = "docs/evidence/v0.2-function-batch/reference.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.async_func_pointer = type <{ i32, i32 }>
%swift.type_descriptor = type opaque
%swift.full_boxmetadata = type { ptr, ptr, %swift.type, i32, ptr }
%swift.type = type { i64 }
%swift.opaque = type opaque
%swift.serial_executor_task_option = type { %swift.task_option, %swift.executor }
%swift.task_option = type { i64, ptr }
%swift.executor = type { i64, i64 }
%swift.metadata_response = type { ptr, i64 }
%swift.async_task_and_context = type { ptr, ptr }

@"symbolic ScPSg" = linkonce_odr hidden constant <{ [5 x i8], i8 }> <{ [5 x i8] c"ScPSg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sScPSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$sScPSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic ScPSg" to i64), i64 ptrtoint (ptr @"$sScPSgMR" to i64)) to i32), i32 5 }, align 8
@"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu" = internal global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_" to i64), i64 ptrtoint (ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu" to i64)) to i32), i32 48 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"symbolic ScA_pSg" = linkonce_odr hidden constant <{ [7 x i8], i8 }> <{ [7 x i8] c"ScA_pSg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s13CoreAIRuntime7AIModelVMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime7AIModelVMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime7AIModelVMn"
@"symbolic _____ 13CoreAIRuntime7AIModelV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime7AIModelVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 13CoreAIRuntime7AIModelV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"symbolic SS" = linkonce_odr hidden constant <{ [2 x i8], i8 }> <{ [2 x i8] c"SS", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"\01l__swift5_reflection_descriptor" = private constant { i32, i32, i32, i32, i32, i32 } { i32 3, i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic ScA_pSg" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 13CoreAIRuntime7AIModelV" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor", i32 0, i32 4) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic SS" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor", i32 0, i32 5) to i64)) to i32) }, section "__TEXT,__swift5_capture, regular", no_sanitize_address, align 4
@metadata = private constant %swift.full_boxmetadata { ptr @__swift_closure_destructor, ptr null, %swift.type { i64 1024 }, i32 16, ptr @"\01l__swift5_reflection_descriptor" }, align 8
@"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu" = internal global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TA" to i64), i64 ptrtoint (ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime17InferenceFunctionVMn" = external global %swift.type_descriptor, align 4
@"got.$s13CoreAIRuntime17InferenceFunctionVMn" = private unnamed_addr constant ptr @"$s13CoreAIRuntime17InferenceFunctionVMn"
@"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV" = linkonce_odr hidden constant <{ i8, i32, [2 x i8], i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$s13CoreAIRuntime17InferenceFunctionVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, [2 x i8], i8 }>, ptr @"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV", i32 0, i32 1) to i64)) to i32), [2 x i8] c"Sg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s13CoreAIRuntime17InferenceFunctionVSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$s13CoreAIRuntime17InferenceFunctionVSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV" to i64), i64 ptrtoint (ptr @"$s13CoreAIRuntime17InferenceFunctionVSgMR" to i64)) to i32), i32 7 }, align 8
@"_swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@__swift_async_entry_functlets = internal constant [1 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_" to i64), i64 ptrtoint (ptr @__swift_async_entry_functlets to i64)) to i32)], section "__TEXT,__swift_as_entry, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_cont_functlets = internal constant [1 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_" to i64), i64 ptrtoint (ptr @__swift_async_cont_functlets to i64)) to i32)], section "__TEXT,__swift_as_cont, coalesced, no_dead_strip", no_sanitize_address, align 4
@llvm.used = appending global [15 x ptr] [ptr @"\01l__swift5_reflection_descriptor", ptr @"$s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF", ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF", ptr @"$s16FunctionBatchABI26verifySendableConformancesyyF", ptr @__swift_reflection_version, ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI", ptr @__swift_async_entry_functlets, ptr @__swift_async_cont_functlets], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc void @"$s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF"(ptr noalias sret(%swift.opaque) %0, ptr noalias %1, i64 %2, ptr %3, ptr readnone swiftself captures(none) %4, ptr noalias swifterror captures(none) dereferenceable(8) %5) #0 {
entry:
  tail call swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque) %0, i64 %2, ptr %3, ptr noalias swiftself %1, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %5)
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr noalias swiftself, ptr noalias swifterror captures(none) dereferenceable(8)) local_unnamed_addr #1

; Function Attrs: noinline
define swiftcc ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF"(ptr noalias %0, i64 %1, ptr %2) #0 {
entry:
  %initial_serial_executor_record = alloca %swift.serial_executor_task_option, align 8
  %3 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7AIModelVMa"(i64 0) #15
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = getelementptr inbounds i8, ptr %4, i64 -8
  %.valueWitnesses = load ptr, ptr %5, align 8, !invariant.load !50, !dereferenceable !51
  %6 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %6, align 8, !invariant.load !50
  %7 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %7)
  %8 = tail call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr nonnull @"$sScPSgMd", ptr nonnull @"$sScPSgMR") #16
  %9 = getelementptr inbounds i8, ptr %8, i64 -8
  %.valueWitnesses1 = load ptr, ptr %9, align 8, !invariant.load !50, !dereferenceable !51
  %10 = getelementptr inbounds nuw i8, ptr %.valueWitnesses1, i64 64
  %size2 = load i64, ptr %10, align 8, !invariant.load !50
  %11 = alloca i8, i64 %size2, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %11)
  %12 = tail call swiftcc %swift.metadata_response @"$sScPMa"(i64 0) #15
  %13 = extractvalue %swift.metadata_response %12, 0
  %14 = getelementptr inbounds i8, ptr %13, i64 -8
  %.valueWitnesses3 = load ptr, ptr %14, align 8, !invariant.load !50, !dereferenceable !51
  %15 = getelementptr inbounds nuw i8, ptr %.valueWitnesses3, i64 56
  %StoreEnumTagSinglePayload = load ptr, ptr %15, align 8, !invariant.load !50
  call void %StoreEnumTagSinglePayload(ptr noalias nonnull %11, i32 1, i32 1, ptr %13) #7
  %16 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 16
  %InitializeWithCopy = load ptr, ptr %16, align 8, !invariant.load !50
  %17 = call ptr %InitializeWithCopy(ptr noalias nonnull %7, ptr noalias %0, ptr %4) #7
  %18 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 80
  %flags = load i32, ptr %18, align 8, !invariant.load !50
  %19 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %19 to i64
  %20 = xor i64 %flags.alignmentMask, -1
  %21 = add nuw nsw i64 %flags.alignmentMask, 32
  %22 = and i64 %21, %20
  %23 = or i64 %flags.alignmentMask, 7
  %24 = add i64 %size, 7
  %25 = add i64 %24, %22
  %26 = and i64 %25, -8
  %27 = add i64 %26, 16
  %28 = call noalias ptr @swift_allocObject(ptr nonnull getelementptr inbounds nuw (i8, ptr @metadata, i64 16), i64 %27, i64 %23) #7
  %29 = getelementptr inbounds nuw i8, ptr %28, i64 16
  %30 = getelementptr inbounds nuw i8, ptr %28, i64 24
  %31 = getelementptr inbounds nuw i8, ptr %28, i64 %22
  %32 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 32
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %29, i8 0, i64 16, i1 false)
  %InitializeWithTake = load ptr, ptr %32, align 8, !invariant.load !50
  %33 = call ptr %InitializeWithTake(ptr noalias %31, ptr noalias nonnull %7, ptr %4) #7
  %34 = getelementptr inbounds i8, ptr %28, i64 %26
  store i64 %1, ptr %34, align 8
  %._guts._object._object = getelementptr inbounds nuw i8, ptr %34, i64 8
  store ptr %2, ptr %._guts._object._object, align 8
  %35 = getelementptr inbounds nuw i8, ptr %.valueWitnesses3, i64 48
  %GetEnumTagSinglePayload = load ptr, ptr %35, align 8, !invariant.load !50
  %36 = call i32 %GetEnumTagSinglePayload(ptr noalias nonnull %11, i32 1, ptr %13) #16
  %.not = icmp eq i32 %36, 1
  %37 = call ptr @swift_bridgeObjectRetain(ptr returned %2) #7
  br i1 %.not, label %42, label %38

38:                                               ; preds = %entry
  %39 = call swiftcc i8 @"$sScP8rawValues5UInt8Vvg"(ptr noalias nonnull swiftself %11)
  %40 = zext i8 %39 to i64
  %41 = or disjoint i64 %40, 4096
  br label %42

42:                                               ; preds = %entry, %38
  %43 = phi i64 [ %41, %38 ], [ 4096, %entry ]
  %44 = load i64, ptr %29, align 8
  %45 = icmp eq i64 %44, 0
  br i1 %45, label %54, label %46

46:                                               ; preds = %42
  %47 = load i64, ptr %30, align 8
  %48 = inttoptr i64 %44 to ptr
  %49 = inttoptr i64 %47 to ptr
  %.Type = call ptr @swift_getObjectType(ptr nonnull %48) #17
  %50 = call ptr @swift_unknownObjectRetain(ptr nonnull returned %48) #7
  %51 = call swiftcc { i64, i64 } @"$sScA15unownedExecutorScevgTj"(ptr nonnull swiftself %48, ptr %.Type, ptr %49)
  call void @swift_unknownObjectRelease(ptr nonnull %48) #7
  %52 = extractvalue { i64, i64 } %51, 0
  %53 = extractvalue { i64, i64 } %51, 1
  br label %54

54:                                               ; preds = %42, %46
  %55 = phi i64 [ %52, %46 ], [ 0, %42 ]
  %56 = phi i64 [ %53, %46 ], [ 0, %42 ]
  %57 = call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr nonnull @"$s13CoreAIRuntime17InferenceFunctionVSgMd", ptr nonnull @"$s13CoreAIRuntime17InferenceFunctionVSgMR") #16
  %58 = or i64 %56, %55
  %59 = icmp eq i64 %58, 0
  br i1 %59, label %initial_serial_executor.cont, label %initial_serial_executor.some

initial_serial_executor.some:                     ; preds = %54
  %60 = getelementptr inbounds nuw i8, ptr %initial_serial_executor_record, i64 16
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %initial_serial_executor_record, i8 0, i64 16, i1 false)
  store i64 %55, ptr %60, align 8
  %61 = getelementptr inbounds nuw i8, ptr %initial_serial_executor_record, i64 24
  store i64 %56, ptr %61, align 8
  br label %initial_serial_executor.cont

initial_serial_executor.cont:                     ; preds = %initial_serial_executor.some, %54
  %62 = phi ptr [ null, %54 ], [ %initial_serial_executor_record, %initial_serial_executor.some ]
  %63 = call swiftcc %swift.async_task_and_context @swift_task_create(i64 %43, ptr %62, ptr %57, ptr nonnull @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu", ptr nonnull %28) #16
  %64 = extractvalue %swift.async_task_and_context %63, 0
  %65 = call ptr @"$sScPSgWOh"(ptr nonnull %11)
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %11)
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %7)
  ret ptr %64
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7AIModelVMa"(i64) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: mustprogress nofree noinline nounwind willreturn memory(read)
define linkonce_odr hidden ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr %0, ptr %1) local_unnamed_addr #3 {
entry:
  %2 = load atomic ptr, ptr %0 monotonic, align 8
  %3 = icmp eq ptr %2, null
  %4 = ptrtoint ptr %2 to i64
  %5 = and i64 %4, 1
  %6 = icmp ne i64 %5, 0
  %7 = or i1 %3, %6
  br i1 %7, label %10, label %8

8:                                                ; preds = %10, %entry
  %9 = phi ptr [ %2, %entry ], [ %17, %10 ]
  ret ptr %9

10:                                               ; preds = %entry
  %11 = load i64, ptr %1, align 8
  %12 = ashr i64 %11, 32
  %sext = shl i64 %11, 32
  %13 = ashr exact i64 %sext, 32
  %14 = ptrtoint ptr %1 to i64
  %15 = add i64 %13, %14
  %16 = inttoptr i64 %15 to ptr
  %17 = tail call swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr %16, i64 %12, ptr null, ptr null) #18
  store atomic ptr %17, ptr %0 monotonic, align 8
  br label %8
}

; Function Attrs: nounwind memory(argmem: readwrite)
declare swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr, i64, ptr, ptr) local_unnamed_addr #4

declare swiftcc %swift.metadata_response @"$sScPMa"(i64) local_unnamed_addr #1

; Function Attrs: noinline nounwind
define internal swifttailcc void @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_"(ptr noalias %0, ptr swiftasync initializes((16, 48)) %1, i64 %2, i64 %3, ptr noalias %4, i64 %5, ptr %6) #5 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %.spill.addr14 = getelementptr inbounds nuw i8, ptr %1, i64 40
  store ptr %6, ptr %.spill.addr14, align 8
  %.spill.addr11 = getelementptr inbounds nuw i8, ptr %1, i64 32
  store i64 %5, ptr %.spill.addr11, align 8
  %.spill.addr8 = getelementptr inbounds nuw i8, ptr %1, i64 24
  store ptr %4, ptr %.spill.addr8, align 8
  store ptr %0, ptr %async.ctx.frameptr, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %1, ptr nonnull @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_", i64 0, i64 0) #7
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_"(ptr swiftasync %0) #6 {
entryresume.0:
  %1 = alloca swifterror ptr, align 8
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %0, i64 16
  %.reload.addr15 = getelementptr inbounds nuw i8, ptr %0, i64 40
  %.reload16 = load ptr, ptr %.reload.addr15, align 8
  %.reload.addr12 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %.reload13 = load i64, ptr %.reload.addr12, align 8
  %.reload.addr9 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %.reload10 = load ptr, ptr %.reload.addr9, align 8
  %.reload = load ptr, ptr %async.ctx.frameptr, align 8
  store ptr null, ptr %1, align 8
  call swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque) %.reload, i64 %.reload13, ptr %.reload16, ptr noalias swiftself %.reload10, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %1)
  %2 = load ptr, ptr %1, align 8
  %.not = icmp eq ptr %2, null
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %4 = load ptr, ptr %3, align 8
  br i1 %.not, label %AfterMustTailCall.Before.CoroEnd, label %AfterMustTailCall.Before.CoroEnd7

AfterMustTailCall.Before.CoroEnd:                 ; preds = %entryresume.0
  musttail call swifttailcc void %4(ptr nonnull swiftasync %0, ptr swiftself null) #7
  ret void

AfterMustTailCall.Before.CoroEnd7:                ; preds = %entryresume.0
  musttail call swifttailcc void %4(ptr nonnull swiftasync %0, ptr nonnull swiftself %2) #7
  ret void
}

define internal swiftcc void @__swift_closure_destructor(ptr swiftself %0) #1 {
entry:
  %1 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7AIModelVMa"(i64 0) #15
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds i8, ptr %2, i64 -8
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !50, !dereferenceable !51
  %4 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 80
  %flags = load i32, ptr %4, align 8, !invariant.load !50
  %5 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %5 to i64
  %6 = xor i64 %flags.alignmentMask, -1
  %7 = add nuw nsw i64 %flags.alignmentMask, 32
  %8 = and i64 %7, %6
  %9 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %9, align 8, !invariant.load !50
  %10 = or i64 %flags.alignmentMask, 7
  %11 = add i64 %size, 7
  %12 = add i64 %11, %8
  %13 = and i64 %12, -8
  %14 = add i64 %13, 16
  %15 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %16 = load ptr, ptr %15, align 8
  tail call void @swift_unknownObjectRelease(ptr %16) #7
  %17 = getelementptr inbounds nuw i8, ptr %0, i64 %8
  %18 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %18, align 8, !invariant.load !50
  tail call void %Destroy(ptr noalias %17, ptr %2) #7
  %19 = getelementptr inbounds i8, ptr %0, i64 %13
  %._guts._object._object = getelementptr inbounds nuw i8, ptr %19, i64 8
  %toDestroy = load ptr, ptr %._guts._object._object, align 8
  tail call void @swift_bridgeObjectRelease(ptr %toDestroy) #7
  tail call void @swift_deallocObject(ptr %0, i64 %14, i64 %10) #7
  ret void
}

; Function Attrs: nounwind
declare void @swift_unknownObjectRelease(ptr) local_unnamed_addr #7

; Function Attrs: nounwind
declare void @swift_bridgeObjectRelease(ptr) local_unnamed_addr #7

; Function Attrs: nounwind
declare void @swift_deallocObject(ptr, i64, i64) local_unnamed_addr #7

; Function Attrs: nounwind
declare ptr @swift_allocObject(ptr, i64, i64) local_unnamed_addr #7

; Function Attrs: nounwind
define internal swifttailcc void @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TA"(ptr noalias %0, ptr swiftasync initializes((16, 24)) %1, ptr swiftself %2) #8 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %3 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7AIModelVMa"(i64 0) #15
  %4 = extractvalue %swift.metadata_response %3, 0
  %5 = getelementptr inbounds i8, ptr %4, i64 -8
  %.valueWitnesses = load ptr, ptr %5, align 8, !invariant.load !50, !dereferenceable !51
  %6 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 80
  %flags = load i32, ptr %6, align 8, !invariant.load !50
  %7 = and i32 %flags, 255
  %flags.alignmentMask = zext nneg i32 %7 to i64
  %8 = xor i64 %flags.alignmentMask, -1
  %9 = add nuw nsw i64 %flags.alignmentMask, 32
  %10 = and i64 %9, %8
  %11 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %11, align 8, !invariant.load !50
  %12 = add i64 %size, 7
  %13 = add i64 %12, %10
  %14 = and i64 %13, -8
  %15 = getelementptr inbounds nuw i8, ptr %2, i64 %10
  %16 = getelementptr inbounds i8, ptr %2, i64 %14
  %17 = load i64, ptr %16, align 8
  %._guts._object._object = getelementptr inbounds nuw i8, ptr %16, i64 8
  %18 = load ptr, ptr %._guts._object._object, align 8
  %19 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu", i64 4), align 4
  %20 = zext i32 %19 to i64
  %21 = tail call swiftcc ptr @swift_task_alloc(i64 %20) #9
  store ptr %21, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %21)
  store ptr %1, ptr %21, align 8
  %22 = getelementptr inbounds nuw i8, ptr %21, i64 8
  store ptr @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_", ptr %22, align 8
  musttail call swifttailcc void @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_"(ptr noalias %0, ptr nonnull swiftasync %21, i64 poison, i64 poison, ptr noalias %15, i64 %17, ptr %18) #7
  ret void
}

define internal swifttailcc void @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_"(ptr readonly swiftasync captures(none) %0, ptr swiftself %1) #1 {
entryresume.0:
  %2 = load ptr, ptr %0, align 8
  %3 = tail call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %2, i64 16
  %.reload = load ptr, ptr %async.ctx.frameptr, align 8
  %4 = load ptr, ptr %0, align 8
  tail call swiftcc void @swift_task_dealloc(ptr nonnull %.reload) #9
  tail call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %.reload)
  %5 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %6 = load ptr, ptr %5, align 8
  musttail call swifttailcc void %6(ptr swiftasync %4, ptr swiftself %1) #7
  ret void
}

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc ptr @swift_task_alloc(i64) local_unnamed_addr #9

; Function Attrs: nounwind
declare ptr @llvm.swift.async.context.addr() #7

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc void @swift_task_dealloc(ptr) local_unnamed_addr #9

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: nounwind
declare ptr @swift_bridgeObjectRetain(ptr returned) local_unnamed_addr #7

; Function Attrs: nofree nounwind memory(read)
declare swiftcc %swift.async_task_and_context @swift_task_create(i64, ptr, ptr, ptr, ptr) local_unnamed_addr #10

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$sScPSgWOh"(ptr %0) local_unnamed_addr #11 {
entry:
  %1 = tail call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr nonnull @"$sScPSgMd", ptr nonnull @"$sScPSgMR") #16
  %2 = getelementptr inbounds i8, ptr %1, i64 -8
  %.valueWitnesses = load ptr, ptr %2, align 8, !invariant.load !50, !dereferenceable !51
  %3 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %3, align 8, !invariant.load !50
  tail call void %Destroy(ptr noalias %0, ptr %1) #7
  ret ptr %0
}

; Function Attrs: mustprogress nofree nounwind willreturn memory(read)
declare ptr @swift_getObjectType(ptr) local_unnamed_addr #12

declare swiftcc { i64, i64 } @"$sScA15unownedExecutorScevgTj"(ptr swiftself, ptr, ptr) local_unnamed_addr #1

; Function Attrs: nounwind
declare ptr @swift_unknownObjectRetain(ptr returned) local_unnamed_addr #7

declare swiftcc i8 @"$sScP8rawValues5UInt8Vvg"(ptr noalias swiftself) local_unnamed_addr #1

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc void @"$s16FunctionBatchABI26verifySendableConformancesyyF"() #13 {
entry:
  ret void
}

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

; Function Attrs: nounwind
declare swifttailcc void @swift_task_switch(ptr, ptr, i64, i64) local_unnamed_addr #7

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #14

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress nofree noinline nounwind willreturn memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { nounwind memory(argmem: readwrite) }
attributes #5 = { noinline nounwind "async_entry" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { noinline "async_continuation" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #7 = { nounwind }
attributes #8 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { nounwind memory(inaccessiblemem: readwrite) }
attributes #10 = { nofree nounwind memory(read) }
attributes #11 = { noinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #12 = { mustprogress nofree nounwind willreturn memory(read) }
attributes #13 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #14 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #15 = { nounwind memory(none) }
attributes #16 = { nounwind memory(read) }
attributes #17 = { nounwind willreturn memory(read) }
attributes #18 = { nounwind memory(argmem: read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49}

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
!49 = !{!"-lobjc"}
!50 = !{}
!51 = !{i64 88}
