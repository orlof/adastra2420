import os

FILENAME = "sfx/Driven_20.sid"


def main():
    with open(FILENAME, "rb") as f:
        data = f.read()

    filename, _ = os.path.splitext(FILENAME)
    with open(filename + ".bin", "wb") as f:
        f.write(data[0x7e:])

    print(f"Converted {FILENAME} to {filename}.bin")


if __name__ == "__main__":
    main()