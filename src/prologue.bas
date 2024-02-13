OPTION FASTINTERRUPT

CONST MSGBOX_ADDR = $cb48
CONST TEXTBOX_LINE = 217
CONST CURTAIN_LINE = 197

CONST COLOR_NARRATOR    = $f    'COLOR_LIGHTGRAY
CONST COLOR_YOU         = $e    'COLOR_LIGHTBLUE
CONST COLOR_COLONEL     = $8    'COLOR_ORANGE
CONST COLOR_LIEUTENANT  = $a    'COLOR_LIGHTRED

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_gfx.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_zx0.bas"
INCLUDE "../libs/lib_sid.bas"

DECLARE SUB PutText(Addr AS WORD, Msg AS STRING*40, ColorNr AS BYTE) STATIC
DECLARE SUB Center(LineNr AS BYTE, ColorNr AS BYTE, Msg AS STRING*40) STATIC
DECLARE SUB Left(LineNr AS BYTE, ColorNr AS BYTE, Msg AS STRING*40) STATIC
DECLARE SUB Right(LineNr AS BYTE, ColorNr AS BYTE, Msg AS STRING*40) STATIC
DECLARE SUB ShowImage(BitmapAddr AS WORD, ScreenAddr AS WORD, ColorAddr AS WORD, BgColor AS BYTE) STATIC
DECLARE SUB ChangePage() STATIC

DIM PETSCII(8) AS BYTE @ _PETSCII

'Setup music
CALL DecompressZX0_Unsafe(@Hellrider_SID_ZX0, $1000)

ASM
    lda #0
    jsr $1000
END ASM

POKE $d015,0
'Setup graphics
CALL ScreenOff()

BORDER COLOR_BLACK
BACKGROUND COLOR_BLACK
CALL SetVideoBank(3)
CALL SetBitmapMemory(1)
CALL SetScreenMemory(2)
SCREEN 2
MEMSET $c800, 1000, 32
MEMSET $d800, 1000, 0
MEMSET $e000, 8000, 0

MEMCPY @CoverSprite, $ff80, 64
FOR T AS BYTE = 0 TO 6
    SPRITE T AT 24+CWORD(48)*T,CURTAIN_LINE SHAPE 254 COLOR COLOR_BLACK XYSIZE 1,0 HIRES ON
NEXT T

POKE $d01b,0

SYSTEM INTERRUPT OFF
ON RASTER TEXTBOX_LINE GOSUB IRQ

CALL SetGraphicsMode(MULTICOLOR_BITMAP_MODE)
CALL ScreenOn()
RASTER INTERRUPT ON

CALL ShowImage(@Image003_Bitmap, @Image003_Screen, @Image003_Color, $03)

CALL Center(2, COLOR_NARRATOR, "this is your ship - moonwraith")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "moonwraith pierces the atmosphere")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "celestial savior on a rescue mission")
CALL ChangePage()

CALL ShowImage(@Image002_Bitmap, @Image002_Screen, @Image002_Color, $0b)

CALL Center(2, COLOR_NARRATOR, "this is you, commander jameson")
CALL Center(3, COLOR_NARRATOR, "a ranger from federation of free traders")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "you walk toward the ominous hq")
CALL Center(3, COLOR_NARRATOR, "of planet irata")
CALL ChangePage()

CALL ShowImage(@Image001_Bitmap, @Image001_Screen, @Image001_Color, $00)

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "commander jameson, thanks for coming")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "elvin atombender has captured")
CALL Center(3, COLOR_COLONEL, "the singularity generator")

CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "that is both stupid and dangerous")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "yes, but he still dreams of")
CALL Center(3, COLOR_COLONEL, "world domination")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "we must stop him before runaway")
CALL Center(3, COLOR_COLONEL, "singularity destroys spacetime")

CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "i am ready to deploy sir")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "that's music to my ears")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "this is my daughter,")
CALL Center(3, COLOR_COLONEL, "lieutenant mariah rockford")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "she will be your liaison officer")
CALL Center(3, COLOR_COLONEL, "and brief you to the mission")

CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "lieutenant, good to meet you")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "good to meet you too, sir")
CALL Center(3, COLOR_LIEUTENANT, "your reputation has preceded you")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "i'll show you to the mission control")

CALL ChangePage()

CALL ShowImage(@Image004_Bitmap, @Image004_Screen, @Image004_Color, $00)

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "commander jameson, situation is dire")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "our only hope is to build")
CALL Center(3, COLOR_LIEUTENANT, "a singularity diffuser")
CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "gathering components for it")
CALL Center(3, COLOR_YOU, "will be an extremely dangerous task")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "that's why you are here, sir")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "negotiate the components from nearby")
CALL Center(3, COLOR_LIEUTENANT, "space stations and bring them to us")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "but be careful, elvin has deployed")
CALL Center(3, COLOR_LIEUTENANT, "ai missile silos to block interception")
CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(1, COLOR_YOU, "aye, lieutenant")
CALL Center(2, COLOR_YOU, "consider it done")
CALL ChangePage()

RASTER INTERRUPT OFF
POKE $d015, 0
CALL SidStop()

CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)
'SCREEN 2

CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

CALL Text(7, 8, 1, 0, TRUE, "verge station", CHAR_MEMORY)
'CALL Text(11, 10, 1, 0, FALSE, "network connecting", CHAR_MEMORY)

GameState = GAMESTATE_STARTING

IF NOT Debug THEN CALL LoadProgram("station", CWORD(8192))

END

IRQ:
    ASM
        lda $d011
        and #%00010000
        beq IRQ_Exit

        lda $d021
        pha
        ;-----------------
        lda $d018
        and #%11110000
        ora #%00000100  ;character memory=2
        sta $d018

        lda #%00011011
        sta $d011       ;bmm off

        lda #%11001000
        sta $d016       ;mcm off

        lda #0
        sta $d021       ;background black
        ;-----------------
        bit $d011
        bpl *-3
        ;-----------------
        lda $d018
        and #%11110000
        ora #%00001000  ;bitmap memory=1
        sta $d018

        lda #%00111011
        sta $d011       ;bmm on

        lda #%11011000
        sta $d016       ;mcm on

        pla
        sta $d021

IRQ_Exit
        jsr $1003
    END ASM
RETURN

SUB PutText(Addr AS WORD, Msg AS STRING*40, ColorNr AS BYTE) STATIC
    MEMSET Addr+$1000, LEN(Msg), ColorNr
    ASM
        lda #<{Msg}
        sta {ZP_W1}
        lda #>{Msg}
        sta {ZP_W1}+1

        lda {Addr}
        sta {ZP_W0}
        lda {Addr}+1
        sta {ZP_W0}+1

        ldy {Msg}
loop
        lda ({ZP_W1}),y
        lsr
        lsr
        lsr
        lsr
        lsr
        tax
        lda ({ZP_W1}),y
        clc
        adc {PETSCII},x

        dey
        sta ({ZP_W0}),y

        bne loop
    END ASM
END SUB

SUB Center(LineNr AS BYTE, ColorNr AS BYTE, Msg AS STRING*40) STATIC
    DIM Addr AS WORD
    Addr = MSGBOX_ADDR + LineNr * 40 + SHR(40 - LEN(Msg), 1)
    CALL PutText(Addr, Msg, ColorNr)
END SUB

SUB Left(LineNr AS BYTE, ColorNr AS BYTE, Msg AS STRING*40) STATIC
    DIM Addr AS WORD
    Addr = MSGBOX_ADDR + LineNr * 40
    CALL PutText(Addr, Msg, ColorNr)
END SUB

SUB Right(LineNr AS BYTE, ColorNr AS BYTE, Msg AS STRING*40) STATIC
    DIM Addr AS WORD
    Addr = MSGBOX_ADDR + LineNr * 40 + 40 - LEN(Msg)
    CALL PutText(Addr, Msg, ColorNr)
END SUB

SUB ShowImage(BitmapAddr AS WORD, ScreenAddr AS WORD, ColorAddr AS WORD, BgColor AS BYTE) STATIC
    CALL WaitRasterLine256()
    CALL ScreenOff()

    CALL DecompressZX0_Unsafe(BitmapAddr, $a000)
    MEMCPY $a000, $e000, 8000
    CALL DecompressZX0_Unsafe(ColorAddr, $c800)
    MEMCPY $c800, $d800, 1000
    CALL DecompressZX0_Unsafe(ScreenAddr, $c800)

    CALL WaitRasterLine256()

    BACKGROUND BgColor

    CALL WaitRasterLine256()
    CALL ScreenOn()
END SUB

SUB ChangePage() STATIC
    CALL JoyWaitClick(JOY2)
    MEMSET MSGBOX_ADDR, 160, 32
END SUB

_PETSCII:
DATA AS BYTE $80, $00, $c0, $e0, $40, $c0, $80, $80

CoverSprite:
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $ff, $ff, $ff

'BgColor = $00
Image001_Bitmap:
    INCBIN "../gfx/prologue001_bitmap.zx0"
Image001_Screen:
    INCBIN "../gfx/prologue001_screen.zx0"
Image001_Color:
    INCBIN "../gfx/prologue001_color.zx0"

'BgColor = $0b
Image002_Bitmap:
    INCBIN "../gfx/prologue002_bitmap.zx0"
Image002_Screen:
    INCBIN "../gfx/prologue002_screen.zx0"
Image002_Color:
    INCBIN "../gfx/prologue002_color.zx0"

'BgColor = $03
Image003_Bitmap:
    INCBIN "../gfx/prologue003_bitmap.zx0"
Image003_Screen:
    INCBIN "../gfx/prologue003_screen.zx0"
Image003_Color:
    INCBIN "../gfx/prologue003_color.zx0"

'BgColor = $00
Image004_Bitmap:
    INCBIN "../gfx/prologue004_bitmap.zx0"
Image004_Screen:
    INCBIN "../gfx/prologue004_screen.zx0"
Image004_Color:
    INCBIN "../gfx/prologue004_color.zx0"

Hellrider_SID_ZX0:
INCBIN "../sfx/Hellrider.zx0"
