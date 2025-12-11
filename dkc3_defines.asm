includeonce

CurrentMusicTrack = $7E0008

ActiveFrameCounter = $7E0000
GlobalFrameCounter = $7E005A

;Direct page RAM addresses used for many purposes
Multipurpose1 = $7E001A
Multipurpose2 = $7E001C
Multipurpose3 = $7E001E
Multipurpose4 = $7E0020
Multipurpose5 = $7E0022

Level = $7E00C0

Pad1Held = $7E04CA
Pad1Pressed = $7E04CE
Pad1Released = $7E04D2

Pad2Held = $7E04CC
Pad2Pressed = $7E04D0
Pad2Released = $7E04D4

CurrPadHeld = $7E04D6
CurrPadPressed = $7E04DA

ScreenBrightness = $7E04EC

LeaderKongPtr = $7E04F9
FollowerKongPtr = $7E04FD

ActiveKong = $7E05B5		;#$0000: Dixie, #$0001, Kiddy

KongFlags = $7E05AF		;bit #$0040 = Game paused; bit #$4000 = Both Kongs are present

BossHP = $7E1B75

;Object array base offsets
Object0 = $7E080A
Object1 = $7E0878
Object2 = $7E08E6
Object3 = $7E0954
Object4 = $7E09C2
Object5 = $7E0A30
Object6 = $7E0A9E
Object7 = $7E0B0C
Object8 = $7E0B7A
Object9 = $7E0BE8
Object10 = $7E0C56
Object11 = $7E0CC4
Object12 = $7E0D32
Object13 = $7E0DA0
Object14 = $7E0E0E
Object15 = $7E0E7C
Object16 = $7E0EEA
Object17 = $7E0F58
Object18 = $7E0FC6
Object19 = $7E1034
Object20 = $7E10A2
Object21 = $7E1110
Object22 = $7E117E
Object23 = $7E11EC
Object24 = $7E125A
Object25 = $7E12C8
Object26 = $7E1336
Object27 = $7E13A4
Object28 = $7E1412
ObjectArrayEnd = $7E1480

;Object array offsets
Type = $7E0000
Priority = $7E000E
XCoord = $7E0012
YCoord = $7E0016
OAMAttr = $7E001E
Sprite = $7E0024
Status = $7E0038

!ObjectArrayLength = $006E

OAMAttrStartPtr = $7E0082		;Direct page RAM address holding start pointer to OAM attribute array
OAMSizeStartPtr = $7E0086		;Direct page RAM address holding start pointer to OAM size bit array
;OAMUnknown = $70
OAMUnknown2 = $7E155E

;Subroutine offsets (names taken from p4plus2's DKC2 disassembly)
InitRegistersGlobal = $808258
;SetKongPtrs = $80883B			;JSR - Sets $04F9-$04FF
DMAtoVRAM = $8087E0
ClearNoncriticalWRAM = $808CB0		;Clears $C6-$F9, $06D8-$1D9A, and $7E2D80-$7EFFFF Thanks, H4v0c21
ClearVRAM = $80825E			;JSR
SetUnusedOAMOffscreen = $80898C
SetFade = $808501
FadeScreen = $808508
PrepareOAMDMAChannel = $808C43		;JSR
IntroControllerRead = $8089CA
SetAndWaitForNMI = $8083C3		;JSR
;ClearVRAMBlock = $80B0C9		;JSR
PlayMusic = $B28009
PlaySndHiPriority = $B2801B
BuildSpriteOAM = $B78857
Code_B5A8DA = $B79BCC
DMASpriteGfx = $B3D843
DMAPalette = $BB856D
DecompressData = $BB857C
DisableScreen = $BB9B42
InitSpriteRenderOrderGlobal = $BB8EF2