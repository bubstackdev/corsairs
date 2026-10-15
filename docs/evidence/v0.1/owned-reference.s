	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF ; -- Begin function $s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF
	.p2align	2
_$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF: ; @"$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF"
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
	.globl	_$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF ; -- Begin function $s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF
	.p2align	2
_$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF: ; @"$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF"
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
	bl	_$s13CoreAIRuntime17InferenceFunctionV10descriptorAA0cD10DescriptorVvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF ; -- Begin function $s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF
	.p2align	2
_$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF: ; @"$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF"
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
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV4nameSSvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF ; -- Begin function $s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.p2align	2
_$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF: ; @"$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF"
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
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV10inputNamesSaySSGvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF ; -- Begin function $s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.p2align	2
_$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF: ; @"$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF"
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
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV11outputNamesSaySSGvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF ; -- Begin function $s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.p2align	2
_$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF: ; @"$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF"
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
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV10stateNamesSaySSGvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF ; -- Begin function $s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.p2align	2
_$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF: ; @"$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	mov	x0, x1
	mov	x1, x2
	str	xzr, [sp, #24]
	str	xzr, [sp, #8]
	str	xzr, [sp, #16]
	mov	x9, x20
	str	x9, [sp, #24]
	str	x0, [sp, #8]
	mov	x2, x1
	str	x2, [sp, #16]
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV05inputE02ofAA0C5ValueV0E0OSgSS_tF
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF ; -- Begin function $s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.p2align	2
_$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF: ; @"$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	mov	x0, x1
	mov	x1, x2
	str	xzr, [sp, #24]
	str	xzr, [sp, #8]
	str	xzr, [sp, #16]
	mov	x9, x20
	str	x9, [sp, #24]
	str	x0, [sp, #8]
	mov	x2, x1
	str	x2, [sp, #16]
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV06outputE02ofAA0C5ValueV0E0OSgSS_tF
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF ; -- Begin function $s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.p2align	2
_$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF: ; @"$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	mov	x0, x1
	mov	x1, x2
	str	xzr, [sp, #24]
	str	xzr, [sp, #8]
	str	xzr, [sp, #16]
	mov	x9, x20
	str	x9, [sp, #24]
	str	x0, [sp, #8]
	mov	x2, x1
	str	x2, [sp, #16]
	bl	_$s13CoreAIRuntime27InferenceFunctionDescriptorV05stateE02ofAA0C5ValueV0E0OSgSS_tF
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF ; -- Begin function $s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF
	.p2align	2
_$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF: ; @"$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF"
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	sub	sp, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x8, [x29, #-120]                ; 8-byte Folded Spill
	stur	x0, [x29, #-112]                ; 8-byte Folded Spill
	stur	xzr, [x29, #-8]
	stur	xzr, [x29, #-16]
	stur	xzr, [x29, #-8]
	mov	x0, #0                          ; =0x0
	stur	x0, [x29, #-104]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime17NDArrayDescriptorVMa
	mov	x8, x0
	ldur	x0, [x29, #-104]                ; 8-byte Folded Reload
	stur	x8, [x29, #-96]                 ; 8-byte Folded Spill
	ldur	x8, [x8, #-8]
	stur	x8, [x29, #-88]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-80]                 ; 8-byte Folded Spill
Lloh2:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh3:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-80]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-72]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x8, [x29, #-8]
	bl	_$s13CoreAIRuntime14InferenceValueV10DescriptorOMa
	stur	x0, [x29, #-64]                 ; 8-byte Folded Spill
	ldur	x8, [x0, #-8]
	stur	x8, [x29, #-56]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x9, x8, #0
	add	x9, x9, #15
	and	x9, x9, #0xfffffffffffffff0
	stur	x9, [x29, #-48]                 ; 8-byte Folded Spill
Lloh4:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh5:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x10, [x29, #-48]                ; 8-byte Folded Reload
	mov	x9, sp
	subs	x0, x9, x10
	stur	x0, [x29, #-40]                 ; 8-byte Folded Spill
	mov	sp, x0
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-32]                 ; 8-byte Folded Spill
Lloh6:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh7:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-32]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-24]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x8, [x29, #-16]
	b	LBB9_1
LBB9_1:
	ldur	x2, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-24]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-112]                ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	stur	x8, [x29, #-136]                ; 8-byte Folded Spill
	blr	x8
	ldur	x1, [x29, #-24]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-136]                ; 8-byte Folded Reload
	ldur	x2, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-40]                 ; 8-byte Folded Reload
	blr	x8
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-40]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #88]
	blr	x8
	stur	w0, [x29, #-124]                ; 4-byte Folded Spill
	adrp	x8, _$s13CoreAIRuntime14InferenceValueV10DescriptorO7ndArrayyAeA07NDArrayE0VcAEmFWC@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime14InferenceValueV10DescriptorO7ndArrayyAeA07NDArrayE0VcAEmFWC@GOTPAGEOFF]
	ldr	w8, [x8]
	subs	w8, w0, w8
	b.eq	LBB9_3
	b	LBB9_2
LBB9_2:
	ldur	w8, [x29, #-124]                ; 4-byte Folded Reload
	adrp	x9, _$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC@GOTPAGE
	ldr	x9, [x9, _$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC@GOTPAGEOFF]
	ldr	w9, [x9]
	subs	w8, w8, w9
	b.eq	LBB9_4
	b	LBB9_5
LBB9_3:
	ldur	x0, [x29, #-40]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #96]
	blr	x8
	ldur	x1, [x29, #-40]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-96]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	blr	x8
	ldur	x8, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-96]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-120]                ; 8-byte Folded Reload
	mov	x9, x1
	stur	x9, [x29, #-8]
	ldr	x8, [x8, #16]
	blr	x8
	ldur	x8, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x3, [x29, #-96]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-120]                ; 8-byte Folded Reload
	ldr	x8, [x8, #56]
	mov	w1, #0                          ; =0x0
	mov	w2, #1                          ; =0x1
	blr	x8
	ldur	x8, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-96]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #8]
	blr	x8
	b	LBB9_6
LBB9_4:
	ldur	x0, [x29, #-40]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #96]
	blr	x8
	ldur	x8, [x29, #-88]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-120]                ; 8-byte Folded Reload
	ldur	x3, [x29, #-96]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #56]
	mov	w2, #1                          ; =0x1
	mov	x1, x2
	blr	x8
	mov	x0, #0                          ; =0x0
	bl	_$s13CoreAIRuntime15ImageDescriptorVMa
	mov	x1, x0
	ldur	x0, [x29, #-40]                 ; 8-byte Folded Reload
	ldur	x8, [x1, #-8]
	ldr	x8, [x8, #8]
	blr	x8
	b	LBB9_6
LBB9_5:
	ldur	x3, [x29, #-96]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-120]                ; 8-byte Folded Reload
	ldur	x8, [x29, #-88]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #56]
	mov	w2, #1                          ; =0x1
	mov	x1, x2
	blr	x8
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-40]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-64]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #8]
	blr	x8
	b	LBB9_6
LBB9_6:
	mov	sp, x29
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh2, Lloh3
	.loh AdrpLdrGot	Lloh4, Lloh5
	.loh AdrpLdrGot	Lloh6, Lloh7
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF ; -- Begin function $s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF
	.p2align	2
_$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF: ; @"$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF"
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
	bl	_$s13CoreAIRuntime17NDArrayDescriptorV5shapeSaySiGvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF ; -- Begin function $s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF
	.p2align	2
_$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF: ; @"$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF"
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
	bl	_$s13CoreAIRuntime17NDArrayDescriptorV10scalarTypeAA0C0V06ScalarF0Ovg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF ; -- Begin function $s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF
	.p2align	2
_$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF: ; @"$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF"
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	stur	x0, [x29, #-88]                 ; 8-byte Folded Spill
	stur	x1, [x29, #-96]                 ; 8-byte Folded Spill
	stur	x2, [x29, #-104]                ; 8-byte Folded Spill
	stur	xzr, [x29, #-24]
	stur	xzr, [x29, #-40]
	stur	xzr, [x29, #-32]
	stur	xzr, [x29, #-48]
	mov	x0, #0                          ; =0x0
	stur	x0, [x29, #-128]                ; 8-byte Folded Spill
	bl	_$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa
	mov	x8, x0
	ldur	x0, [x29, #-128]                ; 8-byte Folded Reload
	ldur	x8, [x8, #-8]
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-120]                ; 8-byte Folded Spill
Lloh8:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh9:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-120]                ; 8-byte Folded Reload
	mov	x8, sp
	subs	x1, x8, x9
	stur	x1, [x29, #-112]                ; 8-byte Folded Spill
	mov	sp, x1
	bl	_$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa
	ldur	x2, [x29, #-104]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-96]                 ; 8-byte Folded Reload
	mov	x8, x0
	ldur	x0, [x29, #-88]                 ; 8-byte Folded Reload
	stur	x8, [x29, #-80]                 ; 8-byte Folded Spill
	ldur	x8, [x8, #-8]
	stur	x8, [x29, #-72]                 ; 8-byte Folded Spill
	ldr	x8, [x8, #64]
	lsr	x8, x8, #0
	add	x8, x8, #15
	and	x9, x8, #0xfffffffffffffff0
	stur	x9, [x29, #-64]                 ; 8-byte Folded Spill
Lloh10:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh11:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	ldur	x9, [x29, #-64]                 ; 8-byte Folded Reload
	mov	x8, sp
	subs	x8, x8, x9
	stur	x8, [x29, #-56]                 ; 8-byte Folded Spill
	mov	sp, x8
	stur	x0, [x29, #-24]
	stur	x1, [x29, #-40]
	stur	x2, [x29, #-32]
	stur	x8, [x29, #-48]
	b	LBB12_1
LBB12_1:
	ldur	x8, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x20, [x29, #-88]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC
	ldur	x8, [x29, #-112]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF
	ldur	x20, [x29, #-56]                ; 8-byte Folded Reload
	ldur	x0, [x29, #-112]                ; 8-byte Folded Reload
	ldur	x1, [x29, #-96]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-104]                ; 8-byte Folded Reload
	bl	_$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryAA7NDArrayV0E7RawViewVn_SStF
	ldur	x8, [x29, #-72]                 ; 8-byte Folded Reload
	ldur	x0, [x29, #-56]                 ; 8-byte Folded Reload
	ldur	x1, [x29, #-80]                 ; 8-byte Folded Reload
	ldr	x8, [x8, #8]
	blr	x8
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh8, Lloh9
	.loh AdrpLdrGot	Lloh10, Lloh11
	.cfi_endproc
                                        ; -- End function
	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI"
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI:
	.quad	__swift_FORCE_LOAD_$_swiftMetal

	.private_extern	___swift_reflection_version ; @__swift_reflection_version
	.section	__TEXT,__const
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3                               ; 0x3

	.no_dead_strip	_$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF
	.no_dead_strip	_$s8OwnedABI10gpuOptions15CoreAIDelegates014SpecializationD0VyF
	.no_dead_strip	_$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF
	.no_dead_strip	_$s8OwnedABI18functionDescriptory13CoreAIRuntime017InferenceFunctionD0VAC0gH0VF
	.no_dead_strip	_$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI14descriptorNameySS13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI10inputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI11outputNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI10stateNamesySaySSG13CoreAIRuntime27InferenceFunctionDescriptorVF
	.no_dead_strip	_$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.no_dead_strip	_$s8OwnedABI15inputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.no_dead_strip	_$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.no_dead_strip	_$s8OwnedABI16outputDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.no_dead_strip	_$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.no_dead_strip	_$s8OwnedABI15stateDescriptory13CoreAIRuntime14InferenceValueV0D0OSgAC0g8FunctionD0V_SStF
	.no_dead_strip	_$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF
	.no_dead_strip	_$s8OwnedABI17ndarrayDescriptory13CoreAIRuntime07NDArrayD0VSgAC14InferenceValueV0D0OnF
	.no_dead_strip	_$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF
	.no_dead_strip	_$s8OwnedABI5shapeySaySiG13CoreAIRuntime17NDArrayDescriptorVF
	.no_dead_strip	_$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF
	.no_dead_strip	_$s8OwnedABI6scalary13CoreAIRuntime7NDArrayV10ScalarTypeOAC0F10DescriptorVF
	.no_dead_strip	_$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF
	.no_dead_strip	_$s8OwnedABI13insertMutableyy13CoreAIRuntime7NDArrayVz_SStF
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_OwnedABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_OwnedABI
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
