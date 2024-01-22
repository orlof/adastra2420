'INCLUDE "../libs/lib_common.bas"
'INCLUDE "../libs/lib_space_gfx.bas"


CONST NUM_STARS = 24
ASM
NUM_STARS = 24
END ASM

DIM x(NUM_STARS) AS BYTE
DIM y(NUM_STARS) AS BYTE
DIM addr_y_hi(NUM_STARS) AS BYTE
DIM addr_y_lo(NUM_STARS) AS BYTE
DIM addr_x(NUM_STARS) AS BYTE

SUB BackgroundInit() SHARED STATIC
    FOR ZP_B0 = 0 TO NUM_STARS-1
        x(ZP_B0) = RNDB()
        y(ZP_B0) = RNDB()
        addr_y_hi(ZP_B0) = _bitmap_y_tbl_hi(0)
        addr_y_lo(ZP_B0) = _bitmap_y_tbl_lo(0)
        addr_x(ZP_B0) = 0
    NEXT ZP_B0
END SUB

SUB BackgroundUpdate() SHARED STATIC
    ASM
        ldx #NUM_STARS-1                     ;init loop 23 to 0
background_update_loop
        stx {ZP_B0}                 ;loop counter
        lda {addr_y_lo},x                ;clear old location
        sta {ZP_W0}
        lda {addr_y_hi},x
        sta {ZP_W0}+1
        ldy {addr_x},x
        lda #0
        sta ({ZP_W0}),y

        sec                         ;y = player.y + star.y
        lda {y},x
        sbc {PlayerY}+1
        tay

        lda {_bitmap_y_tbl_lo},y      ;addr by y
        sta {ZP_W0}
        lda {_bitmap_y_tbl_hi},y
        sta {ZP_W0}+1

        sec                         ;x = player.x + star.x
        lda {x},x
        sbc {PlayerX}+1
        sta {ZP_B1}

        and #%11111000
        sta {addr_x},x              ;addr offset by x
        tay

        lda {ZP_B1}
        and #%00000111
        tax

        lda {_hires_mask1},x
        sta ({ZP_W0}),y

        ldx {ZP_B0}

        lda {ZP_W0}
        sta {addr_y_lo},x
        lda {ZP_W0}+1
        sta {addr_y_hi},x

        dex
        bpl background_update_loop
    END ASM
END SUB
