OPTION FASTINTERRUPT
SYSTEM INTERRUPT OFF

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_str.bas"
INCLUDE "../libs/lib_gfx.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_rnd.bas"

DECLARE SUB SetupScreen() STATIC

CALL SetupScreen()




SUB SetupScreen() STATIC
    BORDER COLOR_BLACK
    BACKGROUND COLOR_BLACK

    'CALL SetVideoBank(3)
    ASM
        lda #0          ;bank=3
        sta $dd00
    END ASM

    CALL SetBitmapMemory(1)
    CALL SetScreenMemory(2)
    SCREEN 2
    MEMSET $c800, 1000, 1

    CALL SetGraphicsMode(STANDARD_BITMAP_MODE)
END SUB