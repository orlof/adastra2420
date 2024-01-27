OPTION FASTINTERRUPT

DIM Debug AS BYTE
Debug = (PEEK($441) <> $ee)

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
MEMCPY @SID, $1000, @SID_END - @SID

ASM
    lda #0
    jsr $1000
END ASM

'Setup graphics
CALL ScreenOff()

BORDER COLOR_BLACK
BACKGROUND COLOR_BLACK
CALL SetVideoBank(3)
CALL SetBitmapMemory(1)
CALL SetScreenMemory(2)
MEMSET $c800, 1000, 32
MEMSET $d800, 1000, 0
MEMSET $e000, 8000, 0
MEMSET $cbf8, 8, 254
MEMSET $8bf8, 8, 254

MEMCPY @CoverSprite, $bf80, 64
MEMCPY @CoverSprite, $ff80, 64
FOR T AS BYTE = 0 TO 6
    SPRITE T AT 24+CWORD(48)*T,CURTAIN_LINE COLOR COLOR_BLACK XYSIZE 0,1 HIRES ON
NEXT T

SYSTEM INTERRUPT OFF
ON RASTER TEXTBOX_LINE GOSUB IRQ

CALL SetGraphicsMode(MULTICOLOR_BITMAP_MODE)
CALL ScreenOn()
RASTER INTERRUPT ON

CALL ShowImage(@Image001_Bitmap, @Image001_Screen, @Image001_Color, $00)

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "this can't be happening")
CALL Center(3, COLOR_LIEUTENANT, "we lost contact with the moonwraith")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "colonel, what can we do?")
CALL ChangePage()

CALL ShowImage(@Image002_Bitmap, @Image002_Screen, @Image002_Color, $00)

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "there is only one thing left to do")
CALL ChangePage()

CALL ShowImage(@Image003_Bitmap, @Image003_Screen, @Image003_Color, $00)
CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "god help us all")
CALL ChangePage()

RASTER INTERRUPT OFF

POKE $d015, 0

CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)

CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

CALL Text(7, 2, 1, 0, TRUE, "verge station", CHAR_MEMORY)
CALL Text(13, 4, 1, 0, TRUE, "network", CHAR_MEMORY)
CALL Text(15, 7, 1, 0, FALSE, "connecting", CHAR_MEMORY)

CALL SidStop()

'GameState = GAMESTATE_STARTING

IF NOT Debug THEN CALL LoadProgram("intro", CWORD(8192))

END

IRQ:
    ASM
        lda $d021
        pha
        ;-----------------
        lda #%00100100  ;screen_memory=2, character_memory=2
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
        lda #%00101000  ;screen_memory=2, bitmap_memory=1
        sta $d018

        lda #%00111011
        sta $d011       ;bmm on

        lda #%11011000
        sta $d016       ;mcm on

        pla
        sta $d021

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
    CALL DecompressZX0_Unsafe(BitmapAddr, $a000)
    CALL DecompressZX0_Unsafe(ScreenAddr, $8800)
    CALL DecompressZX0_Unsafe(ColorAddr, $9800)

    CALL WaitRasterLine256()
    CALL SetVideoBank(2)
    BACKGROUND BgColor

    MEMCPY $9800, $d800, 1000
    MEMCPY $a000, $e000, 8000
    MEMCPY $8800, $c800, 1000

    CALL WaitRasterLine256()
    CALL SetVideoBank(3)
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
    INCBIN "../gfx/gameover001_bitmap.zx0"
Image001_Screen:
    INCBIN "../gfx/gameover001_screen.zx0"
Image001_Color:
    INCBIN "../gfx/gameover001_color.zx0"

'BgColor = $00
Image002_Bitmap:
    INCBIN "../gfx/gameover002_bitmap.zx0"
Image002_Screen:
    INCBIN "../gfx/gameover002_screen.zx0"
Image002_Color:
    INCBIN "../gfx/gameover002_color.zx0"

'BgColor = $00
Image003_Bitmap:
    INCBIN "../gfx/gameover003_bitmap.zx0"
Image003_Screen:
    INCBIN "../gfx/gameover003_screen.zx0"
Image003_Color:
    INCBIN "../gfx/gameover003_color.zx0"


SID:
INCBIN "../sfx/Pucker_Up.bin"
SID_END: