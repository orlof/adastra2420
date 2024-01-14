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

CALL Text(13, 6, 1, 0, TRUE, "aileon", $c000)
CALL Text(16, 8, 1, 0, FALSE, "mmxxiv", $c000)
CALL Text(13, 11, 1, 0, FALSE, "code", $c000)
CALL Text(20, 11, 1, 0, FALSE, "orlof", $c000)
CALL Text(20, 14, 1, 0, FALSE, "roy batty", $c000)
CALL Text(12, 15, 1, 0, FALSE, "music", $c000)
CALL Text(20, 16, 1, 0, FALSE, "millenium demo", $c000)
CALL Text(11, 19, 1, 0, FALSE, "loader", $c000)
CALL Text(20, 19, 1, 0, FALSE, "krill", $c000)

CALL InstallDriveCode()
CALL InstallLoaderCode()

CALL LoadProgram("intro", CWORD(8192))

DIM _ProgramFilename AS STRING*17 @$5ef
DIM _ProgramAddress AS WORD @$5ed

SUB InstallLoaderCode() STATIC
    'MEMCPY @LOADER_CODE_START, $600, @LOADER_CODE_END - @LOADER_CODE_START
    MEMCPY @BOOTSTRAP_START, $400, @BOOTSTRAP_END - @BOOTSTRAP_START
    EXIT SUB

BOOTSTRAP_START:
    ASM
        ldx #$f6
        txs

        ldx <#({_ProgramFilename}+1)
        ldy >#({_ProgramFilename}+1)
        jsr $600
        bcs * + 5
        jmp ({_ProgramAddress})
_load_program_error
        inc $400
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
