REM  COMMON DEFINITIONS AND SUBROUTINES
REM  SHOULD BE INCLUDED BY ALL SUB-PROGRAMS

SHARED CONST TRUE = $ff
SHARED CONST FALSE = 0

SHARED CONST CHAR_MEMORY = $d000

SHARED CONST COMP_GOLD   = 0
SHARED CONST COMP_METAL  = 1
SHARED CONST COMP_FUEL   = 2
SHARED CONST COMP_OXYGEN = 3
SHARED CONST COMP_ARMOR  = 4

SHARED CONST SUBSYSTEM_WEAPON = 0
SHARED CONST SUBSYSTEM_ENGINE = 1
SHARED CONST SUBSYSTEM_GYRO = 2

SHARED CONST GAMESTATE_STARTING         = %00000001
SHARED CONST GAMESTATE_SPACE            = %00000010
SHARED CONST GAMESTATE_STATION          = %00000100
SHARED CONST GAMESTATE_COMPLETED        = %10000001
SHARED CONST GAMESTATE_EXPLOSION        = %10000010
SHARED CONST GAMESTATE_OUT_OF_FUEL      = %10000100
SHARED CONST GAMESTATE_OUT_OF_OXYGEN    = %10001000
SHARED CONST GAMESTATE_OUT_OF_TIME      = %10010000

SHARED CONST LOC_SOURCE = 0
SHARED CONST LOC_PLAYER = 1
SHARED CONST LOC_DESTINATION = 2

DECLARE SUB LoadProgram(Filename AS STRING*16, Address AS WORD) STATIC SHARED

REM  ZP_NN ZERO PAGE VARIABLES CAN BE USED BY ANY ROUTINES
REM  KEEP TRACK THAT CALLED SUBROUTINES OR FUNCTIONS DONT USE THE SAME VARIABLES
DIM SHARED ZP_W0 AS WORD @$16
DIM SHARED ZP_W1 AS WORD @$18
DIM SHARED ZP_W2 AS WORD @$1a
DIM SHARED ZP_I0 AS INT  @$1c
DIM SHARED ZP_I1 AS INT  @$1e

DIM SHARED ZP_B0 AS BYTE @$20
DIM SHARED ZP_B1 AS BYTE @$21
DIM SHARED ZP_B2 AS BYTE @$22
DIM SHARED ZP_B3 AS BYTE @$23
DIM SHARED ZP_B4 AS BYTE @$24
DIM SHARED ZP_B5 AS BYTE @$25

DIM SHARED ZP_L0 AS LONG @$26
DIM SHARED ZP_L1 AS LONG @$29

DIM SHARED _ProgramAddress AS WORD @$420
DIM SHARED _ProgramFilename AS STRING*28 @$422

SUB LoadProgram(Filename AS STRING*16, Address AS WORD) STATIC SHARED
    IF PEEK($441) = $ee THEN
        MEMSET @_ProgramFilename, 29, 0
        _ProgramFilename = Filename
        _ProgramAddress = Address

        ASM
            jmp $400
        END ASM
    END IF
END SUB

DIM GameMap(255) AS BYTE @$828 SHARED
DIM GameState AS BYTE @$900 SHARED
DIM TimeLeft AS DECIMAL @$92e SHARED

DIM PlayerCredit AS LONG @$801 SHARED
DIM PlayerX AS LONG @$928 SHARED
DIM PlayerY AS LONG @$92b SHARED

DIM LocalMapVergeStationId AS BYTE @$81b SHARED

DIM PlayerSubSystem(3) AS BYTE @$818 SHARED
DIM ComponentValue(5) AS WORD @$804 SHARED
DIM ComponentCapacity(5) AS WORD @$80e SHARED
DIM ArtifactLocation(12) AS BYTE @$81c SHARED





