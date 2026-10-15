	.build_version macos, 27, 0	sdk_version 27, 0
                                        ; Start of file scope inline assembly
	.section	__TEXT,__const
	.p2align	3, 0x0
_oracle_descriptor:
	.long	_oracle_entry-_oracle_descriptor
	.long	64

                                        ; End of file scope inline assembly
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_oracle_entry                   ; -- Begin function oracle_entry
	.p2align	2
_oracle_entry:                          ; @oracle_entry
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
	ldr	x20, [x22, #32]
	ldr	w8, [x20, #116]
	add	w8, w8, #1
	str	w8, [x20, #116]
Lloh0:
	adrp	x8, _current_task@PAGE
Lloh1:
	ldr	x8, [x8, _current_task@PAGEOFF]
	blr	x8
	ldr	x8, [x20, #136]
	cmp	x0, x8
	ldr	w8, [x20, #124]
	cinc	w8, w8, eq
	str	w8, [x20, #124]
	bl	_pthread_self
	str	x0, [x20, #144]
Lloh2:
	adrp	x8, _task_alloc@PAGE
Lloh3:
	ldr	x8, [x8, _task_alloc@PAGEOFF]
Lloh4:
	adrp	x9, _yield_context_size@PAGE
Lloh5:
	ldr	w0, [x9, _yield_context_size@PAGEOFF]
	blr	x8
	str	x0, [x22, #16]
Lloh6:
	adrp	x8, _yield_resume@PAGE
Lloh7:
	add	x8, x8, _yield_resume@PAGEOFF
	stp	x22, x8, [x0]
Lloh8:
	adrp	x8, _yield_entry@PAGE
Lloh9:
	ldr	x1, [x8, _yield_entry@PAGEOFF]
	mov	x22, x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	add	sp, sp, #32
	br	x1
	.loh AdrpLdr	Lloh8, Lloh9
	.loh AdrpAdd	Lloh6, Lloh7
	.loh AdrpLdr	Lloh4, Lloh5
	.loh AdrpLdr	Lloh2, Lloh3
	.loh AdrpLdr	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function yield_resume
_yield_resume:                          ; @yield_resume
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	str	x19, [sp, #-32]!                ; 8-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -32
	mov	x20, x22
	ldr	x22, [x22]
	ldr	x19, [x22, #32]
	ldr	w8, [x19, #120]
	add	w8, w8, #1
	str	w8, [x19, #120]
Lloh10:
	adrp	x8, _current_task@PAGE
Lloh11:
	ldr	x8, [x8, _current_task@PAGEOFF]
	blr	x8
	ldr	x8, [x19, #136]
	cmp	x0, x8
	ldr	w8, [x19, #124]
	cinc	w8, w8, eq
	str	w8, [x19, #124]
	bl	_pthread_self
	str	x0, [x19, #152]
Lloh12:
	adrp	x8, _task_dealloc@PAGE
Lloh13:
	ldr	x8, [x8, _task_dealloc@PAGEOFF]
	mov	x0, x20
	blr	x8
	ldr	x0, [x22, #8]
	mov	x20, #0                         ; =0x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldr	x19, [sp], #32                  ; 8-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	br	x0
	.loh AdrpLdr	Lloh12, Lloh13
	.loh AdrpLdr	Lloh10, Lloh11
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #144
	stp	x26, x25, [sp, #64]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #80]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #96]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #112]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #128]            ; 16-byte Folded Spill
	add	x29, sp, #128
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
Lloh14:
	adrp	x0, l_.str@PAGE
Lloh15:
	add	x0, x0, l_.str@PAGEOFF
	mov	w1, #6                          ; =0x6
	bl	_dlopen
	mov	x20, x0
Lloh16:
	adrp	x0, l_.str.1@PAGE
Lloh17:
	add	x0, x0, l_.str.1@PAGEOFF
	mov	w1, #6                          ; =0x6
	bl	_dlopen
	cmp	x20, #0
	ccmp	x0, #0, #4, ne
	b.ne	LBB2_2
; %bb.1:
Lloh18:
	adrp	x8, ___stderrp@GOTPAGE
Lloh19:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh20:
	ldr	x19, [x8]
	bl	_dlerror
	str	x0, [sp]
Lloh21:
	adrp	x1, l_.str.2@PAGE
Lloh22:
	add	x1, x1, l_.str.2@PAGEOFF
	mov	x0, x19
	bl	_fprintf
	mov	w0, #2                          ; =0x2
	b	LBB2_14
LBB2_2:
	mov	x24, x0
Lloh23:
	adrp	x1, l_.str.3@PAGE
Lloh24:
	add	x1, x1, l_.str.3@PAGEOFF
	mov	x0, x20
	bl	_dlsym
	cbz	x0, LBB2_28
; %bb.3:
	mov	x22, x0
Lloh25:
	adrp	x1, l_.str.4@PAGE
Lloh26:
	add	x1, x1, l_.str.4@PAGEOFF
	mov	x0, x20
	bl	_dlsym
	cbz	x0, LBB2_29
; %bb.4:
	mov	x21, x0
Lloh27:
	adrp	x1, l_.str.5@PAGE
Lloh28:
	add	x1, x1, l_.str.5@PAGEOFF
	mov	x0, x20
	bl	_dlsym
	cbz	x0, LBB2_30
; %bb.5:
	adrp	x26, _current_task@PAGE
	str	x0, [x26, _current_task@PAGEOFF]
Lloh29:
	adrp	x1, l_.str.6@PAGE
Lloh30:
	add	x1, x1, l_.str.6@PAGEOFF
	mov	x0, x20
	bl	_dlsym
	cbz	x0, LBB2_31
; %bb.6:
	adrp	x8, _task_alloc@PAGE
	str	x0, [x8, _task_alloc@PAGEOFF]
Lloh31:
	adrp	x1, l_.str.7@PAGE
Lloh32:
	add	x1, x1, l_.str.7@PAGEOFF
	mov	x0, x20
	bl	_dlsym
	cbz	x0, LBB2_32
; %bb.7:
	adrp	x8, _task_dealloc@PAGE
	str	x0, [x8, _task_dealloc@PAGEOFF]
Lloh33:
	adrp	x1, l_.str.8@PAGE
Lloh34:
	add	x1, x1, l_.str.8@PAGEOFF
	mov	x0, x24
	bl	_dlsym
	cbz	x0, LBB2_33
; %bb.8:
	mov	x23, x0
Lloh35:
	adrp	x1, l_.str.9@PAGE
Lloh36:
	add	x1, x1, l_.str.9@PAGEOFF
	mov	x0, x24
	bl	_dlsym
	cbz	x0, LBB2_34
; %bb.9:
	mov	x19, x0
Lloh37:
	adrp	x1, l_.str.10@PAGE
Lloh38:
	add	x1, x1, l_.str.10@PAGEOFF
	mov	x0, x24
	bl	_dlsym
	cbz	x0, LBB2_35
; %bb.10:
	mov	x24, x0
Lloh39:
	adrp	x1, l_.str.11@PAGE
Lloh40:
	add	x1, x1, l_.str.11@PAGEOFF
	mov	x0, x20
	bl	_dlsym
	cbz	x0, LBB2_36
; %bb.11:
	ldp	w8, w9, [x0]
                                        ; kill: def $w8 killed $w8 def $x8
	sxtw	x8, w8
	adrp	x25, _yield_context_size@PAGE
	str	w9, [x25, _yield_context_size@PAGEOFF]
	add	x8, x8, x0
	adrp	x10, _yield_entry@PAGE
	str	x8, [x10, _yield_entry@PAGEOFF]
	sub	w8, w9, #256, lsl #12           ; =1048576
	sub	w8, w8, #1
	mov	w9, #-1048561                   ; =0xfff0000f
	cmp	w8, w9
	b.lo	LBB2_13
; %bb.12:
	ldr	x8, [x26, _current_task@PAGEOFF]
	blr	x8
	cbz	x0, LBB2_15
LBB2_13:
	mov	w0, #3                          ; =0x3
LBB2_14:
	ldp	x29, x30, [sp, #128]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #112]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #96]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #80]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #144
	ret
LBB2_15:
	mov	w0, #1                          ; =0x1
	mov	w1, #168                        ; =0xa8
	bl	_calloc
	mov	x20, x0
	mov	w8, #2                          ; =0x2
	str	w8, [x0, #160]
	mov	x1, #0                          ; =0x0
	bl	_pthread_mutex_init
	add	x0, x20, #64
	mov	x1, #0                          ; =0x0
	bl	_pthread_cond_init
Lloh41:
	adrp	x3, _oracle_descriptor@GOTPAGE
Lloh42:
	ldr	x3, [x3, _oracle_descriptor@GOTPAGEOFF]
	add	x2, x24, #8
	mov	x0, #0                          ; =0x0
	mov	x1, #0                          ; =0x0
	mov	x4, #0                          ; =0x0
	blr	x22
	cbz	x0, LBB2_37
; %bb.16:
	cbz	x1, LBB2_37
; %bb.17:
	mov	x22, x0
	str	x0, [x20, #136]
	ldr	x8, [x1, #8]
	stp	x8, x20, [x1, #24]
Lloh43:
	adrp	x8, _completion_wrapper@PAGE
Lloh44:
	add	x8, x8, _completion_wrapper@PAGEOFF
	str	x8, [x1, #8]
	blr	x23
	mov	x0, x22
	mov	x1, #0                          ; =0x0
	mov	x2, #0                          ; =0x0
	blr	x21
	ldr	x8, [x26, _current_task@PAGEOFF]
	blr	x8
	mov	x21, x0
	cmp	x0, #0
	cset	w23, eq
	mov	x0, x20
	bl	_pthread_mutex_lock
	ldr	w8, [x20, #112]
	cbnz	w8, LBB2_19
LBB2_18:                                ; =>This Inner Loop Header: Depth=1
	add	x0, x20, #64
	mov	x1, x20
	bl	_pthread_cond_wait
	ldr	w8, [x20, #112]
	cbz	w8, LBB2_18
LBB2_19:
	mov	x0, x20
	bl	_pthread_mutex_unlock
	ldp	x0, x1, [x20, #144]
	bl	_pthread_equal
	cmp	w0, #0
	cset	w9, eq
	ldp	w8, w10, [x20, #116]
	cmp	w8, #1
	ccmp	w10, #1, #0, eq
	b.eq	LBB2_21
; %bb.20:
	mov	w21, #0                         ; =0x0
	b	LBB2_25
LBB2_21:
	ldr	w10, [x20, #124]
	cmp	w10, #2
	b.ne	LBB2_23
; %bb.22:
	ldr	w10, [x20, #128]
	cmp	w10, #0
	ccmp	x21, #0, #0, ne
	cset	w21, eq
	b	LBB2_24
LBB2_23:
	mov	w21, #0                         ; =0x0
LBB2_24:
	mov	w10, #1                         ; =0x1
LBB2_25:
	ldp	w11, w12, [x20, #124]
	ldr	w13, [x25, _yield_context_size@PAGEOFF]
	stp	x9, x13, [sp, #48]
	stp	x12, x23, [sp, #32]
	stp	x10, x11, [sp, #16]
Lloh45:
	adrp	x0, l_.str.12@PAGE
Lloh46:
	add	x0, x0, l_.str.12@PAGEOFF
	stp	x21, x8, [sp]
	bl	_printf
	mov	x0, x22
	blr	x19
	add	x8, x20, #160
	mov	w9, #-1                         ; =0xffffffff
	ldaddal	w9, w8, [x8]
	cmp	w8, #1
	b.ne	LBB2_27
; %bb.26:
	add	x0, x20, #64
	bl	_pthread_cond_destroy
	mov	x0, x20
	bl	_pthread_mutex_destroy
	mov	x0, x20
	bl	_free
LBB2_27:
	eor	w0, w21, #0x1
	b	LBB2_14
LBB2_28:
	bl	_main.cold.9
LBB2_29:
	bl	_main.cold.8
LBB2_30:
	bl	_main.cold.7
LBB2_31:
	bl	_main.cold.6
LBB2_32:
	bl	_main.cold.5
LBB2_33:
	bl	_main.cold.4
LBB2_34:
	bl	_main.cold.3
LBB2_35:
	bl	_main.cold.2
LBB2_36:
	bl	_main.cold.1
LBB2_37:
	bl	_abort
	.loh AdrpAdd	Lloh16, Lloh17
	.loh AdrpAdd	Lloh14, Lloh15
	.loh AdrpAdd	Lloh21, Lloh22
	.loh AdrpLdrGotLdr	Lloh18, Lloh19, Lloh20
	.loh AdrpAdd	Lloh23, Lloh24
	.loh AdrpAdd	Lloh25, Lloh26
	.loh AdrpAdd	Lloh27, Lloh28
	.loh AdrpAdd	Lloh29, Lloh30
	.loh AdrpAdd	Lloh31, Lloh32
	.loh AdrpAdd	Lloh33, Lloh34
	.loh AdrpAdd	Lloh35, Lloh36
	.loh AdrpAdd	Lloh37, Lloh38
	.loh AdrpAdd	Lloh39, Lloh40
	.loh AdrpLdrGot	Lloh41, Lloh42
	.loh AdrpAdd	Lloh43, Lloh44
	.loh AdrpAdd	Lloh45, Lloh46
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function completion_wrapper
_completion_wrapper:                    ; @completion_wrapper
	.cfi_startproc
; %bb.0:
	orr	x29, x29, #0x1000000000000000
	str	x19, [sp, #-32]!                ; 8-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	str	x22, [sp, #8]
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -32
	ldp	x8, x19, [x22, #24]
	blr	x8
Lloh47:
	adrp	x8, _current_task@PAGE
Lloh48:
	ldr	x8, [x8, _current_task@PAGEOFF]
	blr	x8
	cmp	x0, #0
	cset	w20, eq
	mov	x0, x19
	bl	_pthread_mutex_lock
	str	w20, [x19, #128]
	mov	w8, #1                          ; =0x1
	str	w8, [x19, #112]
	add	x0, x19, #64
	bl	_pthread_cond_signal
	mov	x0, x19
	bl	_pthread_mutex_unlock
	add	x8, x19, #160
	mov	w9, #-1                         ; =0xffffffff
	ldaddal	w9, w8, [x8]
	cmp	w8, #1
	b.ne	LBB3_2
; %bb.1:
	add	x0, x19, #64
	bl	_pthread_cond_destroy
	mov	x0, x19
	bl	_pthread_mutex_destroy
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldr	x19, [sp], #32                  ; 8-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	b	_free
LBB3_2:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldr	x19, [sp], #32                  ; 8-byte Folded Reload
	and	x29, x29, #0xefffffffffffffff
	ret
	.loh AdrpLdr	Lloh47, Lloh48
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.1
_main.cold.1:                           ; @main.cold.1
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
	bl	_OUTLINED_FUNCTION_1
Lloh49:
	adrp	x8, l_.str.11@PAGE
Lloh50:
	add	x8, x8, l_.str.11@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh49, Lloh50
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.2
_main.cold.2:                           ; @main.cold.2
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
	bl	_OUTLINED_FUNCTION_1
Lloh51:
	adrp	x8, l_.str.10@PAGE
Lloh52:
	add	x8, x8, l_.str.10@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh51, Lloh52
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.3
_main.cold.3:                           ; @main.cold.3
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
	bl	_OUTLINED_FUNCTION_1
Lloh53:
	adrp	x8, l_.str.9@PAGE
Lloh54:
	add	x8, x8, l_.str.9@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh53, Lloh54
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.4
_main.cold.4:                           ; @main.cold.4
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
	bl	_OUTLINED_FUNCTION_1
Lloh55:
	adrp	x8, l_.str.8@PAGE
Lloh56:
	add	x8, x8, l_.str.8@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh55, Lloh56
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.5
_main.cold.5:                           ; @main.cold.5
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
	bl	_OUTLINED_FUNCTION_1
Lloh57:
	adrp	x8, l_.str.7@PAGE
Lloh58:
	add	x8, x8, l_.str.7@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh57, Lloh58
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.6
_main.cold.6:                           ; @main.cold.6
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
	bl	_OUTLINED_FUNCTION_1
Lloh59:
	adrp	x8, l_.str.6@PAGE
Lloh60:
	add	x8, x8, l_.str.6@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh59, Lloh60
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.7
_main.cold.7:                           ; @main.cold.7
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
	bl	_OUTLINED_FUNCTION_1
Lloh61:
	adrp	x8, l_.str.5@PAGE
Lloh62:
	add	x8, x8, l_.str.5@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh61, Lloh62
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.8
_main.cold.8:                           ; @main.cold.8
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
	bl	_OUTLINED_FUNCTION_1
Lloh63:
	adrp	x8, l_.str.4@PAGE
Lloh64:
	add	x8, x8, l_.str.4@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh63, Lloh64
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function main.cold.9
_main.cold.9:                           ; @main.cold.9
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
	bl	_OUTLINED_FUNCTION_1
Lloh65:
	adrp	x8, l_.str.3@PAGE
Lloh66:
	add	x8, x8, l_.str.3@PAGEOFF
	bl	_OUTLINED_FUNCTION_0
	bl	_OUTLINED_FUNCTION_2
	.loh AdrpAdd	Lloh65, Lloh66
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function OUTLINED_FUNCTION_0
_OUTLINED_FUNCTION_0:                   ; @OUTLINED_FUNCTION_0 Thunk
	.cfi_startproc
; %bb.0:
	stp	x8, x0, [sp]
	adrp	x1, l_.str.13@PAGE
	add	x1, x1, l_.str.13@PAGEOFF
	mov	x0, x19
	b	_fprintf
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function OUTLINED_FUNCTION_1
_OUTLINED_FUNCTION_1:                   ; @OUTLINED_FUNCTION_1 Thunk
	.cfi_startproc
; %bb.0:
	adrp	x8, ___stderrp@GOTPAGE
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
	ldr	x19, [x8]
	b	_dlerror
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function OUTLINED_FUNCTION_2
_OUTLINED_FUNCTION_2:                   ; @OUTLINED_FUNCTION_2 Thunk
	.cfi_startproc
; %bb.0:
	mov	w0, #2                          ; =0x2
	b	_exit
	.cfi_endproc
                                        ; -- End function
.zerofill __DATA,__bss,_current_task,8,3 ; @current_task
.zerofill __DATA,__bss,_task_alloc,8,3  ; @task_alloc
.zerofill __DATA,__bss,_yield_context_size,4,2 ; @yield_context_size
.zerofill __DATA,__bss,_yield_entry,8,3 ; @yield_entry
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"/usr/lib/swift/libswift_Concurrency.dylib"

l_.str.1:                               ; @.str.1
	.asciz	"/usr/lib/swift/libswiftCore.dylib"

l_.str.2:                               ; @.str.2
	.asciz	"dlopen: %s\n"

l_.str.3:                               ; @.str.3
	.asciz	"swift_task_create"

l_.str.4:                               ; @.str.4
	.asciz	"swift_job_run"

l_.str.5:                               ; @.str.5
	.asciz	"swift_task_getCurrent"

l_.str.6:                               ; @.str.6
	.asciz	"swift_task_alloc"

l_.str.7:                               ; @.str.7
	.asciz	"swift_task_dealloc"

.zerofill __DATA,__bss,_task_dealloc,8,3 ; @task_dealloc
l_.str.8:                               ; @.str.8
	.asciz	"swift_retain"

l_.str.9:                               ; @.str.9
	.asciz	"swift_release"

l_.str.10:                              ; @.str.10
	.asciz	"$sytN"

l_.str.11:                              ; @.str.11
	.asciz	"$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu"

l_.str.12:                              ; @.str.12
	.asciz	"ok=%d entries=%d resumes=%d identity_matches=%d completion_tls_clear=%d caller_tls_clear=%d changed_thread=%d yield_context_size=%u\n"

l_.str.13:                              ; @.str.13
	.asciz	"missing %s: %s\n"

.subsections_via_symbols
