# WORKING DOOM BUILD FOR THUMBY COLOR RP2350 - CHECKPOINT 2026-02-02

## ✅ STATUS: DOOM RENDERING ON SCREEN WITH HORIZONTAL DOWNSAMPLING!

This checkpoint represents DOOM on Thumby Color RP2350 with proper horizontal scaling.
Game graphics are visible and updating with full 320→128 pixel downsampling, showing the complete width of the game scaled to fit the screen. Vertical shows top portion (will need vertical scaling next).

---

## 🔧 HARDWARE CONFIGURATION

### Thumby Color Display Pins (GC9107 128x128 LCD)
**CRITICAL: These are the CORRECT pins for Thumby Color hardware**

```
PIN_LCD_DC   = 16  (Data/Command)
PIN_LCD_CS   = 17  (Chip Select)
PIN_LCD_SCK  = 18  (SPI Clock)
PIN_LCD_DO   = 19  (SPI MOSI - Data Out)
PIN_LCD_RST  = 4   (Reset)
PIN_LCD_BL   = 7   (Backlight - used as simple GPIO, NOT in PWM config)
```

**File:** `src/pico/pinoutRp2350defcon.h`

### Display Configuration
**File:** `src/pico/dispDefcon.h`
```c
#define HARDWARE_WIDTH  128
#define HARDWARE_HEIGHT 128
#define DISP_WIDTH      128
#define DISP_HEIGHT     128
```

**Actual 128x128 GC9107 display dimensions.**

---

## 🔑 CRITICAL FIXES IMPLEMENTED

### 1. RP2350 XIP Access Control (REQUIRED!)
**File:** `src/doom/d_main.c` at line ~1580 (after D_AddFile call)
```c
#if PICO_RP2350
    hw_set_bits(&accessctrl_hw->xip_ctrl, ACCESSCTRL_PASSWORD_BITS | 0xff);
#endif
```
**Why?** RP2350 requires explicit XIP permissions to access flash beyond program region. Without this, WAD file reading crashes.

### 2. GPIO Configuration Fix
**File:** `src/pico/lcd.c` - `gpiosConfig()` function

**LCD_BL (GPIO 7) REMOVED from gpiosConfig array:**
```c
static const struct {
    uint8_t pinNo;
    uint8_t func;
    uint8_t dir : 1;
    uint8_t pulls : 2;
    uint8_t val : 1;
} gpioCfgs[] = {
    { .pinNo = PIN_LCD_DnC,   .func = GPIO_FUNC_SIO, .dir = 1, .pulls = 0, .val = 0, },
    { .pinNo = PIN_LCD_SCK,   .func = GPIO_FUNC_SIO, .dir = 1, .pulls = 0, .val = 1, },
    { .pinNo = PIN_LCD_DO,    .func = GPIO_FUNC_SIO, .dir = 1, .pulls = 0, .val = 0, },
    { .pinNo = PIN_LCD_CS,    .func = GPIO_FUNC_SIO, .dir = 1, .pulls = 0, .val = 1, },
    // PIN_LCD_BL commented out - configured separately as simple GPIO
    { .pinNo = PIN_SELF_PWR,  .func = GPIO_FUNC_SIO, .dir = 0, .pulls = 2, .val = 0, },
};
```

**Button pins disabled:**
```c
for (i = 0; i < sizeof(gpioCfgs) / sizeof(gpioCfgs[0]); i++) {
    if (pinNo >= 28) continue;  // Skip GPIO 28+ (crashes on RP2350)
    // ... rest of configuration
}
```

### 3. Backlight Configuration
**File:** `src/pico/i_video.c` - `I_InitGraphics()` function
```c
// Initialize GPIO 7 for backlight
gpio_init(7);
gpio_set_dir(7, GPIO_OUT);

gpiosConfig(true);
dispInit(10);
dispOn();

// Keep backlight ON (100% brightness)
gpio_put(7, 1);

// Start the rendering loop by calling fill_scanlines once
// The DMA interrupt will then keep calling it
fill_scanlines();
```

### 4. GC9107 Display Initialization
**File:** `src/pico/lcd.c` - `dispInit()` function
```c
// GC9107 initialization sequence (VERIFIED WORKING on Thumby Color)
printf("Initializing GC9107 display\n");

// Inter Register Enable
lcdCmd(0xFE, true, -1);  // Inter Register Enable1
lcdCmd(0xEF, true, -1);  // Inter Register Enable2

// Power Control
lcdCmd(0xB3, true, 0x03, -1);  // PWRCTRL2

// Color mode - 16-bit RGB565
lcdCmd(0x3A, true, 0x55, -1);  // COLMOD

// Memory Access Control - Rotate 90° for portrait
lcdCmd(0x36, true, 0xE0, -1);  // MADCTL: MY=1, MX=1, MV=1

// Display Inversion ON - CRITICAL for correct colors!
lcdCmd(0x21, true, -1);  // INVON

// Sleep Out
lcdCmd(0x11, true, -1);  // SLPOUT
lcdDelayMs(120);

// Display On  
lcdCmd(0x29, true, -1);  // DISPON
lcdDelayMs(20);
```

**MADCTL 0xE0** provides proper portrait orientation without mirroring.

### 5. Display Rendering Configuration
**File:** `src/pico/lcd.c` - `dispRenderLine()` function
```c
void __not_in_flash_func(dispRenderLine)(uint y, uint16_t *buf, uint32_t width) {
    while (dma_channel_is_busy(DISP_DMA_XFER_CH));
    busy_wait_at_least_cycles(3200);
    dispPrvSetPioWidth(8);
    lcdSetRegion(y, 0, 1, width, 0, 0);  // Direct coordinates with MADCTL rotation
    lcdCmd(0x2c, false, -1);
    dispPrvSetPioWidth(16);
    dma_channel_transfer_from_buffer_now(DISP_DMA_XFER_CH, buf, 128);
}
```

**File:** `src/pico/i_video.c` - `fill_scanlines()` function with HORIZONTAL DOWNSAMPLING
```c
static uint16_t scaled_line[128]; // Scaled line buffer

void __scratch_x("scanlines") fill_scanlines() {
    if (stretch) {
        // Downsample from 320 pixels to 128 pixels (scale factor ~2.5)
        uint16_t *src = (uint16_t*)(sdata[which] + 1);
        for (int i = 0; i < 128; i++) {
            // Sample every 2.5th pixel: i * 320 / 128 = i * 2.5
            scaled_line[i] = src[(i * 5) / 2];
        }
        dispRenderLine(asl++, scaled_line, 128);
        if ((asl % 6) == 0) return;
    }
}
```

**KEY FEATURE:** Horizontal pixel downsampling converts 320-pixel game width to 128-pixel display width by sampling every 2.5th pixel. This shows the full width of the game scaled to fit!

---

## 💾 MEMORY LAYOUT

### Flash Memory Map
```
0x10000000 - 0x100B4000  : Program code (735KB)
0x10100000 - 0x102B7898  : WAD file doom1.whx (1,800,344 bytes)
```

**WAD Address:** `0x10100000` (1MB offset from program start)
- Safe separation from program code
- Accessible after XIP access control enabled

### WAD File Details
- **File:** doom1.whx
- **Format:** IWHX (Chocolate Doom shareware WAD)
- **Size:** 1,800,344 bytes
- **Lumps:** 1264
- **Location:** Flash via `add_custom_command` in CMakeLists.txt

---

## 🔨 BUILD PROCESS

### Prerequisites
- MSYS2 MinGW64 environment
- arm-none-eabi-gcc 13.3.0
- CMake + Ninja
- Pico SDK (RP2350 support)
- picotool

### Build Commands
```powershell
cd C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom

# Clean build (if needed)
Remove-Item -Recurse -Force build\src\CMakeFiles\doom_tiny.dir

# Build
ninja -C build doom_tiny

# Flash to device (device must be in BOOTSEL mode)
C:\msys64\home\Q\bin\picotool.exe load build\src\doom_tiny.elf
C:\msys64\home\Q\bin\picotool.exe reboot
```

### Build Configuration
**Platform:** RP2350 ARM Secure (rp2350-arm-s)
**Core:** Cortex-M33
**Mode:** Single-core (multicore broken in ARM Secure mode)
**RAM:** 264KB
**Flash tool:** picotool (UF2 drag-drop unreliable on RP2350)

---

## 📋 TO RESTORE THIS CHECKPOINT

### Option 1: Copy Backup Files
```powershell
Copy-Item "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02\lcd.c" "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\src\pico\lcd.c"
Copy-Item "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02\i_video.c" "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\src\pico\i_video.c"
Copy-Item "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02\dispDefcon.h" "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\src\pico\dispDefcon.h"
Copy-Item "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02\pinoutRp2350defcon.h" "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\src\pico\pinoutRp2350defcon.h"
Copy-Item "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02\d_main.c" "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\src\doom\d_main.c"
```

### Option 2: Flash Pre-Built Binary
```powershell
# Put device in BOOTSEL mode, then:
C:\msys64\home\Q\bin\picotool.exe load "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02\doom_tiny.elf"
C:\msys64\home\Q\bin\picotool.exe reboot
```

---

## 🎮 CURRENT BEHAVIOR

### ✅ What Works
- Display hardware fully functional
- Game engine running
- Frame rendering active  
- DMA interrupt loop working
- Backlight staying on
- **GAME GRAPHICS VISIBLE ON SCREEN!**
- **HORIZONTAL DOWNSAMPLING: Full 320-pixel game width scaled to 128 pixels!**
- **PROPER ORIENTATION: Portrait mode, no mirroring (MADCTL 0xE0)**

### ⚠️ Known Issues (To Be Fixed)
- Only showing top ~64% of game (200 pixels tall → 128-pixel display needs vertical scaling)
- Vertical downsampling attempted but caused black screen (reverted)

### 💡 Current Display Status
The horizontal scaling works perfectly - you can see the entire width of the DOOM logo and gameplay scaled to fit. The vertical dimension still needs work to show the full height of the game.

---

## 🔧 KEY CODE SECTIONS

### Display Rendering Entry Point
`src/pico/i_video.c:990` - `fill_scanlines()` function
- Called initially by `I_InitGraphics()` to start DMA loop
- Called repeatedly by DMA interrupt handler `line_done()`
- Triggers `dispRenderLine()` for each scanline

### DMA Interrupt Handler  
`src/pico/lcd.c:262` - `line_done()` function
```c
void __not_in_flash_func(line_done)(void) {
    dma_irqn_acknowledge_channel(2, DISP_DMA_XFER_CH);
    fill_scanlines();
}
```

### GPIO Configuration
`src/pico/lcd.c:44` - `gpiosConfig()` function
- Only 5 pins configured (DC, SCK, DO, CS, SELF_PWR)
- Button pins disabled (GPIO 20-28 cause crashes)
- LCD_BL handled separately

---

## 🐛 TROUBLESHOOTING

### If Display Shows Only Colorful Border (No Game Graphics)
- `fill_scanlines()` not being called
- DMA interrupt not firing
- Frame buffer not populated
→ **Solution:** Ensure `fill_scanlines()` is called in `I_InitGraphics()` after `dispOn()`

### If Display Is Completely Black
- Backlight not turned on
- Display init failed
- GC9107 not receiving commands
→ **Solution:** Check GPIO 7 is set high, verify SPI pins

### If Device Crashes During Init
- GPIO 28+ accessed (not available on RP2350)
- XIP access control not enabled before WAD access
- Button pins in gpiosConfig array
→ **Solution:** Restore checkpoint files

---

## 📝 NEXT STEPS (For Future Work)

1. **Fix rotation:** Adjust MADCTL or coordinate system for proper vertical orientation
2. **Fix scaling:** Scale 320x200 game output to fit 128x128 display  
3. **Center viewport:** Show proper gameplay area (not zoomed corner)
4. **Button input:** Configure GPIO 20-27 for buttons (carefully!)
5. **Performance optimization:** Tune frame rate and DMA timing

---

## 📞 SUPPORT INFO

**Project:** Chocolate Doom port to Thumby Color (RP2350)
**Hardware:** Thumby Color with RP2350 (ARM Secure mode)
**Display:** GC9107 128x128 RGB565 LCD
**Build Date:** February 2, 2026
**Status:** First successful rendering achieved! 🎉

---

## 🎯 SUMMARY FOR AI/COPILOT REPRODUCTION

To reproduce this exact working build:

1. **Hardware Pins:**
   - DC=16, CS=17, SCK=18, DO=19, RST=4, BL=7
   - Buttons disabled (GPIO crash on RP2350)

2. **Display Config:**
   - HARDWARE_WIDTH=128, HARDWARE_HEIGHT=128
   - DISP_WIDTH=128, DISP_HEIGHT=128
   - MADCTL=0xE0 for portrait orientation
   - Coordinates: lcdSetRegion(y, 0, 1, width, 0, 0)

3. **Critical Fixes:**
   - RP2350 XIP access control after WAD load
   - LCD_BL as simple GPIO (not in gpiosConfig)
   - fill_scanlines() called in I_InitGraphics()
   - GC9107 init with INVON (0x21) and MADCTL (0xE0)
   - **Horizontal downsampling: 320→128 pixels via sampling every 2.5th pixel**

4. **Build:**
   - ninja -C build doom_tiny
   - picotool load + reboot

5. **Result:**
   - DOOM renders in portrait mode with full width visible!
   - Horizontal scaling perfect, vertical needs work

**All backup files stored in:** `WORKING_CHECKPOINT_2026-02-02/`
