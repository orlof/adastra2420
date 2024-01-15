import os

#FILENAME = "gfx/loader_font.bin"
#FILENAME = "data/battle_map.prg"
FILENAME = "loader/save-c64.prg"


def main():
    filename, _ = os.path.splitext(FILENAME)

    if not os.path.splitext(filename)[1]:
        filename = filename + ".bin"

    with open(FILENAME, "rb") as f:
        data = f.read()

    with open(filename, "wb") as f:
        f.write(data[2:])

    print(f"Converted {FILENAME} to {filename}")


if __name__ == "__main__":
    main()
