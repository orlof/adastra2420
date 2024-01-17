'INCLUDE "ext/lib_memory.bas"

FUNCTION AngleToOrigo AS BYTE(x AS BYTE, y AS BYTE) SHARED STATIC
    ASM
        lda  {x}
        bpl x_abs_done
        
        eor #$ff
        clc
        adc #1
        
        bpl x_abs_done
        lda #127

x_abs_done
        sta {ZP_B0}

        lda  {y}
        bpl y_abs_done
        
        eor #$ff
        clc
        adc #1
        
        bpl y_abs_done
        lda #127

y_abs_done
        sta {ZP_B1}

        lda {ZP_B0}
        cmp {ZP_B1}
        bcc _x_lt_y
_x_gt_y
        lsr
        cmp {ZP_B1}
        bcs _x_gt_2y
_x_lt_2y
        lda #3
        jmp angle_done

_x_gt_2y
        lsr
        cmp {ZP_B1}
        bcs _x_gt_4y
_x_lt_4y
        lda #2
        jmp angle_done

_x_gt_4y
        lsr
        cmp {ZP_B1}
        bcs _x_gt_8y
_x_lt_8y
        lda #1
        jmp angle_done

_x_gt_8y
        lda #0
        jmp angle_done

_x_lt_y
        asl
        cmp {ZP_B1}
        bcc _2x_lt_y
_2x_gt_y
        lda #5
        jmp angle_done

_2x_lt_y
        asl
        cmp {ZP_B1}
        bcc _4x_lt_y
_4x_gt_y
        lda #6
        jmp angle_done

_4x_lt_y
        asl
        cmp {ZP_B1}
        bcc _8x_lt_y
_8x_gt_y
        lda #7
        jmp angle_done

_8x_lt_y
        lda #8
        
angle_done
        bit  {x}
        bmi left_quadrant

right_quadrant
        bit  {y}
        bmi quadrant_1

quadrant_4
        sta {ZP_B0}
        sec
        lda #15
        sbc {ZP_B0}
        jmp exit

quadrant_1
        clc
        adc #16
        jmp exit

left_quadrant
        bit  {y}
        bpl quadrant_3
quadrant_2
        sta {ZP_B0}
        sec
        lda #31
        sbc {ZP_B0}
        jmp exit

quadrant_3

exit
        sta {ZP_B0}
    END ASM
    RETURN ZP_B0
END FUNCTION
