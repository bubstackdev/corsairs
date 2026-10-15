; ModuleID = '/private/tmp/corsairs-throwing-ndwdx2v2/string.ll'
source_filename = "/private/tmp/corsairs-throwing-ndwdx2v2/string.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.opaque = type opaque

@"_swift_FORCE_LOAD_$_swiftFoundation_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_StringABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [12 x ptr] [ptr @"$s9StringABI04makeA0ySSSPys4Int8VGF", ptr @"$s9StringABI04makeA0ySSSPys4Int8VGF", ptr @"$s9StringABI11makeFileURLy10Foundation0E0VSPys4Int8VGF", ptr @"$s9StringABI11makeFileURLy10Foundation0E0VSPys4Int8VGF", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_StringABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_StringABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_StringABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_StringABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_StringABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_StringABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_StringABI", ptr @__swift_reflection_version], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc { i64, ptr } @"$s9StringABI04makeA0ySSSPys4Int8VGF"(ptr %0) #0 {
entry:
  %bytes.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %bytes.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !39
  store ptr %0, ptr %bytes.debug, align 8
  %1 = call swiftcc { i64, ptr } @"$sSS7cStringSSSPys4Int8VG_tcfC"(ptr %0)
  %2 = extractvalue { i64, ptr } %1, 0
  %3 = extractvalue { i64, ptr } %1, 1
  %4 = insertvalue { i64, ptr } undef, i64 %2, 0
  %5 = insertvalue { i64, ptr } %4, ptr %3, 1
  ret { i64, ptr } %5
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

declare swiftcc { i64, ptr } @"$sSS7cStringSSSPys4Int8VG_tcfC"(ptr) #2

; Function Attrs: noinline
define swiftcc void @"$s9StringABI11makeFileURLy10Foundation0E0VSPys4Int8VGF"(ptr noalias sret(%swift.opaque) %0, ptr %1) #0 {
entry:
  %bytes.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %bytes.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !39
  store ptr %1, ptr %bytes.debug, align 8
  %2 = call swiftcc { i64, ptr } @"$sSS7cStringSSSPys4Int8VG_tcfC"(ptr %1)
  %3 = extractvalue { i64, ptr } %2, 0
  %4 = extractvalue { i64, ptr } %2, 1
  call swiftcc void @"$s10Foundation3URLV15fileURLWithPathACSSh_tcfC"(ptr noalias sret(%swift.opaque) %0, i64 %3, ptr %4)
  call void @swift_bridgeObjectRelease(ptr %4) #3
  ret void
}

declare swiftcc void @"$s10Foundation3URLV15fileURLWithPathACSSh_tcfC"(ptr noalias sret(%swift.opaque), i64, ptr) #2

; Function Attrs: nounwind
declare void @swift_bridgeObjectRelease(ptr) #3

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38}

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
!37 = !{!"-lswiftSwiftOnoneSupport"}
!38 = !{!"-lobjc"}
!39 = !{!"true"}
