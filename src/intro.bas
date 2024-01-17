OPTION FASTINTERRUPT

CONST MSGBOX_ADDR = $cb48
CONST TEXTBOX_LINE = 217
CONST CURTAIN_LINE = 198

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
MEMCPY @Hellrider_SID_ZX0, $1000, @Hellrider_SID_ZX0_END - @Hellrider_SID_ZX0

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

CALL ShowImage(@Encounter003_Bitmap, @Encounter003_Screen, @Encounter003_Color, $03)

CALL Center(2, COLOR_NARRATOR, "this is your ship - worluk")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "worluk pierces the atmosphere")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "celestial savior on a rescue mission")
CALL ChangePage()

CALL ShowImage(@Encounter002_Bitmap, @Encounter002_Screen, @Encounter002_Color, $0b)

CALL Center(2, COLOR_NARRATOR, "this is you, commander max power")
CALL Center(3, COLOR_NARRATOR, "a ranger from federation of free traders")
CALL ChangePage()

CALL Center(2, COLOR_NARRATOR, "you walk toward the ominous hq")
CALL Center(3, COLOR_NARRATOR, "of planet irata")
CALL ChangePage()

CALL ShowImage(@Encounter001_Bitmap, @Encounter001_Screen, @Encounter001_Color, $00)

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "commander max power, thanks for coming")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "elvin atombender has captured")
CALL Center(3, COLOR_COLONEL, "the singularity generator")

CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "that is both stupid and dangerous")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "yes, but he still dreams of")
CALL Center(3, COLOR_COLONEL, "world domination")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "we must stop him before runaway")
CALL Center(3, COLOR_COLONEL, "singularity destroys spacetime")

CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "i am ready to deploy sir")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "that's music to my ears")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "this is my daughter,")
CALL Center(3, COLOR_COLONEL, "lieutenant sarah jameson")

CALL ChangePage()

CALL Left(0, COLOR_COLONEL, "colonel jameson")
CALL Center(2, COLOR_COLONEL, "she will be your liaison officer")
CALL Center(3, COLOR_COLONEL, "and brief you to the mission")

CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "lieutenant, good to meet you")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "good to meet you too, sir")
CALL Center(3, COLOR_LIEUTENANT, "your reputation has preceded you")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "i'll show you to the mission control")

CALL ChangePage()

CALL ShowImage(@Encounter004_Bitmap, @Encounter004_Screen, @Encounter004_Color, $00)

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "commander power, situation is dire")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "our only hope is to build")
CALL Center(3, COLOR_LIEUTENANT, "a singularity diffuser")
CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(2, COLOR_YOU, "gathering components for sd")
CALL Center(3, COLOR_YOU, "will be extremely dangerous task")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "that's why you are here, sir")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "negotiate the components from nearby")
CALL Center(3, COLOR_LIEUTENANT, "space stations and bring them to us")
CALL ChangePage()

CALL Left(0, COLOR_LIEUTENANT, "lieutenant sarah jameson")
CALL Center(2, COLOR_LIEUTENANT, "but be careful, elvin has deployed")
CALL Center(3, COLOR_LIEUTENANT, "ai missile silos to block interception")
CALL ChangePage()

CALL Left(0, COLOR_YOU, "you")
CALL Center(1, COLOR_YOU, "aye, lieutenant")
CALL Center(2, COLOR_YOU, "consider it done")
CALL ChangePage()

RASTER INTERRUPT OFF

POKE $d015, 0

'CALL SetBitmapMemory(1)
CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)
'SCREEN 2

CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

CALL Text(7, 2, 1, 0, TRUE, "verge station", CHAR_MEMORY)
CALL Text(13, 4, 1, 0, TRUE, "network", CHAR_MEMORY)
CALL Text(15, 7, 1, 0, FALSE, "connecting", CHAR_MEMORY)

CALL SidStop()

GameState = GAMESTATE_STARTING

CALL LoadProgram("station", CWORD(8192))

END

IRQ:
    ASM
        lda $dd00       ;bank
        and #%00000011
        pha

        lda $d018       ;charmem, bitmapmem, scrmem
        pha

        lda $d021       ;bgcolor
        pha

        ;-----------------
        lda #0          ;bank=3
        sta $dd00

        lda #%00100100  ;screen_memory=2, character_memory=2
        sta $d018

        lda #$1b        ;bim_map_mode=0
        sta $d011

        lda #$c8        ;multi_color_mode=0
        sta $d016

        lda #0
        sta $d021       ;background=black

        ;-----------------
        bit $d011
        bpl *-3

        ;-----------------
        pla
        sta $d021

        pla
        sta $d018

        pla
        sta $dd00

        lda #$3b
        sta $d011

        lda #$d8
        sta $d016

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
Encounter001_Bitmap:
    INCBIN "../gfx/encounter001_bitmap_bin.zx0"
Encounter001_Screen:
    INCBIN "../gfx/encounter001_screen_bin.zx0"
Encounter001_Color:
    INCBIN "../gfx/encounter001_color_bin.zx0"

'BgColor = $0b
Encounter002_Bitmap:
    INCBIN "../gfx/encounter002_bitmap_bin.zx0"
Encounter002_Screen:
    INCBIN "../gfx/encounter002_screen_bin.zx0"
Encounter002_Color:
    INCBIN "../gfx/encounter002_color_bin.zx0"

'BgColor = $03
Encounter003_Bitmap:
    INCBIN "../gfx/encounter003_bitmap_bin.zx0"
Encounter003_Screen:
    INCBIN "../gfx/encounter003_screen_bin.zx0"
Encounter003_Color:
    INCBIN "../gfx/encounter003_color_bin.zx0"

'BgColor = $00
Encounter004_Bitmap:
    INCBIN "../gfx/encounter004_bitmap_bin.zx0"
Encounter004_Screen:
    INCBIN "../gfx/encounter004_screen_bin.zx0"
Encounter004_Color:
    INCBIN "../gfx/encounter004_color_bin.zx0"

'Charset:
'    INCBIN "../gfx/army_moves.64c"
'    INCBIN "../gfx/generic_charset.bin"


Hellrider_SID_ZX0:
INCBIN "../sfx/Hellrider.bin"
Hellrider_SID_ZX0_END:
