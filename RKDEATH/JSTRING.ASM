***
*** FILE: JSTRING.ASM
*** STRING GENERATION AND MANIPULATION FUNCTIONS
***
*** JMS 09 MAR 93; STARTED
***
	.MLIB	"APMACS.LIB"
	.FILE	"JSTRING.ASM"
	.TITLE	"<<< STRING FUNCTIONS >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**
** COMPILE FLAGS
**

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"AP.H"
	.INCLUDE	"IMGTBLB1.GLO"
	.INCLUDE	"DISPEQU.ASM"
	.INCLUDE	"DRB.I"
	.INCLUDE	"DRINP.I"

** OTHERS USE
	.DEF	CREATE_STRING	;JSTRING.ASM
	.DEF	DISPLAY_STRING	;JSTRING.ASM
	.DEF	HORZ_ALIGN_STRING	;JSTRING.ASM
	.DEF	VERT_ALIGN_STRING	;JSTRING.ASM

** WE USE
	.REF	INSANI		;APD.ASM
	.REF	INSOBJ		;APD.ASM
	.REF	INSERT_OBJ	;APD.ASM
	.REF	ZAP_OBJ		;APD.ASM
	.REF	STARTNEWATTRACT	;DRATT.ASM
	.REF	GAMEOVER		;DRATT.ASM
	.REF	GETINPDATA		;DRINP.ASM
	.REF	SET_IMAGE		;DREQUIP.ASM

** WE USE -- RAM

	.TEXT
	.EVEN

	.BSS	J_OBJINIT,COSIZE

**
** DEFINES
**

J_CHARINITOBJ
	.LONG	FONT_A		;IMAGE
	.LONG	0		;COLLISION VECTOR
 	.WORD	OID_JUNK+M_OIDFAUTOVEL  	;OID
	.WORD	DMAWNZ		;OCTRL
	.WORD	0		;OFLAGS
	.WORD	STYPNONE	;OSCALTYP
 	.LONG	0		;CFUNC

J_EOP	EQU	0h	;END-OF-PARAGRAPH FLAG

ASCII_A	EQU	41h
ASCII_SPACE EQU	20h

J_CHARACTER_SPACING	EQU	2h	;2 PIXELS BETWEEN CHARACTERS

MOVERATE	EQU	6

;BIT FIELDS FOR SCREEN BOUNDARY CHECKING
B_TOP	EQU	0
B_BOTTOM EQU	1
B_LEFT	EQU	2
B_RIGHT	EQU	3

BC_TOP	EQU	0001h
BC_BOTTOM EQU	0002h
BC_LEFT	EQU	0004h
BC_RIGHT EQU	0008h

BC_VERT	EQU	BC_TOP | BC_BOTTOM
BC_HORZ	EQU	BC_LEFT | BC_RIGHT

J_FONT
	.LONG	FONT_A
	.LONG	FONT_B
	.LONG	FONT_C
	.LONG	FONT_D
	.LONG	FONT_E
	.LONG	FONT_F
	.LONG	FONT_G
	.LONG	FONT_H
	.LONG	FONT_I
	.LONG	FONT_J
	.LONG	FONT_K
	.LONG	FONT_L
	.LONG	FONT_M
	.LONG	FONT_N
	.LONG	FONT_O
	.LONG	FONT_P
	.LONG	FONT_Q
	.LONG	FONT_R
	.LONG	FONT_S
	.LONG	FONT_T
	.LONG	FONT_U
	.LONG	FONT_V
	.LONG	FONT_W
	.LONG	FONT_X
	.LONG	FONT_Y
	.LONG	FONT_Z

* DEFINITIONS FOR THE OBJECT STRUCT

OSTRLINK EQU	OCVECT	;REPLACE COLLITION VECTOR WITH POINTER TO NEXT
			;STRING IN PARAGRAPH

OFXVAL	EQU	OVAR1	;DESTINATION POSITIONS USED FOR TEXT EXPLOSION
OFZVAL	EQU	OVAR2

**
** CREATE_STRING
**
**  IN
**    A2 NULL-TERMINATED STRING (ALL CAPS AND SPACES)
**
**  OUT
**    A3 LEAD OBJECT IN SUPPLEMENTAL LIST
**
**  PURPOSE
**    CREATES A SUPPLEMENTAL OBJECT STRING MATCHING THE INPUT
**    ASCII STRING AND RETURNS A HANDLE TO THE HEAD OF THE LIST
**
**  JMS 10 MAR 93
**  JMS 11 MAR 93 ;ADDED DEFAULT Z-VALUES AND OFFSETS
**                ;ADDED SUPPORT FOR SPACES (ASCII 32)
**  JMS 19 MAR 93 
**

CREATE_STRING

	;REG USE:
	;  A4  HOLDS INDIVIDUAL CHARACTERS IN STRING
	;  A5  POINTS TO OBJECT INITIALIZATION RAM
	;  A6  POINTS TO PREVIOUSLY CREATED OBJECT
	;  A7  SPACE (ASCII 32) FLAG
	
	MMTM	SP,A2,A4,A5,A6,A7

	;INITIALIZATIONS
	CLR	A6	;SIGNIFIES FIRST OBJECT IN CHAIN

JCS_LOOP
	MOVB	*A2,A4
	JRZ	JCS_DONE
	ADDK	8,A2

	;CHECK FOR A SPACE CHARACTER
	CLR	A7	;CLEAR SPACE FLAG
	CMPI	ASCII_SPACE,A4
	JRNZ	JCS_NOT_SPACE

	;IT'S A SPACE.  SET THE SPACE FLAG
	INC	A7

	;SET THE EFFECTIVE VALUE SO IT COMES THROUGH AS AN 'A'
	MOVI	ASCII_A,A4

JCS_NOT_SPACE
	;CONVERT A4 TO FONT INDEX, THEN TO AN OFFSET
	SUBI	ASCII_A,A4
	SLL	5,A4	;MULTIPLY BY 32

	;LOAD THE CHARACTER ICON INTO THE OBJECT STRUCT
	MOVI	J_CHARINITOBJ,A5

	;INITIALIZE THE OBJECT
	CALLA	CREATE_OBJ ;IN: A5 COBLOCK OUT: A0 OBJ
	JRZ	JCS_BAD_OBJECT
	
	ADDI	J_FONT,A4
	MOVL	*A4(0),A1
	CALLA	SET_IMAGE ;IN:A0,A1 hOBJECT,hIMAGE

	;SET THE OUTPUT REGISTER ONLY IF THIS IS THE FIRST OBJECT
	MOVE	A6,A6	;FEWER CYCLES THAN A COMPARE
	JRNZ	JCS_PREV_OBJECT_EXISTS
	MOVE	A0,A3
	JRUC	JCS_NO_PREV_OBJECT

JCS_PREV_OBJECT_EXISTS
	;LINK PREVIOUS OBJECT TO THE CURRENT ONE
	MOVL	A0,*A6(OSLINK)

JCS_NO_PREV_OBJECT
	;CLEAR THE OSLINK FOR THIS NEW OBJECT
	CLR	A14
	MOVL	A14,*A0(OSLINK)

	;IF IT'S A SPACE, CLEAR THE DMA_GO BIT ON THE CONTROL WORD
	MOVE	A7,A7
	JRZ	JCS_NOT_SPACE2
	SETF	1,0,0
	MOVE	SP,*A0(OCTRL+B_INUSE),0
	SETF	16,1,0

JCS_NOT_SPACE2
	;UPDATE THE POINTER TO THE PREVIOUS OBJECT
	MOVE	A0,A6

	;AND THEN HOP BACK TO THE TOP FOR THE NEXT ITERATION
	JRUC	JCS_LOOP
		
JCS_BAD_OBJECT
	;OH, SET THE ZERO FLAG OR SOMETHING.  LATER.
	TLOCKUP

JCS_DONE
	MMFM	SP,A2,A4,A5,A6,A7
	RETS


**
** DISPLAY_STRING
**
**  IN
**    A0 HEAD OF SUPPLEMEMTAL LIST CONTAINING FONT CHARACTERS
**
**  OUT
**    NONE
**
**  PURPOSE
**    INSERTS THE OBJECTS IN A SUPPLEMENTAL STRING INTO THE OBJECT LIST
**
**  JMS 10 MAR 93
**  JMS 11 MAR 93; REMOVED X-Y INPUTS
**

DISPLAY_STRING

	MMTM	SP,A2

	;REG USE
	;  A2  CURRENT OBJECT POINTER

	MOVE	A0,A2

DS_LOOP
	CALLA	INSOBJ	;IN: A0 CURRENT OBJECT
	MOVL	*A0(OSLINK),A0
	JRNZ	DS_LOOP

	;RESTORE A0
	MOVE	A2,A0

	MMFM	SP,A2
	RETS

**
** VERT_ALIGN_STRING
**
**  IN
**    A0 HEAD OF SUPPLEMENTAL LIST CONTAINING FONT CHARACTERS
**
**  OUT
**    NONE
**
**  PURPOSE
**    SETS THE Y-POSITION OF ALL CHARACTERS TO THAT OF THE LEAD CHARACTER,
**    AND AUTOMATICALLY ADDS SCRBOT TO THE Z POSITION AND SETS THE Z OFFSET
**    TO -SCRBOT.
**
**  JMS 11 MAR 93
**

VERT_ALIGN_STRING

	;REG USE
	;  A1  CURRENT OBJECT POINTER
	;  A2  Y-VALUE OF LEAD CHARACTER
	;  A3  -SCRBOT

	MMTM	SP,A1,A2,A3

	;SET THE VALUE REGISTER
	MOVL	*A0(OZVAL),A2

	;SET THE OFFSET FOR THE LEAD CHARACTER
	MOVI	-SCRBOT,A3
	MOVW	A3,*A0(OZOFF)

	;SET THE TEMPORARY LIST INDEX
	MOVL	*A0(OSLINK),A1
	JRZ	VAS_DONE

VAS_LOOP
	MOVL	A2,*A1(OZVAL)
	MOVW	A3,*A1(OZOFF)
	MOVL	*A1(OSLINK),A1
	JRNZ	VAS_LOOP

VAS_DONE
	MMFM	SP,A1,A2,A3
	RETS
	

**
** HORZ_ALIGN_STRING
**
**  IN
**    A0 HEAD OF SUPPLEMEMTAL LIST CONTAINING FONT CHARACTERS
**
**  OUT
**    NONE
**
**  PURPOSE
**    ADJUSTS THE SPACING OF THE CHARACTERS APPROPRIATE TO THE CURRENT
**    DISPLAY SIZE.  POSITION OF LEFTMOST CHARACTER IS UNCHANGED
**
**  JMS 10 MAR 93
**  JMS 12 MAR 93 ;ADDED OFFSETS
**

HORZ_ALIGN_STRING

	;REG USE:
	;  A2  CURRENT X INDEX
	;  A3  SIZE OF CURRENT CHARACTER
	;  A4  CURRENT OBJECT
	;  A5  TEMP ZVAL
	;  A6  TEMP OFFSET

	MMTM	SP,A2,A3,A4,A5,A6

	;INITIALIZE THE LOOP POINTER
	MOVE	A0,A4

	;SET STARTING X INDEX
	MOVL	*A4(OXVAL),A2
	MOVL	*A4(OZVAL),A5
	MOVW	*A4(OZOFF),A6

	;SKIP THE REALIGN ON THE FIRST CHARACTER
	JRUC	HAS_FIRST_TIME

HAS_LOOP
	;ALIGN CURRENT CHARACTER
	MOVL	A2,*A4(OXVAL)
	MOVL	A5,*A4(OZVAL)
	MOVW	A6,*A4(OZOFF)

HAS_FIRST_TIME
	;UPDATE THE X INDEX
	MOVW	*A4(OSIZEX),A3
	SLL	16,A3
	ADD	A3,A2
	ADDI	[J_CHARACTER_SPACING,0],A2


	;STEP TO NEXT CHARACTER
	MOVL	*A4(OSLINK),A4
	JRNZ	HAS_LOOP

	;ALL DONE
	MMFM	SP,A2,A3,A4,A5,A6
	RETS

**
** MODIFY_STRING_LONG
**
**  IN
**    A0  HEAD OF SUPPLEMEMTAL LIST CONTAINING FONT CHARACTERS
**    A1  OFFSET OF THE FIELD LONG TO BE MODIFIED
**    A2  AMOUNT TO ADD TO FIELD A2 IN EACH ELEMENT OF THE LIST
**
**  OUT
**    NONE
**
**  JMS 10 MAR 93
**  JMS 11 MAR 93; COMPLETE REWRITE,NAME CHANGE FROM MODIFY_STRING_POSVEL
**

MODIFY_STRING_LONG

	;REG USE
	;  A3  OBJECT POINTER
	;  A4  POINTER TO THE FIELD TO BE MODIFIED	

	MMTM	SP,A3,A4

	;PRESERVE THE A0 VALUE
	MOVE	A0,A3
	JRZ	MSL_END

MSL_LOOP
	;PREPARE THE FIELD POINTER
	MOVE	A3,A4
	ADD	A1,A4

	;MODIFY THE VALUE
	MOVL	*A4,A14
	ADD	A2,A14
	MOVL	A14,*A4

	;MOVE ON
	MOVL	*A3(OSLINK),A3
	JRNZ	MSL_LOOP

MSL_END
	MMFM	SP,A3,A4
	RETS

**
** MODIFY_STRING_WORD
**
**  IN
**    A0  HEAD OF SUPPLEMEMTAL LIST CONTAINING FONT CHARACTERS
**    A1  OFFSET OF THE FIELD WORD TO BE MODIFIED
**    A2  AMOUNT TO ADD TO FIELD A2 IN EACH ELEMENT OF THE LIST
**
**  OUT
**    NONE
**
**  JMS 11 MAR 93; COPIED FROM MODIFY_STRING_LONG
**

MODIFY_STRING_WORD

	;REG USE
	;  A3  OBJECT POINTER
	;  A4  POINTER TO THE FIELD TO BE MODIFIED	

	MMTM	SP,A3,A4

	;PRESERVE THE A0 VALUE
	MOVE	A0,A3
	JRZ	MSW_END

MSW_LOOP
	;PREPARE THE FIELD POINTER
	MOVE	A3,A4
	ADD	A1,A4

	;MODIFY THE VALUE
	MOVW	*A4,A14
	ADD	A2,A14
	MOVW	A14,*A4

	;MOVE ON
	MOVL	*A3(OSLINK),A3
	JRNZ	MSW_LOOP

MSW_END
	MMFM	SP,A3,A4
	RETS


**
** PLACE_STRING
**
**  IN
**    A0  HEAD OF SUPPLEMENTAL OBJECT CHARACTER STRING
**    A1  [Z,X] POSITION FOR LEAD CHARACTER
**
**  OUT
**    NONE
**
**  PURPOSE
**    POSITIONS THE LEAD CHARACTER OF A STRING AT THE POSITION GIVEN
**    IN A1, THEN VERTICALLY AND HORIZONTALLY ALIGNS THE STRING.
**    AUTOMATICALLY ADJUSTS THE Z-COORDINATE FOR THE OFFSET.
**
**  JMS 11 MAR 93
**

PLACE_STRING

	;SET POSITION OF THE FIRST CHARACTER
	MOVE	A1,A14
	SLL	16,A14
	MOVL	A14,*A0(OXVAL)

	RL	16,A1
	MOVE	A1,A14
	ADDI	SCRBOT,A14
	SLL	16,A14
	MOVL	A14,*A0(OZVAL)
	RL	16,A1
		
	;ALIGN THE REST OF THE STRING
	CALLR	HORZ_ALIGN_STRING ;IN: A0 HEAD OF STRING
	CALLR	VERT_ALIGN_STRING ;IN: A0 HEAD OF STRING

	;AND THAT'S IT
	RETS

**
**  EDGE_CHECK_CHAR
**
**  IN
**    A0  ADDRESS OF A CHARACTER GRAPHIC
**
**  OUT
**    A1  BIT 0  TOP OF SCREEN
**            1  BOTTOM
**            2  LEFT EDGE
**            3  RIGHT EDGE
**
**  PURPOSE
**    CHECKS FOR A COLLISION BETWEEN A CHARACTER GRAPHIC AND AN EDGE OF
**    THE SCREEN
**
**  JMS 11 MAR 93
**

EDGE_CHECK_CHAR

	;REG USE
	;  A2  CHARACTER TOP
	;  A3  CHARACTER BOTTOM
	;  A4  CHARACTER LEFT
	;  A5  CHARACTER RIGHT
	;  A6  SCREEN BOTTOM
	;  A7  SCREEN RIGHT

	MMTM	SP,A2,A3,A4,A5,A6,A7

	;CLEAR THE OUTPUT REGISTER
	CLR	A1

	;LOAD CHARACTER POSITION
	MOVW	*A0(OZPOS),A2
	MOVW	*A0(OXPOS),A4

	;ADJUST FOR Z-OFFSET
	MOVI	SCRBOT,A14
	SUB	A14,A2

	;COMPUTE RIGHT AND BOTTOM EDGES
	MOVE	A2,A3
	MOVE	A4,A5

	MOVW	*A0(OSIZEY),A14
	ADD	A14,A3
	MOVW	*A0(OSIZEX),A14
	ADD	A14,A5

	;LOAD SCREEN DIMENSIONS
	MOVI	SCRBOT,A6
	MOVI	SCRRGT,A7

	;PERFORM THE COMPARISONS
ECC_CHECK_TOP
	CMPI 	0h,A2
	JRGT	ECC_CHECK_BOTTOM
	ORI	BC_TOP,A1

ECC_CHECK_BOTTOM
	CMP	A6,A3
	JRLT	ECC_CHECK_LEFT
	ORI	BC_BOTTOM,A1

ECC_CHECK_LEFT
	CMPI	0h,A4
	JRGT	ECC_CHECK_RIGHT
	ORI	BC_LEFT,A1

ECC_CHECK_RIGHT
	CMP	A7,A5
	JRLT	ECC_DONE
	ORI	BC_RIGHT,A1

ECC_DONE
	;ALL DONE
	MMFM	SP,A2,A3,A4,A5,A6,A7
	RETS

**
**  EDGE_CHECK_STRING
**
**  IN
**    A0  ADDRESS OF A CHARACTER GRAPHIC
**
**  OUT
**    A1  BIT 0  TOP OF SCREEN
**            1  BOTTOM
**            2  LEFT EDGE
**            3  RIGHT EDGE
**
**  PURPOSE
**    CHECKS FOR A COLLISION BETWEEN A CHARACTER STRING AND AN EDGE OF
**    THE SCREEN
**
**  JMS 11 MAR 93
**

EDGE_CHECK_STRING

	;REG USE
	;  A0  INPUT VALUE.  BACKED UP AND RESTORED
	;  A1  OUTPUT VALUE
	;  A2  LEAD CHARACTER RESULT
	;  A4  LOOP POINTER

	MMTM	SP,A0,A2,A4

	;CHECK THE HEAD CHARACTER
	CALLA	EDGE_CHECK_CHAR	;IN: A0 CHARACTER POINTER

	;GO HOME IF THERE IS ONLY ONE CHARACTER IN THE STRING
	MOVL	*A0(OSLINK),A4
	JRZ	ECS_DONE

	;SAVE THAT VALUE
	MOVE	A1,A2

	;FIND THE END CHARACTER
ECS_LOOP
	MOVE	A4,A0
	MOVL	*A0(OSLINK),A4
	JRNZ	ECS_LOOP

	;CHECK THE END CHARACTER
	CALLA	EDGE_CHECK_CHAR	;IN: A0 CHARACTER POINTER

	;OR THE RESULTS OF THE TWO CHECKS
	OR	A2,A1

ECS_DONE
	;ALL DONE
	MMFM	SP,A0,A2,A4
	RETS

**
** OFFSRCN_CHECK_CHAR
**
**  IN
**   A0 HANDLE OF CHARACTER
**
**  OUT
**    A1  BIT 0  TOP OF SCREEN
**            1  BOTTOM
**            2  LEFT EDGE
**            3  RIGHT EDGE
**
**  PURPOSE
**    CHECKS FOR A CHARACTER COMPLETELY LEAVING THE SCREEN
**   
**  JMS 11 MAR 93
**
OFFSCRN_CHECK_CHAR

	;REG USE
	;  A2  CHARACTER TOP
	;  A3  CHARACTER BOTTOM
	;  A4  CHARACTER LEFT
	;  A5  CHARACTER RIGHT
	;  A6  SCREEN BOTTOM
	;  A7  SCREEN RIGHT

	MMTM	SP,A2,A3,A4,A5,A6,A7

	;CLEAR THE OUTPUT REGISTER
	CLR	A1

	;LOAD CHARACTER POSITION
	MOVW	*A0(OZPOS),A2
	MOVW	*A0(OXPOS),A4

	;ADJUST FOR Z-OFFSET
	MOVI	SCRBOT,A14
	SUB	A14,A2

	;COMPUTE RIGHT AND BOTTOM EDGES
	MOVE	A2,A3
	MOVE	A4,A5

	MOVW	*A0(OSIZEY),A14
	ADD	A14,A3
	MOVW	*A0(OSIZEX),A14
	ADD	A14,A5

	;LOAD SCREEN DIMENSIONS
	MOVI	SCRBOT,A6
	MOVI	SCRRGT,A7

	;PERFORM THE COMPARISONS
OCC_CHECK_TOP
	CMPI 	0h,A3
	JRGE	OCC_CHECK_BOTTOM
	ORI	BC_TOP,A1

OCC_CHECK_BOTTOM
	CMP	A6,A2
	JRLE	OCC_CHECK_LEFT
	ORI	BC_BOTTOM,A1

OCC_CHECK_LEFT
	CMPI	0h,A5
	JRGE	OCC_CHECK_RIGHT
	ORI	BC_LEFT,A1

OCC_CHECK_RIGHT
	CMP	A7,A4
	JRLE	OCC_DONE
	ORI	BC_RIGHT,A1

OCC_DONE
 	;ALL DONE
	MMFM	SP,A2,A3,A4,A5,A6,A7
	RETS

**
** EXPLODE_PARAGRAPH
**
**  IN
**    A0  PARAGRAPH HANDLE
**
**  OUT
**    NONE
**
**  PURPOSE
**    EXPLODES TEXT ONTO THE SCREEN.  THE PASSED PARAGRAPH SHOULD BE
**    ALREADY PLACED IN THE FINAL POSITION BUT NOT YET INSERTED INTO
**    THE ACTIVE LIST.
**
**  JMS 12 MAR 93
**

EXPLODE_PARAGRAPH

	;REG USE
	;  A0  HEAD OF CURRENT STRING
	;  A4  STRING LOOP COUNTER
	;  A5  CHARACTER LOOP COUNTER
	;  A6  PREVIOUS STRING INDEX
	;  A8  PARAGRAPH HANDLE
	; A10  EXPLODE DONE FLAG

	MMTM	SP,A0,A4,A5,A6,A8,A10

	;SET THE A8 REGISTER NOW.  REMEMBER NOT TO TOUCH IT FROM HERE ON
	MOVE	A0,A8

	;STORE THEIR FINAL POSITIONS
	MOVE	A0,A4

EP_STORSTRLOOP
	MOVE	A4,A5

EP_STORCHARLOOP
	;STORE THE FINAL POSITIONS
	MOVL	*A5(OXVAL),*A5(OFXVAL)
	MOVL	*A5(OZVAL),*A5(OFZVAL)

	MOVL	*A5(OSLINK),A5
	JRNZ	EP_STORCHARLOOP

	MOVL	*A4(OSTRLINK),A4
	JRNZ	EP_STORSTRLOOP


	;MOVE THE CHARACTERS TO THE CENTER POINT
	MOVE	A0,A4
	MOVI	SCRBOT*3/2,A1
	SLL	16,A1
	MOVI	SCRRGT/2,A2
	SLL	16,A2

EP_MCENSTRLOOP
	MOVE	A4,A5

EP_MCENCHARLOOP
	MOVL	A1,*A5(OZVAL)
	MOVL	A2,*A5(OXVAL)

	MOVL	*A5(OSLINK),A5
	JRNZ	EP_MCENCHARLOOP

	MOVL	*A4(OSTRLINK),A4
	JRNZ	EP_MCENSTRLOOP


	;SET THE VELOCITIES
	MOVE	A0,A4

EP_SETVELSTRLOOP
	MOVE	A4,A5

EP_SETVELCHRLOOP
	;SET THE VELOCITY NEEDED TO GET THE CHARACTER TO IT'S FINAL
	;DESTINATION IN _MOVETIME_ CYCLES
	MOVL	*A5(OFZVAL),A1
	MOVL	*A5(OZVAL),A14
	SUB	A14,A1
	SRA	MOVERATE,A1
	MOVL	A1,*A5(OZVEL)

	MOVL	*A5(OFXVAL),A1
	MOVL	*A5(OXVAL),A14
	SUB	A14,A1
	SRA	MOVERATE,A1
	MOVL	A1,*A5(OXVEL)

	MOVL	*A5(OSLINK),A5
	JRNZ	EP_SETVELCHRLOOP

	MOVL	*A4(OSTRLINK),A4
	JRNZ	EP_SETVELSTRLOOP


	;ACTIVATE THE STRINGS
	MOVE	A0,A4

EP_STRACTIVATELOOP
	MOVE	A4,A0
	CALLA	DISPLAY_STRING ;IN: A0 hSTRING
	MOVL	*A4(OSTRLINK),A4
	JRNZ	EP_STRACTIVATELOOP

	;SPAWN THE PROCESS THAT'LL KEEP AN EYE ON THESE GUYS
;	CREATE	PID_TEXT,EXP_PGRAPH_PROC

	MMFM	SP,A0,A4,A5,A6,A8,A10

	RETS


**
** EXP_PGRAPH_PROC - PROCESS
**
**  IN
**    A8  HANDLE TO PROCESSED PARAGRAPH
**
**  OUT
**    NONE
**
**  PURPOSE
**    WATCHDOG.  THIS PROCESS KEEPS AN EYE ON THE MOVING CHARACTERS
**    DURING AN EXPLODE AND HALTS THEIR MOTION AT THE PROPER TIME.
**
**  JMS 12 MAR 93
**

EXP_PGRAPH_PROC

EPPLOOP
	;IF THE LEAD CHARACTER IS IN IT'S FINAL POSITION, HALT THEM ALL
	;COMPARE THE SIGN OF THE VELOCITY TO THE SIGN OF THE 
	;DIFFERENCE BETWEEN THE FINAL AND CURRENT POSITIONS OF THE
	;CHARACTER.  IF THE SIGNS ARE DIFFERENT, WE'RE THERE.
	MOVL	*A8(OXVAL),A1
	MOVL	*A8(OFXVAL),A14
	SUB	A14,A1
	MOVL	*A8(OXVEL),A2
	XOR	A1,A2
	SLL	1,A2
	JRNC	EPP_INPOSITION
	JRUC	EPP_STILLGOING

EPP_INPOSITION
	;SET ALL CHARACTER VELOCITIES TO ZERO AND ALL POSITIONS TO
	;STORED FINALS
	MOVE	A8,A4

EPP_DONESTRLOOP
	MOVE	A4,A5

EPP_DONECHARLOOP
	MOVL	*A5(OFZVAL),A1
	MOVL	*A5(OFXVAL),A2

	MOVL	A1,*A5(OZVAL)
	MOVL	A2,*A5(OXVAL)
	MOVI	0h,A14
	MOVL	A14,*A5(OZVEL)
	MOVL	A14,*A5(OXVEL)

	MOVL	*A5(OSLINK),A5
	JRNZ	EPP_DONECHARLOOP

	MOVL	*A4(OSTRLINK),A4
	JRNZ	EPP_DONESTRLOOP

	;AND SET THE DONE FLAG
	INC	A10

EPP_STILLGOING

	SLEEP	1

	JRUC	EPPLOOP

EPP_EXPLODE_DONE
	DIE

**
** DESTROY_STRING
**
**  IN
**    A0  HANDLE OF OBJECT CHAIN TO BE ZAPPED
**
**  OUT
**    NONE
**
**  PURPOSE
**    ZAPS EVERY CHARACTER IN A GRAPHIC STRING
**
**  JMS 12 MAR 93
**

DESTROY_STRING

	;REG USE
	;  A0 INPUT VALUE
	;  A1 CHARACTER IMMEDIATELY FOLLOWING A0

	MMTM	SP,A0,A1

DSTRING_LOOP
	MOVL	*A0(OSLINK),A1
	CALLA	ZAPOBJ ;IN: A0 OBJECT TO BE SCORCHED
	MOVE	A1,A0
	JRNZ	DSTRING_LOOP

	MMFM	SP,A0,A1
	RETS


**
** SCROLL_PARAGRAPH - PROCESS
**
**  IN
**    A8  POINTER TO THE FIRST ENTRY IN A TABLE OF lpSTRINGS
**    A9  SPACING BETWEEN LINES
**   A10  UPWARD VELOCITY OF EACH LINE
**
**  OUT
**    NONE
**
**  PURPOSE
**    SCROLLS THE PARAGRAPH VERTICALLY UP THE SCREEN, ALLOCATING AND
**    DEALLOCATING OBJECTS AS IT GOES.
**
**  JMS 12 MAR 93
**

SCROLL_PARAGRAPH

	;REG USE
	;  A4  SCRATCH
	;  A5  SCRATCH
	;  A6  POINTER TO TOP DISPLAYED LINE
	;  A7  POINTER TO BOTTOM DISPLAYED LINE
	;  A8  POINTER TO NEXT ASCII STRING TO BE DISPLAYED

	;START WITH NO STRINGS DISPLAYED
	CLR	A6
	CLR	A7

	;GO HOME IF THERE AREN'T ANY STRINGS AT ALL
	MOVL	*A8,A14
	CMPI	J_EOP,A14
	JRZ	SP_ALLDONE

	;THERE ARE STRINGS IN THE LIST.  DO THE FIRST ONE BY HAND
	;TO AVOID MESSY SPECIAL CASES IN THE ADD_LINE SECTION
	MOVL	*A8,A2
	ADDI	20h,A8
	CALLA	CREATE_STRING ;IN: A2 lpSTRING  OUT: A3 hSTRING

	MOVI	[SCRBOT+10h,20h],A1
	MOVE	A3,A0
	CALLA	PLACE_STRING ;IN: A0,A1 hSTRING,[z,x]

	MOVI	OZVEL,A1
	MOVE	A10,A2
	CALLA	MODIFY_STRING_LONG ;IN: A0,A1,A2 hSTRING,OFFSET,DELTA

	CALLA	DISPLAY_STRING ;IN: A0 hSTRING

	;SET THE LINKS TO THIS STRING
	MOVE	A0,A6
	MOVE	A0,A7

SP_PROCESSLOOP
	;CHECK FOR THE TOP LINE LEAVING THE SCREEN
	MOVE	A6,A0
	CALLA	OFFSCRN_CHECK_CHAR ;IN: A0 hSTRING  OUT: A1 FLAGS
	BTST	B_TOP,A1
	JRZ	SP_TOP_CHECKED

	;TOP STRING IS OFF THE TOP OF THE SCREEN
	JRUC	SP_REMOVE_LINE

SP_TOP_CHECKED
	;CHECK FOR THE BOTTOM LINE ENTERING THE SCREEN
	MOVE	A7,A0
	CALLA	EDGE_CHECK_STRING ;IN: A0 hSTRING  OUT: A1 FLAGS
	BTST	B_BOTTOM,A1
	JRNZ	SP_BTM_CHECKED

	;BOTTOM STRING IS PARTIALLY ON THE SCREEN
	MOVE	*A8,A14
	JRNZ	SP_ADD_LINE

SP_BTM_CHECKED
	;BEFORE WE GO NAPPIE-BYE, SAVE THE TEXT POINTERS
	MMTM	A12,A6,A7
	SLEEP	1
	MMFM	A12,A6,A7

	JRUC	SP_PROCESSLOOP

SP_ADD_LINE
	;ADD A NEW LINE TO THE BOTTOM OF THE LIST
	MOVL	*A8,A2
	ADDI	20h,A8
	CALLA	CREATE_STRING ;IN: A2 lpSTRING  OUT: A3 hSTRING

	;SET THE POSITION
	MOVW	*A7(OZOFF),*A3(OZOFF)
	MOVL	*A7(OXVAL),*A3(OXVAL)
	MOVW	*A7(OZPOS),A4
	MOVW	*A7(OSIZEY),A14
	ADD	A14,A4
	ADD	A9,A4
	MOVW	A4,*A3(OZPOS)
	MOVE	A3,A0
	CALLA	HORZ_ALIGN_STRING ;IN: A0 hSTRING

	;SET THE VELOCITIES
	MOVI	OZVEL,A1
	MOVE	A10,A2
	CALLA	MODIFY_STRING_LONG ;IN: A0,A1,A2 hSTRING,OFFSET,DELTA

	;TURN IT ON
	CALLA	DISPLAY_STRING ;IN: A0 hSTRING
			 	
	;LINK IT TO THE PREVIOUS STRING
	MOVL	A3,*A7(OSTRLINK)
	CLR	A14
	MOVL	A14,*A3(OSTRLINK)
	MOVE	A3,A7

	JRUC	SP_BTM_CHECKED

SP_REMOVE_LINE
	;KILL THE TOP LINE ON THE LIST
	;SET THE TOP POINTER TO THE SECOND STRING IN LINE
	MOVE	A6,A0
	MOVL	*A6(OSTRLINK),A6

	CALLA	DESTROY_STRING ;IN: A0 hSTRING

	;IF THAT WAS THE LAST LINE THEN JUMP TO THE END
	MOVE	A6,A6
	JRZ	SP_ALLDONE

	JRUC	SP_TOP_CHECKED

SP_ALLDONE
	;ALL DONE
	DIE


* EOF
