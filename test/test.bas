OPTION FASTINTERRUPT
SYSTEM INTERRUPT OFF

ON TIMER 17095 GOSUB IRQ
TIMER INTERRUPT ON

    ASM
            LDA #fname_end-fname
            LDX #<fname
            LDY #>fname
            JSR $FFBD       ; call SETNAM
            LDA #$01
            LDX $BA         ; last used device number
            BNE *+4
                LDX #$08    ; default to device 8
            LDY #$01        ; $01 means: load to address stored in file
            JSR $FFBA       ; call SETLFS

            LDA #$00        ; $00 means: load to memory (not verify)
            JSR $FFD5       ; call LOAD
            BCC fname_end   ; if carry set, a load error has happened
            JMP *

fname
            dc "DATA"
fname_end
    END ASM

    TIMER INTERRUPT OFF
    MEMSET $400, 1000, 32
    FOR T AS BYTE = 0 TO 7
        SPRITE T AT 100,100 ON
    NEXT T

    ASM
            LDA #fname_end2-fname2
            LDX #<fname2
            LDY #>fname2
            JSR $FFBD       ; call SETNAM
            LDA #$01
            LDX $BA         ; last used device number
            BNE *+4
                LDX #$08    ; default to device 8
            LDY #$01        ; $01 means: load to address stored in file
            JSR $FFBA       ; call SETLFS

            LDA #$00        ; $00 means: load to memory (not verify)
            JSR $FFD5       ; call LOAD
            BCC fname_end2   ; if carry set, a load error has happened
            JMP *

fname2
            dc "DATA2"
fname_end2
    END ASM

    MEMSET $400, 1000, 32

    END


IRQ:
    ASM
        inc $400
    END ASM
RETURN
