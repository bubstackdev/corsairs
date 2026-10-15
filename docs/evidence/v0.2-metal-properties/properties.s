	.build_version macos, 27, 0	sdk_version 27, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF ; -- Begin function $s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF
	.p2align	2
_$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF: ; @"$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF"
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
	bl	_objc_msgSend$device
	; InlineAsm Start
	mov	x29, x29	; marker for objc_retainAutoreleaseReturnValue
	; InlineAsm End
	bl	_objc_retainAutoreleasedReturnValue
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
	.globl	_$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF ; -- Begin function $s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF
	.p2align	2
_$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF: ; @"$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF"
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
	bl	_objc_msgSend$device
	; InlineAsm Start
	mov	x29, x29	; marker for objc_retainAutoreleaseReturnValue
	; InlineAsm End
	bl	_objc_retainAutoreleasedReturnValue
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
	.globl	_$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF ; -- Begin function $s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF
	.p2align	2
_$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF: ; @"$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF"
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
	bl	_objc_msgSend$storageMode
	mov	x1, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	bl	_swift_unknownObjectRelease
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_$sSo14MTLStorageModeV8rawValueSuvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$sSo14MTLStorageModeV8rawValueSuvg ; -- Begin function $sSo14MTLStorageModeV8rawValueSuvg
	.globl	_$sSo14MTLStorageModeV8rawValueSuvg
	.weak_definition	_$sSo14MTLStorageModeV8rawValueSuvg
	.p2align	2
_$sSo14MTLStorageModeV8rawValueSuvg:    ; @"$sSo14MTLStorageModeV8rawValueSuvg"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	xzr, [sp, #8]
	str	x0, [sp, #8]
	str	x0, [sp]
	ldr	x0, [sp]
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF ; -- Begin function $s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF
	.p2align	2
_$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF: ; @"$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF"
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
	bl	_objc_msgSend$status
	mov	x1, x0
	ldr	x0, [sp, #8]                    ; 8-byte Folded Reload
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	bl	_swift_unknownObjectRelease
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	bl	_$sSo22MTLCommandBufferStatusV8rawValueSuvg
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	_$sSo22MTLCommandBufferStatusV8rawValueSuvg ; -- Begin function $sSo22MTLCommandBufferStatusV8rawValueSuvg
	.globl	_$sSo22MTLCommandBufferStatusV8rawValueSuvg
	.weak_definition	_$sSo22MTLCommandBufferStatusV8rawValueSuvg
	.p2align	2
_$sSo22MTLCommandBufferStatusV8rawValueSuvg: ; @"$sSo22MTLCommandBufferStatusV8rawValueSuvg"
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	xzr, [sp, #8]
	str	x0, [sp, #8]
	str	x0, [sp]
	ldr	x0, [sp]
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.private_extern	__swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI"
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftMetal

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI ; @"_swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI"
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.private_extern	___swift_reflection_version ; @__swift_reflection_version
	.section	__TEXT,__const
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3                               ; 0x3

	.no_dead_strip	_$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF
	.no_dead_strip	_$s18MetalPropertiesABI11queueDeviceySo9MTLDevice_pSo15MTLCommandQueue_pF
	.no_dead_strip	_$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF
	.no_dead_strip	_$s18MetalPropertiesABI12bufferDeviceySo9MTLDevice_pSo9MTLBuffer_pF
	.no_dead_strip	_$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF
	.no_dead_strip	_$s18MetalPropertiesABI11storageModeySuSo9MTLBuffer_pF
	.no_dead_strip	_$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF
	.no_dead_strip	_$s18MetalPropertiesABI13commandStatusySuSo16MTLCommandBuffer_pF
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftMetal_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_MetalPropertiesABI
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_MetalPropertiesABI
	.no_dead_strip	___swift_reflection_version
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
