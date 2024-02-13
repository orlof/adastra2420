OPTION FASTINTERRUPT

DECLARE SUB InstallDriveCode() STATIC
DECLARE SUB InstallLoaderCode() STATIC

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_gfx.bas"

BORDER COLOR_BLACK
CALL SetVideoBank(3)
CALL SetScreenMemory(2)
CALL SetGraphicsMode(STANDARD_BITMAP_MODE)
CALL SetBitmapMemory(1)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)
CALL FillBitmap(0)
SCREEN 2

CALL Text(5, 7, 1, 0, TRUE,  "ad astra", CHAR_MEMORY)
CALL Text(5, 8, 1, 0, FALSE, "2420", CHAR_MEMORY)
'CALL Text(5, 8, 1, 0, FALSE, "mmxxiv", CHAR_MEMORY)
CALL Text(5, 11, 1, 0, FALSE, "code.............orlof", CHAR_MEMORY)
CALL Text(5, 13, 1, 0, FALSE, "music............roy batty", CHAR_MEMORY)
CALL Text(5, 15, 1, 0, FALSE, "loader...........krill", CHAR_MEMORY)
CALL Text(5, 17, 1, 0, FALSE, "xc=basic3........fekete csaba", CHAR_MEMORY)
CALL Text(5, 19, 1, 0, FALSE, "play test........timppa and spock", CHAR_MEMORY)

CALL InstallDriveCode()
CALL InstallLoaderCode()

CALL LoadProgram("menu", CWORD(8192))

SUB InstallLoaderCode() STATIC
    MEMCPY @LOADER_START, $440, @LOADER_END - @LOADER_START
    MEMCPY @BOOTSTRAP_START, $400, @BOOTSTRAP_END - @BOOTSTRAP_START
    EXIT SUB

BOOTSTRAP_START:
    ASM
        ldx #$f6
        txs

        ldx <#({_ProgramFilename}+1)
        ldy >#({_ProgramFilename}+1)
        jsr $440
        bcs * + 5
        jmp ({_ProgramAddress})
_load_program_error
        sta $fb
        jmp _load_program_error
    END ASM
BOOTSTRAP_END:
END SUB

SUB InstallDriveCode() STATIC
    DIM ErrorCode AS BYTE @$fb
    ErrorCode = 0

    ASM
        jsr $4000
        bcc *+4
            sta {ErrorCode}
    END ASM

    IF ErrorCode THEN
        CALL ResetScreen()
        PRINT "drive error"
        END
    END IF
END SUB

LOADER_START:
    INCBIN "../loader/loader-c64.bin"
LOADER_END:
