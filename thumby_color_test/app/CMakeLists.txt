cmake_minimum_required(VERSION 3.13)

# Import the Pico SDK (uses your PICO_SDK_PATH env var)
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(thumby_color_test C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

# ---- ST7789 helper "library" target (INTERFACE) ----
add_library(pico_st7789 INTERFACE)
target_include_directories(pico_st7789 INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/../st7789-library-for-pico/src/include
)
target_link_libraries(pico_st7789 INTERFACE
    pico_stdlib
    hardware_spi
)

# ---- Your app ----
add_executable(thumby_color_test
    main.c
)

target_link_libraries(thumby_color_test
    pico_stdlib
    hardware_spi
    pico_st7789
)

# Enable USB serial printf()
pico_enable_stdio_usb(thumby_color_test 1)
pico_enable_stdio_uart(thumby_color_test 0)

pico_add_extra_outputs(thumby_color_test)
