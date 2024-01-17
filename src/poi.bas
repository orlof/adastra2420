CONST MISSILE_SILO_ARMOR = 21

CONST RADAR_SCR_ADDR = 49946
CONST RADAR_BITMAP_ADDR = $f8d0

DIM PoiSx AS INT SHARED
DIM PoiSy AS INT SHARED
DIM GravityTTL AS BYTE SHARED

DIM RadarBitmapAddr(5) AS WORD @_RadarBitmapAddr SHARED
DIM RadarPixels(8) AS BYTE @_RadarPixels SHARED
DIM gv(8) AS BYTE @_gv SHARED
DIM PoiMap(8) AS BYTE @_PoiMap SHARED

DIM GeomAi AS BYTE @_GeomAi SHARED
DIM GeomPortal AS BYTE @_GeomPortal SHARED
DIM GeomMissileSilo AS BYTE @_GeomMissileSilo SHARED

SUB LocalMap_AddRandom(Item AS BYTE) SHARED STATIC
    DO
        ZP_B0 = RNDB()
        IF (ZP_B0 < 133 OR ZP_B0 > 136) AND (GameMap(ZP_B0) AND %11100111) = 0 THEN
            GameMap(ZP_B0) = GameMap(ZP_B0) OR Item
            EXIT SUB
        END IF
    LOOP
END SUB

SUB LocalMap_StartGame() SHARED STATIC
    ASM
        sei
        dec 1
        dec 1
    END ASM
    MEMCPY $df00, @GameMap, 256
    ASM
        inc 1
        inc 1
        cli
    END ASM
    ' ADD VERGE STATION 2
    CALL LocalMap_AddRandom(%01000110)
    FOR ZP_B1 = 0 TO 20
        ' ADD STAR
        CALL LocalMap_AddRandom(%00000101)
        ' ADD SILO
        CALL LocalMap_AddRandom(%00000111)
    NEXT
    'LocalMap(135) = %00000101
END SUB

SUB LocalMap_Launch() SHARED STATIC
    ZoneType = ZONE_NONE
    'SprFrame(SPR_NR_POI) = 42
END SUB

SUB LocalMap_Basic() SHARED STATIC
    ' DEDUCT CURRENT ZONE AND ITS PROPERTIES
    ASM
        lda {PlayerY} + 2
        ;and #$0f
        asl
        asl
        asl
        asl
        sta {ZP_B0}
        lda {PlayerX} + 2
        and #$0f
        ora {ZP_B0}
        tay
        lda {GameMap},y

        tay
        and #%00000111
        tax
        lda {PoiMap},x
        sta {ZP_B0}

        tya
        lsr
        lsr
        lsr
        tay
        and #%00000011
        sta {ZoneAsteroidSpeed}

        tya
        lsr
        lsr
        and #%00000111
        sta {LocalMapVergeStationId}
    END ASM

    IF ZP_B0 <> ZoneType THEN
        ZoneType = ZP_B0
        IF ZP_B0 = ZONE_NONE THEN
            spr_y(SPR_NR_POI) = $ff
        ELSE
            'AI, STAR, PORTAL OR MISSILE_SILO
            SprColor(SPR_NR_POI) = ZP_B0

            SELECT CASE ZP_B0
                CASE ZONE_STAR
                    ASM
                        sei
                        dec 1
                        dec 1
                    END ASM
                    MEMSHIFT @_StarSpr, $ca80, 64
                    MEMCPY $deab, $cac0, 64
                    ASM
                        inc 1
                        inc 1
                        cli
                    END ASM
                    CALL SprDraw_SetClean(SPR_NR_POI)
                    Spr_EdgeWest(SPR_NR_POI) = 0
                    Spr_EdgeEast(SPR_NR_POI) = 0
                    Spr_EdgeNorth(SPR_NR_POI) = 0
                    Spr_EdgeSouth(SPR_NR_POI) = 0
                    GravityTTL = GameTime + SHR(PoiDistance, 4)
                CASE ZONE_PORTAL
                    CALL SprDraw_UpdateSprite(SPR_NR_POI, @GeomPortal, 0)
                CASE ZONE_AI
                    CALL SprDraw_UpdateSprite(SPR_NR_POI, @GeomAi, 0)
                CASE ZONE_MISSILE_SILO
                    PoiHitPoints = MISSILE_SILO_ARMOR
                    CALL SprDraw_UpdateSprite(SPR_NR_POI, @GeomMissileSilo, 0)
            END SELECT
        END IF
    END IF
END SUB

SUB LocalMap_Screen() SHARED STATIC
    IF ZoneType <> ZONE_NONE THEN
        ASM
            lda #0              ; guess positive
            sta {PoiSx}+1
            sta {PoiSy}+1

            sec
            lda #255
            sbc {PlayerX}+1
            sta {PoiSx}

            sec
            lda #228
            sbc {PlayerY}+1
            sta {PoiSy}

            sec
            lda #127
            sbc {PoiSx}
            bpl poi_sx_ok

            eor #$ff            ; abs(sx)
            clc
            adc #1
poi_sx_ok
            sta {PoiDistance}

            sec
            lda #100
            sbc {PoiSy}
            bpl poi_sy_ok

            eor #$ff            ; abs(sx)
            clc
            adc #1
poi_sy_ok
            cmp {PoiDistance}
            bcc poi_screen_coordinates_end

            sta {PoiDistance}
poi_screen_coordinates_end
        END ASM

        CALL SprXY(SPR_NR_POI, PoiSx, PoiSy)
    END IF
END SUB

SUB Star_Animate() SHARED STATIC
    IF ZoneType = ZONE_STAR THEN
        CALL SprDraw_FlipFrame(SPR_NR_POI)
    END IF
END SUB

SUB PoiShip_Animate() SHARED STATIC
    IF ZoneType = ZONE_MISSILE_SILO OR ZoneType = ZONE_PORTAL THEN
        CALL SprDraw_SetAngle(SPR_NR_POI, GameTime)
    END IF
END SUB

REM Radar coordinates
REM pixels 272-311, 152-191 = chars 34-38, 19-23

SUB LocalMap_UpdateRadar() SHARED STATIC
    ' NW corner of radar
    ASM
        ;bit position
        ;ZP_B0 = SHL(1, SHR(PEEK(@PlayerX + 1), 5))
        lda {PlayerX}+1
        lsr
        lsr
        lsr
        lsr
        lsr
        tax
        lda {RadarPixels},x
        sta {ZP_B0}

        ;y offset
        ;ZP_B1 = 7 - SHR(PEEK(@PlayerY + 1), 5)
        lda {PlayerY}+1
        lsr
        lsr
        lsr
        lsr
        lsr
        sta {ZP_B1}

        sec
        lda #7
        sbc {ZP_B1}
        sta {ZP_B1}
    END ASM

    ZP_W1 = $c31a
    FOR Y AS BYTE = 0 TO 4
        ZP_W0 = RadarBitmapAddr(Y)
        MEMSET ZP_W0, 40, 0
        FOR X AS BYTE = 0 TO 4
            ASM
                ;Location in map
                ;ZP_B3 = 16 * (PlayerY.hi - 2 + Y)
                sec
                lda {PlayerY}+2
                sbc #2

                clc
                adc {Y}
                asl
                asl
                asl
                asl

                sta {ZP_B3}

                ;calculate relative address in map
                ;((PlayerX.hi - 2 + X) & 0x0f) | ZP_B3
                sec
                lda {PlayerX}+2
                sbc #2

                clc
                adc {X}
                and #$0f
                ora {ZP_B3}

                tax
                ;get map value
                lda {GameMap},x
                ;get poi type
                and #%00000111
                tax
                lda {PoiMap},x
                and #%11110000
                sta {ZP_B3}

                ;POKE ZP_W0 + ZP_B1 + 8 * X, ZP_B0
                beq update_radar_zone_none
                lda {X}
                asl
                asl
                asl
                clc
                adc {ZP_B1}
                tay
                lda {ZP_B0}
                sta ({ZP_W0}),y
update_radar_zone_none
            END ASM

            ASM
                ldy {x}

                lda ({ZP_W1}),y
                and #$0f
                ora {ZP_B3}
                sta ({ZP_W1}),y
            END ASM
        NEXT X
        ZP_W1 = ZP_W1 + 40
    NEXT Y
END SUB

SUB Star_Gravity() SHARED STATIC
    IF GravityTTL = GameTime THEN
        GravityTTL = GameTime + gv(SHR(PoiDistance, 4))
        ZP_B0 = AngleToOrigo(127 - PoiSx, 100 - PoiSy)

        ASM
            ldx {ZP_B0}

            ldy #0
            lda {impulse_dx},x
            ;asl
            ;asl
            bpl update_x_positive
            dey

update_x_positive
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
            ;asl
            ;asl
            bpl update_y_positive
            dey

update_y_positive
            clc
            adc {PlayerDy}
            sta {PlayerDy}

            tya
            adc {PlayerDy}+1
            sta {PlayerDy}+1

            tya
            adc {PlayerDy}+2
            sta {PlayerDy}+2
        END ASM
    END IF
END SUB

SUB Star_Refuel() SHARED STATIC
    IF PoiDistance < (RNDB() AND $7f) AND ComponentValue(COMP_FUEL) < ComponentCapacity(COMP_FUEL) THEN
        ComponentValue(COMP_FUEL) = ComponentValue(COMP_FUEL) + 1
        StatusFlag = StatusFlag OR STATUS_FUEL
        IF (GameTime AND %001111) = 0 THEN
            CALL SfxPlay(2, @SfxFuel)
        END IF
    END IF
END SUB

SUB Map_SetCurrentZone(Value AS BYTE) SHARED STATIC
    ASM
        lda {PlayerY} + 2
        ;and #$0f
        asl
        asl
        asl
        asl
        sta {ZP_B0}
        lda {PlayerX} + 2
        and #$0f
        ora {ZP_B0}
        tay
        lda {GameMap},y
        and #%11111000
        ora {Value}
        sta {GameMap},y
ms_destruct_end
    END ASM
END SUB

SHARED CONST MISSILE_SILO_HIT = 4
SHARED CONST MISSILE_SILO_KILL = 8
SUB MissileSilo_Destruct(Power AS BYTE) SHARED STATIC
    CALL SfxPlay(1, @SfxExplosion)
    ZP_B1 = GameTime AND %111
    FOR ZP_B2 = ZP_B1 TO ZP_B1 + 31 STEP Power
        CALL ParticleEmit(PoiSx, PoiSy, small_impulse_dx(ZP_B2), small_impulse_dy(ZP_B2), 15, 1)
    NEXT
END SUB

_PoiMap:
DATA AS BYTE ZONE_NONE, ZONE_NONE, ZONE_NONE, ZONE_NONE
DATA AS BYTE ZONE_AI, ZONE_STAR, ZONE_PORTAL, ZONE_MISSILE_SILO

_RadarBitmapAddr:
DATA AS WORD $f8d0
DATA AS WORD $fa10
DATA AS WORD $fb50
DATA AS WORD $fc90
DATA AS WORD $fdd0

_RadarPixels:
DATA AS BYTE 3,6,12,24,48,96,192,192

_gv:
DATA AS BYTE 2,3,5,7,9,12,15,15

_GeomAi:
DATA AS BYTE %10100011
DATA AS BYTE %01000011
DATA AS BYTE %11100100
DATA AS BYTE %00100100
DATA AS BYTE $20
DATA AS BYTE %10000001
DATA AS BYTE %00000001
DATA AS BYTE $20
DATA AS BYTE %00100111
DATA AS BYTE %01100111
DATA AS BYTE %10100111
DATA AS BYTE %11100111
DATA AS BYTE %00100111
DATA AS BYTE $10


_GeomPortal:
DATA AS BYTE %00000111
DATA AS BYTE %00100111
DATA AS BYTE %01000111
DATA AS BYTE %01100111
DATA AS BYTE %10000111
DATA AS BYTE %10100111
DATA AS BYTE %11000111
DATA AS BYTE %11100111
DATA AS BYTE %00000111
DATA AS BYTE $20
DATA AS BYTE %00000110
DATA AS BYTE %01000110
DATA AS BYTE %10000110
DATA AS BYTE %11000110
DATA AS BYTE %00000110
DATA AS BYTE $10

_GeomMissileSilo:
DATA AS BYTE %00000111
DATA AS BYTE %00100111
DATA AS BYTE %01000111
DATA AS BYTE %01100111
DATA AS BYTE %10000111
DATA AS BYTE %10100111
DATA AS BYTE %11000111
DATA AS BYTE %11100111
DATA AS BYTE %00000111

DATA AS BYTE %00000010

DATA AS BYTE %00100010
DATA AS BYTE %01000010
DATA AS BYTE %01100010
DATA AS BYTE %10000010
DATA AS BYTE %10100010
DATA AS BYTE %11000010
DATA AS BYTE %11100010
DATA AS BYTE %00000010

DATA AS BYTE $20
DATA AS BYTE %00100010
DATA AS BYTE %00100111
DATA AS BYTE $20
DATA AS BYTE %01000010
DATA AS BYTE %01000111
DATA AS BYTE $20
DATA AS BYTE %01100010
DATA AS BYTE %01100111
DATA AS BYTE $20
DATA AS BYTE %10000010
DATA AS BYTE %10000111
DATA AS BYTE $20
DATA AS BYTE %10100010
DATA AS BYTE %10100111
DATA AS BYTE $20
DATA AS BYTE %11000010
DATA AS BYTE %11000111
'DATA AS BYTE $20
'DATA AS BYTE %11100010
'DATA AS BYTE %11100111
DATA AS BYTE $10

_StarSpr:
DATA AS BYTE $00,$00,$00,$00,$10,$00,$00,$91
DATA AS BYTE $00,$10,$89,$08,$04,$4a,$20,$02
DATA AS BYTE $00,$40,$21,$3c,$84,$18,$ff,$18
DATA AS BYTE $04,$ff,$20,$01,$ff,$80,$1d,$ad
DATA AS BYTE $8e,$61,$b7,$b0,$01,$db,$80,$04
DATA AS BYTE $ef,$20,$18,$ff,$18,$21,$3c,$84
DATA AS BYTE $02,$00,$40,$04,$52,$20,$10,$89
DATA AS BYTE $08,$00,$89,$00,$01,$08,$80,$07
'
'DATA AS BYTE $00,$00,$00,$00,$88,$00,$08,$48
'DATA AS BYTE $80,$04,$49,$00,$02,$4a,$00,$01
'DATA AS BYTE $00,$30,$00,$3c,$c0,$30,$ff,$0e
'DATA AS BYTE $0c,$ff,$30,$01,$af,$80,$7d,$f7
'DATA AS BYTE $80,$01,$bf,$bc,$05,$ff,$80,$08
'DATA AS BYTE $b7,$20,$10,$ff,$1c,$21,$3c,$80
'DATA AS BYTE $02,$40,$60,$04,$52,$10,$00,$92
'DATA AS BYTE $00,$00,$91,$00,$00,$00,$00,$07
