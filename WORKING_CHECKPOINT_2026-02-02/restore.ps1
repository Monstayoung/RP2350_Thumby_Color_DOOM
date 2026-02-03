# Quick Restore Script - PowerShell
# Run this to restore the working checkpoint

$CHECKPOINT_DIR = "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\WORKING_CHECKPOINT_2026-02-02"
$DEST_DIR = "C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom"

Write-Host "🔄 Restoring WORKING CHECKPOINT from 2026-02-02..." -ForegroundColor Cyan

Copy-Item "$CHECKPOINT_DIR\lcd.c" "$DEST_DIR\src\pico\lcd.c" -Force
Copy-Item "$CHECKPOINT_DIR\i_video.c" "$DEST_DIR\src\pico\i_video.c" -Force
Copy-Item "$CHECKPOINT_DIR\dispDefcon.h" "$DEST_DIR\src\pico\dispDefcon.h" -Force
Copy-Item "$CHECKPOINT_DIR\pinoutRp2350defcon.h" "$DEST_DIR\src\pico\pinoutRp2350defcon.h" -Force
Copy-Item "$CHECKPOINT_DIR\d_main.c" "$DEST_DIR\src\doom\d_main.c" -Force

Write-Host "✅ Files restored!" -ForegroundColor Green
Write-Host ""
Write-Host "Now rebuild:" -ForegroundColor Yellow
Write-Host "  cd $DEST_DIR"
Write-Host "  ninja -C build doom_tiny"
Write-Host ""
Write-Host "Then flash:" -ForegroundColor Yellow
Write-Host "  C:\msys64\home\Q\bin\picotool.exe load build\src\doom_tiny.elf"
Write-Host "  C:\msys64\home\Q\bin\picotool.exe reboot"
