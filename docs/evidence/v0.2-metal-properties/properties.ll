; ModuleID = '/private/tmp/corsairs-metal-properties/properties.ll'
source_filename = "/private/tmp/corsairs-metal-properties/properties.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%TSo14MTLStorageModeV = type { i64 }
%TSu = type <{ i64 }>
%TSo22MTLCommandBufferStatusV = type { i64 }

@"_swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [17 x ptr] [ptr @"$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF", ptr @"$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF", ptr @"$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF", ptr @"$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF", ptr @"$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF", ptr @"$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF", ptr @"$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF", ptr @"$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI", ptr @__swift_reflection_version], section "llvm.metadata"

; Function Attrs: noinline
define swiftcc ptr @"$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF"(ptr %0) #0 {
entry:
  %queue.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %queue.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !42
  store ptr %0, ptr %queue.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #2
  %1 = call ptr @swift_unknownObjectRetain(ptr returned %0) #3
  %2 = call ptr @"objc_msgSend$device"(ptr %0, ptr undef)
  call void asm sideeffect "mov\09fp, fp\09\09// marker for objc_retainAutoreleaseReturnValue", ""()
  %3 = call ptr @llvm.objc.retainAutoreleasedReturnValue(ptr %2)
  call void @swift_unknownObjectRelease(ptr %0) #3
  ret ptr %3
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

; Function Attrs: nounwind willreturn memory(read)
declare ptr @swift_getObjectType(ptr) #2

; Function Attrs: nounwind
declare ptr @swift_unknownObjectRetain(ptr returned) #3

declare void @objc_msgSend()

declare void @"objc_msgSend$device"()

; Function Attrs: nounwind
declare ptr @llvm.objc.retainAutoreleasedReturnValue(ptr) #3

; Function Attrs: nounwind
declare void @swift_unknownObjectRelease(ptr) #3

; Function Attrs: noinline
define swiftcc ptr @"$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF"(ptr %0) #0 {
entry:
  %buffer.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %buffer.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !42
  store ptr %0, ptr %buffer.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #2
  %1 = call ptr @swift_unknownObjectRetain(ptr returned %0) #3
  %2 = call ptr @"objc_msgSend$device"(ptr %0, ptr undef)
  call void asm sideeffect "mov\09fp, fp\09\09// marker for objc_retainAutoreleaseReturnValue", ""()
  %3 = call ptr @llvm.objc.retainAutoreleasedReturnValue(ptr %2)
  call void @swift_unknownObjectRelease(ptr %0) #3
  ret ptr %3
}

; Function Attrs: noinline
define swiftcc i64 @"$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF"(ptr %0) #0 {
entry:
  %buffer.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %buffer.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !42
  store ptr %0, ptr %buffer.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #2
  %1 = call ptr @swift_unknownObjectRetain(ptr returned %0) #3
  %2 = call i64 @"objc_msgSend$storageMode"(ptr %0, ptr undef)
  call void @swift_unknownObjectRelease(ptr %0) #3
  %3 = call swiftcc i64 @"$sSo14MTLStorageModeV8rawValueSuvg"(i64 %2)
  ret i64 %3
}

declare void @"objc_msgSend$storageMode"()

define linkonce_odr hidden swiftcc i64 @"$sSo14MTLStorageModeV8rawValueSuvg"(i64 %0) #4 {
entry:
  %self.debug = alloca i64, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %self.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !42
  %bitcast = alloca %TSo14MTLStorageModeV, align 8
  store i64 %0, ptr %self.debug, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr %bitcast)
  %1 = getelementptr inbounds nuw %TSo14MTLStorageModeV, ptr %bitcast, i32 0, i32 0
  store i64 %0, ptr %1, align 8
  %bitcast._value = getelementptr inbounds nuw %TSu, ptr %bitcast, i32 0, i32 0
  %2 = load i64, ptr %bitcast._value, align 8
  call void @llvm.lifetime.end.p0(i64 8, ptr %bitcast)
  ret i64 %2
}

; Function Attrs: noinline
define swiftcc i64 @"$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF"(ptr %0) #0 {
entry:
  %command.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %command.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !42
  store ptr %0, ptr %command.debug, align 8
  %.Type = call ptr @swift_getObjectType(ptr %0) #2
  %1 = call ptr @swift_unknownObjectRetain(ptr returned %0) #3
  %2 = call i64 @"objc_msgSend$status"(ptr %0, ptr undef)
  call void @swift_unknownObjectRelease(ptr %0) #3
  %3 = call swiftcc i64 @"$sSo22MTLCommandBufferStatusV8rawValueSuvg"(i64 %2)
  ret i64 %3
}

declare void @"objc_msgSend$status"()

define linkonce_odr hidden swiftcc i64 @"$sSo22MTLCommandBufferStatusV8rawValueSuvg"(i64 %0) #4 {
entry:
  %self.debug = alloca i64, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %self.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !42
  %bitcast = alloca %TSo22MTLCommandBufferStatusV, align 8
  store i64 %0, ptr %self.debug, align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr %bitcast)
  %1 = getelementptr inbounds nuw %TSo22MTLCommandBufferStatusV, ptr %bitcast, i32 0, i32 0
  store i64 %0, ptr %1, align 8
  %bitcast._value = getelementptr inbounds nuw %TSu, ptr %bitcast, i32 0, i32 0
  %2 = load i64, ptr %bitcast._value, align 8
  call void @llvm.lifetime.end.p0(i64 8, ptr %bitcast)
  ret i64 %2
}

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #5

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #5

attributes #0 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #2 = { nounwind willreturn memory(read) }
attributes #3 = { nounwind }
attributes #4 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41}

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
!40 = !{!"-lswiftSwiftOnoneSupport"}
!41 = !{!"-lobjc"}
!42 = !{!"true"}
