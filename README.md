# DOOM for Thumby Color (RP2350)

![DOOM on Thumby Color](https://img.shields.io/badge/Status-Playable-brightgreen) ![Platform](https://img.shields.io/badge/Platform-RP2350-blue) ![Display](https://img.shields.io/badge/Display-128x128-orange)

A port of Chocolate DOOM to the **Thumby Color** handheld gaming device powered by the **RP2350** microcontroller.

## 🎮 Features

- ✅ Full DOOM gameplay running on RP2350 (ARM Secure mode)
- ✅ Real-time horizontal pixel downsampling (320→128 pixels)
- ✅ Custom GC9107 display driver (128x128 RGB565)
- ✅ Proper portrait orientation
- ✅ DMA-driven rendering with interrupt loop
- ⚠️ Vertical scaling in progress (currently shows top ~64% of game)

## 📸 Screenshots

*Add your photos here!*

## 🔧 Hardware Requirements

- **Thumby Color** by TinyCircuits
- **RP2350** microcontroller (ARM Cortex-M33)
- **GC9107** 128x128 LCD display
- USB-C cable for flashing

## 🚀 Quick Start

### Prerequisites

- MSYS2 MinGW64 environment
- arm-none-eabi-gcc toolchain (13.3.0+)
- CMake and Ninja
- Pico SDK with RP2350 support
- picotool

### Building

```bash
cd rp2040-doom
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja doom_tiny
```

### Flashing

1. Hold BOOTSEL button while plugging in Thumby Color
2. Flash with picotool:
```bash
picotool load build/src/doom_tiny.elf
picotool reboot
```

## 🎯 Technical Highlights

### RP2350-Specific Fixes

- **XIP Access Control**: Required for accessing flash beyond program region
  ```c
  hw_set_bits(&accessctrl_hw->xip_ctrl, ACCESSCTRL_PASSWORD_BITS | 0xff);
  ```
- **Single-core mode**: Multicore broken in ARM Secure mode
- **GPIO limitations**: GPIO 28+ causes crashes on RP2350

### Display Configuration

**Pins (Thumby Color):**
- LCD_DC = GPIO 16
- LCD_CS = GPIO 17  
- LCD_SCK = GPIO 18
- LCD_DO (MOSI) = GPIO 19
- LCD_RST = GPIO 4
- LCD_BL = GPIO 7

**GC9107 Initialization:**
- MADCTL = 0xE0 (portrait orientation: MY=1, MX=1, MV=1)
- INVON (0x21) for correct colors
- RGB565 color mode

### Pixel Downsampling

Horizontal scaling samples every 2.5th pixel to fit 320-pixel game width into 128-pixel display:

```c
for (int i = 0; i < 128; i++) {
    scaled_line[i] = src[(i * 5) / 2];  // Sample every 2.5th pixel
}
```

## 📂 Project Structure

```
rp2040-doom/
├── src/
│   ├── pico/
│   │   ├── i_video.c          # Video system with downsampling
│   │   ├── lcd.c               # GC9107 display driver
│   │   ├── dispDefcon.h        # Display configuration
│   │   └── pinoutRp2350defcon.h # Pin definitions
│   └── doom/
│       └── d_main.c            # XIP access control fix
├── doom1.whx                   # Shareware DOOM WAD (IWHX format)
└── WORKING_CHECKPOINT_2026-02-02/
    └── RESTORE_INSTRUCTIONS.md # Complete setup guide
```

## 🐛 Known Issues

- Vertical downsampling causes black screen (in progress)
- Currently displays top ~64% of game (200→128 pixels needs work)
- Button input not yet implemented
- Audio not yet implemented

## 🔮 Future Work

- [ ] Complete vertical pixel downsampling
- [ ] Implement button controls (GPIO 20-27)
- [ ] Add audio support
- [ ] Performance optimization
- [ ] Menu navigation
- [ ] Save game support

## 📝 Memory Layout

```
Flash Memory Map:
0x10000000 - 0x100B4000  Program code (735KB)
0x10100000 - 0x102B7898  WAD file (1.8MB)
```

## 🤝 Contributing

Contributions welcome! This is cutting-edge RP2350 development. Areas that need help:

1. Vertical downsampling algorithm
2. Button input implementation  
3. Performance optimization
4. Audio system

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

