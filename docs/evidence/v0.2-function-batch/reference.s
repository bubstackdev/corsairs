	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF ; -- Begin function $s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF
	.p2align	2
_$s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF: ; @"$s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF"
	.cfi_startproc
; %bb.0:
	str	x20, [sp, #-32]!                ; 8-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w20, -32
	mov	x20, x0
	mov	x0, x1
	mov	x1, x2
	bl	_$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldr	x20, [sp], #32                  ; 8-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF ; -- Begin function $s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF
	.p2align	2
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF: ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF"
	.cfi_startproc
; %bb.0:
	stp	x28, x27, [sp, #-96]!           ; 16-byte Folded Spill
	stp	x26, x25, [sp, #16]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #32]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #48]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	sub	sp, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	stp	x1, x2, [x29, #-128]            ; 16-byte Folded Spill
	mov	x21, x0
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7AIModelVMa
	mov	x23, x0
	ldur	x27, [x0, #-8]
	ldr	x25, [x27, #64]
	mov	x9, x25
Lloh0:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh1:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	mov	x8, sp
	add	x9, x25, #15
	and	x9, x9, #0xfffffffffffffff0
	sub	x24, x8, x9
	mov	sp, x24
Lloh2:
	adrp	x0, _$sScPSgMd@PAGE
Lloh3:
	add	x0, x0, _$sScPSgMd@PAGEOFF
Lloh4:
	adrp	x1, _$sScPSgMR@PAGE
Lloh5:
	add	x1, x1, _$sScPSgMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	ldur	x8, [x0, #-8]
	ldr	x9, [x8, #64]
	add	x8, x9, #15
	and	x8, x8, #0xfffffffffffffff0
Lloh6:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh7:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	mov	x9, sp
	sub	x19, x9, x8
	mov	sp, x19
	mov	x0, #0                          ; =0x0
	bl	_$sScPMa
	mov	x26, x0
	ldur	x28, [x0, #-8]
	ldr	x8, [x28, #56]
	mov	x0, x19
	mov	w1, #1                          ; =0x1
	mov	w2, #1                          ; =0x1
	mov	x3, x26
	blr	x8
	ldr	x8, [x27, #16]
	mov	x0, x24
	mov	x1, x21
	mov	x2, x23
	blr	x8
	ldrb	w8, [x27, #80]
	add	x9, x8, #32
	bic	x22, x9, x8
	add	x9, x25, x22
	add	x9, x9, #7
	and	x20, x9, #0xfffffffffffffff8
Lloh8:
	adrp	x0, l_metadata@PAGE+16
Lloh9:
	add	x0, x0, l_metadata@PAGEOFF+16
	add	x1, x20, #16
	orr	x2, x8, #0x7
	bl	_swift_allocObject
	mov	x21, x0
	mov	x25, x0
	str	xzr, [x25, #16]!
	str	xzr, [x0, #24]
	ldr	x8, [x27, #32]
	add	x0, x0, x22
	mov	x1, x24
	mov	x2, x23
	blr	x8
	add	x8, x21, x20
	ldp	x9, x20, [x29, #-128]           ; 16-byte Folded Reload
	stp	x9, x20, [x8]
	ldr	x8, [x28, #48]
	mov	x0, x19
	mov	w1, #1                          ; =0x1
	mov	x2, x26
	blr	x8
	mov	x22, x0
	mov	x0, x20
	bl	_swift_bridgeObjectRetain
	cmp	w22, #1
	b.ne	LBB1_3
; %bb.1:
	mov	w22, #4096                      ; =0x1000
	ldr	x24, [x25]
	cbz	x24, LBB1_4
LBB1_2:
	ldr	x23, [x21, #24]
	mov	x0, x24
	bl	_swift_getObjectType
	mov	x25, x0
	mov	x0, x24
	bl	_swift_unknownObjectRetain
	mov	x20, x24
	mov	x0, x25
	mov	x1, x23
	bl	_$sScA15unownedExecutorScevgTj
	mov	x20, x0
	mov	x23, x1
	mov	x0, x24
	bl	_swift_unknownObjectRelease
	b	LBB1_5
LBB1_3:
	mov	x20, x19
	bl	_$sScP8rawValues5UInt8Vvg
                                        ; kill: def $w0 killed $w0 def $x0
	mov	w22, #4096                      ; =0x1000
	bfxil	x22, x0, #0, #8
	ldr	x24, [x25]
	cbnz	x24, LBB1_2
LBB1_4:
	mov	x20, #0                         ; =0x0
	mov	x23, #0                         ; =0x0
LBB1_5:
Lloh10:
	adrp	x0, _$s13CoreAIRuntime17InferenceFunctionVSgMd@PAGE
Lloh11:
	add	x0, x0, _$s13CoreAIRuntime17InferenceFunctionVSgMd@PAGEOFF
Lloh12:
	adrp	x1, _$s13CoreAIRuntime17InferenceFunctionVSgMR@PAGE
Lloh13:
	add	x1, x1, _$s13CoreAIRuntime17InferenceFunctionVSgMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	mov	x2, x0
	orr	x8, x23, x20
	cbz	x8, LBB1_7
; %bb.6:
	stp	xzr, xzr, [x29, #-112]
	sub	x1, x29, #112
	stp	x20, x23, [x29, #-96]
	b	LBB1_8
LBB1_7:
	mov	x1, #0                          ; =0x0
LBB1_8:
Lloh14:
	adrp	x3, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu@PAGE
Lloh15:
	add	x3, x3, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu@PAGEOFF
	mov	x0, x22
	mov	x4, x21
	bl	_swift_task_create
	mov	x20, x0
	mov	x0, x19
	bl	_$sScPSgWOh
	mov	x0, x20
	sub	sp, x29, #80
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #48]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #32]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #16]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp], #96             ; 16-byte Folded Reload
	ret
	.loh AdrpAdd	Lloh8, Lloh9
	.loh AdrpAdd	Lloh4, Lloh5
	.loh AdrpAdd	Lloh2, Lloh3
	.loh AdrpAdd	Lloh12, Lloh13
	.loh AdrpAdd	Lloh10, Lloh11
	.loh AdrpAdd	Lloh14, Lloh15
	.loh AdrpLdrGot	Lloh0, Lloh1
	.loh AdrpLdrGot	Lloh6, Lloh7
	.cfi_endproc
                                        ; -- End function
	.private_extern	___swift_instantiateConcreteTypeFromMangledNameV2 ; -- Begin function __swift_instantiateConcreteTypeFromMangledNameV2
	.globl	___swift_instantiateConcreteTypeFromMangledNameV2
	.weak_def_can_be_hidden	___swift_instantiateConcreteTypeFromMangledNameV2
	.p2align	2
___swift_instantiateConcreteTypeFromMangledNameV2: ; @__swift_instantiateConcreteTypeFromMangledNameV2
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	mov	x19, x0
	ldr	x0, [x0]
	and	x8, x0, #0x1
	cmp	x0, #0
	ccmp	x8, #0, #0, ne
	b.eq	LBB2_2
; %bb.1:
	ldr	x9, [x1]
	asr	x8, x9, #32
	add	x0, x1, w9, sxtw
	mov	x1, x8
	mov	x2, #0                          ; =0x0
	mov	x3, #0                          ; =0x0
	bl	_swift_getTypeByMangledNameInContext2
	str	x0, [x19]
LBB2_2:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_: ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_"
; %bb.0:
	stp	x4, x5, [x22, #32]
	stp	x0, x3, [x22, #16]
Lloh16:
	adrp	x0, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_@PAGE
Lloh17:
	add	x0, x0, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_@PAGEOFF
	mov	x1, #0                          ; =0x0
	mov	x2, #0                          ; =0x0
	b	_swift_task_switch
	.loh AdrpAdd	Lloh16, Lloh17
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_: ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #48
	str	x21, [sp, #16]                  ; 8-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	str	x22, [sp, #24]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w21, -32
	ldp	x0, x1, [x22, #32]
	ldp	x8, x20, [x22, #16]
	mov	x21, #0                         ; =0x0
	bl	_$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF
	ldr	x0, [x22, #8]
	cbz	x21, LBB4_2
; %bb.1:
	mov	x20, x21
	b	LBB4_3
LBB4_2:
	mov	x20, #0                         ; =0x0
LBB4_3:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldr	x21, [sp, #16]                  ; 8-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	br	x0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function __swift_closure_destructor
___swift_closure_destructor:            ; @__swift_closure_destructor
	.cfi_startproc
; %bb.0:
	stp	x24, x23, [sp, #-64]!           ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7AIModelVMa
	mov	x19, x0
	ldur	x21, [x0, #-8]
	ldrb	w22, [x21, #80]
	add	x8, x22, #32
	bic	x23, x8, x22
	ldr	x8, [x21, #64]
	add	x8, x8, x23
	add	x8, x8, #7
	and	x24, x8, #0xfffffffffffffff8
	ldr	x0, [x20, #16]
	bl	_swift_unknownObjectRelease
	ldr	x8, [x21, #8]
	add	x0, x20, x23
	mov	x1, x19
	blr	x8
	add	x8, x20, x24
	ldr	x0, [x8, #8]
	bl	_swift_bridgeObjectRelease
	add	x1, x24, #16
	orr	x2, x22, #0x7
	mov	x0, x20
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	b	_swift_deallocObject
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TA
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TA: ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TA"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #64
	stp	x24, x23, [sp, #8]              ; 16-byte Folded Spill
	stp	x21, x19, [sp, #24]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	str	x22, [sp, #40]
	add	x29, sp, #48
	mov	x19, x0
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7AIModelVMa
	ldur	x8, [x0, #-8]
	ldrb	w9, [x8, #80]
	add	x10, x9, #32
	bic	x24, x10, x9
	ldr	x8, [x8, #64]
	add	x8, x8, x24
	add	x8, x8, #7
	and	x8, x8, #0xfffffffffffffff8
	add	x8, x20, x8
	ldp	x21, x23, [x8]
Lloh18:
	adrp	x8, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu@PAGE+4
Lloh19:
	ldr	w0, [x8, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu@PAGEOFF+4]
	bl	_swift_task_alloc
	mov	x8, x0
	str	x0, [x22, #16]
Lloh20:
	adrp	x9, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_@PAGE
Lloh21:
	add	x9, x9, _$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_@PAGEOFF
	stp	x22, x9, [x0]
	add	x3, x20, x24
	mov	x0, x19
	mov	x22, x8
	mov	x4, x21
	mov	x5, x23
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x21, x19, [sp, #24]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #8]              ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #64
	b	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_
	.loh AdrpAdd	Lloh20, Lloh21
	.loh AdrpLdr	Lloh18, Lloh19
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_: ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATQ0_"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	ldr	x8, [x22]
	stur	x8, [x29, #-8]
	ldr	x0, [x8, #16]
	ldr	x22, [x22]
	bl	_swift_task_dealloc
	ldr	x0, [x22, #8]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x0
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$sScPSgWOh             ; -- Begin function $sScPSgWOh
	.globl	_$sScPSgWOh
	.weak_def_can_be_hidden	_$sScPSgWOh
	.p2align	2
_$sScPSgWOh:                            ; @"$sScPSgWOh"
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	mov	x19, x0
Lloh22:
	adrp	x0, _$sScPSgMd@PAGE
Lloh23:
	add	x0, x0, _$sScPSgMd@PAGEOFF
Lloh24:
	adrp	x1, _$sScPSgMR@PAGE
Lloh25:
	add	x1, x1, _$sScPSgMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	mov	x1, x0
	ldur	x8, [x0, #-8]
	ldr	x8, [x8, #8]
	mov	x0, x19
	blr	x8
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpAdd	Lloh24, Lloh25
	.loh AdrpAdd	Lloh22, Lloh23
                                        ; -- End function
	.globl	_$s16FunctionBatchABI26verifySendableConformancesyyF ; -- Begin function $s16FunctionBatchABI26verifySendableConformancesyyF
	.p2align	2
_$s16FunctionBatchABI26verifySendableConformancesyyF: ; @"$s16FunctionBatchABI26verifySendableConformancesyyF"
; %bb.0:
	ret
                                        ; -- End function
	.private_extern	"_symbolic ScPSg"       ; @"symbolic ScPSg"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic ScPSg"
	.weak_definition	"_symbolic ScPSg"
	.p2align	1, 0x0
"_symbolic ScPSg":
	.ascii	"ScPSg"
	.byte	0                               ; 0x0

	.private_extern	_$sScPSgMd              ; @"$sScPSgMd"
	.section	__DATA,__data
	.globl	_$sScPSgMd
	.weak_definition	_$sScPSgMd
	.p2align	3, 0x0
_$sScPSgMd:
	.space	8

	.private_extern	_$sScPSgMR              ; @"$sScPSgMR"
	.section	__TEXT,__const
	.globl	_$sScPSgMR
	.weak_definition	_$sScPSgMR
	.p2align	3, 0x0
_$sScPSgMR:
	.long	"_symbolic ScPSg"-_$sScPSgMR
	.long	5                               ; 0x5

	.p2align	3, 0x0                          ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu"
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu:
	.long	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_-_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_Tu
	.long	48                              ; 0x30

	.private_extern	"_symbolic ScA_pSg"     ; @"symbolic ScA_pSg"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic ScA_pSg"
	.weak_definition	"_symbolic ScA_pSg"
	.p2align	1, 0x0
"_symbolic ScA_pSg":
	.ascii	"ScA_pSg"
	.byte	0                               ; 0x0

	.private_extern	"_symbolic _____ 13CoreAIRuntime7AIModelV" ; @"symbolic _____ 13CoreAIRuntime7AIModelV"
	.globl	"_symbolic _____ 13CoreAIRuntime7AIModelV"
	.weak_definition	"_symbolic _____ 13CoreAIRuntime7AIModelV"
	.p2align	1, 0x0
"_symbolic _____ 13CoreAIRuntime7AIModelV":
	.byte	2                               ; 0x2
Ltmp0:
	.long	_$s13CoreAIRuntime7AIModelVMn@GOT-Ltmp0
	.byte	0                               ; 0x0

	.private_extern	"_symbolic SS"          ; @"symbolic SS"
	.globl	"_symbolic SS"
	.weak_definition	"_symbolic SS"
	.p2align	1, 0x0
"_symbolic SS":
	.space	2,83
	.byte	0                               ; 0x0

	.section	__TEXT,__swift5_capture
	.p2align	2, 0x0                          ; @"\01l__swift5_reflection_descriptor"
l__swift5_reflection_descriptor:
	.long	3                               ; 0x3
	.long	0                               ; 0x0
	.long	0                               ; 0x0
	.long	"_symbolic ScA_pSg"-l__swift5_reflection_descriptor-12
	.long	"_symbolic _____ 13CoreAIRuntime7AIModelV"-l__swift5_reflection_descriptor-16
	.long	"_symbolic SS"-l__swift5_reflection_descriptor-20

	.section	__DATA,__const
	.p2align	3, 0x0                          ; @metadata
l_metadata:
	.quad	___swift_closure_destructor
	.quad	0
	.quad	1024                            ; 0x400
	.long	16                              ; 0x10
	.space	4
	.quad	l__swift5_reflection_descriptor

	.section	__TEXT,__const
	.p2align	3, 0x0                          ; @"$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu"
_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu:
	.long	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TA-_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TATu
	.long	32                              ; 0x20

	.private_extern	"_symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV" ; @"symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV"
	.weak_definition	"_symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV"
	.p2align	1, 0x0
"_symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV":
	.byte	2                               ; 0x2
Ltmp1:
	.long	_$s13CoreAIRuntime17InferenceFunctionVMn@GOT-Ltmp1
	.ascii	"Sg"
	.byte	0                               ; 0x0

	.private_extern	_$s13CoreAIRuntime17InferenceFunctionVSgMd ; @"$s13CoreAIRuntime17InferenceFunctionVSgMd"
	.section	__DATA,__data
	.globl	_$s13CoreAIRuntime17InferenceFunctionVSgMd
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionVSgMd
	.p2align	3, 0x0
_$s13CoreAIRuntime17InferenceFunctionVSgMd:
	.space	8

	.private_extern	_$s13CoreAIRuntime17InferenceFunctionVSgMR ; @"$s13CoreAIRuntime17InferenceFunctionVSgMR"
	.section	__TEXT,__const
	.globl	_$s13CoreAIRuntime17InferenceFunctionVSgMR
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionVSgMR
	.p2align	3, 0x0
_$s13CoreAIRuntime17InferenceFunctionVSgMR:
	.long	"_symbolic _____Sg 13CoreAIRuntime17InferenceFunctionV"-_$s13CoreAIRuntime17InferenceFunctionVSgMR
	.long	7                               ; 0x7

	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI"
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI:
	.quad	__swift_FORCE_LOAD_$_swiftMetal

	.private_extern	___swift_reflection_version ; @__swift_reflection_version
	.section	__TEXT,__const
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3                               ; 0x3

	.section	__TEXT,__swift_as_entry,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_entry_functlets
___swift_async_entry_functlets:
	.long	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_-___swift_async_entry_functlets

	.section	__TEXT,__swift_as_cont,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_cont_functlets
___swift_async_cont_functlets:
	.long	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStFAFyYaKcfU_TY0_-___swift_async_cont_functlets

	.no_dead_strip	l__swift5_reflection_descriptor
	.no_dead_strip	_$s16FunctionBatchABI08borrowedA4Loady13CoreAIRuntime09InferenceA0VSgAC7AIModelV_SStKF
	.no_dead_strip	_$s16FunctionBatchABI08detachedA4LoadyScTy13CoreAIRuntime09InferenceA0VSgs5Error_pGAC7AIModelV_SStF
	.no_dead_strip	_$s16FunctionBatchABI26verifySendableConformancesyyF
	.no_dead_strip	___swift_reflection_version
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_FunctionBatchABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionBatchABI
	.no_dead_strip	___swift_async_entry_functlets
	.no_dead_strip	___swift_async_cont_functlets
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
