	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s11BFloat16ABI14bfloat16Scalar13CoreAIRuntime7NDArrayV0D4TypeOyF ; -- Begin function $s11BFloat16ABI14bfloat16Scalar13CoreAIRuntime7NDArrayV0D4TypeOyF
	.p2align	2
_$s11BFloat16ABI14bfloat16Scalar13CoreAIRuntime7NDArrayV0D4TypeOyF: ; @"$s11BFloat16ABI14bfloat16Scalar13CoreAIRuntime7NDArrayV0D4TypeOyF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	adrp	x8, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC@GOTPAGEOFF]
	ldr	w8, [x8]
	str	w8, [sp, #4]                    ; 4-byte Folded Spill
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa
	ldr	w1, [sp, #4]                    ; 4-byte Folded Reload
	mov	x2, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	ldur	x8, [x2, #-8]
	ldr	x8, [x8, #104]
	blr	x8
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11BFloat16ABI26float16ScalarForComparison13CoreAIRuntime7NDArrayV0D4TypeOyF ; -- Begin function $s11BFloat16ABI26float16ScalarForComparison13CoreAIRuntime7NDArrayV0D4TypeOyF
	.p2align	2
_$s11BFloat16ABI26float16ScalarForComparison13CoreAIRuntime7NDArrayV0D4TypeOyF: ; @"$s11BFloat16ABI26float16ScalarForComparison13CoreAIRuntime7NDArrayV0D4TypeOyF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	adrp	x8, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float16yA2EmFWC@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float16yA2EmFWC@GOTPAGEOFF]
	ldr	w8, [x8]
	str	w8, [sp, #4]                    ; 4-byte Folded Spill
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa
	ldr	w1, [sp, #4]                    ; 4-byte Folded Reload
	mov	x2, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	ldur	x8, [x2, #-8]
	ldr	x8, [x8, #104]
	blr	x8
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11BFloat16ABI13bfloat16Arrayy13CoreAIRuntime7NDArrayVSaySiGnF ; -- Begin function $s11BFloat16ABI13bfloat16Arrayy13CoreAIRuntime7NDArrayVSaySiGnF
	.p2align	2
_$s11BFloat16ABI13bfloat16Arrayy13CoreAIRuntime7NDArrayVSaySiGnF: ; @"$s11BFloat16ABI13bfloat16Arrayy13CoreAIRuntime7NDArrayVSaySiGnF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	sub	sp, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x8, [x29, #-24]                 ; 8-byte Folded Spill
	stur	x0, [x29, #-32]                 ; 8-byte Folded Spill
	stur	xzr, [x29, #-8]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa
	mov	x2, x0
	ldur	x8, [x2, #-8]
	ldr	x9, [x8, #64]
	lsr	x9, x9, #0
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	stur	x9, [x29, #-40]                 ; 8-byte Folded Spill
Lloh0:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh1:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x11, [x29, #-40]                ; 8-byte Folded Reload
	ldur	x9, [x29, #-32]                 ; 8-byte Folded Reload
	mov	x10, sp
	subs	x0, x10, x11
	stur	x0, [x29, #-16]                 ; 8-byte Folded Spill
	mov	sp, x0
	stur	x9, [x29, #-8]
	adrp	x9, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC@GOTPAGE
	ldr	x9, [x9, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC@GOTPAGEOFF]
	ldr	w1, [x9]
	ldr	x8, [x8, #104]
	blr	x8
	ldur	x8, [x29, #-24]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-16]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-8]
	bl	_$s13CoreAIRuntime7NDArrayV5shape10scalarTypeACSaySiG_AC06ScalarF0OtcfC
	mov	sp, x29
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11BFloat16ABI02isA0ySb13CoreAIRuntime7NDArrayVF ; -- Begin function $s11BFloat16ABI02isA0ySb13CoreAIRuntime7NDArrayVF
	.p2align	2
_$s11BFloat16ABI02isA0ySb13CoreAIRuntime7NDArrayVF: ; @"$s11BFloat16ABI02isA0ySb13CoreAIRuntime7NDArrayVF"
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	stur	xzr, [x29, #-24]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa
	stur	x0, [x29, #-48]                 ; 8-byte Folded Spill
	ldur	x8, [x0, #-8]
	stur	x8, [x29, #-72]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x9, x8, #0
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	stur	x9, [x29, #-88]                 ; 8-byte Folded Spill
Lloh2:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh3:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x10, [x29, #-88]                ; 8-byte Folded Reload
	mov	x9, sp
	subs	x0, x9, x10
	stur	x0, [x29, #-64]                 ; 8-byte Folded Spill
	mov	sp, x0
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-80]                 ; 8-byte Folded Spill
Lloh4:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh5:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-80]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-56]                 ; 8-byte Folded Spill
	mov	sp, x8
	mov	x0, x20
	stur	x0, [x29, #-24]
	bl	_$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg
	ldur	x8, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-48]                 ; 8-byte Folded Reload
	adrp	x9, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC@GOTPAGE
	ldr	x9, [x9, _$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC@GOTPAGEOFF]
	ldr	w1, [x9]
	ldr	x8, [x8, #104]
	blr	x8
	ldur	x1, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-56]                 ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeO2eeoiySbAE_AEtFZ
	ldur	x8, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-48]                 ; 8-byte Folded Reload
	mov	x9, x0
	ldur	x0, [x29, #-64]                 ; 8-byte Folded Reload
	stur	w9, [x29, #-28]                 ; 4-byte Folded Spill
	ldr	x8, [x8, #8]
	stur	x8, [x29, #-40]                 ; 8-byte Folded Spill
	blr	x8
	ldur	x0, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-48]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-40]                 ; 8-byte Folded Reload
	blr	x8
	ldur	w0, [x29, #-28]                 ; 4-byte Folded Reload
	and	w0, w0, #0x1
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh2, Lloh3
	.loh AdrpLdrGot	Lloh4, Lloh5
	.cfi_endproc
                                        ; -- End function
	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_BFloat16ABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_BFloat16ABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_BFloat16ABI"
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_BFloat16ABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_BFloat16ABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_BFloat16ABI:
	.quad	__swift_FORCE_LOAD_$_swiftMetal

	.private_extern	___swift_reflection_version ; @__swift_reflection_version
	.section	__TEXT,__const
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3                               ; 0x3

	.no_dead_strip	_$s11BFloat16ABI14bfloat16Scalar13CoreAIRuntime7NDArrayV0D4TypeOyF
	.no_dead_strip	_$s11BFloat16ABI14bfloat16Scalar13CoreAIRuntime7NDArrayV0D4TypeOyF
	.no_dead_strip	_$s11BFloat16ABI26float16ScalarForComparison13CoreAIRuntime7NDArrayV0D4TypeOyF
	.no_dead_strip	_$s11BFloat16ABI26float16ScalarForComparison13CoreAIRuntime7NDArrayV0D4TypeOyF
	.no_dead_strip	_$s11BFloat16ABI13bfloat16Arrayy13CoreAIRuntime7NDArrayVSaySiGnF
	.no_dead_strip	_$s11BFloat16ABI13bfloat16Arrayy13CoreAIRuntime7NDArrayVSaySiGnF
	.no_dead_strip	_$s11BFloat16ABI02isA0ySb13CoreAIRuntime7NDArrayVF
	.no_dead_strip	_$s11BFloat16ABI02isA0ySb13CoreAIRuntime7NDArrayVF
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_BFloat16ABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_BFloat16ABI
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
