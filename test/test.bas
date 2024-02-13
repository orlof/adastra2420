SUB playnote(note$ as string*20)
    dim freq as int
    FREQ = 0
    dim b as byte
    b=1
    dim notes$ as string*1
    for x as byte = 0 to len(note$)-1
        notes$=mid$(note$,x,1)
        SELECT CASE NOTES$
            CASE "B"
                FREQ = 125
            CASE "C"
                FREQ = 238
            CASE "C#"
                FREQ = 224
            CASE "D"
                FREQ = 210
            CASE "D#"
                FREQ = 199
            CASE "E"
                FREQ = 188
            CASE "F"
                FREQ = 177
            CASE "F#"
                FREQ = 168
            CASE "G"
                FREQ = 158
            CASE "G#"
                FREQ = 149
            CASE "A"
                FREQ = 140
            CASE "A#"
                FREQ = 133
            CASE ELSE
                PRINT "Error: Note not found"
        END SELECT
        REM Play the note
        POKE 59466, 51 : REM Set octave to 1
        POKE 59464, FREQ : REM Set frequency
        FOR DELAY as int = 1 TO 5000
    NEXT
    POKE 59464, 0 : REM Turn off the note
    next
end SUB

CALL playnote("CDE")
