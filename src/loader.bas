OPTION FASTINTERRUPT
SYSTEM INTERRUPT OFF

DECLARE SUB InstallDriveCode() STATIC
DECLARE SUB InstallLoaderCode() STATIC

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_gfx.bas"

BORDER COLOR_BLACK
CALL ScreenOff()
CALL SetVideoBank(3)
CALL SetScreenMemory(2)
CALL SetGraphicsMode(STANDARD_BITMAP_MODE)
CALL SetBitmapMemory(1)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)
CALL FillBitmap(0)
SCREEN 2

CALL Text(5, 7, 1, 0, TRUE,  "ad astra", CHAR_MEMORY)
CALL Text(5, 8, 1, 0, FALSE, "2420", CHAR_MEMORY)
CALL Text(5, 11, 1, 0, FALSE, "code.............orlof", CHAR_MEMORY)
CALL Text(5, 13, 1, 0, FALSE, "music............roy batty", CHAR_MEMORY)
CALL Text(5, 15, 1, 0, FALSE, "loader...........krill", CHAR_MEMORY)
CALL Text(5, 17, 1, 0, FALSE, "xc=basic3........fekete csaba", CHAR_MEMORY)
CALL Text(5, 19, 1, 0, FALSE, "play test........timppa and spock", CHAR_MEMORY)

CALL ScreenOn()

CALL InstallDriveCode()
CALL InstallLoaderCode()

Debug = FALSE

CALL LoadProgram("menu", CWORD(8192))

SUB InstallLoaderCode() STATIC
    MEMCPY @BOOTSTRAP_START, $400, @BOOTSTRAP_END - @BOOTSTRAP_START
    IF UseDiscTurbo THEN
        MEMCPY @LOADER_START, $440, @LOADER_END - @LOADER_START
    ELSE
        MEMCPY @KERNEL_LOADER_START, $440, @KERNEL_LOADER_END - @KERNEL_LOADER_START
    END IF
    EXIT SUB

BOOTSTRAP_START:
    ASM
        ldx #$f6
        txs

        lda {_ProgramFilename}
        ldx <#({_ProgramFilename}+1)
        ldy >#({_ProgramFilename}+1)
        jsr $440
        bcs * + 5
            jmp ({_ProgramAddress})

        sta $fb
        jmp *
    END ASM
BOOTSTRAP_END:

KERNEL_LOADER_START:
    ASM
        bit $ee

        jsr $ffbd     ; call SETNAM
        lda #$01      ; logical file number
        ldx $ba       ; last used device number
        bne *+4
            ldx #$08  ; default to device 8

        ldy #$01      ; $01 means: load to address stored in file
        jsr $ffba     ; call SETLFS

        lda #$00      ; $00 means: load to memory (not verify)
        jsr $ffd5     ; call LOAD
        bcs *         ; if carry set, a load error has happened
        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

        rts
    END ASM
KERNEL_LOADER_END:
    END
END SUB

SUB InstallDriveCode() STATIC
    UseDiscTurbo = TRUE

    ASM
        jsr $4000
        bcc install_drive_code_ok
            lda #$00
            sta {UseDiscTurbo}
install_drive_code_ok
    END ASM
END SUB

LOADER_START:
    INCBIN "../loader/loader-c64.bin"
LOADER_END:
