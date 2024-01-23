To compile in OSX + VSCode, press Command+p and write "task " (note SPACE after "task").
You must have following prerequisites in path:
  - "xcbasic3", "exomizer", vice's "c1541"
  - Optionally you need "python3" and "zx0" to create resources,
    but it is manual task

This will show you the compilation targets.
 - "Run Warzone" builds the disc image and runs it
 - "Build warzone.d64" builds the disc image
 - "Run Intro" runs intro
 - "Run Battle" runs battle state


|  ZP  | SHARED |  XCB3  | LOADER |  ZX0   | INTRO  | BATTLE |
|------|--------|--------|--------|--------|--------|--------|
| 0x16 | ZP_W0  |   FP   |  USED  | SRCPTR |        |        |
| 0x17 | ZP_W0  |   FP   |  USED  | SRCPTR |        |        |
| 0x18 | ZP_W1  |   FP   |  USED  | DSTPTR |        |        |
| 0x19 | ZP_W1  |   FP   |  USED  | DSTPTR |        |        |
| 0x1A | ZP_W2  |   FP   |  USED  | LENGTH |        |        |
| 0x1B | ZP_W2  |   FP   |  USED  | LENGTH |        |        |
| 0x1C | ZP_I0  |   FP   |        | OFFSET |        |        |
| 0x1D | ZP_I0  |   FP   |        | OFFSET |        |        |
| 0x1E | ZP_I1  |   FP   |        |        |        |        |
| 0x1F | ZP_I1  |   FP   |        |        |        |        |
| 0x20 | ZP_B0  |   FP   |        |        |        |        |
| 0x21 | ZP_B1  |   FP   |        |        |        |        |
| 0x22 | ZP_B2  |   FP   |        |        |        |        |
| 0x23 | ZP_B3  |   FP   |        |        |        |        |
| 0x24 | ZP_B4  |   FP   |        |        |        |        |
| 0x25 | ZP_B5  |   FP   |        |        |        |        |
| 0x26 | ZP_L0  |   FP   |        |        |        |        |
| 0x27 | ZP_L0  |   FP   |        |        |        |        |
| 0x28 | ZP_L0  |   FP   |        |        |        |        |
| 0x29 | ZP_L1  |   FP   |        |        |        |        |
| 0x2A | ZP_L1  |   FP   |        |        |        |        |
| 0x2B | ZP_L1  |   FP   |        |        |        |        |
| 0x2C |        |   FP   |        |        |        |        |
| 0x2D |        |   FP   |        |        |        |        |
| 0x2E |        |   FP   |        |        |        |        |
| 0x2F |        |   FP   |        |        |        |        |
| 0x30 |        |   FP   |        |        |        |        |
| 0x31 |        |   FP   |        |        |        |        |
| 0x32 |        |   FP   |        |        |        |        |
| 0x33 |        |   FP   |        |        |        |        |
| 0x34 |        |   FP   |        |        |        |        |
| 0x35 |        |   FP   |        |        |        |        |
| 0x36 |        |   FP   |        |        |        |        |
| 0x37 |        |   FP   |        |        |        |        |
| 0x38 |        |   FP   |        |        |        |        |
| 0x39 |        |   FP   |        |        |        |        |
| 0x3A |        |   FP   |        |        |        |        |
| 0x3B |        |   FP   |        |        |        |        |
| 0x3C |        |  FAST  |        |        |        |        |
| 0x3D |        |  FAST  |        |        |        |        |
| 0x3E |        |  FAST  |        |        |        |        |
| 0x3F |        |  FAST  |        |        |        |        |
| 0x40 |        |  FAST  |        |        |        |        |
| 0x41 |        |  FAST  |        |        |        |        |
| 0x42 |        |  FAST  |        |        |        |        |
| 0x43 |        |  FAST  |        |        |        |        |
| 0x44 |        |  FAST  |        |        |        |        |
| 0x45 |        |  FAST  |        |        |        |        |
| 0x46 |        |  FAST  |        |        |        |        |
| 0x47 |        |  FAST  |        |        |        |        |
| 0x48 |        |  FAST  |        |        |        |        |
| 0x49 |        |  FAST  |        |        |        |        |
| 0x4A |        |  FAST  |        |        |        |        |
| 0x4B |        |  FAST  |        |        |        |        |
| 0x4C |        |  FAST  |        |        |        |        |
| 0x4D |        |  FAST  |        |        |        |        |
| 0x4E |        |  FAST  |        |        |        |        |
| 0x4F |        |  FAST  |        |        |        |        |
| 0x50 |        |  FAST  |        |        |        |        |
| 0x51 |        |  FAST  |        |        |        |        |
| 0x52 |        |  FAST  |        |        |        |        |
| 0x53 |        |  FAST  |        |        |        |        |
| 0x54 |        |  FAST  |        |        |        |        |
| 0x55 |        |  FAST  |        |        |        |        |
| 0x56 |        |  FAST  |        |        |        |        |
| 0x57 |        |  FAST  |        |        |        |        |
| 0x58 |        |  FAST  |        |        |        |        |
| 0x59 |        |  FAST  |        |        |        |        |
| 0x5A |        |  FAST  |        |        |        |        |
| 0x5B |        |  FAST  |        |        |        |        |
| 0x5C |        |  FAST  |        |        |        |        |
| 0x5D |        |  FAST  |        |        |        |        |
| 0x5E |        |  FAST  |        |        |        |        |
| 0x5F |        |  FAST  |        |        |        |        |
| 0x60 |        |  FAST  |        |        |        |        |
| 0x61 |        |  FAST  |        |        |        |        |
| 0x62 |        |  FAST  |        |        |        |        |
| 0x63 |        |  FAST  |        |        |        |        |
| 0x64 |        |  FAST  |        |        |        |        |
| 0x65 |        |  FAST  |        |        |        |        |
| 0x66 |        |  FAST  |        |        |        |        |
| 0x67 |        |  FAST  |        |        |        |        |
| 0x68 |        |  FAST  |        |        |        |        |
| 0x69 |        |  FAST  |        |        |        |        |





| BANK | START | END   | TYPE   | LOADER   | INTRO    | STATION  | SPACE    |
|------|-------|-------|--------|----------|----------|----------|----------|
| 0    | $0000 | $03FF | SYSTEM |          |          |          |          |
| 0    | $0400 | $07FF | RAM    | LOADER   |          |          |          |
| 0    | $0800 | $0BFF | BASIC  |          |          |          |          |
| 0    | $0C00 | $0FFF |        |          |          |          |          |
| 0    | $1000 | $13FF |        |          | SID      |          | CODE     |
| 0    | $1400 | $17FF |        |          | SID      |          | CODE     |
| 0    | $1800 | $1BFF |        |          | SID      |          | CODE     |
| 0    | $1C00 | $1FFF |        |          | SID      |          | CODE     |
| 0    | $2000 | $23FF |        |          | CODE     |          | CODE     |
| 0    | $2400 | $27FF |        |          | CODE     |          | CODE     |
| 0    | $2800 | $2BFF |        |          | CODE     |          | CODE     |
| 0    | $2C00 | $2FFF |        |          | CODE     |          | CODE     |
| 0    | $3000 | $33FF |        |          | CODE     |          | CODE     |
| 0    | $3400 | $37FF |        |          | CODE     |          | CODE     |
| 0    | $3800 | $3BFF |        |          | CODE     |          | CODE     |
| 0    | $3C00 | $3FFF |        |          | CODE     |          | CODE     |
| 1    | $4000 | $43FF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $4400 | $47FF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $4800 | $4BFF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $4C00 | $4FFF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $5000 | $53FF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $5400 | $57FF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $5800 | $5BFF |        | INSTALL  | CODE     |          | CODE     |
| 1    | $5C00 | $5FFF |        |          | CODE     |          | CODE     |
| 1    | $6000 | $63FF |        |          | CODE     |          | CODE     |
| 1    | $6400 | $67FF |        |          | CODE     |          | CODE     |
| 1    | $6800 | $6BFF |        |          | CODE     |          | CODE     |
| 1    | $6C00 | $6FFF |        |          | CODE     |          | CODE     |
| 1    | $7000 | $73FF |        |          | CODE     |          | CODE     |
| 1    | $7400 | $77FF |        |          | CODE     |          | CODE     |
| 1    | $7800 | $7BFF |        |          | CODE     |          | CODE     |
| 1    | $7C00 | $7FFF |        |          | CODE     |          | CODE     |
| 2    | $8000 | $83FF |        |          | CODE     |          | CODE     |
| 2    | $8400 | $87FF |        |          | CODE     |          | CODE     |
| 2    | $8800 | $8BFF |        |          | CODE     |          | CODE     |
| 2    | $8C00 | $8FFF |        |          | CODE     |          |          |
| 2    | $9000 | $93FF |        |          | CODE     |          |          |
| 2    | $9400 | $97FF |        |          | CODE     |          |          |
| 2    | $9800 | $9BFF |        |          | CODE     |          |          |
| 2    | $9C00 | $9FFF |        |          | CODE     |          |          |
| 2    | $A000 | $A3FF |        |          | CODE     |          |          |
| 2    | $A400 | $A7FF |        |          | CODE     |          |          |
| 2    | $A800 | $ABFF |        |          | CODE     |          |          |
| 2    | $AC00 | $AFFF |        |          | CODE     |          |          |
| 2    | $B000 | $B3FF |        |          | CODE     |          |          |
| 2    | $B400 | $B7FF |        |          | CODE     |          |          |
| 2    | $B800 | $BBFF |        |          |          |          |          |
| 2    | $BC00 |       |        |          |          |          |          |
|      | $BC00 | $BCFF |        |          |          |          | DUMMY    |
|      | $BD00 | $BDFF |        |          |          |          | DUMMY    |
|      | $BE00 | $BEFF |        |          |          |          | CHARSET2 |
|      | $BF00 | $BFFF |        |          |          |          | CHARSET2 |
| 3    | $C000 | $C3FF |        |          |          |          | SPRITE   |
| 3    | $C400 | $C7FF |        |          |          |          | SPRITE   |
| 3    | $C800 | $CBFF |        | SCREEN   | SCREEN   | SCREEN   | SCREEN   |
| 3    | $CC00 | $CFFF |        | XCBASIC  | XCBASIC  | XCBASIC  | XCBASIC  |
| 3    | $D000 | $D3FF | IO     | FONT     | FONT     | FONT     | FONT     |
| 3    | $D400 | $D7FF | IO     | FONT     | FONT     | FONT     | FONT     |
| 3    | $D800 | $DBFF | COLMEM |          |          |          |          |
| 3    | $DC00 | $DFFF | IO     |          |          |          |          |
| 3    | $E000 | $E3FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $E400 | $E7FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $E800 | $EBFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $EC00 | $EFFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $F000 | $F3FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $F400 | $F7FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $F800 | $FBFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $FC00 | $FFFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   |


|START |END   | NAME              | TYPE  |
|------|------|-------------------|-------|
| 0800 | 08ff | GameMap           | B(256)|
| 0900 | 0900 | GameState         | B     |
| 0901 | 0902 | TimeLeft          | D     |
| 0903 | 0905 | PlayerCredit      | L     |
| 0906 | 0908 | PlayerX           | L     |
| 0909 | 090b | PlayerY           | L     |
| 090c | 090c | StationId         | B     |
| 090d | 090f | PlayerSubSystem   | B(3)  |
| 0910 | 0919 | ComponentValue    | W(5)  |
| 091a | 0923 | ComponentCapacity | W(5)  |
| 0924 | 092f | ArtifactLocation  | B(12) |
| 0930 | 0931 | PlayerSectorMapX  | W     |
| 0932 | 0932 | PlayerSectorMapY  | B     |
| 0933 | 0933 | PlayerSectorMapRestore | B     |


MAP data format:
<pre>
    Map size: 16 * 16 = 256 bytes
    Byte format: vvvaaott
        vvv: Verge station id
            000 0
            001 1
            010 2
            011 3
            100 4
            101 5
            110 6
            111 7
        aa: asteroid field
            00  no asteroids
            01  high energy asteroids
            10  medium energy asteroids
            11  low energy asteroids
        o: stationary object on/off
            0   no stationary object
            1   stationary object
        tt: stationary object type
            00  AI
            01  star
            10  Verge station
            11  missile silo
</pre>