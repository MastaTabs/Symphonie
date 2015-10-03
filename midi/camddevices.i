    ifnd    MIDI_CAMDDEVICES_I
MIDI_CAMDDEVICES_I set 1

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
* devices.i   - MIDI devicce driver include file
*
*************************************************************************


    ifnd    EXEC_TYPES_I
    include "exec/types.i"
    endc


    STRUCTURE MidiPortData,0
	FPTR	mpd_ActivateXmit
	LABEL	MidiPortData_Size

    STRUCTURE MidiDeviceData,0
	ULONG	mdd_Magic		; MDD_Magic
	APTR	mdd_Name		; driver name
	APTR	mdd_IDString
	UWORD	mdd_Version
	UWORD	mdd_Revision

	FPTR	mdd_Init		; called after LoadSeg()
	FPTR	mdd_Expunge		; called before UnLoadSeg()
	FPTR	mdd_OpenPort
	FPTR	mdd_ClosePort

	UBYTE	mdd_NPorts		; number of ports
	UBYTE	mdd_Flags		; currently none

	LABEL	MidiDeviceData_Size


MDD_SegOffset	equ 8			; offset to structure in segment (past NextSeg and MOVEQ/RTS)
MDD_Magic	equ 'MDEV'              ; Magic # for mdd_Magic


    endc
