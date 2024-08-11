#pragma once

void gpiosConfig(bool);

void dispInit(int fps);
void dispOn(void);
void dispWaitLine(void);
void dispRenderLine(uint y, uint16_t *buf, uint32_t w);


