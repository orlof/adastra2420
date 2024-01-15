LOAD_ADDRESS = 0xc000
FILENAME = "data/test.prg"
SIZE = 0x800

with open(FILENAME, "wb") as f:
    f.write(bytes([LOAD_ADDRESS % 256, LOAD_ADDRESS // 256]))
    f.write(bytes(SIZE))

print(f"Created empty file {FILENAME} with size {SIZE} bytes")

