	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s14SuspendGateABI9yieldOnceyyYaF ; -- Begin function $s14SuspendGateABI9yieldOnceyyYaF
	.p2align	2
_$s14SuspendGateABI9yieldOnceyyYaF:     ; @"$s14SuspendGateABI9yieldOnceyyYaF"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
Lloh0:
	adrp	x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGE
Lloh1:
	ldr	x8, [x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGEOFF]
Lloh2:
	ldr	w0, [x8, #4]
	bl	_swift_task_alloc
	str	x0, [x22, #16]
Lloh3:
	adrp	x8, _$s14SuspendGateABI9yieldOnceyyYaFTQ0_@PAGE
Lloh4:
	add	x8, x8, _$s14SuspendGateABI9yieldOnceyyYaFTQ0_@PAGEOFF
	stp	x22, x8, [x0]
	mov	x22, x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$sScTss5NeverORszABRs_rlE5yieldyyYaFZ
	.loh AdrpAdd	Lloh3, Lloh4
	.loh AdrpLdrGotLdr	Lloh0, Lloh1, Lloh2
                                        ; -- End function
	.globl	_$s14SuspendGateABI10yieldTwiceyyYaF ; -- Begin function $s14SuspendGateABI10yieldTwiceyyYaF
	.p2align	2
_$s14SuspendGateABI10yieldTwiceyyYaF:   ; @"$s14SuspendGateABI10yieldTwiceyyYaF"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
Lloh5:
	adrp	x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGE
Lloh6:
	ldr	x8, [x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGEOFF]
Lloh7:
	ldr	w0, [x8, #4]
	bl	_swift_task_alloc
	str	x0, [x22, #16]
Lloh8:
	adrp	x8, _$s14SuspendGateABI10yieldTwiceyyYaFTQ0_@PAGE
Lloh9:
	add	x8, x8, _$s14SuspendGateABI10yieldTwiceyyYaFTQ0_@PAGEOFF
	stp	x22, x8, [x0]
	mov	x22, x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$sScTss5NeverORszABRs_rlE5yieldyyYaFZ
	.loh AdrpAdd	Lloh8, Lloh9
	.loh AdrpLdrGotLdr	Lloh5, Lloh6, Lloh7
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI10yieldTwiceyyYaFTQ0_
_$s14SuspendGateABI10yieldTwiceyyYaFTQ0_: ; @"$s14SuspendGateABI10yieldTwiceyyYaFTQ0_"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
	ldr	x20, [x22]
	stur	x20, [x29, #-8]
	ldr	x0, [x20, #16]
	ldr	x22, [x22]
	bl	_swift_task_dealloc
Lloh10:
	adrp	x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGE
Lloh11:
	ldr	x8, [x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGEOFF]
Lloh12:
	ldr	w0, [x8, #4]
	bl	_swift_task_alloc
	str	x0, [x20, #24]
Lloh13:
	adrp	x8, _$s14SuspendGateABI10yieldTwiceyyYaFTQ1_@PAGE
Lloh14:
	add	x8, x8, _$s14SuspendGateABI10yieldTwiceyyYaFTQ1_@PAGEOFF
	stp	x22, x8, [x0]
	mov	x22, x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$sScTss5NeverORszABRs_rlE5yieldyyYaFZ
	.loh AdrpAdd	Lloh13, Lloh14
	.loh AdrpLdrGotLdr	Lloh10, Lloh11, Lloh12
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI10yieldTwiceyyYaFTQ1_
_$s14SuspendGateABI10yieldTwiceyyYaFTQ1_: ; @"$s14SuspendGateABI10yieldTwiceyyYaFTQ1_"
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
	ldr	x0, [x8, #24]
	ldr	x22, [x22]
	bl	_swift_task_dealloc
	ldr	x0, [x22, #8]
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_$s14SuspendGateABI9sleepOnceyyYaKF ; -- Begin function $s14SuspendGateABI9sleepOnceyyYaKF
	.p2align	2
_$s14SuspendGateABI9sleepOnceyyYaKF:    ; @"$s14SuspendGateABI9sleepOnceyyYaKF"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
Lloh15:
	adrp	x8, _$sScTss5NeverORszABRs_rlE5sleep11nanosecondsys6UInt64V_tYaKFZTu@GOTPAGE
Lloh16:
	ldr	x8, [x8, _$sScTss5NeverORszABRs_rlE5sleep11nanosecondsys6UInt64V_tYaKFZTu@GOTPAGEOFF]
Lloh17:
	ldr	w0, [x8, #4]
	bl	_swift_task_alloc
	str	x0, [x22, #16]
Lloh18:
	adrp	x8, _$s14SuspendGateABI9sleepOnceyyYaKFTQ0_@PAGE
Lloh19:
	add	x8, x8, _$s14SuspendGateABI9sleepOnceyyYaKFTQ0_@PAGEOFF
	stp	x22, x8, [x0]
	mov	x22, x0
	mov	w0, #16960                      ; =0x4240
	movk	w0, #15, lsl #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$sScTss5NeverORszABRs_rlE5sleep11nanosecondsys6UInt64V_tYaKFZ
	.loh AdrpAdd	Lloh18, Lloh19
	.loh AdrpLdrGotLdr	Lloh15, Lloh16, Lloh17
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI9sleepOnceyyYaKFTQ0_
_$s14SuspendGateABI9sleepOnceyyYaKFTQ0_: ; @"$s14SuspendGateABI9sleepOnceyyYaKFTQ0_"
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
	.globl	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyF ; -- Begin function $s14SuspendGateABI11launchYieldScTyyts5NeverOGyF
	.p2align	2
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyF: ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyF"
	.cfi_startproc
; %bb.0:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
Lloh20:
	adrp	x0, _$sScPSgMd@PAGE
Lloh21:
	add	x0, x0, _$sScPSgMd@PAGEOFF
Lloh22:
	adrp	x1, _$sScPSgMR@PAGE
Lloh23:
	add	x1, x1, _$sScPSgMR@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledNameV2
	ldur	x8, [x0, #-8]
	ldr	x9, [x8, #64]
	add	x8, x9, #15
	and	x8, x8, #0xfffffffffffffff0
Lloh24:
	adrp	x16, ___chkstk_darwin@GOTPAGE
Lloh25:
	ldr	x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
	blr	x16
	mov	x9, sp
	sub	x20, x9, x8
	mov	sp, x20
	mov	x0, #0                          ; =0x0
	bl	_$sScPMa
	mov	x21, x0
	ldur	x22, [x0, #-8]
	ldr	x8, [x22, #56]
	mov	x0, x20
	mov	w1, #1                          ; =0x1
	mov	w2, #1                          ; =0x1
	mov	x3, x21
	blr	x8
Lloh26:
	adrp	x0, l_metadata@PAGE+16
Lloh27:
	add	x0, x0, l_metadata@PAGEOFF+16
	mov	w1, #32                         ; =0x20
	mov	w2, #7                          ; =0x7
	bl	_swift_allocObject
	mov	x19, x0
	stp	xzr, xzr, [x0, #16]
	ldr	x8, [x22, #48]
	mov	x0, x20
	mov	w1, #1                          ; =0x1
	mov	x2, x21
	blr	x8
	cmp	w0, #1
	b.ne	LBB6_2
; %bb.1:
	mov	w21, #4096                      ; =0x1000
	b	LBB6_3
LBB6_2:
	bl	_$sScP8rawValues5UInt8Vvg
                                        ; kill: def $w0 killed $w0 def $x0
	mov	w21, #4096                      ; =0x1000
	bfxil	x21, x0, #0, #8
LBB6_3:
Lloh28:
	adrp	x0, l_metadata.9@PAGE+16
Lloh29:
	add	x0, x0, l_metadata.9@PAGEOFF+16
	mov	w1, #32                         ; =0x20
	mov	w2, #7                          ; =0x7
	bl	_swift_allocObject
	mov	x4, x0
Lloh30:
	adrp	x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATu@PAGE
Lloh31:
	add	x8, x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATu@PAGEOFF
	stp	x8, x19, [x0, #16]
Lloh32:
	adrp	x8, _$sytN@GOTPAGE
Lloh33:
	ldr	x8, [x8, _$sytN@GOTPAGEOFF]
Lloh34:
	adrp	x3, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu@PAGE
Lloh35:
	add	x3, x3, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu@PAGEOFF
	add	x2, x8, #8
	mov	x0, x21
	mov	x1, #0                          ; =0x0
	bl	_swift_task_create
	mov	x19, x0
	mov	x0, x20
	bl	_$sScPSgWOh
	mov	x0, x19
	sub	sp, x29, #32
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
	ret
	.loh AdrpAdd	Lloh26, Lloh27
	.loh AdrpAdd	Lloh22, Lloh23
	.loh AdrpAdd	Lloh20, Lloh21
	.loh AdrpAdd	Lloh34, Lloh35
	.loh AdrpLdrGot	Lloh32, Lloh33
	.loh AdrpAdd	Lloh30, Lloh31
	.loh AdrpAdd	Lloh28, Lloh29
	.loh AdrpLdrGot	Lloh24, Lloh25
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
	b.eq	LBB7_2
; %bb.1:
	ldr	x9, [x1]
	asr	x8, x9, #32
	add	x0, x1, w9, sxtw
	mov	x1, x8
	mov	x2, #0                          ; =0x0
	mov	x3, #0                          ; =0x0
	bl	_swift_getTypeByMangledNameInContext2
	str	x0, [x19]
LBB7_2:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_: ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
Lloh36:
	adrp	x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGE
Lloh37:
	ldr	x8, [x8, _$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu@GOTPAGEOFF]
Lloh38:
	ldr	w0, [x8, #4]
	bl	_swift_task_alloc
	str	x0, [x22, #16]
Lloh39:
	adrp	x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_@PAGE
Lloh40:
	add	x8, x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_@PAGEOFF
	stp	x22, x8, [x0]
	mov	x22, x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$sScTss5NeverORszABRs_rlE5yieldyyYaFZ
	.loh AdrpAdd	Lloh39, Lloh40
	.loh AdrpLdrGotLdr	Lloh36, Lloh37, Lloh38
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_: ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_"
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
	.p2align	2                               ; -- Begin function __swift_closure_destructor
___swift_closure_destructor:            ; @__swift_closure_destructor
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	ldr	x0, [x20, #16]
	bl	_swift_unknownObjectRelease
	mov	x0, x20
	mov	w1, #32                         ; =0x20
	mov	w2, #7                          ; =0x7
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	b	_swift_deallocObject
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TA
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TA: ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TA"
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
Lloh41:
	adrp	x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_Tu@PAGE+4
Lloh42:
	ldr	w0, [x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_Tu@PAGEOFF+4]
	bl	_swift_task_alloc
	str	x0, [x22, #16]
Lloh43:
	adrp	x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATQ0_@PAGE
Lloh44:
	add	x8, x8, _$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATQ0_@PAGEOFF
	stp	x22, x8, [x0]
	mov	x22, x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	b	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_
	.loh AdrpAdd	Lloh43, Lloh44
	.loh AdrpLdr	Lloh41, Lloh42
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATQ0_
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATQ0_: ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATQ0_"
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
	.private_extern	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5 ; -- Begin function $sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5
	.globl	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5
	.weak_definition	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5
	.p2align	2
_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5: ; @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	sub	sp, sp, #48
	str	x19, [sp, #16]                  ; 8-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	str	x22, [sp, #24]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -32
	mov	x20, x2
	mov	x19, x0
	ldp	w8, w0, [x1]
                                        ; kill: def $w8 killed $w8 def $x8
	sxtw	x8, w8
	add	x1, x8, x1
	str	x1, [sp, #8]                    ; 8-byte Folded Spill
	bl	_swift_task_alloc
	mov	x8, x0
	str	x0, [x22, #16]
Lloh45:
	adrp	x9, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_@PAGE
Lloh46:
	add	x9, x9, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_@PAGEOFF
	stp	x22, x9, [x0]
	mov	x0, x19
	mov	x22, x8
	ldp	x1, x19, [sp, #8]               ; 16-byte Folded Reload
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #48
	br	x1
	.loh AdrpAdd	Lloh45, Lloh46
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_
_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_: ; @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_"
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
	mov	x20, #0                         ; =0x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function __swift_closure_destructor.8
___swift_closure_destructor.8:          ; @__swift_closure_destructor.8
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	ldr	x0, [x20, #24]
	bl	_swift_release
	mov	x0, x20
	mov	w1, #32                         ; =0x20
	mov	w2, #7                          ; =0x7
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	b	_swift_deallocObject
                                        ; -- End function
	.p2align	2                               ; -- Begin function $sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TA
_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TA: ; @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TA"
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	str	x23, [sp, #-48]!                ; 8-byte Folded Spill
	stp	x21, x19, [sp, #8]              ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	str	x22, [sp, #24]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -32
	.cfi_offset w21, -40
	.cfi_offset w23, -48
	mov	x19, x0
	ldp	x21, x20, [x20, #16]
Lloh47:
	adrp	x23, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu@PAGE
Lloh48:
	add	x23, x23, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu@PAGEOFF
	ldr	w0, [x23, #4]
	bl	_swift_task_alloc
	mov	x8, x0
	str	x0, [x22, #16]
Lloh49:
	adrp	x9, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_@PAGE
Lloh50:
	add	x9, x9, _$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_@PAGEOFF
	stp	x22, x9, [x0]
	ldrsw	x9, [x23]
	add	x3, x9, x23
	mov	x0, x19
	mov	x22, x8
	mov	x1, x21
	mov	x2, x20
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x21, x19, [sp, #8]              ; 16-byte Folded Reload
	ldr	x23, [sp], #48                  ; 8-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	br	x3
	.loh AdrpAdd	Lloh49, Lloh50
	.loh AdrpAdd	Lloh47, Lloh48
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function $sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_
_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_: ; @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATQ0_"
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
Lloh51:
	adrp	x0, _$sScPSgMd@PAGE
Lloh52:
	add	x0, x0, _$sScPSgMd@PAGEOFF
Lloh53:
	adrp	x1, _$sScPSgMR@PAGE
Lloh54:
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
	.loh AdrpAdd	Lloh53, Lloh54
	.loh AdrpAdd	Lloh51, Lloh52
                                        ; -- End function
	.p2align	2                               ; -- Begin function $s14SuspendGateABI9yieldOnceyyYaFTQ0_
_$s14SuspendGateABI9yieldOnceyyYaFTQ0_: ; @"$s14SuspendGateABI9yieldOnceyyYaFTQ0_"
	.cfi_startproc
; %bb.0:
	b	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__const
	.globl	_$s14SuspendGateABI9yieldOnceyyYaFTu ; @"$s14SuspendGateABI9yieldOnceyyYaFTu"
	.p2align	3, 0x0
_$s14SuspendGateABI9yieldOnceyyYaFTu:
	.long	_$s14SuspendGateABI9yieldOnceyyYaF-_$s14SuspendGateABI9yieldOnceyyYaFTu
	.long	32                              ; 0x20

	.globl	_$s14SuspendGateABI10yieldTwiceyyYaFTu ; @"$s14SuspendGateABI10yieldTwiceyyYaFTu"
	.p2align	3, 0x0
_$s14SuspendGateABI10yieldTwiceyyYaFTu:
	.long	_$s14SuspendGateABI10yieldTwiceyyYaF-_$s14SuspendGateABI10yieldTwiceyyYaFTu
	.long	32                              ; 0x20

	.globl	_$s14SuspendGateABI9sleepOnceyyYaKFTu ; @"$s14SuspendGateABI9sleepOnceyyYaKFTu"
	.p2align	3, 0x0
_$s14SuspendGateABI9sleepOnceyyYaKFTu:
	.long	_$s14SuspendGateABI9sleepOnceyyYaKF-_$s14SuspendGateABI9sleepOnceyyYaKFTu
	.long	32                              ; 0x20

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

	.p2align	3, 0x0                          ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_Tu"
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_Tu:
	.long	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_-_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_Tu
	.long	32                              ; 0x20

	.private_extern	"_symbolic ScA_pSg"     ; @"symbolic ScA_pSg"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic ScA_pSg"
	.weak_definition	"_symbolic ScA_pSg"
	.p2align	1, 0x0
"_symbolic ScA_pSg":
	.ascii	"ScA_pSg"
	.byte	0                               ; 0x0

	.section	__TEXT,__swift5_capture
	.p2align	2, 0x0                          ; @"\01l__swift5_reflection_descriptor"
l__swift5_reflection_descriptor:
	.long	1                               ; 0x1
	.long	0                               ; 0x0
	.long	0                               ; 0x0
	.long	"_symbolic ScA_pSg"-l__swift5_reflection_descriptor-12

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
	.p2align	3, 0x0                          ; @"$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATu"
_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATu:
	.long	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TA-_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TATu
	.long	32                              ; 0x20

	.private_extern	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu ; @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu"
	.globl	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu
	.weak_definition	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu
	.p2align	3, 0x0
_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu:
	.long	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5-_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5Tu
	.long	32                              ; 0x20

	.private_extern	"_symbolic ytIeAgHr_"   ; @"symbolic ytIeAgHr_"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic ytIeAgHr_"
	.weak_definition	"_symbolic ytIeAgHr_"
	.p2align	1, 0x0
"_symbolic ytIeAgHr_":
	.ascii	"ytIeAgHr_"
	.byte	0                               ; 0x0

	.section	__TEXT,__swift5_capture
	.p2align	2, 0x0                          ; @"\01l__swift5_reflection_descriptor.7"
l__swift5_reflection_descriptor.7:
	.long	1                               ; 0x1
	.long	0                               ; 0x0
	.long	0                               ; 0x0
	.long	"_symbolic ytIeAgHr_"-l__swift5_reflection_descriptor.7-12

	.section	__DATA,__const
	.p2align	3, 0x0                          ; @metadata.9
l_metadata.9:
	.quad	___swift_closure_destructor.8
	.quad	0
	.quad	1024                            ; 0x400
	.long	16                              ; 0x10
	.space	4
	.quad	l__swift5_reflection_descriptor.7

	.section	__TEXT,__const
	.p2align	3, 0x0                          ; @"$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu"
_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu:
	.long	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TA-_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TATu
	.long	32                              ; 0x20

	.private_extern	___swift_reflection_version ; @__swift_reflection_version
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3                               ; 0x3

	.section	__TEXT,__swift_as_entry,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_entry_functlets
___swift_async_entry_functlets:
	.long	_$s14SuspendGateABI9yieldOnceyyYaF-___swift_async_entry_functlets
	.long	_$s14SuspendGateABI10yieldTwiceyyYaF-___swift_async_entry_functlets-4
	.long	_$s14SuspendGateABI9sleepOnceyyYaKF-___swift_async_entry_functlets-8
	.long	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_-___swift_async_entry_functlets-12
	.long	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5-___swift_async_entry_functlets-16

	.section	__TEXT,__swift_as_ret,coalesced,no_dead_strip
	.p2align	2, 0x0                          ; @__swift_async_ret_functlets
___swift_async_ret_functlets:
	.long	_$s14SuspendGateABI9yieldOnceyyYaFTQ0_-___swift_async_ret_functlets
	.long	_$s14SuspendGateABI10yieldTwiceyyYaFTQ0_-___swift_async_ret_functlets-4
	.long	_$s14SuspendGateABI10yieldTwiceyyYaFTQ1_-___swift_async_ret_functlets-8
	.long	_$s14SuspendGateABI9sleepOnceyyYaKFTQ0_-___swift_async_ret_functlets-12
	.long	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyFyyYacfU_TQ0_-___swift_async_ret_functlets-16
	.long	_$sxIeAgHr_xs5Error_pIegHrzo_s8SendableRzs5NeverORs_r0_lTRyt_Tg5TQ0_-___swift_async_ret_functlets-20

	.no_dead_strip	l__swift5_reflection_descriptor
	.no_dead_strip	l__swift5_reflection_descriptor.7
	.no_dead_strip	_$s14SuspendGateABI10yieldTwiceyyYaF
	.no_dead_strip	_$s14SuspendGateABI10yieldTwiceyyYaFTu
	.no_dead_strip	_$s14SuspendGateABI11launchYieldScTyyts5NeverOGyF
	.no_dead_strip	_$s14SuspendGateABI9sleepOnceyyYaKF
	.no_dead_strip	_$s14SuspendGateABI9sleepOnceyyYaKFTu
	.no_dead_strip	_$s14SuspendGateABI9yieldOnceyyYaF
	.no_dead_strip	_$s14SuspendGateABI9yieldOnceyyYaFTu
	.no_dead_strip	___swift_reflection_version
	.no_dead_strip	___swift_async_entry_functlets
	.no_dead_strip	___swift_async_ret_functlets
	.linker_option "-lswift_Concurrency"
	.linker_option "-lswiftCore"
	.linker_option "-lswift_StringProcessing"
	.linker_option "-lobjc"
	.section	__DATA,__objc_imageinfo,regular,no_dead_strip
L_OBJC_IMAGE_INFO:
	.long	0
	.long	100927296

.subsections_via_symbols
