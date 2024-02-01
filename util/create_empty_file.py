LOAD_ADDRESS = 0x0800
FILENAME = "data/savefile.prg"
SIZE = 500

with open(FILENAME, "wb") as f:
    f.write(bytes([LOAD_ADDRESS % 256, LOAD_ADDRESS // 256]))
    f.write(bytes(SIZE))

print(f"Created empty file {FILENAME} with size {SIZE} bytes")

