; ModuleID = '/private/tmp/corsairs-suspend-gate/load-debug.ll'
source_filename = "/private/tmp/corsairs-suspend-gate/load-debug.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%swift.async_func_pointer = type <{ i32, i32 }>
%swift.type = type { i64 }
%"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame" = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr }
%swift.metadata_response = type { ptr, i64 }
%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%swift.opaque = type opaque
%TSS = type <{ %Ts11_StringGutsV }>
%Ts11_StringGutsV = type <{ %Ts13_StringObjectV }>
%Ts13_StringObjectV = type <{ %Ts6UInt64V, ptr }>
%Ts6UInt64V = type <{ i64 }>
%Ts4Int8V = type <{ i8 }>

@"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu" = global %swift.async_func_pointer <{ i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF" to i64), i64 ptrtoint (ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu" to i64)) to i32), i32 96 }>, section "__TEXT,__const", no_sanitize_address, align 8
@"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu" = external global %swift.async_func_pointer, align 8
@"$sSSN" = external global %swift.type, align 8
@"$ss4Int8VN" = external global %swift.type, align 8
@"_swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@__swift_async_entry_functlets = internal constant [1 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF" to i64), i64 ptrtoint (ptr @__swift_async_entry_functlets to i64)) to i32)], section "__TEXT,__swift_as_entry, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_ret_functlets = internal constant [1 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_" to i64), i64 ptrtoint (ptr @__swift_async_ret_functlets to i64)) to i32)], section "__TEXT,__swift_as_ret, coalesced, no_dead_strip", no_sanitize_address, align 4
@__swift_async_cont_functlets = internal constant [2 x i32] [i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_" to i64), i64 ptrtoint (ptr @__swift_async_cont_functlets to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_" to i64), i64 ptrtoint (ptr getelementptr inbounds ([2 x i32], ptr @__swift_async_cont_functlets, i32 0, i32 1) to i64)) to i32)], section "__TEXT,__swift_as_cont, coalesced, no_dead_strip", no_sanitize_address, align 4
@llvm.used = appending global [23 x ptr] [ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF", ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu", ptr @"$s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF", ptr @"$s11LoadGateABI10namesCountySiSaySSGF", ptr @"$s11LoadGateABI6nameAtySSSaySSG_SitF", ptr @"$s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF", ptr @"$s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF", ptr @"$s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF", ptr @"$s11LoadGateABI12consumeNamesyySaySSGnF", ptr @"$s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF", ptr @"$s11LoadGateABI13consumeStringyySSnF", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI", ptr @__swift_reflection_version, ptr @__swift_async_entry_functlets, ptr @__swift_async_ret_functlets, ptr @__swift_async_cont_functlets], section "llvm.metadata"

; Function Attrs: noinline
define swifttailcc void @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF"(ptr noalias %0, ptr swiftasync %1, ptr noalias %2) #0 {
entry:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %1, i32 16
  %3 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %url.debug = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.spill.addr10 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  store ptr %2, ptr %.spill.addr10, align 8
  %.spill.addr = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  store ptr %0, ptr %.spill.addr, align 8
  store ptr %1, ptr %3, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %url.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %4 = call swiftcc %swift.metadata_response @"$s15CoreAIDelegates21SpecializationOptionsVMa"(i64 0) #9
  %5 = extractvalue %swift.metadata_response %4, 0
  %6 = getelementptr inbounds ptr, ptr %5, i64 -1
  %.valueWitnesses = load ptr, ptr %6, align 8, !invariant.load !52, !dereferenceable !53
  %7 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses, i32 0, i32 8
  %size = load i64, ptr %7, align 8, !invariant.load !52
  %8 = add i64 %size, 15
  %9 = and i64 %8, -16
  %10 = call swiftcc ptr @swift_task_alloc(i64 %9) #4
  %.spill.addr13 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  store ptr %10, ptr %.spill.addr13, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %10)
  %11 = call swiftcc %swift.metadata_response @"$s10Foundation3URLVMa"(i64 0) #9
  %12 = extractvalue %swift.metadata_response %11, 0
  %.spill.addr22 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  store ptr %12, ptr %.spill.addr22, align 8
  %13 = getelementptr inbounds ptr, ptr %12, i64 -1
  %.valueWitnesses1 = load ptr, ptr %13, align 8, !invariant.load !52, !dereferenceable !53
  %.valueWitnesses1.spill.addr = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  store ptr %.valueWitnesses1, ptr %.valueWitnesses1.spill.addr, align 8
  %14 = getelementptr inbounds nuw %swift.vwtable, ptr %.valueWitnesses1, i32 0, i32 8
  %size2 = load i64, ptr %14, align 8, !invariant.load !52
  %15 = add i64 %size2, 15
  %16 = and i64 %15, -16
  %17 = call swiftcc ptr @swift_task_alloc(i64 %16) #4
  %.spill.addr25 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  store ptr %17, ptr %.spill.addr25, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %17)
  store ptr %2, ptr %url.debug, align 8
  call void asm sideeffect "", "r"(ptr %url.debug)
  %18 = load ptr, ptr %3, align 8
  %19 = load ptr, ptr %3, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %19, ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_", i64 0, i64 0) #7
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_"(ptr swiftasync %0) #1 {
entryresume.0:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %url.debug = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr32 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload33 = load ptr, ptr %.reload.addr32, align 8
  %.valueWitnesses1.reload.addr = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 6
  %.valueWitnesses1.reload = load ptr, ptr %.valueWitnesses1.reload.addr, align 8
  %.reload.addr23 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 5
  %.reload24 = load ptr, ptr %.reload.addr23, align 8
  %.reload.addr20 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload21 = load ptr, ptr %.reload.addr20, align 8
  %.reload.addr11 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 3
  %.reload12 = load ptr, ptr %.reload.addr11, align 8
  store ptr %0, ptr %1, align 8
  %2 = getelementptr inbounds ptr, ptr %.valueWitnesses1.reload, i32 2
  %InitializeWithCopy = load ptr, ptr %2, align 8, !invariant.load !52
  %3 = call ptr %InitializeWithCopy(ptr noalias %.reload33, ptr noalias %.reload12, ptr %.reload24) #7
  call swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ"(ptr noalias sret(%swift.opaque) %.reload21)
  %4 = load i32, ptr getelementptr inbounds nuw (%swift.async_func_pointer, ptr @"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu", i32 0, i32 1), align 4
  %5 = zext i32 %4 to i64
  %6 = call swiftcc ptr @swift_task_alloc(i64 %5) #4
  %.spill.addr34 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 8
  store ptr %6, ptr %.spill.addr34, align 8
  call void @llvm.lifetime.start.p0(i64 -1, ptr %6)
  %7 = load ptr, ptr %1, align 8
  %8 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %6, i32 0, i32 0
  store ptr %7, ptr %8, align 8
  %9 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %6, i32 0, i32 1
  store ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_", ptr %9, align 8
  %.reload.addr30 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload31 = load ptr, ptr %.reload.addr30, align 8
  %.reload.addr18 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload19 = load ptr, ptr %.reload.addr18, align 8
  %.reload.addr = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 2
  %.reload = load ptr, ptr %.reload.addr, align 8
  musttail call swifttailcc void @"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfC"(ptr noalias %.reload, ptr swiftasync %6, ptr noalias %.reload31, ptr noalias %.reload19) #7
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_"(ptr swiftasync %0, ptr swiftself %1) #2 {
entryresume.1:
  %2 = load ptr, ptr %0, align 8
  %3 = call ptr @llvm.swift.async.context.addr()
  store ptr %2, ptr %3, align 8
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %2, i32 16
  %4 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %url.debug = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr35 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 8
  %.reload36 = load ptr, ptr %.reload.addr35, align 8
  %5 = load ptr, ptr %0, align 8
  store ptr %5, ptr %4, align 8
  %.spill.addr37 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  store ptr %1, ptr %.spill.addr37, align 8
  call swiftcc void @swift_task_dealloc(ptr %.reload36) #4
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload36)
  %6 = icmp ne ptr %1, null
  %7 = ptrtoint ptr %1 to i64
  br i1 %6, label %CoroSuspend5, label %MustTailCall.Before.CoroEnd

MustTailCall.Before.CoroEnd:                      ; preds = %entryresume.1
  %.reload.addr26 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload27 = load ptr, ptr %.reload.addr26, align 8
  %.reload.addr14 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload15 = load ptr, ptr %.reload.addr14, align 8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload27)
  call swiftcc void @swift_task_dealloc(ptr %.reload27) #4
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload15)
  call swiftcc void @swift_task_dealloc(ptr %.reload15) #4
  %8 = load ptr, ptr %4, align 8
  %9 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %8, i32 0, i32 1
  %10 = load ptr, ptr %9, align 8
  %11 = load ptr, ptr %4, align 8
  musttail call swifttailcc void %10(ptr swiftasync %11, ptr swiftself null) #7
  ret void

CoroSuspend5:                                     ; preds = %entryresume.1
  %12 = phi ptr [ %1, %entryresume.1 ]
  %13 = load ptr, ptr %4, align 8
  musttail call swifttailcc void @swift_task_switch(ptr swiftasync %13, ptr @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_", i64 0, i64 0) #7
  ret void
}

; Function Attrs: noinline
define internal swifttailcc void @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_"(ptr swiftasync %0) #1 {
entryresume.2:
  %async.ctx.frameptr = getelementptr inbounds i8, ptr %0, i32 16
  %1 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 0
  %url.debug = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 1
  %.reload.addr28 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 7
  %.reload29 = load ptr, ptr %.reload.addr28, align 8
  %.reload.addr16 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 4
  %.reload17 = load ptr, ptr %.reload.addr16, align 8
  store ptr %0, ptr %1, align 8
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload29)
  call swiftcc void @swift_task_dealloc(ptr %.reload29) #4
  call void @llvm.lifetime.end.p0(i64 -1, ptr %.reload17)
  call swiftcc void @swift_task_dealloc(ptr %.reload17) #4
  %2 = load ptr, ptr %1, align 8
  %3 = getelementptr inbounds nuw <{ ptr, ptr }>, ptr %2, i32 0, i32 1
  %4 = load ptr, ptr %3, align 8
  %5 = load ptr, ptr %1, align 8
  %.reload.addr38 = getelementptr inbounds %"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF.Frame", ptr %async.ctx.frameptr, i32 0, i32 9
  %.reload39 = load ptr, ptr %.reload.addr38, align 8
  musttail call swifttailcc void %4(ptr swiftasync %5, ptr swiftself %.reload39) #7
  ret void
}

declare swiftcc %swift.metadata_response @"$s15CoreAIDelegates21SpecializationOptionsVMa"(i64) #3

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc ptr @swift_task_alloc(i64) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #5

declare swiftcc %swift.metadata_response @"$s10Foundation3URLVMa"(i64) #3

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #6

; Function Attrs: nounwind
declare swifttailcc void @swift_task_switch(ptr, ptr, i64, i64) #7

; Function Attrs: nounwind
declare ptr @llvm.swift.async.context.addr() #7

declare swiftcc void @"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ"(ptr noalias sret(%swift.opaque)) #3

declare swifttailcc void @"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfC"(ptr noalias, ptr swiftasync, ptr noalias, ptr noalias) #3

; Function Attrs: nounwind memory(inaccessiblemem: readwrite)
declare swiftcc void @swift_task_dealloc(ptr) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #5

; Function Attrs: noinline
define swiftcc ptr @"$s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF"(ptr noalias %0) #8 {
entry:
  %model.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %model.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %model.debug, align 8
  %1 = call swiftcc ptr @"$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg"(ptr noalias swiftself %0)
  ret ptr %1
}

declare swiftcc ptr @"$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg"(ptr noalias swiftself) #3

; Function Attrs: noinline
define swiftcc i64 @"$s11LoadGateABI10namesCountySiSaySSGF"(ptr %0) #8 {
entry:
  %names.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %names.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %names.debug, align 8
  %1 = call swiftcc i64 @"$sSa5countSivg"(ptr %0, ptr @"$sSSN")
  ret i64 %1
}

declare swiftcc i64 @"$sSa5countSivg"(ptr, ptr) #3

; Function Attrs: noinline
define swiftcc { i64, ptr } @"$s11LoadGateABI6nameAtySSSaySSG_SitF"(ptr %0, i64 %1) #8 {
entry:
  %names.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %names.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %index.debug = alloca i64, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %index.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = alloca %TSS, align 8
  store ptr %0, ptr %names.debug, align 8
  store i64 %1, ptr %index.debug, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr %2)
  call swiftcc void @"$sSayxSicig"(ptr noalias sret(%swift.opaque) %2, i64 %1, ptr %0, ptr @"$sSSN")
  %._guts = getelementptr inbounds nuw %TSS, ptr %2, i32 0, i32 0
  %._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %._guts, i32 0, i32 0
  %._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 0
  %._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %._guts._object._countAndFlagsBits, i32 0, i32 0
  %3 = load i64, ptr %._guts._object._countAndFlagsBits._value, align 8
  %._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %._guts._object, i32 0, i32 1
  %4 = load ptr, ptr %._guts._object._object, align 8
  call void @llvm.lifetime.end.p0(i64 16, ptr %2)
  %5 = insertvalue { i64, ptr } undef, i64 %3, 0
  %6 = insertvalue { i64, ptr } %5, ptr %4, 1
  ret { i64, ptr } %6
}

declare swiftcc void @"$sSayxSicig"(ptr noalias sret(%swift.opaque), i64, ptr, ptr) #3

; Function Attrs: noinline
define swiftcc ptr @"$s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF"(i64 %0, ptr %1) #8 {
entry:
  %string.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %string.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.lifetime.start.p0(i64 16, ptr %string.debug)
  %string.debug._guts = getelementptr inbounds nuw %TSS, ptr %string.debug, i32 0, i32 0
  %string.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %string.debug._guts, i32 0, i32 0
  %string.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %string.debug._guts._object, i32 0, i32 0
  %string.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %string.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %0, ptr %string.debug._guts._object._countAndFlagsBits._value, align 8
  %string.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %string.debug._guts._object, i32 0, i32 1
  store ptr %1, ptr %string.debug._guts._object._object, align 8
  %2 = call swiftcc ptr @"$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg"(i64 %0, ptr %1)
  ret ptr %2
}

declare swiftcc ptr @"$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg"(i64, ptr) #3

; Function Attrs: noinline
define swiftcc i64 @"$s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF"(ptr %0) #8 {
entry:
  %bytes.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %bytes.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %bytes.debug, align 8
  %1 = call swiftcc i64 @"$ss15ContiguousArrayV5countSivg"(ptr %0, ptr @"$ss4Int8VN")
  ret i64 %1
}

declare swiftcc i64 @"$ss15ContiguousArrayV5countSivg"(ptr, ptr) #3

; Function Attrs: noinline
define swiftcc i8 @"$s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF"(ptr %0, i64 %1) #8 {
entry:
  %bytes.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %bytes.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %index.debug = alloca i64, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %index.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  %2 = alloca %Ts4Int8V, align 1
  store ptr %0, ptr %bytes.debug, align 8
  store i64 %1, ptr %index.debug, align 8
  call void @llvm.lifetime.start.p0(i64 1, ptr %2)
  call swiftcc void @"$ss15ContiguousArrayVyxSicig"(ptr noalias sret(%swift.opaque) %2, i64 %1, ptr %0, ptr @"$ss4Int8VN")
  %._value = getelementptr inbounds nuw %Ts4Int8V, ptr %2, i32 0, i32 0
  %3 = load i8, ptr %._value, align 1
  call void @llvm.lifetime.end.p0(i64 1, ptr %2)
  ret i8 %3
}

declare swiftcc void @"$ss15ContiguousArrayVyxSicig"(ptr noalias sret(%swift.opaque), i64, ptr, ptr) #3

; Function Attrs: noinline
define swiftcc void @"$s11LoadGateABI12consumeNamesyySaySSGnF"(ptr %0) #8 {
entry:
  %names.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %names.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %names.debug, align 8
  call void @swift_bridgeObjectRelease(ptr %0) #7
  ret void
}

; Function Attrs: nounwind
declare void @swift_bridgeObjectRelease(ptr) #7

; Function Attrs: noinline
define swiftcc void @"$s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF"(ptr %0) #8 {
entry:
  %bytes.debug = alloca ptr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %bytes.debug, i8 0, i64 8, i1 false), !Swift.isSwiftLLDBpreinit !51
  store ptr %0, ptr %bytes.debug, align 8
  call void @swift_release(ptr %0) #7
  ret void
}

; Function Attrs: nounwind
declare void @swift_release(ptr) #7

; Function Attrs: noinline
define swiftcc void @"$s11LoadGateABI13consumeStringyySSnF"(i64 %0, ptr %1) #8 {
entry:
  %string.debug = alloca %TSS, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %string.debug, i8 0, i64 16, i1 false), !Swift.isSwiftLLDBpreinit !51
  call void @llvm.lifetime.start.p0(i64 16, ptr %string.debug)
  %string.debug._guts = getelementptr inbounds nuw %TSS, ptr %string.debug, i32 0, i32 0
  %string.debug._guts._object = getelementptr inbounds nuw %Ts11_StringGutsV, ptr %string.debug._guts, i32 0, i32 0
  %string.debug._guts._object._countAndFlagsBits = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %string.debug._guts._object, i32 0, i32 0
  %string.debug._guts._object._countAndFlagsBits._value = getelementptr inbounds nuw %Ts6UInt64V, ptr %string.debug._guts._object._countAndFlagsBits, i32 0, i32 0
  store i64 %0, ptr %string.debug._guts._object._countAndFlagsBits._value, align 8
  %string.debug._guts._object._object = getelementptr inbounds nuw %Ts13_StringObjectV, ptr %string.debug._guts._object, i32 0, i32 1
  store ptr %1, ptr %string.debug._guts._object._object, align 8
  call void @swift_bridgeObjectRelease(ptr %1) #7
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

attributes #0 = { noinline "async_entry" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { noinline "async_continuation" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { noinline "async_ret" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { nounwind memory(inaccessiblemem: readwrite) }
attributes #5 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #7 = { nounwind }
attributes #8 = { noinline "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { nounwind memory(none) }

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
