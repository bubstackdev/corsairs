; ModuleID = '/private/tmp/corsairs-load-options-v02/options.ll'
source_filename = "/private/tmp/corsairs-load-options-v02/options.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.opaque = type opaque
%swift.metadata_response = type { ptr, i64 }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }

@"$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC" = external constant i32, align 4
@"_swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [17 x ptr] [ptr @"$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF", ptr @"$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF", ptr @"$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF", ptr @"$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF", ptr @"$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF", ptr @"$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF", ptr @"$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF", ptr @"$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI", ptr @__swift_reflection_version], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc void @"$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF"(ptr %0, i1 %1) #0 {
entry:
  %options.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %options.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %enabled.debug = alloca i1, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %enabled.debug, i8 0, i64 1, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %options.debug, align 8
  store i1 %1, ptr %enabled.debug, align 8
  call swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvs"(i1 %1, ptr swiftself %0)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

declare swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvs"(i1, ptr swiftself) #2

; Function Attrs: noinline
define swiftcc i1 @"$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF"(ptr noalias %0) #0 {
entry:
  %options.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %options.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %options.debug, align 8
  %1 = call swiftcc i1 @"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvg"(ptr noalias swiftself %0)
  ret i1 %1
}

declare swiftcc i1 @"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvg"(ptr noalias swiftself) #2

; Function Attrs: noinline
define swiftcc void @"$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF"(ptr noalias sret(%swift.opaque) %0) #0 {
entry:
  call swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ"(ptr noalias sret(%swift.opaque) %0)
  ret void
}

declare swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ"(ptr noalias sret(%swift.opaque)) #2

; Function Attrs: noinline
define swiftcc void @"$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF"(ptr noalias sret(%swift.opaque) %0) #0 {
entry:
  %1 = call swiftcc %swift.metadata_response @"$s15CoreAIDelegates15ComputeUnitKindOMa"(i64 0) #4
  %2 = extractvalue %swift.metadata_response %1, 0
  %3 = getelementptr inbounds ptr, ptr %2, i64 -1
  %.valueWitnesses = load ptr, ptr %3, align 8, !invariant.load !52, !dereferenceable !53
  %4 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %4, align 8, !invariant.load !52
  %5 = alloca i8, i64 %size, align 16
  call void @llvm.lifetime.start.p0(i64 -1, ptr %5)
  %6 = load i32, ptr @"$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC", align 4
  %7 = getelementptr inbounds ptr, ptr %.valueWitnesses, i32 13
  %DestructiveInjectEnumTag = load ptr, ptr %7, align 8, !invariant.load !52
  call void %DestructiveInjectEnumTag(ptr noalias %5, i32 %6, ptr %2) #5
  call swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC"(ptr noalias sret(%swift.opaque) %0, ptr noalias %5)
  call void @llvm.lifetime.end.p0(i64 -1, ptr %5)
  ret void
}

declare swiftcc %swift.metadata_response @"$s15CoreAIDelegates15ComputeUnitKindOMa"(i64) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #3

declare swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC"(ptr noalias sret(%swift.opaque), ptr noalias) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #3

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
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
!51 = !{!"true"}
!52 = !{}
!53 = !{i64 88}
