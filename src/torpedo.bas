'INCLUDE "../libs/lib_common.bas"
'INCLUDE "../libs/lib_space_gfx.bas"
'INCLUDE "../libs/lib_spr.bas"
'INCLUDE "../libs/lib_sfx.bas"
'INCLUDE "../libs/lib_spr_draw.bas"
'INCLUDE "sounds.bas"
'INCLUDE "space_constants.bas"
'INCLUDE "space_state.bas"
'INCLUDE "space_helper.bas"
'INCLUDE "direction.bas"
'INCLUDE "particle.bas"
'INCLUDE "poi.bas"
'INCLUDE "asteroid.bas"

DIM TorpedoX AS LONG SHARED
DIM TorpedoY AS LONG SHARED
DIM TorpedoDx AS LONG SHARED
DIM TorpedoDy AS LONG SHARED
DIM TorpedoSx AS INT SHARED
DIM TorpedoSy AS INT SHARED
DIM TorpedoLx AS INT SHARED
DIM TorpedoLy AS INT SHARED
DIM TorpedoDirection AS BYTE  SHARED
DIM TorpedoSpawnTime AS BYTE SHARED

DIM GeomTorpedo AS BYTE @_GeomTorpedo SHARED

SUB Torpedo_Init() SHARED STATIC
    CALL SprClearSprite(SPR_NR_TORPEDO)
    CALL SprDraw_SetGeometry(SPR_NR_TORPEDO, @GeomTorpedo)
    'SprFrame(SPR_NR_TORPEDO) = 46
    SprColor(SPR_NR_TORPEDO) = COLOR_RED
    spr_y(SPR_NR_TORPEDO) = $ff
END SUB

SUB Torpedo_Spawn() SHARED STATIC
    ASM
        lda {PlayerX}+2
        sta {TorpedoX}+2
        lda {PlayerY}+2
        sta {TorpedoY}+2
        lda #128
        sta {TorpedoX}+1
        sta {TorpedoY}+1
        lda #0
        sta {TorpedoX}
        sta {TorpedoY}
    END ASM
    TorpedoDx = 0
    TorpedoDy = 0
    TorpedoDirection = 0
    TorpedoFuel = 4
    TorpedoSpawnTime = GameTime
END SUB

SUB Torpedo_Destruct() SHARED STATIC
    TorpedoFuel = 0
    spr_y(SPR_NR_TORPEDO) = $ff
END SUB

SUB Torpedo_Basic() SHARED STATIC
    IF TorpedoSpawnTime = GameTime THEN
        TorpedoFuel = TorpedoFuel - 1
        IF TorpedoFuel = 0 THEN
            CALL Torpedo_Destruct()
        END IF
    END IF
END SUB

SUB Torpedo_Move() SHARED STATIC
    ASM
    clc
    lda {TorpedoX}
    adc {TorpedoDx}
    sta {TorpedoX}

    lda {TorpedoX}+1
    adc {TorpedoDx}+1
    sta {TorpedoX}+1

    lda {TorpedoX}+2
    adc {TorpedoDx}+2
    sta {TorpedoX}+2

    clc
    lda {TorpedoY}
    adc {TorpedoDy}
    sta {TorpedoY}

    lda {TorpedoY}+1
    adc {TorpedoDy}+1
    sta {TorpedoY}+1

    lda {TorpedoY}+2
    adc {TorpedoDy}+2
    sta {TorpedoY}+2
    END ASM
END SUB

SUB Torpedo_Screen() SHARED STATIC
    ASM
        sec
        lda {TorpedoX}+1
        sbc {PlayerX}+1
        sta {TorpedoLx}

        lda {TorpedoX}+2
        sbc {PlayerX}+2
        sta {TorpedoLx}+1

        sec
        lda {TorpedoY}+1
        sbc {PlayerY}+1
        sta {TorpedoLy}

        lda {TorpedoY}+2
        sbc {PlayerY}+2
        sta {TorpedoLy}+1

        clc
        lda {TorpedoLx}
        adc #128
        sta {TorpedoSx}

        lda {TorpedoLx}+1
        adc #0
        sta {TorpedoSx}+1

        clc
        lda {TorpedoLy}
        adc #100
        sta {TorpedoSy}

        lda {TorpedoLy}+1
        adc #0
        sta {TorpedoSy}+1
    END ASM

    CALL SprXY(SPR_NR_TORPEDO, TorpedoSx, TorpedoSy)

    IF (GameTime AND %111) = 0 THEN
        CALL ParticleEmit(TorpedoSx, TorpedoSy, small_impulse_dx(TorpedoDirection), small_impulse_dy(TorpedoDirection), 10, 1)
    END IF
END SUB

SUB Torpedo_Direction() SHARED STATIC
    IF ABS(TorpedoLx) > 127 OR ABS(TorpedoLy) > 127 THEN
        CALL Torpedo_Destruct()
        EXIT SUB
    END IF

    ZP_B0 = AngleToOrigo(TorpedoLx, TorpedoLy)

    TorpedoDirection = ZP_B0 'AND %11111
    ZP_B0 = SHL(ZP_B0, 3)
    CALL SprDraw_SetAngle(SPR_NR_TORPEDO, ZP_B0)
END SUB

SUB Torpedo_Speedup() SHARED STATIC
    IF TorpedoX < PlayerX THEN
        IF TorpedoDx < 0 THEN
            TorpedoDx = TorpedoDx + 4
        END IF
        'TorpedoX = TorpedoX + 32
        'TorpedoDx = TorpedoDx + 4
    ELSE
        IF TorpedoDx > 0 THEN
            TorpedoDx = TorpedoDx - 4
        END IF
        'TorpedoX = TorpedoX - 32
        'TorpedoDx = TorpedoDx - 4
    END IF
    IF TorpedoY < PlayerY THEN
        IF TorpedoDy < 0 THEN
            TorpedoDy = TorpedoDy + 4
        END IF
        'TorpedoY = TorpedoY + 32
        'TorpedoDy = TorpedoDy + 4
    ELSE
        IF TorpedoDy > 0 THEN
            TorpedoDy = TorpedoDy - 4
        END IF
        'TorpedoY = TorpedoY - 32
        'TorpedoDy = TorpedoDy - 4
    END IF
END SUB

SUB Torpedo_EngineThrust() SHARED STATIC
    ASM
        lda {TorpedoDirection}
        sta {ZP_B0}
        tax

        ldy #0
        lda {small_impulse_dx},x
        bpl torpedo_update_x_positive
        dey

torpedo_update_x_positive
        clc
        adc {TorpedoDx}
        sta {TorpedoDx}

        tya
        adc {TorpedoDx}+1
        sta {TorpedoDx}+1

        tya
        adc {TorpedoDx}+2
        sta {TorpedoDx}+2

        ldy #0
        lda {small_impulse_dy},x
        bpl torpedo_update_y_positive
        dey

torpedo_update_y_positive
        clc
        adc {TorpedoDy}
        sta {TorpedoDy}

        tya
        adc {TorpedoDy}+1
        sta {TorpedoDy}+1

        tya
        adc {TorpedoDy}+2
        sta {TorpedoDy}+2
    END ASM
    'TorpedoDx = TorpedoDx + small_impulse_dx(SHR(TorpedoDirection, 3))
    'TorpedoDy = TorpedoDy + small_impulse_dy(SHR(TorpedoDirection, 3))
END SUB

SUB Torpedo_Collision() SHARED STATIC
    IF SprRecordCollisions(SPR_NR_TORPEDO) THEN
        FOR ZP_B0 = 1 TO NUM_ASTEROIDS
            IF SprCollision(ZP_B0) THEN
                CALL AsteroidReduce(ZP_B0-1, 7)
                CALL SfxPlay(1, @SfxExplosion)
                CALL Torpedo_Destruct()
            END IF
        NEXT ZP_B0
        IF SprCollision(SPR_NR_POI) AND (ZoneType = ZONE_MISSILE_SILO) AND (TorpedoFuel < 3) THEN
            IF (TorpedoFuel > 0) AND (TorpedoFuel < 3) THEN
                CALL MissileSilo_Destruct(MISSILE_SILO_KILL)
                CALL Torpedo_Destruct()
                CALL Map_SetCurrentZone(%100)
            END IF
        END IF
    END IF
END SUB

_GeomTorpedo:
DATA AS BYTE %00000011
DATA AS BYTE %01111011
DATA AS BYTE %10001011
DATA AS BYTE %00000011
DATA AS BYTE $10
