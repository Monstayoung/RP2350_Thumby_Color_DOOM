#ifndef _PINOUT_H_
#define _PINOUT_H_



#define PIN_RAM_NCS		0
#define PIN_TOUCHINT	1
#define PIN_SDA			2
#define PIN_SCL			3
#define PIN_LCD_RST		4  // CORRECT: LCD Reset pin

// CORRECT Thumby Color LCD pins (verified working)
#define PIN_LCD_DnC		16  // Data/Command
#define PIN_LCD_CS		17  // Chip Select
#define PIN_LCD_SCK		18  // SPI Clock
#define PIN_LCD_DO		19  // SPI MOSI
#define PIN_LCD_BL		7   // Backlight

#define PIN_SELF_PWR	11

#define PIN_SD_MISO		12
#define PIN_SD_NCS		13
#define PIN_SD_SCK		14
#define PIN_SD_MOSI		15

// Button pins - THESE MAY BE WRONG if LCD used their pins!
// Original had buttons on 16-19 but those are now LCD pins
#define PIN_BTN_R		20  // TODO: verify correct button pins
#define PIN_BTN_D		21
#define PIN_BTN_U		22
#define PIN_BTN_L		23
#define PIN_BTN_B		24
#define PIN_BTN_A		25
#define PIN_BTN_START	26
#define PIN_BTN_SEL		27
#define PIN_BTN_CENTER	28

#define PIN_IRDA_OUT	28		//was 26
#define PIN_IRDA_IN		27
#define PIN_IRDA_SD		7

#define PIN_SPQR		25
#define PIN_WS2812		4  // Moved from line 9 to avoid conflict


//PWM use
#define BACKLITE_PWM_INDEX			5

//DMA USE
#define DISP_DMA_FIRST				0	//uses 2
#define SD_DMA_FIRST				2	//uses 2
#define WS2812_DMA					4	//uses 1
#define I2C_DMA_FIRST				5	//uses 2

//PIO use:
#define DISP_PIO_IDX				0
#define DISP_PIO_SM					0	//of 4
#define DISP_PIO_FIRST_USED_PC		0	//uses 2 instrs

#define I2C_PIO_IDX					1
#define I2C_PIO_SM					0	//of 4
#define I2C_PIO_INT_IRQ_IDX			0	//of 8
#define I2C_PIO_EXT_IRQ_IDX			0	//of 2
#define I2C_PIO_FIRST_USED_PC		0	//uses 22 instrs

#define SIR_PIO_IDX					1
#define SIR_PIO_SM					1	//of 4
#define SIR_PIO_EXT_IRQ_IDX			1	//of 2
#define SIR_PIO_FIRST_USED_PC		22	//uses 9 instrs

#define WS2812_PIO_IDX				1
#define WS2812_PIO_SM				2	//of 4
#define WS2812_PIO_FIRST_USED_PC	31	//uses 1 instr


#endif

