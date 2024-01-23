RANDOMIZE TI()

DIM Debug AS BYTE
Debug = (PEEK($441) <> $ee)

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_rnd.bas"
INCLUDE "../libs/lib_space_gfx.bas"
INCLUDE "../libs/lib_spr.bas"
INCLUDE "../libs/lib_spr_draw.bas"
INCLUDE "../libs/lib_sfx.bas"
INCLUDE "../libs/lib_str.bas"

CONST SPACE_CHARSET_NUM_LEFT = $be00
CONST SPACE_CHARSET_NUM_RIGHT = $be40
ASM
SPACE_CHARSET_FIELD = $b1c0
END ASM

DECLARE SUB DrawDashboard() SHARED STATIC
DECLARE SUB UpdateDashboard(Value AS WORD, Line AS BYTE, Col AS BYTE) SHARED STATIC
DECLARE SUB time_pause(jiffys AS BYTE) SHARED STATIC
DECLARE SUB InitCommon() STATIC

INCLUDE "space_constants.bas"
INCLUDE "space_state.bas"
INCLUDE "space_helper.bas"

INCLUDE "direction.bas"
INCLUDE "sounds.bas"
INCLUDE "particle.bas"
INCLUDE "asteroid.bas"
INCLUDE "poi.bas"
INCLUDE "torpedo.bas"
INCLUDE "bullet.bas"
INCLUDE "player.bas"
INCLUDE "background.bas"

IF Debug THEN
    CALL InitCommon()
END IF

DIM ZoneAsteroidSpeedColor(4) AS BYTE @_ZoneAsteroidSpeedColor

ASM
    lda #%01111111      ;CIA interrupt off
    sta $dc0d
    sta $dd0d
    lda $dc0d           ;ACK interrupt
    lda $dd0d

    dec 1

    lda #0          ;bank 0
    sta $dd00

    lda #%00101000  ;bitmap memory, screen memory
    sta $d018

    lda $d011
    ora #%01100000  ;ECM and BMM
    sta $d011

    lda #0          ;vic interrupts off
    sta $d01a

    lda #$ff        ;ack vic interrupts
    sta $d019

    lda #<irq1
    sta $fffe
    lda #>irq1
    sta $ffff

    lda #$fb        ;set raster line
    sta $d012

    lda $d011
    and #%01111111
    sta $d011

    lda #1          ;enable raster interrupt
    sta $d01a
END ASM

SprColor(0) = COLOR_WHITE

MEMCPY @SPACE_CHARSET_START, $be00, 512
MEMSET $e000, 8000, 0                   'clear bitmap
MEMSET $c800, 1000, %00010000           'clear screen ram

Launch:
GameTime = 0
StatusFlag = $ff
TorpedoFuel = 0
BulletAlive = FALSE

CALL DrawDashboard()

ASM
    lda $d011
    and #%10111111
    sta $d011
END ASM

CALL LocalMap_Launch()
CALL LocalMap_Basic()
CALL LocalMap_Screen()

CALL ParticleInit()
'CALL Bullet_Init()
'CALL Torpedo_Init()
'CALL AsteroidInit()
CALL BackgroundInit()

CALL SprUpdate(TRUE)

CALL LocalMap_Basic()
CALL BackgroundUpdate()
CALL SprUpdate(TRUE)

'CALL time_pause(80)

CALL SfxPlay(0, @SfxGameStart)
FOR ZP_B0 = 0 TO 31 STEP 4
    CALL ParticleEmit(PLAYER_SX, PLAYER_SY, small_impulse_dx(ZP_B0), small_impulse_dy(ZP_B0), 32, 3)
NEXT

CALL Player_Launch()
CALL SprUpdate(TRUE)

DO
    REM 1 / 1
    CALL Player_Basic()
    CALL Player_Rotate()
    CALL Player_Accelerate()
    CALL Player_Move()
    'CALL Player_Shoot()
    'CALL Player_Collision()

    CALL LocalMap_Basic()
    CALL LocalMap_Screen()

    REM 1 / 2
    IF (GameTime AND %1) = 0 THEN
        CALL SprDraw_UpdateDirty()
    ELSE
        CALL BackgroundUpdate()
    END IF

    REM 1 / 8
    IF (GameTime AND %111) = 0 THEN
        CALL PoiShip_Animate()
    END IF

    CALL ParticleUpdate()
    'CALL Asteroid_Move()
    'CALL AsteroidUpdate()

    'CALL SprUpdate(FALSE)
    CALL SprUpdate(TRUE)

    GameTime = GameTime + 1
    IF GameTime = 0 THEN
        TimeLeft = TimeLeft - 1
        IF TimeLeft = 0 THEN
            GameState = GAMESTATE_OUT_OF_TIME
        END IF
    END IF
LOOP UNTIL GameState

IF GameState = GAMESTATE_EXPLOSION THEN
    CALL SfxStop(0)
    CALL SfxPlay(0, @SfxExplosion)

    GameTime = 0
    DO UNTIL GameTime = 96
        IF GameTime < 64 THEN
            ZP_B0 = RNDB() AND 31
            CALL ParticleEmit(128, 100, small_impulse_dx(ZP_B0), small_impulse_dy(ZP_B0), 8, 3)
        END IF
        IF GameTime = 64 THEN
            CALL SfxPlay(1, @SfxExplosion)
            FOR ZP_B0 = 0 TO 31 STEP 2
                CALL ParticleEmit(128, 100, small_impulse_dx(ZP_B0), small_impulse_dy(ZP_B0), 15, 1)
            NEXT
            spr_y(SPR_NR_PLAYER) = $ff
        END IF
        IF GameTime = 72 THEN
            CALL SfxPlay(2, @SfxExplosion)
        END IF
        CALL ParticleUpdate()
        SprColor(0) = GameTime AND 1
        CALL SprUpdate(TRUE)
        GameTime = GameTime + 1
    LOOP
END IF

DockingScene:
CALL time_pause(20)

CALL SprDisable()
CALL SprUpdate(TRUE)

CALL time_pause(150)

CALL SfxStop(0)
CALL SfxStop(1)
CALL SfxStop(2)

IF (GameState AND %10000000)=%10000000 THEN
    CALL FillBitmap(0)
    CALL FillColors(COLOR_BLACK, COLOR_ORANGE)

    'CALL Text(11, 2, 1, 0, TRUE, "game over", CHAR_MEMORY)

    'CALL LoadProgram("gameover", CWORD(8192))
    END
END IF

IF LocalMapVergeStationId = 5 AND _
    ArtifactLocation(0) = LOC_PLAYER AND _
    ArtifactLocation(1) = LOC_PLAYER AND _
    ArtifactLocation(2) = LOC_PLAYER AND _
    ArtifactLocation(3) = LOC_PLAYER _
THEN
    CALL FillBitmap(0)
    CALL FillColors(COLOR_BLACK, COLOR_ORANGE)

    'CALL Text(11, 2, 1, 0, TRUE, "completed", CHAR_MEMORY)

    'CALL LoadProgram("completed", CWORD(8192))
    END
END IF

CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)

'CALL Text(11, 2, 1, 0, TRUE, "initiating docking sequence", CHAR_MEMORY)

'CALL LoadProgram("gameover", CWORD(8192))
END

SUB time_pause(jiffys AS BYTE) SHARED STATIC
    ASM
        ldx {jiffys}
time_pause_wait_positive
        bit $d011
        bmi time_pause_wait_positive
time_pause_wait_negative
        bit $d011
        bpl time_pause_wait_negative

        dex
        bne time_pause_wait_positive
    END ASM
END SUB

SUB DrawDashboard() STATIC SHARED
    ' DASHBOARD
    CALL SetColorInRect(33, 0, 39, 24, 0, COLOR_MIDDLEGRAY)
    CALL SetColorInRect(33, 0, 39, 24, 1, COLOR_DARKGRAY)

    FOR W AS WORD = 264 TO 319 STEP 2
        CALL VDraw(W, 0, 199, MODE_SET)
    NEXT
    FOR W = 0 TO 199 STEP 2
        CALL HDraw(264, 319, W, MODE_SET)
    NEXT

    ' NUMBER PANEL
    CALL SetColorInRect(34, 1, 38, 8, 1, COLOR_WHITE)
    CALL Rect(270, 6, 313, 73, MODE_SET, MODE_CLEAR)

    FOR ZP_B0 = 0 TO 7
        MEMCPY $bf00 + CWORD(24) * ZP_B0, $e250 + 320 * ZP_B0, 24
    NEXT

    ' MAP
    CALL SetColorInRect(34, 11, 38, 16, 1, COLOR_WHITE)
    CALL Rect(270, 86, 313, 137, MODE_SET, MODE_CLEAR)
    CALL Rect(275, 99, 308, 132, MODE_SET, MODE_CLEAR)

    CALL CharacterAt(35, 11, "M")
    CALL CharacterAt(36, 11, "A")
    CALL CharacterAt(37, 11, "P")

    CALL SetColorInRect(34, 12, 38, 16, 1, COLOR_YELLOW)
    FOR ZP_B2 = 0 TO 255
        IF ((GameMap(ZP_B2) AND %00000011) = 2) AND ((GameMap(ZP_B2) AND %11100000) <> %01000000) THEN
            CALL Plot(276 + SHL(CWORD(ZP_B2) MOD 16, 1), 100 + SHL(ZP_B2 / 16, 1))
        END IF
    NEXT

    ' RADAR
    CALL SetColorInRect(34, 18, 38, 18, 1, COLOR_WHITE)
    CALL SetColorInRect(35, 20, 37, 22, 0, COLOR_LIGHTGRAY)
    CALL SetColorInRect(36, 21, 36, 21, 0, COLOR_MIDDLEGRAY)

    CALL Rect(270, 142, 313, 193, MODE_SET, MODE_CLEAR)
    'CALL Rect(271, 143, 312, 192, MODE_CLEAR, MODE_CLEAR)
    'CALL SetColorInRect(34, 19, 38, 23, 0, COLOR_MIDDLEGRAY)

    CALL CharacterAt(34, 18, "R")
    CALL CharacterAt(35, 18, "A")
    CALL CharacterAt(36, 18, "D")
    CALL CharacterAt(37, 18, "A")
    CALL CharacterAt(38, 18, "R")

    'BORDER
    CALL SetColorInRect(32, 0, 32, 24, 1, COLOR_BLACK)
    CALL Rect(256, 0, 263, 199, MODE_SET, MODE_SET)
END SUB

SUB InitCommon() STATIC
    GameState = GAMESTATE_SPACE
    TimeLeft = 1000
    LocalMapVergeStationId = 5
    PlayerCredit = 10000
    PlayerX = $068000
    PlayerY = $088000

    PlayerSectorMapX = 272
    PlayerSectorMapY = 96
    PlayerSectorMapRestore = 0

    FOR ZP_B0 = 0 TO 11
        ArtifactLocation(ZP_B0) = LOC_SOURCE
    NEXT
    FOR ZP_B0 = 0 TO 4
        ComponentCapacity(ZP_B0) = 500
        ComponentValue(ZP_B0) = 50
    NEXT
    PlayerSubSystem(SUBSYSTEM_WEAPON) = 0
    PlayerSubSystem(SUBSYSTEM_ENGINE) = 0
    PlayerSubSystem(SUBSYSTEM_GYRO)   = 0

    'LocalMap(135) = %00000101
END SUB

SUB UpdateDashboard(Value AS WORD, Line AS BYTE, Col AS BYTE) SHARED STATIC
    ZP_W0 = $d84d + 40 * Line
    POKE ZP_W0, Col
    POKE ZP_W0 + 1, Col
    POKE ZP_W0 + 2, Col
    POKE ZP_W0 + 3, Col
    POKE ZP_W0 + 4, Col

    CALL Word2String(Value, 10, 4, 0)

    ZP_W0 = ZP_W0 - $1000 + 3
    ZP_W1 = SPACE_CHARSET_NUM_LEFT + SHL(DecByte(0), 3)
    ASM
        ldy #7
_update_dashboard_loop0
        lda ({ZP_W1}),y
        sta ({ZP_W0}),y
        dey
        bpl _update_dashboard_loop0
    END ASM

    ZP_W1 = SPACE_CHARSET_NUM_RIGHT + SHL(DecByte(1), 3)
    ASM
        ldy #7
_update_dashboard_loop1
        lda ({ZP_W1}),y
        ora ({ZP_W0}),y
        sta ({ZP_W0}),y
        dey
        bpl _update_dashboard_loop1
    END ASM

    ZP_W0 = ZP_W0 + 8
    ZP_W1 = SPACE_CHARSET_NUM_LEFT + SHL(DecByte(2), 3)
    ASM
        ldy #7
_update_dashboard_loop2
        lda ({ZP_W1}),y
        sta ({ZP_W0}),y
        dey
        bpl _update_dashboard_loop2
    END ASM

    ZP_W1 = SPACE_CHARSET_NUM_RIGHT + SHL(DecByte(3), 3)
    ASM
        ldy #7
_update_dashboard_loop3
        lda ({ZP_W1}),y
        ora ({ZP_W0}),y
        sta ({ZP_W0}),y
        dey
        bpl _update_dashboard_loop3
    END ASM
END SUB

_ZoneAsteroidSpeedColor:
DATA AS BYTE $10, $07, $07, $10

SPACE_CHARSET_START:
INCBIN "../gfx/space_charset.bin"

END
