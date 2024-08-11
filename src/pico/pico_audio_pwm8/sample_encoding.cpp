/*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <cstdio>

#include "pico/sample_conversion.h"
#include "pico/audio_pwm8/sample_encoding.h"
#include "pico/audio_pwm8.h"
#include "hardware/gpio.h"

CU_REGISTER_DEBUG_PINS(encoding)
//CU_SELECT_DEBUG_PINS(encoding)

struct FmtPWM8 : public FmtDetails<uint16_t> {
};

template<> struct sample_converter<FmtPWM8, FmtS16> {
    static int16_t convert_sample(const uint16_t &sample) {
        return ((sample ^ 0x8000u) >> 8u);
    }
};

void audio_pwm8_stereo_to_stereo_blocking_give_s16(audio_connection_t *connection, audio_buffer_t *buffer) {
    producer_pool_blocking_give<Stereo<FmtPWM8>, Stereo<FmtS16>>(connection, buffer);
}

audio_buffer_t *audio_pwm8_mono_to_stereo_consumer_take_s16(audio_connection_t *connection, bool block) {
    return consumer_pool_take<Stereo<FmtPWM8>, Mono<FmtS16>>(connection, block);
}

audio_buffer_t *audio_pwm8_stereo_to_stereo_consumer_take_s16(audio_connection_t *connection, bool block) {
    return consumer_pool_take<Stereo<FmtPWM8>, Stereo<FmtS16>>(connection, block);
}

