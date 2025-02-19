***
*** FILE: DRT.I
*** DERBY RACE -- TOPO INCLUDES
*** 
*** JFL 25 SEP 92
*** JFL 08 OCT 92
*** JFL 14 OCT 92
*** JFL 11 JAN 93
*** JFL 02 FEB 93; WATER & PUDDLE BACK TO OWN TYPE
***

TILTVALFLAT	EQU	-1

TTRIGROCKS	EQU	000H	;UHW ROCKS ACTIVE COUNT	
TTRIGSIZE	EQU	010H	; SIZE

TILTSPEEDSHIFT	EQU	6	;SHIFT VALUE FOR CDTILTSPEED

**
** ELEVATION TERRAIN SPECIAL TYPES
**
ETS_FLAT	EQU	0
ETS_SLOPEL	EQU	1
ETS_SLOPEH	EQU	2
ETS_CLIFF	EQU	3
ETS_SLOPEJ	EQU	4
ETS_CHECKPOINT	EQU	5
ETS_TRIGGER	EQU	6
ETS_TRACK	EQU	7
ETS_BARRIER	EQU	8
ETS_TRIGFLAT	EQU	9
ETS_POINT	EQU	10
ETS_WATER	EQU	11
ETS_PUDDLE	EQU	12

ETS_LCLEAN	EQU	24		;ISOLATE TYPE
ETS_RCLEAN	EQU	24		;ISOLATE TYPE

M_ETSPC		EQU	0FFH		;SINGLE TIRE IS SPECIAL

ETSIZEOF	EQU	4		;SHIFT FOR ONE ELEVTBL ENTRY

**
** TRIGGERS
**
** JFL 25 SEP 92
**
TRIGBUMP	EQU	0		;BUMP
TRIGROCKS	EQU	1		;ROCKS
TRIGMUD		EQU	2		;MUD
TRIGROCKING	EQU	3		;
TRIGLAST	EQU	3		; LAST VALID
TRIGNONE	EQU	32		; INVALID

**
** TRIGFLAT
**
** JFL 05 JAN 93
**
TRIGFXXX1	EQU	0		;
TRIGFLAST	EQU	0		; LAST VALID
TRIGFNONE	EQU	32		; INVALID

TOPOAWATER	EQU	0B0B0B0BH	; ETS_WATER
TOPOAPUDDLE	EQU	0C0C0C0CH	; ETS_PUDDLE 

**
** TISTART STRUCT
**
** JFL 26 OCT 92
**
TISX		EQU	000H	;UHW
TISY		EQU	010H	;UHW
TISDIR		EQU	020H	;UHB
TISXXX1		EQU	028H	;UHB	
TISSIZE		EQU	030H	; SIZE
TISMAX		EQU	4	; MAX DEFINED STARTING SPACES

**
** ARENA SCALE TBL -- STRUCT
**
** JFL 10 DEC 92
**
ASTSTART	EQU	000H		;START OF TBL
ASTEND		EQU	020H		;PAST TBL
ASTSIZE		EQU	040H		; SIZE OF
ASTMAX		EQU	5		; NUMBER OF TBLS
ASTZOFF		EQU	0*ASTSIZE	;INDEX
ASTZ		EQU	1*ASTSIZE	;INDEX
ASTGROWMAX	EQU	2*ASTSIZE	;INDEX
ASTGROW1TO1	EQU	3*ASTSIZE	;INDEX
ASTYZ		EQU	4*ASTSIZE	;INDEX
SCLSIZEOF	EQU	5		; SIZEOF ONE SCALE TBL ENTRY

**
** TRACKINFO POINT TBL
**
** .LONG [Y:X],F()
**
** JFL 11 JAN 93
**
TIPXY		EQU	000H		;UHL Y:X
TIPDATA		EQU	020H		;UHL DATA (SEE M_TIPXXX FOR TYPE)
TIPSIZE		EQU	040H		; SIZE
TIPSIZEOF	EQU	6		; SIZEOF SHIFT
TIPCOUNT	EQU	16		; NUMBER OF POINTS IN TBL
M_TIPAOL	EQU	01H		; SIGNAL AN AOL OBJ

**
** DROP TBL
** FOR WHERE TO DROP ICONS
** 
** JFL 10 FEB 93
**
TIDXY		EQU	000H		;UHL Y:X
TIDSIZE		EQU	020H		; SIZE
TIDSIZEOF	EQU	5		; SIZEOF SHIFT
TIDCOUNT	EQU	8		; NUMBER OF POINTS IN TBL
TIDCOUNTMASK	EQU	7H		; NUMBER OF POINTS IN TBL MASK

**
** TRACKINFO STRUCT
**
** JFL 26 OCT 92
**
TIAOBJLIST	EQU	000H			;UHL LIST OF ARENA SPECIFIC
TIAOBJLISTX	EQU	020H			;UHL DEBUG
TILAPMASK	EQU	040H			;UHB LAP MASK
TILAPSTOWIN	EQU	048H			;UHB
TIANTISLIP	EQU	050H			;UHW ANTI SLIP (SMALL IS LESS)
TIPOINTTBL	EQU	060H			;UHL ARRAY [Y:X],F()
TIPOINTTBLX	EQU	TIPOINTTBL+TIPSIZE*TIPCOUNT
TIDROPTBL	EQU	TIPOINTTBLX		;UHL ARRAY [Y:X]
TIDROPTBLX	EQU	TIDROPTBL+TIDSIZE*TIDCOUNT
TISTART		EQU	TIDROPTBLX		;STARTING AREA
TISIZE		EQU	TISTART+TISMAX*TISSIZE	; SIZE

**
** ARENADEFS
**
** JFL 27 OCT 92
**
ADIDARENA1	EQU	0	;THE QUARRY
ADIDARENA2	EQU	1	;LAKE JOHN
ADIDARENA3	EQU	2	;MUD FIGHT
ADIDARENA4	EQU	3	;MUD FIGHT
ADIDARENA5	EQU	4	;MUD FIGHT
ADIDARENA6	EQU	5	;NEW BG TEST 40 DEG
ADIDARENA7	EQU	6	;NEW BG TEST 35 DEG
ADIDARENA8	EQU	7	;NEW BG 40 DEG
ADIDARENAX	EQU	8	; LAST+1

* EOF
