; ASM-One - potgo_lib.i
; (Release 3.0)
;
; by SCHWARZENEGGER/R.A.F

_LVOAllocPotBits	EQU	-6
_LVOFreePotBits	EQU	-12
_LVOWritePotgo	EQU	-18

CALLPOTGO	MACRO
	move.l	_PotgoBase,a6
	jsr	_LVO\1(a6)
	ENDM
