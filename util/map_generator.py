

m = [""] * 16
m[0x00] = "    ......ZZZ.  "
m[0x01] = "  ....:::...... "
m[0x02] = " ..0..:1::::... "
m[0x03] = " .....:::===:..."
m[0x04] = ".....:::==7=:..."
m[0x05] = "...::::::===::.."
m[0x06] = "..:::....::=::.."
m[0x07] = "..:::.....:::..."
m[0x08] = "..::..5........."
m[0x09] = "...::.......... "
m[0x0a] = "....::......... "
m[0x0b] = ".....:.......4. "
m[0x0c] = " ..6........... "
m[0x0d] = " .............  "
m[0x0e] = "  ........ZZZ.  "
m[0x0f] = "          Z3Z   "

startx=0
starty=0
bvalues = []
for count, row in enumerate(m):
    print("DATA AS BYTE ", end="")
    values = []
    for v in row:
        if v == " ":
            data = 0b00000000
        elif v == ".":
            data = 0b00011000
        elif v == ":":
            data = 0b00010000
        elif v == "=":
            data = 0b00001000

        elif v == "0":
            data = (data & 0b00011000) | 0b00000110
        elif v == "1":
            data = (data & 0b00011000) | 0b00100110
        elif v == "2":
            data = (data & 0b00011000) | 0b01000110
        elif v == "3":
            data = (data & 0b00011000) | 0b01100110
        elif v == "4":
            data = (data & 0b00011000) | 0b10000110
        elif v == "5":
            data = (data & 0b00011000) | 0b10100110
            startx= len(values)
            starty= count
        elif v == "6":
            data = (data & 0b00011000) | 0b11000110
        elif v == "7":
            data = (data & 0b00011000) | 0b11100110
        
        elif v == "*":
            data = (data & 0b00011000) | 0b00000101

        elif v == "Z":
            data = (data & 0b00011000) | 0b00000111

        values.append("${:02x}".format(data))
        bvalues.append(data)
    print(", ".join(values))

with open("map.bin", "wb") as f:
    f.write(bytes(bvalues))

print ("PlayerX = $%s8000" % '{:02x}'.format(startx))
print ("PlayerY = $%s8000" % '{:02x}'.format(starty))
print ("POI X = %d" % startx)
print ("POI Y = %d" % starty)
print ("POI Index = %d" % (starty*16+startx))
