ASM
        sta $400
        LDA #fname_end-fname
        LDX #<fname
        LDY #>fname
        JSR $FFBD     ; call SETNAM
        LDA #$01
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$01      ; not $01 means: load to address stored in file
        JSR $FFBA     ; call SETLFS

        LDA #$00      ; $00 means: load to memory (not verify)
        JSR $FFD5     ; call LOAD
        BCS .error    ; if carry set, a load error has happened
        jmp *
.error
        ; Accumulator contains BASIC error code
        sta $fb

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

        jmp *

fname:  dc "DATA"
fname_end:
END ASM
