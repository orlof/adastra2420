'INCLUDE "../libs/lib_common.bas"
'INCLUDE "../libs/lib_joy.bas"
'INCLUDE "../libs/lib_spr.bas"
'INCLUDE "../libs/lib_spr_draw.bas"
'INCLUDE "../libs/lib_space_gfx.bas"
'INCLUDE "../libs/lib_sfx.bas"
'INCLUDE "space_constants.bas"
'INCLUDE "space_state.bas"
'INCLUDE "space_helper.bas"
'INCLUDE "direction.bas"
'INCLUDE "sounds.bas"
'INCLUDE "particle.bas"
'INCLUDE "asteroid.bas"
'INCLUDE "poi.bas"
'INCLUDE "torpedo.bas"
'INCLUDE "bullet.bas"


CONST TURRET_LENGTH = 4

DIM PlayerDirection AS BYTE
DIM PlayerDirectionPrev AS BYTE
DIM PlayerTurretDirection AS BYTE
DIM PlayerTurretDirectionRelative AS BYTE
DIM PlayerPulseDelay AS BYTE
DIM PlayerRotatePowerLeft AS BYTE
DIM PlayerRotatePowerRight AS BYTE
DIM PlayerAccelerationTime AS BYTE
DIM PlayerCanAccelerate AS BYTE
DIM PlayerCanShoot AS BYTE
DIM PlayerShootTime AS BYTE
DIM PlayerCanRotate AS BYTE
DIM PlayerRotateTime AS BYTE

DIM PlayerRotatePower(10) AS BYTE @_PlayerRotatePower SHARED
DIM PlayerEnginePulseDelay(10) AS BYTE @_PlayerEnginePulseDelay SHARED

DIM GeomShip AS BYTE @_GeomShip SHARED
DIM GeomShipTurretDisable AS BYTE @_GeomShipTurretDisable SHARED
DIM GeomShipTurret AS BYTE @_GeomShipTurret SHARED


SUB Player_Launch() SHARED STATIC
    ASM
        lda #127
        sta {PlayerX}+1
        sta {PlayerY}+1
        lda #0
        sta {PlayerX}
        sta {PlayerY}
    END ASM
    'PlayerX = PoiX
    'PlayerY = PoiY
    PlayerDirection = 0
    PlayerTurretDirection = 0
    PlayerDx = 64
    PlayerDy = 0
    PlayerCanAccelerate = TRUE
    PlayerCanShoot = TRUE
    PlayerCanRotate = TRUE
    PlayerPulseDelay = PlayerEnginePulseDelay(PlayerSubSystem(SUBSYSTEM_ENGINE))
    PlayerRotatePowerRight = PlayerRotatePower(PlayerSubSystem(SUBSYSTEM_GYRO))
    PlayerRotatePowerLeft  = (PlayerRotatePowerRight XOR $ff) + 1
    GeomShipTurretDisable = $10

    CALL SprClearSprite(SPR_NR_PLAYER)

    CALL SprDraw_UpdateSprite(SPR_NR_PLAYER, @GeomShip, 0)

    CALL SprXY(SPR_NR_PLAYER, PLAYER_SX, PLAYER_SY)
END SUB

SUB Player_Basic() SHARED STATIC
    CALL JoyUpdate()

    ASM
        ldx #$ff
        lda {GameTime}
        cmp {PlayerAccelerationTime}
        bne player_basic_check_shoot
        stx {PlayerCanAccelerate}

player_basic_check_shoot
        cmp {PlayerShootTime}
        bne player_basic_end
        stx {PlayerCanShoot}

player_basic_end
    END ASM
END SUB

SUB Player_Rotate() SHARED STATIC
    ASM
        ldy #0 ; needed with ZP_Wx

player_rotate_read_joy1
        ldx {PlayerRotatePowerLeft}
        lda {JoyValue}+1
        and #%00001000
        beq player_rotate_ship
        ldx {PlayerRotatePowerRight}
        lda {JoyValue}+1
        and #%00000100
        bne player_rotate_has_turret

player_rotate_ship
        txa
        clc
        adc {PlayerDirection}
        sta {PlayerDirection}

player_rotate_has_turret
        ldx {PlayerRotatePowerLeft}
        dex
        lda {JoyValue}
        and #%00001000
        beq player_rotate_turret
        ldx {PlayerRotatePowerRight}
        inx
        lda {JoyValue}
        and #%00000100
        bne player_rotate_direction_changed

player_rotate_turret
        lda #$10
        cmp {GeomShipTurretDisable}
        bne player_rotate_turret_2

        lda #$20
        sta {GeomShipTurretDisable}
        lda {GeomShipTurret}
        and #%00000111
        sta {GeomShipTurret}
        txa
        clc
        adc {PlayerDirection}
        sta {PlayerTurretDirection}
        ldx #1 ; redraw = true
        jmp player_rotate_direction_changed2

player_rotate_turret_2
        txa
        clc
        adc {PlayerTurretDirection}
        sta {PlayerTurretDirection}

player_rotate_direction_changed
        ldx #0 ; redraw = false
player_rotate_direction_changed2
        lda {PlayerDirection}
        and #%11111000
        cmp {PlayerDirectionPrev}
        beq player_rotate_turret_direction_changed

        sta {PlayerDirectionPrev}
        ldx #1 ; redraw = true

player_rotate_turret_direction_changed
        sec
        lda {PlayerTurretDirection}
        sbc {PlayerDirectionPrev}
        and #%11111000
        cmp {PlayerTurretDirectionRelative}
        beq player_rotate_redraw

        sta {PlayerTurretDirectionRelative}
        ldx #1

player_rotate_redraw
        cpx #0
        beq player_rotate_end

        lda {GeomShipTurret}
        and #%00000111
        ora {PlayerTurretDirectionRelative}
        sta {GeomShipTurret}

        lda {PlayerDirectionPrev}
        sta {_angle}
        lda #$ff
        sta {_spr_draw_dirty}

player_rotate_end
    END ASM
    ' CALL SprDraw_SetAngle(SPR_NR_PLAYER, PlayerDirection)
END SUB

SUB Player_Accelerate() SHARED STATIC
    IF PlayerCanAccelerate THEN
        IF JoyUp(JOY2) AND ComponentValue(COMP_FUEL) > 0 THEN
            ComponentValue(COMP_FUEL) = ComponentValue(COMP_FUEL) - 1
            ASM
                lda {PlayerDirection}
                lsr
                lsr
                lsr
                sta {ZP_B0}
                tax

                ldy #0
                lda {impulse_dx},x
                bpl player_update_x_positive
                dey

player_update_x_positive
                clc
                adc {PlayerDx}
                sta {PlayerDx}

                tya
                adc {PlayerDx}+1
                sta {PlayerDx}+1

                tya
                adc {PlayerDx}+2
                sta {PlayerDx}+2

                ldy #0
                lda {impulse_dy},x
                bpl player_update_y_positive
                dey

player_update_y_positive
                clc
                adc {PlayerDy}
                sta {PlayerDy}

                tya
                adc {PlayerDy}+1
                sta {PlayerDy}+1

                tya
                adc {PlayerDy}+2
                sta {PlayerDy}+2

                lda #0
                sta {PlayerCanAccelerate}

                clc
                lda {Gametime}
                adc {PlayerPulseDelay}
                sta {PlayerAccelerationTime}
            END ASM

            ASM
                sec
                lda {ZP_B0}
                sbc #1
                and #%00011111
                sta {ZP_B0}
            END ASM
            CALL ParticleEmit(PLAYER_SX, PLAYER_SY, small_impulse_dx(ZP_B0), small_impulse_dy(ZP_B0), 30, 3)

            ASM
                clc
                lda {ZP_B0}
                adc #2
                and #%00011111
                sta {ZP_B0}
            END ASM
            CALL ParticleEmit(PLAYER_SX, PLAYER_SY, small_impulse_dx(ZP_B0), small_impulse_dy(ZP_B0), 30, 3)

            CALL SfxPlay(0, @SfxEngine)
            StatusFlag = StatusFlag OR STATUS_FUEL
        END IF

        IF JoyDown(JOY2) THEN
            IF PlayerDx < 0 THEN
                PlayerDx = PlayerDx + 1
            END IF
            IF PlayerDx > 0 THEN
                PlayerDx = PlayerDx - 1
            END IF

            IF PlayerDy < 0 THEN
                PlayerDy = PlayerDy + 1
            END IF
            IF PlayerDy > 0 THEN
                PlayerDy = PlayerDy - 1
            END IF

            PlayerCanAccelerate = FALSE
            PlayerAccelerationTime = GameTime + PlayerPulseDelay
        END IF
    END IF
END SUB

SUB Player_Move() SHARED STATIC
    ASM
        ;update x based on dx
        clc
        lda {PlayerX}
        adc {PlayerDx}
        sta {PlayerX}

        lda {PlayerX}+1
        adc {PlayerDx}+1
        sta {PlayerX}+1

        lda {PlayerX}+2
        adc {PlayerDx}+2
        sta {PlayerX}+2

        ;add dy to y
        clc
        lda {PlayerY}
        adc {PlayerDy}
        sta {PlayerY}

        lda {PlayerY}+1
        adc {PlayerDy}+1
        sta {PlayerY}+1

        lda {PlayerY}+2
        adc {PlayerDy}+2
        sta {PlayerY}+2
    END ASM
END SUB

SUB Player_Friction() SHARED STATIC
    ASM
        lda {PlayerDx}
        sta {ZP_L0}
        lda {PlayerDx}+1
        sta {ZP_L0}+1
        lda {PlayerDx}+2
        sta {ZP_L0}+2

        ora {ZP_L0}+1
        ora {ZP_L0}
        beq friction_dx_ok

        ;ZP_L0 = PlayerDx / 16 or 1
        ;3 byte >> with sign extension
        lda {PlayerDx}+2
        cmp #$80
        ror
        ror {ZP_L0}+1
        ror {ZP_L0}
        cmp #$80
        ror
        ror {ZP_L0}+1
        ror {ZP_L0}
        cmp #$80
        ror
        ror {ZP_L0}+1
        ror {ZP_L0}
        cmp #$80
        ror
        ror {ZP_L0}+1
        ror {ZP_L0}
        sta {ZP_L0}+2

        ora {ZP_L0}+1
        ora {ZP_L0}
        bne friction_dx_ok

        inc {ZP_L0}

friction_dx_ok:
        lda {PlayerDy}
        sta {ZP_L1}
        lda {PlayerDy}+1
        sta {ZP_L1}+1
        lda {PlayerDy}+2
        sta {ZP_L1}+2

        ora {ZP_L1}+1
        ora {ZP_L1}
        beq friction_dy_ok

        ;ZP_L1 = PlayerDy / 16 or 1
        lda {PlayerDy}+2
        cmp #$80
        ror
        ror {ZP_L1}+1
        ror {ZP_L1}

        cmp #$80
        ror
        ror {ZP_L1}+1
        ror {ZP_L1}

        cmp #$80
        ror
        ror {ZP_L1}+1
        ror {ZP_L1}

        cmp #$80
        ror
        ror {ZP_L1}+1
        ror {ZP_L1}
        sta {ZP_L1}+2

        ora {ZP_L1}+1
        ora {ZP_L1}
        bne friction_dy_ok

        inc {ZP_L1}

friction_dy_ok:
        ora {ZP_L0}+1
        ora {ZP_L1}+1
        ora {ZP_L1}+1

        ;PlayerDx = PlayerDx - ZP_L0
        sec
        lda {PlayerDx}
        sbc {ZP_L0}
        sta {PlayerDx}

        lda {PlayerDx}+1
        sbc {ZP_L0}+1
        sta {PlayerDx}+1

        lda {PlayerDx}+2
        sbc {ZP_L0}+2
        sta {PlayerDx}+2

        ;PlayerDy = PlayerDy - ZP_L1
        sec
        lda {PlayerDy}
        sbc {ZP_L1}
        sta {PlayerDy}

        lda {PlayerDy}+1
        sbc {ZP_L1}+1
        sta {PlayerDy}+1

        lda {PlayerDy}+2
        sbc {ZP_L1}+2
        sta {PlayerDy}+2
    END ASM
END SUB

SUB Player_Shoot() SHARED STATIC
    IF PlayerCanShoot AND ComponentValue(COMP_METAL) > 0 THEN
        ZP_B0 = FALSE
        IF JoyFire(JOY2) THEN
            ZP_B0 = TRUE
            ZP_B1 = PlayerDirection
            BulletSource = 0
        END IF
        IF JoyFire(JOY1) THEN
            IF GeomShipTurretDisable = $10 THEN
                GeomShipTurretDisable = $20
                GeomShipTurret = GeomShipTurret AND %00000111
                PlayerTurretDirection = PlayerDirection
                CALL SprDraw_SetAngle(SPR_NR_PLAYER, PlayerDirection)
            ELSE
                ZP_B0 = TRUE
                ZP_B1 = PlayerTurretDirection
                BulletSource = 2
            END IF
        END IF
        IF ZP_B0 THEN
            ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - 1
            StatusFlag = StatusFlag OR STATUS_METAL
            CALL SfxPlay(1, @SfxShot)
            PlayerCanShoot = FALSE
            PlayerShootTime = GameTime + 128
            CALL Bullet_Spawn(ZP_B1)
        END IF
    END IF
END SUB

SUB Player_Collision() SHARED STATIC
    IF SprRecordCollisions(0) THEN
        FOR ZP_B0 = 1 TO NUM_ASTEROIDS
            IF SprCollision(ZP_B0) THEN
                SELECT CASE SprColor(ZP_B0)
                    CASE COLOR_YELLOW
                        IF ComponentValue(COMP_GOLD) < ComponentCapacity(COMP_GOLD) THEN
                            IF (GameTime AND %00001111) = 0 THEN
                                CALL AsteroidReduce(ZP_B0-1, 1)
                                CALL SfxPlay(2, @SfxGold)
                            END IF
                            IF NOT AsteroidEnabled(ZP_B0-1) THEN
                                ComponentValue(COMP_GOLD) = ComponentValue(COMP_GOLD) + 15
                            ELSE
                                IF (GameTime AND %11) = 0 THEN
                                    ComponentValue(COMP_GOLD) = ComponentValue(COMP_GOLD) + 2
                                END IF
                            END IF
                            IF ComponentValue(COMP_GOLD) > ComponentCapacity(COMP_GOLD) THEN
                                ComponentValue(COMP_GOLD) = ComponentCapacity(COMP_GOLD)
                            END IF
                            StatusFlag = StatusFlag OR STATUS_GOLD
                        END IF
                    CASE COLOR_LIGHTGREEN
                        IF ComponentValue(COMP_METAL) < ComponentCapacity(COMP_METAL) THEN
                            IF (GameTime AND %00001111) = 0 THEN
                                CALL AsteroidReduce(ZP_B0-1, 1)
                                CALL SfxPlay(2, @SfxGold)
                            END IF
                            IF NOT AsteroidEnabled(ZP_B0-1) THEN
                                ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) + 10
                            ELSE
                                IF (GameTime AND %11) = 0 THEN
                                    ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) + 2
                                END IF
                            END IF
                            IF ComponentValue(COMP_METAL) > ComponentCapacity(COMP_METAL) THEN
                                ComponentValue(COMP_METAL) = ComponentCapacity(COMP_METAL)
                            END IF
                            StatusFlag = StatusFlag OR STATUS_METAL
                        END IF
                    CASE ELSE
                        IF (GameTime AND %00001111) = 0 THEN
                            CALL AsteroidReduce(ZP_B0-1, 1)
                            CALL SfxPlay(1, @SfxAsteroid)
                        END IF
                        ASM
                            lda {PlayerSpeed}
                            lsr
                            lsr
                            lsr
                            lsr
                            clc
                            adc #1
                            sta {ZP_B1}
                        END ASM
                        IF ComponentValue(COMP_ARMOR) > ZP_B1 THEN
                            ComponentValue(COMP_ARMOR) = ComponentValue(COMP_ARMOR) - ZP_B1
                        ELSE
                            ComponentValue(COMP_ARMOR) = 0
                            GameState = GAMESTATE_EXPLOSION
                        END IF
                        StatusFlag = StatusFlag OR STATUS_ARMOR
                END SELECT
            END IF
        NEXT ZP_B0

        IF SprCollision(SPR_NR_TORPEDO) THEN
            CALL SfxPlay(1, @SfxExplosion)
            ZP_B1 = GameTime AND %111
            FOR ZP_B2 = ZP_B1 TO ZP_B1 + 28 STEP 4
                CALL ParticleEmit(PLAYER_SX, PLAYER_SY, small_impulse_dx(ZP_B2), small_impulse_dy(ZP_B2), 15, 1)
            NEXT
            ZP_B1 = (RNDB() AND %00111111) + 30
            IF ComponentValue(COMP_ARMOR) < ZP_B1 THEN
                ComponentValue(COMP_ARMOR) = 0
                GameState = GAMESTATE_EXPLOSION
            ELSE
                ComponentValue(COMP_ARMOR) = ComponentValue(COMP_ARMOR) - ZP_B1
            END IF
            StatusFlag = StatusFlag OR STATUS_ARMOR
            CALL Torpedo_Destruct()
        END IF

        IF SprCollision(SPR_NR_POI) THEN
            SELECT CASE ZoneType
                CASE ZONE_PORTAL
                    IF ABS(PlayerDx) < 8 AND ABS(PlayerDy) < 8 THEN
                        GameState = GAMESTATE_STATION
                    END IF
                CASE ZONE_AI
                    CALL Map_SetCurrentZone(ZONE_NONE)
                    IF ArtifactLocation(8) = LOC_SOURCE THEN
                        ArtifactLocation(8) = LOC_PLAYER 'GET POSITRONIC AI
                    END IF
                CASE ELSE
                    'MISSILE_SILO STAR
                    IF (GameTime AND %00001110) = 0 THEN
                        CALL SfxPlay(1, @SfxAsteroid)
                    END IF
                    'IF ComponentValue(COMP_ARMOR) <= 5 THEN
                        GameState = GAMESTATE_EXPLOSION
                        ComponentValue(COMP_ARMOR) = 0
                    'ELSE
                    '    ComponentValue(COMP_ARMOR) = ComponentValue(COMP_ARMOR) - 5
                    'END IF
                    StatusFlag = StatusFlag OR STATUS_ARMOR
            END SELECT
        END IF
    END IF
END SUB

_PlayerRotatePower:
DATA AS BYTE $01, $01, $01, $01, $02, $02, $02, $02, $02, $03
_PlayerEnginePulseDelay:
DATA AS BYTE 20, 18, 17, 16, 15, 14, 13, 12, 11, 10

_GeomShip:
DATA AS BYTE %00110111
DATA AS BYTE %01010111
DATA AS BYTE %00000101
DATA AS BYTE %10110111
DATA AS BYTE %11010111
DATA AS BYTE $20
DATA AS BYTE %10110111
DATA AS BYTE %01010111
_GeomShipTurretDisable:
DATA AS BYTE $20
DATA AS BYTE %00000000
_GeomShipTurret:
DATA AS BYTE TURRET_LENGTH
DATA AS BYTE $10
