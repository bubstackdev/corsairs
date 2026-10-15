; ModuleID = 'lowering.8a30a4d72ed4a1d2-cgu.0'
source_filename = "lowering.8a30a4d72ed4a1d2-cgu.0"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

; Function Attrs: nounwind uwtable
define void @call_aggregate3(ptr sret([24 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #0 !guid !4 {
start:
  %0 = alloca [24 x i8], align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %x, i64 24, i1 false)
  call swiftcc void @aggregate3(ptr sret([24 x i8]) align 8 %_0, ptr align 8 %0) #2
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @call_instance(i64 %x, ptr %context) unnamed_addr #0 !guid !5 {
start:
  %_0 = call swiftcc i64 @instance(i64 %x, ptr %context) #2
  ret i64 %_0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: nounwind uwtable
declare swiftcc void @aggregate3(ptr sret([24 x i8]) align 8, ptr align 8) unnamed_addr #0

; Function Attrs: nounwind uwtable
declare swiftcc i64 @instance(i64, ptr) unnamed_addr #0

attributes #0 = { nounwind uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"uwtable", i32 2}
!2 = !{i32 7, !"frame-pointer", i32 1}
!3 = !{!"rustc version 1.99.0 (b940084d7 2026-09-28) (Homebrew)"}
!4 = !{i64 5898677541142232637}
!5 = !{i64 -8562683903390882266}
