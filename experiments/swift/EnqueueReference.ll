; ModuleID = 'experiments/swift/EnqueueReference.ll'
source_filename = "experiments/swift/EnqueueReference.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.async_func_pointer = type <{ i32, i32 }>
%swift.full_boxmetadata = type { ptr, ptr, %swift.type, i32, ptr }
%swift.type = type { i64 }
%swift.full_existential_type = type { ptr, %swift.type }
%swift.metadata_response = type { ptr, i64 }
%swift.async_task_and_context = type { ptr, ptr }

@"symbolic ScPSg" = linkonce_odr hidden constant <{ [5 x i8], i8 }> <{ [5 x i8] c"ScPSg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$sScPSgMd" = linkonce_odr hidden global { ptr } zeroinitializer, align 8
@"$sScPSgMR" = linkonce_odr hidden constant { i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic ScPSg" to i64), i64 ptrtoint (ptr @"$sScPSgMR" to i64)) to i32), i32 5 }, align 8
@"$sIeghH_IeAgH_TRTu" = linkonce_odr hidden global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeghH_IeAgH_TR" to i64), i64 ptrtoint (ptr @"$sIeghH_IeAgH_TRTu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"symbolic ScA_pSg" = linkonce_odr hidden constant <{ [7 x i8], i8 }> <{ [7 x i8] c"ScA_pSg", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"symbolic IeghH_" = linkonce_odr hidden constant <{ [6 x i8], i8 }> <{ [6 x i8] c"IeghH_", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"\01l__swift5_reflection_descriptor" = private constant { i32, i32, i32, i32, i32 } { i32 2, i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic ScA_pSg" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic IeghH_" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor", i32 0, i32 4) to i64)) to i32) }, section "__TEXT,__swift5_capture, regular", no_sanitize_address, align 4
@metadata = private constant %swift.full_boxmetadata { ptr @__swift_closure_destructor, ptr null, %swift.type { i64 1024 }, i32 16, ptr @"\01l__swift5_reflection_descriptor" }, align 8
@"$sIeghH_IeAgH_TRTATu" = internal global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeghH_IeAgH_TRTA" to i64), i64 ptrtoint (ptr @"$sIeghH_IeAgH_TRTATu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$sIeAgH_ytIeAgHr_TRTu" = linkonce_odr hidden global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TR" to i64), i64 ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TRTu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"symbolic IeAgH_" = linkonce_odr hidden constant <{ [6 x i8], i8 }> <{ [6 x i8] c"IeAgH_", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"\01l__swift5_reflection_descriptor.2" = private constant { i32, i32, i32, i32, i32 } { i32 2, i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic ScA_pSg" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor.2", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic IeAgH_" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor.2", i32 0, i32 4) to i64)) to i32) }, section "__TEXT,__swift5_capture, regular", no_sanitize_address, align 4
@metadata.4 = private constant %swift.full_boxmetadata { ptr @__swift_closure_destructor.3, ptr null, %swift.type { i64 1024 }, i32 16, ptr @"\01l__swift5_reflection_descriptor.2" }, align 8
@"$sIeAgH_ytIeAgHr_TRTATu" = internal global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TRTA" to i64), i64 ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TRTATu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu" = linkonce_odr hidden global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5" to i64), i64 ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"symbolic ytIeAgHr_" = linkonce_odr hidden constant <{ [9 x i8], i8 }> <{ [9 x i8] c"ytIeAgHr_", i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"\01l__swift5_reflection_descriptor.6" = private constant { i32, i32, i32, i32 } { i32 1, i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic ytIeAgHr_" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32 }, ptr @"\01l__swift5_reflection_descriptor.6", i32 0, i32 3) to i64)) to i32) }, section "__TEXT,__swift5_capture, regular", no_sanitize_address, align 4
@metadata.8 = private constant %swift.full_boxmetadata { ptr @__swift_closure_destructor.7, ptr null, %swift.type { i64 1024 }, i32 16, ptr @"\01l__swift5_reflection_descriptor.6" }, align 8
@"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu" = internal global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TA" to i64), i64 ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu" to i64)) to i32), i32 32 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$sytN" = external global %swift.full_existential_type
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@__swift_async_entry_functlets = internal constant [3 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeghH_IeAgH_TR" to i64), i64 ptrtoint (ptr @__swift_async_entry_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TR" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_entry_functlets, i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_entry_functlets, i32 0, i32 2) to i64)) to i32)], section "__TEXT,__swift_as_entry, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_ret_functlets = internal constant [3 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeghH_IeAgH_TRTQ0_" to i64), i64 ptrtoint (ptr @__swift_async_ret_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TRTQ0_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_ret_functlets, i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([3 x i32], ptr @__swift_async_ret_functlets, i32 0, i32 2) to i64)) to i32)], section "__TEXT,__swift_as_ret, coalesced, no_dead_strip", no_sanitize_address, align 4
@llvm.used = appending global [8 x ptr] [ptr @"\01l__swift5_reflection_descriptor", ptr @"\01l__swift5_reflection_descriptor.2", ptr @"\01l__swift5_reflection_descriptor.6", ptr @"$s16EnqueueReference07enqueueB0yySv_ScetF", ptr @"$s16EnqueueReference08detachedB0yScTyyts5NeverOGyyYaYbcF", ptr @__swift_reflection_version, ptr @__swift_async_entry_functlets, ptr @__swift_async_ret_functlets], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc void @"$s16EnqueueReference07enqueueB0yySv_ScetF"(ptr %0, i64 %1, i64 %2) #0 {
entry:
  tail call swiftcc void @swift_task_enqueueTaskOnExecutor(ptr %0, i64 %1, i64 %2)
  ret void
}

declare swiftcc void @swift_task_enqueueTaskOnExecutor(ptr, i64, i64) local_unnamed_addr #1

; Function Attrs: noinline
define swiftcc ptr @"$s16EnqueueReference08detachedB0yScTyyts5NeverOGyyYaYbcF"(ptr %0, ptr %1) #0 {
entry:
  %2 = tail call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr nonnull @"$sScPSgMd", ptr nonnull @"$sScPSgMR") #14
  %3 = getelementptr inbounds i8, ptr %2, i64 -8
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !17, !dereferenceable !18
  %4 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %4, align 8, !invariant.load !17
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %5)
  %6 = tail call swiftcc %swift.metadata_response @"$sScPMa"(i64 0) #15
  %7 = extractvalue %swift.metadata_response %6, 0
  %8 = getelementptr inbounds i8, ptr %7, i64 -8
  %.valueWitnesses1 = load ptr, ptr %8, align 8, !invariant.load !17, !dereferenceable !18
  %9 = getelementptr inbounds nuw i8, ptr %.valueWitnesses1, i64 56
  %StoreEnumTagSinglePayload = load ptr, ptr %9, align 8, !invariant.load !17
  call void %StoreEnumTagSinglePayload(ptr noalias nonnull %5, i32 1, i32 1, ptr %7) #7
  %10 = call noalias ptr @swift_allocObject(ptr nonnull getelementptr inbounds nuw (i8, ptr @metadata, i64 16), i64 48, i64 7) #7
  %11 = getelementptr inbounds nuw i8, ptr %10, i64 16
  %12 = getelementptr inbounds nuw i8, ptr %10, i64 32
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %11, i8 0, i64 16, i1 false)
  store ptr %0, ptr %12, align 8
  %.data = getelementptr inbounds nuw i8, ptr %10, i64 40
  store ptr %1, ptr %.data, align 8
  %13 = call noalias ptr @swift_allocObject(ptr nonnull getelementptr inbounds nuw (i8, ptr @metadata.4, i64 16), i64 48, i64 7) #7
  %14 = getelementptr inbounds nuw i8, ptr %13, i64 16
  %15 = getelementptr inbounds nuw i8, ptr %13, i64 32
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %14, i8 0, i64 16, i1 false)
  store ptr @"$sIeghH_IeAgH_TRTATu", ptr %15, align 8
  %.data3 = getelementptr inbounds nuw i8, ptr %13, i64 40
  store ptr %10, ptr %.data3, align 8
  %16 = getelementptr inbounds nuw i8, ptr %.valueWitnesses1, i64 48
  %GetEnumTagSinglePayload = load ptr, ptr %16, align 8, !invariant.load !17
  %17 = call i32 %GetEnumTagSinglePayload(ptr noalias nonnull %5, i32 1, ptr %7) #14
  %.not = icmp eq i32 %17, 1
  %18 = call ptr @swift_retain(ptr returned %1) #16
  br i1 %.not, label %initial_serial_executor.cont, label %19

19:                                               ; preds = %entry
  %20 = call swiftcc i8 @"$sScP8rawValues5UInt8Vvg"(ptr noalias nonnull swiftself %5)
  %21 = zext i8 %20 to i64
  %22 = or disjoint i64 %21, 4096
  br label %initial_serial_executor.cont

initial_serial_executor.cont:                     ; preds = %entry, %19
  %23 = phi i64 [ %22, %19 ], [ 4096, %entry ]
  %24 = call noalias ptr @swift_allocObject(ptr nonnull getelementptr inbounds nuw (i8, ptr @metadata.8, i64 16), i64 32, i64 7) #7
  %25 = getelementptr inbounds nuw i8, ptr %24, i64 16
  store ptr @"$sIeAgH_ytIeAgHr_TRTATu", ptr %25, align 8
  %.data5 = getelementptr inbounds nuw i8, ptr %24, i64 24
  store ptr %13, ptr %.data5, align 8
  %26 = call swiftcc %swift.async_task_and_context @swift_task_create(i64 %23, ptr null, ptr nonnull getelementptr inbounds nuw (i8, ptr @"$sytN", i64 8), ptr nonnull @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu", ptr nonnull %24) #14
  %27 = extractvalue %swift.async_task_and_context %26, 0
  %28 = call ptr @"$sScPSgWOh"(ptr nonnull %5)
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %5)
  ret ptr %27
}

; Function Attrs: mustprogress nofree noinline nounwind willreturn memory(read)
define linkonce_odr hidden ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr %0, ptr %1) local_unnamed_addr #2 {
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
  %17 = tail call swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr %16, i64 %12, ptr null, ptr null) #17
  store atomic ptr %17, ptr %0 monotonic, align 8
  br label %8
}

; Function Attrs: nounwind memory(argmem: readwrite)
declare swiftcc ptr @swift_getTypeByMangledNameInContext2(ptr, i64, ptr, ptr) local_unnamed_addr #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #4

declare swiftcc %swift.metadata_response @"$sScPMa"(i64) local_unnamed_addr #1

; Function Attrs: noinline
define linkonce_odr hidden swifttailcc void @"$sIeghH_IeAgH_TR"(ptr swiftasync %0, i64 %1, i64 %2, ptr %3, ptr %4) #5 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %0, i64 16
  %5 = load i32, ptr %3, align 8
  %6 = sext i32 %5 to i64
  %7 = ptrtoint ptr %3 to i64
  %8 = add i64 %6, %7
  %9 = inttoptr i64 %8 to ptr
  %10 = getelementptr inbounds nuw i8, ptr %3, i64 4
  %11 = load i32, ptr %10, align 4
  %12 = zext i32 %11 to i64
  %13 = tail call swiftcc ptr @swift_task_alloc(i64 %12) #8
  store ptr %13, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %13)
  store ptr %0, ptr %13, align 8
  %14 = getelementptr inbounds nuw i8, ptr %13, i64 8
  store ptr @"$sIeghH_IeAgH_TRTQ0_", ptr %14, align 8
  musttail call swifttailcc void %9(ptr nonnull swiftasync %13, ptr swiftself %4) #7
  ret void
}

; Function Attrs: nounwind
define internal swiftcc void @__swift_closure_destructor(ptr swiftself %0) #6 {
  tail call swiftcc void @__swift_closure_destructorTm(ptr swiftself %0) #6
  ret void
}

; Function Attrs: nounwind
declare void @swift_unknownObjectRelease(ptr) local_unnamed_addr #7

; Function Attrs: nounwind
declare void @swift_release(ptr) local_unnamed_addr #7

; Function Attrs: nounwind
declare void @swift_deallocObject(ptr, i64, i64) local_unnamed_addr #7

; Function Attrs: nounwind
declare ptr @swift_allocObject(ptr, i64, i64) local_unnamed_addr #7

define internal swifttailcc void @"$sIeghH_IeAgH_TRTA"(ptr swiftasync initializes((16, 24)) %0, ptr readonly swiftself captures(none) %1) #1 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %0, i64 16
  %2 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %3 = load i64, ptr %2, align 8
  %4 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %5 = load i64, ptr %4, align 8
  %6 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %7 = load ptr, ptr %6, align 8
  %.data = getelementptr inbounds nuw i8, ptr %1, i64 40
  %8 = load ptr, ptr %.data, align 8
  %9 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$sIeghH_IeAgH_TRTu", i64 4), align 4
  %10 = zext i32 %9 to i64
  %11 = tail call swiftcc ptr @swift_task_alloc(i64 %10) #8
  store ptr %11, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %11)
  store ptr %0, ptr %11, align 8
  %12 = getelementptr inbounds nuw i8, ptr %11, i64 8
  store ptr @"$sIeghH_IeAgH_TRTATQ0_", ptr %12, align 8
  %13 = load i32, ptr @"$sIeghH_IeAgH_TRTu", align 8
  %14 = sext i32 %13 to i64
  %15 = add i64 %14, ptrtoint (ptr @"$sIeghH_IeAgH_TRTu" to i64)
  %16 = inttoptr i64 %15 to ptr
  musttail call swifttailcc void %16(ptr nonnull swiftasync %11, i64 %3, i64 %5, ptr %7, ptr %8) #7
  ret void
}

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc ptr @swift_task_alloc(i64) local_unnamed_addr #8

; Function Attrs: nounwind
declare ptr @llvm.swift.async.context.addr() #7

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc void @swift_task_dealloc(ptr) local_unnamed_addr #8

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #4

; Function Attrs: noinline
define linkonce_odr hidden swifttailcc void @"$sIeAgH_ytIeAgHr_TR"(ptr noalias captures(none) %0, ptr swiftasync %1, i64 %2, i64 %3, ptr %4, ptr %5) #5 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %6 = load i32, ptr %4, align 8
  %7 = sext i32 %6 to i64
  %8 = ptrtoint ptr %4 to i64
  %9 = add i64 %7, %8
  %10 = inttoptr i64 %9 to ptr
  %11 = getelementptr inbounds nuw i8, ptr %4, i64 4
  %12 = load i32, ptr %11, align 4
  %13 = zext i32 %12 to i64
  %14 = tail call swiftcc ptr @swift_task_alloc(i64 %13) #8
  store ptr %14, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %14)
  store ptr %1, ptr %14, align 8
  %15 = getelementptr inbounds nuw i8, ptr %14, i64 8
  store ptr @"$sIeAgH_ytIeAgHr_TRTQ0_", ptr %15, align 8
  musttail call swifttailcc void %10(ptr nonnull swiftasync %14, ptr swiftself %5) #7
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$sIeAgH_ytIeAgHr_TRTQ0_"(ptr readonly swiftasync captures(none) %0) #9 {
entryresume.0:
  %1 = load ptr, ptr %0, align 8
  %2 = tail call ptr @llvm.swift.async.context.addr()
  store ptr %1, ptr %2, align 8
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %.reload = load ptr, ptr %async.ctx.frameptr, align 8
  %3 = load ptr, ptr %0, align 8
  tail call swiftcc void @swift_task_dealloc(ptr nonnull %.reload) #8
  tail call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %.reload)
  %4 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %5 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %5(ptr swiftasync %3) #7
  ret void
}

; Function Attrs: nounwind
define internal swiftcc void @__swift_closure_destructorTm(ptr swiftself %0) #6 {
entry:
  %1 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %2 = load ptr, ptr %1, align 8
  tail call void @swift_unknownObjectRelease(ptr %2) #7
  %.data = getelementptr inbounds nuw i8, ptr %0, i64 40
  %3 = load ptr, ptr %.data, align 8
  tail call void @swift_release(ptr %3) #7
  tail call void @swift_deallocObject(ptr %0, i64 48, i64 7) #7
  ret void
}

define internal swifttailcc void @"$sIeAgH_ytIeAgHr_TRTA"(ptr noalias captures(none) %0, ptr swiftasync initializes((16, 24)) %1, ptr readonly swiftself captures(none) %2) #1 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %3 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %4 = load i64, ptr %3, align 8
  %5 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %6 = load i64, ptr %5, align 8
  %7 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %8 = load ptr, ptr %7, align 8
  %.data = getelementptr inbounds nuw i8, ptr %2, i64 40
  %9 = load ptr, ptr %.data, align 8
  %10 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$sIeAgH_ytIeAgHr_TRTu", i64 4), align 4
  %11 = zext i32 %10 to i64
  %12 = tail call swiftcc ptr @swift_task_alloc(i64 %11) #8
  store ptr %12, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  store ptr %1, ptr %12, align 8
  %13 = getelementptr inbounds nuw i8, ptr %12, i64 8
  store ptr @"$sIeAgH_ytIeAgHr_TRTATQ0_", ptr %13, align 8
  %14 = load i32, ptr @"$sIeAgH_ytIeAgHr_TRTu", align 8
  %15 = sext i32 %14 to i64
  %16 = add i64 %15, ptrtoint (ptr @"$sIeAgH_ytIeAgHr_TRTu" to i64)
  %17 = inttoptr i64 %16 to ptr
  musttail call swifttailcc void %17(ptr noalias captures(none) %0, ptr nonnull swiftasync %12, i64 %4, i64 %6, ptr %8, ptr %9) #7
  ret void
}

define internal swifttailcc void @"$sIeAgH_ytIeAgHr_TRTATQ0_"(ptr readonly swiftasync captures(none) %0) #1 {
entryresume.0:
  %1 = load ptr, ptr %0, align 8
  %2 = tail call ptr @llvm.swift.async.context.addr()
  store ptr %1, ptr %2, align 8
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %.reload = load ptr, ptr %async.ctx.frameptr, align 8
  %3 = load ptr, ptr %0, align 8
  tail call swiftcc void @swift_task_dealloc(ptr nonnull %.reload) #8
  tail call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %.reload)
  %4 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %5 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %5(ptr swiftasync %3) #7
  ret void
}

; Function Attrs: mustprogress nounwind willreturn
declare ptr @swift_retain(ptr returned) local_unnamed_addr #10

; Function Attrs: noinline
define linkonce_odr hidden swifttailcc void @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5"(ptr noalias captures(none) %0, ptr swiftasync %1, ptr %2, ptr %3) #5 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %4 = load i32, ptr %2, align 8
  %5 = sext i32 %4 to i64
  %6 = ptrtoint ptr %2 to i64
  %7 = add i64 %5, %6
  %8 = inttoptr i64 %7 to ptr
  %9 = getelementptr inbounds nuw i8, ptr %2, i64 4
  %10 = load i32, ptr %9, align 4
  %11 = zext i32 %10 to i64
  %12 = tail call swiftcc ptr @swift_task_alloc(i64 %11) #8
  store ptr %12, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %12)
  store ptr %1, ptr %12, align 8
  %13 = getelementptr inbounds nuw i8, ptr %12, i64 8
  store ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_", ptr %13, align 8
  musttail call swifttailcc void %8(ptr noalias captures(none) %0, ptr nonnull swiftasync %12, ptr swiftself %3) #7
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_"(ptr readonly swiftasync captures(none) %0) #9 {
entryresume.0:
  %1 = load ptr, ptr %0, align 8
  %2 = tail call ptr @llvm.swift.async.context.addr()
  store ptr %1, ptr %2, align 8
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %.reload = load ptr, ptr %async.ctx.frameptr, align 8
  %3 = load ptr, ptr %0, align 8
  tail call swiftcc void @swift_task_dealloc(ptr nonnull %.reload) #8
  tail call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %.reload)
  %4 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %5 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %5(ptr swiftasync %3, ptr swiftself null) #7
  ret void
}

; Function Attrs: nounwind
define internal swiftcc void @__swift_closure_destructor.7(ptr swiftself %0) #6 {
entry:
  %.data = getelementptr inbounds nuw i8, ptr %0, i64 24
  %1 = load ptr, ptr %.data, align 8
  tail call void @swift_release(ptr %1) #7
  tail call void @swift_deallocObject(ptr %0, i64 32, i64 7) #7
  ret void
}

define internal swifttailcc void @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TA"(ptr noalias captures(none) %0, ptr swiftasync initializes((16, 24)) %1, ptr readonly swiftself captures(none) %2) #1 {
coro.return:
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %1, i64 16
  %3 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %4 = load ptr, ptr %3, align 8
  %.data = getelementptr inbounds nuw i8, ptr %2, i64 24
  %5 = load ptr, ptr %.data, align 8
  %6 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu", i64 4), align 4
  %7 = zext i32 %6 to i64
  %8 = tail call swiftcc ptr @swift_task_alloc(i64 %7) #8
  store ptr %8, ptr %async.ctx.frameptr, align 8
  tail call void @llvm.lifetime.start.p0(i64 -1, ptr %8)
  store ptr %1, ptr %8, align 8
  %9 = getelementptr inbounds nuw i8, ptr %8, i64 8
  store ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_", ptr %9, align 8
  %10 = load i32, ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu", align 8
  %11 = sext i32 %10 to i64
  %12 = add i64 %11, ptrtoint (ptr @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu" to i64)
  %13 = inttoptr i64 %12 to ptr
  musttail call swifttailcc void %13(ptr noalias captures(none) %0, ptr nonnull swiftasync %8, ptr %4, ptr %5) #7
  ret void
}

define internal swifttailcc void @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_"(ptr readonly swiftasync captures(none) %0, ptr swiftself %1) #1 {
entryresume.0:
  %2 = load ptr, ptr %0, align 8
  %3 = tail call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds nuw i8, ptr %2, i64 16
  %.reload = load ptr, ptr %async.ctx.frameptr, align 8
  %4 = load ptr, ptr %0, align 8
  tail call swiftcc void @swift_task_dealloc(ptr nonnull %.reload) #8
  tail call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %.reload)
  %5 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %6 = load ptr, ptr %5, align 8
  musttail call swifttailcc void %6(ptr swiftasync %4, ptr swiftself %1) #7
  ret void
}

; Function Attrs: nofree nounwind memory(read)
declare swiftcc %swift.async_task_and_context @swift_task_create(i64, ptr, ptr, ptr, ptr) local_unnamed_addr #11

; Function Attrs: noinline nounwind
define linkonce_odr hidden ptr @"$sScPSgWOh"(ptr %0) local_unnamed_addr #12 {
entry:
  %1 = tail call ptr @__swift_instantiateConcreteTypeFromMangledNameV2(ptr nonnull @"$sScPSgMd", ptr nonnull @"$sScPSgMR") #14
  %2 = getelementptr inbounds i8, ptr %1, i64 -8
  %.valueWitnesses = load ptr, ptr %2, align 8, !invariant.load !17, !dereferenceable !18
  %3 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %3, align 8, !invariant.load !17
  tail call void %Destroy(ptr noalias %0, ptr %1) #7
  ret ptr %0
}

declare swiftcc i8 @"$sScP8rawValues5UInt8Vvg"(ptr noalias swiftself) local_unnamed_addr #1

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #13

; Function Attrs: noinline
define internal swifttailcc void @"$sIeghH_IeAgH_TRTQ0_"(ptr readonly swiftasync captures(none) %0) #9 {
  musttail call swifttailcc void @"$sIeAgH_ytIeAgHr_TRTQ0_"(ptr readonly swiftasync captures(none) %0) #9
  ret void
}

define internal swifttailcc void @"$sIeghH_IeAgH_TRTATQ0_"(ptr readonly swiftasync captures(none) %0) #1 {
  musttail call swifttailcc void @"$sIeAgH_ytIeAgHr_TRTATQ0_"(ptr readonly swiftasync captures(none) %0) #1
  ret void
}

; Function Attrs: nounwind
define internal swiftcc void @__swift_closure_destructor.3(ptr swiftself %0) #6 {
  tail call swiftcc void @__swift_closure_destructor(ptr swiftself %0) #6
  ret void
}

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { mustprogress nofree noinline nounwind willreturn memory(read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { nounwind memory(argmem: readwrite) }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { noinline "async_entry" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #7 = { nounwind }
attributes #8 = { nounwind memory(inaccessiblemem: readwrite) }
attributes #9 = { noinline "async_ret" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #10 = { mustprogress nounwind willreturn }
attributes #11 = { nofree nounwind memory(read) }
attributes #12 = { noinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #13 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #14 = { nounwind memory(read) }
attributes #15 = { nounwind memory(none) }
attributes #16 = { nounwind willreturn }
attributes #17 = { nounwind memory(argmem: read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16}

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
!13 = !{!"-lswift_Concurrency"}
!14 = !{!"-lswiftCore"}
!15 = !{!"-lswift_StringProcessing"}
!16 = !{!"-lobjc"}
!17 = !{}
!18 = !{i64 88}
