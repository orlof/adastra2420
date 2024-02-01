OPTION FASTINTERRUPT

CONST ALPHABET_START = 0

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_gfx.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_zx0.bas"
INCLUDE "../libs/lib_sid.bas"
INCLUDE "../libs/lib_rnd.bas"

DIM MaxDistance AS BYTE
DIM NumLetters AS BYTE
DIM _SprX(8) AS INT, _SprY(8) AS INT
DIM _SprDX(8) AS INT, _SprDY(8) AS INT
DIM _SprDistance(8) AS INT
DIM SaveFileName(4) AS STRING * 9 @_SaveFileName

DECLARE FUNCTION Sleep AS BYTE(jiffys AS WORD) SHARED STATIC
DECLARE SUB LoadGame(FileNr AS BYTE) STATIC
DECLARE SUB AddLetter(Letter AS STRING*1, X AS INT, Y AS INT, SprColor AS BYTE) STATIC OVERLOAD
DECLARE SUB AddLetter(Letter AS STRING*1, X AS BYTE, Y AS INT, SprColor AS BYTE) STATIC OVERLOAD
DECLARE SUB AddLetter(Letter AS STRING*1, X AS INT, Y AS BYTE, SprColor AS BYTE) STATIC OVERLOAD
DECLARE SUB AddLetter(Letter AS STRING*1, X AS BYTE, Y AS BYTE, SprColor AS BYTE) STATIC OVERLOAD
DECLARE FUNCTION MoveSpritesIn AS BYTE() STATIC
DECLARE FUNCTION MoveSpritesOut AS BYTE() STATIC
DECLARE FUNCTION Scroller AS BYTE(Text AS STRING*96, Y AS BYTE, Speed AS BYTE, Color0 AS BYTE) STATIC

SYSTEM INTERRUPT OFF

CALL DecompressZX0_Unsafe(@SID, $1000)
'MEMCPY @SID, $1000, @SID_END - @SID
ASM
;LIB_GFX_DISABLE_BANK_3
    lda #0
    jsr $1000
END ASM

ON TIMER 17095 GOSUB IRQ
TIMER INTERRUPT ON

BACKGROUND COLOR_BLACK
BORDER COLOR_BLACK

CALL ScreenOff()
CALL SetVideoBank(2)
CALL SetBitmapMemory(1)
CALL SetScreenMemory(2)
CALL SetGraphicsMode(MULTICOLOR_BITMAP_MODE)

CALL DecompressZX0_Unsafe(@Image001_Bitmap, $a000)
MEMCPY $a000, $e000, 8000
CALL DecompressZX0_Unsafe(@Image001_Screen, $8800)
MEMCPY $8800, $c800, 1000
CALL DecompressZX0_Unsafe(@Image001_Color, $9800)
MEMCPY $9800, $d800, 1000

CALL RectMC(32, 40, 127, 159, 1, 0)
CALL SetColorInRect(8, 5, 31, 19, 0, 0)
CALL SetColorInRect(8, 5, 31, 19, 1, COLOR_RED)
CALL SetColorInRect(8, 5, 31, 19, 2, COLOR_LIGHTRED)
CALL TextMC(16, 8, 1, 0, TRUE, "menu", CHAR_MEMORY)
CALL TextMC(12, 12, 1, 0, TRUE, "new game", CHAR_MEMORY)
CALL TextMC(16, 14, 1, 0, TRUE, "load", CHAR_MEMORY)

CALL SetVideoBank(3)

CALL ScreenOn()

CALL DecompressZX0_Unsafe(@SPRITE_DATA, $c000)
'MEMCPY @SPRITE_DATA, $c000, 1600
SCREEN 2

'SPRITE XY EXPAND
POKE $d017,%11111111
POKE $d01d,%11111111
POKE $d01b,%00000000

NumLetters = 0

IF Sleep(200) THEN GOTO MainMenu

CALL AddLetter("A", 50, 60, COLOR_RED)
CALL AddLetter("D", 100, 60, COLOR_RED)
CALL AddLetter("A", 70, 200, COLOR_RED)
CALL AddLetter("S", 120, 200, COLOR_RED)
CALL AddLetter("T", 170, 200, COLOR_RED)
CALL AddLetter("R", 220, 200, COLOR_RED)
CALL AddLetter("A", 270, 200, COLOR_RED)

IF MoveSpritesIn() THEN GOTO MainMenu
IF Sleep(350) THEN GOTO MainMenu
IF MoveSpritesOut() THEN GOTO MainMenu
IF Sleep(50) THEN GOTO MainMenu

'SPRITE XY EXPAND
POKE $d017,%11111100
POKE $d01d,%11111100

CALL AddLetter("B", 160, 100, COLOR_YELLOW)
CALL AddLetter("Y", 185, 100, COLOR_YELLOW)
CALL AddLetter("O", 65, 140, COLOR_YELLOW)
CALL AddLetter("R", 115, 140, COLOR_YELLOW)
CALL AddLetter("L", 165, 140, COLOR_YELLOW)
CALL AddLetter("O", 215, 140, COLOR_YELLOW)
CALL AddLetter("F", 265, 140, COLOR_YELLOW)

IF MoveSpritesIn() THEN GOTO MainMenu
IF Sleep(250) THEN GOTO MainMenu
IF MoveSpritesOut() THEN GOTO MainMenu
IF Sleep(50) THEN GOTO MainMenu

'IF Scroller("", 208, 2, COLOR_BLUE) THEN GOTO MainMenu

MainMenu:
POKE $d015,0
CALL SetVideoBank(2)
DIM Selected AS INT
Selected = 0

CONST BAR_TOP = 92
CONST BAR_BOTTOM = 108
CONST SAVE_BAR_TOP = 60
CONST SAVE_BAR_BOTTOM = 76
CALL RectMC(40, BAR_TOP + SHL(Selected, 4), 120, BAR_BOTTOM + SHL(Selected, 4), 2, MODE_TRANSPARENT)

DO
    CALL JoyUpdate()
    IF JoySame(JOY2) THEN CONTINUE DO
    IF JoyDown(JOY2) THEN
        CALL RectMC(40, BAR_TOP + SHL(Selected, 4), 120, BAR_BOTTOM + SHL(Selected, 4), 0, MODE_TRANSPARENT)
        Selected = Selected + 1
        IF Selected > 1 THEN Selected = 0
        CALL RectMC(40, BAR_TOP + SHL(Selected, 4), 120, BAR_BOTTOM + SHL(Selected, 4), 2, MODE_TRANSPARENT)
    END IF
    IF JoyUp(JOY2) THEN
        CALL RectMC(40, BAR_TOP + SHL(Selected, 4), 120, BAR_BOTTOM + SHL(Selected, 4), 0, MODE_TRANSPARENT)
        Selected = Selected - 1
        IF Selected < 0 THEN
            Selected = 1
        END IF
        CALL RectMC(40, BAR_TOP + SHL(Selected, 4), 120, BAR_BOTTOM + SHL(Selected, 4), 2, MODE_TRANSPARENT)
    END IF
    IF JoyFire(JOY2) THEN
        IF Selected = 0 THEN GOTO NewGame
        IF Selected = 1 THEN GOTO LoadGame
    END IF
LOOP


LoadGame:
CALL RectMC(32, 40, 127, 159, 1, 0)

CALL TextMC(12, 8, 1, 0, TRUE, "main menu", CHAR_MEMORY)
CALL TextMC(14, 10, 1, 0, TRUE, "slot 1", CHAR_MEMORY)
CALL TextMC(14, 12, 1, 0, TRUE, "slot 2", CHAR_MEMORY)
CALL TextMC(14, 14, 1, 0, TRUE, "slot 3", CHAR_MEMORY)
CALL TextMC(12, 16, 1, 0, TRUE, "autosave", CHAR_MEMORY)

Selected = 0
CALL RectMC(40, SAVE_BAR_TOP + SHL(Selected, 4), 120, SAVE_BAR_BOTTOM + SHL(Selected, 4), 2, MODE_TRANSPARENT)

DO
    CALL JoyUpdate()
    IF JoySame(JOY2) THEN CONTINUE DO
    IF JoyDown(JOY2) THEN
        CALL RectMC(40, SAVE_BAR_TOP + SHL(Selected, 4), 120, SAVE_BAR_BOTTOM + SHL(Selected, 4), 0, MODE_TRANSPARENT)
        Selected = Selected + 1
        IF Selected > 4 THEN Selected = 0
        CALL RectMC(40, SAVE_BAR_TOP + SHL(Selected, 4), 120, SAVE_BAR_BOTTOM + SHL(Selected, 4), 2, MODE_TRANSPARENT)
    END IF
    IF JoyUp(JOY2) THEN
        CALL RectMC(40, SAVE_BAR_TOP + SHL(Selected, 4), 120, SAVE_BAR_BOTTOM + SHL(Selected, 4), 0, MODE_TRANSPARENT)
        Selected = Selected - 1
        IF Selected < 0 THEN
            Selected = 4
        END IF
        CALL RectMC(40, SAVE_BAR_TOP + SHL(Selected, 4), 120, SAVE_BAR_BOTTOM + SHL(Selected, 4), 2, MODE_TRANSPARENT)
    END IF
    IF JoyFire(JOY2) THEN
        IF Selected = 0 THEN
            CALL RectMC(32, 40, 127, 159, 1, 0)
            CALL TextMC(16, 8, 1, 0, TRUE, "menu", CHAR_MEMORY)
            CALL TextMC(12, 12, 1, 0, TRUE, "new game", CHAR_MEMORY)
            CALL TextMC(16, 14, 1, 0, TRUE, "load", CHAR_MEMORY)
            GOTO MainMenu
        END IF
        GOTO Resume
    END IF
LOOP

Resume:
CALL SetVideoBank(3)
CALL SetGraphicsMode(INVALID_MODE)
CALL SetBitmapMemory(1)
CALL SetScreenMemory(2)
CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_LIGHTRED)

CALL Text(7, 5, 1, 0, TRUE, "verge station", CHAR_MEMORY)
CALL Text(11, 10, 1, 0, FALSE, "network connecting", CHAR_MEMORY)

CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

TIMER INTERRUPT OFF
CALL SidStop()
CALL LoadGame(Selected - 1)

IF NOT Debug THEN CALL LoadProgram("station", CWORD(8192))
END

NewGame:
CALL SetVideoBank(3)
CALL SetGraphicsMode(INVALID_MODE)
CALL SetBitmapMemory(1)
CALL SetScreenMemory(2)
CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_LIGHTRED)

CALL Text(12, 18, 1, 0, TRUE, "prologue", CHAR_MEMORY)
CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

SPRITE 0 AT 160,100 SHAPE 0 COLOR COLOR_RED XYSIZE 0,0 ON
SPRITE 1 AT 185,100 SHAPE 3 COLOR COLOR_RED XYSIZE 0,0 ON
SPRITE 2 AT 60,130 SHAPE 0 COLOR COLOR_RED XYSIZE 1,1 ON
SPRITE 3 AT 110,130 SHAPE 18 COLOR COLOR_RED XYSIZE 1,1 ON
SPRITE 4 AT 160,130 SHAPE 19 COLOR COLOR_RED XYSIZE 1,1 ON
SPRITE 5 AT 210,130 SHAPE 17 COLOR COLOR_RED XYSIZE 1,1 ON
SPRITE 6 AT 260,130 SHAPE 0 COLOR COLOR_RED XYSIZE 1,1 ON

TIMER INTERRUPT OFF
CALL SidStop()
IF NOT Debug THEN
    CALL LoadProgram("intro", CWORD(8192))
END IF

END

IRQ:
    ASM
        ;lda $d027
        ;eor #%00001000


        jsr $1003
    END ASM
RETURN

FUNCTION Sleep AS BYTE(jiffys AS WORD) SHARED STATIC
    DO UNTIL jiffys = 0
        CALL WaitRasterLine256()
        CALL JoyUpdate()
        IF JoyFire(JOY1) OR JoyFire(JOY2) THEN
            RETURN TRUE
        END IF

        jiffys = jiffys - 1
    LOOP
    RETURN FALSE
END FUNCTION

SUB AddLetter(Letter AS STRING*1, X AS INT, Y AS INT, SprColor AS BYTE) STATIC OVERLOAD
    SPRITE NumLetters COLOR SprColor SHAPE ASC(Letter)-193+ALPHABET_START
    _SprX(NumLetters) = X
    _SprY(NumLetters) = Y
    NumLetters = NumLetters + 1
END SUB
SUB AddLetter(Letter AS STRING*1, X AS BYTE, Y AS INT, SprColor AS BYTE) STATIC OVERLOAD
    CALL AddLetter(Letter, CINT(X), Y, SprColor)
END SUB
SUB AddLetter(Letter AS STRING*1, X AS INT, Y AS BYTE, SprColor AS BYTE) STATIC OVERLOAD
    CALL AddLetter(Letter, X, CINT(Y), SprColor)
END SUB
SUB AddLetter(Letter AS STRING*1, X AS BYTE, Y AS BYTE, SprColor AS BYTE) STATIC OVERLOAD
    CALL AddLetter(Letter, CINT(X), CINT(Y), SprColor)
END SUB

FUNCTION MoveSpritesIn AS BYTE() STATIC
    MaxDistance = 0
    FOR ZP_B0 = 0 TO NumLetters-1
        _SprDx(ZP_B0) = RndInt(1, 10)
        _SprDy(ZP_B0) = 11 - _SprDx(ZP_B0)
        IF RndQByte() < 128 THEN
            _SprDx(ZP_B0) = -_SprDx(ZP_B0)
        END IF
        IF RndQByte() < 128 THEN
            _SprDy(ZP_B0) = -_SprDy(ZP_B0)
        END IF
        _SprDistance(ZP_B0) = 0
        DO UNTIL (_SprX(ZP_B0) < -23) OR (_SprX(ZP_B0) > 344) OR (_SprY(ZP_B0) < 0) OR (_SprY(ZP_B0) > 250)
            _SprX(ZP_B0) = _SprX(ZP_B0) - _SprDx(ZP_B0)
            _SprY(ZP_B0) = _SprY(ZP_B0) - _SprDy(ZP_B0)
            _SprDistance(ZP_B0) = _SprDistance(ZP_B0) + 1
        LOOP
        IF _SprDistance(ZP_B0) > MaxDistance THEN
            MaxDistance = _SprDistance(ZP_B0)
        END IF
        IF _SprX(ZP_B0) < 0 THEN
            SPRITE ZP_B0 AT _SprX(ZP_B0) - 8, _SprY(ZP_B0) ON
        ELSE
            SPRITE ZP_B0 AT _SprX(ZP_B0), _SprY(ZP_B0) ON
        END IF
    NEXT ZP_B0

    FOR I AS INT = MaxDistance TO 0 STEP -1
        CALL WaitRasterLine256()
        CALL JoyUpdate()
        IF JoyFire(JOY1) OR JoyFire(JOY2) THEN
            RETURN TRUE
        END IF
        FOR ZP_B0 = 0 TO NumLetters-1
            IF I < _SprDistance(ZP_B0) THEN
                _SprX(ZP_B0) = _SprX(ZP_B0) + _SprDx(ZP_B0)
                _SprY(ZP_B0) = _SprY(ZP_B0) + _SprDy(ZP_B0)
                IF _SprX(ZP_B0) < 0 THEN
                    SPRITE ZP_B0 AT _SprX(ZP_B0) - 8, _SprY(ZP_B0)
                ELSE
                    SPRITE ZP_B0 AT _SprX(ZP_B0), _SprY(ZP_B0)
                END IF
            END IF
        NEXT ZP_B0
    NEXT I
    RETURN FALSE
END FUNCTION

FUNCTION MoveSpritesOut AS BYTE() STATIC
    FOR I AS INT = MaxDistance TO 0 STEP -1
        CALL WaitRasterLine256()
        CALL JoyUpdate()
        IF JoyFire(JOY1) OR JoyFire(JOY2) THEN
            RETURN TRUE
        END IF
        FOR ZP_B0 = 0 TO NumLetters-1
            IF I < _SprDistance(ZP_B0) THEN
                _SprX(ZP_B0) = _SprX(ZP_B0) - _SprDx(ZP_B0)
                _SprY(ZP_B0) = _SprY(ZP_B0) - _SprDy(ZP_B0)
                IF _SprX(ZP_B0) < 0 THEN
                    SPRITE ZP_B0 AT _SprX(ZP_B0) - 8, _SprY(ZP_B0)
                ELSE
                    SPRITE ZP_B0 AT _SprX(ZP_B0), _SprY(ZP_B0)
                END IF
            END IF
        NEXT ZP_B0
    NEXT I
    FOR ZP_B0 = 0 TO NumLetters-1
        SPRITE ZP_B0 OFF
    NEXT ZP_B0
    NumLetters = 0
    RETURN FALSE
END FUNCTION

FUNCTION Scroller AS BYTE(Text AS STRING*96, Y AS BYTE, Speed AS BYTE, Color0 AS BYTE) STATIC
    NumLetters = PEEK(@Text)
    ZP_I0 = 344
    DIM EndX AS INT
    EndX = ZP_I0 + 64 - (CINT(48) * NumLetters)
    ZP_W0 = @Text+1

    FOR ZP_B0 = 0 TO 7
        IF ZP_B0 < NumLetters THEN
            _SprX(ZP_B0) = ZP_B0 * CINT(48)
            ZP_B2 = PEEK(ZP_W0)
            ZP_W0 = ZP_W0 + 1
            IF ZP_B2 = 32 THEN ZP_B2 = 219 ' space
            SPRITE ZP_B0 AT ZP_I0 + _SprX(ZP_B0), Y SHAPE ZP_B2-193+ALPHABET_START COLOR Color0
        ELSE
            SPRITE ZP_B0 OFF
        END IF
    NEXT

    DO
        CALL WaitRasterLine256()
        CALL JoyUpdate()
        IF JoyFire(JOY1) OR JoyFire(JOY2) THEN
            RETURN TRUE
        END IF
        FOR ZP_B0 = 0 TO 7
            IF _SprX(ZP_B0) + ZP_I0 < -24 THEN
                _SprX(ZP_B0) = _SprX(ZP_B0) + 384
                ZP_B2 = PEEK(ZP_W0)
                ZP_W0 = ZP_W0 + 1
                IF ZP_B2 = 32 THEN ZP_B2 = 219 ' space
                SPRITE ZP_B0 SHAPE ZP_B2-193+ALPHABET_START
            END IF
            IF ZP_I0 + _SprX(ZP_B0) > 344 THEN
                SPRITE ZP_B0 OFF
            ELSE
                IF _SprX(ZP_B0) + ZP_I0 < 0 THEN
                    SPRITE ZP_B0 AT ZP_I0 + _SprX(ZP_B0) - 8, Y ON
                ELSE
                    SPRITE ZP_B0 AT ZP_I0 + _SprX(ZP_B0), Y ON
                END IF
            END IF
        NEXT
        ZP_I0 = ZP_I0 - Speed
    LOOP UNTIL ZP_I0 < EndX

    NumLetters = 0
    POKE $d015, 0
    RETURN FALSE
END FUNCTION

SUB LoadGame(FileNr AS BYTE) STATIC
    POKE $fff,FileNr
    ZP_W0 = @SaveFileName(FileNr) + 1

    IF NOT Debug THEN
        ASM
            ldx {ZP_W0}
            ldy {ZP_W0}+1
            jsr $440
load_failed
            bcs load_failed
        END ASM
    END IF
END SUB

SID:
INCBIN "../sfx/Syncosmic.zx0"

'BgColor = $00
Image001_Bitmap:
    INCBIN "../gfx/title001_bitmap.zx0"
Image001_Screen:
    INCBIN "../gfx/title001_screen.zx0"
Image001_Color:
    INCBIN "../gfx/title001_color.zx0"

_SaveFileName:
    DATA AS STRING*8 "save0001"
    DATA AS BYTE 0
    DATA AS STRING*8 "save0002"
    DATA AS BYTE 0
    DATA AS STRING*8 "save0003"
    DATA AS BYTE 0
    DATA AS STRING*8 "autosave"
    DATA AS BYTE 0

SPRITE_DATA:
    INCBIN "../gfx/sprite_font.zx0"
