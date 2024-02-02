REM **********************
REM *      GENERAL       *
REM **********************

SHARED CONST JOY1 = 0
SHARED CONST JOY2 = 1

CONST JOY1_ADDR = $dc01  ' Address for joystick 1
CONST JOY2_ADDR = $dc00  ' Address for joystick 2

' Define constants for joystick directions
CONST JOY_UP      = %00000001
CONST JOY_DOWN    = %00000010
CONST JOY_LEFT    = %00000100
CONST JOY_RIGHT   = %00001000
CONST JOY_FIRE    = %00010000
CONST JOY_ANY_DIR = %00001111
CONST JOY_ANY     = %00011111

' Declare variables to store joystick values
DIM JoyValue(2) AS BYTE SHARED
DIM JoyPrev(2) AS BYTE

' Initialize joystick values
JoyValue(0) = PEEK(JOY1_ADDR) AND JOY_ANY
JoyPrev(0) = JoyValue(0)

JoyValue(1) = PEEK(JOY2_ADDR) AND JOY_ANY
JoyPrev(1) = JoyValue(1)

' Update all joystick registers with new values
SUB JoyUpdate() STATIC SHARED
    JoyPrev(0) = JoyValue(0)
    JoyPrev(1) = JoyValue(1)
    JoyValue(0) = PEEK(JOY1_ADDR) AND JOY_ANY
    JoyValue(1) = PEEK(JOY2_ADDR) AND JOY_ANY
END SUB

FUNCTION JoyUp AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN (JoyValue(JoyNr) AND JOY_UP) = 0
END FUNCTION

FUNCTION JoyDown AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN (JoyValue(JoyNr) AND JOY_DOWN) = 0
END FUNCTION

FUNCTION JoyRight AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN (JoyValue(JoyNr) AND JOY_RIGHT) = 0
END FUNCTION

FUNCTION JoyLeft AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN (JoyValue(JoyNr) AND JOY_LEFT) = 0
END FUNCTION

FUNCTION JoyFire AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN (JoyValue(JoyNr) AND JOY_FIRE) = 0
END FUNCTION

FUNCTION JoySame AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN (JoyValue(JoyNr) = JoyPrev(JoyNr)) AND (JoyValue(JoyNr) < JOY_ANY)
END FUNCTION

FUNCTION JoyIdle AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN JoyValue(JoyNr) = JOY_ANY
END FUNCTION

' Check if fire button state has changed
FUNCTION JoyFirePressed AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN ((JoyPrev(JoyNr) AND JOY_FIRE) > 0) AND ((JoyValue(JoyNr) AND JOY_FIRE) = 0)
END FUNCTION

FUNCTION JoyFireReleased AS BYTE(JoyNr AS BYTE) STATIC SHARED
    RETURN ((JoyPrev(JoyNr) AND JOY_FIRE) = 0) AND ((JoyValue(JoyNr) AND JOY_FIRE) > 0)
END FUNCTION

' Convenience funtions that can be used to change coordinates
FUNCTION JoyXAxis AS INT(JoyNr AS BYTE) STATIC SHARED
    IF (JoyValue(JoyNr) AND JOY_LEFT) = 0 THEN RETURN -1
    IF (JoyValue(JoyNr) AND JOY_RIGHT) = 0 THEN RETURN 1
    RETURN 0
END FUNCTION

FUNCTION JoyYAxis AS INT(JoyNr AS BYTE) STATIC SHARED
    IF (JoyValue(JoyNr) AND JOY_UP) = 0 THEN RETURN -1
    IF (JoyValue(JoyNr) AND JOY_DOWN) = 0 THEN RETURN 1
    RETURN 0
END FUNCTION

SUB JoyWaitIdle(JoyNr AS BYTE) STATIC SHARED
    DO
        CALL JoyUpdate()
    LOOP WHILE JoyValue(JoyNr) < JOY_ANY
END SUB

' Subroutine to wait for joystick button click (down+up)
SUB JoyWaitClick(JoyNr AS BYTE) STATIC SHARED
    DO
        CALL JoyUpdate()
    LOOP UNTIL JoyFirePressed(JoyNr)
    DO
        CALL JoyUpdate()
    LOOP UNTIL JoyFireReleased(JoyNr)
END SUB
