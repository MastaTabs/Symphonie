    ifnd    MIDI_CAMD_I
MIDI_CAMD_I set 1

*************************************************************************
*     C. A. M. D.       (Commodore Amiga MIDI Driver)                   *
*************************************************************************
*                                                                       *
* Design & Development  - Roger B. Dannenberg                           *
*                       - Jean-Christophe Dhellemmes                    *
*                       - Bill Barton                                   *
*                       - Darius Taghavy                                *
*                                                                       *
* Copyright 1990-1999 by Amiga, Inc.                                  *
*                                                                       *
*************************************************************************
*
* camd.i      - General CAMD include files.
*             - General CAMD definitions.
*             - CAMD library functions.
*
*************************************************************************

    ifnd    EXEC_TYPES_I
    include "exec/types.i"
    endc

    ifnd    EXEC_MACROS_I
    include "exec/macros.i"
    endc

    ifnd    EXEC_NODES_I
    include "exec/nodes.i"
    endc

    ifnd    UTILITY_TAGITEM_I
    include "utility/tagitem.i"
    endc


****************************************************************
*
*   Library Name and Version
*
****************************************************************

CamdName    macro
            dc.b    'camd.library',0
            endm

; CamdVersion equ     2     ; !!! old


****************************************************************
*
*   CAMD internal lists that can be locked
*
****************************************************************

    ENUM
    EITEM   CD_Linkages                         ; internal linages
    EITEM   CD_NLocks


    ifne 0      ; !!! old

****************************************************************
*
*   MIDI Port Definitions
*
*   The default Unit Ports are:
*
*              ports
*       unit  in  out
*       ----  --  ---
*        0     1   0
*        1     3   2
*        2     5   4
*        3     6   5
*
*   User ports are allocated starting at CMP_Max and descending.
*
****************************************************************

CMP_Out     equ 0       ; Default port # of MIDI Output (really (unit) * 2)
CMP_In      equ 1       ; Default port # of MIDI Input (really (unit) * 2 + 1)
CMP_Max     equ 31      ; highest port #
    endc


****************************************************************
*
*   MidiMsg
*
****************************************************************

    STRUCTURE MidiMsg,0
        LABEL   mm_Msg
        UBYTE   mm_Status
        UBYTE   mm_Data1
        UBYTE   mm_Data2
        UBYTE   mm_Port
        ULONG   mm_Time
        LABEL   MidiMsg_Size


***************************************************************
*
*   MidiCluster -- a meeting place for linkages
*
*   All fields are READ ONLY.  Modifications to fields may
*   performed only through the appropriate library function
*   calls.
*
***************************************************************

    STRUCTURE MidiCluster,LN_SIZE
        WORD    mcl_Pad
        STRUCT  mcl_Receivers,LH_SIZE
        STRUCT  mcl_Senders,LH_SIZE
        WORD    mcl_PublicParticipants
        UWORD   mcl_Flags
        LABEL   MidiCluster_Size
        ; NOTE: Cluster name follows structure, and is pointed to by ln_Name

***************************************************************
*
*   MidiLink -- links a cluster and a MidiNode
*
*   All fields are READ ONLY.  Modifications to fields may
*   performed only through the appropriate library function
*   calls.
*
***************************************************************

    STRUCTURE SysExFilter,0
        LABEL   sxf_Packed
        UBYTE   sxf_Mode                ; mode bits
        STRUCT  sxf_ID,3                ; space for 3 1-byte id's or 1 3-byte id
        LABEL   SysExFilter_Size

    STRUCTURE MidiLink,LN_SIZE
        WORD    ml_Pad
        STRUCT  ml_OwnerNode,MLN_SIZE
        APTR    ml_MidiNode
        APTR    ml_Location
        APTR    ml_ClusterComment
        UBYTE   ml_Flags
        UBYTE   ml_PortID
        UWORD   ml_ChannelMask
        ULONG   ml_EventTypeMask
        ULONG   ml_SysExFilter
        APTR    ml_ParserData
        APTR    ml_UserData
        LABEL   MidiLink_Size

        ; MidiLink types
    ENUM
    EITEM   MLTYPE_Receiver
    EITEM   MLTYPE_Sender
    EITEM   MLTYPE_NTypes

        ; ml_Flags
    BITDEF  ML,SENDER,0                          ; this link sends from app
    BITDEF  ML,PARTCHANGE,1                      ; part change pending
    BITDEF  ML,PRIVATELINK,2                     ; make this link private
    BITDEF  ML,DEVICELINK,3                      ; set by devices only!

        ; MidiLink tags
    ENUM    TAG_USER+65

    EITEM   MLINK_Location
    EITEM   MLINK_ChannelMask
    EITEM   MLINK_EventMask
    EITEM   MLINK_UserData
    EITEM   MLINK_Comment
    EITEM   MLINK_PortID
    EITEM   MLINK_Private
    EITEM   MLINK_Priority
    EITEM   MLINK_SysExFilter
    EITEM   MLINK_SysExFilterX
    EITEM   MLINK_Parse
    EITEM   MLINK_DeviceLink
    EITEM   MLINK_ErrorCode
    EITEM   MLINK_Name


****************************************************************
*
*   MidiNode
*
*   NOTE:  Applications are not permitted to modify this
*   structure directly.  The appropriate library functions must
*   be used for such manipulation.
*
*   Alot of this stuff is camd.library private and may vanish
*   or move!
*
****************************************************************

    STRUCTURE MidiNode,LN_SIZE
        UWORD   mi_ClientType
        APTR    mi_Image

        STRUCT  mi_OutLinks,MLH_SIZE
        STRUCT  mi_InLinks,MLH_SIZE

        APTR    mi_SigTask
        APTR    mi_ReceiveHook
        APTR    mi_ParticipantHook
        BYTE    mi_ReceiveSigBit
        BYTE    mi_ParticipantSigBit
        UBYTE   mi_ErrFilter
        UBYTE   mi_Alignment

        APTR    mi_TimeReference

        ULONG   mi_MsgQueueSize         ; size of MsgQueue in MidiMsg's (includes overflow padding)
        ULONG   mi_SysExQueueSize       ; size of SysExQueue in bytes (includes overflow padding)

        ; private stuff below here

        LABEL   MidiNode_PublicSize

        ; client types

CCType_Sequencer        equ     (1<<0)
CCType_SampleEditor     equ     (1<<1)
CCType_PatchEditor      equ     (1<<2)
CCType_Notator          equ     (1<<3)
CCType_EventProcessor   equ     (1<<4)
CCType_EventFilter      equ     (1<<5)
CCType_EventRouter      equ     (1<<6)
CCType_ToneGenerator    equ     (1<<7)
CCType_EventGenerator   equ     (1<<8)
CCType_GraphicAnimator  equ     (1<<9)

        ; Tags for CreateMidi() and SetMidiAttrs()
    ENUM    TAG_USER+65

    EITEM   MIDI_Name
    EITEM   MIDI_SignalTask
    EITEM   MIDI_RecvHook
    EITEM   MIDI_PartHook
    EITEM   MIDI_RecvSignal
    EITEM   MIDI_PartSignal
    EITEM   MIDI_BufferSize
    EITEM   MIDI_SysExSize
    EITEM   MIDI_TimeStamp
    EITEM   MIDI_ErrFilter
    EITEM   MIDI_ClientType
    EITEM   MIDI_Image
    EITEM   MIDI_ErrorCode


****************************************************************
*
*   MidiNode tag items for use with CreateMidi().
*
****************************************************************

        ifne    0
    ENUM    TAG_USER+64

    EITEM   CMA_SysEx       ; int - allocate a sys/ex buffer,
                            ; ti_Data specifies size in bytes.
                            ; Default is 0.  Only valid if
                            ; RecvSize is non-zero. */

    EITEM   CMA_Parse       ; bool - enable usage of ParseMidi().
                            ; Default is FALSE.

    EITEM   CMA_Alarm       ; bool - enable usage of SetMidiAlarm().
                            ; Also allocates mi_AlarmSigBit.  Default is FALSE.

    EITEM   CMA_SendPort    ; int - initial SendPort.  Default is CMP_Out(0).

    EITEM   CMA_PortFilter  ; int - initial PortFilter.  Default is 0.

    EITEM   CMA_TypeFilter  ; int - initial TypeFilter.  Default is 0.

    EITEM   CMA_ChanFilter  ; int - initial ChanFilter.  Default is 0.

    EITEM   CMA_SysExFilter ; packed - initial SysExFilter as returned by one
                            ; of the PackSysExFilterN() macros. Default is no
                            ; filtering (i.e. recv all).

    EITEM   CMA_ErrFilter   ; int - initial ErrFilter.  Default is 0.
        endc

****************************************************************
*
*   MIDI Message Type Bits
*
*   Returned by MidiMsgType() and used with SetMidiFilters().
*
****************************************************************

    BITDEF  CM,Note,0
    BITDEF  CM,Prog,1
    BITDEF  CM,PitchBend,2

    BITDEF  CM,CtrlMSB,3
    BITDEF  CM,CtrlLSB,4
    BITDEF  CM,CtrlSwitch,5
    BITDEF  CM,CtrlByte,6
    BITDEF  CM,CtrlParam,7
    BITDEF  CM,CtrlUndef,8      ; for future ctrl # expansion

    BITDEF  CM,Mode,9
    BITDEF  CM,ChanPress,10
    BITDEF  CM,PolyPress,11

    BITDEF  CM,RealTime,12
    BITDEF  CM,SysCom,13
    BITDEF  CM,SysEx,14

    ; some handy type macros

CMF_Ctrl    equ CMF_CtrlMSB!CMF_CtrlLSB!CMF_CtrlSwitch!CMF_CtrlByte!CMF_CtrlParam!CMF_CtrlUndef
CMF_Channel equ CMF_Note!CMF_Prog!CMF_PitchBend!CMF_Ctrl!CMF_Mode!CMF_ChanPress!CMF_PolyPress
CMF_All     equ CMF_Channel!CMF_RealTime!CMF_SysCom!CMF_SysEx


****************************************************************
*
*   SysExFilter modes
*
*   Contents of sxf_Mode.
*
****************************************************************

SXF_ModeBits    equ $04
SXF_CountBits   equ $03

SXFM_Off        equ $00     ; don't filter
SXFM_1Byte      equ $00     ; match upto 3 1-byte id's
SXFM_3Byte      equ $04     ; match a single 3-byte id


****************************************************************
*
*   MIDI Error Flags
*
*   These are error flags that can arrive at a MidiNode.
*   An application may choose to ignore or process any
*   combination of error flags.  See SetMidiErrFilter() and
*   GetMidiErr() for more information.
*
****************************************************************

    BITDEF  CME,MsgErr,0        ; invalid message was sent
    BITDEF  CME,BufferFull,1    ; MidiBuffer is full
    BITDEF  CME,SysExFull,2     ; SysExBuffer is full
    BITDEF  CME,ParseMem,3      ; sys/ex memory allocation failure during parse
    BITDEF  CME,RecvErr,4       ; serial receive error
    BITDEF  CME,RecvOverflow,5  ; serial receive buffer overflow
    BITDEF  CME,SysExTooBig,6   ; Attempt to send a sys/ex message bigger than SysExBuffer

    ; a handy macro for SetMidiErrFilter()
CMEF_All    equ CMEF_MsgErr!CMEF_BufferFull!CMEF_SysExFull!CMEF_SysExTooBig!CMEF_ParseMem!CMEF_RecvErr!CMEF_RecvOverflow


****************************************************************
*
*   CreateMidi() Error Codes
*
*   These are the IoErr() codes that CreateMidi() can return
*   on failure.
*
****************************************************************

CME_NoMem       equ 801         ; memory allocation failed
CME_NoSignals   equ 802         ; signal allocation failed
CME_NoTimer     equ 803         ; timer (CIA) allocation failed
CME_BadPrefs    equ 804         ; badly formed midi.prefs file

CME_NoUnit      equ 820         ; unit open failure (really CME_NoUnit + unit num)


****************************************************************
*
*   Hook Message ID's
*
*   Each Hook passes as the "msg" param a pointer to one of these (LONG)
*   Can be extended for some types of messages
*
****************************************************************

    ENUM
    EITEM   CMSG_Recv           ; receive MIDI message
    EITEM   CMSG_Link           ; a linkage notification
    EITEM   CMSG_StateChange    ; change timer state
    EITEM   CMSG_Alarm          ; timer alarm


***************************************************************
*
*   ClusterNotifyNode
*
***************************************************************

    STRUCTURE ClusterNotifyNode,MLN_SIZE
        APTR	cnn_Task
	BYTE	cnn_SigBit
        STRUCT	cnn_pad,3
	LABEL	ClusterNotifyNode_Size

****************************************************************
*
*   CAMD Macros
*
*   All macros assume A6 = CamdBase.  See camd.doc for more
*   info.
*
****************************************************************

* ---- MidiNode

PackSysExFilterN macro  ; Dn, id1, id2, id3
        iflt    narg-1
        fail    PackSysExFilterN -- not enough args
        endc

        ifgt    narg-4
        fail    PackSysExFilterN -- too many args
        endc

sxf\@_val set   (SXFM_1Byte!(narg-1))<<24
        ifge    narg-2
sxf\@_val set   sxf\@_val!(\2)<<16
        endc
        ifge    narg-3
sxf\@_val set   sxf\@_val!(\3)<<8
        endc
        ifge    narg-4
sxf\@_val set   sxf\@_val!(\4)
        endc
        move.l  #sxf\@_val,\1
        endm

PackSysExFilterX macro  ; Dn, xid
        move.l  #(SXFM_3Byte<<24!\2),\1
        endm

ClearSysExFilter macro
        PackSysExFilterN d0
        JSRLIB  SetSysExFilter
        endm

SetSysExFilterN macro
        ifle    narg-1
        PackSysExFilterN d0,\1
        endc
        ifeq    narg-2
        PackSysExFilterN d0,\1,\2
        endc
        ifge    narg-3
        PackSysExFilterN d0,\1,\2,\3
        endc
        JSRLIB  SetSysExFilter
        endm

SetSysExFilterX macro
        PackSysExFilterX d0,\1
        JSRLIB  SetSysExFilter
        endm

ClearSysExBuffer macro
        CLEARA  a1
        CLEAR   d0
        JSRLIB  SetSysExBuffer
        endm


* ---- Message

; commented out by --DJ
;PutMidi macro
;       move.l  mm_Msg(a1),d0
;       move.b  mi_SendPort(a0),d0
;       JSRLIB  PutMidiToPort
;       endm
;
;PutSysEx macro
;       move.b  mi_SendPort(a0),d0
;       move.l  a1,a0
;       JSRLIB  PutSysExToPort
;       endm


* ---- Unit

GetMidiInPort macro
        moveq   #-1,d1
        JSRLIB  SetMidiInPort
        endm

GetMidiOutMask macro
        move.l  d2,-(sp)
        moveq   #0,d1
        moveq   #0,d2
        JSRLIB  SetMidiOutMask
        move.l  (sp)+,d2
        endm


* ---- Timer

ClearMidiAlarm macro
        moveq   #0,d0
        JSRLIB  SetMidiAlarm
        endm

    endc
