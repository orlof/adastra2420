# Manual

## Introduction

This manual provides specific instructions and information for playing the Ad Astra with Commodore 64 computer. Your package should include 5.25" disk, a manual and a map.

## Computer systems

Ad Astra will operate with a Commodore 64 or 128 computer with 1541 disk drive and a joystick. Second joystick is needed for 2 player co-operative game.

## Game

You are a star ranger deployed for long range reconnaissance mission in Rimward Reach asteroid belt.

![](https://github.com/orlof/aileon/blob/main/data/starmap.png?raw=true)

Rimward reach has 8 Verge stations that perform mining operations.

When game stars, your ship is located in Verge Station 5 and you will get your mission parameters via long range quantum communication link.

Note - It is a known fact that bare singularity wraps the edges of the local space.

## Flight Mode

Movement in flight mode can be controlled with joystick in port 2. Another joystick in port 1 can be used to control weapon turret. Following table shows the controls:

### Ship Control

<table>
<tr>
  <td>Joy2</td><td>Up</td><td>Accelerate</td>
</tr>
<tr>
  <td>Joy2</td><td>Down</td><td>Decelerate</td>
</tr>
<tr>
  <td>Joy2</td><td>Right</td><td>Turn ship clockwise</td>
</tr>
<tr>
  <td>Joy2</td><td>Left</td><td>Turn ship counter clockwise</td>
</tr>
<tr>
  <td>Joy2</td><td>Fire</td><td>Shoot Cannon</td>
</tr>
</table>

### Turret Control

<table>
<tr>
  <td>Joy1</td><td>Right</td><td>Turn turret clockwise</td>
</tr>
<tr>
  <td>Joy1</td><td>Left</td><td>Turn turret counter clockwise</td>
</tr>
<tr>
  <td>Joy1</td><td>Fire</td><td>Shoot Turret</td>
</tr>
</table>

### Dashboard

Your ship's status is visible in the right side of the screen.

![](https://github.com/orlof/aileon/blob/main/data/space.png?raw=true)

<table>
<tr>
  <td>FUEL xxx</td><td>Fuel meter</td>
</tr>
<tr>
  <td>OXYGEN xxx</td><td>Oxygen meter</td>
</tr>
<tr>
  <td>GOLD xxx</td><td>Gold tonnage</td>
</tr>
<tr>
  <td>METAL xxx</td><td>Metal tonnage</td>
</tr>
<tr>
  <td>SHIELD xxx</td><td>Armor Status</td>
</tr>
<tr>
  <td>SPEED xxx</td><td>Velocity</td>
</tr>
<tr>
  <td>FIELD x</td><td>Asteroids' average kinetic energy in your proximity</td>
</tr>
<tr>
  <td>TIME xxxx</td><td>Singularity countdown sensor</td>
</tr>
</table>

Map is located in the middle of the dashboard and shows your ship's position in Rimward Reach sector.

Radar is placed in the lowest part of the dashboard. It will show large space objects in your local space.

<table>
<tr>
  <td>Blue</td><td>Verge Station - can be docked for trade and diplomacy. Verge Station will activate Asteroid Protection Field when your ship reaches close proximity. To initiate docking sequence your ship's velocity must be below 3 and your ship must be in touch with the station.</td>
</tr>
<tr>
  <td>Yellow</td><td>Gravity well - ship's fuel scoops will automatically gather fuel during close approach</td>
</tr>
<tr>
  <td>Red</td><td>Missile station - can be destroyed with several direct hits with ship's weapons</td>
</tr>
</table>

### Asteroids

Collisions with different asteroids have different effects.

Note: Your mining computer will mark gold and metal asteroids with small triangles in the center of the asteroid.

<table>
<tr>
  <td>Gray (light/medium/dark)</td><td>Stone asteroid, collision damage reduces ship armor and may destroy your ship</td>
</tr>
<tr>
  <td>Yellow</td><td>Gold asteroid can be mined by touching it</td>
</tr>
<tr>
  <td>Green</td><td>Metal asteroid can be mined by touching it</td>
</tr>
</table>

Rimward Reach is divided into different sectors based on the asteroid's average kinetic energy. Some regions don't have asteroids at all, and some regions have asteroids with low/medium/high kinetic energy. Mining operations are focused to low energy sectors, as mining in high energy sectors is considered hazardous.

## Verge Station

Eight Verge Stations that are located in Rimward Reach provide a place to trade your minerals and improve your ship's capabilities.

![](https://github.com/orlof/aileon/blob/main/data/station.png?raw=true)

Top part of the screen is trade interface. Left side shows how much each material you have stored in cargo. It also shows how much cargo space (or tank volume) you have for each material. Typically you trade your Gold for credits, and use Credits to fill your Fuel and Oxygen tanks.

Metal is mostly needed in Shipyard (but it can also be sold for Credits). In Shipyard you can use Metal to upgrade your ship's Weapon, Manouver Drive, Gyroscopes, Armor and Cargo Space. Following table shows the benefit of each upgrade level for subsystems:

<table>
<tr><th>Level</th><th>Weapon Damage<br>Cannon/Turret</th><th>Drive Pulse</th><th>Gyroscope deg/s</th></tr>
<tr><td>0</td><td>1 / 2</td><td>5.00</td><td>60</td></tr>
<tr><td>1</td><td>2 / 3</td><td>5.56</td><td>60</td></tr>
<tr><td>2</td><td>2 / 3</td><td>5.88</td><td>60</td></tr>
<tr><td>3</td><td>3 / 4</td><td>6.25</td><td>60</td></tr>
<tr><td>4</td><td>3 / 4</td><td>6.67</td><td>120</td></tr>
<tr><td>5</td><td>4 / 5</td><td>7.14</td><td>120</td></tr>
<tr><td>6</td><td>4 / 5</td><td>7.69</td><td>120</td></tr>
<tr><td>7</td><td>5 / 6</td><td>8.33</td><td>120</td></tr>
<tr><td>8</td><td>5 / 6</td><td>9.09</td><td>120</td></tr>
<tr><td>9</td><td>6 / 7</td><td>10</td><td>180</td></tr>
</table>

In the bottom part of the Verge Station interface you can Negotiate the mission objectives, Launch back to space, and load or save the game.

## Playing Tips

In the first phase of the game you should stay in close proximity to Verge Station 5 and collect enough Metals to upgrade your ship. Verge Station 5 is surrounded by low energy asteroids and it makes it a good place for mining operations.

Star Ranger field manual recommends following upgrades:
<table>
<tr><th>Weapon system</th><td>7</td></tr>
<tr><th>Manouver drive</th><td>10</td></tr>
<tr><th>Gyroscope</th><td>4</td></tr>
<tr><th>Gold cargo</th><td>500</td></tr>
<tr><th>Metal cargo</th><td>250</td></tr>
<tr><th>Fuel capacity</th><td>250</td></tr>
<tr><th>Oxygen capacity</th><td>250</td></tr>
<tr><th>Armor</th><td>100</td></tr>
</table>

Feel free to trial with different builds based on your personal tactics.

In the second phase of the game, you must travel through all the Verge stations to get the components that you need to stop the runaway singularity. Verge Stations 0-3 are more difficult to reach and you should first visit stations 4-7. Position of station 2 is not known, you must find it.

 - Beware of AI missile silos
 - If you have strong enough engine, you can scoop fuel from stars
 - Bigger engines consume more fuel. You may want to upgrade your fuel tank capacity along the engine
 - Watch that Singularity countdown sensor!

Note: Difficulty level Easy requires you to deliver only Babbage Siphon.

This table provides the location of each artifact as stated in your intel:
<table>
<tr><th>Verge Station</th><th>Artifact</th><th>Price</th></tr>
<tr><td>0</td><td>Neuman Binder</td><td>Flux Positioner</td></tr>
<tr><td>1</td><td>Babbage Siphon</td><td>Fusion Aligner</td></tr>
<tr><td>2</td><td>Laplace Reactor</td><td>Entropy Emitter</td></tr>
<tr><td>3</td><td>Fermi Entangler</td><td>Quantum Colloid</td></tr>
<tr><td>4</td><td>Flux Positioner</td><td>Positronic AI</td></tr>
<tr><td>5</td><td>Fusion Aligner</td><td>10000 CR</td></tr>
<tr><td>6</td><td>Entropy Emitter</td><td>250 Metals</td></tr>
<tr><td>7</td><td>Quantum Colloid</td><td>500 Gold</td></tr>
</table>

# Thanks

 - Fekete Csaba for XC=Basic3
 - Roy Batty for music
 - Krill for Loader
 - Michel de Bree for Retropixels

# Release Notes

1.0 changes since Beta
 - Game balance tuning
   - cheaper armor, cargo space and engine improvements
   - weaker gravity
 - Added sector map and asteroid kinetic energy monitor to dashboard
 - Title screen with smaller memory footprint
 - README game tips added
 - Multiple bug fixes

1.01 fix for gold cargo bug

2.00
 - New ship improvement - gyroscopes - upgrading those babies can make your ship spin like a wheel (I am still a bit hesitant about this change, as it diminishes the turret's value - but on the other hand I haven't heard anyone even trying the two player co-op)
 - Both weapons (forward facing railgun and rotating turret) are now part of the initial ship configuration
 - Possibility to upgrade weapon damage. Initial weapon damage is now weaker than originally, but in the high end the damage is about 2x more powerful than before

2.01
 - Added Verge stations to sector map

2.02
 - Color coding for dashboard

3.0 Major release
 - Instead of single file, game now occupies a floppy disk
 - Story elements added to beginning and end
 - New dashboard
 - New station interface
 - New game mode "easy"
 - Usability improvements

# Technical Information

Ad Astra is my project to learn games programming for C64. The code is written with XC-Basic 3 (https://xc-basic.net/) and time/memory critical parts are transformed into assembly.

Music is ripped from Millenium Demo and Batty Tunes - made by lengendary Roy Batty. I absolutely love his tunes! The permission to use them is given in the demo scroller.
Thank you Roy Batty!

![](https://github.com/orlof/aileon/blob/main/data/music.png?raw=true)

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

ZERO-PAGE LAYOUT (NOT COMPLETE)

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


MEMORY LAYOUT (NOT COMPLETE)

| BANK | START | END   | TYPE   | LOADER   | PROLOGUE | STATION  | SPACE    | GAMEOVER | EPILOGUE |
|------|-------|-------|--------|----------|----------|----------|----------|----------|----------|
| 0    | $0000 | $03FF | SYSTEM |          |          |          |          |          |          |
| 0    | $0400 | $07FF | RAM    | LOADER   | LOADER   | LOADER   | LOADER   | LOADER   | LOADER   |
| 0    | $0800 | $0BFF | BASIC  |          |          | SHARED   | SHARED   |          |          |
| 0    | $0C00 | $0FFF |        |          |          |          |          |          |          |
| 0    | $1000 | $13FF |        |          | SID      | SID      | CODE     | SID      | SID      |
| 0    | $1400 | $17FF |        |          | SID      | SID      | CODE     | SID      | SID      |
| 0    | $1800 | $1BFF |        |          | SID      | SID      | CODE     | SID      | SID      |
| 0    | $1C00 | $1FFF |        |          | SID      | SID      | CODE     | SID      | SID      |
| 0    | $2000 | $23FF |        |          | CODE     |          | CODE     |          |          |
| 0    | $2400 | $27FF |        |          | CODE     |          | CODE     |          |          |
| 0    | $2800 | $2BFF |        |          | CODE     |          | CODE     |          |          |
| 0    | $2C00 | $2FFF |        |          | CODE     |          | CODE     |          |          |
| 0    | $3000 | $33FF |        |          | CODE     |          | CODE     |          |          |
| 0    | $3400 | $37FF |        |          | CODE     |          | CODE     |          |          |
| 0    | $3800 | $3BFF |        |          | CODE     |          | CODE     |          |          |
| 0    | $3C00 | $3FFF |        |          | CODE     |          | CODE     |          |          |
| 1    | $4000 | $43FF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $4400 | $47FF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $4800 | $4BFF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $4C00 | $4FFF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $5000 | $53FF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $5400 | $57FF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $5800 | $5BFF |        | INSTALL  | CODE     |          | CODE     |          |          |
| 1    | $5C00 | $5FFF |        |          | CODE     |          | CODE     |          |          |
| 1    | $6000 | $63FF |        |          | CODE     |          | CODE     |          |          |
| 1    | $6400 | $67FF |        |          | CODE     |          | CODE     |          |          |
| 1    | $6800 | $6BFF |        |          | CODE     |          | CODE     |          |          |
| 1    | $6C00 | $6FFF |        |          | CODE     |          | CODE     |          |          |
| 1    | $7000 | $73FF |        |          | CODE     |          | CODE     |          |          |
| 1    | $7400 | $77FF |        |          | CODE     |          | CODE     |          |          |
| 1    | $7800 | $7BFF |        |          | CODE     |          | CODE     |          |          |
| 1    | $7C00 | $7FFF |        |          | CODE     |          | CODE     |          |          |
| 2    | $8000 | $83FF |        |          | CODE     |          | CODE     |          |          |
| 2    | $8400 | $87FF |        |          | CODE     |          | CODE     |          |          |
| 2    | $8800 | $8BFF |        |          | CODE     |          | CODE     |          |          |
| 2    | $8C00 | $8FFF |        |          | CODE     |          |          |          |          |
| 2    | $9000 | $93FF |        |          | CODE     |          |          |          |          |
| 2    | $9400 | $97FF |        |          | CODE     |          |          |          |          |
| 2    | $9800 | $9BFF |        |          | CODE     |          |          |          |          |
| 2    | $9C00 | $9FFF |        |          | CODE     |          |          |          |          |
| 2    | $A000 | $A3FF |        |          | CODE     |          |          |          |          |
| 2    | $A400 | $A7FF |        |          | CODE     |          |          |          |          |
| 2    | $A800 | $ABFF |        |          | CODE     |          |          |          |          |
| 2    | $AC00 | $AFFF |        |          | CODE     |          |          |          |          |
| 2    | $B000 | $B3FF |        |          | CODE     |          |          |          |          |
| 2    | $B400 | $B7FF |        |          | CODE     |          |          |          |          |
| 2    | $B800 | $BBFF |        |          |          | SAVE     |          |          |          |
| 2    | $BC00 | $BFFF |        |          |          | SAVE     | FONT-S   |          |          |
| 3    | $C000 | $C3FF |        |          | SPRITE   |          | SPRITE   | SPRITE   | SPRITE   |
| 3    | $C400 | $C7FF |        |          | SPRITE   |          | SPRITE   | SPRITE   | SPRITE   |
| 3    | $C800 | $CBFF |        | SCREEN   | SCREEN   | SCREEN   | SCREEN   | SCREEN   | SCREEN   |
| 3    | $CC00 | $CFFF |        | XCBASIC  | XCBASIC  | XCBASIC  | XCBASIC  |          |          |
| 3    | $D000 | $D3FF | IO     | FONT     | FONT     | FONT     | FONT     | FONT     | FONT     |
| 3    | $D400 | $D7FF | IO     | FONT     | FONT     | FONT     | FONT     | FONT     | FONT     |
| 3    | $D800 | $DBFF | COLMEM |          |          |          |          |          |          |
| 3    | $DC00 | $DFFF | IO     |          |          |          |          |          |          |
| 3    | $E000 | $E3FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $E400 | $E7FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $E800 | $EBFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $EC00 | $EFFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $F000 | $F3FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $F400 | $F7FF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $F800 | $FBFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |
| 3    | $FC00 | $FFFF | KERNAL | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   | BITMAP   |


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
