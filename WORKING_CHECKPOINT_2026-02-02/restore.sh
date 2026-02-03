#!/bin/bash
# Quick restore script - run this to restore the working checkpoint

CHECKPOINT_DIR="C:/msys64/home/Q/thumbycolordoom/defcon/rp2040-doom/WORKING_CHECKPOINT_2026-02-02"
DEST_DIR="C:/msys64/home/Q/thumbycolordoom/defcon/rp2040-doom"

echo "🔄 Restoring WORKING CHECKPOINT from 2026-02-02..."

cp "${CHECKPOINT_DIR}/lcd.c" "${DEST_DIR}/src/pico/lcd.c"
cp "${CHECKPOINT_DIR}/i_video.c" "${DEST_DIR}/src/pico/i_video.c"
cp "${CHECKPOINT_DIR}/dispDefcon.h" "${DEST_DIR}/src/pico/dispDefcon.h"
cp "${CHECKPOINT_DIR}/pinoutRp2350defcon.h" "${DEST_DIR}/src/pico/pinoutRp2350defcon.h"
cp "${CHECKPOINT_DIR}/d_main.c" "${DEST_DIR}/src/doom/d_main.c"

echo "✅ Files restored!"
echo ""
echo "Now rebuild:"
echo "  cd ${DEST_DIR}"
echo "  ninja -C build doom_tiny"
echo ""
echo "Then flash:"
echo "  C:/msys64/home/Q/bin/picotool.exe load build/src/doom_tiny.elf"
echo "  C:/msys64/home/Q/bin/picotool.exe reboot"
