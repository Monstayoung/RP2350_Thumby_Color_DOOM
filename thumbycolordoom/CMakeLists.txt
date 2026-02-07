cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(test_blink C CXX ASM)
set(CMAKE_C_STANDARD 11)

pico_sdk_init()

add_executable(test_blink test_blink.c)

target_link_libraries(test_blink
    pico_stdlib
    hardware_gpio
)

pico_enable_stdio_uart(test_blink 0)
pico_enable_stdio_usb(test_blink 0)

pico_add_extra_outputs(test_blink)
