# Thumby Color DOOM - Build Guide

## Prerequisites

- Raspberry Pi Pico SDK (RP2350 support)
- CMake 3.13+
- ARM GCC toolchain
- Git

## Build Steps

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd thumbycolor-doom
git submodule update --init --recursive
```

### 2. Setup Pico SDK
```bash
export PICO_SDK_PATH=/path/to/pico-sdk
export PICO_EXTRAS_PATH=/path/to/pico-extras
```

### 3. Build
```bash
cd build
cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DPICO_BOARD=thumby_color
make -j4
```

### 4. Output Files
- `thumbycolor-doom-rumble-sfx.uf2` - Main program
- `doom1.whx` - Game data (if building from WAD)

## Key Build Configuration

### CMakeLists.txt Settings
```cmake
set(CMAKE_BUILD_TYPE MinSizeRel)
set(PICO_HEAP_SIZE 0)
set(USE_ZONE_FOR_MALLOC 1)
pico_set_binary_info(doom_tiny_thumby 270000000)  # 270MHz
```

### Audio Configuration (i_picosound.c)
```c
#define MIX_MAX_VOLUME 32  // Prevent clipping
// Music generation disabled for CPU performance
```

### Rumble Implementation (p_pspr.c)
```c
void rumble_pulse(int duration_ms) {
    gpio_put(RUMBLE_PIN, 1);
    sleep_ms(duration_ms);
    gpio_put(RUMBLE_PIN, 0);
}
```

## Source Code Structure

```
src/
├── pico/
│   └── i_picosound.c    # Audio implementation (SFX only)
├── doom/
│   └── p_pspr.c         # Weapon rumble integration
└── whd_gen/             # WAD to WHX converter
```

## Converting Custom WADs to WHX

**Note:** whd_gen requires Pico SDK build environment and cannot be built standalone.

To use custom WADs:
1. Build whd_gen as part of the full project
2. Run: `./whd_gen DOOM1.WAD doom1.whx`
3. Flash the new .whx file to 0x10100000

## Troubleshooting

### Build Fails
- Ensure Pico SDK is up to date (needs RP2350 support)
- Check PICO_SDK_PATH environment variable
- Verify ARM GCC toolchain is in PATH

### Audio Issues
- MIX_MAX_VOLUME controls volume and clipping
- Sample rate: 49716Hz (cannot be changed without audio glitches)
- Buffer size: 2×1024 samples

### Rumble Not Working
- Check GPIO 5 connection
- Verify rumble motor power supply
- Test with `gpio_put(5, 1)` / `gpio_put(5, 0)`

## Performance Notes

- 270MHz is stable overclock for RP2350
- Frame rate: ~20-30 FPS (varies by level complexity)
- Rumble causes 30-150ms frame drops (blocking implementation)
- Music disabled due to OPL2 CPU overhead

## Modified Files

Key modifications from original rp2040-doom:

1. **src/pico/i_picosound.c**
   - Disabled music generation (memset instead of music_generator)
   - Tuned MIX_MAX_VOLUME to 32

2. **src/doom/p_pspr.c**
   - Added rumble_pulse() to all weapon fire functions
   - Weapon-specific durations (30-150ms)

3. **CMakeLists.txt**
   - Set overclock to 270MHz
   - MinSizeRel build type
   - PICO_HEAP_SIZE=0
