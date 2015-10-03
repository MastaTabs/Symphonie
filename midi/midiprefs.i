    ifnd    MIDI_MIDIPREFS_I
MIDI_MIDIPREFS_I set 1

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
* midiprefs.i - CAMD library base structure
*
*************************************************************************

    ifnd    EXEC_TYPES_I
	include "exec/types.i"
    endc


****************************************************************
*
*   MidiUnitDef
*
****************************************************************

    STRUCTURE MidiUnitDef,0
	STRUCT	mud_MidiDeviceName,32	; Name of MIDI device driver for this Unit (ignored for MUDF_Internal)
	STRUCT	mud_MidiClusterInName,32  ; Name of Cluster for input from MIDI device driver
	STRUCT	mud_MidiClusterOutName,32 ; Name of Cluster for output to MIDI device driver
	STRUCT	mud_MidiDeviceComment,34 ; Comment for MIDI device driver
	UBYTE	mud_MidiDevicePort	; MIDI device driver port number for this Unit
	UBYTE	mud_Flags
	ULONG	mud_XmitQueueSize
	ULONG	mud_RecvQueueSize
	LABEL	MidiUnitDef_Size

    ; flags
	BITDEF	MUD,Internal,0	    ; Use Amiga's internal serial port.
				    ; Ignore MidiDeviceName/Port when set.
				    ; Only one Unit can legally have this bit set.
	BITDEF	MUD,Ignore,1	    ; Ignore this entry.

    ; minimum queue sizes

MinXmitQueueSize    equ 512	    ; minimum send queue size (bytes)
MinRecvQueueSize    equ 2048	    ; minimum recv queue size (words)


****************************************************************
*
*   MidiPrefs
*
****************************************************************

; MaxMidiUnits	equ 4		    ; Max # of MIDI Units

    STRUCTURE MidiPrefs,0
;	ULONG	mp_Magic	    ; MidiPrefsMagic
	UBYTE	mp_NUnits
	UBYTE	mp_pad0
	STRUCT	mp_UnitDef,MidiUnitDef_Size
	LABEL	MidiPrefs_Size

;MidiPrefsMagic	equ 'MPRF'

MidiPrefsName	macro
	dc.b	'midi.prefs',0
	endm

    endc
