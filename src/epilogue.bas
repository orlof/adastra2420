OPTION FASTINTERRUPT

GOTO START

ORIGIN $1000
INCBIN "../sfx/Stylerock.bin"

ORIGIN $1e6a
START:

CONST MSGBOX_ADDR = $cb48
CONST TEXTBOX_LINE = 217
CONST CURTAIN_LINE = 197

CONST COLOR_NARRATOR    = $f
CONST COLOR_YOU         = $e
CONST COLOR_COLONEL     = $8
CONST COLOR_LIEUTENANT  = $a
CONST COLOR_MULE        = $7
CONST COLOR_PRESIDENT   = $3

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

CALL ShowImage(@Image001_Bitmap, @Image001_Screen, @Image001_Color, $00)

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "colonel, he did it!")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant mariah rockford")
CALL Center(2, COLOR_LIEUTENANT, "i never doubted him for a second!")
CALL ChangePage()

CALL ShowImage(@Image002_Bitmap, @Image002_Screen, @Image002_Color, $00)

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "that lad is truly elite")
CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel rockford")
CALL Center(2, COLOR_COLONEL, "i was afraid this would be")
CALL Center(3, COLOR_COLONEL, "an impossible mission")
CALL ChangePage()

CALL ShowImage(@Image003_Bitmap, @Image003_Screen, @Image003_Color, $03)

CALL Center(2, COLOR_NARRATOR, "you return to the planet irata")
CALL Center(3, COLOR_NARRATOR, "for debriefing")
CALL ChangePage()

CALL ShowImage(@Image004_Bitmap, @Image004_Screen, @Image004_Color, $03)

CALL Center(2, COLOR_NARRATOR, "on your way to the hq you")
CALL Center(3, COLOR_NARRATOR, "meet an odd cow like robot")
CALL ChangePage()

CALL Left(0, COLOR_MULE, "cow like robot")
CALL Center(2, COLOR_MULE, "hello commander jameson")
CALL ChangePage()

CALL Left(0, COLOR_MULE, "cow like robot")
CALL Center(2, COLOR_MULE, "i was wandering who the president")
CALL Center(3, COLOR_MULE, "of foft was here to meet")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "you leave the cow behind and")
CALL Center(3, COLOR_NARRATOR, "head for the hq")
CALL ChangePage()

CALL ShowImage(@Image005_Bitmap, @Image005_Screen, @Image005_Color, $00)

CALL Center(2, COLOR_NARRATOR, "you are escorted to a great hall")
CALL Center(3, COLOR_NARRATOR, "where president is waiting for you")
CALL ChangePage()

CALL Left(0, COLOR_PRESIDENT, "president")
CALL Center(2, COLOR_PRESIDENT, "never in the field of human conflict")
CALL Center(3, COLOR_PRESIDENT, "was so much owed by so many to so few")
CALL ChangePage()

CALL Left(0, COLOR_PRESIDENT, "president")
CALL Center(2, COLOR_PRESIDENT, "i congratulate you commander jameson")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "after the ceremonies you head to")
CALL Center(3, COLOR_NARRATOR, "a well deserved holiday")
CALL ChangePage()

CALL ShowImage(@Image006_Bitmap, @Image006_Screen, @Image006_Color, $03)
RASTER INTERRUPT OFF
ON RASTER $fb GOSUB IRQ2
RASTER INTERRUPT ON
POKE $d015, 0

CALL DecompressZX0_Unsafe(@Sprite_Font, $c000)

CALL JoyWaitClick(JOY2)

SPRITE 0 AT 110,120 SHAPE 19 COLOR COLOR_BLUE XYSIZE 0,0 ON
SPRITE 1 AT 136,120 SHAPE 7 COLOR COLOR_BLUE XYSIZE 0,0 ON
SPRITE 2 AT 162,120 SHAPE 4 COLOR COLOR_BLUE XYSIZE 0,0 ON
SPRITE 3 AT 110,150 SHAPE 4 COLOR COLOR_BLUE XYSIZE 1,1 ON
SPRITE 4 AT 160,150 SHAPE 13 COLOR COLOR_BLUE XYSIZE 1,1 ON
SPRITE 5 AT 210,150 SHAPE 3 COLOR COLOR_BLUE XYSIZE 1,1 ON

CALL JoyWaitClick(JOY2)

POKE $d015,0

IF Debug THEN
    Score = 123456
END IF

DIM ScoreText AS STRING*8
ScoreText = STR$(Score)
CALL ShowImage(@Image007_Bitmap, @Image007_Screen, @Image007_Color, $00)
CALL TextMC(11, 4, 2, 0, TRUE, "game over", $d000)
CALL TextMC(15, 8, 3, 0, TRUE, "score", $d000)
CALL TextMC(20 - LEN(ScoreText), 10, 2, 0, TRUE, ScoreText, $d000)

CALL JoyWaitClick(JOY2)

RASTER INTERRUPT OFF
CALL SidStop()

IF NOT Debug THEN CALL LoadProgram("menu", CWORD(8192))

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

IRQ2:
    ASM
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

    CALL DecompressZX0_Unsafe(BitmapAddr, $a800)
    MEMCPY $a800, $e000, 8000
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
'mariah rockford
Image001_Bitmap:
    INCBIN "../gfx/epilogue001_bitmap.zx0"
Image001_Screen:
    INCBIN "../gfx/epilogue001_screen.zx0"
Image001_Color:
    INCBIN "../gfx/epilogue001_color.zx0"

'BgColor = $00
'colonel rockford
Image002_Bitmap:
    INCBIN "../gfx/epilogue002_bitmap.zx0"
Image002_Screen:
    INCBIN "../gfx/epilogue002_screen.zx0"
Image002_Color:
    INCBIN "../gfx/epilogue002_color.zx0"

'BgColor = $00
'planet irata
Image003_Bitmap:
    INCBIN "../gfx/prologue003_bitmap.zx0"
Image003_Screen:
    INCBIN "../gfx/prologue003_screen.zx0"
Image003_Color:
    INCBIN "../gfx/prologue003_color.zx0"

'BgColor = $00
'mule
Image004_Bitmap:
    INCBIN "../gfx/epilogue004_bitmap.zx0"
Image004_Screen:
    INCBIN "../gfx/epilogue004_screen.zx0"
Image004_Color:
    INCBIN "../gfx/epilogue004_color.zx0"

'BgColor = $00
'president
Image005_Bitmap:
    INCBIN "../gfx/epilogue005_bitmap.zx0"
Image005_Screen:
    INCBIN "../gfx/epilogue005_screen.zx0"
Image005_Color:
    INCBIN "../gfx/epilogue005_color.zx0"

'BgColor = $00
'holiday
Image006_Bitmap:
    INCBIN "../gfx/epilogue006_bitmap.zx0"
Image006_Screen:
    INCBIN "../gfx/epilogue006_screen.zx0"
Image006_Color:
    INCBIN "../gfx/epilogue006_color.zx0"

'BgColor = $00
Image007_Bitmap:
    INCBIN "../gfx/highscore001_bitmap.zx0"
Image007_Screen:
    INCBIN "../gfx/highscore001_screen.zx0"
Image007_Color:
    INCBIN "../gfx/highscore001_color.zx0"

Sprite_Font:
    INCBIN "../gfx/sprite_font.zx0"