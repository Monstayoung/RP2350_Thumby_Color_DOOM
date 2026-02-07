#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/gpio.h"

#define TFT_SPI spi0

#define PIN_SCK  18
#define PIN_MOSI 19
#define PIN_CS   17
#define PIN_DC   16
#define PIN_RST  4
#define PIN_BL   7

#define SCREEN_W 128
#define SCREEN_H 128

static inline void cs_low()  { gpio_put(PIN_CS, 0); }
static inline void cs_high() { gpio_put(PIN_CS, 1); }
static inline void dc_cmd()  { gpio_put(PIN_DC, 0); }
static inline void dc_data() { gpio_put(PIN_DC, 1); }

void write_cmd(uint8_t cmd, const uint8_t *data, int len) {
    spi_set_format(TFT_SPI, 8, SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST);

    cs_low();
    dc_cmd();
    spi_write_blocking(TFT_SPI, &cmd, 1);

    if (len > 0 && data) {
        dc_data();
        spi_write_blocking(TFT_SPI, data, len);
    }
    cs_high();

    spi_set_format(TFT_SPI, 16, SPI_CPOL_1, SPI_CPHA_1, SPI_MSB_FIRST);
}

void display_init() {
    sleep_ms(5);
    gpio_put(PIN_RST, 0);
    sleep_ms(50);
    gpio_put(PIN_RST, 1);
    sleep_ms(120);

    write_cmd(0xFE, 0, 0);
    write_cmd(0xEF, 0, 0);

    write_cmd(0x3A, (uint8_t[]){0x05}, 1);

    write_cmd(0x11, 0, 0);
    sleep_ms(120);
    write_cmd(0x29, 0, 0);
}

void fill(uint16_t color) {
    write_cmd(0x2A, (uint8_t[]){0,0,0,127}, 4);
    write_cmd(0x2B, (uint8_t[]){0,0,0,127}, 4);
    write_cmd(0x2C, 0, 0);

    cs_low();
    dc_data();

    for (int i = 0; i < SCREEN_W * SCREEN_H; i++) {
        spi_write_blocking(TFT_SPI, (uint8_t*)&color, 2);
    }

    cs_high();
}

int main() {
    stdio_init_all();

    spi_init(TFT_SPI, 80000000);
    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    gpio_init(PIN_CS);
    gpio_init(PIN_DC);
    gpio_init(PIN_RST);
    gpio_init(PIN_BL);

    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_set_dir(PIN_DC, GPIO_OUT);
    gpio_set_dir(PIN_RST, GPIO_OUT);
    gpio_set_dir(PIN_BL, GPIO_OUT);

    cs_high();
    gpio_put(PIN_BL, 1);

    display_init();

    while (1) {
        fill(0xF800);
        sleep_ms(500);
        fill(0x07E0);
        sleep_ms(500);
        fill(0x001F);
        sleep_ms(500);
    }
}
