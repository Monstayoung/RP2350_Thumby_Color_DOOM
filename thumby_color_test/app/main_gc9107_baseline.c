#include <string.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/gpio.h"

// --- Pins (from TinyCircuits Thumby Color engine) ---
#define PIN_SCK   18   // SPI0 SCK
#define PIN_MOSI  19   // SPI0 TX
#define PIN_CS    17   // Chip select (manual)
#define PIN_DC    16   // Data/Command
#define PIN_RST   4    // Reset (active low)
#define PIN_BL    7    // Backlight (engine uses PWM; we’ll just turn it ON)

// --- Display ---
#define TFT_W 128
#define TFT_H 128

static inline void cs_select(void)   { gpio_put(PIN_CS, 0); }
static inline void cs_deselect(void) { gpio_put(PIN_CS, 1); }

static void spi_set_8bit_mode(void)  { spi_set_format(spi0, 8,  SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST); }
static void spi_set_16bit_mode(void) { spi_set_format(spi0, 16, SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST); }

static void write_cmd(uint8_t cmd, const uint8_t *data, size_t len) {
    spi_set_8bit_mode();

    cs_select();
    gpio_put(PIN_DC, 0); // command
    spi_write_blocking(spi0, &cmd, 1);

    gpio_put(PIN_DC, 1); // data
    if (len && data) {
        spi_write_blocking(spi0, data, len);
    }
    cs_deselect();

    spi_set_16bit_mode();
}

static void set_addr_window(uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1) {
    // MADCTL
    write_cmd(0x36, (uint8_t[]){ 0x00 }, 1);

    // Column address set (CASET)
    write_cmd(0x2A, (uint8_t[]){ x0 >> 8, x0 & 0xFF, x1 >> 8, x1 & 0xFF }, 4);

    // Row address set (RASET)
    write_cmd(0x2B, (uint8_t[]){ y0 >> 8, y0 & 0xFF, y1 >> 8, y1 & 0xFF }, 4);

    // Memory write (RAMWR)
    write_cmd(0x2C, NULL, 0);
}

static void gc9107_init(void) {
    // Reset sequence (matches engine)
    cs_deselect();
    sleep_ms(5);
    gpio_put(PIN_RST, 0);
    sleep_ms(50);
    gpio_put(PIN_RST, 1);
    sleep_ms(120);

    // Init sequence (from engine_display_driver_rp2_gc9107.c)
    write_cmd(0xFE, NULL, 0);
    write_cmd(0xEF, NULL, 0);

    write_cmd(0xB0, (uint8_t[]){ 0xC0 }, 1);
    write_cmd(0xB1, (uint8_t[]){ 0x80 }, 1);
    write_cmd(0xB2, (uint8_t[]){ 0x2F }, 1);
    write_cmd(0xB3, (uint8_t[]){ 0x03 }, 1);
    write_cmd(0xB7, (uint8_t[]){ 0x01 }, 1);
    write_cmd(0xB6, (uint8_t[]){ 0x19 }, 1);

    write_cmd(0xAC, (uint8_t[]){ 0xC8 }, 1);
    write_cmd(0xAB, (uint8_t[]){ 0x0F }, 1);

    write_cmd(0x3A, (uint8_t[]){ 0x05 }, 1); // 16-bit color (RGB565)

    write_cmd(0xB4, (uint8_t[]){ 0x04 }, 1);

    write_cmd(0xA8, (uint8_t[]){ 0x07 }, 1);

    write_cmd(0xB8, (uint8_t[]){ 0x08 }, 1);

    write_cmd(0xE7, (uint8_t[]){ 0x5A }, 1);
    write_cmd(0xE8, (uint8_t[]){ 0x23 }, 1);
    write_cmd(0xE9, (uint8_t[]){ 0x47 }, 1);
    write_cmd(0xEA, (uint8_t[]){ 0x99 }, 1);

    write_cmd(0xC6, (uint8_t[]){ 0x30 }, 1);
    write_cmd(0xC7, (uint8_t[]){ 0x1F }, 1);

    write_cmd(0xF0, (uint8_t[]){ 0x05, 0x1D, 0x51, 0x2F, 0x85, 0x2A, 0x11, 0x62, 0x00, 0x07, 0x07, 0x0F, 0x08, 0x1F }, 14);
    write_cmd(0xF1, (uint8_t[]){ 0x2E, 0x41, 0x62, 0x56, 0xA5, 0x3A, 0x3F, 0x60, 0x0F, 0x07, 0x0A, 0x18, 0x18, 0x1D }, 14);

    write_cmd(0x11, NULL, 0); // Sleep out
    sleep_ms(120);
    write_cmd(0x29, NULL, 0); // Display on
    sleep_ms(10);
}

static void fill_screen(uint16_t color565) {
    set_addr_window(0, 0, TFT_W - 1, TFT_H - 1);

    // Send pixel data in 16-bit mode
    spi_set_16bit_mode();

    cs_select();
    gpio_put(PIN_DC, 1);

    // Chunked fill to avoid huge buffers
    static uint16_t line[TFT_W];
    for (int i = 0; i < TFT_W; i++) line[i] = color565;

    for (int y = 0; y < TFT_H; y++) {
        spi_write16_blocking(spi0, line, TFT_W);
    }

    cs_deselect();
}

int main() {
    // Backlight: just turn pin on as GPIO (not PWM for now)
    gpio_init(PIN_BL);
    gpio_set_dir(PIN_BL, GPIO_OUT);
    gpio_put(PIN_BL, 1); // ON

    // Init SPI
    spi_init(spi0, 62 * 1000 * 1000); // start slightly under 80MHz
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    // Control pins
    gpio_init(PIN_CS);
    gpio_init(PIN_DC);
    gpio_init(PIN_RST);
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_set_dir(PIN_DC, GPIO_OUT);
    gpio_set_dir(PIN_RST, GPIO_OUT);

    cs_deselect();
    gpio_put(PIN_DC, 1);
    gpio_put(PIN_RST, 1);

    sleep_ms(20);

    gc9107_init();

    // Fill screen: try red, then green, then blue loop
    while (true) {
        fill_screen(0xF800); // red
        sleep_ms(500);
        fill_screen(0x07E0); // green
        sleep_ms(500);
        fill_screen(0x001F); // blue
        sleep_ms(500);
        fill_screen(0xFFFF); // white
        sleep_ms(500);
        fill_screen(0x0000); // black
        sleep_ms(500);
    }
}
