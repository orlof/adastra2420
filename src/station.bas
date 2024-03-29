OPTION FASTINTERRUPT
SYSTEM INTERRUPT OFF

DIM Debug AS BYTE
Debug = (PEEK($441) <> $ee)

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_str.bas"
INCLUDE "../libs/lib_gfx.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_ui.bas"
INCLUDE "../libs/lib_rnd.bas"
INCLUDE "../libs/lib_sid.bas"
INCLUDE "../libs/lib_zx0.bas"

TYPE SaveParamsType
    FileName AS WORD
    From AS WORD
    Length AS WORD
    LoadAddress AS WORD
    DriveCodeBuffer AS WORD
END TYPE

DIM SaveParams AS SaveParamsType
SaveParams.FileName = $0000
SaveParams.From = $0800
SaveParams.Length = 500
SaveParams.LoadAddress = $0800
SaveParams.DriveCodeBuffer = $b300

DIM SaveFileName(4) AS STRING * 9 @_SaveFileName
DIM ReplaceFileName(4) AS STRING * 11 @_ReplaceFileName

DIM ArtifactTitle(12) AS STRING * 15 @_ArtifactTitle
DIM ComponentTitle(5) AS STRING * 6 @_ComponentTitle
DIM SubSystemTitle(2) AS STRING * 6 @_SubSystemTitle

DIM ComponentInitialCapacity(5) AS WORD @_ComponentInitialCapacity
DIM ComponentInitialValue(5) AS WORD @_ComponentInitialValue
DIM ComponentInitialCapacityEasy(5) AS WORD @_ComponentInitialCapacityEasy
DIM ComponentInitialValueEasy(5) AS WORD @_ComponentInitialValueEasy
DIM ComponentPrice(5) AS BYTE @_ComponentPrice
DIM ComponentUpgradeCost(5) AS BYTE @_ComponentUpgradeCost
DIM ComponentMaxCapacity(5) AS WORD @_ComponentMaxCapacity

DIM LeftPanel AS UiPanel
DIM TradePanel AS UiPanel
DIM SystemPanel AS UiPanel
DIM CargoPanel AS UiPanel
DIM ShieldPanel AS UiPanel
DIM DiplomacyPanel AS UiPanel
DIM DiscPanel AS UiPanel
DIM SlotPanel AS UiPanel
DIM NotifyPanel AS UiPanel
DIM MapPanel AS UiPanel

DIM ArtifactVergeStationId AS BYTE

DECLARE SUB DrawDesktop(Char AS BYTE) STATIC
DECLARE SUB MissionBriefingHandler() STATIC
DECLARE SUB SetupGraphics() STATIC
DECLARE SUB CreateLeftPanel() STATIC
DECLARE SUB CreateSystemPanel() STATIC
DECLARE SUB CreateTradePanel(ComponentId AS BYTE) STATIC
DECLARE SUB CreateCargoPanel() STATIC
DECLARE SUB CreateShieldPanel() STATIC
DECLARE SUB CreateDiplomacyPanel() STATIC
DECLARE SUB CreateDiscPanel() STATIC
DECLARE SUB CreateSlotPanel(IsSave AS BYTE) STATIC
DECLARE SUB CreateMapPanel() STATIC
DECLARE SUB AutoSave() STATIC
DECLARE SUB SaveGame(FileNr AS BYTE) STATIC
DECLARE SUB LoadGame(FileNr AS BYTE) STATIC
DECLARE SUB Map_AddRandom(Item AS BYTE) SHARED STATIC
DECLARE FUNCTION GetBuyAllPrice AS LONG(ComponentId AS BYTE) STATIC

POKE $d015,0

CALL DecompressZX0_Unsafe(@SID, $1000)

ASM
    lda #0
    jsr $1000

    lda #125
    sta {ZP_B0}
sid_fwd_loop
    jsr $1003
    dec {ZP_B0}
    bne sid_fwd_loop
END ASM

ON TIMER 17095 GOSUB InterruptHandlerPlaySid
TIMER INTERRUPT ON

CALL DecompressZX0_Unsafe(@KRILL_SAVE, $bb00)

CALL SetupGraphics()

IF Debug OR (GameState = GAMESTATE_STARTING) THEN
    IF Debug THEN GameLevel = GAMELEVEL_NORMAL
    CALL MissionBriefingHandler()
    ASM
        lda {RndTimer}
        sta {ZP_L0}
        sta {ZP_L0}+1
        sta {ZP_L0}+2
    END ASM
    RANDOMIZE ZP_L0

    GameState = GAMESTATE_STATION
    Time = 0
    LocalMapVergeStationId = 5
    Verge2Found = FALSE
    PlayerCredit = 10000
    PlayerX = $068000
    PlayerY = $088000

    PlayerSectorMapX = 272
    PlayerSectorMapY = 96
    PlayerSectorMapRestore = 0

    MEMCPY @_GameMap, @GameMap, 256
    ZP_B1 = 19
    IF GameLevel < GAMELEVEL_HARD THEN
        ZP_B1 = 9
        ' CONVERT FAST ASTEROIDS TO SLOW
        IF GameLevel = GAMELEVEL_EASY THEN
            FOR ZP_B0 = 0 TO 255
                IF (GameMap(ZP_B0) AND %00011000) > 0 THEN
                    GameMap(ZP_B0) = (GameMap(ZP_B0) AND %11100111) OR %00011000
                END IF
            NEXT
        END IF
    END IF

    CALL Map_AddRandom(%01000110)
    FOR ZP_B2 = 0 TO ZP_B1
        ' ADD STAR
        CALL Map_AddRandom(%00000101)
        ' ADD SILO
        CALL Map_AddRandom(%00000111)
    NEXT

    FOR ZP_B0 = 0 TO 11
        ArtifactLocation(ZP_B0) = LOC_SOURCE
        'ArtifactLocation(ZP_B0) = LOC_PLAYER
    NEXT

    IF GameLevel < GAMELEVEL_HARD THEN
        FOR ZP_B0 = 0 TO 4
            ComponentCapacity(ZP_B0) = ComponentInitialCapacityEasy(ZP_B0)
            ComponentValue(ZP_B0) = ComponentInitialValueEasy(ZP_B0)
        NEXT
        PlayerSubSystem(SUBSYSTEM_WEAPON) = 9
        PlayerSubSystem(SUBSYSTEM_ENGINE) = 5
        PlayerSubSystem(SUBSYSTEM_GYRO)   = 8
    ELSE
        FOR ZP_B0 = 0 TO 4
            ComponentCapacity(ZP_B0) = ComponentInitialCapacity(ZP_B0)
            ComponentValue(ZP_B0) = ComponentInitialValue(ZP_B0)
        NEXT
        PlayerSubSystem(SUBSYSTEM_WEAPON) = 0
        PlayerSubSystem(SUBSYSTEM_ENGINE) = 0
        PlayerSubSystem(SUBSYSTEM_GYRO)   = 0
    END IF
END IF

IF LocalMapVergeStationId = 2 THEN
    Verge2Found = TRUE
END IF

CALL DrawDesktop($30+LocalMapVergeStationId)

'CALL AutoSave()

CALL CreateLeftPanel()

CALL LeftPanel.SetSelected(4)

LeftPanelHandler:
    CALL LeftPanel.SetFocus(TRUE)
    DO
        CALL LeftPanel.WaitEvent(FALSE)

        SELECT CASE LeftPanel.Selected
            CASE 4,5,6,7 ' gold, metal, fuel, oxygen
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateTradePanel(LeftPanel.Selected - 4)
                CALL TradePanel.SetSelected(1)
                GOTO TradePanelHandler
            CASE 12 ' system upgrades
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateSystemPanel()
                CALL SystemPanel.SetSelected(3)
                GOTO SystemPanelHandler
            CASE 13 ' shield
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateShieldPanel()
                CALL ShieldPanel.SetSelected(3)
                GOTO ShieldPanelHandler
            CASE 14 ' cargo space
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateCargoPanel()
                CALL CargoPanel.SetSelected(3)
                GOTO CargoPanelHandler
            CASE 15 ' map panel
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateMapPanel()
                CALL MapPanel.SetSelected(255)
                GOTO MapPanelHandler
            CASE 16 ' diplomacy
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateDiplomacyPanel()
                CALL DiplomacyPanel.SetSelected(8)
                GOTO DiplomacyPanelHandler
            CASE 17 ' disc
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateDiscPanel()
                CALL DiscPanel.SetSelected(1)
                GOTO DiscPanelHandler
            CASE 19 ' launch
                CALL WaitRasterLine256()
                CALL SetGraphicsMode(INVALID_MODE)
                CALL SetBitmapMemory(1)
                CALL SetScreenMemory(2)
                CALL FillBitmap(0)
                CALL FillColors(COLOR_BLACK, COLOR_ORANGE)

                CALL Text(10, 8, 1, 0, TRUE, "moonwraith", CHAR_MEMORY)
                'CALL Text(10, 5, 1, 0, TRUE, "moonwraith", CHAR_MEMORY)
                'CALL Text(12, 8, 1, 0, FALSE, "launch sequence", CHAR_MEMORY)
                'CALL Text(15, 10, 1, 0, FALSE, "initiated", CHAR_MEMORY)

                CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

                TIMER INTERRUPT OFF
                CALL SidStop()

                IF NOT Debug THEN CALL LoadProgram("space", CWORD(4096))
                END
        END SELECT
    LOOP

SUB AutoSave() STATIC
    CALL NotifyPanel.Init("", 13, 10, 14, 5, TRUE)
    CALL NotifyPanel.Center(1, "autosaving", COLOR_BLUE, TRUE)

    CALL SaveGame(3)

    CALL NotifyPanel.Dispose()
END SUB

SUB SaveGame(FileNr AS BYTE) STATIC
    IF NOT Debug THEN
        IF UseDiscTurbo THEN
            SaveParams.FileName = @SaveFileName(FileNr) + 1
            ZP_W0 = @SaveParams
            ASM
                lda #1
                sta $30

                ldx {ZP_W0}
                ldy {ZP_W0}+1
                jsr $bb00
                bcs save_failed
                lda #0
save_failed
                sta $30
            END ASM
        ELSE
            TIMER INTERRUPT OFF
            CALL SidStop()

            ZP_W0 = @ReplaceFileName(FileNr) + 1

            ASM
                sta $30

                lda #10
                ldx {ZP_W0}
                ldy {ZP_W0}+1
                jsr $ffbd     ; call SETNAM

                lda #$00
                ldx $ba         ; last used device number
                bne *+4
                    ldx #$08    ; default to device 8
                ldy #$00
                jsr $ffba       ; call SETLFS

                lda #<$0800
                sta {ZP_W1}
                lda #>$0800
                sta {ZP_W1}+1

                ldx #<$09f4
                ldy #>$09f4

                lda #$18        ; address of ZP_W1
                jsr $ffd8       ; call SAVE
                bcs *           ; if carry set, a load error has happened
            END ASM

            ON TIMER 17095 GOSUB InterruptHandlerPlaySid3
            TIMER INTERRUPT ON
            EXIT SUB
InterruptHandlerPlaySid3:
            ASM
                jsr $1003
                rts
            END ASM
        END IF
    END IF
END SUB

SUB LoadGame(FileNr AS BYTE) STATIC
    ZP_W0 = @SaveFileName(FileNr) + 1

    IF NOT Debug THEN
        IF NOT UseDiscTurbo THEN
            TIMER INTERRUPT OFF
            CALL SidStop()
        END IF
        ASM
            lda {SaveFileName}
            ldx {ZP_W0}
            ldy {ZP_W0}+1
            jsr $440

            bcs *
        END ASM
        IF NOT UseDiscTurbo THEN
            ON TIMER 17095 GOSUB InterruptHandlerPlaySid2
            TIMER INTERRUPT ON
            EXIT SUB
InterruptHandlerPlaySid2:
            ASM
                jsr $1003
                rts
            END ASM
        END IF
    END IF
END SUB

DiplomacyPanelHandler:
    CALL DiplomacyPanel.SetFocus(TRUE)

    DO
        CALL DiplomacyPanel.WaitEvent(FALSE)

        IF (DiplomacyPanel.Event = EVENT_FIRE) AND (DiplomacyPanel.Selected = 9) THEN
            SELECT CASE ArtifactVergeStationId
                CASE 5
                    PlayerCredit = PlayerCredit - 10000
                CASE 6
                    ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - 250
                CASE 7
                    ComponentValue(COMP_GOLD) = ComponentValue(COMP_GOLD) - 500
                CASE ELSE
                    ArtifactLocation(ArtifactVergeStationId+4) = LOC_DESTINATION
            END SELECT

            ArtifactLocation(ArtifactVergeStationId) = LOC_PLAYER
        END IF

        CALL DiplomacyPanel.Dispose()
        CALL LeftPanel.Right(13, 1, GetLong2String(PlayerCredit, 7), COLOR_YELLOW, FALSE)
        CALL LeftPanel.Left(10, 4, GetWord2String(ComponentValue(0), 3), COLOR_LIGHTGRAY, TRUE)
        CALL LeftPanel.Left(10, 5, GetWord2String(ComponentValue(1), 3), COLOR_LIGHTGRAY, TRUE)
        GOTO LeftPanelHandler
    LOOP

LoadPanelHandler:
    CALL SlotPanel.SetFocus(TRUE)

    DO
        CALL SlotPanel.WaitEvent(FALSE)

        SELECT CASE SlotPanel.Event
            CASE EVENT_LEFT
                CALL SlotPanel.Dispose()
                GOTO DiscPanelHandler
            CASE EVENT_FIRE
                CALL LoadGame(SlotPanel.Selected - 1)
                CALL SlotPanel.Dispose()
                CALL DiscPanel.Dispose()
                CALL CreateLeftPanel()
                CALL LeftPanel.SetSelected(17)
                GOTO LeftPanelHandler
        END SELECT
    LOOP

MapPanelHandler:
    CALL MapPanel.SetFocus(TRUE)

    DO
        CALL MapPanel.WaitEvent(FALSE)

        SELECT CASE MapPanel.Event
            CASE EVENT_LEFT
                CALL MapPanel.Dispose()
                GOTO LeftPanelHandler
            CASE EVENT_FIRE
                CALL MapPanel.Dispose()
                GOTO LeftPanelHandler
        END SELECT
    LOOP

SavePanelHandler:
    CALL SlotPanel.SetFocus(TRUE)

    DO
        CALL SlotPanel.WaitEvent(FALSE)

        SELECT CASE SlotPanel.Event
            CASE EVENT_LEFT
                CALL SlotPanel.Dispose()
                GOTO DiscPanelHandler
            CASE EVENT_FIRE
                CALL SaveGame(SlotPanel.Selected - 1)
                CALL SlotPanel.Dispose()
                CALL DiscPanel.Dispose()
                GOTO LeftPanelHandler
        END SELECT
    LOOP

DiscPanelHandler:
    CALL DiscPanel.SetFocus(TRUE)

    DO
        CALL DiscPanel.WaitEvent(FALSE)

        SELECT CASE DiscPanel.Event
            CASE EVENT_LEFT
                CALL DiscPanel.Dispose()
                GOTO LeftPanelHandler
            CASE EVENT_FIRE, EVENT_RIGHT
                CALL DiscPanel.SetFocus(FALSE)
                IF DiscPanel.Selected = 1 THEN
                    CALL CreateSlotPanel(0)
                    CALL SlotPanel.SetSelected(1)
                    GOTO LoadPanelHandler
                ELSE
                    CALL CreateSlotPanel(1)
                    CALL SlotPanel.SetSelected(1)
                    GOTO SavePanelHandler
                END IF
        END SELECT
    LOOP

SystemPanelHandler:
    CALL SystemPanel.SetFocus(TRUE)

    DO
        CALL SystemPanel.WaitEvent(FALSE)

        SELECT CASE SystemPanel.Event
            CASE EVENT_LEFT
                CALL SystemPanel.Dispose()
                GOTO LeftPanelHandler
            CASE EVENT_FIRE
                IF ComponentValue(COMP_METAL) >= 50 THEN
                    ZP_B0 = SystemPanel.Selected - 3
                    IF PlayerSubSystem(ZP_B0) < 9 THEN
                        PlayerSubSystem(ZP_B0) = PlayerSubSystem(ZP_B0) + 1
                        ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - 50
                        CALL SystemPanel.Right(12, SystemPanel.Selected, GetByte2String(PlayerSubSystem(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
                        CALL LeftPanel.Left(10, 4 + COMP_METAL, GetWord2String(ComponentValue(COMP_METAL), 3), COLOR_LIGHTGRAY, TRUE)
                    END IF
                END IF
        END SELECT
    LOOP

CargoPanelHandler:
    CALL CargoPanel.SetFocus(TRUE)

    DO
        CALL CargoPanel.WaitEvent(FALSE)

        SELECT CASE CargoPanel.Event
            CASE EVENT_LEFT
                CALL CargoPanel.Dispose()
                GOTO LeftPanelHandler
            CASE EVENT_FIRE
                ZP_B0 = CargoPanel.Selected - 3
                IF ComponentValue(COMP_METAL) >= ComponentUpgradeCost(ZP_B0) THEN
                    IF ComponentCapacity(ZP_B0) < ComponentMaxCapacity(ZP_B0) THEN
                        ComponentCapacity(ZP_B0) = ComponentCapacity(ZP_B0) + 1
                        ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - ComponentUpgradeCost(ZP_B0)
                        CALL CargoPanel.Right(13, CargoPanel.Selected, GetWord2String(ComponentCapacity(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
                        CALL LeftPanel.Left(10, 4 + COMP_METAL, GetWord2String(ComponentValue(COMP_METAL), 3), COLOR_LIGHTGRAY, TRUE)
                        CALL LeftPanel.Left(14, 4 + ZP_B0, GetWord2String(ComponentCapacity(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
                    END IF
                END IF
        END SELECT
    LOOP

ShieldPanelHandler:
    CALL ShieldPanel.SetFocus(TRUE)

    DO
        CALL ShieldPanel.WaitEvent(FALSE)

        SELECT CASE ShieldPanel.Event
            CASE EVENT_LEFT
                CALL ShieldPanel.Dispose()
                GOTO LeftPanelHandler
            CASE EVENT_FIRE
                SELECT CASE ShieldPanel.Selected
                    CASE 3 ' repair
                        IF ComponentValue(COMP_ARMOR) < ComponentCapacity(COMP_ARMOR) THEN
                            IF ComponentValue(COMP_METAL) >= ComponentPrice(COMP_ARMOR) THEN
                                ComponentValue(COMP_ARMOR) = ComponentValue(COMP_ARMOR) + 1
                                ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - ComponentPrice(COMP_ARMOR)
                                CALL ShieldPanel.Right(13, 3, GetWord2String(ComponentValue(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
                                CALL LeftPanel.Left(10, 4 + COMP_METAL, GetWord2String(ComponentValue(COMP_METAL), 3), COLOR_LIGHTGRAY, TRUE)
                            END IF
                        END IF
                    CASE 4 ' upgrade
                        IF ComponentCapacity(COMP_ARMOR) < ComponentMaxCapacity(COMP_ARMOR) THEN
                            IF ComponentValue(COMP_METAL) >= ComponentUpgradeCost(COMP_ARMOR) THEN
                                ComponentCapacity(COMP_ARMOR) = ComponentCapacity(COMP_ARMOR) + 1
                                ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - ComponentUpgradeCost(COMP_ARMOR)
                                CALL ShieldPanel.Right(13, 4, GetWord2String(ComponentCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
                                CALL ShieldPanel.Right(17, 3, GetWord2String(ComponentCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
                                CALL LeftPanel.Left(10, 4 + COMP_METAL, GetWord2String(ComponentValue(COMP_METAL), 3), COLOR_LIGHTGRAY, TRUE)
                            END IF
                        END IF
                END SELECT
        END SELECT
    LOOP

TradePanelHandler:
    CALL TradePanel.SetFocus(TRUE)

    DO
        CALL TradePanel.WaitEvent(TRUE)

        SELECT CASE TradePanel.Event
            CASE EVENT_FIRE
                ZP_B0 = LeftPanel.Selected - 4
                SELECT CASE TradePanel.Selected
                    CASE 1  ' buy
                        ZP_B1 = SHL(ComponentPrice(ZP_B0), 1)
                        IF PlayerCredit >= ZP_B1 THEN
                            IF ComponentValue(ZP_B0) < ComponentCapacity(ZP_B0) THEN
                                PlayerCredit = PlayerCredit - ZP_B1
                                ComponentValue(ZP_B0) = ComponentValue(ZP_B0) + 1
                            END IF
                        END IF
                    CASE 2  ' buy all
                        PlayerCredit = PlayerCredit - GetBuyAllPrice(ZP_B0)
                        ComponentValue(ZP_B0) = ComponentValue(ZP_B0) + ZP_L0
                    CASE 4 ' sell
                        IF ComponentValue(ZP_B0) > 0 THEN
                            PlayerCredit = PlayerCredit + ComponentPrice(ZP_B0)
                            ComponentValue(ZP_B0) = ComponentValue(ZP_B0) - 1
                        END IF
                    CASE 5 ' sell all
                        PlayerCredit = PlayerCredit + CLONG(ComponentPrice(ZP_B0)) * ComponentValue(ZP_B0)
                        ComponentValue(ZP_B0) = 0
                END SELECT
                CALL LeftPanel.Right(13, 1, GetLong2String(PlayerCredit, 7), COLOR_YELLOW, FALSE)
                CALL LeftPanel.Right(12, LeftPanel.Selected, GetWord2String(ComponentValue(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
                CALL TradePanel.Right(16, 5, GetLong2String(CLONG(ComponentPrice(ZP_B0)) * ComponentValue(ZP_B0), 7), COLOR_LIGHTGRAY, TRUE)
                CALL TradePanel.Right(16, 2, GetLong2String(GetBuyAllPrice(ZP_B0), 7), COLOR_LIGHTGRAY, TRUE)

            CASE EVENT_LEFT
                CALL TradePanel.Dispose()
                GOTO LeftPanelHandler
        END SELECT
    LOOP

REM ********************************
REM * ROUTINES
REM ********************************

SUB SetupGraphics() STATIC
    BORDER COLOR_BLACK
    BACKGROUND COLOR_BLACK
    CALL ScreenOff()
    'CALL SetVideoBank(3)
    ASM
        lda #0          ;bank=3
        sta $dd00
    END ASM
    CALL SetCharacterMemory(2)
    CALL SetScreenMemory(2)
    SCREEN 2
    MEMSET $c800, 1000, 32
    MEMSET $d800, 1000, 1

    CALL SetGraphicsMode(STANDARD_CHARACTER_MODE)
    CALL ScreenOn()
END SUB

SUB DrawDesktop(Char AS BYTE) STATIC
    CALL UiLattice(0, 0, 40, 25, Char, Char, COLOR_BLUE, COLOR_DARKGRAY)
    'MEMSET $c800, 1000, 32
    'MEMSET $d800, 1000, COLOR_MIDDLEGRAY
END SUB

FUNCTION GetBuyAllPrice AS LONG(ComponentId AS BYTE) STATIC
    ZP_B5 = SHL(ComponentPrice(ComponentId), 1)
    ZP_L0 = PlayerCredit / ZP_B5
    ZP_L1 = ComponentCapacity(ComponentId) - ComponentValue(ComponentId)
    IF ZP_L1 < ZP_L0 THEN ZP_L0 = ZP_L1
    GetBuyAllPrice = ZP_B5 * ZP_L0
END FUNCTION

SUB CreateSystemPanel() STATIC
    CALL SystemPanel.Init("system upgrades", 7, 12, 26, 9, TRUE)
    CALL SystemPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL SystemPanel.Left(11, 1, "lvl max metal", COLOR_BLUE, FALSE)
    FOR ZP_B0 = 0 TO 2
        CALL SystemPanel.Left(1, 3 + ZP_B0, SubSystemTitle(ZP_B0), COLOR_LIGHTGRAY, TRUE)
        CALL SystemPanel.Right(12, 3 + ZP_B0, GetByte2String(PlayerSubSystem(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
        CALL SystemPanel.Right(16, 3 + ZP_B0, "9", COLOR_LIGHTGRAY, TRUE)
        CALL SystemPanel.Right(21, 3 + ZP_B0, "50", COLOR_LIGHTGRAY, TRUE)
    NEXT
END SUB

SUB CreateCargoPanel() STATIC
    CALL CargoPanel.Init("cargo space", 12, 10, 26, 10, TRUE)
    CALL CargoPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL CargoPanel.Left(11, 1, "cur max metal", COLOR_BLUE, FALSE)
    FOR ZP_B0 = 0 TO 3
        CALL CargoPanel.Left(1, 3 + ZP_B0, ComponentTitle(ZP_B0), COLOR_LIGHTGRAY, TRUE)
        CALL CargoPanel.Right(13, 3 + ZP_B0, GetWord2String(ComponentCapacity(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
        CALL CargoPanel.Right(17, 3 + ZP_B0, GetWord2String(ComponentMaxCapacity(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
        CALL CargoPanel.Right(21, 3 + ZP_B0, GetByte2String(ComponentUpgradeCost(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
    NEXT
END SUB

SUB CreateMapPanel() STATIC
    CALL MapPanel.Init("sector map", 16, 3, 18, 18, TRUE)
    CALL MapPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)
    DIM ScreenAddr AS WORD
    ScreenAddr = $c8b1
    ZP_B1 = COLOR_BLACK
    FOR Y AS WORD = 0 TO 15
        FOR X AS WORD = 0 TO 15
            ZP_B0 = GameMap(SHL(Y, 4) + X)
            IF (ZP_B0 AND %00000100) = 0 THEN
                ' NO STATIONARY OBJECT
                ZP_B2 = 160
                SELECT CASE (ZP_B0 AND %00011000)
                    CASE %00000000 ' NO ASTEROIDS
                        ZP_B1 = COLOR_BLACK
                    CASE %00011000 ' LOW
                        ZP_B1 = COLOR_DARKGRAY
                    CASE %00010000 ' MEDIUM
                        ZP_B1 = COLOR_MIDDLEGRAY
                    CASE %00001000 ' HIGH
                        ZP_B1 = COLOR_LIGHTGRAY
                END SELECT
            ELSE
                ' STATIONARY OBJECT
                SELECT CASE (ZP_B0 AND %00000011)
                    CASE %00000000 ' AI
                        ZP_B1 = COLOR_LIGHTRED
                        ZP_B2 = 90
                    CASE %00000001 ' STAR
                        ZP_B1 = COLOR_YELLOW
                        ZP_B2 = 81
                    CASE %00000010 ' STATION
                        ZP_B3 = SHR(ZP_B0, 5)
                        IF (ZP_B3 = 2) AND (NOT Verge2Found) THEN
                            ZP_B2 = 160
                        ELSE
                            IF ZP_B3 = LocalMapVergeStationId THEN
                                ZP_B1 = COLOR_WHITE
                            ELSE
                                ZP_B1 = COLOR_LIGHTBLUE
                            END IF
                            ZP_B2 = 48 + ZP_B3
                        END IF
                    CASE %00000011 ' SILO
                        ZP_B1 = COLOR_RED
                        ZP_B2 = 86
                END SELECT
            END IF
            POKE ScreenAddr + X, ZP_B2
            POKE ScreenAddr + $1000 + X, ZP_B1
        NEXT X
        ScreenAddr = ScreenAddr + 40
    NEXT Y
END SUB

SUB CreateShieldPanel() STATIC
    CALL ShieldPanel.Init("shield", 11, 14, 26, 8, TRUE)
    CALL ShieldPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL ShieldPanel.Left(11, 1, "cur max metal", COLOR_BLUE, FALSE)

    CALL ShieldPanel.Left(1, 3, "repair", COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Right(13, 3, GetWord2String(ComponentValue(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Right(17, 3, GetWord2String(ComponentCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Right(21, 3, GetWord2String(ComponentPrice(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Left(1, 4, "upgrade", COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Right(13, 4, GetWord2String(ComponentCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Right(17, 4, GetWord2String(ComponentMaxCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL ShieldPanel.Right(21, 4, GetByte2String(ComponentUpgradeCost(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
END SUB

SUB CreateDiplomacyPanel() STATIC
    ArtifactLocation(9) = LOC_SOURCE
    ArtifactLocation(10) = LOC_SOURCE
    ArtifactLocation(11) = LOC_SOURCE

    IF PlayerCredit >= 10000 THEN
        ArtifactLocation(9) = LOC_PLAYER
    END IF
    IF ComponentValue(COMP_METAL) >= 250 THEN
        ArtifactLocation(10) = LOC_PLAYER
    END IF
    IF ComponentValue(COMP_GOLD) >= 500 THEN
        ArtifactLocation(11) = LOC_PLAYER
    END IF

    CALL DiplomacyPanel.Init("diplomacy", 5, 0, 30, 25, TRUE)
    CALL DiplomacyPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL DiplomacyPanel.Center(1, "welcome to verge station " + STR$(LocalMapVergeStationId), COLOR_BLUE, FALSE)

    ArtifactVergeStationId = 255
    IF GameLevel THEN
        IF ArtifactLocation(LocalMapVergeStationId) = LOC_SOURCE THEN
            ArtifactVergeStationId = LocalMapVergeStationId
        END IF
    ELSE
        IF LocalMapVergeStationId = 5 THEN
            IF ArtifactLocation(5) = LOC_SOURCE THEN
                ArtifactVergeStationId = 5
            END IF
        ELSE
            IF ArtifactLocation(1) = LOC_SOURCE THEN
                ArtifactVergeStationId = 1
            END IF
        END IF
    END IF

    IF ArtifactVergeStationId = 255 THEN
        CALL DiplomacyPanel.Center(8, "godspeed commander", COLOR_LIGHTGRAY, TRUE)
    ELSE
        CALL DiplomacyPanel.Center(3, "we can sell you", COLOR_LIGHTGRAY, FALSE)
        CALL DiplomacyPanel.Center(4, ArtifactTitle(ArtifactVergeStationId), COLOR_YELLOW, FALSE)
        CALL DiplomacyPanel.Center(5, "in exchange we want", COLOR_LIGHTGRAY, FALSE)
        CALL DiplomacyPanel.Center(6, ArtifactTitle(ArtifactVergeStationId + 4), COLOR_YELLOW, FALSE)

        CALL DiplomacyPanel.Center(8, "i'll be back", COLOR_LIGHTGRAY, TRUE)
        IF ArtifactLocation(ArtifactVergeStationId + 4) = LOC_PLAYER THEN
            CALL DiplomacyPanel.Center(9, "it's a deal", COLOR_LIGHTGRAY, TRUE)
        END IF
    END IF

    CALL DiplomacyPanel.Center(11, "mission status", COLOR_BLUE, FALSE)

    FOR ZP_B0 = 0 TO 8
        IF (ZP_B0 = 1) OR ((ZP_B0 < 4) AND GameLevel) OR (ArtifactLocation(ZP_B0) > LOC_SOURCE) THEN
            CALL DiplomacyPanel.Left(1, 13+ZP_B0, ArtifactTitle(ZP_B0), COLOR_LIGHTGRAY, TRUE)
            SELECT CASE ArtifactLocation(ZP_B0)
                CASE LOC_SOURCE
                    CALL DiplomacyPanel.Center(22, 13+ZP_B0, "no", COLOR_RED, FALSE)
                CASE LOC_PLAYER
                    CALL DiplomacyPanel.Center(22, 13+ZP_B0, "acquired", COLOR_ORANGE, FALSE)
                CASE LOC_DESTINATION
                    CALL DiplomacyPanel.Center(22, 13+ZP_B0, "delivered", COLOR_GREEN, FALSE)
            END SELECT
        END IF
    NEXT
END SUB

SUB CreateDiscPanel() STATIC
    CALL DiscPanel.Init("disc", 16, 14, 8, 6, TRUE)
    CALL DiscPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT OR EVENT_RIGHT)

    CALL DiscPanel.Left(1, 1, "load", COLOR_LIGHTGRAY, TRUE)
    CALL DiscPanel.Left(1, 2, "save", COLOR_LIGHTGRAY, TRUE)
END SUB

SUB CreateSlotPanel(IsSave AS BYTE) STATIC
    IF IsSave THEN
        CALL SlotPanel.Init("save", 24, 12, 12, 7, TRUE)
    ELSE
        CALL SlotPanel.Init("load", 24, 12, 12, 8, TRUE)
        CALL SlotPanel.Left(1, 4, "autosave", COLOR_LIGHTGRAY, TRUE)
    END IF
    CALL SlotPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL SlotPanel.Left(1, 1, "slot 1", COLOR_LIGHTGRAY, TRUE)
    CALL SlotPanel.Left(1, 2, "slot 2", COLOR_LIGHTGRAY, TRUE)
    CALL SlotPanel.Left(1, 3, "slot 3", COLOR_LIGHTGRAY, TRUE)
END SUB

SUB CreateTradePanel(ComponentId AS BYTE) STATIC
    CALL TradePanel.Init(ComponentTitle(ComponentId), 20, 4 + ComponentId, 20, 9, TRUE)
    CALL TradePanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL TradePanel.Left(1, 1, "buy", COLOR_LIGHTGRAY, TRUE)
    CALL TradePanel.Right(16, 1, GetByte2String(SHL(ComponentPrice(ComponentId), 1), 3), COLOR_LIGHTGRAY, TRUE)
    CALL TradePanel.Left(1, 2, "buy all", COLOR_LIGHTGRAY, TRUE)

    CALL TradePanel.Right(16, 2, GetLong2String(GetBuyAllPrice(ComponentId), 7), COLOR_LIGHTGRAY, TRUE)

    CALL TradePanel.Left(1, 4, "sell", COLOR_LIGHTGRAY, TRUE)
    CALL TradePanel.Right(16, 4, GetByte2String(ComponentPrice(ComponentId), 3), COLOR_LIGHTGRAY, TRUE)
    CALL TradePanel.Left(1, 5, "sell all", COLOR_LIGHTGRAY, TRUE)
    CALL TradePanel.Right(16, 5, GetLong2String(CLONG(ComponentPrice(ComponentId)) * ComponentValue(ComponentId), 7), COLOR_LIGHTGRAY, TRUE)
END SUB

SUB CreateLeftPanel() STATIC
    CALL LeftPanel.Init("verge station " + GetByte2String(LocalMapVergeStationId, 1), 0, 1, 20, 23, FALSE)
    CALL LeftPanel.SetEvents(EVENT_FIRE OR EVENT_RIGHT)

    CALL LeftPanel.Left(0, 1, "trade", COLOR_BLUE, FALSE)

    CALL LeftPanel.Left(15, 1, "cr", COLOR_YELLOW, FALSE)
    CALL LeftPanel.Right(13, 1, GetLong2String(PlayerCredit, 7), COLOR_YELLOW, FALSE)

    CALL LeftPanel.Left(1, 3, "         cur max", COLOR_BLUE, FALSE)
    FOR ZP_B0 = 0 TO 3
        CALL LeftPanel.Left(1, 4 + ZP_B0, ComponentTitle(ZP_B0), COLOR_LIGHTGRAY, TRUE)
        CALL LeftPanel.Left(10, 4 + ZP_B0, GetWord2String(ComponentValue(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
        CALL LeftPanel.Left(14, 4 + ZP_B0, GetWord2String(ComponentCapacity(ZP_B0), 3), COLOR_LIGHTGRAY, TRUE)
    NEXT

    CALL LeftPanel.Left(0, 10, "station services", COLOR_BLUE, FALSE)
    CALL LeftPanel.Left(1, 12, "system upgrades", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 13, "shields", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 14, "cargo space", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 15, "sector map", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 16, "diplomacy", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 17, "disc", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 19, "launch", COLOR_RED, TRUE)
END SUB

SUB MissionBriefingHandler() STATIC
    DIM Panel AS UiPanel

    CALL DrawDesktop($30)
    CALL Panel.Init("mission briefing", 1, 1, 38, 23, FALSE)
    CALL Panel.SetEvents(EVENT_FIRE)
    Panel.Selected = 19

    CALL Panel.Left(1, 1, "status", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 3, "elvin the hacker has build", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 4, "a singularity generator to", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 5, "assure unlimited energy source", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 6, "and world domination", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 8, "warning!", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 10, "cosmic projections indicate", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 11, "possibility of runaway singularity", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 12, "resulting in supercluster", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 13, "destruction", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 15, "elvin has deployed ai missile", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 16, "silos to block interception", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Center(19, "press fire", COLOR_LIGHTGRAY, TRUE)

    CALL Panel.WaitEvent(FALSE)

    CALL Panel.Draw(TRUE, TRUE)

    CALL Panel.Left(1, 1, "acquire", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(6, 4, ArtifactTitle(1), COLOR_LIGHTGRAY, FALSE)
    IF GameLevel THEN
        CALL Panel.Left(6, 3, ArtifactTitle(0), COLOR_LIGHTGRAY, FALSE)
        CALL Panel.Left(6, 5, ArtifactTitle(2), COLOR_LIGHTGRAY, FALSE)
        CALL Panel.Left(6, 6, ArtifactTitle(3), COLOR_LIGHTGRAY, FALSE)
    END IF
    CALL Panel.Left(1, 8, "to build a singularity diffuser", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 10, "intelligence reports that", COLOR_LIGHTGRAY, FALSE)
    IF GameLevel THEN
        CALL Panel.Left(1, 11, "components are available in nearby", COLOR_LIGHTGRAY, FALSE)
        CALL Panel.Left(1, 12, "space stations", COLOR_LIGHTGRAY, FALSE)

        CALL Panel.Left(1, 14, "negotiate with space stations and", COLOR_LIGHTGRAY, FALSE)
        CALL Panel.Left(1, 15, "bring parts back to verge", COLOR_LIGHTGRAY, FALSE)
    ELSE
        CALL Panel.Left(1, 11, "babbage siphon is available at", COLOR_LIGHTGRAY, FALSE)
        CALL Panel.Left(1, 12, "multiple verge stations, but they", COLOR_LIGHTGRAY, FALSE)
        CALL Panel.Left(1, 13, "want fusion aligner in exchange", COLOR_LIGHTGRAY, FALSE)

        CALL Panel.Left(1, 15, "bring babbage siphon to verge", COLOR_LIGHTGRAY, FALSE)
    END IF
    CALL Panel.Left(1, 16, "station 5 before runaway", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 17, "singularity destroys spacetime", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Center(19, "press fire", COLOR_LIGHTGRAY, TRUE)

    CALL Panel.WaitEvent(FALSE)
END SUB

SUB Map_AddRandom(Item AS BYTE) SHARED STATIC
    DO
        ZP_B0 = RNDB()
        IF (ZP_B0 < 133 OR ZP_B0 > 136) AND (GameMap(ZP_B0) AND %11100111) = 0 THEN
            GameMap(ZP_B0) = GameMap(ZP_B0) OR Item
            EXIT SUB
        END IF
    LOOP
END SUB

GOTO SkipAsm
InterruptHandlerPlaySid:
    ASM
        jsr $1003
    END ASM
    RETURN
SkipAsm:

_ArtifactTitle:
DATA AS STRING * 15 "neuman binder"
DATA AS STRING * 15 "babbage siphon"
DATA AS STRING * 15 "laplace reactor"
DATA AS STRING * 15 "fermi entangler"
DATA AS STRING * 15 "flux positioner"
DATA AS STRING * 15 "fusion aligner"
DATA AS STRING * 15 "entropy emitter"
DATA AS STRING * 15 "quantum colloid"
DATA AS STRING * 15 "positronic ai"
DATA AS STRING * 15 "10 000 cr"
DATA AS STRING * 15 "250 metals"
DATA AS STRING * 15 "500 gold"

_ComponentTitle:
DATA AS STRING * 6 "gold"
DATA AS STRING * 6 "metal"
DATA AS STRING * 6 "fuel"
DATA AS STRING * 6 "oxygen"
DATA AS STRING * 6 "armor"

_SubSystemTitle:
DATA AS STRING * 6 "weapon"
DATA AS STRING * 6 "engine"
DATA AS STRING * 6 "gyro"

_SaveFileName:
DATA AS STRING*8 "save0001"
DATA AS BYTE 0
DATA AS STRING*8 "save0002"
DATA AS BYTE 0
DATA AS STRING*8 "save0003"
DATA AS BYTE 0
DATA AS STRING*8 "autosave"
DATA AS BYTE 0

_ReplaceFileName:
DATA AS STRING*10 "@:save0001"
DATA AS BYTE 0
DATA AS STRING*10 "@:save0002"
DATA AS BYTE 0
DATA AS STRING*10 "@:save0003"
DATA AS BYTE 0
DATA AS STRING*10 "@:autosave"
DATA AS BYTE 0


_ComponentInitialCapacity:
DATA AS WORD 150, 150, 150, 150, 50

_ComponentInitialValue:
DATA AS WORD 0, 10, 150, 150, 50

_ComponentInitialCapacityEasy:
DATA AS WORD 300, 300, 300, 300, 150

_ComponentInitialValueEasy:
DATA AS WORD 0, 20, 300, 300, 150

_ComponentPrice:
DATA AS BYTE  60, 40, 10, 14, 1

_ComponentUpgradeCost:
DATA AS BYTE 1, 1, 1, 1, 3

_ComponentMaxCapacity:
DATA AS WORD 999, 999, 999, 999, 250

_GameMap:
DATA AS BYTE $00, $00, $00, $00, $18, $18, $18, $18, $18, $18, $1f, $1f, $1f, $18, $00, $00
DATA AS BYTE $00, $00, $18, $18, $18, $18, $10, $10, $10, $18, $18, $18, $18, $18, $18, $00
DATA AS BYTE $00, $18, $18, $1e, $18, $18, $10, $36, $10, $10, $10, $10, $18, $18, $18, $00
DATA AS BYTE $00, $18, $18, $18, $18, $18, $10, $10, $10, $08, $08, $08, $10, $18, $18, $18
DATA AS BYTE $18, $18, $18, $18, $18, $10, $10, $10, $08, $08, $ee, $08, $10, $18, $18, $18
DATA AS BYTE $18, $18, $18, $10, $10, $10, $10, $10, $10, $08, $08, $08, $10, $10, $18, $18
DATA AS BYTE $18, $18, $10, $10, $10, $18, $18, $18, $18, $10, $10, $08, $10, $10, $18, $18
DATA AS BYTE $18, $18, $10, $10, $10, $18, $18, $18, $18, $18, $10, $10, $10, $18, $18, $18
DATA AS BYTE $18, $18, $10, $10, $18, $18, $be, $18, $18, $18, $18, $18, $18, $18, $18, $18
DATA AS BYTE $18, $18, $18, $10, $10, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00
DATA AS BYTE $18, $18, $18, $18, $10, $10, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00
DATA AS BYTE $18, $18, $18, $18, $18, $10, $18, $18, $18, $18, $18, $18, $18, $9e, $18, $00
DATA AS BYTE $00, $18, $18, $de, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00
DATA AS BYTE $00, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00, $00
DATA AS BYTE $00, $00, $18, $18, $18, $18, $18, $18, $18, $18, $1f, $1f, $1f, $18, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $66, $07, $00, $00, $00

SID:
INCBIN "../sfx/Driven_20.zx0"

KRILL_SAVE:
INCBIN "../loader/save-c64.zx0"
