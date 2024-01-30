import os
import subprocess

FILENAME = "/Users/teppo/Desktop/snapshot.vsf"
START = 0x3000
END = 0x3800


def write_data(data):
    filename = os.path.splitext(FILENAME)[0] + ".bin"
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

    # Define the target byte sequence to search for
    target_bytes = b'C64MEM'

    # Initialize variables to keep track of the search state
    found = False
    start_index = -1

    # Iterate through the bytearray
    for i in range(len(data)):
        if data[i:i+len(target_bytes)] == target_bytes:
            found = True
            start_index = i
            break

    data = data[start_index + 0x001a:start_index + 0x1001a]
    data = data[START:END]
    fn = write_data(data)



if __name__ == "__main__":
    main()
