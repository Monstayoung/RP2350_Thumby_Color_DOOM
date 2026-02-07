#include "pico/stdlib.h"
#include "hardware/gpio.h"
#if PICO_RP2350
#include "hardware/structs/accessctrl.h"
#endif

#define PIN_LCD_BL 7

int main() {
    // Initialize GPIO for backlight
    gpio_init(PIN_LCD_BL);
    gpio_set_dir(PIN_LCD_BL, GPIO_OUT);
    gpio_put(PIN_LCD_BL, 1);
    
#if PICO_RP2350
    // RP2350 ARM Secure: Configure USB peripheral as accessible
    hw_clear_bits(&accessctrl_hw->usbctrl, ACCESSCTRL_USBCTRL_BITS);
#endif
    
    // Initialize USB CDC serial
    stdio_init_all();
    
    // Give USB time to enumerate
    sleep_ms(3000);
    
    printf("\n\n==========  USB CDC TEST ==========\n");
    printf("RP2350 ARM Secure mode\n");
    printf("Thumby Color USB Serial Test\n");
    printf("===================================\n\n");
    
    // Main loop - print message every second
    int count = 0;
    while (1) {
        // Blink backlight
        gpio_put(PIN_LCD_BL, count % 2);
        
        printf("[%d] USB CDC is working! Time: %llu ms\n", count, to_ms_since_boot(get_absolute_time()));
        
        count++;
        sleep_ms(1000);
    }
    
    return 0;
}
