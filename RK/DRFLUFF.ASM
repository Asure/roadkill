***
*** FILE: DRFLUFF.ASM
*** TITLE SCREENS AND THE LIKE
***
*** JMS 15 APR 93; STARTED
*** 
	.MLIB	"APMACS.LIB"
	.FILE	"DRFLUFF.ASM"
	.TITLE	"<<< DERBY RACE -- FLUFF >>>"
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
	.INCLUDE	"IMGTBLM2.GLO"
	.INCLUDE	"IMGTBLF1.GLO"
	.INCLUDE	"DISPEQU.ASM"
	.INCLUDE	"DRB.I"
	.INCLUDE	"DRINP.I"
	.INCLUDE	"DRSND.I"
	.INCLUDE	"DRDISP.I"

** OTHERS USE
	.DEF	FLP_FLUFF	;DRWINSCR.ASM

** WE USE
	.REF	WIPEOUT			;AP.ASM
	.REF	STARTNEWATTRACT	;DRATT.ASM
	.REF	DISPATCHPROC	;AP.ASM
	.REF	SET_IMAGE   	;DREQUIP.ASM
	.REF	INSOBJ		;APD.ASM
	.REF	INSERT_OBJ	;APD.ASM
	.REF	ZAP_OBJ		;APD.ASM
	.REF	STARTPLANES	;DRB.ASM
	.REF	GETFPAL		;APPALL.ASM
	.REF	MAKESND		;DRSND.ASM
	.REF	GAME_STATE	;
	.REF	GET_BUTTON_CHECKSUM	;DRINITAL.ASM
	.REF	PALFXINIT	;APPALL.ASM
	.REF	PALCYCLEADD	;APPALL.ASM

** WE USE -- RAM


** LOCAL VARIABLES

FLUFF_GENERIC_OBJECT
	.LONG	FONT_A		;IMAGE
	.LONG	0		;COLLISION VECTOR
	.WORD	OID_JUNK	;OID
	.WORD	DMAWNZ		;OCTRL
	.WORD	0		;OFLAGS
	.WORD	STYPNONE	;OSCALTYP
	.LONG	0		;CFUNC


**
** FLP_FLUFF - FLOW-LEVEL PROCESS
**
**  IN
**    NONE
**
**  OUT
**    NONE
**
**  PURPOSE
**    HANDLES THE FLUFF
**
**  JMS 15 APR 93
**

FLP_FLUFF

	;SET GAME_STATE
	MOVI	INFLUFFMODE,A14
	MOVW	A14,@GAME_STATE

	;CALL THE COLOR CYCLE INITIALIZATION WIDGET
	CALLA	PALFXINIT ;IN:NONE

	;DRAW THE BACKGROUND
	MOVK	PLIDTITLE,A2
	CALLA	STARTNEWATTRACT ;IN:A2 PLANEID

	;MAKE THE TITLE THANG
	MOVI	FLUFF_GENERIC_OBJECT,A5
	CALLA	CREATE_OBJ ;IN:A5 COBLOCK  OUT:A0 hOBJECT
	CALLA	INSOBJ ;IN:A0
	MOVI	RKILL,A1
	CALLA	SET_IMAGE ;IN:A0,A1 hOBJECT,hIMAGE

	;CYCLE IT
	MOVW	*A0(OPAL),A14
	SRL	8,A14
	SLL	8,A14

	MOVI	01380002h,A2
	OR	A14,A2
	MOVK	1,A3

	;PALCYCLEADD ZORCHES A0-A6
	CALLA	PALCYCLEADD ;IN:A2,A3 VEL.8:COUNT.8:PAL.16,TIME

	;MAKE THE TITLE THANG PART 2
	MOVI	FLUFF_GENERIC_OBJECT,A5
	CALLA	CREATE_OBJ ;IN:A5 COBLOCK  OUT:A0 hOBJECT
	CALLA	INSOBJ ;IN:A0
	MOVI	RKILL2,A1
	CALLA	SET_IMAGE ;IN:A0,A1 hOBJECT,hIMAGE

	SLEEP	ONESECOND*5

	CREATE	PID_MAIN,DISPATCHPROC
	DIE



* EOF
