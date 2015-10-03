    ifnd MIDI_MIDIDEFS_I
MIDI_MIDIDEFS_I set 1

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
* mididefs.i  - MIDI message definitions
*
* This information is derived from MIDI 1.0 Detailed Specification
* v4.0 published by the Internation MIDI Association and is
* current as of June, 1988.  The Sys/Ex ID numbers are hot off the
* IMA's FAX machine as of Jan 8, 1990.
*
*************************************************************************

****************************************************************
*
*   Status Bytes
*
****************************************************************

    ; Channel Voice Messages (1sssnnnn) (OR with channel number)
MS_NoteOff	equ $80
MS_NoteOn	equ $90
MS_PolyPress	equ $A0
MS_Ctrl 	equ $B0
MS_Mode 	equ $B0
MS_Prog 	equ $C0
MS_ChanPress	equ $D0
MS_PitchBend	equ $E0

MS_StatBits	equ $F0
MS_ChanBits	equ $0F

    ; System Common Messages (11110sss)
MS_System	equ $F0 	    ; min system status byte
MS_SysEx	equ $F0
MS_QtrFrame	equ $F1
MS_SongPos	equ $F2
MS_SongSelect	equ $F3
MS_TuneReq	equ $F6
MS_EOX		equ $F7

    ; System Real Time Messages (11111sss)
MS_RealTime	equ $F8 	    ; min real time status byte
MS_Clock	equ $F8
MS_Start	equ $FA
MS_Continue	equ $FB
MS_Stop 	equ $FC
MS_ActvSense	equ $FE
MS_Reset	equ $FF


****************************************************************
*
*   Standard Controllers
*
****************************************************************

    ; Continuous 14 bit - MSB: 0-1f, LSB: 20-3f
MC_Bank 	equ $00
MC_ModWheel	equ $01
MC_Breath	equ $02
MC_Foot 	equ $04
MC_PortaTime	equ $05
MC_DataEntry	equ $06
MC_Volume	equ $07
MC_Balance	equ $08
MC_Pan		equ $0a
MC_Expression	equ $0b
MC_General1	equ $10
MC_General2	equ $11
MC_General3	equ $12
MC_General4	equ $13

    ; Continuous 7 bit (switches: 0-3f=off, 40-7f=on)
MC_Sustain	equ $40
MC_Porta	equ $41
MC_Sustenuto	equ $42
MC_SoftPedal	equ $43
MC_Hold2	equ $45
MC_General5	equ $50
MC_General6	equ $51
MC_General7	equ $52
MC_General8	equ $53
MC_ExtDepth	equ $5b
MC_TremoloDepth equ $5c
MC_ChorusDepth	equ $5d
MC_CelesteDepth equ $5e
MC_PhaserDepth	equ $5f

    ; Parameters
MC_DataIncr	equ $60
MC_DataDecr	equ $61
MC_NRPNL	equ $62
MC_NRPNH	equ $63
MC_RPNL 	equ $64
MC_RPNH 	equ $65

MC_Max		equ $78     ; max controller value


****************************************************************
*
*   Channel Modes
*
****************************************************************

MM_Min		equ $79     ; min mode value

MM_ResetCtrl	equ $79
MM_Local	equ $7a
MM_AllOff	equ $7b
MM_OmniOff	equ $7c
MM_OmniOn	equ $7d
MM_Mono 	equ $7e
MM_Poly 	equ $7f


****************************************************************
*
*   Registered Parameter Numbers
*
*   These are 16 bit values that need to be separated into two
*   bytes for use with the MC_RPNH & MC_RPNL messages using 8
*   bit math (hi = MRP_ >> 8, lo = MRP_ & equ $ff) as opposed to 7
*   bit math.  This is done so that the defines match the
*   numbers from the MMA.  See MIDI 1.0 Detailed Spec v4.0 pp
*   12, 23 for more info.
*
****************************************************************

MRP_PBSens	equ $0000
MRP_FineTune	equ $0001
MRP_CourseTune	equ $0002


****************************************************************
*
*   MTC Quarter Frame messages
*
*   Qtr Frame message is F1 0nnndddd where
*
*	nnn is a message type defined below
*	dddd is 4 bit data nibble for those message types
*
*   Each pair of nibbles is combined by the receiver into a
*   single byte. There are masks and type values defined for
*   some of these data bytes below.
*
****************************************************************

    ; Message Types
MTCQ_FrameL	equ $00
MTCQ_FrameH	equ $10
MTCQ_SecL	equ $20
MTCQ_SecH	equ $30
MTCQ_MinL	equ $40
MTCQ_MinH	equ $50
MTCQ_HourL	equ $60
MTCQ_HourH	equ $70     ; also contains time code type

    ; Message Masks
MTCQ_TypeMask	equ $70     ; mask for type bits in message
MTCQ_DataMask	equ $0f     ; mask for data bits in message

    ; Hour Byte
MTCH_TypeMask	equ $60     ; mask for time code type
MTCH_HourMask	equ $1f     ; hours mask (range 0-23)

    ; Time code type values for hour byte
MTCT_24FPS	equ $00
MTCT_25FPS	equ $20
MTCT_30FPS_Drop equ $40
MTCT_30FPS_NonDrop  equ $60


****************************************************************
*
*   Sys/Ex ID numbers
*
*   Now includes 3 byte extension for the American Group.  This
*   new format uses a equ $00 as the sys/ex id followed by two
*   additional bytes that actually identify the manufacturer.
*   These new extended id constants are 32 bit values with 24
*   significant bits.
*
****************************************************************

    ; North American Group (1 byte)
MID_Sequential	    equ $01
MID_IDP 	    equ $02
MID_OctavePlateau   equ $03
MID_Moog	    equ $04
MID_Passport	    equ $05
MID_Lexicon	    equ $06
MID_Kurzweil	    equ $07
MID_Fender	    equ $08
MID_Gulbransen	    equ $09
MID_AKG 	    equ $0a
MID_Voyce	    equ $0b
MID_Waveframe	    equ $0c
MID_ADA 	    equ $0d
MID_Garfield	    equ $0e
MID_Ensoniq	    equ $0f
MID_Oberheim	    equ $10
MID_Apple	    equ $11
MID_GreyMatter	    equ $12
MID_PalmTree	    equ $14
MID_JLCooper	    equ $15
MID_Lowrey	    equ $16
MID_AdamsSmith	    equ $17
MID_Emu 	    equ $18
MID_Harmony	    equ $19
MID_ART 	    equ $1a
MID_Baldwin	    equ $1b
MID_Eventide	    equ $1c
MID_Inventronics    equ $1d
MID_Clarity	    equ $1f

    ; North American Group (3 byte)
MID_XAmerica	    equ $00	; North American 3 byte prefix

MIDX_DigitalMusic   equ $000007
MIDX_Iota	    equ $000008
MIDX_Artisyn	    equ $00000a
MIDX_IVL	    equ $00000b
MIDX_SouthernMusic  equ $00000c
MIDX_LakeButler     equ $00000d
MIDX_DOD	    equ $000010
MIDX_PerfectFret    equ $000014
MIDX_KAT	    equ $000015
MIDX_Opcode	    equ $000016
MIDX_Rane	    equ $000017
MIDX_SpatialSound   equ $000018
MIDX_KMX	    equ $000019
MIDX_Brenell	    equ $00001a
MIDX_Peavey	    equ $00001b
MIDX_360	    equ $00001c
MIDX_Axxes	    equ $000020
MIDX_CAE	    equ $000026
MIDX_Cannon	    equ $00002b
MIDX_BlueSkyLogic   equ $00002e
MIDX_Voce	    equ $000031

    ; European Group
MID_SIEL	    equ $21
MID_Synthaxe	    equ $22
MID_Hohner	    equ $24
MID_Twister	    equ $25
MID_Solton	    equ $26
MID_Jellinghaus     equ $27
MID_Southworth	    equ $28
MID_PPG 	    equ $29
MID_JEN 	    equ $2a
MID_SSL 	    equ $2b
MID_AudioVeritrieb  equ $2c
MID_Elka	    equ $2f
MID_Dynacord	    equ $30
MID_Clavia	    equ $33
MID_Soundcraft	    equ $39

    ; Japanese Group
MID_Kawai	    equ $40
MID_Roland	    equ $41
MID_Korg	    equ $42
MID_Yamaha	    equ $43
MID_Casio	    equ $44
MID_Kamiya	    equ $46
MID_Akai	    equ $47
MID_JapanVictor     equ $48
MID_Mesosha	    equ $49

    ; Universal ID Numbers
MID_UNC 	equ $7d
MID_UNRT	equ $7e
MID_URT 	equ $7f


****************************************************************
*
*   Miscellaneous
*
****************************************************************

MiddleC 	equ 60	    ; Middle C note value
DefaultVelocity equ 64	    ; Default Note On or Off velocity
PitchBendCenter equ $2000   ; Pitch bend center position as a 14 bit word
MClksPerQtr	equ 24	    ; MIDI clocks per qtr-note
MClksPerSP	equ 6	    ; MIDI clocks per song position index
MCCenter	equ 64	    ; Center value for controllers like Pan and Balance


    endc MIDI_MIDIDEFS_I
