
cmake_minimum_required(VERSION 3.13)

include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(thumbycolor_screen_test C CXX ASM)

set(PICO_NO_PICOTOOL 1)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(thumbycolor_screen_test
    main.c
)

target_link_libraries(thumbycolor_screen_test
    pico_stdlib
    hardware_spi
    hardware_gpio
    hardware_pio
)

pico_add_extra_outputs(thumbycolor_screen_test)

