// Minimal display hardware test with CORRECT Thumby Color pins
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/spi.h"

// CORRECT Thumby Color pins (from working copilot config)
#define LCD_MOSI_PIN    19    // SPI TX (MOSI)
#define LCD_SCK_PIN     18    // SPI Clock
#define LCD_CS_PIN      17    // Chip Select
#define LCD_DC_PIN      16    // Data/Command
#define LCD_RST_PIN     4     // Reset
#define BACKLIGHT_PIN   7     // Backlight control

#define LED_PIN 25

// GC9107 commands
#define GC9107_SLPOUT   0x11  // Sleep Out
#define GC9107_DISPON   0x29  // Display On
#define GC9107_CASET    0x2A  // Column Address Set
#define GC9107_RASET    0x2B  // Row Address Set  
#define GC9107_RAMWR    0x2C  // Memory Write
#define GC9107_COLMOD   0x3A  // Color Mode
#define GC9107_INVON    0x21  // Inversion ON (CRITICAL!)

void lcd_cmd(uint8_t cmd) {
    gpio_put(LCD_DC_PIN, 0);  // Command mode
    gpio_put(LCD_CS_PIN, 0);
    spi_write_blocking(spi0, &cmd, 1);
    gpio_put(LCD_CS_PIN, 1);
}

void lcd_data(uint8_t data) {
    gpio_put(LCD_DC_PIN, 1);  // Data mode
    gpio_put(LCD_CS_PIN, 0);
    spi_write_blocking(spi0, &data, 1);
    gpio_put(LCD_CS_PIN, 1);
}

int main() {
    // Configure LED
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    
    // 3 quick blinks = started
    for (int i = 0; i < 3; i++) {
        gpio_put(LED_PIN, 1);
        sleep_ms(100);
        gpio_put(LED_PIN, 0);
        sleep_ms(100);
    }
    
    // Configure LCD control pins
    gpio_init(LCD_DC_PIN);
    gpio_set_dir(LCD_DC_PIN, GPIO_OUT);
    gpio_init(LCD_CS_PIN);
    gpio_set_dir(LCD_CS_PIN, GPIO_OUT);
    gpio_put(LCD_CS_PIN, 1);  // Deselect
    gpio_init(LCD_RST_PIN);
    gpio_set_dir(LCD_RST_PIN, GPIO_OUT);
    
    // Configure backlight
    gpio_init(BACKLIGHT_PIN);
    gpio_set_dir(BACKLIGHT_PIN, GPIO_OUT);
    gpio_put(BACKLIGHT_PIN, 1);  // Turn on backlight
    
    // 1 long blink = GPIOs configured
    gpio_put(LED_PIN, 1);
    sleep_ms(500);
    gpio_put(LED_PIN, 0);
    sleep_ms(200);
    
    // Initialize SPI0 at 62.5MHz
    spi_init(spi0, 62500000);
    gpio_set_function(LCD_SCK_PIN, GPIO_FUNC_SPI);
    gpio_set_function(LCD_MOSI_PIN, GPIO_FUNC_SPI);
    
    // 2 long blinks = SPI configured
    for (int i = 0; i < 2; i++) {
        gpio_put(LED_PIN, 1);
        sleep_ms(500);
        gpio_put(LED_PIN, 0);
        sleep_ms(200);
    }
    
    sleep_ms(100);
    
    // Hardware reset GC9107
    gpio_put(LCD_RST_PIN, 0);
    sleep_ms(100);
    gpio_put(LCD_RST_PIN, 1);
    sleep_ms(100);
    
    // Initialize GC9107 with WORKING sequence from newhope.c
    lcd_cmd(0xFE);  // Inter Register Enable1
    lcd_cmd(0xEF);  // Inter Register Enable2
    
    lcd_cmd(0xB3);  // PWRCTRL2
    lcd_data(0x03);
    
    lcd_cmd(GC9107_COLMOD);  // Color mode
    lcd_data(0x55);          // 16-bit RGB565
    
    lcd_cmd(GC9107_INVON);   // Display Inversion ON - CRITICAL!
    
    lcd_cmd(GC9107_SLPOUT);  // Wake from sleep
    sleep_ms(120);
    
    lcd_cmd(GC9107_DISPON);  // Display on
    sleep_ms(20);
    
    // 3 long blinks = Display initialized
    for (int i = 0; i < 3; i++) {
        gpio_put(LED_PIN, 1);
        sleep_ms(500);
        gpio_put(LED_PIN, 0);
        sleep_ms(200);
    }
    
    // Set window to full screen (128x128)
    lcd_cmd(GC9107_CASET);
    lcd_data(0);
    lcd_data(0);
    lcd_data(0);
    lcd_data(127);
    
    lcd_cmd(GC9107_RASET);
    lcd_data(0);
    lcd_data(0);
    lcd_data(0);
    lcd_data(127);
    
    // Start writing pixels
    lcd_cmd(GC9107_RAMWR);
    
    // Fill screen with color bands
    gpio_put(LCD_DC_PIN, 1);  // Data mode
    gpio_put(LCD_CS_PIN, 0);
    
    // Red band (32 lines)
    for (int i = 0; i < 128 * 32; i++) {
        uint8_t buf[2] = {0xF8, 0x00};  // Red RGB565
        spi_write_blocking(spi0, buf, 2);
    }
    
    // Green band (32 lines)
    for (int i = 0; i < 128 * 32; i++) {
        uint8_t buf[2] = {0x07, 0xE0};  // Green RGB565
        spi_write_blocking(spi0, buf, 2);
    }
    
    // Blue band (32 lines)
    for (int i = 0; i < 128 * 32; i++) {
        uint8_t buf[2] = {0x00, 0x1F};  // Blue RGB565
        spi_write_blocking(spi0, buf, 2);
    }
    
    // White band (32 lines)
    for (int i = 0; i < 128 * 32; i++) {
        uint8_t buf[2] = {0xFF, 0xFF};  // White RGB565
        spi_write_blocking(spi0, buf, 2);
    }
    
    gpio_put(LCD_CS_PIN, 1);
    
    // Slow blink forever = success
    while (1) {
        gpio_put(LED_PIN, 1);
        sleep_ms(1000);
        gpio_put(LED_PIN, 0);
        sleep_ms(1000);
    }
    
    return 0;
}
