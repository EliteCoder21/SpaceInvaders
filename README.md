# Space Invaders FPGA Implementation

<div align="center">

![Project Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Hardware](https://img.shields.io/badge/Hardware-DE1--SoC-blue)
![Language](https://img.shields.io/badge/Language-SystemVerilog-orange)
![Tools](https://img.shields.io/badge/Tools-Quartus%20Prime%2017.1%20%7C%20ModelSim-blue)

*A simplified Space Invaders game implemented on an FPGA*

</div>

---

## Overview

This project implements a simplified version of the classic arcade game **Space Invaders** on the **DE1-SoC** FPGA development board. The game features interactive gameplay with basic game logic, rendered on a 16x16 bi-color LED matrix.

### Gameplay

| Element            | Color     | Description                                   |
|--------------------|-----------|-----------------------------------------------|
| **Player**         | 🟩 Green  | Controlled by the player, moves horizontally |
| **Aliens**         | 🟥 Red    | Enemy characters that move and shoot         |
| **Player Bullets** | 🟩 Green  | Shoot upward to destroy aliens               |
| **Alien Bullets**  | 🟧 Orange | Shoot downward at the player                 |

**Objective:** Destroy aliens with your bullets to score points. Avoid alien bullets or lose points!

---

## Hardware Configuration

### Target Board
- **DE1-SoC Development Kit** (Cyclone V FPGA)

### I/O Mapping

| Signal     | Pin      | Function                  |
|------------|----------|---------------------------|
| `CLOCK_50` | PIN_AF14 | 50 MHz system clock       |
| `KEY[0]`   | PIN_AA15 | Move right                |
| `KEY[1]`   | PIN_W15  | Fire bullet               |
| `KEY[2]`   | PIN_Y16  | Move left                 |
| `KEY[3]`   | PIN_V16  | Reset (active low)        |
| `HEX0-2`   | -        | Score display (7-segment) |
| `GPIO_1`   | -        | 16x16 LED Matrix header   |

---

## Project Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        DE1_SoC.sv                             │
│                    (Top-Level Module)                         │
└─────────────────────┬─────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┬────────────────┐
        │             │             │                │
        ▼             ▼             ▼                ▼
┌──────────────┐ ┌──────────┐ ┌────────────┐ ┌─────────────────┐
│clock_divider│ │ LEDDriver│ │  Game      │ │   Score Display │
│             │ │          │ │  Logic     │ │                 │
│ Generates   │ │ Drives   │ │            │ │ Converts binary │
│ divided     │ │ 16x16 LED│ │ Player,    │ │ score to 7-seg  │
│ clocks      │ │ matrix   │ │ Aliens,    │ │ display         │
└─────────────┘ └──────────┘ │ Bullets    │ └─────────────────┘
                             │            │
                             │ ┌──────────┴──────────┐
                             │ │                     │
                             ▼ ▼                     ▼
                       ┌──────────┐ ┌──────────┐ ┌──────────────┐
                       │player_   │ │ aliens   │ │random_choice│
                       │control   │ │          │ │              │
                       └──────────┘ │ Movement │ │ 41-bit LFSR  │
                       ┌──────────┐ │ & AI     │ │ for pseudo-  │
                       │player_   │ │          │ │ random       │
                       │bullets   │ └──────────┘ │ behavior     │
                       └──────────┘              └──────────────┘
```

### Module Descriptions

| Module | File | Purpose |
|--------|------|---------|
| `DE1_SoC` | DE1_SoC.sv | Top-level integration |
| `LEDDriver` | LEDDriver.sv | Drives 16x16 bi-color LED matrix via GPIO |
| `clock_divider` | clock_divider.sv | Generates multiple clock frequencies |
| `player_control` | player_control.sv | Handles player movement (shift-register based) |
| `player_bullets` | player_bullets.sv | Manages player bullet firing and movement |
| `aliens` | aliens.sv | Alien movement, AI, and collision detection |
| `random_choice` | random_choice.sv | 41-bit LFSR for pseudo-random behavior |
| `draw_enemies` | draw_enemies.sv | Composites game elements into pixel buffers |
| `binary_score_to_decimal_7seg` | binary_score_to_decimal_7seg.sv | Score to 7-segment conversion |

---

## Key Features

### 1. LFSR-Based Enemy AI
The game uses a **41-bit Linear Feedback Shift Register (LFSR)** to generate pseudo-random values that control:
- Alien horizontal movement patterns
- Alien bullet firing timing
- Alien respawn positions

### 2. Collision Detection
- **Player bullets hitting aliens:** Alien destroyed, score +1
- **Alien bullets hitting player:** Score -1 (if score > 0)

### 3. LED Matrix Display
- 16x16 bi-color (red/green) LED matrix
- Row-scanning technique for efficient multiplexing
- Color mixing: Red + Green = Orange (alien bullets)

---

## Gameplay Sample

```
⬛ 🟥 ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛
⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ 🟥 ⬛ ⬛    ← Alien rows (red)
⬛ ⬛ ⬛ 🟥 ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛
⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛
⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛
⬛ ⬛ ⬛ ⬛ ⬛ 🟩 ⬛ ⬛ ⬛ ⬛ ⬛    ← Player bullet (green)
⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛
⬛ ⬛ 🟥 ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛    ← Alien bullet (orange)
⬛ ⬛ ⬛ ⬛ ⬛ 🟩 ⬛ ⬛ ⬛ ⬛ ⬛
⬛ ⬛ ⬛ ⬛ 🟩 🟩 🟩 ⬛ ⬛ ⬛ ⬛    ← Player (green)
```

---

## Development Tools

|         Tool        | Version |                Purpose                 |
|---------------------|---------|----------------------------------------|
|  **Quartus Prime**  |   17.1  | FPGA synthesis and board programming   |
| **ModelSim-Altera** |     -   | Functional simulation and verification |
|     **DE1-SoC**     |     -   | Target hardware (Cyclone V)            |

---

## Building and Running

### 1. Quartus Synthesis
1. Open `DE1_SoC.qpf` in Quartus Prime
2. Run Analysis & Synthesis
3. Compile the design
4. Program the FPGA using `output_files/DE1_SoC.sof`

### 2. ModelSim Simulation
```bash
# Launch ModelSim
.\Launch_ModelSim.bat

# Or run the simulation script
vsim -do runlab.do
```

---

## File Structure

```
SpaceInvaders/
├── DE1_SoC.sv                  # Top-level module
├── DE1_SoC.qpf                # Quartus project file
├── DE1_SoC.qsf                # Pin assignments
│
├── Implementation Files/
│   ├── LEDDriver.sv            # LED matrix driver
│   ├── clock_divider.sv        # Clock generation
│   ├── player_control.sv       # Player movement
│   ├── player_bullets.sv        # Player bullets
│   ├── aliens.sv               # Alien enemies
│   ├── draw_enemies.sv         # Graphics compositor
│   ├── random_choice.sv        # LFSR random generator
│   └── binary_score_to_decimal_7seg.sv  # Score display
│
├── Simulation/
│   ├── runlab.do               # ModelSim batch script
│   └── DE1_SoC_wave.do         # Waveform configuration
│
└── output_files/
    └── DE1_SoC.sof             # FPGA programming file
```

---

## Technical Notes

### Clock Domains
- **CLOCK_50 (50 MHz):** Source clock for all game logic
- **clk[14] (~1526 Hz):** LED matrix row scanning
- **clk[20] (~48 Hz):** Optional for slower animations

### Display Configuration
- **Scan Rate:** ~1526 Hz (clk[14])
- **Flicker Note:** If flickering occurs, try using a faster clock
- **Brightness Note:** Faster scanning reduces LED brightness

---

## Credits

Developed as part of **EE 271** course work. I took the class with Professor Mahmood Hameed at the University of Washington.

---

## License

This project is provided for educational purposes.
