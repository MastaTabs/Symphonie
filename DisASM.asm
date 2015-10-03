MsgIDCMP EQU $14

OpenAutoLiblist:
		movem.l	d1-a6,-(sp)

.start:
		moveq	#0,d0
		cmpi.b	#$FF,(a0)	; list at end ?
		beq.s	.exit		; yes, ->exit
		movea.l	a0,a2 		; save pointer to a2
		move.l	(a0),d7 	; get first long in d7 / load on avail
		clr.l	(a0)+ 		; clear first long		0, 0, 0, 0, 0, 0, "name.library"
		move.w	(a0)+,d0    ; get word in d0
		movea.l	a0,a1 		; save libname ptr to a1 for OpenLibrary
		jsr		MoveNextString ; goto next string
		jsr		sub_190DC 	; ??? +1 clr bit 0 in a0 align ?
		movea.l	a0,a3
		CALLEXEC OpenLibrary
		;movea.l	(4).w,a6
		;jsr	-$228(a6)	; _LVOOpenLibrary
		move.l	d0,(a2)		; save libbase in first long
		;tst.l	d0
		bne.s	.success	; branch if set
		tst.l	d7 			; test load on avail
		bne.s	.success 	; if set success continue anyway else error
		moveq	#-1,d0
		jsr		WarnFlash	; warn
		bra.s	.exit		; exit
.success:
		movea.l	a3,a0 		; get next lib in a0
		bra.s	.start 		; start over
.exit:
		movem.l	(sp)+,d1-a6
		rts

CloseAutoLiblist:
		movem.l	d1-a6,-(sp)
.start:
		cmpi.b	#$FF,(a0)
		beq.s	.exit
		movea.l	(a0)+,a1
		move.w	(a0)+,d0
		jsr	MoveNextString
		jsr	sub_190DC
		cmpa.l	#0,a1
		beq.s	.start
		movea.l	a0,a3
		CALLEXEC CloseLibrary
		;movea.l	(4).w,a6
		;jsr	-$19E(a6)
		movea.l	a3,a0
		bra.s	.start
.exit:
		movem.l	(sp)+,d1-a6
		rts

ActivateCopList:
		move.w	#$80,($DFF096).l ; '€'
		move.l	a0,($DFF080).l
		move.l	a0,($DFF080).l
		clr.w	($DFF088).l
		move.w	#$8080,($DFF096).l
		rts

sub_190DC:
		move.l	d0,-(sp)
		move.l	a0,d0
		addq.l	#1,d0
		bclr	#0,d0
		movea.l	d0,a0
		move.l	(sp)+,d0
		rts

AutoGetMem:
		;I(A0) (PointerList)
		movem.l	d1-a6,-(sp)
		movea.l	a0,a1
		moveq	#-1,d7
.next:
		movea.l	(a1)+,a0
		cmpa.l	#-1,a0
		beq.s	.exit
		bsr.w	GetMem
		tst.l	d0
		bne.s	.next
		moveq	#0,d7
		bra.s	.next
.exit:
		move.w	d7,d0
		movem.l	(sp)+,d1-a6
		rts

AutoFreeMem:
		movem.l	d0-a6,-(sp)
		movea.l	a0,a1
.next:
		movea.l	(a1)+,a0
		cmpa.l	#-1,a0
		beq.s	.exit
		addq.l	#1,((MEM_DEBUG_INFO+4)).l
		bsr	FreeMem
		bra.s	.next
.exit:
		movem.l	(sp)+,d0-a6
		rts

MENUCOL:	dc.w $100

AutoMenu:
		movem.l	d0-a6,-(sp)
loc_19A94:
		movea.l	a0,a2
		bsr.w	sub_19AB0
		addq.l	#1,a1
		tst.b	(a1)
		beq.s	loc_19AAA
		move.l	a0,(a2)
		add.w	(word_19B44).l,d0
		bra.s	loc_19A94
loc_19AAA:
		movem.l	(sp)+,d0-a6
		rts
sub_19AFC:
		move.l	a0,-(sp)
		moveq	#0,d0
loc_19B00:
		tst.b	(a0)+
		beq.s	loc_19B08
		addq.l	#1,d0
		bra.s	loc_19B00
loc_19B08:
		movea.l	(sp)+,a0
		rts

sub_19B0C:
		movem.l	d0-d7/a1-a6,-(sp)
		movea.l	a0,a2
		lea	$1E(a2),a3
		clr.l	(a2)+
		move.w	d0,(a2)+
		move.w	d1,(a2)+
		movea.l	a1,a0
		jsr	sub_19AFC
		lsl.w	#3,d0
		move.w	d0,(word_19B44).l
		move.w	d0,(a2)+
		move.w	(MENUFONT_H).l,(a2)+
		move.w	#1,(a2)+
		move.l	a1,(a2)+
		clr.l	(a2)+
		movea.l	a3,a0
		movem.l	(sp)+,d0-d7/a1-a6
		rts

word_19B44:	dc.w 0

sub_19AB0:
		movem.l	d0-d7/a2-a6,-(sp)
		movea.l	a0,a2
		bsr.w	sub_19B0C
		moveq	#0,d0
		moveq	#0,d1
		exg	a0,a1
		jsr	MoveNextString
		exg	a0,a1
		tst.b	(a1)
		beq.s	loc_19AF6
		move.l	a0,$12(a2)
		movea.l	a0,a2
		bsr.w	sub_19B46
loc_19AD6:
		add.w	(MENUFONT_H+2).l,d1
		exg	a0,a1
		jsr	MoveNextString
		exg	a0,a1
		tst.b	(a1)
		beq.s	loc_19AF6
		move.l	a0,(a2)
		movea.l	a0,a2
		jsr	sub_19B46
		bra.s	loc_19AD6
loc_19AF6:
		movem.l	(sp)+,d0-d7/a2-a6
		rts

sub_190EC:
		move.l	d1,-(sp)
		lsl.l	#1,d0
		move.l	d0,d1
		lsl.l	#2,d0
		add.l	d1,d0
		move.l	(sp)+,d1
		rts

AddString:
		movem.l	d0-a6,-(sp)
		exg	a1,a0
		bsr.w	sub_19256
		exg	a1,a0
		bsr.w	CopyString
		movem.l	(sp)+,d0-a6
		rts

ConvDecBytePtr:
		movem.l	d0-d4/a0,-(sp)
		lea	3(a0),a0
		bra.s	loc_19142

ConvertToDecByte:
		movem.l	d0-d4/a0,-(sp)
		lea	DecByteTemp,a0
loc_19142:
		move.w	d0,d1
		moveq	#2,d4
loc_19146:
		andi.l	#$3FF,d1
		divu.w	#$A,d1
		move.l	d1,d3
		swap	d3
		andi.b	#$F,d3
		addi.b	#$30,d3
		move.b	d3,-(a0)
		dbf	d4,loc_19146
		movem.l	(sp)+,d0-d4/a0
		rts

DecByteSave:	dcb.b 3,$30
DecByteTemp:	dc.b   0

ConvertToDecWord:
		movem.l	d0-d4/a0-a1,-(sp)
		movea.l	a0,a1
		addq.l	#5,a0
		move.w	d0,d1
		move.w	#4,d4
loc_1917A:
		andi.l	#$FFFF,d1
		divu.w	#$A,d1
		move.l	d1,d3
		swap	d3
		andi.b	#$F,d3
		addi.b	#$30,d3
		move.b	d3,-(a0)
		dbf	d4,loc_1917A
		moveq	#3,d0
loc_19198:
		cmpi.b	#'0',(a1)
		bne.s	loc_191A6
		move.b	#' ',(a1)+ ; ' '
		dbf	d0,loc_19198
loc_191A6:
		movem.l	(sp)+,d0-d4/a0-a1
		rts

CopyString:
		movem.l	d0-a6,-(sp)
		bsr.w	GetLen
		addq.w	#1,d0
		movea.l	(4).w,a6
		jsr	-$270(a6)
		movem.l	(sp)+,d0-a6
		rts

sub_191DE:
		movem.l	d1-a6,-(sp)
		bsr.w	sub_1920A
		move.l	d0,d7
		moveq	#0,d0
		subq.w	#1,d7
		bmi.s	loc_19204
loc_191EE:
		bsr.w	sub_190EC
		move.b	(a0)+,d1
		subi.b	#$30,d1	; '0'
		andi.l	#$F,d1
		add.l	d1,d0
		dbf	d7,loc_191EE
loc_19204:
		movem.l	(sp)+,d1-a6
		rts

sub_1920A:
		movem.l	d1/a0,-(sp)
		moveq	#$FFFFFFFF,d0
loc_19210:
		addq.l	#1,d0
		move.b	(a0)+,d1
		cmpi.b	#$39,d1	; '9'
		bhi.s	loc_19220
		cmpi.b	#$30,d1	; '0'
		bcc.s	loc_19210
loc_19220:
		movem.l	(sp)+,d1/a0
		rts

GetLen:
		movem.l	d1-a6,-(sp)
		moveq	#0,d0
loc_1922C:
		tst.b	(a0)+
		beq.s	loc_19234
		addq.l	#1,d0
		bra.s	loc_1922C
loc_19234:
		movem.l	(sp)+,d1-a6
		rts

MoveNextString:
		tst.b	(a0)+
		bne.s	MoveNextString	; increase ptr until not zero
		rts

sub_19256:
		bsr.w	MoveNextString
		subq.l	#1,a0
		rts

sub_1934E:
		movea.l	sp,a3
		lea	dword_1937C,a4
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3)+,(a4)+
		move.l	(a3),(a4)
		jsr	sub_19FA8
		rts
dword_1937C:	dcb.l $100,0

CheckMem
		movem.l	d0-a6,-(sp)
		move.l	a0,((MEM_DEBUG_INFO+8)).l
		move.l	4(a0),((MEM_DEBUG_INFO+$C)).l
		move.l	8(a0),((MEM_DEBUG_INFO+$10)).l
		tst.l	(a0)
		beq		.exit
		movea.l	(a0),a1
		move.l	4(a0),d0
		beq		.exit
		tst.l	d0
		beq		.exit
		bmi		.exit
		move.l	a1,d7
		tst.l	d7
		beq		.exit
		bmi		.exit
		subq.l	#4,a1
		addq.l	#8,d0
		movea.l	a1,a2
		adda.l	d0,a2
		cmpi.l	#'SYM2',(a1)
		beq.s	.loc_197DC
		bsr.w	sub_1934E
.loc_197DC:
		cmpi.l	#'SYM2',-4(a2)
		beq		.exit
		bsr.w	sub_1934E
.exit
		movem.l	(sp)+,d0-a6
		rts

GetMem:
		movem.l	d1-a6,-(sp)
		movea.l	a0,a2
		move.l	4(a2),d0
		tst.l	d0
		beq.s	.exit
		move.l	8(a2),d1
		move.l	d0,d2
		addq.l	#8,d0
		CALLEXEC AllocMem
		tst.l	d0
		bne.s	loc_19824
		move.l	d0,(a2)
		move.l	#ERRFastMem_TXT,(ErrorText_TXT).l
.exit:
		movem.l	(sp)+,d1-a6
		rts

loc_19824:
		movea.l	d0,a0
		move.l	#'SYM2',(a0)+
		move.l	a0,(a2)
		adda.l	d2,a0
		move.l	#'SYM2',(a0)+
		movem.l	(sp)+,d1-a6
		rts

FreeMem		
		movem.l	d0-a6,-(sp)
		move.l	a0,((MEM_DEBUG_INFO+8)).l
		move.l	4(a0),((MEM_DEBUG_INFO+$C)).l
		move.l	8(a0),((MEM_DEBUG_INFO+$10)).l
		tst.l	(a0)
		beq.s	.exit
		movea.l	(a0),a1
		clr.l	(a0)
		move.l	4(a0),d0
		beq.s	.exit
		tst.l	d0
		beq.s	.loc_19336
		bmi.s	.loc_19336
		move.l	a1,d7
		tst.l	d7
		beq.s	.loc_19336
		bmi.s	.loc_19336
		btst	#0,d7
		bne.s	.loc_19336
		subq.l	#4,a1
		addq.l	#8,d0
		movea.l	a1,a2
		adda.l	d0,a2
		cmpi.l	#'SYM2',(a1)
		beq.s	.loc_19314
		jsr	WarnFlash
		bsr.w	sub_1934E
.loc_19314
		cmpi.l	#'SYM2',-4(a2)
		beq.s	.loc_19328
		jsr	WarnFlash
		bsr.w	sub_1934E

.loc_19328
		CALLEXEC FreeMem
		;movea.l	(4).w,a6
		;jsr	-$D2(a6)
.exit
		movem.l	(sp)+,d0-a6
		rts
.loc_19336:
		movem.l	(sp)+,d0-a6
		move.l	(sp),((DEBUG+4)).l
		move.l	#'FreM',(DEBUG).l
		rts

sub_19B46:
		movem.l	d0-d7/a1-a6,-(sp)
		move.l	a0,(dword_19CF4).l
		movea.l	a0,a2
		lea	$32(a0),a3
		clr.l	(a2)+
		cmpi.w	#$FFFF,(word_19CFA).l
		bne.s	loc_19B6C
		movem.w	(word_19CFC).l,d0-d2
		add.w	d2,d0
loc_19B6C:
		move.w	d0,(a2)+
		move.w	d1,(a2)+
		move.w	d0,d4
		move.w	d1,d5
		movea.l	a1,a0
		jsr	sub_19AFC
		move.w	d0,d1
		lsl.w	#3,d0
		move.w	d0,(a2)+
		move.w	d0,(word_19CF8).l
		move.w	d0,d2
		move.w	d0,d6
		move.w	(MENUFONT_H).l,(a2)+
		move.w	(word_19D04).l,d0
		cmpi.b	#$2D,(a1) ; '-'
		bne.s	loc_19BA4
		move.w	(word_19D0A).l,d0
loc_19BA4:
		move.b	-1(a1,d1.w),(byte_19CF0).l
		cmpi.b	#$41,-1(a1,d1.w) ; 'A'
		bne.s	loc_19BD0
		move.b	#$20,-1(a1,d1.w) ; ' '
		move.b	-2(a1,d1.w),d2
		move.b	#$20,-2(a1,d1.w) ; ' '
		move.b	d2,(word_19D0C).l
		move.w	(word_19D08).l,d0
loc_19BD0:
		cmpi.b	#$3F,(a1) ; '?'
		bne.s	loc_19BF2
		move.b	#$20,(a1) ; ' '
		move.w	(word_19D06).l,d0
		cmpi.b	#$2B,1(a1) ; '+'
		bne.s	loc_19BF2
		ori.w	#$100,d0
		move.b	#$20,1(a1) ; ' '
loc_19BF2:
		cmpi.b	#$26,-1(a1,d1.w) ; '&'
		bne.s	loc_19C24
		move.b	#$20,-1(a1,d1.w) ; ' '
		cmpi.w	#$FFFF,(word_19CFA).l
		beq.s	loc_19C1C
		move.w	#$FFFF,(word_19CFA).l
		movem.w	d4-d6,(word_19CFC).l
		bra.s	loc_19C36
loc_19C1C:
		add.w	d6,(word_19D00).l
		bra.s	loc_19C36
loc_19C24:
		cmpi.w	#$FFFF,(word_19CFA).l
		bne.s	loc_19C36
		move.w	#$7B,(word_19CFA).l ; '{'
loc_19C36:
		move.w	d0,(a2)+
		clr.l	(a2)+
		move.l	a3,(a2)+
		clr.l	(a2)+
		move.w	(word_19D0C).l,(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		movea.l	a3,a2
		move.w	(MENUCOL).l,(a2)+
		move.w	#1,(a2)+
		move.w	#0,(a2)+
		move.w	#1,(a2)+
		move.l	#0,(a2)+
		move.l	a1,(a2)+
		move.l	#0,(a2)+
		movea.l	a2,a0
		movem.l	(sp)+,d0-d7/a1-a6
		cmpi.b	#$BB,(byte_19CF0).l
		bne.s	loc_19CD4
		movem.l	d0-d7/a2-a6,-(sp)
		movea.l	(dword_19CF4).l,a3
		move.l	a0,$1C(a3)
		movea.l	a0,a3
		movea.l	a0,a2
		movea.l	a1,a0
		jsr	MoveNextString
		add.w	(word_19CF8).l,d0
		subi.w	#$14,d0
		moveq	#3,d1
		cmpi.b	#0,(a0)
		beq.s	loc_19CCC
loc_19CA6:
		movea.l	a0,a1
		movea.l	a2,a0
		jsr	sub_19D10
		movea.l	a0,a2
		movea.l	a1,a0
		jsr	MoveNextString
		add.w	((MENUFONT_H+2)).l,d1
		cmpi.b	#0,(a0)
		beq.s	loc_19CCC
		move.l	a2,(a3)
		movea.l	a2,a3
		bra.s	loc_19CA6
loc_19CCC:
		movea.l	a0,a1
		movea.l	a2,a0
		movem.l	(sp)+,d0-d7/a2-a6
loc_19CD4:
		cmpi.w	#$7B,(word_19CFA).l
		bne.s	locret_19CEE
		movem.w	(word_19CFC).l,d0-d1
		move.w	#0,(word_19CFA).l
locret_19CEE:
		rts

byte_19CF0:
		dc.b 0
		dc.b 0
		dc.b 0
		dc.b 0
dword_19CF4:
		dc.l 0
word_19CF8:
		dc.w 0
word_19CFA:
		dc.w 0
word_19CFC:
		dc.w 0
		dc.b 0
		dc.b 0
word_19D00:
		dc.w 0
		dc.b 0
		dc.b 0
word_19D04:	dc.w $52
word_19D06:	dc.w $5B
word_19D08:	dc.w $56
word_19D0A:	dc.w $42
word_19D0C:	dc.w 0
			dc.w $102

sub_19D10:
		movem.l	d0-d7/a1-a6,-(sp)
		andi.w	#$FEFF,(word_19EE8).l
		movea.l	a0,a2
		lea	$22(a0),a3
		clr.l	(a2)+
		cmpi.w	#$FFFF,(word_19EDA).l
		bne.s	loc_19D38
		movem.w	(word_19EDC).l,d0-d2
		add.w	d2,d0
loc_19D38:
		move.w	d0,(a2)+
		move.w	d1,(a2)+
		move.w	d0,d4
		move.w	d1,d5
		movea.l	a1,a0
		jsr	GetLen
		move.w	d0,d1
		lsl.w	#3,d0
		move.w	d0,(a2)+
		move.w	d0,d2
		move.w	d0,d6
		move.w	((MENUFONT_H+2)).l,(a2)+
		move.w	(word_19EE4).l,d0
		cmpi.b	#$2D,(a1) ; '-'
		bne.s	loc_19D6A
		move.w	(word_19EEC).l,d0
loc_19D6A:
		cmpi.b	#$41,-1(a1,d1.w) ; 'A'
		bne.s	loc_19D8E
		move.b	#$20,-1(a1,d1.w) ; ' '
		move.b	-2(a1,d1.w),d2
		move.b	#$20,-2(a1,d1.w) ; ' '
		move.b	d2,(word_19EEE).l
		move.w	(word_19EEA).l,d0
loc_19D8E:
		cmpi.b	#$3F,(a1) ; '?'
		bne.s	loc_19E02
		move.b	#$20,(a1) ; ' '
		move.w	(word_19EE6).l,d0
		cmpi.b	#$39,1(a1) ; '9'
		bhi.s	loc_19DE8
		cmpi.b	#$30,1(a1) ; '0'
		bcs.s	loc_19DE8
		movem.l	d0-a6,-(sp)
		lea	1(a1),a0
		jsr	sub_191DE
		move.w	d0,(word_19EFC).l
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	dword_19F00,a0
		move.l	(a0,d0.w),d0
		move.l	d0,(dword_19EF4).l
		move.l	#$FFFFFFFE,(dword_19EF8).l
		movem.l	(sp)+,d0-a6
		move.b	#$20,1(a1) ; ' '
loc_19DE8:
		cmpi.b	#$2B,1(a1) ; '+'
		bne.s	loc_19E02
		ori.w	#$100,d0
		ori.w	#$100,(word_19EE8).l
		move.b	#$20,1(a1) ; ' '
loc_19E02:
		cmpi.b	#$26,-1(a1,d1.w) ; '&'
		bne.s	loc_19E34
		move.b	#$20,-1(a1,d1.w) ; ' '
		cmpi.w	#$FFFF,(word_19EDA).l
		beq.s	loc_19E2C
		move.w	#$FFFF,(word_19EDA).l
		movem.w	d4-d6,(word_19EDC).l
		bra.s	loc_19E46
loc_19E2C:
		add.w	d6,(word_19EE0).l
		bra.s	loc_19E46
loc_19E34:
		cmpi.w	#$FFFF,(word_19EDA).l
		bne.s	loc_19E46
		move.w	#$7B,(word_19EDA).l ; '{'
loc_19E46:
		move.w	d0,(a2)+
		move.l	#0,(dword_19EF0).l
		tst.w	(word_19EFC).l
		beq.s	loc_19E82
		movem.l	(dword_19EF4).l,d0-d1
		and.l	d1,d0
		move.l	d0,(dword_19EF0).l
		rol.l	#1,d1
		move.l	d1,(dword_19EF8).l
		subq.w	#1,(word_19EFC).l
		move.w	(word_19EE8).l,d0
		move.w	d0,-2(a2)
loc_19E82:
		move.l	(dword_19EF0).l,(a2)+
		move.l	a3,(a2)+
		clr.l	(a2)+
		move.w	(word_19EEE).l,(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		movea.l	a3,a2
		move.w	(MENUCOL).l,(a2)+
		move.w	#1,(a2)+
		move.w	#0,(a2)+
		move.w	#1,(a2)+
		move.l	#0,(a2)+
		move.l	a1,(a2)+
		move.l	#0,(a2)+
		movea.l	a2,a0
		movem.l	(sp)+,d0-d7/a1-a6
		cmpi.w	#$7B,(word_19EDA).l ; '{'
		bne.s	locret_19ED8
		movem.w	(word_19EDC).l,d0-d1
		move.w	#0,(word_19EDA).l
locret_19ED8:
		rts
word_19EDA:	dc.w 0
word_19EDC:	dc.w 0
			dc.w 0
word_19EE0:	dc.w 0
			dc.w 0
word_19EE4:	dc.w $52
word_19EE6:	dc.w $5B
word_19EE8:	dc.w $53
word_19EEA:	dc.w $56
word_19EEC:	dc.w $42
word_19EEE:	dc.w 0
dword_19EF0:	dc.l 0
dword_19EF4:	dc.l 0
dword_19EF8:	dc.l 0
word_19EFC:	dc.w 0
			dc.b 0
			dc.b 0
dword_19F00:	dc.l 1,	3, 7, $F, $F1, $F3, $F7, $FF, $FF1, $FF3, $FF7
				dc.l $FFF, $FFF1, $FFF3, $FFF7,	$FFFF, $FFFF1, $FFFF3
				dc.l $FFFF7, $FFFFF, $FFFFF1, $FFFFF3, $FFFFF7,	$FFFFFF
				dc.l $FFFFFF1, $FFFFFF3, $FFFFFF7, $FFFFFFF, $FFFFFFF1
				dc.l $FFFFFFF3,	$FFFFFFF7, $FFFFFFFF

sub_19FA8:
		movem.l	d0-a6,-(sp)
		lea	MEM_DEBUG_INFO,a2
		move.l	12(a2),d0
		move.l	$10(a2),d1
		jsr	PrintDblAssHex
		move.l	(a2),d0
		move.l	4(a2),d1
		jsr	PrintDblAssHex
		move.l	#MemFail_ERR,(AssText_TXT).l
		jsr	PrintHexBlock
		movem.l	(sp)+,d0-a6
		rts

LinkNullSpriteCopList:
		movem.l	d0-d1,-(sp)
		move.l	(SpriteNULL_PTR).l,d0
		move.l	d0,d1
		swap	d0
		move.w	#$120,(a0)+
		move.w	d0,(a0)+
		move.w	#$122,(a0)+
		move.w	d1,(a0)+
		move.w	#$124,(a0)+
		move.w	d0,(a0)+
		move.w	#$126,(a0)+
		move.w	d1,(a0)+
		move.w	#$128,(a0)+
		move.w	d0,(a0)+
		move.w	#$12A,(a0)+
		move.w	d1,(a0)+
		move.w	#$12C,(a0)+
		move.w	d0,(a0)+
		move.w	#$12E,(a0)+
		move.w	d1,(a0)+
		move.w	#$130,(a0)+
		move.w	d0,(a0)+
		move.w	#$132,(a0)+
		move.w	d1,(a0)+
		move.w	#$134,(a0)+
		move.w	d0,(a0)+
		move.w	#$136,(a0)+
		move.w	d1,(a0)+
		move.w	#$138,(a0)+
		move.w	d0,(a0)+
		move.w	#$13A,(a0)+
		move.w	d1,(a0)+
		move.w	#$13C,(a0)+
		move.w	d0,(a0)+
		move.w	#$13E,(a0)+
		move.w	d1,(a0)+
		movem.l	(sp)+,d0-d1
		rts

OldCopList:
		movem.l	d0-a6,-(sp)
		move.w	#$80,($DFF096).l
		movea.l	(_GraphicsBase).l,a0
		move.l	$26(a0),($DFF080).l
		move.l	$26(a0),($DFF080).l
		clr.w	($DFF088).l
		move.w	#$8080,($DFF096).l
		movem.l	(sp)+,d0-a6
		rts
