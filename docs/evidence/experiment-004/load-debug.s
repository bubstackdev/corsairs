	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF ; -- Begin function $s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF
	.p2align	2
_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF: ; @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF"
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
	str	x1, [sp]                        ; 8-byte Folded Spill
	str	x1, [x22, #40]
	str	x0, [x22, #32]
	mov	x8, x22
	str	x8, [x22, #16]
	add	x8, x22, #24
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	str	xzr, [x22, #24]
	mov	x0, #0                          ; =0x0
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
	bl	_$s15CoreAIDelegates21SpecializationOptionsVMa
	ldur	x8, [x0, #-8]
	ldr	x8, [x8, #64]
	add	x8, x8, #15
	and	x0, x8, #0xfffffffffffffff0
	bl	_swift_task_alloc
	mov	x8, x0
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	str	x8, [x22, #48]
	bl	_$s10Foundation3URLVMa
	mov	x8, x0
	str	x8, [x22, #56]
	ldur	x8, [x0, #-8]
	mov	x9, x8
	str	x9, [x22, #64]
	ldr	x8, [x8, #64]
	add	x8, x8, #15
	and	x0, x8, #0xfffffffffffffff0
	bl	_swift_task_alloc
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x2, [sp, #16]                   ; 8-byte Folded Reload
	str	x0, [x22, #72]
	str	x1, [x22, #24]
	; InlineAsm Start
	; InlineAsm End
	ldr	x22, [x22, #16]
	adrp	x0, _$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_@PAGE
	add	x0, x0, _$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_@PAGEOFF
	mov	x1, x2
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	b	_swift_task_switch
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_
_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_: ; @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_"
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
	mov	x9, x22
	str	x9, [sp, #16]                   ; 8-byte Folded Spill
	ldr	x0, [x9, #72]
	ldr	x8, [x9, #64]
	ldr	x2, [x9, #56]
	ldr	x10, [x9, #48]
	str	x10, [sp, #8]                   ; 8-byte Folded Spill
	ldr	x1, [x9, #40]
	mov	x22, x9
	str	x22, [x9, #16]
	ldr	x8, [x8, #16]
	blr	x8
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	bl	_$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ
	adrp	x8, _$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu@GOTPAGE
	ldr	x8, [x8, _$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu@GOTPAGEOFF]
	ldr	w8, [x8, #4]
	mov	x0, x8
	bl	_swift_task_alloc
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	mov	x22, x0
	mov	x0, x22
	str	x0, [x8, #80]
	ldr	x9, [x8, #16]
	str	x9, [x22]
	adrp	x9, _$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_@PAGE
	add	x9, x9, _$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_@PAGEOFF
	str	x9, [x22, #8]
	ldr	x1, [x8, #72]
	ldr	x2, [x8, #48]
	ldr	x0, [x8, #32]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	b	_$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfC
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_
_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_: ; @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_"
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
	ldr	x8, [x22]
	mov	x9, x29
	sub	x9, x9, #8
	str	x8, [x9]
	ldr	x0, [x8, #80]
	ldr	x9, [x22]
	str	x9, [x8, #16]!
	mov	x9, x8
	str	x9, [sp, #8]                    ; 8-byte Folded Spill
	mov	x9, x8
	str	x9, [sp, #16]                   ; 8-byte Folded Spill
	str	x20, [x8, #72]
	bl	_swift_task_dealloc
	cbnz	x20, LBB2_2
	b	LBB2_1
LBB2_1:
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	ldr	x0, [x8, #56]
	ldr	x8, [x8, #32]
	str	x8, [sp]                        ; 8-byte Folded Spill
	bl	_swift_task_dealloc
	ldr	x0, [sp]                        ; 8-byte Folded Reload
	bl	_swift_task_dealloc
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x22, [x8]
	ldr	x0, [x22, #8]
	mov	x20, #0                         ; =0x0
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	br	x0
LBB2_2:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x22, [x8]
	adrp	x0, _$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_@PAGE
	add	x0, x0, _$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_@PAGEOFF
	mov	x2, #0                          ; =0x0
	mov	x1, x2
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	b	_swift_task_switch
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_
_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_: ; @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_"
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
	mov	x8, x22
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	ldr	x0, [x8, #72]
	ldr	x9, [x8, #48]
	str	x9, [sp, #8]                    ; 8-byte Folded Spill
	mov	x22, x8
	str	x22, [x8, #16]
	bl	_swift_task_dealloc
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	bl	_swift_task_dealloc
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	x9, [x8, #16]
	ldr	x0, [x9, #8]
	ldr	x22, [x8, #16]
	ldr	x20, [x8, #88]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF ; -- Begin function $s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF
	.p2align	2
_$s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF: ; @"$s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF"
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
	bl	_$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI10namesCountySiSaySSGF ; -- Begin function $s11LoadGateABI10namesCountySiSaySSGF
	.p2align	2
_$s11LoadGateABI10namesCountySiSaySSGF: ; @"$s11LoadGateABI10namesCountySiSaySSGF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	xzr, [sp, #8]
	mov	x8, x0
	str	x8, [sp, #8]
	adrp	x1, _$sSSN@GOTPAGE
	ldr	x1, [x1, _$sSSN@GOTPAGEOFF]
	bl	_$sSa5countSivg
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI6nameAtySSSaySSG_SitF ; -- Begin function $s11LoadGateABI6nameAtySSSaySSG_SitF
	.p2align	2
_$s11LoadGateABI6nameAtySSSaySSG_SitF:  ; @"$s11LoadGateABI6nameAtySSSaySSG_SitF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #8]                    ; 8-byte Folded Spill
	mov	x0, x1
	ldr	x1, [sp, #8]                    ; 8-byte Folded Reload
	stur	xzr, [x29, #-8]
	stur	xzr, [x29, #-16]
	mov	x8, x1
	stur	x8, [x29, #-8]
	stur	x0, [x29, #-16]
	add	x8, sp, #16
	adrp	x2, _$sSSN@GOTPAGE
	ldr	x2, [x2, _$sSSN@GOTPAGEOFF]
	bl	_$sSayxSicig
	ldr	x0, [sp, #16]
	ldr	x1, [sp, #24]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF ; -- Begin function $s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF
	.p2align	2
_$s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF: ; @"$s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	xzr, [sp]
	str	xzr, [sp, #8]
	str	x0, [sp]
	mov	x8, x1
	str	x8, [sp, #8]
	bl	_$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF ; -- Begin function $s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF
	.p2align	2
_$s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF: ; @"$s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	xzr, [sp, #8]
	mov	x8, x0
	str	x8, [sp, #8]
	adrp	x1, _$ss4Int8VN@GOTPAGE
	ldr	x1, [x1, _$ss4Int8VN@GOTPAGEOFF]
	bl	_$ss15ContiguousArrayV5countSivg
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF ; -- Begin function $s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF
	.p2align	2
_$s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF: ; @"$s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp]                        ; 8-byte Folded Spill
	mov	x0, x1
	ldr	x1, [sp]                        ; 8-byte Folded Reload
	stur	xzr, [x29, #-8]
	str	xzr, [sp, #16]
	mov	x8, x1
	stur	x8, [x29, #-8]
	str	x0, [sp, #16]
	add	x8, sp, #15
	adrp	x2, _$ss4Int8VN@GOTPAGE
	ldr	x2, [x2, _$ss4Int8VN@GOTPAGEOFF]
	bl	_$ss15ContiguousArrayVyxSicig
	ldrb	w0, [sp, #15]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI12consumeNamesyySaySSGnF ; -- Begin function $s11LoadGateABI12consumeNamesyySaySSGnF
	.p2align	2
_$s11LoadGateABI12consumeNamesyySaySSGnF: ; @"$s11LoadGateABI12consumeNamesyySaySSGnF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	xzr, [sp, #8]
	mov	x8, x0
	str	x8, [sp, #8]
	bl	_swift_bridgeObjectRelease
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF ; -- Begin function $s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF
	.p2align	2
_$s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF: ; @"$s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	xzr, [sp, #8]
	mov	x8, x0
	str	x8, [sp, #8]
	bl	_swift_release
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s11LoadGateABI13consumeStringyySSnF ; -- Begin function $s11LoadGateABI13consumeStringyySSnF
	.p2align	2
_$s11LoadGateABI13consumeStringyySSnF:  ; @"$s11LoadGateABI13consumeStringyySSnF"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x0
	mov	x0, x1
	str	xzr, [sp]
	str	xzr, [sp, #8]
	str	x8, [sp]
	mov	x1, x0
	str	x1, [sp, #8]
	bl	_swift_bridgeObjectRelease
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__const
	.globl	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu ; @"$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu"
	.p2align	3, 0x0
_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu:
	.long	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF-_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu
	.long	96                              ; 0x60

	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI"
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI:
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
	.long	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF-___swift_async_entry_functlets

	.section	__TEXT,__swift_as_ret,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_ret_functlets
___swift_async_ret_functlets:
	.long	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTQ1_-___swift_async_ret_functlets

	.section	__TEXT,__swift_as_cont,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_cont_functlets
___swift_async_cont_functlets:
	.long	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY0_-___swift_async_cont_functlets
	.long	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTY2_-___swift_async_cont_functlets-4

	.no_dead_strip	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKF
	.no_dead_strip	_$s11LoadGateABI14loadCPUOptionsy13CoreAIRuntime7AIModelV10Foundation3URLVYaKFTu
	.no_dead_strip	_$s11LoadGateABI10modelNamesySaySSG13CoreAIRuntime7AIModelVF
	.no_dead_strip	_$s11LoadGateABI10namesCountySiSaySSGF
	.no_dead_strip	_$s11LoadGateABI6nameAtySSSaySSG_SitF
	.no_dead_strip	_$s11LoadGateABI17nulTerminatedUTF8ys15ContiguousArrayVys4Int8VGSSF
	.no_dead_strip	_$s11LoadGateABI9utf8CountySis15ContiguousArrayVys4Int8VGF
	.no_dead_strip	_$s11LoadGateABI6utf8Atys4Int8Vs15ContiguousArrayVyADG_SitF
	.no_dead_strip	_$s11LoadGateABI12consumeNamesyySaySSGnF
	.no_dead_strip	_$s11LoadGateABI14consumeCStringyys15ContiguousArrayVys4Int8VGnF
	.no_dead_strip	_$s11LoadGateABI13consumeStringyySSnF
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_LoadGateABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_LoadGateABI
	.no_dead_strip	___swift_reflection_version
	.no_dead_strip	___swift_async_entry_functlets
	.no_dead_strip	___swift_async_ret_functlets
	.no_dead_strip	___swift_async_cont_functlets
	.linker_option "-lswiftFoundation"
	.linker_option "-framework", "Foundation"
	.linker_option "-lswiftCore"
	.linker_option "-lswift_DarwinFoundation3"
	.linker_option "-lswift_DarwinFoundation1"
	.linker_option "-lswift_Builtin_float"
	.linker_option "-lswift_DarwinFoundation2"
	.linker_option "-lswift_StringProcessing"
	.linker_option "-lswift_Concurrency"
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
	.linker_option "-framework", "CoreAI"
	.linker_option "-framework", "CoreAIDelegates"
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
