# DOOM for Thumby Color (RP2350)

DOOM port for TinyCircuits Thumby Color with RP2350-ARM-S processor.

## Installation

1. Hold the **BOOT** button on your Thumby Color
2. Plug in the USB cable while holding BOOT
3. Your computer will show a drive called **RP2350**
4. **Drag and drop** `doom_thumby_color.uf2` onto the RP2350 drive
5. The device will automatically reboot and start DOOM!

## Features

- Full 128x128 display support
- Shareware DOOM WAD included
- Optimized for RP2350-ARM-S
- No audio (hardware limitation with current libraries)

## Controls

- **D-Pad**: Move forward/backward, turn left/right
- **A Button**: Fire weapon
- **B Button**: Use/Open doors

## Technical Notes

- Display: GC9107 128x128 LCD
- CPU: RP2350-ARM-S dual-core Cortex-M33
- Flash: Program runs from external flash
- Audio: Disabled (pico_audio_pwm8 incompatible with Thumby Color's simple PWM audio hardware)

## Building from Source

See the full source code at: https://github.com/Monstayoung/RP2350_Thumby_Color_DOOM

## Credits

Based on Chocolate DOOM and rp2040-doom project
