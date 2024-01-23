'INCLUDE "../libs/lib_common.bas"

ASM
TRANSPARENT =  $fe
FLIP        =  $ff
END ASM

REM **********************
REM *     CONSTANTS      *
REM **********************
SHARED CONST MODE_SET   = 1
SHARED CONST MODE_CLEAR = 0
SHARED CONST MODE_FLIP  = $ff

SHARED CONST MODE_TRANSPARENT = $fe

SHARED CONST COLOR_BLACK       = $0
SHARED CONST COLOR_WHITE       = $1
SHARED CONST COLOR_RED         = $2
SHARED CONST COLOR_CYAN        = $3
SHARED CONST COLOR_PURPLE      = $4
SHARED CONST COLOR_GREEN       = $5
SHARED CONST COLOR_BLUE        = $6
SHARED CONST COLOR_YELLOW      = $7
SHARED CONST COLOR_ORANGE      = $8
SHARED CONST COLOR_BROWN       = $9
SHARED CONST COLOR_LIGHTRED    = $a
SHARED CONST COLOR_DARKGRAY    = $b
SHARED CONST COLOR_MIDDLEGRAY  = $c
SHARED CONST COLOR_LIGHTGREEN  = $d
SHARED CONST COLOR_LIGHTBLUE   = $e
SHARED CONST COLOR_LIGHTGRAY   = $f

REM **********************
REM *     VARIABLES      *
REM **********************

DIM _hires_mask0(8) AS BYTE @__hires_mask0 SHARED
DIM _hires_mask1(8) AS BYTE @__hires_mask1 SHARED

DIM _hdraw_end_mask(8) AS BYTE @__hdraw_end_mask
DIM _hdraw_start_mask(8) AS BYTE @__hdraw_start_mask

DIM _bitmap_y_tbl_lo(200) AS BYTE @__bitmap_y_tbl_lo SHARED
DIM _bitmap_y_tbl_hi(200) AS BYTE @__bitmap_y_tbl_hi SHARED

DIM _screen_y_tbl_lo(25) AS BYTE @__screen_y_tbl_lo
DIM _screen_y_tbl_hi(25) AS BYTE @__screen_y_tbl_hi

DIM _color_y_tbl_hi(25) AS BYTE @ __color_y_tbl_hi
DIM _color_y_tbl_lo(25) AS BYTE @ __color_y_tbl_lo

REM **********************
REM *    DECLARATIONS    *
REM **********************
DECLARE FUNCTION GetPixel AS BYTE(x AS WORD, y AS BYTE) SHARED STATIC
DECLARE SUB Plot(x AS WORD, y AS BYTE) SHARED STATIC
DECLARE SUB UnPlot(x AS WORD, y AS BYTE) SHARED STATIC
DECLARE SUB HDraw(x0 AS WORD, x1 AS WORD, y AS BYTE, Mode AS BYTE) SHARED STATIC
DECLARE SUB VDraw(x AS WORD, y0 AS BYTE, y1 AS BYTE, Mode AS BYTE) SHARED STATIC
DECLARE SUB Rect(x0 AS WORD, y0 AS BYTE, x1 AS WORD, y1 AS BYTE, Mode AS BYTE, FillMode AS BYTE) SHARED STATIC

DECLARE SUB SetColorInRect(x0 AS BYTE, y0 AS BYTE, x1 AS BYTE, y1 AS BYTE, Ink AS BYTE, ColorId AS BYTE) SHARED STATIC
DECLARE SUB WaitRasterLine256() SHARED STATIC

REM **********************
REM *     FUNCTIONS      *
REM **********************
SUB CharacterAt(x AS BYTE, y AS BYTE, Char AS STRING*1) SHARED STATIC
    ASM
        sei
        dec 1
    END ASM
    MEMCPY $d000 + ASC(Char) * 8, $e000 + CWORD(y) * 320 + CWORD(x) * 8, 8
    ASM
        inc 1
        cli
    END ASM
END SUB

SUB FillBitmap(Value AS BYTE) SHARED STATIC
    MEMSET $e000, 8000, Value
END SUB

SUB FillColors(BgColor AS BYTE, FgColor AS BYTE) SHARED STATIC
    ASM
        lda {FgColor}
        asl
        asl
        asl
        asl
        ora {BgColor}
        sta {BgColor}
    END ASM
    MEMSET $d800, 1000, BgColor
END SUB

SUB Rect(x0 AS WORD, y0 AS BYTE, x1 AS WORD, y1 AS BYTE, Mode AS BYTE, FillMode AS BYTE) SHARED STATIC
    IF Mode <> MODE_TRANSPARENT THEN
        CALL HDraw(x0, x1, y0, Mode)
        CALL HDraw(x0, x1, y1, Mode)
        CALL VDraw(x0, y0, y1, Mode)
        CALL VDraw(x1, y0, y1, Mode)
    END IF

    IF FillMode <> MODE_TRANSPARENT THEN
        ASM
            inc {x0}
            bne *+4
                inc {x0}+1

            lda {x1}
            bne *+4
                dec {x1}+1

            dec {x1}

            inc {y0}
            dec {y1}
        END ASM
        FOR Y AS BYTE = y0 TO y1
            CALL HDraw(x0, x1, Y, FillMode)
        NEXT Y
    END IF
END SUB

SUB WaitRasterLine256() SHARED STATIC
    ASM
wait1:  bit $d011
        bmi wait1
wait2:  bit $d011
        bpl wait2
    END ASM
END SUB

SUB SetColorInRect(x0 AS BYTE, y0 AS BYTE, x1 AS BYTE, y1 AS BYTE, Ink AS BYTE, ColorId AS BYTE) SHARED STATIC
    ASM
        ldx {y0}
        lda {_screen_y_tbl_hi},x
        sta {ZP_W0}+1
        lda {_screen_y_tbl_lo},x
        sta {ZP_W0}

        ldy {Ink}
        bne _set_color_1

_set_color_0
        lda #%11110000
        sta {ZP_B3}
        lda {ColorId}
        sta {ZP_B2}
        jmp _set_color_init_loops

_set_color_1
        lda #%00001111
        sta {ZP_B3}
        lda {ColorId}
        asl
        asl
        asl
        asl
        sta {ZP_B2}

_set_color_init_loops
        sec
        lda {y1}
        sbc {y0}
        tax

_set_color_y_loop
        ldy {x0}

_set_color_x_loop
        lda ({ZP_W0}),y
        and {ZP_B3}
        ora {ZP_B2}
        sta ({ZP_W0}),y

        iny
        cpy {x1}
        bcc _set_color_x_loop
        beq _set_color_x_loop

        clc
        lda #40
        adc {ZP_W0}
        sta {ZP_W0}

        bcc *+4
            inc {ZP_W0}+1

        dex
        bpl _set_color_y_loop
    END ASM
END SUB

FUNCTION GetPixel AS BYTE(x AS WORD, y AS BYTE) SHARED STATIC
    ASM
        ldx {y}
        lda {_bitmap_y_tbl_lo},x
        sta {ZP_W0}

        lda {_bitmap_y_tbl_hi},x
        clc
        adc {x}+1
        sta {ZP_W0}+1

        lda {x}
        and #7
        tax

        eor {x}
        tay

        lda {_hires_mask1},x
        ldx #0

        and ({ZP_W0}),y
        beq *+3
            dex

        stx {GetPixel}
    END ASM
END FUNCTION

SUB Plot(x AS WORD, y AS BYTE) SHARED STATIC
    ASM
        ldx {y}
        lda {_bitmap_y_tbl_lo},x
        sta {ZP_W0}

        lda {_bitmap_y_tbl_hi},x
        clc
        adc {x}+1
        sta {ZP_W0}+1

        lda {x}
        and #7
        tax

        eor {x}
        tay

        lda {_hires_mask1},x
        ora ({ZP_W0}),y
        sta ({ZP_W0}),y
    END ASM
END SUB

SUB UnPlot(x AS WORD, y AS BYTE) SHARED STATIC
    ASM
        ldx {y}
        lda {_bitmap_y_tbl_lo},x
        sta {ZP_W0}

        lda {_bitmap_y_tbl_hi},x
        clc
        adc {x}+1
        sta {ZP_W0}+1

        lda {x}
        and #7
        tax

        eor {x}
        tay

        lda {_hires_mask0},x
        and ({ZP_W0}),y
        sta ({ZP_W0}),y
    END ASM
END SUB

SUB VDraw(x AS WORD, y0 AS BYTE, y1 AS BYTE, Mode AS BYTE) SHARED STATIC
    ' ZP_W0: Base
    ' ZP_B0: dy
    ' ZP_B1: y1
    ' ZP_B5: x and %11111000
    ASM
_vdraw_smc_init
        lda {Mode}
        beq _vdraw_smc_init_clear
        bpl _vdraw_smc_init_set
_vdraw_smc_init_flip
        lda #$24            ; -> bit <- #$ff
        sta _vdraw_smc0
        lda #$51            ; -> eor <- ($af),y
        sta _vdraw_smc1
        jmp _vdraw_smc_init_end
_vdraw_smc_init_clear
        lda #$49            ; -> eor <- #$ff
        sta _vdraw_smc0
        lda #$31            ; -> and <- ($af),y
        sta _vdraw_smc1
        jmp _vdraw_smc_init_end
_vdraw_smc_init_set
        lda #$24            ; -> bit <- #$ff
        sta _vdraw_smc0
        lda #$11            ; -> ora <- ($af),y
        sta _vdraw_smc1
_vdraw_smc_init_end

_vdraw_init
        lda {y1}
        sta {ZP_B1}
        lda {y0}
        tax
        sta {ZP_B0}

        lda  {_bitmap_y_tbl_hi},x
        clc
        adc {x}+1
        sta {ZP_W0}+1
        lda {_bitmap_y_tbl_lo},x
        sta {ZP_W0}

        lda {x}
        and #7
        tax

        eor {x}

        clc
        adc {ZP_W0}
        sta {ZP_W0}
        bcc *+4
            inc {ZP_W0}+1

        lda {ZP_W0}
        sec
        sbc {ZP_B0}
        sta {ZP_W0}
        bcs *+4
            dec {ZP_W0}+1

        lda {_hires_mask1},x
_vdraw_smc0
        bit $ff
        tax

        ldy {ZP_B0}
_vdraw_loop
        txa
_vdraw_smc1
        ora ({ZP_W0}),y
        sta ({ZP_W0}),y

        cpy {ZP_B1}
        beq _vdraw_end

        iny
        tya
        and #%00000111
        bne _vdraw_loop

        lda {ZP_W0}
        clc
        adc #$38
        sta {ZP_W0}
        lda {ZP_W0}+1
        adc #1
        sta {ZP_W0}+1

        jmp _vdraw_loop
_vdraw_end
    END ASM
END SUB

SUB HDraw(x0 AS WORD, x1 AS WORD, y AS BYTE, Mode AS BYTE) SHARED STATIC
    ' ZP_W0: Base
    ' ZP_B0: y & 7
    ' ZP_B1: x0
    ' ZP_B2: x1
    ' ZP_B3: Count
    ' ZP_B4: End Mask
    ASM
_hdraw_init
        ldx {Mode}
        inx

        lda _hdraw_mode_lo,x
        sta {ZP_W1}
        lda _hdraw_mode_hi,x
        sta {ZP_W1}+1

_hdraw_init_end
        ldx {y}
        lda {_bitmap_y_tbl_lo},x
        sta {ZP_W0}

        ; calculate DX
        lda {x0}+1
        ror
        lda {x0}
        sta {ZP_B1}
        ror
        lsr
        lsr
        sta {ZP_B4}

        lda {x1}+1
        ror
        lda {x1}
        sta {ZP_B2}
        ror
        lsr
        lsr

        sec
        sbc {ZP_B4}

_hdraw_start_x0
        sta {ZP_B3}

        ; calc base hi
        lda  {_bitmap_y_tbl_hi},x
        clc
        adc {x0}+1
        sta {ZP_W0}+1

        ; store end mask
        lda {ZP_B2}
        and #%00000111
        tax
        lda {_hdraw_end_mask},x
        sta {ZP_B4}

        ; calc base offset
        lda {ZP_B1}
        and #%11111000
        tay

        lda {ZP_B1}

_hdraw_start_mask
        ; load start mask
        and #7
        tax
        lda {_hdraw_start_mask},x

        ; load counter
        ldx {ZP_B3}
        beq _hdraw_end

_hdraw_start_loop
        ; draw byte
        jmp ({ZP_W1})

_hdraw_set
        ora ({ZP_W0}),y
        sta ({ZP_W0}),y

_hdraw_shared_loop
        ;addr += 8
        tya
        clc
        adc #8
        tay
        bcc *+4
            inc {ZP_W0}+1

        lda #$ff

        ;loop until addr = end
        dex
        bmi _hdraw_end
        bne *+4
            and {ZP_B4}
        jmp ({ZP_W1})

_hdraw_clear
        eor #$ff
        and ({ZP_W0}),y
        sta ({ZP_W0}),y

        jmp _hdraw_shared_loop

_hdraw_flip
        eor ({ZP_W0}),y
        sta ({ZP_W0}),y

        jmp _hdraw_shared_loop

_hdraw_mode_hi
        .byte #>_hdraw_flip, #>_hdraw_clear, #>_hdraw_set
_hdraw_mode_lo
        .byte #<_hdraw_flip, #<_hdraw_clear, #<_hdraw_set

_hdraw_end
    END ASM
END SUB

__hdraw_start_mask:
DATA AS BYTE %11111111, %01111111, %00111111, %00011111, %00001111, %00000111, %00000011, %00000001
__hdraw_end_mask:
DATA AS BYTE %10000000, %11000000, %11100000, %11110000, %11111000, %11111100, %11111110, %11111111

__color_y_tbl_hi:
DATA AS BYTE $d8, $d8, $d8, $d8, $d8, $d8, $d8, $d9, $d9, $d9, $d9, $d9, $d9, $da, $da, $da
DATA AS BYTE $da, $da, $da, $da, $db, $db, $db, $db, $db
__color_y_tbl_lo:
DATA AS BYTE $00, $28, $50, $78, $a0, $c8, $f0, $18, $40, $68, $90, $b8, $e0, $08, $30, $58
DATA AS BYTE $80, $a8, $d0, $f8, $20, $48, $70, $98, $c0

__hires_mask0:
DATA AS BYTE $7f, $bf, $df, $ef, $f7, $fb, $fd, $fe
__hires_mask1:
DATA AS BYTE $80, $40, $20, $10, $08, $04, $02, $01

__petscii_to_screencode:
DATA AS BYTE $80, $00, $c0, $e0, $40, $c0, $80, $80

__bitmap_y_tbl_hi:
DATA AS BYTE $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
DATA AS BYTE $e1, $e1, $e1, $e1, $e1, $e1, $e1, $e1
DATA AS BYTE $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2
DATA AS BYTE $e3, $e3, $e3, $e3, $e3, $e3, $e3, $e3
DATA AS BYTE $e5, $e5, $e5, $e5, $e5, $e5, $e5, $e5
DATA AS BYTE $e6, $e6, $e6, $e6, $e6, $e6, $e6, $e6
DATA AS BYTE $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7
DATA AS BYTE $e8, $e8, $e8, $e8, $e8, $e8, $e8, $e8
DATA AS BYTE $ea, $ea, $ea, $ea, $ea, $ea, $ea, $ea
DATA AS BYTE $eb, $eb, $eb, $eb, $eb, $eb, $eb, $eb
DATA AS BYTE $ec, $ec, $ec, $ec, $ec, $ec, $ec, $ec
DATA AS BYTE $ed, $ed, $ed, $ed, $ed, $ed, $ed, $ed
DATA AS BYTE $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ef
DATA AS BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
DATA AS BYTE $f1, $f1, $f1, $f1, $f1, $f1, $f1, $f1
DATA AS BYTE $f2, $f2, $f2, $f2, $f2, $f2, $f2, $f2
DATA AS BYTE $f4, $f4, $f4, $f4, $f4, $f4, $f4, $f4
DATA AS BYTE $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5
DATA AS BYTE $f6, $f6, $f6, $f6, $f6, $f6, $f6, $f6
DATA AS BYTE $f7, $f7, $f7, $f7, $f7, $f7, $f7, $f7
DATA AS BYTE $f9, $f9, $f9, $f9, $f9, $f9, $f9, $f9
DATA AS BYTE $fa, $fa, $fa, $fa, $fa, $fa, $fa, $fa
DATA AS BYTE $fb, $fb, $fb, $fb, $fb, $fb, $fb, $fb
DATA AS BYTE $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
DATA AS BYTE $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe

DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc
DATA AS BYTE $bc, $bc, $bc, $bc, $bc, $bc, $bc, $bc

__bitmap_y_tbl_lo:
DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07
DATA AS BYTE $40, $41, $42, $43, $44, $45, $46, $47
DATA AS BYTE $80, $81, $82, $83, $84, $85, $86, $87
DATA AS BYTE $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7

DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07
DATA AS BYTE $40, $41, $42, $43, $44, $45, $46, $47
DATA AS BYTE $80, $81, $82, $83, $84, $85, $86, $87
DATA AS BYTE $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7

DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07
DATA AS BYTE $40, $41, $42, $43, $44, $45, $46, $47
DATA AS BYTE $80, $81, $82, $83, $84, $85, $86, $87
DATA AS BYTE $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7

DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07
DATA AS BYTE $40, $41, $42, $43, $44, $45, $46, $47
DATA AS BYTE $80, $81, $82, $83, $84, $85, $86, $87
DATA AS BYTE $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7

DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07
DATA AS BYTE $40, $41, $42, $43, $44, $45, $46, $47
DATA AS BYTE $80, $81, $82, $83, $84, $85, $86, $87
DATA AS BYTE $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7

DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07
DATA AS BYTE $40, $41, $42, $43, $44, $45, $46, $47
DATA AS BYTE $80, $81, $82, $83, $84, $85, $86, $87
DATA AS BYTE $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7

DATA AS BYTE $00, $01, $02, $03, $04, $05, $06, $07

DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00

__screen_y_tbl_hi:
DATA AS BYTE $c8, $c8, $c8, $c8, $c8, $c8, $c8, $c9, $c9, $c9, $c9, $c9, $c9, $ca, $ca, $ca
DATA AS BYTE $ca, $ca, $ca, $ca, $cb, $cb, $cb, $cb, $cb
__screen_y_tbl_lo:
DATA AS BYTE $00, $28, $50, $78, $a0, $c8, $f0, $18, $40, $68, $90, $b8, $e0, $08, $30, $58
DATA AS BYTE $80, $a8, $d0, $f8, $20, $48, $70, $98, $c0
