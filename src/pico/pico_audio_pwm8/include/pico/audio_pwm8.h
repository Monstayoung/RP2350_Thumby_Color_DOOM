/*
 * Copyright (c) 2021 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef _PICO_AUDIO_PWM8_H
#define _PICO_AUDIO_PWM8_H

#include "pico/audio.h"

/** \file audio_pwm8.h
 *  \defgroup pico_audio_pw m_lo pico_audio_pwm8
 *  Lower fidelity (8 bit) PWM audio output
 *
 */

#ifdef __cplusplus
extern "C" {
#endif

#ifndef PICO_AUDIO_PWM8_DMA_IRQ
#ifdef PICO_AUDIO_DMA_IRQ
#define PICO_AUDIO_PWM8_DMA_IRQ PICO_AUDIO_DMA_IRQ
#else
#define PICO_AUDIO_PWM8_DMA_IRQ 0
#endif
#endif

#ifndef PICO_AUDIO_PWM8_PIO
#ifdef PICO_AUDIO_PIO
#define PICO_AUDIO_PWM8_PIO PICO_AUDIO_PIO
#else
#define PICO_AUDIO_PWM8_PIO 0
#endif
#endif

#if !(PICO_AUDIO_PWM8_DMA_IRQ == 0 || PICO_AUDIO_PWM8_DMA_IRQ == 1)
#error PICO_AUDIO_PWM8_DMA_IRQ must be 0 or 1
#endif

#if !(PICO_AUDIO_PWM8_PIO == 0 || PICO_AUDIO_PWM8_PIO == 1)
#error PICO_AUDIO_PWM8_PIO ust be 0 or 1
#endif

#ifndef PICO_AUDIO_PWM8_MAX_CHANNELS
#ifdef PICO_AUDIO_MAX_CHANNELS
#define PICO_AUDIO_PWM8_MAX_CHANNELS PICO_AUDIO_MAX_CHANNELS
#else
#define PICO_AUDIO_PWM8_MAX_CHANNELS 2u
#endif
#endif

// todo may be required for more than 2 channels, but then again not sure we support that
#ifndef PICO_AUDIO_PWM8_SUPPORT_MULTI_SLICE
#define PICO_AUDIO_PWM8_SUPPORT_MULTI_SLICE 0
#endif

// todo this name doesn't make sense as we don't separate channel buffers
#ifndef PICO_AUDIO_PWM8_BUFFERS_PER_CHANNEL
#ifdef PICO_AUDIO_BUFFERS_PER_CHANNEL
#define PICO_AUDIO_PWM8_BUFFERS_PER_CHANNEL PICO_AUDIO_BUFFERS_PER_CHANNEL
#else
#define PICO_AUDIO_PWM8_BUFFERS_PER_CHANNEL 3u
#endif
#endif

#ifndef PICO_AUDIO_PWM8_BUFFER_SAMPLE_LENGTH
#ifdef PICO_AUDIO_BUFFER_SAMPLE_LENGTH
#define PICO_AUDIO_PWM8_BUFFER_SAMPLE_LENGTH PICO_AUDIO_BUFFER_SAMPLE_LENGTH
#else
#define PICO_AUDIO_PWM8_BUFFER_SAMPLE_LENGTH 576u
#endif
#endif

#ifndef PICO_AUDIO_PWM8_SILENCE_BUFFER_SAMPLE_LENGTH
#ifdef PICO_AUDIO_PWM8_SILENCE_BUFFER_SAMPLE_LENGTH
#define PICO_AUDIO_PWM8_SILENCE_BUFFER_SAMPLE_LENGTH PICO_AUDIO_SILENCE_BUFFER_SAMPLE_LENGTH
#else
#define PICO_AUDIO_PWM8_SILENCE_BUFFER_SAMPLE_LENGTH 256u
#endif
#endif

// Allow use of pico_audio driver without actually doing anything much
#ifndef PICO_AUDIO_PWM8_NOOP
#ifdef PICO_AUDIO_NOOP
#define PICO_AUDIO_PWM8_NOOP PICO_AUDIO_NOOP
#else
#define PICO_AUDIO_PWM8_NOOP 0
#endif
#endif

#ifndef PICO_AUDIO_PWM8_MONO_INPUT
#define PICO_AUDIO_PWM8_MONO_INPUT 0
#endif
#ifndef PICO_AUDIO_PWM8_MONO_OUTPUT
#define PICO_AUDIO_PWM8_MONO_OUTPUT 0
#endif

#ifndef PICO_AUDIO_PWM8_DATA_PIN
//#warning PICO_AUDIO_PWM8_DATA_PIN should be defined when using AUDIO_PWM8
#define PICO_AUDIO_PWM8_DATA_PIN 28
#endif

// todo this needs to come from a build config
/** \brief Base configuration structure used when setting up
 * \ingroup pico_audio_pwm8
 */
typedef struct audio_pwm8_config {
    uint8_t num_channels;
    uint8_t pins[PICO_AUDIO_PWM8_MAX_CHANNELS];
} audio_pwm8_config_t;

/** \brief Set up system to output PWM audio
 * \ingroup pico_audio_pwm8
 *
 * \param intended_audio_format \todo
 * \param config The configuration to apply.
 */
const audio_format_t *audio_pwm8_setup(const audio_format_t *intended_audio_format,
                                               const audio_pwm8_config_t *config);


/** \brief \todo
 * \ingroup pico_audio_pwm8
 *
 * \param producer
 * \param connection
 */
bool audio_pwm8_connect_thru(audio_buffer_pool_t *producer, audio_connection_t *connection);


/** \brief \todo
 * \ingroup pico_audio_pwm8
 *
 * \param producer
 *
 *  todo make a common version (or a macro) .. we don't want to pull in unnecessary code by default
 */
bool audio_pwm8_connect(audio_buffer_pool_t *producer);


/** \brief \todo
 * \ingroup pico_audio_pwm8
 *
 * \param producer
 */
bool audio_pwm8_connect_s8(audio_buffer_pool_t *producer);
bool audio_pwm8_connect_extra(audio_buffer_pool_t *producer, bool buffer_on_give, uint buffer_count, uint samples_per_buffer, audio_connection_t *connection);

/** \brief \todo
 * \ingroup pico_audio_pwm8
 *
 * \param producer
 * \param buffer_on_give
 * \param buffer_count
 * \param samples_per_buffer
 * \param connection
 * \return
 */
bool audio_pwm8_connect_extra(audio_buffer_pool_t *producer, bool buffer_on_give, uint buffer_count,
                                 uint samples_per_buffer, audio_connection_t *connection);


/** \brief Set up system to output I2S audio
 * \ingroup pico_audio_pwm8
 *
 * \param enable true to enable I2S audio, false to disable.
 */
void audio_pwm8_set_enabled(bool enabled);

#ifdef __cplusplus
}
#endif

#endif //_AUDIO_PWM8_H
