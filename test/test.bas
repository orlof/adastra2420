

DIM Score AS LONG

' POINTS FROM CREDITS (MAX 2300)
ZP_L0 = PlayerCredit
DO WHILE ZP_L0
    Score = Score + 100
    ZP_L0 = SHR(ZP_L0, 1)
LOOP
Score = Score + ZP_L0

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

' POINTS FROM ARTIFACTS (MAX EASY: 2048, NORMAL: 24576, HARD: 49152)
FOR ZP_B0 = 0 TO 11
    Score = Score + SHL(CLONG(ArtifactLocation(ZP_B0)), 10 + GameLevel)
NEXT

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
