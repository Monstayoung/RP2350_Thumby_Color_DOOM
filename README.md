# Thumby Color DOOM

DOOM port for Thumby Color (RP2350) running at 270MHz with rumble motor support and sound effects.

## Features

- ✅ DOOM Shareware (Episode 1) running at 270MHz
- ✅ Rumble motor feedback for all 7 weapons (30-150ms durations)
- ✅ Sound effects (ADPCM PCM audio)
- ✅ 128×128 pixel display
- ✅ Optimized for RP2350 dual Cortex-M33

## Hardware Requirements

- **Thumby Color (RP2350-ARM-S)** - Stock hardware, no modifications needed!
  - ✅ Works with original firmware (will be replaced by DOOM)
  - ✅ Rumble motor (built-in, GPIO 5)
  - ✅ Audio speaker (built-in, GPIO 23 PWM, GPIO 20 enable)

## Quick Start (3 Steps)

**The easiest way to get DOOM running on your stock Thumby Color:**

> ✅ **Works on unmodified Thumby Color** - No hardware changes needed! Rumble and audio work out of the box.

1. **Download this repository**
   - Click the green "Code" button → Download ZIP
   - Extract it anywhere (like your Desktop or Downloads folder)
   - Remember where you extracted it!

2. **Install picotool** (one-time setup)
   - Download from: https://github.com/raspberrypi/picotool/releases
   - Add `picotool.exe` to your PATH, OR just remember where you saved it

3. **Flash your Thumby Color**
   - Hold the **BOOT button** while plugging in USB (BOOTSEL mode)
   - **Open PowerShell:** Press `Windows Key`, type `powershell`, press Enter
   - **Navigate to the folder:** Type `cd` then drag the extracted folder into PowerShell, press Enter
     - Example: `cd C:\Users\YourName\Desktop\RP2350_Thumby_Color_DOOM`
   - **Run the flash script:** Type `.\flash.ps1` and press Enter
   - Done! DOOM starts automatically

**That's it!** The script handles everything automatically.

---

## Detailed Installation Guide

### Prerequisites

- [picotool](https://github.com/raspberrypi/picotool) - Download from releases page
- Thumby Color in BOOTSEL mode (hold BOOT button while connecting USB)

**Optional:** Add picotool to your PATH so you can run it from anywhere. Otherwise, just remember where you downloaded it.

### Method 1: Automated Script (Recommended)

**Windows PowerShell:**
```powershell
# Navigate to the downloaded repo folder
cd path\to\RP2350_Thumby_Color_DOOM

# Run the flash script
.\flash.ps1
```

The script automatically:
- ✅ Finds the correct files
- ✅ Flashes in the correct order
- ✅ Checks for errors
- ✅ Reboots your device

### Method 2: Manual Commands (Advanced)

If you prefer to flash manually or the script doesn't work:

**IMPORTANT: Flash in this exact order!**

**Step 1:** Navigate to the repo folder
```powershell
cd path\to\RP2350_Thumby_Color_DOOM
```

**Step 2:** Flash game data (WHX file)
```powershell
picotool load -v binaries/doom1.whx -t bin -o 0x10100000
```

**Step 3:** Flash program (UF2 file)
```powershell
picotool load -v binaries/thumbycolor-doom-rumble-sfx.uf2
picotool reboot
```

**Alternative:** If picotool is not in your PATH, use the full path:
```powershell
C:\path\to\picotool.exe load -v binaries/doom1.whx -t bin -o 0x10100000
C:\path\to\picotool.exe load -v binaries/thumbycolor-doom-rumble-sfx.uf2
C:\path\to\picotool.exe reboot
```

---

## Troubleshooting

**❌ "picotool not found" or "command not found"**
- Download picotool from: https://github.com/raspberrypi/picotool/releases
- Either add it to your PATH, or run it with the full path: `C:\path\to\picotool.exe`
- The flash.ps1 script will tell you if it can't find picotool

**❌ "No accessible RP2040 devices in BOOTSEL mode were found"**
- Make sure you're holding the BOOT button while plugging in USB
- The device should appear as "RPI-RP2" drive in File Explorer
- Try a different USB cable or port

**❌ Flash script won't run / "cannot be loaded because running scripts is disabled"**
- PowerShell blocks scripts by default. Run this once:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- Or run the script with: `powershell -ExecutionPolicy Bypass -File .\flash.ps1`

**❌ No rumble / no audio**
- Confirm you flashed `binaries/thumbycolor-doom-rumble-sfx.uf2` (not a different UF2)
- Stock Thumby Color has rumble and audio built-in, so this should work automatically
- If you modified your hardware or have an older prototype, check GPIO connections

**❓ What happens to the original Thumby Color firmware?**
- It gets replaced by DOOM (this is normal!)
- To restore original firmware, re-flash it using the same process
- Your Thumby Color is not permanently modified

**❌ Game doesn't start after flashing**
- Make sure you flashed BOTH files (WHX first, then UF2)
- Try unplugging and replugging the device
- Check that the WHX flashed to the correct address: `0x10100000`

## Controls

- D-Pad: Move forward/backward, turn left/right
- A Button: Fire weapon
- B Button: Open doors
- Menu: Pause/Menu

## Weapon Rumble Durations

- Chaingun: 30ms (fast tap)
- Plasma: 40ms
- Pistol: 50ms
- Shotgun: 80ms
- Super Shotgun: 100ms (double blast)
- Rocket Launcher: 120ms (heavy kick)
- BFG 9000: 150ms (massive recoil)

## Technical Details

- **CPU**: RP2350 @ 270MHz (overclocked from default 150MHz)
- **RAM**: 520KB
- **Display**: 128×128 pixels
- **Audio**: 49,716Hz sample rate, 2×1024 sample buffers
- **Build**: MinSizeRel, `PICO_HEAP_SIZE=0`, `USE_ZONE_FOR_MALLOC=1`
- **Game Data**: Compressed .whx format (custom WAD compression)

## Known Limitations

- ❌ Music disabled (OPL2 synthesis too CPU intensive)
- ❌ No button combo weapon switching (input timing issues)
- ⚠️ Rumble causes minor frame drops (blocking sleep_ms)

## Building from Source

See [docs/BUILDING.md](docs/BUILDING.md) for compilation instructions.

## Credits

- Original DOOM: id Software
- RP2040/RP2350 Port: [kilograham/rp2040-doom](https://github.com/kilograham/rp2040-doom)
- Thumby Color: TinyCircuits
- Rumble & Audio Implementation: Custom modifications

## License

This project uses code from Chocolate DOOM and the RP2040 DOOM port. See original licenses in source files.
