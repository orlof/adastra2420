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

CALL Text(13, 6, 1, 0, TRUE,  "aileon", CHAR_MEMORY)
CALL Text(16, 9, 1, 0, FALSE, "mmxxiv", CHAR_MEMORY)
CALL Text(2, 11, 1, 0, FALSE, "           code    orlof", CHAR_MEMORY)
CALL Text(2, 13, 1, 0, FALSE, "       loader        krill", CHAR_MEMORY)
CALL Text(2, 15, 1, 0, FALSE, "      music            roy batty", CHAR_MEMORY)
CALL Text(2, 17, 1, 0, FALSE, "xc=basic3                fekete csaba", CHAR_MEMORY)

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
        jmp _load_program_error
    END ASM
BOOTSTRAP_END:
END SUB

SUB InstallDriveCode() STATIC
    DIM ErrorCode AS BYTE
    ErrorCode = 0

    ASM
        jsr $4000
        bcc no_error
        lda $ff
        sta {ErrorCode}
no_error
    END ASM

    IF ErrorCode THEN
        CALL ResetScreen()
        PRINT "error"
        END
    END IF
END SUB

LOADER_START:
    INCBIN "../loader/loader-c64.bin"
LOADER_END:
