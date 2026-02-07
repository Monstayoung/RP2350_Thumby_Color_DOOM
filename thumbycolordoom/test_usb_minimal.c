#include "pico/stdlib.h"
#include "hardware/gpio.h"

int main() {
    // Initialize stdio USB
    stdio_init_all();
    
    // Wait for USB to enumerate
    sleep_ms(3000);
    
    // Blink LED on GPIO 25 (if available) and print
    const uint LED_PIN = 25;
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    
    int counter = 0;
    while (true) {
        gpio_put(LED_PIN, 1);
        printf("USB CDC Test - Count: %d\n", counter++);
        sleep_ms(500);
        
        gpio_put(LED_PIN, 0);
        sleep_ms(500);
    }
}
