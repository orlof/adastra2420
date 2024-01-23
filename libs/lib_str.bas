
DECLARE SUB StringBuilder_Init() STATIC SHARED
DECLARE SUB StringBuilder_AppendLong(Value AS LONG) STATIC SHARED
DECLARE SUB StringBuilder_AppendWord(Value AS WORD) STATIC SHARED
DECLARE SUB StringBuilder_AppendByte(Value AS BYTE) STATIC SHARED
DECLARE SUB StringBuilder_AppendString(Value AS String*16) STATIC SHARED
DECLARE SUB Byte2String(Value AS Byte, Pad AS BYTE, MaxLen AS BYTE, ZeroOffset AS BYTE) STATIC SHARED
DECLARE SUB Word2String(Value AS WORD, Pad AS BYTE, MaxLen AS BYTE, ZeroOffset AS BYTE) STATIC SHARED
DECLARE SUB Long2String(Value AS LONG, Pad AS BYTE, MaxLen AS BYTE, ZeroOffset AS BYTE) STATIC SHARED
DECLARE FUNCTION GetByte2String AS STRING*3(Value AS BYTE, MaxLen AS BYTE) STATIC SHARED
DECLARE FUNCTION GetWord2String AS STRING*5(Value AS WORD, MaxLen AS BYTE) STATIC SHARED
DECLARE FUNCTION GetLong2String AS STRING*8(Value AS LONG, MaxLen AS BYTE) STATIC SHARED

DIM PrDecTens(7) AS LONG @_PrDecTens
DIM DecStr AS STRING*8 @_DecStr SHARED
DIM DecByte(8) AS BYTE @_DecByte SHARED
DIM StringBuilder AS STRING*40 SHARED
DIM OriginalPad AS BYTE

SUB StringBuilder_Init() STATIC SHARED
    StringBuilder = ""
END SUB

SUB StringBuilder_AppendLong(Value AS LONG) STATIC SHARED
    CALL Long2String(Value, 32, 7, $30)
    StringBuilder = StringBuilder + DecStr
END SUB

SUB StringBuilder_AppendWord(Value AS WORD) STATIC SHARED
    CALL Word2String(Value, 32, 5, $30)
    StringBuilder = StringBuilder + DecStr
END SUB

SUB StringBuilder_AppendByte(Value AS BYTE) STATIC SHARED
    CALL Byte2String(Value, 32, 3, $30)
    StringBuilder = StringBuilder + DecStr
END SUB

SUB StringBuilder_AppendString(Value AS String*16) STATIC SHARED
    StringBuilder = StringBuilder + Value
END SUB

FUNCTION GetByte2String AS STRING*3(Value AS BYTE, MaxLen AS BYTE) STATIC SHARED
    CALL Byte2String(Value, 32, MaxLen, $30)
    GetByte2String = DecStr
END FUNCTION

FUNCTION GetWord2String AS STRING*5(Value AS WORD, MaxLen AS BYTE) STATIC SHARED
    CALL Word2String(Value, 32, MaxLen, $30)
    GetWord2String = DecStr
END FUNCTION

FUNCTION GetLong2String AS STRING*8(Value AS LONG, MaxLen AS BYTE) STATIC SHARED
    CALL Long2String(Value, 32, MaxLen, $30)
    GetLong2String = DecStr
END FUNCTION

SUB Byte2String(Value AS Byte, Pad AS BYTE, MaxLen AS BYTE, ZeroOffset AS BYTE) STATIC SHARED
    OriginalPad = Pad
    MaxLen = 3 * (MaxLen - 1)
    ASM
        ; ---------------------------
        ; Print 8-bit decimal number
        ; ---------------------------
        ; On entry, {Value}=number to print
        ;           {Pad}=0 or {Pad} character (eg '0' or ' ')
        ; On entry at PrDec8Lp1,
        ;           Y=(number of digits)*3-3, eg 21 for 8 digits
        ; On exit,  A,X,Y,{Value},{Pad} corrupted
        ; Size      69 bytes
        ; -----------------------------------------------------------------
        lda #0
        sta {DecStr}
PrDec8
        ldy {MaxLen}                                      ; Offset to powers of ten
PrDec8Lp1
        ldx #$ff
        sec                                         ; Start with digit=-1
PrDec8Lp2
        lda {Value}+0
        sbc {PrDecTens}+0,y
        sta {Value}+0                                   ; Subtract current tens

        inx
        bcs PrDec8Lp2                              ; Loop until <0

        lda {Value}+0
        adc {PrDecTens}+0,y
        sta {Value}+0                                   ; Add current tens back in

        txa
        bne PrDec8Digit                            ; Not zero, print it

        lda {Pad}
        cmp #$ff
        bne PrDec8Print
        beq PrDec8Next                             ; {Pad}<>0, use it
PrDec8Digit
        ldx #$00
        stx {Pad}                                   ; No more zero padding
        clc
        adc {ZeroOffset}
PrDec8Print
        ldx {DecStr}
        inx
        sta {DecStr},x                                   ; Print digit
        stx {DecStr}
PrDec8Next
        dey
        dey
        dey
        bpl PrDec8Lp1                              ; Loop for next digit

        ldx {DecStr}
        lda {DecStr},x
        cmp {OriginalPad}
        bne PrDec8Done
        lda {ZeroOffset}
        sta {DecStr},x
PrDec8Done
    END ASM
END SUB

SUB Word2String(Value AS WORD, Pad AS BYTE, MaxLen AS BYTE, ZeroOffset AS BYTE) STATIC SHARED
    OriginalPad = Pad
    MaxLen = 3 * (MaxLen - 1)
    ASM
        ; ---------------------------
        ; Print 16-bit decimal number
        ; ---------------------------
        ; On entry, {Value}=number to print
        ;           {Pad}=0 or {Pad} character (eg '0' or ' ')
        ; On entry at PrDec16Lp1,
        ;           Y=(number of digits)*3-3, eg 21 for 8 digits
        ; On exit,  A,X,Y,{Value},{Pad} corrupted
        ; Size      69 bytes
        ; -----------------------------------------------------------------
        lda #0
        sta {DecStr}
PrDec16
        ldy {MaxLen}                                    ; Offset to powers of ten
PrDec16Lp1
        ldx #$ff
        sec                                             ; Start with digit=-1
PrDec16Lp2
        lda {Value}+0
        sbc {PrDecTens}+0,y
        sta {Value}+0                                   ; Subtract current tens

        lda {Value}+1
        sbc {PrDecTens}+1,y
        sta {Value}+1

        inx
        bcs PrDec16Lp2                              ; Loop until <0

        lda {Value}+0
        adc {PrDecTens}+0,y
        sta {Value}+0                                   ; Add current tens back in

        lda {Value}+1
        adc {PrDecTens}+1,y
        sta {Value}+1

        txa
        bne PrDec16Digit                            ; Not zero, print it

        lda {Pad}
        cmp #$ff
        bne PrDec16Print
        beq PrDec16Next                             ; {Pad}<>0, use it
PrDec16Digit
        ldx #$00
        stx {Pad}                                   ; No more zero padding
        clc
        adc {ZeroOffset}                                     ; Print this digit
PrDec16Print
        ldx {DecStr}
        inx
        sta {DecStr},x                                   ; Print digit
        stx {DecStr}
PrDec16Next
        dey
        dey
        dey
        bpl PrDec16Lp1                              ; Loop for next digit

        ldx {DecStr}
        lda {DecStr},x
        cmp {OriginalPad}
        bne PrDec16Done
        lda {ZeroOffset}
        sta {DecStr},x
PrDec16Done
    END ASM
END SUB

SUB Long2String(Value AS LONG, Pad AS BYTE, MaxLen AS BYTE, ZeroOffset AS BYTE) STATIC SHARED
    MaxLen = 3 * (MaxLen - 1)
    ASM
        ; ---------------------------
        ; Print 24-bit decimal number
        ; ---------------------------
        ; On entry, {Value}=number to print
        ;           {Pad}=0 or {Pad} character (eg '0' or ' ')
        ; On entry at PrDec24Lp1,
        ;           Y=(number of digits)*3-3, eg 21 for 8 digits
        ; On exit,  A,X,Y,{Value},{Pad} corrupted
        ; Size      98 bytes
        ; -----------------------------------------------------------------
        lda #0
        sta {DecStr}
PrDec24
        ldy {MaxLen}                                         ; Offset to powers of ten
PrDec24Lp1
        ldx #$ff
        sec                                             ; Start with digit=-1
PrDec24Lp2
        lda {Value}+0
        sbc {PrDecTens}+0,y
        sta {Value}+0                                   ; Subtract current tens

        lda {Value}+1
        sbc {PrDecTens}+1,y
        sta {Value}+1

        lda {Value}+2
        sbc {PrDecTens}+2,y
        sta {Value}+2

        inx
        bcs PrDec24Lp2                                  ; Loop until <0

        lda {Value}+0
        adc {PrDecTens}+0,y
        sta {Value}+0                                   ; Add current tens back in

        lda {Value}+1
        adc {PrDecTens}+1,y
        sta {Value}+1

        lda {Value}+2
        adc {PrDecTens}+2,y
        sta {Value}+2

        txa
        bne PrDec24Digit                            ; Not zero, print it

        lda {Pad}
        cmp #$ff
        bne PrDec24Print
        beq PrDec24Next                             ; {Pad}<>0, use it
PrDec24Digit
        ldx #$00
        stx {Pad}                                   ; No more zero padding
        clc
        adc {ZeroOffset}                                     ; Print this digit
PrDec24Print
        ldx {DecStr}
        inx
        sta {DecStr},x                                   ; Print digit
        stx {DecStr}
PrDec24Next
        dey
        dey
        dey
        bpl PrDec24Lp1                              ; Loop for next digit

        ldx {DecStr}
        lda {DecStr},x
        cmp #$20
        bne PrDec24Done
        lda #$30
        sta {DecStr},x

PrDec24Done
    END ASM
END SUB

_DecStr:
    DATA AS BYTE 0
_DecByte:
    DATA AS BYTE 0,0,0,0,0,0,0,0

_PrDecTens:
    DATA AS LONG 1
    DATA AS LONG 10
    DATA AS LONG 100
    DATA AS LONG 1000
    DATA AS LONG 10000
    DATA AS LONG 100000
    DATA AS LONG 1000000
