cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(test_usb_cdc C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(test_usb_cdc
    main.c
)

target_link_libraries(test_usb_cdc
    pico_stdlib
    hardware_gpio
)

# Enable USB serial - this is the KEY part
pico_enable_stdio_usb(test_usb_cdc 1)
pico_enable_stdio_uart(test_usb_cdc 0)

pico_add_extra_outputs(test_usb_cdc)
