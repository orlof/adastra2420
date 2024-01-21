INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_space_gfx.bas"





ASM
    lda $d011
    and #%10111111
    sta $d011
END ASM

FOR W = 0 TO 199
    CALL HDraw(0, 255, W, MODE_FLIP)
    CALL HDraw(0, 255, 199-W, MODE_FLIP)
NEXT

DO
LOOP



GENERIC_CHARSET_START:
INCBIN "../gfx/generic_charset.bin"
