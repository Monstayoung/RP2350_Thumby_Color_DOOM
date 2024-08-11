if (NOT TARGET pico_audio_pwm8)
    add_library(pico_audio_pwm8 INTERFACE)

    target_sources(pico_audio_pwm8 INTERFACE
            ${CMAKE_CURRENT_LIST_DIR}/audio_pwm8.c
            ${CMAKE_CURRENT_LIST_DIR}/sample_encoding.cpp
    )

    target_include_directories(pico_audio_pwm8 INTERFACE ${CMAKE_CURRENT_LIST_DIR}/include)
    target_link_libraries(pico_audio_pwm8 INTERFACE hardware_dma hardware_pwm hardware_irq pico_audio)
endif()