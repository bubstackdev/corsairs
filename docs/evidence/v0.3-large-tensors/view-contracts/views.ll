; ModuleID = '/private/tmp/corsairs-large-view-contracts/views.ll'
source_filename = "/private/tmp/corsairs-large-view-contracts/views.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.type = type { i64 }
%swift.metadata_response = type { ptr, i64 }
%swift.opaque = type opaque
%TSV = type <{ ptr }>

@"$sSVN" = external global %swift.type, align 8
@"$ss5NeverON" = external global %swift.type, align 8
@"$ss5NeverOs5ErrorsWP" = external global ptr, align 8
@"_swift_FORCE_LOAD_$_swiftFoundation_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_ViewAudit" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [13 x ptr] [ptr @"$s9ViewAudit10rawClosureySV13CoreAIRuntime7NDArrayVF", ptr @"$s9ViewAudit11mutableSpanySv_Sit13CoreAIRuntime7NDArrayVzF", ptr @"$s9ViewAudit14mutableClosureySv13CoreAIRuntime7NDArrayVzF", ptr @"$s9ViewAudit7rawSpanySV_Sit13CoreAIRuntime7NDArrayVF", ptr @__swift_reflection_version, ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_ViewAudit", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_ViewAudit"], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc { ptr, i64 } @"$s9ViewAudit11mutableSpanySv_Sit13CoreAIRuntime7NDArrayVzF"(ptr %0) #0 {
entry:
  %1 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa"(i64 0) #6
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds i8, ptr %2, i64 -8
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !50, !dereferenceable !51
  %4 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %4, align 8, !invariant.load !50
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %5)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF"(ptr noalias nonnull sret(%swift.opaque) %5, ptr swiftself %0)
  %6 = call swiftcc ptr @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV6_startSvyF"(ptr noalias nonnull swiftself %5)
  %7 = call swiftcc i64 @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV16storageByteCountSiyF"(ptr noalias nonnull swiftself %5)
  %8 = icmp slt i64 %7, 0
  br i1 %8, label %13, label %9, !prof !52

9:                                                ; preds = %entry
  %10 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %10, align 8, !invariant.load !50
  call void %Destroy(ptr noalias nonnull %5, ptr nonnull %2) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %5)
  %11 = insertvalue { ptr, i64 } undef, ptr %6, 0
  %12 = insertvalue { ptr, i64 } %11, i64 %7, 1
  ret { ptr, i64 } %12

13:                                               ; preds = %entry
  call void @llvm.trap() #8
  unreachable
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa"(i64) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #2

declare swiftcc void @"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF"(ptr noalias sret(%swift.opaque), ptr swiftself) local_unnamed_addr #1

declare swiftcc ptr @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV6_startSvyF"(ptr noalias swiftself) local_unnamed_addr #1

declare swiftcc i64 @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV16storageByteCountSiyF"(ptr noalias swiftself) local_unnamed_addr #1

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #2

; Function Attrs: noinline
define swiftcc ptr @"$s9ViewAudit14mutableClosureySv13CoreAIRuntime7NDArrayVzF"(ptr %0) #0 {
entry:
  %1 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa"(i64 0) #6
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds i8, ptr %2, i64 -8
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !50, !dereferenceable !51
  %4 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %4, align 8, !invariant.load !50
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %5)
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %6)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF"(ptr noalias nonnull sret(%swift.opaque) %6, ptr swiftself %0)
  %7 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 32
  %InitializeWithTake = load ptr, ptr %7, align 8, !invariant.load !50
  %8 = call ptr %InitializeWithTake(ptr noalias nonnull %5, ptr noalias nonnull %6, ptr %2) #7
  %9 = call swiftcc ptr @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV6_startSvyF"(ptr noalias nonnull swiftself %5)
  %10 = call swiftcc { i64, i64 } @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV5shapes4SpanVySiGvg"(ptr noalias nonnull swiftself %5)
  %11 = call swiftcc { i64, i64 } @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV7stridess4SpanVySiGvg"(ptr noalias nonnull swiftself %5)
  %12 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %12, align 8, !invariant.load !50
  call void %Destroy(ptr noalias nonnull %5, ptr %2) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %6)
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %5)
  ret ptr %9
}

declare swiftcc { i64, i64 } @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV5shapes4SpanVySiGvg"(ptr noalias swiftself) local_unnamed_addr #1

declare swiftcc { i64, i64 } @"$s13CoreAIRuntime7NDArrayV14MutableRawViewV7stridess4SpanVySiGvg"(ptr noalias swiftself) local_unnamed_addr #1

; Function Attrs: noinline
define swiftcc { ptr, i64 } @"$s9ViewAudit7rawSpanySV_Sit13CoreAIRuntime7NDArrayVF"(ptr noalias %0) #0 {
entry:
  %1 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV7RawViewVMa"(i64 0) #6
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds i8, ptr %2, i64 -8
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !50, !dereferenceable !51
  %4 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %4, align 8, !invariant.load !50
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %5)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF"(ptr noalias nonnull sret(%swift.opaque) %5, ptr noalias swiftself %0)
  %6 = call swiftcc { i64, i64 } @"$s13CoreAIRuntime7NDArrayV7RawViewV5bytess0D4SpanVvg"(ptr noalias nonnull swiftself %5)
  %7 = extractvalue { i64, i64 } %6, 0
  %8 = icmp eq i64 %7, 0
  br i1 %8, label %16, label %9

9:                                                ; preds = %entry
  %10 = extractvalue { i64, i64 } %6, 1
  %11 = inttoptr i64 %7 to ptr
  %12 = icmp sgt i64 %10, -1
  call void @llvm.assume(i1 %12)
  %13 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %13, align 8, !invariant.load !50
  call void %Destroy(ptr noalias nonnull %5, ptr nonnull %2) #7
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %5)
  %14 = insertvalue { ptr, i64 } undef, ptr %11, 0
  %15 = insertvalue { ptr, i64 } %14, i64 %10, 1
  ret { ptr, i64 } %15

16:                                               ; preds = %entry
  call void @llvm.trap() #8
  unreachable
}

declare swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV7RawViewVMa"(i64) local_unnamed_addr #1

declare swiftcc void @"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF"(ptr noalias sret(%swift.opaque), ptr noalias swiftself) local_unnamed_addr #1

declare swiftcc { i64, i64 } @"$s13CoreAIRuntime7NDArrayV7RawViewV5bytess0D4SpanVvg"(ptr noalias swiftself) local_unnamed_addr #1

; Function Attrs: noinline
define swiftcc ptr @"$s9ViewAudit10rawClosureySV13CoreAIRuntime7NDArrayVF"(ptr noalias %0) #0 {
entry:
  %1 = alloca %TSV, align 8
  %swifterror = alloca swifterror ptr, align 8
  store ptr null, ptr %swifterror, align 8
  %2 = tail call swiftcc %swift.metadata_response @"$s13CoreAIRuntime7NDArrayV7RawViewVMa"(i64 0) #6
  %3 = extractvalue %swift.metadata_response %2, 0
  %4 = getelementptr inbounds i8, ptr %3, i64 -8
  %.valueWitnesses = load ptr, ptr %4, align 8, !invariant.load !50, !dereferenceable !51
  %5 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 64
  %size = load i64, ptr %5, align 8, !invariant.load !50
  %6 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr nonnull %6)
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %1)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF"(ptr noalias nonnull sret(%swift.opaque) %6, ptr noalias swiftself %0)
  call swiftcc void @"$s13CoreAIRuntime7NDArrayV7RawViewV15withUnsafeBytesyxxSV_s4SpanVySiGAItq_YKXEq_YKs5ErrorR_r0_lF"(ptr noalias nonnull sret(%swift.opaque) %1, ptr nonnull @"$s9ViewAudit10rawClosureySV13CoreAIRuntime7NDArrayVFS2V_s4SpanVySiGAHtXEfU_", ptr null, ptr nonnull @"$sSVN", ptr nonnull @"$ss5NeverON", ptr nonnull @"$ss5NeverOs5ErrorsWP", ptr noalias nonnull swiftself %6, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %swifterror, ptr undef)
  %7 = getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 8
  %Destroy = load ptr, ptr %7, align 8, !invariant.load !50
  call void %Destroy(ptr noalias nonnull %6, ptr %3) #7
  %8 = load ptr, ptr %1, align 8
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %1)
  call void @llvm.lifetime.end.p0(i64 -1, ptr nonnull %6)
  ret ptr %8
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal swiftcc void @"$s9ViewAudit10rawClosureySV13CoreAIRuntime7NDArrayVFS2V_s4SpanVySiGAHtXEfU_"(ptr noalias writeonly sret(%TSV) captures(none) initializes((0, 8)) %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, ptr readnone swiftself captures(none) %6, ptr noalias readnone swifterror captures(none) dereferenceable(8) %7, ptr readnone captures(none) %8) #5 {
entry:
  store ptr %1, ptr %0, align 8
  ret void
}

declare swiftcc void @"$s13CoreAIRuntime7NDArrayV7RawViewV15withUnsafeBytesyxxSV_s4SpanVySiGAItq_YKXEq_YKs5ErrorR_r0_lF"(ptr noalias sret(%swift.opaque), ptr, ptr, ptr, ptr, ptr, ptr noalias swiftself, ptr noalias swifterror captures(none) dereferenceable(8), ptr) local_unnamed_addr #1

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
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { nounwind memory(none) }
attributes #7 = { nounwind }
attributes #8 = { nomerge }

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
!52 = !{!"branch_weights", !"expected", i32 1, i32 2000}
