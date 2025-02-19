***
*** FILE: DRINP.ASM
*** JFL 12 JUL 92; STARTED
*** JFL 23 JUL 92; ALLOW WHEELS TO SPIN DIFFERENT DIRECTIONS
*** JFL 06 AUG 92; INP BITS
*** JFL 30 NOV 92; TUNIT STUFF
*** JFL 11 FEB 93; FIX TO INIT
*** JFL 16 FEB 93; THREW AWAY YUNIT VARIATION
*** JFL 11 MAR 93; SWITCH STACKING MOVED INTO HERE
***

	.MLIB	"APMACS.LIB"
	.FILE	"DRINP.ASM"
	.TITLE	" <<< DERBY RACE -- INPUT ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**
** COMPILE FLAGS
**
PEDALONOFF	EQU	1	;TREAT PEDAL AS ON/OFF SWITCH

***********************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
*************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"AP.H"
	.INCLUDE	"DR.I"
	.INCLUDE	"DRINP.I"

** DEFINE FOR OTHERS TO USE
	.DEF	INITINPUT		;DRINP.ASM
	.DEF	GETINPDATA		;DRINP.ASM
	.DEF	READSWITCHES		;DRINP.ASM
	.DEF	UNSTACKSWITCHES		;DRINP.ASM
	.DEF	READOTHERINP		;DRINP.ASM


** WE USE
	.REF	LCOIN
	.REF	CCOIN
	.REF	RCOIN
	.REF	XCOIN
	.REF	LCOIN
	.REF	SLAM
	.REF	DIAG

** WE USE -- RAM
	.REF	INDATA			;DRRAM.ASM
	.REF	INDATAX			;DRRAM.ASM
	.REF	WAVEIRQS

	.REF	SWITCHSTACK		;DRRAM.ASM
	.REF	SWITCHST		;DRRAM.ASM
	.REF	SWITCHSTX		;DRRAM.ASM
	.REF	SWITCHRAM		;DRRAM.ASM
	.REF	SWITCHRAMX		;DRRAM.ASM

	.TEXT
	.EVEN
***
*** TUNIT ------------------------------------------------------------------
***

**
** INITINPUT
**
** SCRATCH: A0-A11
**
** JFL 07 JUL 92
** JFL 13 JUL 92; DO NOTHING FOR NOW
** JFL 08 AUG 92
** JFL 11 FEB 93
** JFL 16 FEB 93
** JFL 11 MAR 93; NOT NECESSARY
**
INITINPUT
	RETS

**
** DESIGN IDEAS
**
** SWITCHES MUST BE CHECKED EVERY DISPLAY INTERRUPT
** ALL SWITCH CLOSURES MUST BE OFF OFF ON TO COUNT AS A CLOSE
** THE MAJORITY OF SWITCH CLOSURES CAN BE TREATED SIMPLY --
** THAT IS ALL THATS IMPORTANT IS TO KNOW THE SWITCH WAS PRESSED
** SOME SWITCHES (I.E. COIN SWITCHES) NEED TO SPAWN AN INDESTRUCTABLE PROCESS
** TO HANDLE THEM
**
** JFL 11 MAR 93
**

**
** SET OFFSETS INTO INDATA
**
P1B1	EQU	INPB0+(0*INPSIZE)	;OFFSET INTO INDATA
P1B2	EQU	INPB1+(0*INPSIZE)	;OFFSET INTO INDATA
P1B3	EQU	INPB2+(0*INPSIZE)	;OFFSET INTO INDATA
P2B1	EQU	INPB0+(1*INPSIZE)	;OFFSET INTO INDATA
P2B2	EQU	INPB1+(1*INPSIZE)	;OFFSET INTO INDATA
P2B3	EQU	INPB2+(1*INPSIZE)	;OFFSET INTO INDATA
P3B1	EQU	INPB0+(2*INPSIZE)	;OFFSET INTO INDATA
P3B2	EQU	INPB1+(2*INPSIZE)	;OFFSET INTO INDATA
P3B3	EQU	INPB2+(2*INPSIZE)	;OFFSET INTO INDATA

**
** SWITCHTBL
**
** .LONG PORT ADR
** .LONG ACT TBL - SASIZE
**
** JFL 11 MAR 93
**
SWITCHTBL
	.LONG	SWITCH0
	.LONG	SWITCH0ACT-SASIZE
	.LONG	SWITCH2
	.LONG	SWITCH2ACT-SASIZE
	.LONG	0			;TERM

**
** SWITCH TBL STRUCT
**
** JFL 11 MAR 93
**
STPORT		EQU	000H	;UHL PORT ADR
STACT		EQU	020H	;UHL ACT TBL ADR - SIZE OF ONE ENTRY
STSIZE		EQU	040H	; SIZE OF ONE ENTRY

**
** SWITCH ACT
**
** IF ENTRY IS ZERO, SWITCH IS JUST PLAIN IGNORED, PERIOD
** IF ENTRY IS NEGATIVE, THAT WORD IS ADDED TO THE STACK
** IF ENTRY IS POSITIVE, ITS TREATED AS AN OFFSET INTO INDATA AND
** THE WORD AT THIS LOCATION IS INC'D
**
** JFL 11 MAR 93
**
SASIZE		EQU	10H 	; SIZE OF ONE ENTRY
SASIZEOF	EQU	4	; SIZEOF SHIFT FOR ONE ENTRY
M_SASTACK	EQU	8000H	;MASK TO SIGNAL TO STACK SWITCH
	
SWITCH0ACT
	;--- SWITCH0
	.WORD	0		;00
	.WORD	0		;01
	.WORD	0		;02
	.WORD	0		;03
	.WORD	P1B1		;04
	.WORD	P1B2		;05
	.WORD	P1B3		;06
	.WORD	0		;07
	.WORD	0		;08
	.WORD	0		;09
	.WORD	0		;10
	.WORD	0		;11
	.WORD	P2B1		;12
	.WORD	P2B2		;13
	.WORD	P2B3		;14
	.WORD	0		;15
	;--- SWITCH1 (AKA COINS)
	.WORD	0 ;SWID_LEFTCOIN ;00
	.WORD	0 ;SWID_RIGHTCOIN ;01
	.WORD	0		;02
	.WORD	0 ;SWID_SLAM	;03
	.WORD	0		;04
	.WORD	0		;05
	.WORD	0 ;SWID_SERVICE	;06
	.WORD	0 ;SWID_CENTERCOIN ;07
	.WORD	0 ;SWID_FOURTHCOIN ;08
	.WORD	0		;09
	.WORD	0		;10
	.WORD	0		;11
	.WORD	0		;12
	.WORD	0		;13
	.WORD	0		;14
	.WORD	0		;15
SWITCH2ACT
	;--- SWITCH2
	.WORD	0		;00
	.WORD	0		;01
	.WORD	0		;02
	.WORD	0		;03
	.WORD	P3B1		;04
	.WORD	P3B2		;05
	.WORD	P3B3		;06
	.WORD	0		;07
	.WORD	0		;08
	.WORD	0		;09
	.WORD	0		;10
	.WORD	0		;11
	.WORD	0		;12
	.WORD	0		;13
	.WORD	0		;14
	.WORD	0		;15
	;--- SWITCH3 (AKA COINS)
	.WORD	0		;00
	.WORD	0		;01
	.WORD	0		;02
	.WORD	0		;03
	.WORD	0		;04
	.WORD	0		;05
	.WORD	0		;06
	.WORD	0		;07
	.WORD	0		;08
	.WORD	0		;09
	.WORD	0		;10
	.WORD	0		;11
	.WORD	0		;12
	.WORD	0		;13
	.WORD	0		;14
	.WORD	0		;15

**
** SWID_XXX
** DEFINE SWITCH IDS
**
** JFL 11 MAR 93
**
SWID_LEFTCOIN	EQU	M_SASTACK+0
SWID_CENTERCOIN	EQU	M_SASTACK+1
SWID_RIGHTCOIN	EQU	M_SASTACK+2
SWID_FOURTHCOIN	EQU	M_SASTACK+3
SWID_SERVICE	EQU	M_SASTACK+4
SWID_SLAM	EQU	M_SASTACK+5
SWID_DIAG	EQU	M_SASTACK+6

**
** UNSTACKTBL
**
** ORDER DEFINED IN SWID_XXXX !!!
**
** JFL 11 MAR 93
**
UNSTACKTBL
	;LEFT COIN
	.LONG	LCOIN
	.WORD	LC_PID,0

	;CENTER COIN
	.LONG	CCOIN
	.WORD	CC_PID,0

	;RIGHT COIN
	.LONG	RCOIN
	.WORD	RC_PID,0

	;FOURTH COIN
	.LONG	XCOIN
	.WORD	XC_PID,0

	;SERVICE CREDIT
	.LONG	LCOIN
	.WORD	LC_PID,0

	;SLAM
	.LONG	SLAM
	.WORD	SLAM_PID,0

	;DIAG
	.LONG	DIAG
	.WORD	DIAG_PID,0
UNSTACKTBLX

**
** UNSTACKSWITCHES
** CHECK THAT STACK IS NON-EMPTY BEFORE CALLING THIS
**
** IN
**   A4 SWITCHSTACK (NON-EMPTY STACK)
**
** SCRATCH: A0-A7
**
** JFL 11 MAR 93; BASED ON T2'S
**
UNSTACKSWITCHES
 	TLOCKUP ;NOT TESTED YET	
USLOOP
	;GET ENTRY
	MOVW	-*A4,A5	
	TLOCKON	NN ;ALL ENTRIES SHOULD BE NEG
	SLL	16+1,A5			;DROP NEG BIT
	SRL	16+1-6,A5		;SIZEOF UNSTACKTBL ENTRY
	ADDI	UNSTACKTBL,A5
	.IF DEBUG
	CMPI	UNSTACKTBLX,A5
	TLOCKON	HS
	.ENDIF ;DEBUG
	
	;CREATE THE PROCESS
	MOVL	*A5+,A7	
	MOVW	*A5,A1
	CALLA	GETPRC ;IN:A1,A7 PID,PROC

USNEXT
	;CHECK IF WE ARE POINTING TO THE FIRST SLOT
	CMPI	SWITCHST,A4
	JRHI	USLOOP
	
USX
	MOVI	SWITCHST,A14
	MOVL	A14,@SWITCHSTACK

	RETS

**
** READSWITCHES -- EXGPC B8
** CALLED DURING DIRQ
**
** IN
**   B8 PC
**
** SCRATCH:A0-A14
**
** JFL 11 MAR 93; MODIFIED EXISTING SWSCAN FROM T2
** JFL 12 MAR 93; THE PENACHO OFF ADDED TO UP TRANSITIONS
**
	.ALIGN	;CACHE BOUNDRY
READSWITCHES
	
	MOVK	1,A13
	MOVI	SWITCHTBL-STSIZE,A8
	MOVI	SWITCHRAM+SROLDA1,A9
	MOVI	INDATA,A10

RSLOOP
	;MOVE ONTO NEXT SET OF SWITCHES
	ADDI	STSIZE,A8

	;READ A SWITCH PORT
	MOVL	*A8,A0			;GET ADR OF TWO PORTS
	JRZ	RSX
	MOVL	*A0,A0	  		;READ CUR FROM BOTH PORTS
	MOVL	*A9,A1			;GET PREV OLD
	MOVL	*A9(20H),A2		;GET PREV OLDER	
	MOVL	A0,*A9+			;SET OLD
	MOVL	A1,*A9+			;SET OLDER
	.IF DEBUG
	CMPI	SWITCHRAMX,A9
	TLOCKON	HI
	.ENDIF ;DEBUG

	;
	;CHECK FOR DOWN TRANSITIONS
	;

	;ANY BTN THAT WAS OFF OFF ON WILL HAVE ITS BIT SET
	MOVE	A2,A3			;WORKING BITS
	AND	A1,A3			;LOOK FOR OFF OFF -- SINCE OFF==1
	ANDN	A0,A3			;LOOK FOR ON (OFF OFF)
	JRNZ	RSDOWN

RSDOWNRET
	;
	;CHECK FOR UP TRANSITIONS
	;

	;LOOK FOR ON OFF OFF
	ANDN	A2,A0
	AND	A1,A0
	JRZ	RSLOOP

	;REG USE
	;  A0 CUR, WORKING BITS
	;  A1 OLD
	;  A2 OLDER
	;  A3
	;  A4
	;  A5 COUNT
	;  A6 ACT
	;  A7 SCRATCH
	;  A8 SWITCH TBL
	;  A9 SWITCH RAM
	; A10 INDATA
	; A11
	; A12
	; A13 THE VALUE 1
	; A14 SCRATCH

	;AT LEAST ONE SWITCH WAS OFF OFF ON -- I.E. DOWN
	CLR	A5			;COUNT
	MOVL	*A8(STACT),A6		;GET ADR OF ACT TBL FOR THIS PORT
RSUPLOOP
	INC	A5			;NOTE FIRST ENTRY IS ONE NOT ZERO
	SRL	1,A0   			;TOSS BIT INTO CARRY
	JRNC	RSUPLOOP

	;THIS SWITCH WAS JUST OPENED LOOKUP IN ACT TBL
	MOVE	A5,A14	  
	SLL	SASIZEOF,A14		;SIZEOF ONE ENTRY IN ACT TBL
	ADD	A6,A14
	MOVW	*A14,A14		;GET ACT CODE
	JRZ	RSUPNEXT		;IGNORE THIS BTN
	JRNN	RSUPCOUNT		;HANDLE AS A COUNTER
	JRUC	RSUPNEXT

RSUPCOUNT
	;BUMP UP THE RELEASED COUNT
	;IF THIS HITS MORE THAN ONCE, IT HAS NO EFFECT
	ADD	A10,A14			;ADD INDATA
	MOVW	*A14,A7			;GET OLD COUNT
	INC	A7			;BUMP UP
	ANDN	A13,A7			;MAKE SURE BIT IS CLEAR
	MOVW	A7,*A14			;SET NEW COUNT
	
RSUPNEXT
	;CHECK IF THERE IS ANOTHER SWITCH UP
	MOVE	A0,A0			;WORKING BITS
	JRZ	RSLOOP			;NO MORE
	JRUC	RSUPLOOP		;FIND ANOTHER

RSDOWN
	;REG USE
	;  A0 CUR
	;  A1 OLD
	;  A2 OLDER
	;  A3 WORKING BITS
	;  A4
	;  A5 COUNT
	;  A6 ACT
	;  A7 SCRATCH
	;  A8 SWITCH TBL
	;  A9 SWITCH RAM
	; A10 INDATA
	; A11
	; A12
	; A13 THE VALUE 1
	; A14 SCRATCH

	;AT LEAST ONE SWITCH WAS OFF OFF ON -- I.E. DOWN
	CLR	A5			;COUNT
	MOVL	*A8(STACT),A6		;GET ADR OF ACT TBL FOR THIS PORT
RSDOWNLOOP
	INC	A5			;NOTE FIRST ENTRY IS ONE NOT ZERO
	SRL	1,A3   			;TOSS BIT INTO CARRY
	JRNC	RSDOWNLOOP

	;THIS SWITCH WAS JUST CLOSED LOOKUP IN ACT TBL
	MOVE	A5,A14	  
	SLL	SASIZEOF,A14		;SIZEOF ONE ENTRY IN ACT TBL
	ADD	A6,A14
	MOVW	*A14,A14		;GET ACT CODE
	JRZ	RSDOWNNEXT		;IGNORE THIS BTN
	JRNN	RSDOWNCOUNT		;HANDLE AS A COUNTER

	;STACK THE SWITCH CODE
	MOVL	@SWITCHSTACK,A7		;GET ADR TO STACK AT
	CMPI	SWITCHSTX,A7
	TLOCKON	HS ;SWITCH STACK FULL -- VERY BAD!!!
	JRHS	RSDOWNNEXT		
	MOVW	A14,*A7+
	MOVL	A7,@SWITCHSTACK
	JRUC	RSDOWNNEXT

RSDOWNCOUNT
	;BUMP UP THE PRESSED COUNT
	;IF DOWN WAS MISSED THIS WILL ADD 2, ELSE JUST 1
	ADD	A10,A14			;ADD INDATA
	MOVW	*A14,A7			;GET OLD COUNT
	INC	A7			;BUMP IT UP
	OR	A13,A7			;MAKE SURE BIT IS SET
	MOVW	A7,*A14			;SET NEW COUNT
	
RSDOWNNEXT
	;CHECK IF THERE IS ANOTHER SWITCH DOWN
	MOVE	A3,A3			;WORKING BITS
	JRZ	RSDOWNRET		;NO MORE
	JRUC	RSDOWNLOOP		;FIND ANOTHER

RSX
	EXGPC	B8
	
**
** GETINPDATA
**
** IN
**   A2 PLAYER NUM 0..2 -- SAVED
** OUT
**   A3 PTR TO INPDATA
**
** JFL 15 JAN 93
** JFL 16 FEB 93
**
GETINPDATA
	MOVI	INPSIZE,A3
	SETF	8,1,1
	MPYU	A2,A3
	SETF	32,1,1
	ADDI	INDATA,A3
	.IF DEBUG
	CMPI	INDATAX,A3
	TLOCKON	HS
	.ENDIF ;DEBUG
	RETS


A2DTBL
	.WORD	8+0	;PEDAL 0
	.WORD	0800H	;DIR BIT MASK
	.WORD	8+1	;WHEEL 0
	.WORD	8+2	;PEDAL 1
	.WORD	1000H	;DIR BIT MASK
	.WORD	8+3	;WHEEL 1
	.WORD	8+4	;PEDAL 2
	.WORD	2000H	;DIR BIT MASK
	.WORD	8+5	;WHEEL 2

WHEELDIRWAIT	EQU	4	;WAIT THIS LONG FOR CHANGE IN DIR


PEDALTBL
	.WORD	0
	.WORD	PEDALA2DMAX-PEDALA2DMAX/8
	.WORD	PEDALA2DMAX-PEDALA2DMAX/16
	.WORD	PEDALA2DMAX

**
** READOTHERINP
** READ NON-SWITCH OR SPECIAL CASE INPUTS
**
** SCRATCH: A0-A11,A14
**
** JFL 01 DEC 92
** JFL 06 JAN 93; DEBOUNCE WHEEL DIR BIT
** JFL 11 MAR 93; REDONE
**
READOTHERINP
	;GET DIR BIT SWITCH & UPDATE OLD & OLDER SAVES
	MOVW	@SWITCH1,A3		;CUR DIRECTION BITS
	MOVW	@SWITCHRAM+SRDBIT0,A4	;OLD DIR BITS
	MOVW	@SWITCHRAM+SRDBIT1,A5	;OLDER DIR BITS
	MOVW	A3,@SWITCHRAM+SRDBIT0	;SET OLD DIR BITS
	MOVW	A4,@SWITCHRAM+SRDBIT1	;SET OLDER DIR BITS

	;SET UP THE REST
	MOVI	TALKPORT,A1		;A2D INTERRUPT BIT FLAG
	MOVI	A2D_PORT,A2		;A2D PORT
	MOVI	A2DTBL,A6		;DATA
	MOVK	NUMINPUTSETS,A7		;NUM SETS
	MOVI	INDATA-INPSIZE,A8	;OUTPUT

	;REG USE
	;  A0,A10-A11 SCRATCH
	;  A1 TALKPORT
	;  A2 A2D_PORT
	;  A3 DIRBITS CUR
	;  A4 DIRBITS OLD
	;  A5 DIRBITS OLDER
	;  A6 A2D TBL
	;  A7 INP SET COUNT
	;  A8 OUTPUT

	
ROISETLOOP
	ADDI	INPSIZE,A8

	;
	;GET PEDAL
	;
	MOVW	*A6+,A14		;GET A2D CANNEL
	CALLR	GETA2D ;IN:A0,A1,A2,A14 SC,TALKPORT,A2D_PORT,CHNL OUT:A14

	.IF PEDALONOFF
	SRL	6,A14
	SLL	4,A14
	ADDI	PEDALTBL,A14
	MOVW	*A14,A14
	.ENDIF ;PEDALONOFF

	MOVW	A14,*A8(INPPEDAL)

	;
	;GET DIR BIT
	;
	CLR	A14			;DEFAULT TO NO SPIN
	MOVW	*A6+,A0			;DIRECTION BIT MASK
	MOVE	A3,A10
	MOVE	A4,A11
	AND	A0,A10
	AND	A0,A11
	CMP	A10,A11
	JRNE	ROISETSPIN
	AND	A5,A0
	CMP	A0,A10
	JRNE	ROISETSPIN

	;
	;GET WHEEL
	;
	MOVW	*A6,A14			;GET A2D CANNEL
	CALLR	GETA2D ;IN:A0,A1,A2,A14 SC,TALKPORT,A2D_PORT,CHNL OUT:A14

	;SET DIR OF SPIN
	MOVE	A10,A10
	JRZ	ROIPOS
	NEG	A14
ROIPOS

ROISETSPIN
	MOVW	A14,*A8(INPWHEELMAG)	;SAVE
	ADDK	16,A6			;BUMP PAST A2D CHANNEL
	
ROINEXT
	;NEXT SET
	DSJ	A7,ROISETLOOP
	
	RETS

**
** GETA2D
**
** IN
**   A0 SCRATCH
**   A1 TALKPORT
**   A2 A2D_PORT
**  A14 CHANNEL
** OUT
**  A14 VALUE
**
** JFL 01 DEC 92
** JFL 11 MAR 93
**
GETA2D
	MOVW	A14,*A2			;START CONVSERSION	

	MOVI	(1*MICRO_SECOND)/2,A0
	DSJ	A0,$

	MOVI	(70*MICRO_SECOND)/2,A0	;MAX DELAY FOR CONVERSION
GADWAIT
	MOVW	*A1,A14			;READY?
	BTST	B_A2D,A14
	JRZ	GADREADY
	DSJ	A0,GADWAIT

GADREADY
	MOVW	*A2,A14			;GET A2D VALUE
	SLL	24,A14			;ISOLATE VALUE
	SRL	24,A14
	RETS

	.END

* EOF
