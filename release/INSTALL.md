# DOOM for Thumby Color - Installation Guide

## 📦 What You Need
- Thumby Color (RP2350)
- USB cable
- Windows/Mac/Linux computer
- **picotool** installed ([Get it here](https://github.com/raspberrypi/picotool))

## 🚀 Installation Steps

### Step 1: Enter BOOTSEL Mode
1. **Unplug** your Thumby Color from USB
2. **Hold down the BOOT button** (small button on the side/back)
3. **While holding BOOT**, plug the USB cable into your computer
4. Release the BOOT button
5. A drive named **RPI-RP2** should appear

### Step 2: Flash the Game
Open a terminal/command prompt and run these two commands:

**Windows:**
```cmd
picotool load doom_thumby_color.uf2
picotool load -t bin doom1.whx -o 0x10100000
picotool reboot
```

**Mac/Linux:**
```bash
picotool load doom_thumby_color.uf2
picotool load -t bin doom1.whx -o 0x10100000
picotool reboot
```

### Step 3: Play!
Your Thumby Color will reboot and DOOM will start automatically!

---

## ⚠️ Important Notes

- **Both files are required!** The `.uf2` is the program, the `.whx` is the game data
- Flashing the original Thumby firmware will erase DOOM - just reflash both files to restore it
- If you get a black screen, make sure you flashed BOTH files

## 🎮 Controls
- **D-Pad Up/Down**: Move forward/backward
- **D-Pad Left/Right**: Turn left/right
- **A Button**: Menu select / Enter
- **B Button**: Fire weapon
- **Left Bumper**: Use / Open doors
- **Right Bumper**: Strafe

---

## 🛠️ Troubleshooting

**Black screen after flashing?**
- Make sure you flashed BOTH files (doom_thumby_color.uf2 AND doom1.whx)
- Try reflashing: put back in BOOTSEL mode and run the commands again

**Can't find picotool?**
- Install from: https://github.com/raspberrypi/picotool
- Or use your system's package manager

**Original Thumby firmware won't work anymore?**
- DOOM uses the full flash memory. Download the original firmware from TinyCircuits and flash it back.
