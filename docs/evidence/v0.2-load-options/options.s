	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF ; -- Begin function $s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF
	.p2align	2
_$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF: ; @"$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	str	xzr, [sp, #8]
	strb	wzr, [sp]
	mov	x0, x20
	str	x0, [sp, #8]
	and	w8, w1, #0x1
	and	w8, w8, #0x1
	strb	w8, [sp]
	and	w0, w1, #0x1
	bl	_$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvs
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF ; -- Begin function $s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF
	.p2align	2
_$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF: ; @"$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	str	xzr, [sp, #8]
	mov	x0, x20
	str	x0, [sp, #8]
	bl	_$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvg
	and	w0, w0, #0x1
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF ; -- Begin function $s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF
	.p2align	2
_$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF: ; @"$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF ; -- Begin function $s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF
	.p2align	2
_$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF: ; @"$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	sub	sp, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x8, [x29, #-16]                 ; 8-byte Folded Spill
	mov	x0, #0                          ; =0x0
	bl	_$s15CoreAIDelegates15ComputeUnitKindOMa
	mov	x2, x0
	ldur	x8, [x2, #-8]
	ldr	x9, [x8, #64]
	lsr	x9, x9, #0
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	stur	x9, [x29, #-24]                 ; 8-byte Folded Spill
Lloh0:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh1:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x10, [x29, #-24]                ; 8-byte Folded Reload
	mov	x9, sp
	subs	x0, x9, x10
	stur	x0, [x29, #-8]                  ; 8-byte Folded Spill
	mov	sp, x0
	adrp	x9, _$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC@GOTPAGE
	ldr	x9, [x9, _$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC@GOTPAGEOFF]
	ldr	w1, [x9]
	ldr	x8, [x8, #104]
	blr	x8
	ldur	x8, [x29, #-16]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-8]                  ; 8-byte Folded Reload
	bl	_$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC
	mov	sp, x29
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI"
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI:
	.quad	__swift_FORCE_LOAD_$_swiftMetal

	.private_extern	___swift_reflection_version ; @__swift_reflection_version
	.section	__TEXT,__const
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3                               ; 0x3

	.no_dead_strip	_$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF
	.no_dead_strip	_$s14LoadOptionsABI19setFrequentReshapesyy15CoreAIDelegates014SpecializationB0Vz_SbtF
	.no_dead_strip	_$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF
	.no_dead_strip	_$s14LoadOptionsABI16frequentReshapesySb15CoreAIDelegates014SpecializationB0VF
	.no_dead_strip	_$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF
	.no_dead_strip	_$s14LoadOptionsABI03cpuB015CoreAIDelegates014SpecializationB0VyF
	.no_dead_strip	_$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF
	.no_dead_strip	_$s14LoadOptionsABI03gpuB015CoreAIDelegates014SpecializationB0VyF
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadOptionsABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_LoadOptionsABI
	.no_dead_strip	___swift_reflection_version
	.linker_option "-framework", "CoreAI"
	.linker_option "-lswiftCore"
	.linker_option "-lswift_StringProcessing"
	.linker_option "-lswift_Concurrency"
	.linker_option "-framework", "CoreAIDelegates"
	.linker_option "-lswiftFoundation"
	.linker_option "-framework", "Foundation"
	.linker_option "-lswift_DarwinFoundation3"
	.linker_option "-lswift_DarwinFoundation1"
	.linker_option "-lswift_Builtin_float"
	.linker_option "-lswift_DarwinFoundation2"
	.linker_option "-lswiftSystem"
	.linker_option "-lswiftDarwin"
	.linker_option "-lswiftObservation"
	.linker_option "-lswiftObjectiveC"
	.linker_option "-lswiftCoreFoundation"
	.linker_option "-framework", "CoreFoundation"
	.linker_option "-lswiftDispatch"
	.linker_option "-framework", "Combine"
	.linker_option "-framework", "CoreServices"
	.linker_option "-framework", "Security"
	.linker_option "-lswiftXPC"
	.linker_option "-framework", "CFNetwork"
	.linker_option "-framework", "DiskArbitration"
	.linker_option "-lswiftIOKit"
	.linker_option "-framework", "IOKit"
	.linker_option "-framework", "CoreAIRuntime"
	.linker_option "-lswiftMetal"
	.linker_option "-framework", "Metal"
	.linker_option "-framework", "IOSurface"
	.linker_option "-framework", "CoreVideo"
	.linker_option "-framework", "CoreGraphics"
	.linker_option "-framework", "OpenGL"
	.linker_option "-framework", "CoreAICommon"
	.linker_option "-framework", "CoreAICompiler"
	.linker_option "-framework", "CoreAIAsset"
	.linker_option "-lswiftSwiftOnoneSupport"
	.linker_option "-lobjc"
	.section	__DATA,__objc_imageinfo,regular,no_dead_strip
L_OBJC_IMAGE_INFO:
	.long	0
	.long	100927296

	.weak_reference __swift_FORCE_LOAD_$_swiftFoundation
	.weak_reference __swift_FORCE_LOAD_$_swift_Builtin_float
	.weak_reference __swift_FORCE_LOAD_$_swiftObjectiveC
	.weak_reference __swift_FORCE_LOAD_$_swiftCoreFoundation
	.weak_reference __swift_FORCE_LOAD_$_swiftDispatch
	.weak_reference __swift_FORCE_LOAD_$_swiftXPC
	.weak_reference __swift_FORCE_LOAD_$_swiftIOKit
	.weak_reference __swift_FORCE_LOAD_$_swiftMetal
.subsections_via_symbols
