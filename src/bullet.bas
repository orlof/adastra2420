'INCLUDE "../libs/lib_common.bas"
'INCLUDE "../libs/lib_spr.bas"
'INCLUDE "../libs/lib_spr_draw.bas"
'INCLUDE "../libs/lib_space_gfx.bas"
'INCLUDE "../libs/lib_sfx.bas"
'INCLUDE "space_constants.bas"
'INCLUDE "space_state.bas"
'INCLUDE "space_helper.bas"
'INCLUDE "sounds.bas"
'INCLUDE "direction.bas"
'INCLUDE "particle.bas"
'INCLUDE "asteroid.bas"
'INCLUDE "poi.bas"
'INCLUDE "torpedo.bas"

DIM CannonBulletDamage(10) AS BYTE @_CannonBulletDamage

DIM BulletX AS LONG
DIM BulletY AS LONG
DIM BulletDx AS LONG
DIM BulletDy AS LONG
DIM BulletSx AS INT
DIM BulletSy AS INT
DIM BulletAlive AS BYTE SHARED
DIM BulletTTL AS BYTE

SUB Bullet_Init() SHARED STATIC
    CALL SprClearSprite(SPR_NR_BULLET)
    ASM
        lda #%00010100
        sta $c3a2
        sta $c39c
        sta $c3df
        lda #%00001000
        sta $c39f
        sta $c3dc
        sta $c3e2
    END ASM

    'SprFrame(SPR_NR_BULLET) = 44
    SprColor(SPR_NR_BULLET) = COLOR_LIGHTGREEN
    Spr_EdgeWest(SPR_NR_BULLET) = 2
    Spr_EdgeEast(SPR_NR_BULLET) = 2
    Spr_EdgeNorth(SPR_NR_BULLET) = 2
    Spr_EdgeSouth(SPR_NR_BULLET) = 2
    spr_y(SPR_NR_BULLET) = $ff
END SUB

SUB Bullet_Spawn(Direction AS BYTE) SHARED STATIC
    BulletX = PlayerX
    BulletY = PlayerY

    ASM
        ldy #0
        lda {Direction}
        lsr
        lsr
        lsr
        tax
        lda {impulse_dx},x
        cmp #$80
        bcc bullet_spawn_dx_positive
        dey
bullet_spawn_dx_positive
        sty {BulletDx}+1
        sty {BulletDx}+2

        asl
        asl
        asl
        asl
        sta {BulletDx}

        ldy #0
        lda {impulse_dy},x
        cmp #$80
        bcc bullet_spawn_dy_positive
        dey
bullet_spawn_dy_positive
        sty {BulletDy}+1
        sty {BulletDy}+2

        asl
        asl
        asl
        asl
        sta {BulletDy}

        clc
        lda {PlayerDx}
        adc {BulletDx}
        sta {BulletDx}

        lda {PlayerDx}+1
        adc {BulletDx}+1
        sta {BulletDx}+1

        lda {PlayerDx}+2
        adc {BulletDx}+2
        sta {BulletDx}+2

        clc
        lda {PlayerDy}
        adc {BulletDy}
        sta {BulletDy}

        lda {PlayerDy}+1
        adc {BulletDy}+1
        sta {BulletDy}+1

        lda {PlayerDy}+2
        adc {BulletDy}+2
        sta {BulletDy}+2
    END ASM

    BulletTTL = GameTime + 150
    BulletAlive = TRUE

    CALL SprXY(SPR_NR_BULLET, PLAYER_SX, PLAYER_SY)
END SUB

SUB Bullet_Destruct() SHARED STATIC
    BulletAlive = FALSE
    spr_y(SPR_NR_BULLET) = $ff
END SUB

SUB Bullet_Basic() SHARED STATIC
    IF BulletAlive AND BulletTTL = GameTime THEN
        CALL Bullet_Destruct()
    END IF
END SUB

SUB Bullet_Move() SHARED STATIC
    ASM
        clc
        lda {BulletX}
        adc {BulletDx}
        sta {BulletX}

        lda {BulletX}+1
        adc {BulletDx}+1
        sta {BulletX}+1

        lda {BulletX}+2
        adc {BulletDx}+2
        sta {BulletX}+2

        clc
        lda {BulletY}
        adc {BulletDy}
        sta {BulletY}

        lda {BulletY}+1
        adc {BulletDy}+1
        sta {BulletY}+1

        lda {BulletY}+2
        adc {BulletDy}+2
        sta {BulletY}+2
    END ASM
END SUB

SUB Bullet_Screen() SHARED STATIC
    ASM
        sec
        lda {BulletX}+1
        sbc {PlayerX}+1
        sta {BulletSx}

        lda {BulletX}+2
        sbc {PlayerX}+2
        sta {BulletSx}+1

        clc
        lda {BulletSx}
        adc #128
        sta {BulletSx}

        lda {BulletSx}+1
        adc #0
        sta {BulletSx}+1

        sec
        lda {BulletY}+1
        sbc {PlayerY}+1
        sta {BulletSy}

        lda {BulletY}+2
        sbc {PlayerY}+2
        sta {BulletSy}+1

        clc
        lda {BulletSy}
        adc #100
        sta {BulletSy}

        lda {BulletSy}+1
        adc #0
        sta {BulletSy}+1
    END ASM

    IF BulletSx < 0 OR BulletSx > 255 OR BulletSy < 0 OR BulletSy > 199 THEN
        CALL Bullet_Destruct()
    ELSE
        CALL SprXY(SPR_NR_BULLET, BulletSx, BulletSy)
    END IF
END SUB

SUB Bullet_Collision() SHARED STATIC
    IF SprRecordCollisions(SPR_NR_BULLET) THEN
        FOR ZP_B0 = 0 TO NUM_ASTEROIDS-1
            IF SprCollision(ZP_B0 + 1) THEN
                CALL AsteroidReduce(ZP_B0, CannonBulletDamage(PlayerSubSystem(SUBSYSTEM_WEAPON)) + BulletSource)
                CALL SfxPlay(1, @SfxAsteroid)
                CALL Bullet_Destruct()
            END IF
        NEXT ZP_B0

        IF SprCollision(SPR_NR_TORPEDO) THEN
            CALL SfxPlay(1, @SfxExplosion)
            ZP_B1 = GameTime AND %111
            FOR ZP_B2 = ZP_B1 TO ZP_B1 + 28 STEP 4
                CALL ParticleEmit(BulletSx, BulletSy, small_impulse_dx(ZP_B2), small_impulse_dy(ZP_B2), 15, 1)
            NEXT
            CALL Torpedo_Destruct()
            CALL Bullet_Destruct()
        END IF

        IF SprCollision(SPR_NR_POI) THEN
            CALL Bullet_Destruct()
            IF ZoneType = ZONE_MISSILE_SILO THEN
                IF (CannonBulletDamage(PlayerSubSystem(SUBSYSTEM_WEAPON)) + BulletSource) < PoiHitPoints THEN
                    PoiHitPoints = PoiHitPoints - (CannonBulletDamage(PlayerSubSystem(SUBSYSTEM_WEAPON)) + BulletSource)
                    CALL MissileSilo_Destruct(MISSILE_SILO_HIT)
                ELSE
                    CALL MissileSilo_Destruct(MISSILE_SILO_KILL)
                    CALL Map_SetCurrentZone(%100)
                END IF
            END IF
        END IF
    END IF
END SUB

GOTO THE_END

_CannonBulletDamage:
DATA AS BYTE 1, 2, 2, 3, 3, 4, 4, 5, 5, 6


THE_END:
