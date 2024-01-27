import os
import subprocess

FILENAME = "gfx/gameover003.kla"


def write_data(part, data):
    filename = os.path.splitext(FILENAME)[0] + "_" + part + ".bin"
    with open(filename, "wb") as f:
        f.write(bytes(data))

    print(f"Wrote {len(data)} bytes to {filename}")

    return filename


def zx0_decompress(filename):
    # Command to execute (replace with your actual command)
    command = "zx0 -c -f " + filename + " " + filename.replace(".bin", "") + ".zx0"

    # Run the command
    result = subprocess.run(command, shell=True, capture_output=False, text=True)
    print(result.stdout)


def main():
    with open(FILENAME, "rb") as f:
        data = f.read()

    bitmap_data = bytearray(data[2:8002])
    bitmap_data[8000-4*320:] = [0] * 4*320
    screen_data = bytearray(data[8002:9002])
    screen_data[1000-4*40:] = [32] * 4*40
    color_data = bytearray(data[9002:10002])
    color_data[1000-4*40:] = [0] * 4*40

    bgcolor_data = data[10002]

    fn = write_data("bitmap", bitmap_data)
    zx0_decompress(fn)

    fn = write_data("screen", screen_data)
    zx0_decompress(fn)
    print(f"screen: {screen_data[0]:02x}")
    fn = write_data("color", color_data)
    zx0_decompress(fn)
    print(f"color: {color_data[0]:02x}")
    print(f"bgcolor: ${bgcolor_data:02x}")


if __name__ == "__main__":
    main()
