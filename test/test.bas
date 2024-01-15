OPTION FASTINTERRUPT
SYSTEM INTERRUPT OFF


TYPE SaveParamsType
    FileName AS WORD
    From AS WORD
    Length AS WORD
    LoadAddress AS WORD
    DriveCodeBuffer AS WORD
END TYPE

DIM SaveParams AS SaveParamsType
SaveParams.FileName = @_SaveFileName(0)+1
SaveParams.From = $0800
SaveParams.Length = $800
SaveParams.LoadAddress = $0800
SaveParams.DriveCodeBuffer = $b300

ASM
    jsr $4000
    bcs error
    lda #0
    sta $c000
    jmp exit
error:
    sta $c000
exit:
END ASM

PRINT "drive code loaded"

MEMCPY @LOADER_START, $440, @LOADER_END - @LOADER_START
MEMCPY @SAVE_START, $bb00, 1211

ON TIMER 17095 GOSUB irq
TIMER INTERRUPT ON

DIM Addr AS WORD
Addr = @SaveParams


ASM
    ldx {Addr}
    ldy {Addr}+1

    jsr $bb00
    bcs error2
    lda #0
    sta $c001
    jmp exit2
error2:
    sta $c001
exit2:
END ASM

print "file saved"

DO
LOOP


irq:
    ASM
        inc $d020
    END ASM
    RETURN

FileName:
    DATA AS STRING*8 "savefile"
    DATA AS BYTE 0

LOADER_START:
INCBIN "../loader/loader-c64.bin"
LOADER_END:

SAVE_START:
INCBIN "../loader/save-c64.bin"
SAVE_END:

_SaveFileName:
DATA AS STRING*8 "savefile"
DATA AS BYTE 0
DATA AS STRING*8 "save0001"
DATA AS BYTE 0
DATA AS STRING*8 "save0002"
DATA AS BYTE 0
DATA AS STRING*8 "save0003"
DATA AS BYTE 0
DATA AS STRING*8 "save0004"
DATA AS BYTE 0
DATA AS STRING*8 "save0005"
DATA AS BYTE 0

ORIGIN $4000
INCBIN "../loader/install-c64.bin"
