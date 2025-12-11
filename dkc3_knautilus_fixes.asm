hirom

incsrc dkc3_defines.asm

optimize address ram

org $DD758D
	incbin "incbin/dkc3_krool_far_propeller_color_fix.bin"	; The propeller sprites used when Baron K. Roolenstein is in the background of Knautilus
								; are colored inconsistently from the normal sprites. This bin file contains a corrected
								; version of these sprites.
org $B3A40D
; In the vanilla US version, the electric ray in Knautilus continues to move when the game is paused and will harm the player if unpaused at the right moment.
; This tweak, backported from the European version, fixes the bug.
KnautilusElectricRayFix:
	JMP .Main
	NOP
.EndHijack

org $B3F938
.StopRay
	JMP.w $B3A5C8
.Main
	LDA.w KongFlags
	BIT.w #$0040		;Game Paused flag
	BNE.w .StopRay
	LDA.l $7EA220
	JMP.w .EndHijack