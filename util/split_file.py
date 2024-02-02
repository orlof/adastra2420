with open("gfx/c64_uppercase.64c", "rb") as f:
    generic = bytearray(f.read())

with open("gfx/generic_charset.64c", "rb") as f:
    generic2 = bytearray(f.read())

generic[0] = 0x00
generic[1] = 0xd0

for x in range(0, 8*64):
    generic[x+2] = generic2[x+2]

#with open("gfx/army_moves.64c", "rb") as f:
#    army = bytearray(f.read())

#for t in range(2, len(army)):
#    generic[t] = army[t]
#    generic[t + 1024] = army[t] ^ 0xff

#with open("gfx/generic_charset.prg", "wb") as f:
#    f.write(bytes(generic))

with open("gfx/generic_charset.prg", "wb") as f:
    f.write(bytes(generic))
