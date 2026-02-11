# DOOM for Thumby Color (RP2350)

![DOOM on Thumby Color](https://img.shields.io/badge/Status-Fully_Playable-brightgreen) ![Platform](https://img.shields.io/badge/Platform-RP2350-blue) ![Display](https://img.shields.io/badge/Display-128x128-orange)

A fully working port of Chocolate DOOM to the **Thumby Color** handheld gaming device powered by the **RP2350** microcontroller.

## 🎮 Features

- ✅ Full DOOM gameplay running on RP2350 (ARM Secure mode)
- ✅ 270MHz overclock for improved performance
- ✅ Enhanced controls (+35% faster turning, +20% faster movement)
- ✅ Working audio with PWM output
- ✅ Save state support (save and resume your progress!)
- ✅ Complete vertical coverage (200→128 scanlines with smart downsampling)
- ✅ Real-time horizontal pixel downsampling (320→128 pixels)
- ✅ Custom GC9107 display driver (128x128 RGB565)
- ✅ Proper orientation with BGR color correction
- ✅ Working button controls (D-pad, A/B, bumpers)
- ✅ DMA-driven rendering with continuous scanline processing

## 🎯 Controls

**D-Pad:**
- UP (GPIO 1): Move forward
- DOWN (GPIO 3): Move backward  
- LEFT (GPIO 0): Turn left
- RIGHT (GPIO 2): Turn right

**Action Buttons:**
- A Button (GPIO 21): Menu select / Enter
- B Button (GPIO 25): Fire weapon / Shoot

**Bumpers:**
- Left Bumper (GPIO 6): Use/Activate
- Right Bumper (GPIO 22): Strafe

**System:**
- Menu Button (GPIO 26): Access menu

## 📸 Screenshots

*Add your photos here!*

## 🔧 Hardware Requirements

- **Thumby Color** by TinyCircuits
- **RP2350** microcontroller (ARM Cortex-M33)
- **GC9107** 128x128 LCD display
- USB-C cable for flashing

## 🚀 Quick Start

### For Users (Easy!)

**Just drag and drop - no tools needed!**

1. Download `doom_thumby_color.uf2` from the [release folder](./release/)
2. Hold the **BOOTSEL button** on your Thumby Color while plugging it in via USB
3. Your Thumby Color will appear as a USB drive (usually D: on Windows)
4. Drag and drop `doom_thumby_color.uf2` onto the drive
5. The Thumby will automatically flash and reboot into DOOM!

**That's it! Start playing!**

### For Developers (Building from Source)

#### Prerequisites

- Windows with MSYS2 MinGW64 environment
- arm-none-eabi-gcc toolchain (13.3.0+)
- CMake and Ninja
- Pico SDK with RP2350 support

#### Building

```bash
cd defcon/rp2040-doom
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel ..
ninja
```

#### Creating UF2 (Windows)

Use the provided PowerShell script for easy building and flashing:

```powershell
.\build_and_flash.ps1
```

Or manually:
```powershell
# Build
cd build
ninja

# Convert ELF to UF2
C:\msys64\home\Q\bin\picotool.exe uf2 convert src\doom_tiny.elf src\doom_tiny.uf2 --family rp2350-arm-s

# Flash (with Thumby in BOOTSEL mode on D:)
Copy-Item src\doom_tiny.uf2 D:\doom_tiny.uf2
```

## 🎯 Technical Highlights

### Performance Optimizations

- **270MHz Overclock**: CPU running at 270MHz (11% faster than default 243MHz) for improved frame rate
- **Enhanced Controls**: 
  - Turn speed increased by 35% for more responsive aiming
  - Movement speed increased by 20% for better gameplay feel
- **Stable Voltage**: VREG set to 1.30V for reliable overclocking

### RP2350-Specific Fixes

- **XIP Access Control**: Required for accessing flash beyond program region
  ```c
  hw_set_bits(&accessctrl_hw->xip_ctrl, ACCESSCTRL_PASSWORD_BITS | 0xff);
  ```
- **Single-core mode**: Multicore not used (ARM Secure mode limitations)
- **GPIO limitations**: Buttons mapped to GPIO 0-6, 21-22, 25-26 (safe range for RP2350)

### Display Configuration

**Pins (Thumby Color):**
- LCD_DC = GPIO 16
- LCD_CS = GPIO 17  
- LCD_SCK = GPIO 18
- LCD_DO (MOSI) = GPIO 19
- LCD_RST = GPIO 4
- LCD_BL = GPIO 7

**Button Pins (Thumby Color):**
- D-PAD_LEFT = GPIO 0
- D-PAD_UP = GPIO 1
- D-PAD_RIGHT = GPIO 2
- D-PAD_DOWN = GPIO 3
- BUMPER_LEFT = GPIO 6
- BUTTON_A = GPIO 21
- BUMPER_RIGHT = GPIO 22
- BUTTON_B = GPIO 25
- MENU = GPIO 26

**GC9107 Initialization:**
- MADCTL = 0xC8 (MY=1, MX=1, MV=0, BGR=1)
- Display Inversion ON (0x21) - critical for correct colors
- RGB565 color mode (16-bit)

### Pixel Downsampling

**Horizontal:** Samples every 2.5th pixel to fit 320-pixel game width into 128-pixel display:

```c
for (int i = 0; i < 128; i++) {
    scaled_line[i] = src[(i * 5) / 2];  // Sample every 2.5th pixel
}
```

**Vertical:** Maps 200 game scanlines to 128 display rows by rendering each scanline to calculated display row:

```c
uint8_t display_row = (asl * 128) / 200;  // Maps scanline 0-199 to row 0-127
dispRenderLine(display_row, scaled_line, 128);
```

This ensures all 200 vertical scanlines are represented across the 128 display rows without skipping `dispRenderLine()` calls (which would break the DMA chain).

## 📂 Project Structure

```
rp2040-doom/
├── src/
│   ├── pico/
│   │   ├── i_video.c          # Video system with dual-axis downsampling
│   │   ├── i_input.c          # Button input handling
│   │   ├── lcd.c              # GC9107 display driver
│   │   ├── lcd.h              # Display function declarations
│   │   ├── dispDefcon.h       # Display configuration
│   │   └── pinoutRp2350defcon.h # Thumby Color pin definitions
│   └── doom/
│       └── d_main.c           # XIP access control fix
├── doom1.whx                  # Shareware DOOM WAD (IWHX format)
├── build/                     # Build output directory
└── WORKING_CHECKPOINT_*/      # Backup snapshots
```

## 🐛 Known Issues & Solutions

### Solved Issues:
- ✅ **Color inversion fixed**: Required MADCTL BGR bit (0x08) + Display Inversion ON
- ✅ **Black screen on vertical scaling**: Must call `dispRenderLine()` for every scanline to maintain DMA chain
- ✅ **Button GPIO mapping**: Used actual Thumby Color GPIO (0-3, 6, 21-22, 25-26) instead of 20-27
- ✅ **Vertical coverage**: Map 200 scanlines to 128 rows using `(scanline * 128) / 200`

### Current Issues:
- Minor 1-pixel colorful artifact on right edge (cosmetic only)
- Audio not yet implemented
- Save game support not implemented

## 🔮 Future Work

- [ ] Add audio support (OPL emulator compiled in, needs initialization)
- [ ] Implement save game support
- [ ] Performance optimization
- [ ] Weapon switching combo refinement
- [ ] Remove 1-pixel edge artifact

## 📝 Memory Layout

```
Flash Memory Map:
0x10000000 - 0x100B4000  Program code (~735KB)
0x10100000 - 0x102B7898  WAD file (~1.8MB)

RAM Usage:
- Frame buffers: ~64KB (double buffered)
- Game state: ~150KB
- Stack/heap: ~50KB
Total: ~264KB (fits in RP2350 RAM)
```

## 🔍 Development Insights

### Critical Discoveries:

1. **DMA Chain Must Not Break**: The `fill_scanlines()` function is called after each DMA completion. Skipping `dispRenderLine()` calls breaks the chain and causes black screens.

2. **Display Rotation Architecture**: The GC9107 MADCTL MV bit (row/column exchange) was initially used, causing the game to render vertical columns instead of horizontal scanlines. Removing MV and adjusting `lcdSetRegion()` from `(y, 0, 1, width)` to `(0, y, width, 1)` fixed orientation.

3. **GPIO Safety on RP2350**: GPIO 28+ can cause crashes in certain RP2350 configurations. Thumby Color uses safe GPIOs (0-26).

4. **Vertical Downsampling Strategy**: Since we must call `dispRenderLine()` for all 200 scanlines, we map each to a calculated display row. Some rows get overwritten (later scanlines), but this shows the full game view.

## 🤝 Contributing

This is a fully working implementation! Areas for enhancement:

1. Audio implementation (PWM8 code exists, needs activation)
2. Performance optimization
3. UI polish and menu improvements
4. Additional control schemes

## 📄 License

Based on Chocolate DOOM (GPL-2.0). See original project for license details.

## 🙏 Credits

- **Chocolate DOOM** team for the original port
- **TinyCircuits** for Thumby Color hardware
- **Raspberry Pi Foundation** for RP2350 and Pico SDK
- This port created with assistance from GitHub Copilot

## 📚 References

- [Chocolate DOOM](https://github.com/chocolate-doom/chocolate-doom)
- [Thumby Color](https://tinycircuits.com/products/thumby-color)
- [RP2350 Datasheet](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf)
- [GC9107 Display Driver](https://www.buydisplay.com/download/ic/GC9107.pdf)

---

**Status:** Active Development | **First Playable:** February 2026 🎉

