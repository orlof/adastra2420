SHARED CONST WIN_ACTIVE = 1
SHARED CONST WIN_NOT_ACTIVE = 12

CONST NO_SELECTION = $ff

CONST CH_HLINE = 64
CONST CH_VLINE = 93

CONST CH_NW_CORNER = 112
CONST CH_NE_CORNER = 110
CONST CH_SW_CORNER = 109
CONST CH_SE_CORNER = 125

DIM InventorySelected AS BYTE
DIM ShipyardSelected AS BYTE
DIM SystemSelected AS BYTE
DIM MarketSelected AS BYTE
DIM LaunchSelected AS BYTE
DIM LoadSaveSelected AS BYTE
DIM NegotiateSelected AS BYTE

DIM SystemTitle(5) AS STRING * 6 @_SystemTitle 
DIM SystemItems(5) AS BYTE @_SystemItems

DIM BuyAllCache AS LONG

SUB DrawFrame(Active AS BYTE, Title AS STRING * 24, x0 AS BYTE, y0 AS BYTE, x1 AS BYTE, y1 AS BYTE) SHARED STATIC
    ZP_B1 = x0 + LEN(Title)
    FOR ZP_B0 = x0+1 TO x1-1
        IF ZP_B0 > ZP_B1 THEN CHARAT ZP_B0, y0, CH_HLINE, Active
        CHARAT ZP_B0, y1, CH_HLINE, Active
    NEXT
    FOR ZP_B0 = y0+1 TO y1-1
        CHARAT x0, ZP_B0, CH_VLINE, Active
        CHARAT x1, ZP_B0, CH_VLINE, Active
    NEXT
    CHARAT x0, y0, CH_NW_CORNER, Active
    CHARAT x1, y0, CH_NE_CORNER, Active
    CHARAT x0, y1, CH_SW_CORNER, Active
    CHARAT x1, y1, CH_SE_CORNER, Active
    IF LEN(Title) > 0 THEN
        TEXTAT x0+1, y0, Title, Active
    END IF
END SUB

SUB InvertText(x0 AS BYTE, x1 AS BYTE, y AS BYTE, Invert AS BYTE) SHARED STATIC
    ASM
        ;ZP_W0 = 1024 + 40 * CWORD(y) + x0
        lda #0
        sta {ZP_W0}+1
        lda {y}
        ldy #5
loop_x32        
        asl
        rol {ZP_W0}+1
        dey
        bne loop_x32
        sta {ZP_W0}

        lda {y}
        asl
        asl
        asl

        clc
        adc {x0}
        adc {ZP_W0}
        sta {ZP_W0}
        lda {ZP_W0}+1
        adc #4
        sta {ZP_W0}+1

        ;FOR ZP_W1 = ZP_W0 TO ZP_W0 + x1 - x0
        ;   IF Invert THEN
        ;        POKE ZP_W1, PEEK(ZP_W1) OR 128
        ;   ELSE
        ;        POKE ZP_W1, PEEK(ZP_W1) AND 127
        ;   END IF
        ;NEXT
        sec
        lda {x1}
        sbc {x0}
        tay
invert_loop
        lda ({ZP_W0}),y
        ldx {Invert}
        beq invert_no
        ora #128
        jmp invert_end
invert_no
        and #127
invert_end
        sta ({ZP_W0}),y
        dey
        bpl invert_loop
    END ASM
END SUB

SUB DrawCredits() SHARED STATIC
    CALL StringBuilder_Clear(17)
    CALL StringBuilder_Right(13, PlayerCredit)
    CALL StringBuilder_Left(15, "Cr")
    TEXTAT 21, 1, StringBuilder
END SUB

SUB DrawInventory(Active AS BYTE, Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(Active, "Inventory", 1, 2, 19, 8)
    FOR ZP_B0 = 0 TO 3
        ZP_B1 = 4 + ZP_B0

        CALL StringBuilder_Clear(17)
        CALL StringBuilder_Left(0, ComponentTitle(ZP_B0))
        CALL StringBuilder_Right(11, ComponentValue(ZP_B0))
        CALL StringBuilder_Right(16, ComponentCapacity(ZP_B0))
        TEXTAT 2, 4 + ZP_B0, StringBuilder

        CALL InvertText(2, 18, 4 + ZP_B0, ZP_B0 = Selected)
    NEXT
END SUB

SUB DrawMarket(Active AS BYTE, Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(Active, ComponentTitle(InventorySelected), 20, 2, 38, 8)

    CALL StringBuilder_Clear(17)
    CALL StringBuilder_Left(0, "Buy")
    CALL StringBuilder_Right(16, 2 * ComponentPrice(InventorySelected))
    TEXTAT 21, 4, StringBuilder

    CALL StringBuilder_Clear(17)
    CALL StringBuilder_Left(0, "Buy All")
    BuyAllCache = PlayerCredit / SHL(ComponentPrice(InventorySelected), 1)
    ZP_L1 = ComponentCapacity(InventorySelected) - ComponentValue(InventorySelected)
    IF ZP_L1 < BuyAllCache THEN BuyAllCache = ZP_L1
    CALL StringBuilder_Right(16, 2 * ComponentPrice(InventorySelected) * BuyAllCache)
    TEXTAT 21, 5, StringBuilder

    CALL StringBuilder_Clear(17)
    CALL StringBuilder_Left(0, "Sell")
    CALL StringBuilder_Right(16, ComponentPrice(InventorySelected))
    TEXTAT 21, 6, StringBuilder

    CALL StringBuilder_Clear(17)
    CALL StringBuilder_Left(0, "Sell All")
    CALL StringBuilder_Right(16, ComponentPrice(InventorySelected) * ComponentValue(InventorySelected))
    TEXTAT 21, 7, StringBuilder

    FOR ZP_B0 = 0 TO 3
        CALL InvertText(21, 37, 4 + ZP_B0, ZP_B0 = Selected)
    NEXT
END SUB

SUB DrawShipyard(Active AS BYTE, Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(Active, "Shipyard", 1, 10, 19, 17)

    FOR ZP_B0 = 0 TO 4
        TEXTAT 2, 12 + ZP_B0, SystemTitle(ZP_B0)
        CALL InvertText(2, 18, 12 + ZP_B0, ZP_B0 = Selected)
    NEXT
END SUB

SUB DrawSystem(Active AS BYTE, Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(Active, SystemTitle(ShipyardSelected), 20, 10, 38, 17)
    SELECT CASE ShipyardSelected
        CASE 0, 1, 2 'WEAPON, ENGINE, GYRO
            CALL StringBuilder_Clear(17)
            TEXTAT 21, 11, StringBuilder
            TEXTAT 21, 13, StringBuilder
            TEXTAT 21, 15, StringBuilder
            TEXTAT 21, 16, StringBuilder

            CALL StringBuilder_Left(0, "Installed")
            CALL StringBuilder_Right(16, PlayerSubSystem(ShipyardSelected))
            TEXTAT 21, 12, StringBuilder

            CALL StringBuilder_Clear(17)
            CALL StringBuilder_Left(0, "Upgrade")
            IF PlayerSubSystem(ShipyardSelected) < 9 THEN
                CALL StringBuilder_Right(16, 50)
            ELSE
                CALL StringBuilder_Right(16, "MAX")
            END IF
            TEXTAT 21, 14, StringBuilder
            CALL InvertText(21, 37, 14, Selected=0)

        CASE 3 'ARMOR
            CALL StringBuilder_Clear(17)
            CALL StringBuilder_Left(0, "Current")
            CALL StringBuilder_Right(16, ComponentValue(COMP_ARMOR))
            TEXTAT 21, 12, StringBuilder

            CALL StringBuilder_Clear(17)
            CALL StringBuilder_Left(0, "Maximum")
            CALL StringBuilder_Right(16, ComponentCapacity(COMP_ARMOR))
            TEXTAT 21, 13, StringBuilder

            CALL StringBuilder_Clear(17)
            TEXTAT 21, 14, StringBuilder
            TEXTAT 21, 16, StringBuilder

            CALL StringBuilder_Clear(17)
            CALL StringBuilder_Left(0, "Repair")
            IF ComponentValue(COMP_ARMOR) < ComponentCapacity(COMP_ARMOR) THEN
                CALL StringBuilder_Right(16, ComponentPrice(COMP_ARMOR))
            ELSE
                CALL StringBuilder_Right(16, "MAX")
            END IF
            TEXTAT 21, 15, StringBuilder

            CALL StringBuilder_Clear(17)
            CALL StringBuilder_Left(0, "Upgrade")
            IF ComponentCapacity(COMP_ARMOR) < ComponentMaxCapacity(COMP_ARMOR) THEN
                CALL StringBuilder_Right(16, ComponentUpgradeCost(COMP_ARMOR))
            ELSE
                CALL StringBuilder_Right(16, "MAX")
            END IF
            TEXTAT 21, 16, StringBuilder

            FOR ZP_B0 = 0 TO 1
                CALL InvertText(21, 37, 15 + ZP_B0, Selected = ZP_B0)
            NEXT

        CASE 4 'CARGO
            CALL StringBuilder_Clear(17)
            TEXTAT 21, 12, StringBuilder

            IF Selected = NO_SELECTION THEN
                TEXTAT 21, 11, StringBuilder
            ELSE
                CALL StringBuilder_Left(0, "Installed")
                CALL StringBuilder_Right(16, ComponentCapacity(Selected))
                TEXTAT 21, 11, StringBuilder
            END IF

            FOR ZP_B0 = 0 TO 3
                CALL StringBuilder_Clear(17)
                CALL StringBuilder_Left(0, ComponentTitle(ZP_B0))
                IF ComponentCapacity(ZP_B0) < ComponentMaxCapacity(ZP_B0) THEN
                    CALL StringBuilder_Right(16, ComponentUpgradeCost(ZP_B0))
                ELSE
                    CALL StringBuilder_Right(16, "MAX")
                END IF
                TEXTAT 21, 13 + ZP_B0, StringBuilder
                CALL InvertText(21, 37, 13 + ZP_B0, Selected = ZP_B0)
            NEXT
    END SELECT
END SUB

SUB Draw_Mission(Active AS BYTE, Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(Active, "Mission", 1, 19, 19, 23)

    TEXTAT 2, 21, "Negotiate"
    TEXTAT 2, 22, "Launch"

    FOR ZP_B0 = 0 TO 1
        CALL InvertText(2, 18, 21 + ZP_B0, ZP_B0 = Selected)
    NEXT
END SUB

SUB Draw_Negotiate(Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(TRUE, "Station Command", 5, 0, 34, 11)

    IF ArtifactLocation(LocalMapVergeStationId) = LOC_SOURCE THEN
        TEXTAT 7, 2, "We can sell you "
        TEXTAT 9, 3, ArtifactTitle(LocalMapVergeStationId)
        TEXTAT 7, 5, "In exchange we want"
        TEXTAT 9, 6, ArtifactTitle(LocalMapVergeStationId+4)

        TEXTAT 8, 8, "Leave"
        IF ArtifactLocation(LocalMapVergeStationId+4) = LOC_PLAYER THEN
            TEXTAT 8, 9, "Agree"
        END IF
        FOR ZP_B0 = 0 TO 1
            CALL InvertText(7, 14, 8 + ZP_B0, ZP_B0 = Selected)
        NEXT
    ELSE
        TEXTAT 7, 4, "Godspeed Commander"
        TEXTAT 7, 6, "Leave"
        CALL InvertText(6, 15, 6, TRUE)
    END IF
END SUB

SUB Draw_Progress() SHARED STATIC
    CALL DrawFrame(TRUE, "Mission Status", 5, 13, 34, 23)

    FOR ZP_B0 = 0 TO 8
        IF ZP_B0 < 4 OR ArtifactLocation(ZP_B0) > LOC_SOURCE THEN
            TEXTAT 7, 14+ZP_B0, ArtifactTitle(ZP_B0)
            SELECT CASE ArtifactLocation(ZP_B0)
                CASE LOC_SOURCE
                    TEXTAT 25, 14+ZP_B0, "No"
                CASE LOC_PLAYER
                    TEXTAT 25, 14+ZP_B0, "Acquired"
                CASE LOC_DESTINATION
                    TEXTAT 25, 14+ZP_B0, "Delivered"
            END SELECT            
        END IF
    NEXT
END SUB

SUB DrawLoadSave(Active AS BYTE, Selected AS BYTE) SHARED STATIC
    CALL DrawFrame(Active, "Disc", 20, 19, 38, 23)
    TEXTAT 21, 21, "Load"
    TEXTAT 21, 22, "Save"

    FOR ZP_B0 = 0 TO 1
        CALL InvertText(21, 37, 21 + ZP_B0, ZP_B0 = Selected)
    NEXT
END SUB

SUB MessageShow() SHARED STATIC
    CALL Text.Focus()
    CALL Text.Fill(32, COLOR_LIGHTGRAY)
    CALL Text.Show()

    CALL DrawFrame(WIN_ACTIVE, "Priority Message", 0, 0, 39, 24)

    TEXTAT 3, 3, "STATUS"
    TEXTAT 3, 5, "ROSCOS TERRORIST CELL HAS CAPTURED"
    TEXTAT 3, 6, "RESEARCH STATION TO HARNESS CORE" 
    TEXTAT 3, 7, "DENSITY SINGULARITY AND ASSURE"
    TEXTAT 3, 8, "UNLIMITED ENERGY SOURCE AND WORLD"
    TEXTAT 3, 9, "DOMINATION"

    TEXTAT 3, 11, "WARNING!"
    TEXTAT 3, 13, "COSMIC PROJECTIONS INDICATE"
    TEXTAT 3, 14, "POSSIBILITY OF RUNAWAY SINGULARITY"
    TEXTAT 3, 15, "RESULTING IN SUPERCLUSTER"
    TEXTAT 3, 16, "DESTRUCTION"

    TEXTAT 3, 18, "ROSCOS DEPLOYED AI MISSILE SILOS"
    TEXTAT 3, 19, "TO BLOCK INTERCEPTION"

    TEXTAT 3, 21, "Press Fire"

    CALL Joy1.WaitClick()

    CALL Text.Fill(32, COLOR_LIGHTGRAY)
    CALL DrawFrame(WIN_ACTIVE, "Your Mission", 0, 0, 39, 24)

    TEXTAT 3, 3, "ACQUIRE"
    TEXTAT 6, 5, ArtifactTitle(0)
    TEXTAT 6, 6, ArtifactTitle(1)
    TEXTAT 6, 7, ArtifactTitle(2)
    TEXTAT 6, 8, ArtifactTitle(3)
    TEXTAT 3, 10, "BUILD A SINGULARITY DIFFUSER"

    TEXTAT 3, 12, "INTELLIGENCE REPORTS THAT"
    TEXTAT 3, 13, "COMPONENTS ARE AVAILABLE IN NEARBY"
    TEXTAT 3, 14, "SPACE STATIONS"

    TEXTAT 3, 16, "NEGOTIATE WITH SPACE STATIONS AND"
    TEXTAT 3, 17, "BRING PARTS TO VERGE STATION 5"
    TEXTAT 3, 18, "BEFORE RUNAWAY SINGULARITY"
    TEXTAT 3, 19, "DESTROYS SPACETIME"

    TEXTAT 3, 21, "Press Fire"

    CALL Joy1.WaitClick()
END SUB

SUB VergeShow() SHARED STATIC
    DIM Action AS BYTE

    CALL Text.Focus()
    CALL Text.Show()
    'POKE 53272,23

SHOW_MENU:
    InventorySelected = 0
    ShipyardSelected = 0
    MarketSelected = 0
    LaunchSelected = 0
    LoadSaveSelected = 0

    CALL Text.Fill(32, COLOR_LIGHTGRAY)

    CALL StringBuilder_Clear(15)
    CALL StringBuilder_Left(0, "Verge Station")
    CALL StringBuilder_Right(14, STR$(LocalMapVergeStationId))
    CALL DrawFrame(WIN_NOT_ACTIVE, StringBuilder, 0, 0, 39, 24)

    CALL DrawCredits()
    CALL DrawInventory(WIN_ACTIVE, NO_SELECTION)
    CALL DrawMarket(WIN_NOT_ACTIVE, NO_SELECTION)
    CALL DrawShipyard(WIN_NOT_ACTIVE, NO_SELECTION)
    CALL DrawSystem(WIN_NOT_ACTIVE, NO_SELECTION)
    CALL Draw_Mission(WIN_NOT_ACTIVE, NO_SELECTION)
    CALL DrawLoadSave(WIN_NOT_ACTIVE, NO_SELECTION)

WIN_INVENTORY:
    DO
        CALL DrawInventory(WIN_ACTIVE, InventorySelected)
        CALL DrawMarket(WIN_NOT_ACTIVE, NO_SELECTION)
        
        Action = Joy1.WaitSingleAction()
        SELECT CASE Action
            CASE JOY_UP
                IF InventorySelected > 0 THEN
                    InventorySelected = InventorySelected - 1
                END IF
            CASE JOY_RIGHT
                CALL DrawInventory(WIN_NOT_ACTIVE, InventorySelected)
                GOTO WIN_MARKET
            CASE JOY_DOWN
                IF InventorySelected < 3 THEN
                    InventorySelected = InventorySelected + 1
                ELSE
                    CALL DrawInventory(WIN_NOT_ACTIVE, NO_SELECTION)
                    'CALL DrawMarket(WIN_NOT_ACTIVE, NO_SELECTION)
                    GOTO WIN_SHIPYARD
                END IF
        END SELECT
    LOOP

WIN_MARKET:
    MarketSelected = 0
    DO
        CALL DrawMarket(WIN_ACTIVE, MarketSelected)
        
        Action = Joy1.WaitSingleAction()
        SELECT CASE Action
            CASE JOY_LEFT
                CALL DrawMarket(WIN_NOT_ACTIVE, MarketSelected)
                GOTO WIN_INVENTORY
            CASE JOY_DOWN
                IF MarketSelected < 3 THEN
                    MarketSelected = MarketSelected + 1
                END IF
            CASE JOY_UP
                IF MarketSelected > 0 THEN
                    MarketSelected = MarketSelected - 1
                END IF
            CASE JOY_FIRE
                DO
                    SELECT CASE MarketSelected
                        CASE 0
                            'Buy
                            IF ComponentValue(InventorySelected) < ComponentCapacity(InventorySelected) THEN
                                ZP_W0 = 2 * ComponentPrice(InventorySelected)
                                IF PlayerCredit >= ZP_W0 THEN
                                    ComponentValue(InventorySelected) = ComponentValue(InventorySelected) + 1
                                    PlayerCredit = PlayerCredit - ZP_W0
                                    CALL DrawCredits()
                                    CALL DrawInventory(WIN_NOT_ACTIVE, InventorySelected)
                                END IF
                            END IF
                        CASE 1
                            'Buy All
                            ZP_L0 = 2 * ComponentPrice(InventorySelected) * BuyAllCache
                            ComponentValue(InventorySelected) = ComponentValue(InventorySelected) + BuyAllCache
                            PlayerCredit = PlayerCredit - ZP_L0 
                            CALL DrawCredits()
                            CALL DrawInventory(WIN_NOT_ACTIVE, InventorySelected)
                        CASE 2
                            'Sell
                            IF ComponentValue(InventorySelected) > 0 THEN
                                ComponentValue(InventorySelected) = ComponentValue(InventorySelected) - 1
                                PlayerCredit = PlayerCredit + ComponentPrice(InventorySelected)
                                CALL DrawCredits()
                                CALL DrawInventory(WIN_NOT_ACTIVE, InventorySelected)
                            END IF
                        CASE 3
                            'Sell All
                            PlayerCredit = PlayerCredit + ComponentPrice(InventorySelected) * ComponentValue(InventorySelected)
                            ComponentValue(InventorySelected) = 0
                            CALL DrawCredits()
                            CALL DrawInventory(WIN_NOT_ACTIVE, InventorySelected)
                    END SELECT
                    CALL WaitRasterLine256()
                    CALL DrawMarket(WIN_ACTIVE, MarketSelected)
                    CALL Joy1.Update()
                LOOP WHILE Joy1.Button()
        END SELECT
    LOOP

WIN_SHIPYARD:
    DO
        CALL DrawShipyard(WIN_ACTIVE, ShipyardSelected)
        CALL DrawSystem(WIN_NOT_ACTIVE, NO_SELECTION)

        Action = Joy1.WaitSingleAction()
        SELECT CASE Action
            CASE JOY_UP
                IF ShipyardSelected > 0 THEN
                    ShipyardSelected = ShipyardSelected - 1
                ELSE
                    CALL DrawShipyard(WIN_NOT_ACTIVE, NO_SELECTION)
                    GOTO WIN_INVENTORY
                END IF
            CASE JOY_DOWN
                IF ShipyardSelected < 4 THEN
                    ShipyardSelected = ShipyardSelected + 1
                ELSE
                    CALL DrawShipyard(WIN_NOT_ACTIVE, NO_SELECTION)
                    GOTO WIN_MISSION
                END IF
            CASE JOY_RIGHT
                CALL DrawShipyard(WIN_NOT_ACTIVE, ShipyardSelected)
                GOTO WIN_SYSTEM
        END SELECT
    LOOP

WIN_SYSTEM:
    SystemSelected = 0
    DO
        CALL DrawSystem(WIN_ACTIVE, SystemSelected)
        
        Action = Joy1.WaitSingleAction()
        SELECT CASE Action
            CASE JOY_LEFT
                CALL DrawSystem(WIN_NOT_ACTIVE, NO_SELECTION)
                GOTO WIN_SHIPYARD
            CASE JOY_DOWN
                IF SystemSelected < SystemItems(ShipyardSelected) THEN
                    SystemSelected = SystemSelected + 1
                END IF
            CASE JOY_UP
                IF SystemSelected > 0 THEN
                    SystemSelected = SystemSelected - 1
                END IF
            CASE JOY_FIRE
                SELECT CASE ShipyardSelected
                    CASE 0, 1, 2
                        IF ComponentValue(COMP_METAL) >= 50 THEN
                            IF PlayerSubSystem(ShipyardSelected) < 9 THEN
                                PlayerSubSystem(ShipyardSelected) = PlayerSubSystem(ShipyardSelected) + 1
                                ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - 50
                                CALL DrawInventory(WIN_NOT_ACTIVE, NO_SELECTION)
                            END IF
                        END IF
                        CALL WaitRasterLine256()
                        CALL DrawInventory(WIN_NOT_ACTIVE, NO_SELECTION)
                        CALL DrawSystem(WIN_ACTIVE, SystemSelected)
                        CALL Joy1.Update()
                    CASE 3
                        DO
                            SELECT CASE SystemSelected
                                CASE 0
                                    IF ComponentValue(COMP_ARMOR) < ComponentCapacity(COMP_ARMOR) THEN
                                        IF ComponentValue(COMP_METAL) >= ComponentPrice(COMP_ARMOR) THEN
                                            ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - ComponentPrice(COMP_ARMOR)
                                            ComponentValue(COMP_ARMOR) = ComponentValue(COMP_ARMOR) + 1
                                        END IF
                                    END IF
                                CASE 1
                                    IF ComponentCapacity(COMP_ARMOR) < ComponentMaxCapacity(COMP_ARMOR) THEN
                                        IF ComponentValue(COMP_METAL) >= ComponentUpgradeCost(COMP_ARMOR) THEN
                                            ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - ComponentUpgradeCost(COMP_ARMOR)
                                            ComponentCapacity(COMP_ARMOR) = ComponentCapacity(COMP_ARMOR) + 1
                                        END IF
                                    END IF
                            END SELECT
                            CALL WaitRasterLine256()
                            CALL DrawCredits()
                            CALL DrawInventory(WIN_NOT_ACTIVE, NO_SELECTION)
                            CALL DrawSystem(WIN_ACTIVE, SystemSelected)
                            CALL Joy1.Update()
                        LOOP WHILE Joy1.Button()
                    CASE 4
                        DO
                            IF ComponentValue(COMP_METAL) >= ComponentUpgradeCost(SystemSelected) THEN
                                IF ComponentCapacity(SystemSelected) < ComponentMaxCapacity(SystemSelected) THEN
                                    ComponentCapacity(SystemSelected) = ComponentCapacity(SystemSelected) + 1
                                    ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - ComponentUpgradeCost(SystemSelected)
                                    CALL DrawInventory(WIN_NOT_ACTIVE, NO_SELECTION)
                                END IF
                            END IF
                            CALL WaitRasterLine256()
                            CALL DrawInventory(WIN_NOT_ACTIVE, NO_SELECTION)
                            CALL DrawSystem(WIN_ACTIVE, SystemSelected)
                            CALL Joy1.Update()
                        LOOP WHILE Joy1.Button()
                END SELECT
        END SELECT
    LOOP

WIN_NEGOTIATE:
    CALL Text.Fill(32, COLOR_LIGHTGRAY)

    ArtifactLocation(9) = LOC_SOURCE
    IF PlayerCredit >= 10000 THEN
        ArtifactLocation(9) = LOC_PLAYER
    END IF
    ArtifactLocation(10) = LOC_SOURCE
    IF ComponentValue(COMP_METAL) >= 250 THEN
        ArtifactLocation(10) = LOC_PLAYER
    END IF
    ArtifactLocation(11) = LOC_SOURCE
    IF ComponentValue(COMP_GOLD) >= 500 THEN
        ArtifactLocation(11) = LOC_PLAYER
    END IF
    
    NegotiateSelected = 0
    DO
        CALL Draw_Negotiate(NegotiateSelected)
        CALL Draw_Progress()

        Action = Joy1.WaitSingleAction()
        SELECT CASE Action
            CASE JOY_UP
                IF NegotiateSelected > 0 THEN
                    NegotiateSelected = NegotiateSelected - 1
                END IF
            CASE JOY_DOWN
                IF NegotiateSelected < 1 _
                    AND ArtifactLocation(LocalMapVergeStationId) = LOC_SOURCE _
                    AND ArtifactLocation(LocalMapVergeStationId+4) = LOC_PLAYER _
                THEN
                    NegotiateSelected = NegotiateSelected + 1
                END IF
            CASE JOY_FIRE
                IF NegotiateSelected = 0 THEN
                    'LEAVE
                    GOTO SHOW_MENU
                ELSE
                    'AGREE
                    SELECT CASE LocalMapVergeStationId
                        CASE 5
                            PlayerCredit = PlayerCredit - 10000
                        CASE 6
                            ComponentValue(COMP_METAL) = ComponentValue(COMP_METAL) - 250
                        CASE 7
                            ComponentValue(COMP_GOLD) = ComponentValue(COMP_GOLD) - 500
                        CASE ELSE
                            ArtifactLocation(LocalMapVergeStationId+4) = LOC_DESTINATION
                    END SELECT
                            
                    ArtifactLocation(LocalMapVergeStationId) = LOC_PLAYER

                    GOTO SHOW_MENU
                END IF
        END SELECT
    LOOP

WIN_MISSION:
    DO
        CALL Draw_Mission(WIN_ACTIVE, LaunchSelected)

        Action = Joy1.WaitSingleAction()
        SELECT CASE Action
            CASE JOY_UP
                IF LaunchSelected > 0 THEN
                    LaunchSelected = LaunchSelected - 1
                ELSE
                    CALL Draw_Mission(WIN_NOT_ACTIVE, NO_SELECTION)
                    GOTO WIN_SHIPYARD
                END IF
            CASE JOY_RIGHT
                CALL Draw_Mission(WIN_NOT_ACTIVE, NO_SELECTION)
                GOTO WIN_LOADSAVE
            CASE JOY_DOWN
                IF LaunchSelected < 1 THEN
                    LaunchSelected = LaunchSelected + 1
                END IF
            CASE JOY_FIRE
                IF LaunchSelected = 1 THEN
                    EXIT SUB
                ELSE
                    GOTO WIN_NEGOTIATE
                END IF
        END SELECT
    LOOP

WIN_LOADSAVE:
    DO
        CALL DrawLoadSave(WIN_ACTIVE, LoadSaveSelected)

        Action = Joy1.WaitSingleAction()
        IF Action = JOY_UP THEN
            IF LoadSaveSelected > 0 THEN
                LoadSaveSelected = LoadSaveSelected - 1
            ELSE
                CALL DrawLoadSave(WIN_NOT_ACTIVE, NO_SELECTION)
                GOTO WIN_SHIPYARD
            END IF
        END IF
        IF Action = JOY_LEFT THEN
            CALL DrawLoadSave(WIN_NOT_ACTIVE, NO_SELECTION)
            GOTO WIN_MISSION
        END IF
        IF Action = JOY_DOWN THEN
            IF LoadSaveSelected < 1 THEN
                LoadSaveSelected = LoadSaveSelected + 1
            END IF
        END IF
        IF Action = JOY_FIRE THEN
            IF LoadSaveSelected = 0 THEN
                ' Load
                OPEN 2,8,2,"savegame,s,r"
                READ #2, PlayerX, PlayerY, PlayerCredit, LocalMapVergeStationId, TimeLeft
                'READ #2, PlayerY
                'READ #2, PlayerCredit
                'READ #2, LocalMapVergeStationId
                'READ #2, TimeLeft
                FOR ZP_B0 = 0 TO 2
                    READ #2, PlayerSubSystem(ZP_B0)
                NEXT
                FOR ZP_B0 = 0 TO 5
                    READ #2, ComponentValue(ZP_B0), ComponentCapacity(ZP_B0)
                NEXT
                FOR ZP_B0 = 0 TO 11
                    READ #2, ArtifactLocation(ZP_B0)
                NEXT
                FOR ZP_B0 = 0 TO 255
                    READ #2, GameMap(ZP_B0)
                NEXT
                CLOSE 2
                GOTO SHOW_MENU
            END IF
            IF LoadSaveSelected = 1 THEN
                ' Save
                OPEN 15,8,15,"s0:savegame"
                CLOSE 15
                OPEN 2,8,2,"@0:savegame,s,w"
                WRITE #2, PlayerX, PlayerY, PlayerCredit, LocalMapVergeStationId, TimeLeft
                'WRITE #2, PlayerY
                'WRITE #2, PlayerCredit
                'WRITE #2, LocalMapVergeStationId
                'WRITE #2, TimeLeft
                FOR ZP_B0 = 0 TO 2
                    WRITE #2, PlayerSubSystem(ZP_B0)
                NEXT
                FOR ZP_B0 = 0 TO 5
                    WRITE #2, ComponentValue(ZP_B0), ComponentCapacity(ZP_B0)
                NEXT
                FOR ZP_B0 = 0 TO 11
                    WRITE #2, ArtifactLocation(ZP_B0)
                NEXT
                FOR ZP_B0 = 0 TO 255
                    WRITE #2, GameMap(ZP_B0)
                NEXT
                CLOSE 2
            END IF
        END IF
    LOOP
END SUB

GOTO THE_END

_SystemTitle:
DATA AS STRING * 6 "Weapon", "Engine", "Gyro", "Armor", "Cargo"
_SystemItems:
DATA AS BYTE 0, 0, 0, 1, 3

THE_END:
