import os

FILENAME = "gfx/generic_charset.bin"
LOAD_ADDRESS = 0xc000
ZX0_INPLACE_UNPACK = True


def main():
    filename, ext = os.path.splitext(FILENAME)

    if ZX0_INPLACE_UNPACK and ext == ".zx0":
        packed_size = os.path.getsize(FILENAME)
        unpacked_size = os.path.getsize(filename)
        load_address = LOAD_ADDRESS + unpacked_size - packed_size
        filename = FILENAME + ".prg"
    elif ext == ".bin":
        load_address = LOAD_ADDRESS
        filename = filename + ".prg"
    else:
        load_address = LOAD_ADDRESS
        filename = FILENAME + ".prg"

    with open(FILENAME, "rb") as f:
        data = f.read()

    with open(filename, "wb") as f:
        f.write(bytes([load_address % 256, load_address // 256]))
        f.write(data)

    print(f"Converted {FILENAME} to {filename}")
    print(f"Load address: ${load_address:04x}")


if __name__ == "__main__":
    main()