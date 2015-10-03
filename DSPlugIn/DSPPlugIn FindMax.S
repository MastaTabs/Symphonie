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
SST_ADR_MaxAmplitude		EQU	1820	;$7fff in SymPRO
SST_ADR_BitPerSample		EQU	1824	;16 for 16 Bit Stream



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


StartDSP
	lea.l	Counter(PC),a0
	clr.l	(a0)
	rts

StopDSP
	rts

GraphSizeModify
	rts

RefreshGraph
	lea.l	Counter(PC),a0
	move.l	(a0),d0
	move.l	4(a0),d1
	cmp.l	d1,d0
	beq.s	RefreshGraph_X

	move.l	d0,4(a0)

	move.l	#SST_GFX_AssistDecLong,d7
	bsr	GoSST	
RefreshGraph_X
	rts

ModifyValue	;INPUT (D0L,D1L)(VALUE, PARAMETER ID)
	move.l	Counter(PC),d0
	move.l	#SST_GFX_AssistHexLong,d7
	bsr	GoSST	
	rts

GoSST
	move.l	a6,-(sp)
	move.l	SUPERSTBASE(PC),a6
	move.l	(a6,d7.w),a6
	jsr	(a6)
	move.l	(sp)+,a6
	rts


InitDSP		;INPUT (A0L)(SUPERSUPPORTTABLE_PTR)
		;OUTPUT (A0L)(PARAMETER GUI DEF_PTR)
	lea.l	SUPERSTBASE(PC),a1
	move.l	a0,(a1)


	lea.l	Welcome_TXT(PC),a0
	move.l	#SST_GFX_AssistText,d7
	bsr	GoSST

	lea.l	Parameter_DEF(PC),a0
	rts

Welcome_TXT	dc.b	"Welcome to DSP test",0

SUPERSTBASE	dc.l	0

CleanUpDSP	rts

GetDspTitle	;OUTPUT (A0L)(DSPTitle_TXT)
	lea.l	DSPTitle(PC),a0
	rts

Counter	dc.l	0,0

ProcDsp		;INPUT (D0W,A1L)(SAMPLE_NUMB,SAMPLECHUNK_PTR)
	movem.l	d0-a6,-(sp)

	lea.l	Counter(PC),a0
	move.l	(a0),d2

	subq.w	#1,d0
.loop	move.l	(a1)+,d1

	bsr	CheckMax
	swap	d1
	bsr	CheckMax

	dbf	d0,.loop

	move.l	d2,(a0)

	movem.l	(sp)+,d0-a6
	rts

CheckMax
	tst.w	d1
	bpl.s	.ok

	neg.w	d1
.ok	cmp.w	d1,d2
	bhs.s	.exit
	move.w	d1,d2
.exit	rts

	;- GUI ------------------------------------------------------

	even
Parameter_DEF
	dc.b	0		;END OF GUI DEF

	;- TITLE ----------------------------------------------------


		dc.b	"$VER: "
DSPTitle	dc.b	"Test Dsp Plugin: Find Max Amplitude v1.0",0


	END
