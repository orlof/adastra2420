
SUB SprClearSprite(SprNr AS BYTE) STATIC SHARED
    MEMSET $c000 + SHL(CWORD(SprNr), 7), 128, 0
END SUB

