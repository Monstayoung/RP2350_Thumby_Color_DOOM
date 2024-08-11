/*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef _PICO_AUDIO_PWM8_SAMPLE_ENCODING_H
#define _PICO_AUDIO_PWM8_SAMPLE_ENCODING_H

#ifdef __cplusplus
extern "C" {
#endif

audio_buffer_t *audio_pwm8_stereo_to_stereo_consumer_take_s16(audio_connection_t *connection, bool block);
audio_buffer_t *audio_pwm8_mono_to_stereo_consumer_take_s16(audio_connection_t *connection, bool block);
void audio_pwm8_stereo_to_stereo_blocking_give_s16(audio_connection_t *connection, audio_buffer_t *buffer);

#ifdef __cplusplus
}
#endif

#endif
