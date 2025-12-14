;Donkey Kong Country 3 (U) - Fix follower Kong idle animation
;By Mattrizzle
;These changes fix the issue where the follower Kong will be in a continuous walk cycle when stationary in most cases.

hirom

incsrc dkc3_defines.asm

;$F90000-$F9007D Table of substatus routines for follower to run based on leader's animation ID
org $F90001
	db $01	;Change follower's status while leader is idle (default: db $00). 
		;In the vanilla game, $00 is a duplicate of $01. We've changed it so that it always shows the either the idle animation or the rolling animation
		;(see FollowerCannonOrTeamUp), which would cause the follower to slide along the ground in their idle animation briefly when the leader 
		;would start moving if this byte wasn't changed.
org $F90006
	db $07	;Change follower's substatus while leader is riding a Steel Keg (default: db $02). This makes them use the Steel Keg riding animation, just like the leader.

org $F90007
	db $01	;Change follower's substatus while leader is crouching (default: db $00).
		;This needs to be changed for same reason as $F90001.
org $F90015
	db $03	;Change follower's substatus while leader is throwing an object (default: db $01). This fixes a visual anomaly where the follower will display their walking
		;animation in the air if the leader throws an object while jumping.
org $F90037
	db $00	;Change follower's substatus while fired from a Barrel Cannon or "teamed up" (default: db $05).
		;For the "teamed up" part, this only affects when they've landed on the ground after being thrown into a sprite which knocks them back
		;(e.g. Doorstop Dash's titular doorstops).
org $F90039
	db $16	;Change follower's substatus when leader collects a Bonus Coin (default: db $01).

org $B88488
	RTS				;\Make follower Kong copy leader Kong's movements the normal way after collecting a Bonus Coin 
	padbyte $FF : pad $B88492	;/instead of floating in a straight line toward them
					; (default: LDA.w #$001F : LDX.w #$0002 : LDY.w #$0000 : JSL $B8F028 : RTS)
org $B8F14D
	JMP.w FollowerKongIdleFix

org $B8F158
	JMP.w FollowerKongIdleFix_2	;Entry point for standing on platform sprite

org $B8FA1D
FollowerKongIdleFix_2:
	  JSR.w IdleFix_Main
	  LDA.w $1925
	  JMP.w $B8F15B

FollowerKongIdleFix:
	  BCC.b IdleFix_Main
	  JMP.w $B8F168

IdleFix_Main:
	  LDY.w LeaderKongPtr
	  ;Start of extra code not ported from DKC2 to handle follower Kong's movement to leader Kong's X-coordinate before jumping
	  ;Without this, the follower would slide toward the leader Kong in their idle animation.
	  ;With this, the follower shows their walking or running animation when doing so.
	  LDA.w $0028,y		;Load leader Kong's collision flags
	  AND.w #$0011		;Isolate the platform sprite and top of tile contact bits	  
	  BNE.b .LeaderOnGround	;Branch if not zero
	  LDA.b $1A,x		;Load follower Kong's ground distance
	  BNE.b .Return		;Don't set idle flag if airborne
	  LDA.w $191B		;Load follower Kong status
	  CMP.w #$0008		;Check if #$0008 (jumping)
	  BEQ.b +		;If so, branch
	  CMP.w #$0024		;Check if #$0024 (jumping while carrying object)
	  BEQ.b +		;If so, branch
	  CMP.w #$000C		;Check if #$000C (knocked back)
	  BNE.b ++
       +  LDA.w #$0001		;-Set to #$0001 (standing/walking). This fixes an issue where the follower's animation doesn't switch to idle when leader repeatedly jumps in place.
	  STA.w $191B		;/
       ++ LDA.w $0012,y		;Load leader Kong's X-coordinate
	  CMP.b $12,x		;Compare to follower Kong's X-coordinate
	  BNE.b .Return		;Branch if not equal (skips setting idle animation flag)
	  ;End of extra code not ported from DKC2
.LeaderOnGround
	  LDA.w $0030,y		;Load leader Kong's target X-velocity
	  BNE.b .Return		;Skip to RTS if non-zero
	  LDA.w $002A,y		;Load leader Kong's current X-velocity
	  BNE.b .Return		;Skip to RTS if non-zero
	  LDA.w #$0008		;Set follower Kong idle animation flag (carried over from DKC2, but never used in vanilla DKC3)
	  TSB.w $1927
.Return
	  RTS
pushpc
org $B8F1B1
	dw FollowerCannonOrTeamUp	;Follower substatus $00, normally status 0 jumps to the same location as status 1: $B8F1C5

org $B8F1B7
	dw FollowerDisplayJumpAnim	;Follower substatus $03

org $B8F1BB
	dw FollowerDisplayRollAnim	;Follower substatus $05

org $B8F1DC
	db $FF
	dw FollowerBonusClear		;Follower substatus $16 (using space normally out of bounds for the table at $B8F1B1 for an extra status)
	padbyte $FF : pad $B8F1E2

org $B8F1F4
	JMP.w FollowerKongLandFromAirFix

pullpc
FollowerCannonOrTeamUp:
	LDY.w LeaderKongPtr
	LDA.w $0038,y		; Load leader Kong's status
	CMP #$001D		; Check if fired from barrel cannon
	BEQ.b +			; Branch to vanilla rolling code if true
	LDA.w #$0001		; Load ID of idle animation
	JMP.w $B8F280		; Jump to routine to set animation
+	JMP.w $B8F1FA		; Jump to location of vanilla rolling code

FollowerDisplayJumpAnim:
	   LDX.b $70
	   LDA.b $1A,x
	   BNE.b +
	   JSR.w CheckGroundCollisionForFollowerIdleAnim
	   BCC.b +
	   JSR.w ResetAnimationBuffer
	   LDA.w #$0004
	   TRB.w $1927
	   RTS
	+  JMP.w $B8F1E2

CheckGroundCollisionForFollowerIdleAnim:
	LDY.w LeaderKongPtr
	LDA.w $0028,y		; Load leader Kong's collision flags
	AND.w #$0011		; Isolate the platform sprite and top of tile contact bits
	BEQ.b .LeaderInAir	; Branch if zero (leader in air)
	LDA.b $1A,x		; Load follower Kong's ground distance
	BEQ.b .FollowerOnGround	; Branch if zero (follower on ground)
	LDA.b $16,x		; Load follower's Y-coordinate
	CMP.w $0016,y 		; Compare to leader's Y-coordinate
	BNE.b .LeaderInAir

.FollowerOnGround
	SEC
	RTS

.LeaderInAir
	CLC
	RTS

FollowerDisplayRollAnim:
	   LDA.w $191B
	   CMP.w #$000D		;-If bouncing after stomping enemy,
	   BEQ.b ++		;/skip to vanilla code
	   LDY.b $74
	   LDA.w $0000,y	
	   CMP.w #$0001		;-Check if leader in idle animation
	   BEQ.b +		;/If so, skip to resetting animation buffer and clearing follower turning bit
	   CMP.w #$0007		;-Check if leader in crouching animation
	   BNE.b ++		;/If not, skip to vanilla code
	+  JSR.w ResetAnimationBuffer
	   LDA.w #$0004		;-Clear follower turning bit.
	   TRB.w $1927		;/
	   RTS
	++ JMP.w $B8F1FA

;This sets several indices in animation buffer for the follower Kong to match the Leader Kong's current animation 
;until the current index of the leader's animation in the buffer is reached.
ResetAnimationBuffer:
	  PHX
	  LDA.w #$0001
	  LDX.w $1925
	- STA.l $7E4140,x
	  PHA
	  INX
	  INX
	  TXA
	  AND.w #$003F
	  TAX
	  PLA
	  CPX.w $1923 
	  BNE.b -
	  PLX
	  RTS

FollowerBonusClear:
	LDX.w LeaderKongPtr
	LDA.b $60,x		;Load leader's walk timer
	BEQ.b .LeaderWalking	;Skip setting follower idle flag if zero
	LDA.w #$0008
	TSB.w $1927
.LeaderWalking
	JMP.w $BBF1C5

FollowerKongLandFromAirFix:
	  JSR.w CheckGroundCollisionForFollowerIdleAnim
	  BCC.b +
	  LDA.w #$0004	; Clear follower turning bit. This prevents an issue where follower sometimes gets stuck in their turning animation
	  TRB.w $1927	; after dropping from a horizontal rope/pull bar
	  JMP.w $B8F1C5	; Jump to code for handling ground animations
	+ LDA.w #$0081	;-Set follower Kong's falling animation
	  JMP.w $B8F280	;/

;Adjustments to make follower Kong turn properly while in the Steel Keg riding animation
org $F91079
	db $85 : dw CheckIfFollowerKong

org $F91432
	db $85 : dw CheckIfFollowerKong

org $B9C087
CheckIfFollowerKong:
	  CPX.w FollowerKongPtr
	  BEQ +
	  JMP.w $B9AA15
	+ RTS
pushpc
;End of adjustments to make follower Kong turn properly while in the Steel Keg riding animation

org $B9A625
	JMP.w IdleAnimationZeroSpeedIfFollowerKong ;This is to fix a side effect with the idle animation. The follower Kong's X and Y speed are not cleared when using the animation,
	NOP					   ;which makes the Kong walk away when their idle animation should be displayed in multiple cases.
HijackEnd:					   ;Among these cases are after being rescued from a DK Barrel and after Kiddy completes his team throw slam attack.
skip 16
HijackEnd_2:

pullpc
IdleAnimationZeroSpeedIfFollowerKong:
	LDA.b $00,x		;\ Load current object's type
	CMP.w #$0310		; >Check if NPC screen object
	BEQ.b +			;/ Branch to vanilla code if true
	CPX.w FollowerKongPtr
	BEQ.w ++
+	LDA.b $30,x
	BNE.b +
	JMP.w HijackEnd
+	JMP.w HijackEnd_2
++	STZ.b $30,x		;Follower Kong X speed variable
+	LDA.w #$0000
	RTS