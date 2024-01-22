'INCLUDE "../libs/lib_common.bas"
'INCLUDE "../libs/lib_sfx.bas"
'INCLUDE "../libs/lib_spr.bas"
'INCLUDE "../libs/lib_spr_draw.bas"
'INCLUDE "../libs/lib_space_gfx.bas"
'INCLUDE "space_constants.bas"
'INCLUDE "space_state.bas"
'INCLUDE "particle.bas"
'INCLUDE "sounds.bas"

CONST STATION_SAFE_ZONE = $40
CONST NUM_VERTEX = 6

DECLARE SUB AsteroidSpawn(AsteroidNr AS BYTE) SHARED STATIC
DECLARE SUB Asteroid_Destruct(AsteroidNr AS BYTE) SHARED STATIC

DIM AsteroidXLo(NUM_ASTEROIDS) AS BYTE
DIM AsteroidXMed(NUM_ASTEROIDS) AS BYTE
DIM AsteroidXHi(NUM_ASTEROIDS) AS BYTE
DIM AsteroidYLo(NUM_ASTEROIDS) AS BYTE
DIM AsteroidYMed(NUM_ASTEROIDS) AS BYTE
DIM AsteroidYHi(NUM_ASTEROIDS) AS BYTE
DIM AsteroidEnabled(NUM_ASTEROIDS) AS BYTE SHARED
DIM AsteroidDxHi(NUM_ASTEROIDS) AS BYTE
DIM AsteroidDxMed(NUM_ASTEROIDS) AS BYTE
DIM AsteroidDxLo(NUM_ASTEROIDS) AS BYTE
DIM AsteroidDyHi(NUM_ASTEROIDS) AS BYTE
DIM AsteroidDyMed(NUM_ASTEROIDS) AS BYTE
DIM AsteroidDyLo(NUM_ASTEROIDS) AS BYTE
DIM AsteroidSpawnTime(NUM_ASTEROIDS) AS BYTE @_AsteroidSpawnTime

DIM AsteroidSx(NUM_ASTEROIDS) AS BYTE SHARED
DIM AsteroidSy(NUM_ASTEROIDS) AS BYTE SHARED

DIM AsteroidGeom(112) AS BYTE

TYPE TypeCoordinate
    x AS INT
    y AS INT
END TYPE

DIM AsteroidSpawnPointX(32) AS BYTE @_ASTEROID_SPAWN_POINT_X
DIM AsteroidSpawnPointY(32) AS BYTE @_ASTEROID_SPAWN_POINT_Y
DIM AsteroidDirectionX(32) AS BYTE @_ASTEROID_DIRECTION_X
DIM AsteroidDirectionY(32) AS BYTE @_ASTEROID_DIRECTION_Y

DIM LastAsteroid AS BYTE
    LastAsteroid = NUM_ASTEROIDS - 1

SUB AsteroidInit() SHARED STATIC
    FOR ZP_B0 = 0 TO LastAsteroid
        'SprFrame(ZP_B0 + 1) = 18 + 2 * ZP_B0
        CALL SprDraw_SetGeometry(ZP_B0 + 1, @AsteroidGeom(8 * ZP_B0))
        CALL Asteroid_Destruct(ZP_B0)
    NEXT
END SUB

SUB Asteroid_Move() SHARED STATIC
    ASM
asteroid_move:
    ldx {LastAsteroid}
asteroid_move_loop:
    lda {AsteroidEnabled},x
    beq asteroid_move_next

    clc
    lda {AsteroidXLo},x
    adc {AsteroidDxLo},x
    sta {AsteroidXLo},x

    lda {AsteroidXMed},x
    adc {AsteroidDxMed},x
    sta {AsteroidXMed},x

    lda {AsteroidXHi},x
    adc {AsteroidDxHi},x
    sta {AsteroidXHi},x

    clc
    lda {AsteroidYLo},x
    adc {AsteroidDyLo},x
    sta {AsteroidYLo},x

    lda {AsteroidYMed},x
    adc {AsteroidDyMed},x
    sta {AsteroidYMed},x

    lda {AsteroidYHi},x
    adc {AsteroidDyHi},x
    sta {AsteroidYHi},x

asteroid_move_next:
    dex
    bpl asteroid_move_loop
    END ASM
END SUB

SUB Asteroid_CreateGeometry(AsteroidNr AS BYTE) SHARED STATIC
    ZP_B1 = SHL(AsteroidNr, 3)
    FOR ZP_B2 = 0 TO NUM_VERTEX - 1
        ZP_B3 = (RNDB() AND %00011111) + ((ZP_B2 * 42) AND %11111000)
        IF (ZP_B3 AND %00000111) < 2 THEN ZP_B3 = ZP_B3 + 4
        AsteroidGeom(ZP_B1 + ZP_B2) = ZP_B3
    NEXT
    AsteroidGeom(ZP_B1 + NUM_VERTEX) = AsteroidGeom(ZP_B1)
    AsteroidGeom(ZP_B1 + NUM_VERTEX + 1) = END_SHAPE
END SUB

SUB Asteroid_Destruct(AsteroidNr AS BYTE) SHARED STATIC
    AsteroidEnabled(AsteroidNr) = FALSE
    spr_y(AsteroidNr + 1) = $ff
    CALL Asteroid_CreateGeometry(AsteroidNr)
    CALL SprDraw_Clear(AsteroidNr + 1)
END SUB

SUB AsteroidSpawn(AsteroidNr AS BYTE) SHARED STATIC
    CALL SprDraw_SetDirty(AsteroidNr + 1)

    '--- END OF ZP_xx ---

    DIM spawn_dx AS INT
    DIM spawn_dy AS INT
    DIM dx AS INT
    DIM dy AS INT

    DO
        ZP_B1 = RNDB()
        ZP_B2 = RNDB()

        ASM
            lda {ZP_B1}
            and #%00011111
            tax
            lda {AsteroidSpawnPointX},x
            sta {spawn_dx}

            asl                             ;sign extend
            lda #$00
            adc #$ff
            eor #$ff
            sta {spawn_dx}+1

            lda {AsteroidSpawnPointY},x
            sta {spawn_dy}

            asl                             ;sign extend
            lda #$00
            adc #$ff
            eor #$ff
            sta {spawn_dy}+1

            lda {ZP_B2}
            and #%00011111
            tax

            lda {AsteroidDirectionX},x
            ldy {ZoneAsteroidSpeed}
spawn_asteroid_speed_x_loop
            dey
            beq spawn_asteroid_speed_x_done
            cmp #$80
            ror
            jmp spawn_asteroid_speed_x_loop

spawn_asteroid_speed_x_done
            sta {dx}

            asl                             ;sign extend
            lda #$00
            adc #$ff
            eor #$ff
            sta {dx}+1

            lda {AsteroidDirectionY},x
            ldy {ZoneAsteroidSpeed}
spawn_asteroid_speed_y_loop
            dey
            beq spawn_asteroid_speed_y_done
            cmp #$80
            ror
            jmp spawn_asteroid_speed_y_loop

spawn_asteroid_speed_y_done
            sta {dy}

            asl                             ;sign extend
            lda #$00
            adc #$ff
            eor #$ff
            sta {dy}+1

spawn_asteroid_compare_min_y
            lda {spawn_dy}
            cmp #156
            bne spawn_asteroid_compare_max_y

            lda {dy}
            cmp {PlayerDy}
            lda {dy}+1
            sbc {PlayerDy}+1
            bvc spawn_asteroid_compare_min_y_flip
            eor #$ff
spawn_asteroid_compare_min_y_flip
            bmi spawn_asteroid_compare_nok

spawn_asteroid_compare_max_y
            lda {spawn_dy}
            cmp #99
            bne spawn_asteroid_compare_min_x

            lda {dy}
            cmp {PlayerDy}
            lda {dy}+1
            sbc {PlayerDy}+1
            bvc spawn_asteroid_compare_max_y_flip
            eor #$ff
spawn_asteroid_compare_max_y_flip
            bpl spawn_asteroid_compare_nok


spawn_asteroid_compare_min_x
            lda {spawn_dx}
            cmp #128
            bne spawn_asteroid_compare_max_x

            lda {dx}
            cmp {PlayerDx}
            lda {dx}+1
            sbc {PlayerDx}+1
            bvc spawn_asteroid_compare_min_x_flip
            eor #$ff
spawn_asteroid_compare_min_x_flip
            bmi spawn_asteroid_compare_nok

spawn_asteroid_compare_max_x
            lda {spawn_dx}
            cmp #127
            bne spawn_asteroid_compare_ok

            lda {dx}
            cmp {PlayerDx}
            lda {dx}+1
            sbc {PlayerDx}+1
            bvc spawn_asteroid_compare_max_x_flip
            eor #$ff
spawn_asteroid_compare_max_x_flip
            bmi spawn_asteroid_compare_ok

spawn_asteroid_compare_nok
            lda #$00
            .byte $2c
spawn_asteroid_compare_ok
            lda #$ff

            sta {ZP_B1}
        END ASM
    LOOP UNTIL ZP_B1

    ASM
        ldx {AsteroidNr}

        lda #0
        sta {AsteroidXLo},x
        sta {AsteroidYLo},x

        clc
        lda {PlayerX}+1
        adc {spawn_dx}
        sta {AsteroidXMed},x

        lda {PlayerX}+2
        adc {spawn_dx}+1
        sta {AsteroidXHi},x

        clc
        lda {PlayerY}+1
        adc {spawn_dy}
        sta {AsteroidYMed},x

        lda {PlayerY}+2
        adc {spawn_dy}+1
        sta {AsteroidYHi},x
    END ASM

    ZP_B1 = RNDB() AND %00001111
    SELECT CASE ZP_B1
        CASE 0
            ZP_B1 = COLOR_YELLOW
        CASE 1
            ZP_B1 = COLOR_LIGHTGREEN
        CASE IS < 6
            ZP_B1 = COLOR_DARKGRAY
        CASE IS < 11
            ZP_B1 = COLOR_MIDDLEGRAY
        CASE ELSE
            ZP_B1 = COLOR_LIGHTGRAY
    END SELECT
    SprColor(AsteroidNr + 1) = ZP_B1

    ASM
        ldx {AsteroidNr}

        ;lda {ZP_B1}
        ;and {dx}
        lda {dx}
        sta {AsteroidDxLo},x
        lda {dx}+1
        sta {AsteroidDxMed},x

        asl                             ;sign extend
        lda #$00
        adc #$ff
        eor #$ff
        sta {AsteroidDxHi},x

        lda {dy}
        sta {AsteroidDyLo},x
        lda {dy}+1
        sta {AsteroidDyMed},x

        asl                             ;sign extend
        lda #$00
        adc #$ff
        eor #$ff
        sta {AsteroidDyHi},x
    END ASM

    AsteroidEnabled(AsteroidNr) = TRUE
    'SprEnable(AsteroidNr + 1) = TRUE
END SUB

SUB AsteroidReduce(AsteroidNr AS BYTE, Force AS BYTE) SHARED STATIC
    'IF ZP_B2 > 4 THEN ZP_B2 = ZP_B2 - 4
    ZP_B2 = SHL(AsteroidNr, 3) + (RNDB() AND %11) + 1

    ZP_B1 = AsteroidGeom(ZP_B2) AND %00000111
    IF ZP_B1 > Force THEN
        AsteroidGeom(ZP_B2) = (AsteroidGeom(ZP_B2) AND %11111000) OR (ZP_B1 - Force)
        CALL SprDraw_SetDirty(AsteroidNr + 1)
        ZP_B2 = GameTime AND %11111
        CALL ParticleEmit(AsteroidSx(AsteroidNr), AsteroidSy(AsteroidNr), small_impulse_dx(ZP_B2), small_impulse_dy(ZP_B2), 15, 3)
    ELSE
        ZP_B1 = GameTime AND %111
        FOR ZP_B2 = ZP_B1 TO ZP_B1 + 24 STEP 8
            CALL ParticleEmit(AsteroidSx(AsteroidNr), AsteroidSy(AsteroidNr), small_impulse_dx(ZP_B2), small_impulse_dy(ZP_B2), 15, 1)
        NEXT
        CALL Asteroid_Destruct(AsteroidNr)
    END IF
END SUB

SUB AsteroidUpdate() SHARED STATIC
    DIM x AS INT
    DIM y AS INT
    't = Asteroids(0).X - Player.x
    FOR AsteroidNr AS BYTE = 0 TO LastAsteroid
        IF GameTime = AsteroidSpawnTime(AsteroidNr) THEN
            IF AsteroidEnabled(AsteroidNr) = FALSE THEN
                IF ZoneAsteroidSpeed > 0 THEN
                    IF ZoneType <> ZONE_PORTAL OR PoiDistance > STATION_SAFE_ZONE THEN
                        CALL AsteroidSpawn(AsteroidNr)
                    END IF
                END IF
            END IF
        END IF
        IF AsteroidEnabled(AsteroidNr) THEN
            ASM
                ldx {AsteroidNr}

                sec
                lda {AsteroidXMed},x
                sbc {PlayerX}+1
                sta {x}

                lda {AsteroidXHi},x
                sbc {PlayerX}+2
                sta {x}+1

                clc
                lda {x}
                adc #128
                sta {x}

                lda {x}+1
                adc #0
                sta {x}+1

                sec
                lda {AsteroidYMed},x
                sbc {PlayerY}+1
                sta {y}

                lda {AsteroidYHi},x
                sbc {PlayerY}+2
                sta {y}+1

                clc
                lda {y}
                adc #100
                sta {y}

                lda {y}+1
                adc #0
                sta {y}+1
            END ASM
            IF x < 0 OR x > 255 OR y < 0 OR y > 199 THEN
                CALL Asteroid_Destruct(AsteroidNr)
            ELSE
                AsteroidSx(AsteroidNr) = x
                AsteroidSy(AsteroidNr) = y
                CALL SprXY(AsteroidNr + 1, x, y)
                ' CALL SprDraw_SetAngle(AsteroidNr + 2, AsteroidAngleHi(AsteroidNr))
            END IF
            IF AsteroidEnabled(AsteroidNr) AND ZoneType = ZONE_PORTAL AND PoiDistance < STATION_SAFE_ZONE THEN
                ZP_B1 = GameTime AND %00011111
                CALL ParticleEmit(AsteroidSx(AsteroidNr), AsteroidSy(AsteroidNr), small_impulse_dx(ZP_B1), small_impulse_dy(ZP_B1), 5, %00000111)
                CALL AsteroidReduce(AsteroidNr, 1)
                ZP_B1 = ZP_B1 AND %00001111
                IF ZP_B1 = 0 THEN
                    CALL SfxPlay(2, @VergeField)
                END IF
            END IF
        END IF
    NEXT AsteroidNr
END SUB

GOTO THE_END

_AsteroidSpawnTime:
DATA AS BYTE 0, 21, 42, 64, 85, 106, 128, 149, 170, 191, 212, 234

_ASTEROID_SPAWN_POINT_X:
DATA AS BYTE 128, 160, 192, 224, 0, 32, 64, 96
DATA AS BYTE 127, 127, 127, 127, 127, 127, 127, 127
DATA AS BYTE 127, 96, 64, 32, 0, 224, 192, 160
DATA AS BYTE 128, 128, 128, 128, 128, 128, 128, 128

_ASTEROID_SPAWN_POINT_Y:
DATA AS BYTE 156, 156, 156, 156, 156, 156, 156, 156
DATA AS BYTE 156, 181, 206, 231, 0, 25, 50, 75
DATA AS BYTE 99, 99, 99, 99, 99, 99, 99, 99
DATA AS BYTE 99, 75, 50, 25, 0, 231, 206, 181

_ASTEROID_DIRECTION_X:
DATA AS BYTE 127, 96, 64, 32, 0, 224, 192, 160
DATA AS BYTE 128, 128, 128, 128, 128, 128, 128, 128
DATA AS BYTE 128, 160, 192, 224, 0, 32, 64, 96
DATA AS BYTE 127, 127, 127, 127, 127, 127, 127, 127

_ASTEROID_DIRECTION_Y:
DATA AS BYTE 127, 127, 127, 127, 127, 127, 127, 127
DATA AS BYTE 127, 96, 64, 32, 0, 224, 192, 160
DATA AS BYTE 128, 128, 128, 128, 128, 128, 128, 128
DATA AS BYTE 128, 160, 192, 224, 0, 32, 64, 96

THE_END:
