with open("gfx/space_charset3.64c", "rb") as f:
    generic = bytearray(f.read())

generic[0] = 0x00
generic[1] = 0xbe

#with open("gfx/army_moves.64c", "rb") as f:
#    army = bytearray(f.read())

#for t in range(2, len(army)):
#    generic[t] = army[t]
#    generic[t + 1024] = army[t] ^ 0xff

#with open("gfx/generic_charset.prg", "wb") as f:
#    f.write(bytes(generic))

with open("gfx/space_charset.bin", "wb") as f:
    f.write(bytes(generic[2:514]))
