RANDOMIZE TI()

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_rnd.bas"
INCLUDE "../libs/lib_space_gfx.bas"
INCLUDE "../libs/lib_spr.bas"
INCLUDE "../libs/lib_spr_draw.bas"
INCLUDE "../libs/lib_sfx.bas"
INCLUDE "../libs/lib_str.bas"

CONST SPACE_CHARSET_NUM_LEFT = $be00
CONST SPACE_CHARSET_NUM_RIGHT = $be80
CONST DASHBOARD_COLOR_NOMINAL = 1
CONST DASHBOARD_COLOR_WARN = 7
CONST DASHBOARD_COLOR_CRITICAL = 10

ASM
SPACE_CHARSET_FIELD = $bfc0
END ASM

DECLARE SUB DrawDashboard() SHARED STATIC
DECLARE SUB UpdateDashboard(Value AS WORD, Line AS BYTE, FgColor AS BYTE) SHARED STATIC
DECLARE SUB time_pause(jiffys AS BYTE) SHARED STATIC
DECLARE SUB InitCommon() STATIC
DECLARE SUB CalculateScore() STATIC

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

CALL GraphicsModeInvalid()

ASM
    lda #0
    sta $d017
    sta $d01d

    sei

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

    lda #0          ;background black
    sta $d020

    lda #$ff
    sta $d01b

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

    lda #1          ;enable raster interrupt
    sta $d01a

    cli
END ASM

SprColor(0) = COLOR_WHITE

MEMCPY @SPACE_CHARSET_START, $be00, 512
MEMSET $e000, 8000, 0                   'clear bitmap
MEMSET $c800, 1000, %00010000           'init screen ram

Launch:
GameState = GAMESTATE_SPACE
GameTime = 0
StatusFlag = $ff
TorpedoFuel = 0
BulletAlive = FALSE

CALL DrawDashboard()
CALL GraphicsModeValid()

ASM
    lda $d011
    and #%00111111
    sta $d011
END ASM

CALL LocalMap_Launch()
CALL LocalMap_Basic()
CALL LocalMap_Screen()

CALL ParticleInit()
CALL Bullet_Init()
CALL Torpedo_Init()
CALL AsteroidInit()
CALL BackgroundInit()

CALL SprUpdate(TRUE)

CALL LocalMap_Basic()
CALL BackgroundUpdate()
CALL SprUpdate(TRUE)

CALL time_pause(80)

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
    CALL Player_Shoot()
    CALL Player_Collision()

    CALL Bullet_Basic()
    IF BulletAlive THEN
        CALL Bullet_Move()
        CALL Bullet_Screen()
        CALL Bullet_Collision()

        IF (GameTime AND %1111) = 0 THEN
            CALL SprDraw_FlipFrame(SPR_NR_BULLET)
        END IF
    END IF

    IF ZoneType = ZONE_MISSILE_SILO THEN
        IF TorpedoFuel=0 THEN
            CALL Torpedo_Spawn()
        END IF
    END IF

    IF TorpedoFuel>0 THEN
        CALL Torpedo_Basic()
        IF (GameTime AND %11) = 0 THEN
            CALL Torpedo_Direction()
            CALL Torpedo_EngineThrust()
            CALL Torpedo_Speedup()
        END IF
        IF TorpedoFuel>0 THEN
            CALL Torpedo_Move()
            CALL Torpedo_Screen()
            CALL Torpedo_Collision()
        END IF
    END IF

    CALL LocalMap_Basic()
    CALL LocalMap_Screen()
    IF ZoneType = ZONE_STAR THEN
        CALL Star_Gravity()
        IF (GameTime AND %11) = 0 THEN
            CALL Star_Refuel()
        END IF
    END IF

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

    REM 1 / 16
    IF (GameTime AND %11111) = 0 THEN
        CALL Player_Friction()
    END IF

    REM 1 / 32
    IF (GameTime AND %11111) = 0 THEN
        CALL Star_Animate()
    END IF

    CALL ParticleUpdate()
    CALL Asteroid_Move()
    CALL AsteroidUpdate()

    ZP_B2 = GameTime AND %111111
    SELECT CASE ZP_B2
        CASE 0
            IF StatusFlag AND STATUS_FUEL THEN
                SELECT CASE ComponentValue(COMP_FUEL)
                    CASE 0 TO 24
                        CALL UpdateDashboard(ComponentValue(COMP_FUEL), 0, DASHBOARD_COLOR_CRITICAL)
                    CASE 25 TO 49
                        CALL UpdateDashboard(ComponentValue(COMP_FUEL), 0, DASHBOARD_COLOR_WARN)
                    CASE 50 TO 1000
                        CALL UpdateDashboard(ComponentValue(COMP_FUEL), 0, DASHBOARD_COLOR_NOMINAL)
                END SELECT
                StatusFlag = StatusFlag XOR STATUS_FUEL
            END IF
        CASE 8
            IF ComponentValue(COMP_OXYGEN) = 0 THEN
                GameState = GAMESTATE_OUT_OF_OXYGEN
            END IF
            IF (GameLevel = GAMELEVEL_HARD) OR (GameTime AND %01000000) THEN
                ComponentValue(COMP_OXYGEN) = ComponentValue(COMP_OXYGEN) - 1
                SELECT CASE ComponentValue(COMP_OXYGEN)
                    CASE 0 TO 24
                        CALL UpdateDashboard(ComponentValue(COMP_OXYGEN), 1, DASHBOARD_COLOR_CRITICAL)
                    CASE 25 TO 49
                        CALL UpdateDashboard(ComponentValue(COMP_OXYGEN), 1, DASHBOARD_COLOR_WARN)
                    CASE 50 TO 1000
                        CALL UpdateDashboard(ComponentValue(COMP_OXYGEN), 1, DASHBOARD_COLOR_NOMINAL)
                END SELECT
            END IF
        CASE 12
            CALL LocalMap_UpdateRadar()
        CASE 16
            IF StatusFlag AND STATUS_ARMOR THEN
                SELECT CASE ComponentValue(COMP_ARMOR)
                    CASE 0 TO 24
                        CALL UpdateDashboard(ComponentValue(COMP_ARMOR), 4, DASHBOARD_COLOR_CRITICAL)
                    CASE 25 TO 49
                        CALL UpdateDashboard(ComponentValue(COMP_ARMOR), 4, DASHBOARD_COLOR_WARN)
                    CASE 50 TO 1000
                        CALL UpdateDashboard(ComponentValue(COMP_ARMOR), 4, DASHBOARD_COLOR_NOMINAL)
                END SELECT
                StatusFlag = StatusFlag XOR STATUS_ARMOR
            END IF
        CASE 24 ' GOLD
            IF StatusFlag AND STATUS_GOLD THEN
                IF ComponentValue(COMP_GOLD) = ComponentCapacity(COMP_GOLD) THEN
                    CALL UpdateDashboard(ComponentValue(COMP_GOLD), 2, DASHBOARD_COLOR_WARN)
                ELSE
                    CALL UpdateDashboard(ComponentValue(COMP_GOLD), 2, DASHBOARD_COLOR_NOMINAL)
                END IF
                StatusFlag = StatusFlag XOR STATUS_GOLD
            END IF
        CASE 28 ' UPDATE MAP
            IF PlayerSectorMapRestore THEN
                CALL Plot(PlayerSectorMapX, PlayerSectorMapY)
            ELSE
                CALL UnPlot(PlayerSectorMapX, PlayerSectorMapY)
            END IF
            ASM
                lda {PlayerX} + 1
                rol
                lda {PlayerX} + 2
                rol
                and #$1f
                clc
                adc #20
                sta {PlayerSectorMapX}
                lda #1
                sta {PlayerSectorMapX} + 1

                lda {PlayerY} + 1
                rol
                lda {PlayerY} + 2
                rol
                and #$1f
                clc
                adc #100
                sta {PlayerSectorMapY}
            END ASM

            PlayerSectorMapRestore = GetPixel(PlayerSectorMapX, PlayerSectorMapY)
            CALL Plot(PlayerSectorMapX, PlayerSectorMapY)
        CASE 32 'METAL
            IF StatusFlag AND STATUS_METAL THEN
                IF ComponentValue(COMP_METAL) = ComponentCapacity(COMP_METAL) THEN
                    CALL UpdateDashboard(ComponentValue(COMP_METAL), 3, DASHBOARD_COLOR_WARN)
                ELSE
                    CALL UpdateDashboard(ComponentValue(COMP_METAL), 3, DASHBOARD_COLOR_NOMINAL)
                END IF
                StatusFlag = StatusFlag XOR STATUS_METAL
            END IF
        CASE 40 'TIME
            CALL UpdateDashboard(Time, 7, DASHBOARD_COLOR_NOMINAL)
        CASE 48 'ENERGY
            ASM
                ;color
                ldx {ZoneAsteroidSpeed}
                lda {ZoneAsteroidSpeedColor},x

                sta {ZP_B0}
                lda $c93a
                and #%00001111
                ora {ZP_B0}

                sta $c93a
                sta $c93b
                sta $c93c
                sta $c93d
                sta $c93e

                ;text
                lda {ZoneAsteroidSpeed}
                asl
                asl
                asl
                asl

                adc #<SPACE_CHARSET_FIELD
                sta {ZP_W0}
                lda #>SPACE_CHARSET_FIELD
                adc #0
                sta {ZP_W0} + 1

                ldy #15
_update_dashboard_loop
                lda ({ZP_W0}),y
                sta $e9e8,y
                dey
                bpl _update_dashboard_loop
            END ASM
        CASE 52 'GAME OVER - OUT OF FUEL
            IF ComponentValue(COMP_FUEL) = 0 AND PlayerDx = 0 AND PlayerDy = 0 AND GameState <> GAMESTATE_STATION THEN
                GameState = GAMESTATE_OUT_OF_FUEL
            END IF
        CASE 56 ' SPEED
            ASM
                sta $fff
                bit {PlayerDx}+1
                bpl speed_x_plus

                lda {PlayerDx}
                eor #$ff
                clc
                adc #1
                sta {ZP_W0}

                lda {PlayerDx}+1
                eor #$ff
                adc #0
                sta {ZP_W0} + 1
                jmp speed_y

speed_x_plus
                lda {PlayerDx}
                sta {ZP_W0}

                lda {PlayerDx}+1
                sta {ZP_W0} + 1

speed_y
                bit {PlayerDy}+1
                bpl speed_y_plus

                lda {PlayerDy}
                eor #$ff
                clc
                adc #1
                sta {ZP_W1}

                lda {PlayerDy}+1
                eor #$ff
                adc #0
                sta {ZP_W1} + 1
                jmp speed_max

speed_y_plus
                lda {PlayerDy}
                sta {ZP_W1}

                lda {PlayerDy}+1
                sta {ZP_W1} + 1

speed_max
                lda {ZP_W1}+1
                cmp {ZP_W0}+1
                bcc speed_done
                bne speed_swap

                lda {ZP_W1}
                cmp {ZP_W0}
                bcc speed_done
                beq speed_done

speed_swap
                lda {ZP_W1}
                sta {ZP_W0}
                lda {ZP_W1} + 1
                sta {ZP_W0} + 1

speed_done
                lda {ZP_W0}
                sta {PlayerSpeed}
                lda {ZP_W0} + 1
                sta {PlayerSpeed} + 1
            END ASM
            CALL UpdateDashboard(ZP_W0, 5, DASHBOARD_COLOR_NOMINAL)
    END SELECT

    'CALL SprUpdate(FALSE)
    CALL SprUpdate(FALSE)

    GameTime = GameTime + 1
    IF GameTime = 0 THEN
        IF Time < 10000 THEN
            Time = Time + 1
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

BORDER COLOR_BLACK
CALL GraphicsModeInvalid()

CALL FillBitmap(0)
CALL FillColors(COLOR_BLACK, COLOR_ORANGE)

ASM
    sei

    inc 1

    lda #0          ;vic interrupts off
    sta $d01a

    lda #$ff        ;ack vic interrupts
    sta $d019

    lda #<$ff48      ;restore default irq vector
    sta $fffe
    lda #>$ff48
    sta $ffff

    cli
END ASM

IF (GameState AND GAMESTATE_GAMEOVER) THEN
    'CALL Text(12, 5, TRUE, "irata hq")
    SELECT CASE GameState
        CASE GAMESTATE_OUT_OF_FUEL
            CALL Text(7, 10, FALSE, "moonwraith was lost in the")
            CALL Text(9, 12, FALSE, "dark between the stars")
        CASE GAMESTATE_OUT_OF_OXYGEN
            CALL Text(10, 11, FALSE, "life support failed")
        CASE GAMESTATE_OUT_OF_TIME
            CALL Text(5, 10, FALSE, "not enough time left to build")
            CALL Text(8, 12, FALSE, "the singularity diffuser")
        CASE GAMESTATE_EXPLOSION
            CALL Text(8, 10, FALSE, "moonwraith was destroyed")
            CALL Text(12, 12, FALSE, "in an explosion")
    END SELECT
    CALL CalculateScore()
    CALL GraphicsModeValid()
    IF NOT Debug THEN CALL LoadProgram("gameover", CWORD(8192))
    END
END IF

IF (LocalMapVergeStationId = 5) AND (ArtifactLocation(1) = LOC_PLAYER) THEN
    IF (GameLevel = GAMELEVEL_EASY) OR ((ArtifactLocation(0) = LOC_PLAYER) AND _
    (ArtifactLocation(2) = LOC_PLAYER) AND _
    (ArtifactLocation(3) = LOC_PLAYER)) THEN
        GameState = GAMESTATE_COMPLETED
        CALL Text(12, 8, TRUE, "irata hq")
        CALL GraphicsModeValid()
        CALL CalculateScore()
        IF NOT Debug THEN CALL LoadProgram("epilogue", CWORD(3072))
        END
    END IF
END IF

CALL Text(7, 8, TRUE, "verge station")
'CALL Text(11, 10, FALSE, "network connecting")

CALL GraphicsModeValid()
GameState = GAMESTATE_STATION
IF NOT Debug THEN CALL LoadProgram("station", CWORD(8192))
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
    CALL SetColorInRect(33, 0, 39, 24, 0, COLOR_BLACK)
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
            ZP_W1 = 276 + SHL(CWORD(ZP_B2) MOD 16, 1)
            ZP_B0 = 100 + SHL(ZP_B2 / 16, 1)
            CALL Plot(ZP_W1, ZP_B0)
            CALL Plot(ZP_W1+1, ZP_B0)
            CALL Plot(ZP_W1, ZP_B0+1)
            CALL Plot(ZP_W1-1, ZP_B0)
            CALL Plot(ZP_W1, ZP_B0-1)
        END IF
    NEXT

    ' RADAR
    CALL SetColorInRect(34, 18, 38, 18, 1, COLOR_WHITE)
    CALL SetColorInRect(35, 20, 37, 22, 0, COLOR_DARKGRAY)
    CALL SetColorInRect(36, 21, 36, 21, 0, COLOR_BLACK)

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
    Time = 0
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
        ComponentValue(ZP_B0) = 250
    NEXT
    PlayerSubSystem(SUBSYSTEM_WEAPON) = 0
    PlayerSubSystem(SUBSYSTEM_ENGINE) = 9
    PlayerSubSystem(SUBSYSTEM_GYRO)   = 0

    'LocalMap(135) = %00000101
END SUB

SUB UpdateDashboard(Value AS WORD, Line AS BYTE, FgColor AS BYTE) SHARED STATIC
    ZP_W0 = $c84a + CWORD(40) * Line
    ASM
        ldy #4
        lda {FgColor}
        asl
        asl
        asl
        asl
        sta {FgColor}
        lda ({ZP_W0}),y
        and #%00001111
        ora {FgColor}
update_dashboard_color_loop
        sta ({ZP_W0}),y
        dey
        bpl update_dashboard_color_loop
    END ASM

    CALL Word2String(Value, 10, 4, 0)

    ZP_W0 = $e000 + 320 * (Line+1) + 296
    ZP_W1 = SPACE_CHARSET_NUM_LEFT + SHL(DecByte(0), 3)
    ZP_W2 = SPACE_CHARSET_NUM_RIGHT + SHL(DecByte(1), 3)
    ASM
        ldy #7
_update_dashboard_loop0
        lda ({ZP_W1}),y
        ora ({ZP_W2}),y
        sta ({ZP_W0}),y
        dey
        bpl _update_dashboard_loop0
    END ASM

    ZP_W0 = ZP_W0 + 8
    ZP_W1 = SPACE_CHARSET_NUM_LEFT + SHL(DecByte(2), 3)
    ZP_W2 = SPACE_CHARSET_NUM_RIGHT + SHL(DecByte(3), 3)
    ASM
        ldy #7
_update_dashboard_loop2
        lda ({ZP_W1}),y
        ora ({ZP_W2}),y
        sta ({ZP_W0}),y
        dey
        bpl _update_dashboard_loop2
    END ASM
END SUB

SUB CalculateScore() STATIC
    POKE $bfff, Score
    Score = 0

    ' POINTS FROM CREDITS (MAX 2300)
    ZP_L0 = PlayerCredit
    DO WHILE ZP_L0
        Score = Score + 100
        ZP_L0 = SHR(ZP_L0, 1)
    LOOP
    POKE $bfff, Score

    ' POINTS FROM DESTROYED SILOS (MAX 2800)
    IF GameLevel = GAMELEVEL_HARD THEN
        ZP_B1 = 28
    ELSE
        ZP_B1 = 18
    END IF
    FOR ZP_B0 = 0 TO 255
        IF (GameMap(ZP_B0) AND %00000011) = %00000011 THEN
            ZP_B1 = ZP_B1 - 1
        END IF
    NEXT
    Score = Score + SHL(CLONG(ZP_B1), 7)
    POKE $bfff, Score

    ' POINTS FROM ARTIFACTS (MAX EASY: 2048, NORMAL: 24576, HARD: 49152)
    FOR ZP_B0 = 0 TO 11
        Score = Score + SHL(CLONG(ArtifactLocation(ZP_B0)), 10 + GameLevel)
    NEXT
    POKE $bfff, Score

    IF GameState = GAMESTATE_COMPLETED THEN
        SELECT CASE GameLevel
            CASE GAMELEVEL_EASY
                '2500 - 8192
                Score = Score + CLONG(32768) / SHR((CLONG(10) + Time), 3)
            CASE GAMELEVEL_NORMAL
                '4032 - 14563
                Score = Score + CLONG(262144) / SHR((CLONG(100) + Time), 5)
            CASE GAMELEVEL_HARD
                '8066 - 29127
                Score = Score + CLONG(524288) / SHR((CLONG(100) + Time), 5)
        END SELECT
    END IF
    POKE $bfff, Score
END SUB

_ZoneAsteroidSpeedColor:
DATA AS BYTE $00, $a0, $70, $10

SPACE_CHARSET_START:
INCBIN "../gfx/space_charset.bin"

END
