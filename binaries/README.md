# Binaries

Pre-compiled binaries for Thumby Color DOOM.

## Files

- **thumbycolor-doom-rumble-sfx.uf2** (491 KB) - Main program executable
- **doom1.whx** (1.7 MB) - DOOM Shareware Episode 1 game data (compressed)

## Flashing Order

**Always flash in this order:**

1. Flash `doom1.whx` to address `0x10100000`
2. Flash `thumbycolor-doom-rumble-sfx.uf2`

## File Sizes

- UF2: 491 KB (program code)
- WHX: 1.7 MB (compressed game data, textures, sounds, levels)
- Total: ~2.2 MB

## Versions

- Built: 2026-02-15
- Pico SDK: 2.0.0+
- Overclock: 270MHz
- Features: Rumble + SFX (no music)
