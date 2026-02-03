// Simple display test - fill screen with colors
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "lcd.h"

#define LED_PIN 25  // Use onboard LED for status

int main() {
    stdio_init_all();
    
    // Configure LED pin
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    
    // Blink to show we started
    for (int i = 0; i < 3; i++) {
        gpio_put(LED_PIN, 1);
        sleep_ms(100);
        gpio_put(LED_PIN, 0);
        sleep_ms(100);
    }
    
    printf("Display test starting\n");
    
    // Initialize GPIOs and display
    gpiosConfig(true);
    gpio_put(LED_PIN, 1);  // LED on during dispInit
    sleep_ms(200);
    
    dispInit(60);
    gpio_put(LED_PIN, 0);  // LED off after dispInit
    sleep_ms(200);
    
    dispOn();
    gpio_put(LED_PIN, 1);  // LED on after dispOn
    
    printf("Display initialized\n");
    
    // Create test pattern buffer
    uint16_t line[128];
    
    // Fill screen with colors in bands
    while (1) {
        // Red band (0-31)
        for (int i = 0; i < 128; i++) line[i] = 0xF800;  // Red (RGB565)
        for (int y = 0; y < 32; y++) {
            dispRenderLine(y, line, 128);
        }
        
        // Green band (32-63)
        for (int i = 0; i < 128; i++) line[i] = 0x07E0;  // Green
        for (int y = 32; y < 64; y++) {
            dispRenderLine(y, line, 128);
        }
        
        // Blue band (64-95)
        for (int i = 0; i < 128; i++) line[i] = 0x001F;  // Blue
        for (int y = 64; y < 96; y++) {
            dispRenderLine(y, line, 128);
        }
        
        // White band (96-127)
        for (int i = 0; i < 128; i++) line[i] = 0xFFFF;  // White
        for (int y = 96; y < 128; y++) {
            dispRenderLine(y, line, 128);
        }
        
        // Blink LED to show loop is running
        gpio_put(LED_PIN, 0);
        sleep_ms(500);
        gpio_put(LED_PIN, 1);
        sleep_ms(500);
        
        printf("Frame rendered\n");
    }
    
    return 0;
}
