#include "pico/stdlib.h"

int main() {
    gpio_init(7);
    gpio_set_dir(7, GPIO_OUT);
    
    // Flash exactly 5 times then stay on
    for(int i=0; i<5; i++) {
        gpio_put(7, 1);
        sleep_ms(500);
        gpio_put(7, 0);
        sleep_ms(500);
    }
    
    // Stay on
    gpio_put(7, 1);
    while(1) {
        tight_loop_contents();
    }
}
