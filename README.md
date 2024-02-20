# Manual

## Introduction

This manual provides specific instructions and information for playing the Ad Astra 2420 with Commodore 64 computer. Your package should include 5.25" disk, a manual and a map.

## Computer systems

Ad Astra will operate with a Commodore 64 or 128 computer with 1541 disk drive and a joystick. A second joystick is needed for 2 player co-operative game.

## Game

### Background

You are a star ranger deployed for long range reconnaissance mission in Rimward Reach asteroid belt.

![](https://github.com/orlof/aileon/blob/main/data/starmap.png?raw=true)

Rimward reach has 8 Verge stations that perform mining operations.

When game stars, your ship is located in Verge Station 5 and you will see your mission parameters via long range quantum communication link.

## Difficulty levels

When game starts you can choose the difficulty level: Rookie, Veteran or Elite. The difficulty level effects the game play in many different ways.

### Rookie

Designed for newcomers, the Rookie level simplifies gameplay significantly to ensure a smooth and welcoming introduction. At this level, your mission is straightforward: secure a Babbage Siphon from any Verge station (other than 5) and deliver it to Verge Station 5. The game boosts your chances of success by doubling the occurrence of gold and metal asteroids and ensuring their kinetic energy remains low, reducing the risk of collision. Your star ship comes equipped with upgraded engines, weapons, gyroscope, and cargo space, allowing you to focus on the mission without the need for early upgrades. Oxygen consumption is halved, and space hazards are significantly reduced, making your journey through the Rimward Reach asteroid belt safer and more manageable. This level is perfect for players looking to familiarize themselves with the game mechanics without the pressure of complex objectives or the need for extensive upgrades.

### Veteran

The Veteran level maintains the foundational supports of the Rookie difficulty but extends the gameplay to encompass the full campaign. Players are tasked with a more challenging mission: collect four unique items from different Verge stations. This objective necessitates careful planning and strategic upgrades to ship systems, introducing players to the game's deeper mechanics while still providing a safety net through some of the gameplay aids found in the Rookie level. The Veteran level strikes a balance between accessibility and challenge, offering a rewarding experience for players ready to delve deeper into the game's strategy and mechanics.

### Elite

The Elite level presents the ultimate challenge, stripping back all the aids and enhancements of the lower difficulties to deliver a raw and immersive experience. Players start with base-level ship systems, emphasizing the importance of strategic planning and prioritization from the outset. Upgrading your ship becomes a critical early goal, requiring careful management of resources and successful navigation through the asteroid belt's hazards. The Elite level is designed for those seeking to test their skills to the fullest, offering a rigorous campaign that demands tactical thinking, precise control, and a deep engagement with all aspects of gameplay. Only the most dedicated star rangers will thrive at this level, earning their place among the legends of the Rimward Reach.

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
  <td>TIME xxxx</td><td>Mission Time</td>
</tr>
</table>

Map is located in the middle of the dashboard and shows your ship's position in Rimward Reach sector. Map shows the whole sector and does not scroll. Small "+" signs on the map are Verge Stations and your own ship is shown with a single dot that moves on the map.

The radar is positioned at the bottom of the dashboard. It displays large space objects within your close proximity. The radar screen is divided into a 5x5 grid, with your ship always at the center. Each cell on the radar corresponds to an area visible on the main gameplay screen. For instance, an object shown at the top left corner of the radar indicates it is two screen widths to the left and two screen heights upwards from your current position.

Color coding in radar:
<table>
<tr>
  <td>Blue</td><td>Verge Station - can be docked for trade and diplomacy. Verge Station will activate Asteroid Protection Field when your ship reaches close proximity. To initiate docking sequence your ship's velocity must be below 9 and your ship must be in touch with the station.</td>
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

Note: Your ship's mining computer will mark gold and metal asteroids with small triangles in the center of the asteroid.

<table>
<tr>
  <td>Gray (light/medium/dark)</td><td>Stone asteroid, collision damage reduces ship armor and may destroy your ship</td>
</tr>
<tr>
  <td>Yellow</td><td>Gold asteroid can be mined by touching it. Gold asteroid is also marked with small up-pointing triangle</td>
</tr>
<tr>
  <td>Green</td><td>Metal asteroid can be mined by touching it. Metal steroid is also marked with small down-pointing triangle</td>
</tr>
</table>

Rimward Reach is divided into different sectors based on the asteroid's average kinetic energy. Some regions don't have asteroids at all, and some regions have asteroids with low/medium/high kinetic energy. Mining operations are focused to low energy sectors, as mining in high energy sectors is considered hazardous.

## Verge Station

Eight Verge Stations that are located in Rimward Reach provide a place to trade your minerals and improve your ship's capabilities.

![](https://github.com/orlof/aileon/blob/main/data/station.png?raw=true)

Top part of the screen is trade interface. Left side shows how much each material you have stored in cargo. It also shows how much cargo space (or tank volume) you have for each material. Typically you trade your Gold for credits, and use Credits to fill your Fuel and Oxygen tanks.

Metal is mostly needed in Shipyard for system upgrades (but it can also be sold for Credits). In Shipyard you can use Metal to upgrade your ship's Weapon, Engines, Gyroscopes and Armor, or to increase your Cargo Space. Following table shows the benefit of each upgrade level for subsystems:

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

 - Roy Batty for music
 - Krill for Loader
 - Fekete Csaba for XC=Basic3
 - Michel de Bree for Retropixels
 - Timppa and Spock for play testing

# Release Notes

3.0 Major release - Ad Astra 2420
 - Instead of single file, game now occupies a whole floppy
 - New story elements
 - New dashboard
 - New station interface
 - Difficulty modes
 - Usability improvements

2.02
 - Color coding for dashboard

2.01
 - Added Verge stations to sector map

2.00
 - New ship improvement - gyroscopes - upgrading those babies can make your ship spin like a wheel (I am still a bit hesitant about this change, as it diminishes the turret's value - but on the other hand I haven't heard anyone even trying the two player co-op)
 - Both weapons (forward facing railgun and rotating turret) are now part of the initial ship configuration
 - Possibility to upgrade weapon damage. Initial weapon damage is now weaker than originally, but in the high end the damage is about 2x more powerful than before

1.01 fix for gold cargo bug

1.0 changes since Beta
 - Game balance tuning
   - cheaper armor, cargo space and engine improvements
   - weaker gravity
 - Added sector map and asteroid kinetic energy monitor to dashboard
 - Title screen with smaller memory footprint
 - README game tips added
 - Multiple bug fixes

# Technical Information

Ad Astra is my project to learn games programming for C64. The code is written with XC-Basic 3 (https://xc-basic.net/) and time/memory critical parts are transformed into assembly.

Music is ripped from Millenium Demo and Batty Tunes - made by lengendary Roy Batty. I absolutely love his tunes! The permission to use them is given in the Millenium demo scroller.

    *C:4a78 He^ao                     HOWDY, AND WEL
    *C:4aa0 COME TO THE DEBUT RELEASE OF THE NEW GRO
    *C:4ac8 UP...    MILLENIUM!
    *C:4af0                          ROY BATTY HERE,
    *C:4b18  I'M VERY PROUD TO OFFER THE COMBINED EF
    *C:4b40 FORTS OF MYSELF, FUNGUS, AND WAVEFORM IN
    *C:4b68  OUR FIRST RELEASE.  WE'VE CHOSEN THE NA
    *C:4b90 ME MILLENIUM BECAUSE WE ALL FEEL THAT TH
    *C:4bb8 E C= CULT WILL PROSPER WELL INTO THE SEC
    *C:4be0 OND MILLENNIUM... AND BEYOND!
    *C:4c08      WE ARE NOT HERE TO COMPETE, (WELL,
    *C:4c30 MAYBE A LITTLE...) OUR ONLY GOAL IS TO A
    *C:4c58 CHIEVE A HIGHER UNDERSTANDING OF PROGRAM
    *C:4c80 MING AND TO HAVE FUN DOING IT. WE ARE WI
    *C:4ca8 LLING TO SHARE OUR IDEAS AND ALGORYTHMS
    *C:4cd0 WITH ANYONE WHO MIGHT BE INTERESTED, WE
    *C:4cf8 BELIEVE THAT A GOOD THING IS NOT SO GOOD
    *C:4d20      IF IT'S NOT SHARED...   ALL MUSICS IN T
    *C:4d48     HIS DEMO ARE BATTY-TUNES, FEEL FREE TO R
    *C:4d70     IP THEM, ALL I ASK IS THAT YOU MENTION M
    *C:4d98     Y NAME IN YOUR WORK.     THE MEMBERS OF
    *C:4dc0 MILLENIUM WILL BE RELEASING WAREZ ON THE
    *C:4de8 IR OWN AS WELL AS IN COLLABORATION WITH
    *C:4e10 OTHER GROUPS. FOR TRADES, DICUSSIONS AND
    *C:4e38  SUCH, CONTACT WAVEFORM OR FUNGUS AT THE
    *C:4e60 IR E-MAIL ADDYS LISTED ELSEWHERE IN THIS
    *C:4e88  DEMO.                      MEANWHILE, R
    *C:4eb0 ELAX, HAVE A BANANA, SIT BACK AND ENJOY.
    *C:4ed8 ..                             MILLENIUM

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

MEMORY LAYOUT (INCOMPLETE)

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
