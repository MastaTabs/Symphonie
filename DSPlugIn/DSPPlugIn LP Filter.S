; Simple DSP Filter algorithm v1.0
; Can be used for filtering, antialiasing or smoothing

; Designed by Patrick Meng 96

; Pretty well optimized for: Motorola CPU 020 - 060 (superscalar)

	;- BEGIN -------------------------------------------------

	MC68020

SST_SYS_GetMem			EQU	0
SST_SYS_FreeMem			EQU	4

SST_FILE_RequestFileName	EQU	100
SST_FILE_SetReqPattern		EQU	104
SST_FILE_SetReqDir		EQU	108
SST_FILE_GetFileName		EQU	112
SST_FILE_GetFileLen		EQU	116

SST_GFX_AssistText		EQU	200
SST_GFX_AssistDecLong		EQU	204
SST_GFX_AssistDecByte		EQU	208
SST_GFX_AssistHexLong		EQU	212

SST_AUDIO_GetChunkLen		EQU	400

SST_PTR_EXECBASE		EQU	1600
SST_PTR_INTBASE			EQU	1604
SST_PTR_DOSBASE			EQU	1608
SST_PTR_ASLBASE			EQU	1612
SST_PTR_REQTOOLSBASE		EQU	1616
SST_PTR_GFXBASE			EQU	1620

SST_PTR_Screen			EQU	1650

SST_ADR_ProcessorFlags		EQU	1800
SST_ADR_SystemFrequency		EQU	1804
SST_ADR_SystemBpm		EQU	1808
SST_ADR_ChunkLen		EQU	1812
SST_ADR_OversampleFlag		EQU	1816


FASTMEM	EQU	$10004
ANYMEM	EQU	$10000

CALLSST	macro
	move.l	#SST_\1,d7
	bsr	GoSST
	endm

FLASH	macro
	move.w	#$\1,$dff180
	endm

BGN	macro
	movem.l	d0-d7/a0-a6,-(a7)
	endm

RET	macro
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	endm

puts	macro
	movem.l	\1,-(sp)
	endm

gets	macro
	movem.l	(sp)+,\1
	endm

acode	macro
	CNOP 0,4
	endm


	dc.b	"Symphonie DSP Plugin"	;MAGIC String    (PRIVATE)
	dc.w	1,0			;Version,Release (PRIVATE,DO NOT CHANGE)

	;- DSPLIB -------------------------------------------------

	jmp	InitDSP(PC)		;Allocate Mem, Build your Tables
	jmp	CleanUpDSP(PC)		;Free Mem

	jmp	ProcDsp(PC)		;Process DSP algorithm (interrupt)

	jmp	GetDspTitle(PC)		;Get DSP algorithm Title
	jmp	ModifyValue(PC)		;notify changed Value

	jmp	GraphSizeModify(PC)	;notify graph size has changed
	jmp	RefreshGraph(PC)	;notify its time for a GFX update

	jmp	StartDSP(PC)		;notify start
	jmp	StopDSP(PC)		;notify stop
	dc.l	-1

	;- CODE --------------------------------------------------


	acode
GoSST	puts	a6
	move.l	SUPERSTBASE(PC),a6
	move.l	(a6,d7.w),a6
	jsr	(a6)
	gets	a6
	rts
SUPERSTBASE	dc.l	0


	acode
StartDSP
	lea.l	DspHPFilt_LASTSAMPLE(PC),a0
	clr.l	(a0)
	lea.l	On_TXT(PC),a0
	CALLSST GFX_AssistText
	rts


StopDSP
	lea.l	Off_TXT(PC),a0
	CALLSST GFX_AssistText
	rts




	acode

GraphSizeModify
	rts

RefreshGraph
	rts

ModifyValue	;INPUT (D0L,D1L)(VALUE, PARAMETER ID)
	tst.w	d1
	bne.s	.val1
	lea.l	Volume(PC),a0
	move.l	d0,(a0)
	rts
.val1	
	lea.l	Volume+4(PC),a0
	move.l	d0,(a0)
	rts


Volume	dc.l	1,1


InitDSP		;I(A0L)(SUPERSUPPORTTABLE_PTR)
		;O(A0L)(DSPGUI_PTR)

	lea.l	SUPERSTBASE(PC),a1
	move.l	a0,(a1)

	lea.l	Welcome_TXT(PC),a0
	CALLSST GFX_AssistText

	lea.l	DspHPFilt_LASTSAMPLE(PC),a0
	clr.l	(a0)

	lea.l	Parameter_DEF(PC),a0
	rts

CleanUpDSP	
	rts

GetDspTitle	;OUTPUT (A0L)(DSPTitle_TXT)
	lea.l	DSPTitle(PC),a0
	rts



	acode
ProcDsp		;INPUT (D0W,A1L)(SAMPLE_NUMB,SAMPLECHUNK_PTR)
	puts	d0-a3

	lea.l	DspHPFilt_LASTSAMPLE(PC),a2

	move.l	Volume+4(PC),d3
	;moveq	#1,d3			;Filter Intensity


	move.l	(a2),d2			;D2L	LASTSAMPLE
	subq.w	#1,d0
	move.w	d0,d6


	move.l	Volume(PC),d7		;Depth (Interation)
	subq.w	#1,d7
	bmi.s	.exit

	move.l	d2,d5
	move.l	a1,a3

.loop	move.w	d6,d0
	move.l	d5,d2
	move.l	a3,a1

.loop2		move.l	(a1),d1

		move.l	d1,d4
		sub.w	d2,d1
		asr.w	d3,d1
		sub.w	d1,d4
		swap	d1
		swap	d2
		sub.w	d2,d1
		asr.w	d3,d1
		swap	d4
		sub.w	d1,d4
		swap	d4

		move.l	d4,(a1)+
		move.l	d4,d2
		dbf	d0,.loop2

	dbf	d7,.loop

	move.l	d4,(a2)

.exit	gets	d0-a3
	rts

DspHPFilt_LASTSAMPLE	dc.l	0



	;- GUI ------------------------------------------------------

Parameter_DEF
	dc.b	"Depth",0
	dc.b	0,0,0,1		;init
	dc.b	0,0,0,1		;min
	dc.b	0,0,0,8		;max

	dc.b	"Level",0
	dc.b	0,0,0,1		;init
	dc.b	0,0,0,1		;min
	dc.b	0,0,0,4		;max

	dc.b	0		;END OF GUI DEF

	;- TITLE ----------------------------------------------------


		dc.b	"$VER: "
DSPTitle	dc.b	"Test Filter Dsp Plugin v1.0",0
Welcome_TXT	dc.b	"Test Dsp: Filter",0
On_TXT		dc.b	"LP Filter: On",0
Off_TXT		dc.b	"LP Filter: Off",0
		even

	END
