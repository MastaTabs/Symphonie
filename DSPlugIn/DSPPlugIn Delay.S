
; Simple DSP Delay algorithm V1.0 - For Demonstration

; A Ringbuffer is installed using SST_GetMem
; Fixed Size of Delay in SampleNumb 
;  -> Fixed Length (time) at same MixFreq
; Actual Delay PTRs are displayed (if FORCE UPATE IS ON)
; If no buffer mem has been allocated, the delay algorithm
; won't be processed (using RingBufMem_STATUS)

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


GoSST	move.l	a6,-(sp)
	move.l	SUPERSTBASE(PC),a6
	move.l	(a6,d7.w),a6
	jsr	(a6)
	move.l	(sp)+,a6
	rts


StartDSP
	bsr	FreeDelayMem

	lea.l	RingBufMem_STATUS(PC),a0
	clr.b	(a0)

	lea.l	Delay_MEM(PC),a0

	CALLSST SYS_GetMem
	tst.l	d0
	beq.s	.exit			;No Memory
	CALLSST GFX_AssistHexLong

	lea.l	Delay_MEM(PC),a2

	move.l	(a2),a0

	move.l	a0,DELAYREAD_PTR(a2)
	lea.l	(DELAYLEN.l,a0),a1
	move.l	a1,DELAYWRITE_PTR(a2)
	lea.l	(DELAYBUFLEN-4,a0),a1
	move.l	a1,DELAYEND_PTR(a2)

	bsr	ViewBuf

	lea.l	RingBufMem_STATUS(PC),a0
	move.b	#-1,(a0)

.exit	rts

ViewBuf
	BGN
	lea.l	Delay_MEM(PC),a2

	move.l	DELAYREAD_PTR(a2),d0
	CALLSST	GFX_AssistHexLong

	move.l	DELAYWRITE_PTR(a2),d0
	CALLSST	GFX_AssistHexLong

;	move.l	DELAYEND_PTR(a2),d0
;	CALLSST GFX_AssistHexLong

;	move.l	DELAYSTART_PTR(a2),d0
;	CALLSST GFX_AssistHexLong

;	CALLSST AUDIO_GetChunkLen
;	CALLSST GFX_AssistHexLong

	RET

StopDSP
	lea.l	RingBufMem_STATUS(PC),a0
	clr.b	(a0)

	bsr	ViewBuf
	bsr	FreeDelayMem

	rts

	acode
FreeDelayMem
	BGN
	tst.l	Delay_MEM(PC)
	beq.s	.exit
		lea.l	Delay_MEM(PC),a0
		CALLSST SYS_FreeMem
		lea.l	FreeMem_TXT(PC),a0
		CALLSST GFX_AssistText
.exit	RET
	

		dc.l	0,0,0,0

Delay_MEM	dc.l	0,DELAYBUFLEN,ANYMEM
FreeMem_TXT	dc.b	"Delay Mem has been freed.",0


	acode

GraphSizeModify
	rts

RefreshGraph
	bsr	ViewBuf
	rts

ModifyValue	;INPUT (D0L,D1L)(VALUE, PARAMETER ID)
	lea.l	Volume(PC),a0
	move.l	d0,(a0)
	rts

Volume	dc.l	256


InitDSP		;I(A0L)(SUPERSUPPORTTABLE_PTR)
		;O(A0L)(DSPGUI_PTR)

	lea.l	SUPERSTBASE(PC),a1
	move.l	a0,(a1)

	lea.l	Welcome_TXT(PC),a0
	CALLSST GFX_AssistText

	lea.l	Parameter_DEF(PC),a0
	rts

CleanUpDSP	
	lea.l	RingBufMem_STATUS(PC),a0
	clr.b	(a0)
	rts

GetDspTitle	;OUTPUT (A0L)(DSPTitle_TXT)
	lea.l	DSPTitle(PC),a0
	rts



DELAYWRITE_PTR	EQU	-4
DELAYREAD_PTR	EQU	-8
DELAYEND_PTR	EQU	-12
DELAYSTART_PTR	EQU	0

DELAYLEN	EQU	$6000
DELAYBUFLEN	EQU	$8000


RingBufMem_STATUS	dc.b	0	;0= not allocated

	acode

ProcDsp		;INPUT (D0W,A1L)(SAMPLE_NUMB,SAMPLECHUNK_PTR)
	movem.l	d0-a6,-(sp)
	
	lea.l	RingBufMem_STATUS(PC),a0
	tst.b	(a0)
	beq.s	.exit


	lea.l	Delay_MEM(PC),a0
	tst.l	(a0)
	beq.s	.exit


	move.l	DELAYEND_PTR(a0),d7	;end

	move.l	DELAYWRITE_PTR(a0),a2
	lea.l	(a2,d0.w*4),a6
	cmp.l	a6,d7
	bhs.s	.rok

	move.l	DELAYSTART_PTR(a0),a2
.rok
	move.l	DELAYREAD_PTR(a0),a3
	lea.l	(a3,d0.w*4),a6
	cmp.l	a6,d7
	bhs.s	.lok

	move.l	DELAYSTART_PTR(a0),a3
.lok




	subq.w	#1,d0

	move.l	Volume(PC),d3
	
.loop
	move.l	(a1),d1

	move.l	d1,(a2)+

	move.l	(a3)+,d2

	move.w	d2,d4

	muls	d3,d4
	asr.l	#8,d4
	add.w	d4,d1

	swap	d1
	swap	d2

	muls	d3,d2
	asr.l	#8,d2
	add.w	d2,d1
	swap	d1
	

	move.l	d1,(a1)+

	dbf	d0,.loop


.quit
	move.l	a3,DELAYREAD_PTR(a0)
	move.l	a2,DELAYWRITE_PTR(a0)
.exit	movem.l	(sp)+,d0-a6
	rts



	;- GUI ------------------------------------------------------

Parameter_DEF
	dc.b	"Volume",0
	dc.b	0,0,1,0		;init
	dc.b	0,0,0,0		;min
	dc.b	0,0,1,0		;max

	dc.b	0		;END OF GUI DEF

	;- TITLE ----------------------------------------------------


		dc.b	"$VER: "
DSPTitle	dc.b	"Test Delay Dsp Plugin v1.0",0
Welcome_TXT	dc.b	"Test Dsp: Delay",0

		even
SUPERSTBASE	dc.l	0
test		dc.l	0
	END
