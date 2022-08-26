//========================================================================
// spi.h
//========================================================================
// Header file for SPI functions
// Author: Aidan McNay

#ifndef SPI_SPI
#define SPI_SPI

#include "spi_messages.h"
#include <stdint.h>

typedef struct {
    volatile uint32_t* data_addr;
    int cs_index;
    int sclk_index;
    int mosi_index;
    int miso_index;
    int lt_sel;
    int lt_index;
    int reset_index;
    int clk_en;
    int clk_index;
    int spi_bits;
    int spi_msg_bits;
} spi_controller_t;

void spi_controller_construct ( 
    spi_controller_t* this, 
    volatile uint32_t* data_addr, 
    int cs_index, 
    int sclk_index, 
    int mosi_index, 
    int miso_index, 
    int lt_sel,
    int lt_index,
    int reset_index, 
    int clk_en,
    int clk_index,
    int spi_bits 
);

void spi_controller_destruct  ( spi_controller_t* this );
void send_messages            ( spi_controller_t* this, spi_messages_t* spi_requests, spi_messages_t* spi_responses );
void design_reset             ( spi_controller_t* this );


#endif // SPI_SPI