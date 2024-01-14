OPTION FASTINTERRUPT
SYSTEM INTERRUPT OFF

INCLUDE "../libs/lib_common.bas"
INCLUDE "../libs/lib_str.bas"
INCLUDE "../libs/lib_gfx.bas"
INCLUDE "../libs/lib_joy.bas"
INCLUDE "../libs/lib_ui.bas"
INCLUDE "../libs/lib_rnd.bas"
INCLUDE "../libs/lib_sid.bas"

DIM ArtifactTitle(12) AS STRING * 15 @_ArtifactTitle
DIM ComponentTitle(5) AS STRING * 6 @_ComponentTitle
DIM SubSystemTitle(2) AS STRING * 6 @_SubSystemTitle
DIM ComponentInitialCapacity(5) AS WORD @_ComponentInitialCapacity
DIM ComponentInitialValue(5) AS WORD @_ComponentInitialValue
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

DECLARE SUB DrawDesktop() STATIC
DECLARE SUB MissionBriefingHandler() STATIC
DECLARE SUB SetupGraphics() STATIC
DECLARE SUB CreateLeftPanel() STATIC
DECLARE SUB CreateSystemPanel() STATIC
DECLARE SUB CreateTradePanel(ComponentId AS BYTE) STATIC
DECLARE SUB CreateCargoPanel() STATIC
DECLARE SUB CreateShieldPanel() STATIC
DECLARE SUB CreateDiplomacyPanel() STATIC
DECLARE SUB CreateDiscPanel() STATIC
DECLARE FUNCTION GetBuyAllPrice AS LONG(ComponentId AS BYTE) STATIC

MEMCPY @SID_Driven_20, $1000, @SID_END_Driven_20 - @SID_Driven_20
ASM
    lda #0
    jsr $1000
END ASM

ON TIMER 17095 GOSUB InterruptHandlerPlaySid
TIMER INTERRUPT ON

CALL SetupGraphics()

IF GameState = GAMESTATE_MISSIONBRIEFING THEN
    CALL MissionBriefingHandler()
    GameState = GAMESTATE_PLAYING
    PlayerCredit = 10000
    LocalMapVergeStationId = 5
    FOR ZP_B0 = 0 TO 4
        ComponentCapacity(ZP_B0) = ComponentInitialCapacity(ZP_B0)
        ComponentValue(ZP_B0) = ComponentInitialValue(ZP_B0)
    NEXT
    FOR ZP_B0 = 0 TO 2
        PlayerSubSystem(ZP_B0) = 0
    NEXT
END IF

CALL DrawDesktop()
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
            CASE 16 ' diplomacy
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateDiplomacyPanel()
                CALL DiplomacyPanel.SetSelected(1)
                GOTO DiplomacyPanelHandler
            CASE 17 ' disc
                CALL LeftPanel.SetFocus(FALSE)
                CALL CreateDiscPanel()
                CALL DiscPanel.SetSelected(1)
                GOTO DiscPanelHandler
            CASE 19 ' launch
                'CALL SetBitmapMemory(1)
                CALL FillBitmap(0)
                CALL FillColors(COLOR_BLACK, COLOR_ORANGE)
                CALL SetGraphicsMode(STANDARD_BITMAP_MODE)

                CALL Text(7, 2, 1, 0, TRUE, "skymax", $c000)
                CALL Text(13, 5, 1, 0, TRUE, "launch sequence", $c000)
                CALL Text(15, 7, 1, 0, FALSE, "initiated", $c000)

                CALL SidStop()

                CALL LoadProgram("space", CWORD(4096))
        END SELECT
    LOOP

DiplomacyPanelHandler:
    CALL DiplomacyPanel.SetFocus(TRUE)

    DO
        CALL DiplomacyPanel.WaitEvent(FALSE)

        SELECT CASE DiplomacyPanel.Event
            CASE EVENT_LEFT
                CALL DiplomacyPanel.Dispose()
                GOTO LeftPanelHandler
            CASE EVENT_FIRE
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
            CASE EVENT_FIRE
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

SELECT CASE GameState
    CASE GAMESTATE_COMPLETED
        CALL LoadProgram("completed", CWORD(8192))
    CASE GAMESTATE_PLAYING

END SELECT

END

REM ********************************
REM * ROUTINES
REM ********************************

SUB SetupGraphics() STATIC
    BORDER COLOR_BLACK
    BACKGROUND COLOR_BLACK
    CALL SetVideoBank(3)
    CALL SetCharacterMemory(0)
    CALL SetScreenMemory(2)
    SCREEN 2
    MEMSET $c800, 1000, 32
    MEMSET $d800, 1000, 1

    CALL SetGraphicsMode(STANDARD_CHARACTER_MODE)
END SUB

SUB DrawDesktop() STATIC
    CALL UiLattice(0, 0, 40, 25, $30+LocalMapVergeStationId, $30+LocalMapVergeStationId, COLOR_BLUE, COLOR_DARKGRAY)
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
    CALL DiplomacyPanel.Init("diplomacy", 11, 14, 26, 8, TRUE)
    CALL DiplomacyPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL DiplomacyPanel.Left(11, 1, "cur max metal", COLOR_BLUE, FALSE)

    CALL DiplomacyPanel.Left(1, 3, "repair", COLOR_LIGHTGRAY, TRUE)
    CALL DiplomacyPanel.Right(13, 3, GetWord2String(ComponentValue(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL DiplomacyPanel.Right(17, 3, GetWord2String(ComponentCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL DiplomacyPanel.Right(21, 3, GetWord2String(ComponentPrice(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
END SUB

SUB CreateDiscPanel() STATIC
    CALL DiscPanel.Init("disc", 11, 14, 26, 8, TRUE)
    CALL DiscPanel.SetEvents(EVENT_FIRE OR EVENT_LEFT)

    CALL DiscPanel.Left(11, 1, "cur max metal", COLOR_BLUE, FALSE)

    CALL DiscPanel.Left(1, 3, "repair", COLOR_LIGHTGRAY, TRUE)
    CALL DiscPanel.Right(13, 3, GetWord2String(ComponentValue(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL DiscPanel.Right(17, 3, GetWord2String(ComponentCapacity(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
    CALL DiscPanel.Right(21, 3, GetWord2String(ComponentPrice(COMP_ARMOR), 3), COLOR_LIGHTGRAY, TRUE)
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
    CALL LeftPanel.Left(1, 13, "armor", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 14, "cargo space", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 16, "diplomacy", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 17, "disc", COLOR_LIGHTGRAY, TRUE)
    CALL LeftPanel.Left(1, 19, "launch", COLOR_RED, TRUE)
END SUB

SUB MissionBriefingHandler() STATIC
    DIM Panel AS UiPanel

    CALL DrawDesktop()
    CALL Panel.Init("mission briefing", 1, 1, 38, 23, FALSE)
    CALL Panel.SetEvents(EVENT_FIRE)
    Panel.Selected = 19

    CALL Panel.Left(1, 1, "status", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 3, "elvin atombender's terrorist", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 4, "organisation has captured core", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 5, "density singularity to assure", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 6, "unlimited energy source and world", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 7, "domination", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 9, "warning!", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 11, "cosmic projections indicate", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 12, "possibility of runaway singularity", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 13, "resulting in supercluster", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 14, "destruction", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 16, "elvin has deployed ai missile", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 17, "silos to block interception", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Center(19, "press fire", COLOR_LIGHTGRAY, TRUE)

    CALL Panel.WaitEvent(FALSE)

    CALL Panel.Draw(TRUE, TRUE)

    CALL Panel.Left(1, 1, "acquire", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(6, 3, ArtifactTitle(0), COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(6, 4, ArtifactTitle(1), COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(6, 5, ArtifactTitle(2), COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(6, 6, ArtifactTitle(3), COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 8, "build a singularity diffuser", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 10, "intelligence reports that", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 11, "components are available in nearby", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 12, "space stations", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Left(1, 14, "negotiate with space stations and", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 15, "bring parts to verge station 5", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 16, "before runaway singularity", COLOR_LIGHTGRAY, FALSE)
    CALL Panel.Left(1, 17, "destroys spacetime", COLOR_LIGHTGRAY, FALSE)

    CALL Panel.Center(19, "press fire", COLOR_LIGHTGRAY, TRUE)

    CALL Panel.WaitEvent(FALSE)

    CALL DrawDesktop()
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

_ComponentInitialCapacity:
DATA AS WORD 150, 150, 150, 150, 50

_ComponentInitialValue:
DATA AS WORD 0, 0, 150, 150, 50

_ComponentPrice:
DATA AS BYTE  60, 40, 10, 15, 1

_ComponentUpgradeCost:
DATA AS BYTE 1, 1, 1, 1, 3

_ComponentMaxCapacity:
DATA AS WORD 999, 999, 999, 999, 250

SID_Driven_20:
INCBIN "../sfx/Driven_20.bin"
SID_END_Driven_20:
