# Thumby Color DOOM

DOOM port for Thumby Color (RP2350) running at 270MHz with rumble motor support and sound effects.

## Features

- ✅ DOOM Shareware (Episode 1) running at 270MHz
- ✅ Rumble motor feedback for all 7 weapons (30-150ms durations)
- ✅ Sound effects (ADPCM PCM audio)
- ✅ 128×128 pixel display
- ✅ Optimized for RP2350 dual Cortex-M33

## Hardware Requirements

- Thumby Color (RP2350-ARM-S)
- Rumble motor on GPIO 5
- Audio: GPIO 23 (PWM), GPIO 20 (speaker enable)

## Installation

### Prerequisites

1. Install [picotool](https://github.com/raspberrypi/picotool)
2. Put Thumby Color in BOOTSEL mode (hold BOOT button while connecting USB)

### Flashing Steps

**IMPORTANT: Flash in this exact order!**

#### Step 1: Flash the game data (WHX file)
```powershell
picotool load -v binaries/doom1.whx -t bin -o 0x10100000
```

#### Step 2: Flash the program (UF2 file)
Simply drag `binaries/thumbycolor-doom-rumble-sfx.uf2` onto the RPI-RP2 drive, or:
```powershell
picotool load -v binaries/thumbycolor-doom-rumble-sfx.uf2
picotool reboot
```

### Quick Flash Script (Windows PowerShell)

```powershell
# flash.ps1
$ErrorActionPreference = "Stop"

Write-Host "Flashing Thumby Color DOOM..." -ForegroundColor Cyan

# Flash game data
Write-Host "`n[1/2] Flashing doom1.whx to 0x10100000..." -ForegroundColor Yellow
picotool load -v binaries/doom1.whx -t bin -o 0x10100000

# Flash program
Write-Host "`n[2/2] Flashing UF2..." -ForegroundColor Yellow
picotool load -v binaries/thumbycolor-doom-rumble-sfx.uf2

# Reboot
Write-Host "`nRebooting Thumby Color..." -ForegroundColor Green
picotool reboot

Write-Host "`n✓ Flash complete! DOOM should start automatically." -ForegroundColor Green
```

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
