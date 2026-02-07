#include "pico/stdlib.h"
#include "hardware/gpio.h"

// Absolute minimal test - just blink forever
int main() {
    gpio_init(7);  // Backlight pin
    gpio_set_dir(7, GPIO_OUT);
    
    // Blink forever - if this doesn't work, toolchain/hardware incompatible
    while(1) {
        gpio_put(7, 1);
        sleep_ms(500);
        gpio_put(7, 0);
        sleep_ms(500);
    }
    
    return 0;
}
