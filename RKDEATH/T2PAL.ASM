***
*** FILE: T2PAL.ASM
*** JFL 15 JUL 92; A COUPLE OF EXTRA PALETTES THE SYSTEM NEEDS (FOR NOW)
**
	.DEF	TEXTPAL
	.DEF	T2FIXED
	.EVEN	16

TEXTPAL:
	.word	 45
	.word	00H,07C00H,06739H,01FH,035ADH,077A0H,0741AH,03A0H
	.word	00H,010H,0881H,0CA1H,0CC2H,010E2H,01102H,01523H
	.word	01543H,01963H,01984H,01DA4H,01DC3H,01DC4H,021C3H,021C4H
	.word	01DE3H,01DE4H,021E3H,021E4H,02205H,02625H,02645H,02A66H
	.word	02A86H,02EA6H,02EC7H,032E7H,03307H,03727H,03748H,03B47H
	.word	03B48H,03767H,03768H,03B67H,03B68H
T2FIXED:
	.word	 25
	.word	00H,07C00H,06739H,01FH,035ADH,077A0H,0741AH,03A0H
	.word	00H,010H,07E3H,07FFFH,07DADH,06420H,02108H,03DEFH
	.word	04210H,05AD6H,05EF7H,0C0H,0120H,0982H,0221H,0782H
	.word	047F1H

* EOF
