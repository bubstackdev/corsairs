	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF ; -- Begin function $s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF
	.p2align	2
_$s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF: ; @"$s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF"
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
	str	x0, [sp, #8]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime13ComputeStreamCMa
	mov	x20, x0
	ldr	x0, [sp, #8]
	bl	_$s13CoreAIRuntime13ComputeStreamC12commandQueueACSo010MTLCommandF0_p_tcfC
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF ; -- Begin function $s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF
	.p2align	2
_$s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF: ; @"$s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF"
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	stur	x0, [x29, #-80]                 ; 8-byte Folded Spill
	stur	x1, [x29, #-112]                ; 8-byte Folded Spill
	stur	x2, [x29, #-104]                ; 8-byte Folded Spill
	stur	xzr, [x29, #-32]
	stur	xzr, [x29, #-40]
	adrp	x0, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd@PAGE
	add	x0, x0, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd@PAGEOFF
	adrp	x1, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR@PAGE
	add	x1, x1, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	ldur	x8, [x0, #-8]
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-96]                 ; 8-byte Folded Spill
Lloh0:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh1:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-96]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x0, x8, x9
	stur	x0, [x29, #-88]                 ; 8-byte Folded Spill
	mov	sp, x0
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa
	mov	x8, x0
	ldur	x0, [x29, #-80]                 ; 8-byte Folded Reload
	stur	x8, [x29, #-72]                 ; 8-byte Folded Spill
	ldur	x8, [x8, #-8]
	stur	x8, [x29, #-64]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-56]                 ; 8-byte Folded Spill
Lloh2:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh3:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-56]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-48]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x0, [x29, #-24]
	stur	x8, [x29, #-32]
	b	LBB1_1
LBB1_1:
	ldur	x0, [x29, #-48]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-112]                ; 8-byte Folded Reload
	ldur	x8, [x29, #-64]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	blr	x8
	ldur	x8, [x29, #-104]                ; 8-byte Folded Reload
	stur	x8, [x29, #-40]
	mov	x0, #0                          ; =0x0
	stur	x0, [x29, #-136]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa
	mov	x20, x0
	ldur	x0, [x29, #-104]                ; 8-byte Folded Reload
	bl	_swift_bridgeObjectRetain
	ldur	x0, [x29, #-136]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa
	mov	x3, x0
	ldur	x0, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x8, [x3, #-8]
	ldr	x8, [x8, #56]
	mov	w2, #1                          ; =0x1
	mov	x1, x2
	blr	x8
	ldur	x8, [x29, #-24]
	stur	x8, [x29, #-120]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_
	stur	x0, [x29, #-128]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_
	ldur	x1, [x29, #-128]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-48]                 ; 8-byte Folded Reload
	ldur	x3, [x29, #-104]                ; 8-byte Folded Reload
	ldur	x5, [x29, #-88]                 ; 8-byte Folded Reload
	mov	x4, x0
	ldur	x0, [x29, #-120]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfC
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh0, Lloh1
	.loh AdrpLdrGot	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.private_extern	___swift_instantiateConcreteTypeFromMangledNameV2 ; -- Begin function __swift_instantiateConcreteTypeFromMangledNameV2
	.globl	___swift_instantiateConcreteTypeFromMangledNameV2
	.weak_definition	___swift_instantiateConcreteTypeFromMangledNameV2
	.p2align	2
___swift_instantiateConcreteTypeFromMangledNameV2: ; @__swift_instantiateConcreteTypeFromMangledNameV2
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	str	x0, [sp, #8]                    ; 8-byte Folded Spill
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	ldr	x8, [x0]
	stur	x8, [x29, #-8]                  ; 8-byte Folded Spill
	and	x8, x8, #0x1
	subs	x8, x8, #1
	b.eq	LBB2_3
	b	LBB2_1
LBB2_1:
	ldur	x8, [x29, #-8]                  ; 8-byte Folded Reload
	mov	x0, x8
	str	x0, [sp]                        ; 8-byte Folded Spill
	cbz	x8, LBB2_3
	b	LBB2_2
LBB2_2:
	ldr	x0, [sp]                        ; 8-byte Folded Reload
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
LBB2_3:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x9, [x8]
	asr	x1, x9, #32
                                        ; kill: def $w9 killed $w9 killed $x9
	add	x0, x8, w9, sxtw
	mov	x3, #0                          ; =0x0
	mov	x2, x3
	bl	_swift_getTypeByMangledNameInContext2
	ldr	x9, [sp, #8]                    ; 8-byte Folded Reload
	mov	x8, x0
	str	x8, [x9]
	str	x0, [sp]                        ; 8-byte Folded Spill
	b	LBB2_2
                                        ; -- End function
	.private_extern	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_ ; -- Begin function $s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_
	.globl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_
	.p2align	2
_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_: ; @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA0_"
	.cfi_startproc
; %bb.0:
	mov	x0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_ ; -- Begin function $s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_
	.globl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_
	.p2align	2
_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_: ; @"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfcfA3_"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x0, #0                          ; =0x0
	bl	_$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF ; -- Begin function $s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF
	.p2align	2
_$s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF: ; @"$s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	sub	sp, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x8, [x29, #-104]                ; 8-byte Folded Spill
	stur	x0, [x29, #-64]                 ; 8-byte Folded Spill
	stur	x1, [x29, #-96]                 ; 8-byte Folded Spill
	stur	x2, [x29, #-88]                 ; 8-byte Folded Spill
	stur	xzr, [x29, #-16]
	stur	xzr, [x29, #-24]
	adrp	x0, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd@PAGE
	add	x0, x0, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd@PAGEOFF
	adrp	x1, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR@PAGE
	add	x1, x1, _$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	ldur	x8, [x0, #-8]
	ldr	x8, [x8, #64]
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
	subs	x0, x8, x9
	stur	x0, [x29, #-72]                 ; 8-byte Folded Spill
	mov	sp, x0
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa
	mov	x8, x0
	ldur	x0, [x29, #-64]                 ; 8-byte Folded Reload
	stur	x8, [x29, #-56]                 ; 8-byte Folded Spill
	ldur	x8, [x8, #-8]
	stur	x8, [x29, #-48]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-40]                 ; 8-byte Folded Spill
Lloh6:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh7:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-40]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-32]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x0, [x29, #-8]
	stur	x8, [x29, #-16]
	b	LBB5_1
LBB5_1:
	ldur	x0, [x29, #-32]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-96]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-48]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	blr	x8
	ldur	x0, [x29, #-88]                 ; 8-byte Folded Reload
	mov	x8, x0
	stur	x8, [x29, #-24]
	bl	_swift_bridgeObjectRetain
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa
	mov	x3, x0
	ldur	x0, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x8, [x3, #-8]
	ldr	x8, [x8, #56]
	mov	w2, #1                          ; =0x1
	mov	x1, x2
	blr	x8
	ldur	x8, [x29, #-8]
	stur	x8, [x29, #-112]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_
	stur	x0, [x29, #-120]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_
	ldur	x8, [x29, #-104]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-120]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-32]                 ; 8-byte Folded Reload
	ldur	x3, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x5, [x29, #-72]                 ; 8-byte Folded Reload
	mov	x4, x0
	ldur	x0, [x29, #-112]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfC
	mov	sp, x29
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh4, Lloh5
	.loh AdrpLdrGot	Lloh6, Lloh7
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_ ; -- Begin function $s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_
	.globl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_
	.p2align	2
_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_: ; @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA0_"
	.cfi_startproc
; %bb.0:
	mov	x0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_ ; -- Begin function $s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_
	.globl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_
	.p2align	2
_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_: ; @"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfcfA3_"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x0, #0                          ; =0x0
	bl	_$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF ; -- Begin function $s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF
	.p2align	2
_$s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF: ; @"$s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF"
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	stur	x0, [x29, #-64]                 ; 8-byte Folded Spill
	stur	xzr, [x29, #-24]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayVMa
	stur	x0, [x29, #-56]                 ; 8-byte Folded Spill
	ldur	x8, [x0, #-8]
	stur	x8, [x29, #-48]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-40]                 ; 8-byte Folded Spill
Lloh8:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh9:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-40]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-32]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x8, [x29, #-24]
	b	LBB8_1
LBB8_1:
	ldur	x0, [x29, #-32]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-48]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	blr	x8
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa
	mov	x20, x0
	ldur	x0, [x29, #-32]                 ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCyAeA7NDArrayVcfC
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh8, Lloh9
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF ; -- Begin function $s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF
	.p2align	2
_$s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF: ; @"$s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	sub	sp, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x8, [x29, #-56]                 ; 8-byte Folded Spill
	stur	x0, [x29, #-48]                 ; 8-byte Folded Spill
	stur	xzr, [x29, #-8]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime7NDArrayVMa
	stur	x0, [x29, #-40]                 ; 8-byte Folded Spill
	ldur	x8, [x0, #-8]
	stur	x8, [x29, #-32]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-24]                 ; 8-byte Folded Spill
Lloh10:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh11:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-24]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-16]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x8, [x29, #-8]
	b	LBB9_1
LBB9_1:
	ldur	x0, [x29, #-16]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-40]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-48]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-32]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	blr	x8
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-16]                 ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVyAeA7NDArrayVcfC
	mov	sp, x29
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh10, Lloh11
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF ; -- Begin function $s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF
	.p2align	2
_$s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF: ; @"$s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF"
	.cfi_startproc
; %bb.0:
	str	x20, [sp, #-32]!                ; 8-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #176
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w20, -32
	stur	x0, [x29, #-112]                ; 8-byte Folded Spill
	stur	x1, [x29, #-120]                ; 8-byte Folded Spill
	stur	x2, [x29, #-152]                ; 8-byte Folded Spill
	stur	x3, [x29, #-144]                ; 8-byte Folded Spill
	stur	x4, [x29, #-136]                ; 8-byte Folded Spill
	stur	x5, [x29, #-128]                ; 8-byte Folded Spill
	stur	x21, [x29, #-160]               ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-24]
	stur	xzr, [x29, #-32]
	stur	xzr, [x29, #-40]
	stur	xzr, [x29, #-56]
	stur	xzr, [x29, #-48]
	stur	xzr, [x29, #-64]
	stur	xzr, [x29, #-72]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa
	ldur	x2, [x29, #-152]                ; 8-byte Folded Reload
	ldur	x3, [x29, #-144]                ; 8-byte Folded Reload
	ldur	x4, [x29, #-136]                ; 8-byte Folded Reload
	ldur	x5, [x29, #-128]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-120]                ; 8-byte Folded Reload
	mov	x8, x0
	ldur	x0, [x29, #-112]                ; 8-byte Folded Reload
	ldur	x8, [x8, #-8]
	ldr	x8, [x8, #64]
	lsr	x9, x8, #0
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	stur	x9, [x29, #-104]                ; 8-byte Folded Spill
Lloh12:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh13:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x10, [x29, #-104]               ; 8-byte Folded Reload
	mov	x9, sp
	subs	x6, x9, x10
	stur	x6, [x29, #-96]                 ; 8-byte Folded Spill
	mov	sp, x6
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-88]                 ; 8-byte Folded Spill
Lloh14:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh15:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-88]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-80]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x0, [x29, #-24]
	stur	x1, [x29, #-32]
	stur	x2, [x29, #-40]
	stur	x3, [x29, #-56]
	stur	x4, [x29, #-48]
	stur	x5, [x29, #-64]
	stur	x8, [x29, #-72]
	b	LBB10_1
LBB10_1:
	ldur	x20, [x29, #-80]                ; 8-byte Folded Reload
	mov	x8, x20
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC
	ldur	x0, [x29, #-152]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-144]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-136]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF
	ldur	x20, [x29, #-112]               ; 8-byte Folded Reload
	ldur	x8, [x29, #-96]                 ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_
	ldur	x0, [x29, #-120]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-96]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-80]                 ; 8-byte Folded Reload
	ldur	x3, [x29, #-128]                ; 8-byte Folded Reload
	ldur	x21, [x29, #-160]               ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF
	stur	x21, [x29, #-184]               ; 8-byte Folded Spill
	stur	x0, [x29, #-176]                ; 8-byte Folded Spill
	mov	x8, x21
	stur	x8, [x29, #-168]                ; 8-byte Folded Spill
	cbnz	x21, LBB10_3
	b	LBB10_2
LBB10_2:
	ldur	x21, [x29, #-184]               ; 8-byte Folded Reload
	ldur	x0, [x29, #-176]                ; 8-byte Folded Reload
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldr	x20, [sp], #32                  ; 8-byte Folded Reload
	ret
LBB10_3:
	ldur	x0, [x29, #-192]                ; 8-byte Folded Reload
	ldur	x21, [x29, #-168]               ; 8-byte Folded Reload
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldr	x20, [sp], #32                  ; 8-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh12, Lloh13
	.loh AdrpLdrGot	Lloh14, Lloh15
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_ ; -- Begin function $s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_
	.globl	_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_
	.weak_definition	_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_
	.p2align	2
_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_: ; @"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKFfA0_"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF ; -- Begin function $s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF
	.p2align	2
_$s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF: ; @"$s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF"
	.cfi_startproc
; %bb.0:
	stp	x28, x20, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #240
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w20, -24
	.cfi_offset w28, -32
	stur	x0, [x29, #-152]                ; 8-byte Folded Spill
	stur	x1, [x29, #-160]                ; 8-byte Folded Spill
	stur	x2, [x29, #-208]                ; 8-byte Folded Spill
	stur	x3, [x29, #-200]                ; 8-byte Folded Spill
	stur	x4, [x29, #-192]                ; 8-byte Folded Spill
	stur	x5, [x29, #-184]                ; 8-byte Folded Spill
	stur	x6, [x29, #-176]                ; 8-byte Folded Spill
	stur	x7, [x29, #-168]                ; 8-byte Folded Spill
	ldr	x8, [x29, #16]
	stur	x8, [x29, #-120]                ; 8-byte Folded Spill
	stur	x21, [x29, #-216]               ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-24]
	stur	xzr, [x29, #-32]
	stur	xzr, [x29, #-40]
	stur	xzr, [x29, #-56]
	stur	xzr, [x29, #-48]
	stur	xzr, [x29, #-64]
	stur	xzr, [x29, #-80]
	stur	xzr, [x29, #-72]
	stur	xzr, [x29, #-88]
	stur	xzr, [x29, #-96]
	stur	xzr, [x29, #-104]
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa
	ldur	x2, [x29, #-208]                ; 8-byte Folded Reload
	ldur	x3, [x29, #-200]                ; 8-byte Folded Reload
	ldur	x4, [x29, #-192]                ; 8-byte Folded Reload
	ldur	x5, [x29, #-184]                ; 8-byte Folded Reload
	ldur	x6, [x29, #-176]                ; 8-byte Folded Reload
	ldur	x7, [x29, #-168]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-160]                ; 8-byte Folded Reload
	mov	x8, x0
	ldur	x0, [x29, #-152]                ; 8-byte Folded Reload
	ldur	x8, [x8, #-8]
	ldr	x8, [x8, #64]
	lsr	x9, x8, #0
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	stur	x9, [x29, #-144]                ; 8-byte Folded Spill
Lloh16:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh17:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x10, [x29, #-144]               ; 8-byte Folded Reload
	mov	x9, sp
	subs	x9, x9, x10
	stur	x9, [x29, #-136]                ; 8-byte Folded Spill
	mov	sp, x9
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-128]                ; 8-byte Folded Spill
Lloh18:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh19:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x10, [x29, #-128]               ; 8-byte Folded Reload
	ldur	x9, [x29, #-120]                ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x10
	stur	x8, [x29, #-112]                ; 8-byte Folded Spill
	mov	sp, x8
	stur	x0, [x29, #-24]
	stur	x1, [x29, #-32]
	stur	x2, [x29, #-40]
	stur	x3, [x29, #-56]
	stur	x4, [x29, #-48]
	stur	x5, [x29, #-64]
	stur	x6, [x29, #-80]
	stur	x7, [x29, #-72]
	stur	x9, [x29, #-88]
	stur	x8, [x29, #-96]
	b	LBB12_1
LBB12_1:
	ldur	x8, [x29, #-112]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC
	ldur	x8, [x29, #-136]                ; 8-byte Folded Reload
	stur	x8, [x29, #-104]
	b	LBB12_2
LBB12_2:
	ldur	x8, [x29, #-136]                ; 8-byte Folded Reload
	ldur	x20, [x29, #-112]               ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC
	ldur	x0, [x29, #-208]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-200]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-192]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF
	ldur	x20, [x29, #-136]               ; 8-byte Folded Reload
	ldur	x0, [x29, #-184]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-176]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-168]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF
	ldur	x20, [x29, #-152]               ; 8-byte Folded Reload
	ldur	x0, [x29, #-160]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-112]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-136]                ; 8-byte Folded Reload
	ldur	x3, [x29, #-120]                ; 8-byte Folded Reload
	ldur	x21, [x29, #-216]               ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF
	stur	x21, [x29, #-240]               ; 8-byte Folded Spill
	stur	x0, [x29, #-232]                ; 8-byte Folded Spill
	mov	x8, x21
	stur	x8, [x29, #-224]                ; 8-byte Folded Spill
	cbnz	x21, LBB12_4
	b	LBB12_3
LBB12_3:
	ldur	x21, [x29, #-240]               ; 8-byte Folded Reload
	ldur	x0, [x29, #-232]                ; 8-byte Folded Reload
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x28, x20, [sp], #32             ; 16-byte Folded Reload
	ret
LBB12_4:
	ldur	x0, [x29, #-248]                ; 8-byte Folded Reload
	ldur	x21, [x29, #-224]               ; 8-byte Folded Reload
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x28, x20, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh16, Lloh17
	.loh AdrpLdrGot	Lloh18, Lloh19
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF ; -- Begin function $s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF
	.p2align	2
_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF: ; @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF"
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
	str	x22, [sp]                       ; 8-byte Folded Spill
	mov	x20, x0
	mov	x8, x22
	str	x8, [x22, #16]
	add	x8, x22, #24
	str	xzr, [x22, #24]
	mov	x0, x20
	str	x0, [x22, #24]
	; InlineAsm Start
	; InlineAsm End
	adrp	x8, _$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaFTu@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaFTu@GOTPAGEOFF]
	ldr	w8, [x8, #4]
	mov	x0, x8
	bl	_swift_task_alloc
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	mov	x22, x0
	mov	x0, x22
	str	x0, [x8, #32]
	ldr	x8, [x8, #16]
	str	x8, [x22]
	adrp	x8, _$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_@PAGE
	add	x8, x8, _$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_@PAGEOFF
	str	x8, [x22, #8]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaF
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_
_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_: ; @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_"
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
	ldr	x9, [x22]
	str	x9, [sp]                        ; 8-byte Folded Spill
	mov	x8, x29
	sub	x8, x8, #8
	str	x9, [x8]
	ldr	x0, [x9, #32]
	ldr	x8, [x22]
	str	x8, [x9, #16]
	bl	_swift_task_dealloc
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldr	x22, [x8, #16]
	ldr	x0, [x22, #8]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF ; -- Begin function $s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF
	.p2align	2
_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF: ; @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	str	x22, [sp, #24]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
	str	x22, [sp, #8]                   ; 8-byte Folded Spill
	mov	x20, x1
	mov	x8, x22
	str	x8, [x22, #16]
	add	x8, x22, #24
	str	xzr, [x22, #24]
	mov	x1, x20
	str	x1, [x22, #24]
	; InlineAsm Start
	; InlineAsm End
	adrp	x8, _$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvgTu@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvgTu@GOTPAGEOFF]
	ldr	w8, [x8, #4]
	mov	x0, x8
	bl	_swift_task_alloc
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	mov	x22, x0
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	mov	x9, x22
	str	x9, [x8, #32]
	ldr	x8, [x8, #16]
	str	x8, [x22]
	adrp	x8, _$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_@PAGE
	add	x8, x8, _$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_@PAGEOFF
	str	x8, [x22, #8]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	b	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvg
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_
_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_: ; @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	str	x22, [sp, #24]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x20, [sp, #8]                   ; 8-byte Folded Spill
	ldr	x8, [x22]
	mov	x9, x29
	sub	x9, x9, #8
	str	x8, [x9]
	ldr	x0, [x8, #32]
	ldr	x9, [x22]
	str	x9, [x8, #16]!
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	bl	_swift_task_dealloc
	cbnz	x20, LBB16_2
	b	LBB16_1
LBB16_1:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x22, [x8]
	ldr	x0, [x22, #8]
	mov	x20, #0                         ; =0x0
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	br	x0
LBB16_2:
	ldr	x20, [sp, #8]                   ; 8-byte Folded Reload
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x22, [x8]
	ldr	x0, [x22, #8]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF ; -- Begin function $s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF
	.p2align	2
_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF: ; @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	str	x22, [sp, #40]
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	str	x0, [x22, #32]
	mov	x8, x22
	str	x8, [x22, #16]
	add	x8, x22, #24
	str	x8, [sp]                        ; 8-byte Folded Spill
	str	xzr, [x22, #24]
	str	xzr, [x22, #24]
	mov	x0, #0                          ; =0x0
	stur	x0, [x29, #-16]                 ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVMa
	str	x0, [sp, #24]                   ; 8-byte Folded Spill
	ldur	x8, [x0, #-8]
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	add	x8, x8, #15
	and	x0, x8, #0xfffffffffffffff0
	bl	_swift_task_alloc
	ldr	x9, [sp]                        ; 8-byte Folded Reload
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x1, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x2, [sp, #24]                   ; 8-byte Folded Reload
	mov	x10, x0
	str	x10, [x22, #40]
	mov	x10, x0
	str	x10, [x22, #24]
	; InlineAsm Start
	; InlineAsm End
	ldr	x8, [x8, #32]
	blr	x8
	ldur	x2, [x29, #-16]                 ; 8-byte Folded Reload
	ldr	x22, [x22, #16]
	adrp	x0, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_@PAGE
	add	x0, x0, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_@PAGEOFF
	mov	x1, x2
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #64
	b	_swift_task_switch
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_
_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_: ; @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_"
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
	str	x22, [sp]                       ; 8-byte Folded Spill
	ldr	x9, [x22, #40]
	mov	x8, x22
	str	x8, [x22, #16]
	add	x8, x22, #24
	str	x9, [x22, #24]
	; InlineAsm Start
	; InlineAsm End
	; InlineAsm Start
	nop
	; InlineAsm End
	adrp	x8, _$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu@GOTPAGEOFF]
	ldr	w8, [x8, #4]
	mov	x0, x8
	bl	_swift_task_alloc
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	mov	x22, x0
	mov	x0, x22
	str	x0, [x8, #48]
	ldr	x9, [x8, #16]
	str	x9, [x22]
	adrp	x9, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_@PAGE
	add	x9, x9, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_@PAGEOFF
	str	x9, [x22, #8]
	ldr	x20, [x8, #40]
	ldr	x0, [x8, #32]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvg
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_
_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_: ; @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_"
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
	mov	x9, x29
	sub	x9, x9, #8
	str	x8, [x9]
	ldr	x0, [x8, #48]
	ldr	x9, [x22]
	str	x9, [x8, #16]!
	mov	x9, x8
	str	x9, [sp]                        ; 8-byte Folded Spill
	str	x20, [x8, #40]
	bl	_swift_task_dealloc
	cbnz	x20, LBB19_2
	b	LBB19_1
LBB19_1:
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldr	x22, [x8]
	adrp	x0, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_@PAGE
	add	x0, x0, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_@PAGEOFF
	mov	x2, #0                          ; =0x0
	mov	x1, x2
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_swift_task_switch
LBB19_2:
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldr	x22, [x8]
	adrp	x0, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_@PAGE
	add	x0, x0, _$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_@PAGEOFF
	mov	x2, #0                          ; =0x0
	mov	x1, x2
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_swift_task_switch
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_
_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_: ; @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_"
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
	ldr	x0, [x22, #40]
	mov	x8, x22
	str	x8, [x22, #16]
	bl	_swift_task_dealloc
	ldr	x8, [x22, #16]
	ldr	x0, [x8, #8]
	ldr	x22, [x22, #16]
	mov	x20, #0                         ; =0x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_
_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_: ; @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_"
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
	mov	x8, x22
	str	x8, [sp]                        ; 8-byte Folded Spill
	ldr	x0, [x8, #40]
	mov	x22, x8
	str	x22, [x8, #16]
	bl	_swift_task_dealloc
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldr	x9, [x8, #16]
	ldr	x0, [x9, #8]
	ldr	x22, [x8, #16]
	ldr	x20, [x8, #56]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF ; -- Begin function $s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF
	.p2align	2
_$s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF: ; @"$s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa
	mov	x1, x0
	adrp	x0, _$sSSN@GOTPAGE
	ldr	x0, [x0, _$sSSN@GOTPAGEOFF]
	adrp	x2, _$sSSSHsWP@GOTPAGE
	ldr	x2, [x2, _$sSSSHsWP@GOTPAGEOFF]
	bl	_$sS2Dyxq_GycfC
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF ; -- Begin function $s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF
	.p2align	2
_$s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF: ; @"$s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #128
	stp	x20, x19, [sp, #96]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	str	x1, [sp]                        ; 8-byte Folded Spill
	str	x2, [sp, #8]                    ; 8-byte Folded Spill
	mov	x0, x3
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
	stur	xzr, [x29, #-24]
	stur	xzr, [x29, #-32]
	stur	xzr, [x29, #-48]
	stur	xzr, [x29, #-40]
	mov	x8, x20
	stur	x8, [x29, #-24]
	stur	x1, [x29, #-32]
	stur	x2, [x29, #-48]
	mov	x3, x0
	stur	x3, [x29, #-40]
	bl	_swift_bridgeObjectRetain
	ldr	x0, [sp]                        ; 8-byte Folded Reload
	bl	_swift_retain
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	ldr	x2, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x3, [sp, #16]                   ; 8-byte Folded Reload
	add	x8, sp, #56
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	str	x1, [sp, #56]
	add	x8, sp, #40
	str	x8, [sp, #24]                   ; 8-byte Folded Spill
	str	x2, [sp, #40]
	str	x3, [sp, #48]
	adrp	x0, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd@PAGE
	add	x0, x0, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd@PAGEOFF
	adrp	x1, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR@PAGE
	add	x1, x1, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	ldr	x1, [sp, #24]                   ; 8-byte Folded Reload
	mov	x2, x0
	ldr	x0, [sp, #32]                   ; 8-byte Folded Reload
	bl	_$sSDyq_Sgxcis
	ldp	x29, x30, [sp, #112]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #128
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF ; -- Begin function $s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF
	.p2align	2
_$s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF: ; @"$s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	stur	xzr, [x29, #-24]
	str	xzr, [sp, #40]
	str	xzr, [sp, #48]
	mov	x0, x20
	stur	x0, [x29, #-24]
	str	x1, [sp, #40]
	mov	x8, x2
	str	x8, [sp, #48]
	add	x8, sp, #16
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	str	x1, [sp, #16]
	str	x2, [sp, #24]
	adrp	x0, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd@PAGE
	add	x0, x0, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd@PAGEOFF
	adrp	x1, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR@PAGE
	add	x1, x1, _$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	mov	x1, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	add	x8, sp, #32
	bl	_$sSD11removeValue6forKeyq_Sgx_tF
	ldr	x0, [sp, #32]
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF ; -- Begin function $s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF
	.p2align	2
_$s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF: ; @"$s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x1
	mov	x1, x2
	mov	x2, x3
	mov	x3, x4
	str	xzr, [sp, #8]
	str	xzr, [sp]
	mov	x9, x1
	stur	x9, [x29, #-8]
	mov	x9, x2
	str	x9, [sp, #16]
	str	x0, [sp, #8]
	str	x8, [sp]
	mov	x0, #0                          ; =0x0
	bl	_$sSDMa
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF ; -- Begin function $s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF
	.p2align	2
_$s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF: ; @"$s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x0
	add	x0, sp, #8
	str	xzr, [sp, #8]
	str	x8, [sp, #8]
	bl	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh ; -- Begin function $sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh
	.globl	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh
	.weak_definition	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh
	.p2align	2
_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh: ; @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGWOh"
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	str	x0, [sp, #8]                    ; 8-byte Folded Spill
	ldr	x0, [x0]
	bl	_swift_bridgeObjectRelease
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
                                        ; -- End function
	.globl	_$s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF ; -- Begin function $s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF
	.p2align	2
_$s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF: ; @"$s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_MTLCreateSystemDefaultDevice
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF ; -- Begin function $s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF
	.p2align	2
_$s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF: ; @"$s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-8]
	mov	x8, x0
	stur	x8, [x29, #-8]
	bl	_swift_getObjectType
	ldr	x1, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_objc_msgSend$newCommandQueue
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF ; -- Begin function $s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF
	.p2align	2
_$s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF: ; @"$s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #24]                   ; 8-byte Folded Spill
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-8]
	stur	xzr, [x29, #-16]
	mov	x8, x0
	stur	x8, [x29, #-8]
	stur	x1, [x29, #-16]
	bl	_swift_getObjectType
	ldr	x1, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x2, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x0, [sp, #24]                   ; 8-byte Folded Reload
	mov	x3, #0                          ; =0x0
	bl	"_objc_msgSend$newBufferWithLength:options:"
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF ; -- Begin function $s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF
	.p2align	2
_$s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF: ; @"$s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-8]
	mov	x8, x0
	stur	x8, [x29, #-8]
	bl	_swift_getObjectType
	ldr	x1, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_objc_msgSend$commandBuffer
	; InlineAsm Start
	mov	x29, x29	; marker for objc_retainAutoreleaseReturnValue
	; InlineAsm End
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	b	_objc_retainAutoreleasedReturnValue
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI8contentsySvSo9MTLBuffer_pF ; -- Begin function $s8MetalABI8contentsySvSo9MTLBuffer_pF
	.p2align	2
_$s8MetalABI8contentsySvSo9MTLBuffer_pF: ; @"$s8MetalABI8contentsySvSo9MTLBuffer_pF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #8]                    ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-8]
	mov	x8, x0
	stur	x8, [x29, #-8]
	bl	_swift_getObjectType
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	bl	_swift_unknownObjectRetain
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	bl	_objc_msgSend$contents
	mov	x1, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	bl	_objc_autorelease
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI6lengthySiSo9MTLBuffer_pF ; -- Begin function $s8MetalABI6lengthySiSo9MTLBuffer_pF
	.p2align	2
_$s8MetalABI6lengthySiSo9MTLBuffer_pF:  ; @"$s8MetalABI6lengthySiSo9MTLBuffer_pF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #8]                    ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-8]
	mov	x8, x0
	stur	x8, [x29, #-8]
	bl	_swift_getObjectType
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	bl	_swift_unknownObjectRetain
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	bl	_objc_msgSend$length
	mov	x1, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	bl	_swift_unknownObjectRelease
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF ; -- Begin function $s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF
	.p2align	2
_$s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF: ; @"$s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
                                        ; implicit-def: $x8
	stur	xzr, [x29, #-8]
	mov	x8, x0
	stur	x8, [x29, #-8]
	bl	_swift_getObjectType
	ldr	x1, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_objc_msgSend$commit
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_swift_getObjectType
	ldr	x1, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_objc_msgSend$waitUntilCompleted
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5 ; -- Begin function $sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5
	.globl	_$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5
	.weak_definition	_$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5
	.p2align	2
_$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5: ; @"$sSa22_allocateUninitializedySayxG_SpyxGtSiFZSi_Tt0gq5"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-32]                 ; 8-byte Folded Spill
	adrp	x8, "l_.str.11.Fatal error"@PAGE
	add	x8, x8, "l_.str.11.Fatal error"@PAGEOFF
	stur	x8, [x29, #-24]                 ; 8-byte Folded Spill
	adrp	x8, "l_.str.36.Can't construct Array with count < 0"@PAGE
	add	x8, x8, "l_.str.36.Can't construct Array with count < 0"@PAGEOFF
	stur	x8, [x29, #-16]                 ; 8-byte Folded Spill
	adrp	x8, "l_.str.39.Swift/arm64e-apple-macos.swiftinterface"@PAGE
	add	x8, x8, "l_.str.39.Swift/arm64e-apple-macos.swiftinterface"@PAGEOFF
	stur	x8, [x29, #-8]                  ; 8-byte Folded Spill
	tbz	x0, #63, LBB35_2
	b	LBB35_1
LBB35_1:
	ldur	x6, [x29, #-8]                  ; 8-byte Folded Reload
	ldur	x3, [x29, #-16]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-24]                 ; 8-byte Folded Reload
	mov	x9, sp
	mov	w8, #2                          ; =0x2
	strb	w8, [x9]
	mov	w8, #903                        ; =0x387
                                        ; kill: def $x8 killed $w8
	str	x8, [x9, #8]
	mov	w8, #1                          ; =0x1
	str	w8, [x9, #16]
	mov	w8, #11                         ; =0xb
	mov	x1, x8
	mov	w5, #2                          ; =0x2
	mov	x2, x5
	mov	w8, #36                         ; =0x24
	mov	x4, x8
	mov	w8, #39                         ; =0x27
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB35_2:
	adrp	x0, __swiftEmptyArrayStorage@GOTPAGE
	ldr	x0, [x0, __swiftEmptyArrayStorage@GOTPAGEOFF]
	bl	_swift_retain
	ldur	x9, [x29, #-32]                 ; 8-byte Folded Reload
	mov	x8, #0                          ; =0x0
	subs	x8, x8, x9
	b.lt	LBB35_4
	b	LBB35_3
LBB35_3:
	adrp	x0, __swiftEmptyArrayStorage@GOTPAGE
	ldr	x0, [x0, __swiftEmptyArrayStorage@GOTPAGEOFF]
	str	x0, [sp, #40]                   ; 8-byte Folded Spill
	b	LBB35_5
LBB35_4:
	adrp	x0, __swiftEmptyArrayStorage@GOTPAGE
	ldr	x0, [x0, __swiftEmptyArrayStorage@GOTPAGEOFF]
	bl	_swift_release
	ldur	x0, [x29, #-32]                 ; 8-byte Folded Reload
	adrp	x1, _$sSiN@GOTPAGE
	ldr	x1, [x1, _$sSiN@GOTPAGEOFF]
	bl	_$sSa28_allocateBufferUninitialized15minimumCapacitys06_ArrayB0VyxGSi_tFZ
	str	x0, [sp, #32]                   ; 8-byte Folded Spill
	bl	_swift_bridgeObjectRetain
	ldr	x0, [sp, #32]                   ; 8-byte Folded Reload
	ldur	x8, [x29, #-32]                 ; 8-byte Folded Reload
	str	x8, [x0, #16]
	bl	_swift_release
	ldr	x0, [sp, #32]                   ; 8-byte Folded Reload
	str	x0, [sp, #40]                   ; 8-byte Folded Spill
	b	LBB35_5
LBB35_5:
	ldr	x0, [sp, #40]                   ; 8-byte Folded Reload
	mov	x8, x0
	add	x1, x8, #32
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	"_symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV" ; @"symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV"
	.weak_definition	"_symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV"
	.p2align	1, 0x0
"_symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV":
	.byte	2                               ; 0x2
Ltmp0:
	.long	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMn@GOT-Ltmp0
	.ascii	"Sg"
	.byte	0                               ; 0x0

	.private_extern	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd ; @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd"
	.section	__DATA,__data
	.globl	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd
	.weak_definition	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd
	.p2align	3, 0x0
_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMd:
	.space	8

	.private_extern	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR ; @"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR"
	.section	__TEXT,__const
	.globl	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR
	.weak_definition	_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR
	.p2align	3, 0x0
_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR:
	.long	"_symbolic _____Sg 13CoreAIRuntime7NDArrayV16InterleaveLayoutV"-_$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVSgMR
	.long	7                               ; 0x7

	.globl	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu ; @"$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu"
	.p2align	3, 0x0
_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu:
	.long	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF-_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu
	.long	48                              ; 0x30

	.globl	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu ; @"$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu"
	.p2align	3, 0x0
_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu:
	.long	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF-_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu
	.long	48                              ; 0x30

	.globl	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu ; @"$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu"
	.p2align	3, 0x0
_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu:
	.long	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF-_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu
	.long	64                              ; 0x40

	.private_extern	"_symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC" ; @"symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC"
	.weak_definition	"_symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC"
	.p2align	1, 0x0
"_symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC":
	.ascii	"SDySS"
	.byte	2                               ; 0x2
Ltmp1:
	.long	_$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMn@GOT-Ltmp1
	.byte	71
	.byte	0                               ; 0x0

	.private_extern	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd ; @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd"
	.section	__DATA,__data
	.globl	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd
	.weak_definition	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd
	.p2align	3, 0x0
_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMd:
	.space	8

	.private_extern	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR ; @"$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR"
	.section	__TEXT,__const
	.globl	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR
	.weak_definition	_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR
	.p2align	3, 0x0
_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR:
	.long	"_symbolic SDySS_____G 13CoreAIRuntime17InferenceFunctionV10AsyncValueC"-_$sSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGMR
	.long	11                              ; 0xb

	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_MetalABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftMetal

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.section	__TEXT,__cstring,cstring_literals
	.p2align	4, 0x0                          ; @".str.36.Can't construct Array with count < 0"
"l_.str.36.Can't construct Array with count < 0":
	.asciz	"Can't construct Array with count < 0"

	.p2align	4, 0x0                          ; @".str.39.Swift/arm64e-apple-macos.swiftinterface"
"l_.str.39.Swift/arm64e-apple-macos.swiftinterface":
	.asciz	"Swift/arm64e-apple-macos.swiftinterface"

"l_.str.11.Fatal error":                ; @".str.11.Fatal error"
	.asciz	"Fatal error"

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
	.long	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF-___swift_async_entry_functlets
	.long	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF-___swift_async_entry_functlets-4
	.long	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF-___swift_async_entry_functlets-8

	.section	__TEXT,__swift_as_ret,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_ret_functlets
___swift_async_ret_functlets:
	.long	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTQ0_-___swift_async_ret_functlets
	.long	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTQ0_-___swift_async_ret_functlets-4
	.long	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTQ1_-___swift_async_ret_functlets-8

	.section	__TEXT,__swift_as_cont,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_cont_functlets
___swift_async_cont_functlets:
	.long	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY0_-___swift_async_cont_functlets
	.long	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY2_-___swift_async_cont_functlets-4
	.long	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTY3_-___swift_async_cont_functlets-8

	.no_dead_strip	_$s8MetalABI10makeStreamy13CoreAIRuntime07ComputeD0CSo15MTLCommandQueue_pnF
	.no_dead_strip	_$s8MetalABI11inputBuffery13CoreAIRuntime17InferenceFunctionV10AsyncValueCSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF
	.no_dead_strip	_$s8MetalABI12outputBuffery13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVSo9MTLBuffer_pn_AC7NDArrayV10ScalarTypeOnSaySiGtF
	.no_dead_strip	_$s8MetalABI10arrayInputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCAC7NDArrayVnF
	.no_dead_strip	_$s8MetalABI11arrayOutputy13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVAC7NDArrayVnF
	.no_dead_strip	_$s8MetalABI6encodeySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0h7MutableI0VzSSAC13ComputeStreamCtKF
	.no_dead_strip	_$s8MetalABI10encodeBothySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGAE_AhE0i7MutableJ0VzSSAJzSSAC13ComputeStreamCtKF
	.no_dead_strip	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaF
	.no_dead_strip	_$s8MetalABI5drainyy13CoreAIRuntime13ComputeStreamCYaFTu
	.no_dead_strip	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKF
	.no_dead_strip	_$s8MetalABI10readyInputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV10AsyncValueCYaKFTu
	.no_dead_strip	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKF
	.no_dead_strip	_$s8MetalABI11readyOutputy13CoreAIRuntime7NDArrayVSgAC17InferenceFunctionV17AsyncMutableValueVnYaKFTu
	.no_dead_strip	_$s8MetalABI11emptyInputsSDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGyF
	.no_dead_strip	_$s8MetalABI11insertInputyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGz_AGSStF
	.no_dead_strip	_$s8MetalABI12removeOutputy13CoreAIRuntime17InferenceFunctionV10AsyncValueCSgSDySSAGGz_SStF
	.no_dead_strip	_$s8MetalABI18dictionaryMetadatayypXpxm_q_mtSHRzr0_lF
	.no_dead_strip	_$s8MetalABI13discardInputsyySDySS13CoreAIRuntime17InferenceFunctionV10AsyncValueCGnF
	.no_dead_strip	_$s8MetalABI13defaultDeviceSo9MTLDevice_pSgyF
	.no_dead_strip	_$s8MetalABI12commandQueueySo010MTLCommandD0_pSgSo9MTLDevice_pF
	.no_dead_strip	_$s8MetalABI12sharedBufferySo9MTLBuffer_pSgSo9MTLDevice_p_SitF
	.no_dead_strip	_$s8MetalABI13commandBufferySo010MTLCommandD0_pSgSo0E5Queue_pF
	.no_dead_strip	_$s8MetalABI8contentsySvSo9MTLBuffer_pF
	.no_dead_strip	_$s8MetalABI6lengthySiSo9MTLBuffer_pF
	.no_dead_strip	_$s8MetalABI13commitAndWaityySo16MTLCommandBuffer_pF
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_MetalABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalABI
	.no_dead_strip	___swift_reflection_version
	.no_dead_strip	___swift_async_entry_functlets
	.no_dead_strip	___swift_async_ret_functlets
	.no_dead_strip	___swift_async_cont_functlets
	.linker_option "-lswiftMetal"
	.linker_option "-lswiftCore"
	.linker_option "-lswift_StringProcessing"
	.linker_option "-lswift_Concurrency"
	.linker_option "-framework", "Metal"
	.linker_option "-lswift_DarwinFoundation2"
	.linker_option "-lswift_DarwinFoundation1"
	.linker_option "-lswift_Builtin_float"
	.linker_option "-lswiftFoundation"
	.linker_option "-framework", "Foundation"
	.linker_option "-lswift_DarwinFoundation3"
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
	.linker_option "-framework", "IOSurface"
	.linker_option "-framework", "CoreAI"
	.linker_option "-framework", "CoreAIDelegates"
	.linker_option "-framework", "CoreAIRuntime"
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

	.weak_reference __swift_FORCE_LOAD_$_swiftMetal
	.weak_reference __swift_FORCE_LOAD_$_swift_Builtin_float
	.weak_reference __swift_FORCE_LOAD_$_swiftFoundation
	.weak_reference __swift_FORCE_LOAD_$_swiftObjectiveC
	.weak_reference __swift_FORCE_LOAD_$_swiftCoreFoundation
	.weak_reference __swift_FORCE_LOAD_$_swiftDispatch
	.weak_reference __swift_FORCE_LOAD_$_swiftXPC
	.weak_reference __swift_FORCE_LOAD_$_swiftIOKit
.subsections_via_symbols
