    ifnd    MIDI_CAMDBASE_I
MIDI_CAMDBASE_I set 1

*************************************************************************
*     C. A. M. D.	(Commodore Amiga MIDI Driver)                   *
*************************************************************************
*									*
* Design & Development	- Roger B. Dannenberg				*
*			- Jean-Christophe Dhellemmes			*
*			- Bill Barton					*
*                       - Darius Taghavy                                *
*                                                                       *
* Copyright 1990-1999 by Amiga, Inc.                                    *
*                                                                       *
*************************************************************************
*
* camdbase.i - CAMD library base structure
*
*************************************************************************

	ifnd	EXEC_LIBRARIES_I
	include "exec/libraries.i"
	endc

	ifnd	EXEC_LISTS_I
	include "exec/lists.i"
	endc

	ifnd	EXEC_SEMAPHORES_I
	include "exec/semaphores.i"
	endc


    STRUCTURE CamdBase,LIB_SIZE
	UWORD	camd_pad0

;	ULONG	camd_Time	    ; current time
;	WORD	camd_TickFreq	    ; ideal CAMD Tick frequency
;	WORD	camd_TickErr	    ; nanosecond error from ideal Tick length to real tick length
;				    ; actual tick length is:  1/TickFreq + TickErr/1e9
;				    ; -705 < TickErr < 705

	; private stuff below here

	LABEL	CamdBase_PublicSize


;CAMD_TickErr_Min    equ     -705
;CAMD_TickErr_Max    equ     705

    endc
