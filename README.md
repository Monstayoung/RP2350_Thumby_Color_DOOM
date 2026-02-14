# DOOM for Thumby Color (RP2350)

![DOOM on Thumby Color](https://img.shields.io/badge/Status-Fully_Playable-brightgreen) ![Platform](https://img.shields.io/badge/Platform-RP2350-blue) ![Display](https://img.shields.io/badge/Display-128x128-orange)

A fully optimized port of DOOM running on the **Thumby Color** handheld gaming device.

##  Features

- ✅ Full DOOM gameplay with audio
- ✅ 270MHz overclock for smooth performance
- ✅ Enhanced controls (35% faster turning, 20% faster movement)
- ✅ Save state support
- ✅ 128x128 color display with optimized rendering

##  Installation

1. Download **both files** from the [release folder](./release/):
   - `doom_thumby_color.uf2` (the program)
   - `doom1.whx` (the game data)
2. Install **picotool** if you don't have it
3. Follow the step-by-step instructions in [release/INSTALL.md](./release/INSTALL.md)

**Quick version:**
```bash
picotool load doom_thumby_color.uf2
picotool load -t bin doom1.whx -o 0x10100000
picotool reboot
```

## 🎯 Controls

| Button | Action |
|--------|--------|
| **D-Pad Up** | Move forward |
| **D-Pad Down** | Move backward |
| **D-Pad Left** | Turn left |
| **D-Pad Right** | Turn right |
| **A Button** | Menu select / Enter |
| **B Button** | Fire weapon |
| **Left Bumper** | Use / Open doors |
| **Right Bumper** | Strafe |
| **Menu Button** | Access menu |



---

## 🛠️ For Developers

<details>
<summary>Click to expand build instructions</summary>

### Prerequisites
- Windows with MSYS2 MinGW64
- arm-none-eabi-gcc toolchain
- CMake and Ninja
- Pico SDK with RP2350 support

### Building

```bash
cd defcon/rp2040-doom
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel ..
ninja
```

### Creating UF2

Use the automated script:
```powershell
.\build_and_flash.ps1
```

Or manually:
```powershell
cd build
ninja
C:\msys64\home\Q\bin\picotool.exe uf2 convert src\doom_tiny.elf src\doom_tiny.uf2 --family rp2350-arm-s
```

</details>

---

## 📄 License

Based on Chocolate DOOM (GPL-2.0)

## 🙏 Credits

- Chocolate DOOM team
- TinyCircuits for Thumby Color
- Raspberry Pi Foundation for RP2350

