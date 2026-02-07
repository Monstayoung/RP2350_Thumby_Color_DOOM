#ifndef THUMBY_LCD_RST_PIN
#define THUMBY_LCD_RST_PIN 4
#endif
#ifndef THUMBY_LCD_BL_PIN
#define THUMBY_LCD_BL_PIN 7
#endif

#ifndef LCD_W
#define LCD_W THUMBY_LCD_WIDTH
#endif
#ifndef LCD_H
#define LCD_H THUMBY_LCD_HEIGHT
#endif

/* Small helpers to control lines and SPI */
static inline void cs_select(void) { gpio_put(THUMBY_LCD_CS_PIN, 0); }
static inline void cs_deselect(void) { gpio_put(THUMBY_LCD_CS_PIN, 1); }
static inline void dc_cmd(void) { gpio_put(THUMBY_LCD_DC_PIN, 0); }
static inline void dc_data(void) { gpio_put(THUMBY_LCD_DC_PIN, 1); }

static void spi_write_cmd(uint8_t cmd) {
    dc_cmd();
    cs_select();
    spi_write_blocking(THUMBY_SPI_PORT, &cmd, 1);
    cs_deselect();
}

static void spi_write_data(const uint8_t *data, size_t len) {
    if (len == 0) return;
    dc_data();
    cs_select();
    spi_write_blocking(THUMBY_SPI_PORT, data, len);
    cs_deselect();
}

/* send a 16-bit RAM write window and stream RGB565 pixels
   The incoming buf is uint16_t pixels (host little-endian). We must send MSB then LSB.
*/
void thumby_lcd_push_frame_rgb565(const uint16_t *buf, int w, int h)
{
    if (!buf || w <= 0 || h <= 0) return;

    /* column address (0..w-1) - command 0x2A */
    uint8_t colcmd[] = {
        0x00, 0x00,               /* start high, start low */
        (uint8_t)((w - 1) >> 8),  /* end high */
        (uint8_t)((w - 1) & 0xff) /* end low */
    };
    spi_write_cmd(0x2A);
    spi_write_data(colcmd, sizeof(colcmd));

    /* page address (0..h-1) - command 0x2B */
    uint8_t pagecmd[] = {
        0x00, 0x00,
        (uint8_t)((h - 1) >> 8),
        (uint8_t)((h - 1) & 0xff)
    };
    spi_write_cmd(0x2B);
    spi_write_data(pagecmd, sizeof(pagecmd));

    /* RAM write */
    spi_write_cmd(0x2C);

    /* Stream pixel data in chunks, swapping bytes so MSB goes first */
    const int CHUNK_PIXELS = 512; /* 512 pixels => 1024 bytes chunk */
    uint8_t txbuf[CHUNK_PIXELS * 2];
    int total = w * h;
    int sent = 0;
    while (sent < total) {
        int take = total - sent;
        if (take > CHUNK_PIXELS) take = CHUNK_PIXELS;
        for (int i = 0; i < take; ++i) {
            uint16_t px = buf[sent + i];
            /* buf is little-endian on RP2040, send high byte then low byte */
            txbuf[i * 2 + 0] = (uint8_t)(px >> 8);
            txbuf[i * 2 + 1] = (uint8_t)(px & 0xFF);
        }
        dc_data();
        cs_select();
        spi_write_blocking(THUMBY_SPI_PORT, txbuf, take * 2);
        cs_deselect();
        sent += take;
    }
}

/* Minimal init sequence: reset + some common commands.
   This is intentionally conservative; we'll adjust if needed.
*/
void thumby_lcd_init(void)
{
    /* configure control pins */
    gpio_init(THUMBY_LCD_CS_PIN);
    gpio_set_dir(THUMBY_LCD_CS_PIN, GPIO_OUT);
    cs_deselect();

    gpio_init(THUMBY_LCD_DC_PIN);
    gpio_set_dir(THUMBY_LCD_DC_PIN, GPIO_OUT);
    dc_cmd();

    gpio_init(THUMBY_LCD_RST_PIN);
    gpio_set_dir(THUMBY_LCD_RST_PIN, GPIO_OUT);

    gpio_init(THUMBY_LCD_BL_PIN);
    gpio_set_dir(THUMBY_LCD_BL_PIN, GPIO_OUT);

    /* SPI pins: SCK/MOSI as SPI function */
    gpio_set_function(THUMBY_LCD_SCK_PIN, GPIO_FUNC_SPI);
    gpio_set_function(THUMBY_LCD_MOSI_PIN, GPIO_FUNC_SPI);

    /* Initialize SPI0 at 8-12 MHz (adjust if needed). Mode 3 (CPOL=1,CPHA=1). */
    spi_init(THUMBY_SPI_PORT, 8000 * 1000);
    spi_set_format(THUMBY_SPI_PORT, 8, SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST);

    /* Hardware reset: pulse RST low then high */
    gpio_put(THUMBY_LCD_RST_PIN, 0);
    sleep_ms(20);
    gpio_put(THUMBY_LCD_RST_PIN, 1);
    sleep_ms(120);

    /* Exit sleep */
    spi_write_cmd(0x11);
    sleep_ms(120);

    /* Pixel format: 16-bit/pixel */
    uint8_t colmod = 0x55; /* 16-bit/pixel */
    spi_write_cmd(0x3A);
    spi_write_data(&colmod, 1);
    sleep_ms(10);

    /* Memory access control: try a reasonable default (RGB order) */
    uint8_t madctl = 0x00; /* adjust later if orientation/color swap needed */
    spi_write_cmd(0x36);
    spi_write_data(&madctl, 1);
    sleep_ms(10);

    /* Turn display on */
    spi_write_cmd(0x29);
    sleep_ms(20);

    /* Turn backlight on */
    gpio_put(THUMBY_LCD_BL_PIN, 1);
}

void thumby_lcd_deinit(void)
{
    spi_write_cmd(0x28); /* display off */
    sleep_ms(10);
    spi_write_cmd(0x10); /* enter sleep */
    sleep_ms(10);
    gpio_put(THUMBY_LCD_BL_PIN, 0);
}
EOF

nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_gc9107drv.log
arm-none-eabi-nm -n rp2350-build/src/doom_tiny_nost.elf 2>/dev/null | grep -i thumby || true
grep -n "thumby_lcd" rp2350-build/src/doom_tiny_nost.elf.map || true
sed -n '1,240p' src/CMakeLists.txt
sed -n '1,240p' src/pico/CMakeLists.txt
cp -v src/pico/CMakeLists.txt src/pico/CMakeLists.txt.bak
# This replaces the pico_scanvideo_dpi line by adding hardware_spi after it.
sed -i 's/target_link_libraries(common_pico INTERFACE pico_stdlib pico_multicore pico_scanvideo_dpi)/target_link_libraries(common_pico INTERFACE pico_stdlib pico_multicore pico_scanvideo_dpi hardware_spi)/' src/pico/CMakeLists.txt
sed -n '1,240p' src/pico/CMakeLists.txt | sed -n '1,240p'
# and specifically print the line we changed:
grep -n "target_link_libraries(common_pico" -n src/pico/CMakeLists.txt || true
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_add_hardware_spi.log
arm-none-eabi-nm -n rp2350-build/src/doom_tiny_nost.elf 2>/dev/null | grep -i thumby || true
grep -n "thumby_lcd" rp2350-build/src/doom_tiny_nost.elf.map || true
# make backup just in case
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.swap-bak
# replace the two txbuf assignment lines to send low-byte then high-byte
awk '{
  if ($0 ~ /txbuf\\[i \\* 2 \\+ 0\\] = \\(uint8_t\\)\\(px >> 8\\);/) {
    print "            txbuf[i * 2 + 0] = (uint8_t)(px & 0xFF);"
    getline
    print "            txbuf[i * 2 + 1] = (uint8_t)(px >> 8);"
  } else {
    print $0
  }
}' src/pico/thumby_lcd.c > src/pico/thumby_lcd.c.tmp && mv src/pico/thumby_lcd.c.tmp src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_swap_bytes.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.madctl-bak
# change the madctl assignment; replace the existing line setting madctl
sed -i 's/uint8_t madctl = 0x00;/uint8_t madctl = 0x08;/' src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_madctl.log
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
md5sum rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.swap-bak
awk '{
  if ($0 ~ /txbuf\\[i \\* 2 \\+ 0\\] = \\(uint8_t\\)\\(px >> 8\\);/) {
    print "            txbuf[i * 2 + 0] = (uint8_t)(px & 0xFF);"
    getline
    print "            txbuf[i * 2 + 1] = (uint8_t)(px >> 8);"
  } else {
    print $0
  }
}' src/pico/thumby_lcd.c > src/pico/thumby_lcd.c.tmp && mv src/pico/thumby_lcd.c.tmp src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_swap_bytes.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.madctl-bak
sed -i 's/uint8_t madctl = 0x00;/uint8_t madctl = 0x08;/' src/pico/thumby_lcd.c
# Rebuild:
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_madctl.log
cat > src/pico/display_force_test.c <<'EOF'
#include "thumby_lcd.h"
#include <stdint.h>
#include "pico/stdlib.h"

/* Simple test-run at startup to show known patterns so we can inspect color/order. */
#ifndef LCD_W
#define LCD_W THUMBY_LCD_WIDTH
#endif
#ifndef LCD_H
#define LCD_H THUMBY_LCD_HEIGHT
#endif

static inline uint16_t rgb565(uint8_t r, uint8_t g, uint8_t b) {
    return (uint16_t)(((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3));
}

static void fill_color(uint16_t *buf, uint16_t color) {
    for (int i = 0; i < LCD_W * LCD_H; ++i) buf[i] = color;
}

static void fill_checker(uint16_t *buf, uint16_t a, uint16_t b) {
    for (int y = 0; y < LCD_H; ++y) {
        for (int x = 0; x < LCD_W; ++x) {
            buf[y * LCD_W + x] = ((x / 8 + y / 8) & 1) ? a : b;
        }
    }
}

static void __attribute__((constructor, used)) display_force_test(void) {
    sleep_ms(300); /* wait for things to settle */

    static uint16_t buf[LCD_W * LCD_H];

    /* Show solid colours (red, green, blue, white, black) so you can inspect each. */
    uint16_t patterns[] = {
        rgb565(255, 0, 0),    /* red */
        rgb565(0, 255, 0),    /* green */
        rgb565(0, 0, 255),    /* blue */
        rgb565(255, 255, 255),/* white */
        rgb565(0, 0, 0)       /* black */
    };

    for (int p = 0; p < (int)(sizeof(patterns)/sizeof(patterns[0])); ++p) {
        fill_color(buf, patterns[p]);
        /* Send a few frames to be sure it reaches the panel */
        for (int i = 0; i < 6; ++i) {
            thumby_lcd_push_frame_rgb565(buf, LCD_W, LCD_H);
            sleep_ms(200);
        }
    }

    /* Checkerboard */
    fill_checker(buf, rgb565(255,255,255), rgb565(0,0,0));
    for (int i = 0; i < 6; ++i) {
        thumby_lcd_push_frame_rgb565(buf, LCD_W, LCD_H);
        sleep_ms(200);
    }

    /* Leave black */
    fill_color(buf, rgb565(0,0,0));
    thumby_lcd_push_frame_rgb565(buf, LCD_W, LCD_H);
    sleep_ms(200);
}
EOF

mkdir -p src/pico
nano src/pico/display_force_test.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_force_test.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.16bit.bak
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.16bit.bak
mkdir -p src/pico
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_rgb666.log
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_rgb666.log
arm-none-eabi-nm -n rp2350-build/src/doom_tiny_nost.elf 2>/dev/null | grep -i thumby || true
grep -n "thumby_lcd" rp2350-build/src/doom_tiny_nost.elf.map || true
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.rgb666-current.bak
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.spi-mode0.bak
sed -i 's/spi_set_format(THUMBY_SPI_PORT, 8, SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST);/spi_set_format(THUMBY_SPI_PORT, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);/' src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_spi_mode0.log
# If build succeeds, flash:
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
md5sum rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
# backup current file (if not already)
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.rgb666-before-lower.bak
# replace the 3 assignments
sed -i 's/txbuf\\[i\\*3 \\+ 0\\] = (uint8_t)(r6 << 2);/txbuf[i*3 + 0] = r6;/' src/pico/thumby_lcd.c
sed -i 's/txbuf\\[i\\*3 \\+ 1\\] = (uint8_t)(g6 << 2);/txbuf[i*3 + 1] = g6;/' src/pico/thumby_lcd.c
sed -i 's/txbuf\\[i\\*3 \\+ 2\\] = (uint8_t)(b6 << 2);/txbuf[i*3 + 2] = b6;/' src/pico/thumby_lcd.c
# build & flash
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_rgb666_lower.log
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
md5sum rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
# backup current before change
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.rgb666-before-bgr.bak
# replace assignments to B,G,R order
sed -i 's/txbuf\\[i\\*3 \\+ 0\\] = r6;/txbuf[i*3 + 0] = b6;/' src/pico/thumby_lcd.c
sed -i 's/txbuf\\[i\\*3 \\+ 1\\] = g6;/txbuf[i*3 + 1] = g6;/' src/pico/thumby_lcd.c
sed -i 's/txbuf\\[i\\*3 \\+ 2\\] = b6;/txbuf[i*3 + 2] = r6;/' src/pico/thumby_lcd.c
# build & flash
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_rgb666_bgr.log
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
md5sum rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.backup-for-timing
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.spi-lowclk.bak
sed -i 's/spi_init(THUMBY_SPI_PORT, 8000 \\* 1000);/spi_init(THUMBY_SPI_PORT, 1000 \\* 1000);/' src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_spi_1mhz.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.lsb-first.bak
sed -i 's/spi_set_format(THUMBY_SPI_PORT, 8, SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST);/spi_set_format(THUMBY_SPI_PORT, 8, SPI_CPOL_1, SPI_CPHA_1, SPI_LSB_FIRST);/' src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_spi_lsb.log
cp -v src/pico/thumby_lcd.c.spi-lowclk.bak src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_revert_spi_lowclk.log
cp -v src/pico/thumby_lcd.c.lsb-first.bak src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_revert_spi_lsb.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.autotest-bak
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_autotest.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.backup-before-official
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_official_driver.log
nano src/pico/thumby_lcd.c
# make a quick backup first
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.16bit-bak
# change the 16-bit spi_set_format to 8-bit
sed -i 's/spi_set_format(THUMBY_SPI_PORT, 16, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);/spi_set_format(THUMBY_SPI_PORT, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);/' src/pico/thumby_lcd.c
# (leave the spi_init(THUMBY_SPI_PORT, 40000000); line as-is so the bus stays fast)
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_spi_8bit_highclk.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.before-swapnot-bak
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_after_restore.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.autotest-bak
nano src/pico/thumby_lcd.c
# (delete existing content and paste the entire file above)
# Save with Ctrl+O Enter, exit with Ctrl+X
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_autotest.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.bak || true
cp -v src/pico/thumby_lcd.h src/pico/thumby_lcd.h.bak || true
cp -v src/pico/lcd_test_main.c src/pico/lcd_test_main.c.bak || true
nano src/pico/thumby_lcd.h
nano src/pico/thumby_lcd.c
nano src/pico/lcd_test_main.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_lcd_test.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.bak || true
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_thumby_officialstyle.log
cp -v src/pico/thumby_lcd.c src/pico/thumby_lcd.c.bak || true
nano src/pico/thumby_lcd.c
nano src/pico/lcd_test_main.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_lcd_test.log
nano src/pico/thumby_lcd.c
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_try.log
nano src/pico/thumby_lcd.c
# (optional configure, only if not done)
cmake -S . -B rp2350-build -DCMAKE_BUILD_TYPE=Release
# Build (clean-first)
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_variant.log
# If build fails, show tail:
tail -n 80 build_variant.log
# Flash (open Explorer to build output and drag UF2)
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
# then drag & drop doom_tiny_nost.uf2 onto the RPI-RP2 drive
nano src/pico/lcd_test_main.c
# (optional configure, only if not done)
cmake -S . -B rp2350-build -DCMAKE_BUILD_TYPE=Release
# Build (clean-first)
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_variant.log
# If build fails, show tail:
tail -n 80 build_variant.log
# Flash (open Explorer to build output and drag UF2)
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
# then drag & drop doom_tiny_nost.uf2 onto the RPI-RP2 drive
nano src/pico/thumby_lcd.c
# (optional configure, only if not done)
cmake -S . -B rp2350-build -DCMAKE_BUILD_TYPE=Release
# Build (clean-first)
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_variant.log
# If build fails, show tail:
tail -n 80 build_variant.log
# Flash (open Explorer to build output and drag UF2)
ls -l --full-time rp2350-build/src/doom_tiny_nost.uf2
explorer.exe "$(pwd -W)\\rp2350-build\\src"
# then drag & drop doom_tiny_nost.uf2 onto the RPI-RP2 drive
nano src/pico/thumby_lcd.c
cmake --build rp2350-build --target doom_tiny_nost --clean-first -j 2>&1 | tee build_mode3.log
# flash the UF2 as you did before (open Explorer to rp2350-build/src and drag doom_tiny_nost.uf2 to RPI-RP2)
git clone https://github.com/TinyCircuits/TinyCircuits-Tiny-Game-Engine.git
cd TinyCircuits-Tiny-Game-Engine
ls
grep -r "spi_init" .
src/display/engine_display_driver_rp2_gc9107.c
cat src/display/engine_display_driver_rp2_gc9107.c
grep -r SCREEN_BUFFER_SIZE_PIXELS .
grep -r framebuffer_draw .
grep -r spi_write .
cat src/display/engine_display_common.h
cat src/draw/engine_display_draw.c
cd C:/msys64/home/Q/rp2040-doom3
grep -r "framebuffer" .
grep -r "render" .
grep -r "draw" .
grep -r "width" .
grep -r "height" .
grep -r "framebuffer" ./src
grep -r "render" ./graphics
grep -r "draw" ./video
cat ./src/doom/r_draw.c
cat ./src/pd_render.cpp
cat ./src/pico/i_video_spi.c
cat ./src/pico/thumby_lcd.c.bak
grep -r "screens" ./src
nano ./src/pico/i_video_spi.c
make
cmake --build . --target doom_tiny_nost --clean-first -j 2>&1 | tee build_official_port.log
ls
cd rp2350-build
cmake --build . --target doom_tiny_nost --clean-first -j 2>&1 | tee build_official_port.log
nano ./src/i_sound.c
grep -r "I_StartSound" ./src
cd ~/rp2040-doom3/src
grep -r "I_StartSound" .
grep -r "doom1.whx" ./src
cd C:/msys64/home/Q/rp2040-doom3
grep -r "doom1.whx" .
grep -r "whx" .
ls ./tools ./scripts
ls ./tools
ls ./scripts
ls ./src
./whd_gen doom1.whx extracted.wad
ls -l whd_gen*
grep -r "whd_gen" .
cd src/whd_gen
cmake -S . -B rp2350-build
cd ~/rp2040-doom3
cmake -S . -B rp2350-build
cmake --build rp2350-build --target all --clean-first -j
ls rp2350-build/src/whd_gen/whd_gen
nano src/CMakeLists.txt
nano src/CMakeLists.txt
cmake -S . -B rp2350-build
cmake --build rp2350-build --target all
ls rp2350-build/src/whd_gen/
ls rp2350-build/src/whd_gen/whd_gen
ninja -C rp2350-build -t targets | grep whd_gen
nano src/whd_gen/CMakeLists.txt
nano src/whd_gen/CMakeLists.txt
cmake -S . -B rp2350-build
cmake --build rp2350-build --target whd_gen
nano src/whd_gen/whd_gen.cpp
find rp2350-build/ -type f -name "*.wad"
find rp2350-build/ -type f -name "*.whx"
grep -r "doom1.whx" src/
find rp2350-build/ -type f -size +1M
strings rp2350-build/src/doom_tiny_nost.elf | grep -iE "whx|wad|doom"
readelf -S rp2350-build/src/doom_tiny_nost.elf
objcopy --dump-section .rodata=rodata.bin rp2350-build/src/doom_tiny_nost.elf
git clone https://github.com/Microsoft/uf2.git
cd uf2/utils
python uf2conv.py C:\msys64\home\Q\rp2040-doom3\rp2350-build\src\doom_tiny_nost.uf2 -o firmware.bin -d
python uf2conv.py C:\msys64\home\Q\rp2040-doom3\rp2350-build\src\doom_tiny_nost.uf2 -o firmware.bin
python uf2conv.py C:/msys64/home/Q/rp2040-doom3/rp2350-build/src/doom_tiny_nost.uf2 -o firmware.bin
cd /home/Q/thumbycolordoom/defcon/rp2040-doom/build && ninja doom_tiny && cd src && ../../../build/_deps/picotool/picotool.exe uf2 convert doom_tiny.elf doom_tiny.uf2 --family absolute --abs-block
cd C:/msys64/home/Q/thumbycolordoom/defcon/rp2040-doom
bash cup.sh
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"
cd C:\msys64\home\Q\thumbycolordoom\defcon\rp2040-doom\build
.\_deps\picotool-build\picotool.exe load -v -t bin ..\doom1.whx -o 0x10040000
export PICO_SDK_PATH=/home/Q/pico-sdk
cd /home/Q/thumbycolordoom/defcon/rp2040-doom
rm -rf build
mkdir build
cd build
cmake -G 'MinGW Makefiles' -DCMAKE_BUILD_TYPE=MinSizeRel -DPICO_BOARD=thumby_color -DPICO_PLATFORM=rp2350-arm-s ..
make -j4
cd /home/Q/thumbycolordoom/defcon/rp2040-doom/build
export PICO_SDK_PATH=/home/Q/pico-sdk
cmake -G 'MinGW Makefiles' -DCMAKE_BUILD_TYPE=MinSizeRel -DPICO_BOARD=thumby_color -DPICO_PLATFORM=rp2350-arm-s ..
make -j4
cd /home/Q/thumbycolordoom/defcon/rp2040-doom/build
export PICO_SDK_PATH=/home/Q/pico-sdk
cmake -G 'MinGW Makefiles' -DCMAKE_BUILD_TYPE=MinSizeRel -DPICO_BOARD=thumby_color -DPICO_PLATFORM=rp2350-arm-s ..
ls -la ../CMakeLists.txt
pwd
cd ..
ls -la CMakeLists.txt
cd /home/Q/thumbycolordoom/rp2040-doom/build
export PICO_SDK_PATH=/home/Q/pico-sdk
cmake -G 'MinGW Makefiles' -DCMAKE_BUILD_TYPE=MinSizeRel -DPICO_BOARD=thumby_color -DPICO_PLATFORM=rp2350-arm-s ..
make -j4
