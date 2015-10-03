#ifndef MIDI_MIDIPREFS_H
#define MIDI_MIDIPREFS_H

/************************************************************************
*     C. A. M. D.	(Commodore Amiga MIDI Driver)                   *
*************************************************************************
*									*
* Design & Development	- Roger B. Dannenberg				*
*			- Jean-Christophe Dhellemmes			*
*			- Bill Barton					*
*                       - Darius Taghavy                                *
*                                                                       *
* Copyright 1990-1999 by Amiga, Inc.                                    *
*************************************************************************
*
* midiprefs.h - CAMD MIDI preferences
*
************************************************************************/

#ifndef EXEC_TYPES_H
  #include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/***************************************************************
*
*   MidiUnitDef
*
***************************************************************/

#define MaxMidiDevName		32
#define MaxMidiInOutName	32
#define MaxMidiComment		34

struct MidiUnitDef 
{
    UBYTE MidiDeviceName[32];	/* Name of MIDI device driver for this Unit (ignored for MUDF_Internal) */
    UBYTE MidiClusterInName[32];/* Name of Cluster for input from MIDI device driver */
    UBYTE MidiClusterOutName[32];/* Name of Cluster for output to MIDI device driver */
    UBYTE MidiDeviceComment[34]; /* Comment field */
    UBYTE MidiDevicePort;	/* MIDI device driver port number for this Unit */
    UBYTE Flags;
    ULONG XmitQueueSize;
    ULONG RecvQueueSize;
    ULONG Reserved[4];
};

    /* flags */
#define MUDF_Internal	 (1<<0)	/* Use Amiga's internal serial port.
				   Ignore MidiDeviceName/Port when set.
				   Only one Unit can legally have this bit set. */
#define MUDF_Ignore	 (1<<1) /* Ignore this entry. */

/* !!! maybe additional flags:	running status enable, thru */

    /* minimum queue sizes */

#define MinXmitQueueSize 512L	/* minimum send queue size (bytes) */
#define MinRecvQueueSize 2048L	/* minimum recv queue size (words) */


/***************************************************************
*
*   MidiPrefs
*
***************************************************************/


#define ID_MIDI MAKE_ID('M','I','D','I')

struct MidiPrefs 
{
    UBYTE NUnits;
    UBYTE pad0[3];
    struct MidiUnitDef UnitDef[1];
};

#define MidiPrefsName  "midi.prefs"

#endif
