
SUB SidStop() STATIC SHARED
    ASM
        ; Reset SID
        lda #$ff
reset_sid_loop:
        ldx #$17
reset_sid_0:
        sta $d400,x
        dex
        bpl reset_sid_0
        tax
        bpl reset_sid_1
        lda #$08
        bpl reset_sid_loop
reset_sid_1:
reset_sid_2:
        bit $d011
        bpl reset_sid_2
reset_sid_3:
        bit $d011
        bmi reset_sid_3
        eor #$08
        beq reset_sid_loop

        lda #$0f
        sta $d418
the_end
    END ASM
END SUB
