SHARED CONST NUM_ASTEROIDS = 12

SHARED CONST SPR_NR_PLAYER = 0
SHARED CONST SPR_NR_POI = 13
SHARED CONST SPR_NR_BULLET = 14
SHARED CONST SPR_NR_TORPEDO = 15

SHARED CONST ZONE_NONE          = $00
SHARED CONST ZONE_PORTAL        = $ee
SHARED CONST ZONE_STAR          = $77
SHARED CONST ZONE_MISSILE_SILO  = $aa
SHARED CONST ZONE_AI            = $88

SHARED CONST PLAYER_SX = 127
SHARED CONST PLAYER_SY = 100

SHARED CONST STATUS_GOLD = 1
SHARED CONST STATUS_METAL = 2
SHARED CONST STATUS_FUEL = 4
SHARED CONST STATUS_OXYGEN = 8
SHARED CONST STATUS_ARMOR = 16

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

DIM GameTime AS BYTE FAST SHARED

DIM AsteroidSpeedTitle(4) AS STRING * 5 @_AsteroidSpeedTitle

DIM impulse_dx(32) AS BYTE @_impulse_dx SHARED
DIM impulse_dy(32) AS BYTE @_impulse_dy SHARED

DIM small_impulse_dx(32) AS BYTE @_small_impulse_dx SHARED
DIM small_impulse_dy(32) AS BYTE @_small_impulse_dy SHARED

DIM StatusFlag AS BYTE SHARED
DIM PlayerDx AS LONG SHARED
DIM PlayerDy AS LONG SHARED
DIM PlayerSpeed AS BYTE SHARED

DIM PlayerSectorMapX AS WORD
DIM PlayerSectorMapY AS BYTE
DIM PlayerSectorMapRestore AS BYTE

DIM TorpedoFuel AS BYTE SHARED

DIM BulletSource AS BYTE SHARED

DIM ZoneType AS BYTE SHARED
DIM PoiDistance AS BYTE SHARED
DIM PoiHitPoints AS BYTE SHARED
DIM ZoneAsteroidSpeed AS BYTE SHARED









'INCLUDE "ext/lib_types.bas"
'INCLUDE "ext/lib_color.bas"

'INCLUDE "ext/lib_memory.bas"
INCLUDE "../libs/lib_joy.bas"

'INCLUDE "ext/lib_char.bas"
'INCLUDE "ext/lib_scr.bas"
'INCLUDE "ext/lib_mc.bas"
INCLUDE "../libs/lib_gfx.bas"

'INCLUDE "ext/lib_irq.bas"
'INCLUDE "ext/lib_sid.bas"
INCLUDE "../libs/lib_spr.bas"
INCLUDE "../libs/lib_spr_shape.bas"
INCLUDE "../libs/lib_spr_draw.bas"

INCLUDE "../libs/lib_sfx.bas"


CALL SprInit(3, 0)
CALL SprDraw_Init()

PlayerSectorMapX = 272
PlayerSectorMapY = 96
PlayerSectorMapRestore = 0

RANDOMIZE TI()

SUB UpdateDashboard(Title AS STRING * 1, Value AS WORD, Line AS BYTE, Col AS BYTE) SHARED STATIC
    CALL StringBuilder_Clear(5)
    CALL StringBuilder_Left(0, Title)
    CALL StringBuilder_Right(4, Value)
    CALL GameScreen.Text(34, Line, StringBuilder, Col)
END SUB

INCLUDE "direction.bas"
INCLUDE "sounds.bas"
INCLUDE "particle.bas"
INCLUDE "asteroid.bas"
INCLUDE "poi.bas"
INCLUDE "torpedo.bas"
INCLUDE "bullet.bas"
INCLUDE "player.bas"
INCLUDE "background.bas"

ASM
    ldx #15
set_frames_loop:
    txa
    asl
    adc #16
    sta {SprFrame},x
    dex
    bpl set_frames_loop
END ASM

RestartGame:

TimeLeft = 1000d
LocalMapVergeStationId = 5
PlayerCredit = 10000


FOR ZP_B0 = 0 TO 4
    ComponentValue(ZP_B0) = ComponentInitialValue(ZP_B0)
    ComponentCapacity(ZP_B0) = ComponentInitialCapacity(ZP_B0)
NEXT

FOR ZP_B0 = 0 TO 11
    ArtifactLocation(ZP_B0) = LOC_SOURCE
NEXT

CALL TitleShow(@TITLE_COLOR_RAM)
CALL MessageShow()
CALL Player_StartGame()
CALL LocalMap_StartGame()

Launch:
CALL VergeShow()

GameTime = 0
StatusFlag = $ff
TorpedoFuel = 0
BulletAlive = FALSE

CALL Text.Fill(Color_BLACK, COLOR_BLACK)
CALL GameScreen.Focus()

CALL LocalMap_Launch()
CALL LocalMap_Basic()
CALL LocalMap_Screen()

' WHOLE SCREEN
CALL GameScreen.Clear(COLOR_BLACK, COLOR_WHITE)

' DASHBOARD
CALL GameScreen.Area(33, 0, 39, 24, %10101010)
CALL GameScreen.ColorArea(33, 0, 39, 24, $e0)

' MAP
CALL GameScreen.Rect(271, 95, 312, 136, 1)
CALL GameScreen.Rect(270, 94, 313, 137, 1)
CALL GameScreen.Area(34, 12, 38, 16, 0)
CALL GameScreen.ColorArea(34, 12, 38, 16, $10)
CALL GameScreen.Rect(275, 99, 308, 132, 1)
FOR ZP_B2 = 0 TO 255
    IF ((GameMap(ZP_B2) AND %00000011) = 2) AND ((GameMap(ZP_B2) AND %11100000) <> %01000000) THEN
        CALL GameScreen.Plot(276+SHL(CWORD(ZP_B2) MOD 16, 1), 100+SHL(ZP_B2 / 16, 1), 1)
    END IF
NEXT

' RADAR
CALL GameScreen.Rect(271, 151, 312, 192, 1)
CALL GameScreen.Rect(270, 150, 313, 193, 1)
CALL GameScreen.Area(34, 19, 38, 23, 0)
CALL GameScreen.ColorArea(34, 19, 38, 23, $00)
CALL GameScreen.ColorArea(35, 20, 37, 22, $0b)
CALL GameScreen.ColorBlock(36, 21, COLOR_WHITE, COLOR_BLACK)

' NUMBER PANEL
CALL GameScreen.Rect(271, 7, 312, 72, 1)
CALL GameScreen.Rect(270, 6, 313, 73, 1)
CALL GameScreen.Area(34, 1, 38, 8, 0)

CALL GameScreen.Text(35, 11, "MAP", $10)
CALL GameScreen.Text(34, 18, "RADAR", $10)

CALL GameScreen.Show()

CALL ParticleInit()
CALL Bullet_Init()
CALL Torpedo_Init()
CALL AsteroidInit()
CALL BackgroundInit()
CALL SfxInstall()

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
    POKE $7e0, GameTime

    REM 1 / 1
    CALL Player_Basic()
    CALL Player_Rotate()
    CALL Player_Accelerate()
    CALL Player_Move()
    CALL Player_Shoot()
    CALL Player_Collision()

    POKE $7e1, GameTime

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

    POKE $7e2, GameTime

    REM 1 / 2
    IF (GameTime AND %1) = 0 THEN
        CALL SprDraw_UpdateDirty()
    ELSE
        CALL BackgroundUpdate()
    END IF

    POKE $7e3, GameTime

    REM 1 / 8
    IF (GameTime AND %111) = 0 THEN
        CALL PoiShip_Animate()
    END IF

    POKE $7e4, GameTime

    REM 1 / 16
    IF (GameTime AND %11111) = 0 THEN
        CALL Player_Friction()
    END IF

    POKE $7e5, GameTime

    REM 1 / 32
    IF (GameTime AND %11111) = 0 THEN
        CALL Star_Animate()
    END IF

    CALL ParticleUpdate()
    CALL Asteroid_Move()
    CALL AsteroidUpdate()

    POKE $7e6, GameTime

    ZP_B2 = GameTime AND %111111
    SELECT CASE ZP_B2
        CASE 0
            IF StatusFlag AND STATUS_FUEL THEN
                IF ComponentValue(COMP_FUEL) < 40 THEN
                    CALL UpdateDashboard("F", ComponentValue(COMP_FUEL), 1, $07)
                ELSE
                    CALL UpdateDashboard("F", ComponentValue(COMP_FUEL), 1, $10)
                END IF
                StatusFlag = StatusFlag XOR STATUS_FUEL
            END IF
        CASE 8
            IF ComponentValue(COMP_OXYGEN) = 0 THEN
                GameState = OUT_OF_OXYGEN
            END IF
            ComponentValue(COMP_OXYGEN) = ComponentValue(COMP_OXYGEN) - 1
            IF ComponentValue(COMP_OXYGEN) < 40 THEN
                CALL UpdateDashboard("O", ComponentValue(COMP_OXYGEN), 2, $07)
            ELSE
                CALL UpdateDashboard("O", ComponentValue(COMP_OXYGEN), 2, $10)
            END IF
        CASE 16
            IF StatusFlag AND STATUS_ARMOR THEN
                IF ComponentValue(COMP_ARMOR) < 40 THEN
                    CALL UpdateDashboard("A", ComponentValue(COMP_ARMOR), 5, $07)
                ELSE
                    CALL UpdateDashboard("A", ComponentValue(COMP_ARMOR), 5, $10)
                END IF
                StatusFlag = StatusFlag XOR STATUS_ARMOR
            END IF
        CASE 20 ' ASTEROID ENERGY
            CALL GameScreen.Text(34, 7, AsteroidSpeedTitle(ZoneAsteroidSpeed), $10)
        CASE 24 ' GOLD
            IF StatusFlag AND STATUS_GOLD THEN
                IF ComponentValue(COMP_GOLD) = ComponentCapacity(COMP_GOLD) THEN
                    CALL UpdateDashboard("G", ComponentValue(COMP_GOLD), 3, $05)
                ELSE
                    CALL UpdateDashboard("G", ComponentValue(COMP_GOLD), 3, $10)
                END IF
                StatusFlag = StatusFlag XOR STATUS_GOLD
            END IF
        CASE 28 ' SPEED
            ASM
                lda {PlayerDx}
                sta {ZP_B0}

                lda {PlayerDx}+1
                lsr
                ror {ZP_B0}
                lsr
                ror {ZP_B0}

                lda {ZP_B0}
                bpl x_plus
                eor #$ff
                clc
                adc #1
x_plus
                sta {ZP_B1}

                lda {PlayerDy}
                sta {ZP_B0}

                lda {PlayerDy}+1
                lsr
                ror {ZP_B0}
                lsr
                ror {ZP_B0}

                lda {ZP_B0}
                bpl y_plus
                eor #$ff
                clc
                adc #1
y_plus
                cmp {ZP_B1}
                bcc done
                sta {ZP_B1}
done
            END ASM
            PlayerSpeed = ZP_B1
            CALL StringBuilder_Clear(5)
            CALL StringBuilder_Left(0, "S")
            CALL StringBuilder_Right(4, STR$(ZP_B1))
            CALL GameScreen.Text(34, 6, StringBuilder, $10)
        CASE 32 'METAL
            IF StatusFlag AND STATUS_METAL THEN
                IF ComponentValue(COMP_METAL) = ComponentCapacity(COMP_METAL) THEN
                    CALL UpdateDashboard("M", ComponentValue(COMP_METAL), 4, $05)
                ELSE
                    CALL UpdateDashboard("M", ComponentValue(COMP_METAL), 4, $10)
                END IF
                StatusFlag = StatusFlag XOR STATUS_METAL
            END IF
        CASE 40
            CALL LocalMap_UpdateRadar()
        CASE 44 ' UPDATE MAP
            CALL GameScreen.Plot(PlayerSectorMapX, PlayerSectorMapY, PlayerSectorMapRestore)
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

            CALL GameScreen.Plot(PlayerSectorMapX, PlayerSectorMapY, 1)
            PlayerSectorMapRestore = GameScreen.PlotRestore
        CASE 48
            IF ComponentValue(COMP_FUEL) = 0 AND PlayerDx = 0 AND PlayerDy = 0 AND GameState <> GAMESTATE_STATION THEN
                GameState = OUT_OF_FUEL
            END IF
        CASE 52
            CALL StringBuilder_Clear(5)
            CALL StringBuilder_Left(0, "T")
            CALL StringBuilder_Right(4, STR$(TimeLeft))
            IF TimeLeft < 100d THEN
                CALL GameScreen.Text(34, 8, StringBuilder, $07)
            ELSE
                CALL GameScreen.Text(34, 8, StringBuilder, $10)
            END IF
    END SELECT
    'RegBorderColor = COLOR_BLACK
    CALL SprUpdate(FALSE)
    POKE $7e7, GameTime


    GameTime = GameTime + 1
    IF GameTime = 0 THEN
        TimeLeft = TimeLeft - 1d
        IF TimeLeft = 0d THEN
            GameState = OUT_OF_TIME
        END IF
    END IF
LOOP UNTIL GameState

IF GameState = EXPLOSION THEN
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
CALL SfxUninstall()

IF (GameState AND %10000000)=%10000000 THEN
    CALL Image.Focus()
    CALL Image.Clear(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK)
    CALL Image.Show()

    CALL Image.DrawIconFromDisc3(2, 12, 1)

    CALL Image.Centre(12, "We still Stare", COLOR_MIDDLEGRAY, COLOR_BLACK, 1)
    CALL Image.Centre(13, "at the Heavens", COLOR_MIDDLEGRAY, COLOR_BLACK, 1)
    CALL Image.Centre(14, "While we should", COLOR_MIDDLEGRAY, COLOR_BLACK, 1)
    CALL Image.Centre(15, "Walk among the Stars", COLOR_MIDDLEGRAY, COLOR_BLACK, 1)

    SELECT CASE GameState
        CASE OUT_OF_FUEL
            CALL Image.Centre(19, "Out of fuel", COLOR_RED, COLOR_BLACK, 1)
        CASE OUT_OF_OXYGEN
            CALL Image.Centre(19, "Out of oxygen", COLOR_RED, COLOR_BLACK, 1)
        CASE OUT_OF_TIME
            CALL Image.Centre(19, "Runaway", COLOR_RED, COLOR_BLACK, 1)
            CALL Image.Centre(20, "singularity", COLOR_RED, COLOR_BLACK, 1)
        CASE ELSE
            CALL Image.Centre(19, "Ship exploded", COLOR_RED, COLOR_BLACK, 1)
    END SELECT

    CALL Image.Centre(24, "Press Fire", COLOR_DARKGRAY, COLOR_BLACK, 1)

    CALL Joy1.WaitClick()

    GOTO RestartGame
END IF

IF LocalMapVergeStationId = 5 AND _
    ArtifactLocation(0) = LOC_PLAYER AND _
    ArtifactLocation(1) = LOC_PLAYER AND _
    ArtifactLocation(2) = LOC_PLAYER AND _
    ArtifactLocation(3) = LOC_PLAYER _
THEN
    CALL Image.Focus()
    CALL Image.Clear(COLOR_DARKGRAY, COLOR_MIDDLEGRAY, COLOR_LIGHTGRAY)
    CALL Image.Show()
    CALL Image.DrawIconFromDisc3(1, 12, 1)

    CALL Image.Centre(13, "Well done Commander", COLOR_YELLOW, COLOR_BLACK, 1)

    CALL Image.Centre(15, "I am The President",   COLOR_YELLOW, COLOR_BLACK, 1)
    CALL Image.Centre(16, "of United Planets",    COLOR_YELLOW, COLOR_BLACK, 1)
    CALL Image.Centre(17, "The world is",         COLOR_YELLOW, COLOR_BLACK, 1)
    CALL Image.Centre(18, "grateful for you",     COLOR_YELLOW, COLOR_BLACK, 1)

    CALL Image.Centre(20, "I Congratulate you",   COLOR_YELLOW, COLOR_BLACK, 1)

    CALL Image.Centre(23, "Press Fire",           COLOR_YELLOW, COLOR_BLACK, 1)

    CALL Joy1.WaitClick()

    GOTO RestartGame
END IF

GOTO Launch

_impulse_dx:
DATA AS BYTE 10,10,9,8,7,6,4,2
DATA AS BYTE 0,254,252,250,249,248,247,246
DATA AS BYTE 246,246,247,248,249,250,252,254
DATA AS BYTE 0,2,4,6,7,8,9,10
_impulse_dy:
DATA AS BYTE 0,254,252,250,249,248,247,246
DATA AS BYTE 246,246,247,248,249,250,252,254
DATA AS BYTE 0,2,4,6,7,8,9,10
DATA AS BYTE 10,10,9,8,7,6,4,2
_small_impulse_dx:
DATA AS BYTE 6,6,6,5,4,3,2,1
DATA AS BYTE 0,255,254,253,252,251,250,250
DATA AS BYTE 250,250,250,251,252,253,254,255
DATA AS BYTE 0,1,2,3,4,5,6,6
_small_impulse_dy:
DATA AS BYTE 0,255,254,253,252,251,250,250
DATA AS BYTE 250,250,250,251,252,253,254,255
DATA AS BYTE 0,1,2,3,4,5,6,6
DATA AS BYTE 6,6,6,5,4,3,2,1

_AsteroidSpeedTitle:
DATA AS STRING * 5 "E  NA", "E  Hi", "E Med", "E Low"
