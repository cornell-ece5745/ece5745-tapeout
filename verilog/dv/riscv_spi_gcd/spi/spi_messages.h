//========================================================================
// spi_messages.h
//========================================================================
// Header file for SPI Message functions
// Author: Aidan McNay

#ifndef SPI_SPI_MESSAGES
#define SPI_SPI_MESSAGES

#include "vector-vector-int.h"
#include "vector-int.h"

typedef struct {
    vector_vector_int_t* messages;
    int                  expected_num_messages;
    int                  expected_message_size;
} spi_messages_t;

void spi_messages_construct  ( spi_messages_t* this, int num_expected, int expected_size );
void spi_messages_destruct   ( spi_messages_t* this );
int  get_num_messages        ( spi_messages_t* this );
int  get_message_size        ( spi_messages_t* this );
void set_expected_messages   ( spi_messages_t* this, int num_expected );
int  get_expected_messages   ( spi_messages_t* this );
void set_expected_size       ( spi_messages_t* this, int expected_size );
int  get_expected_size       ( spi_messages_t* this );
void push_back_message_vector( spi_messages_t* this, vector_int_t* message);
void push_back_message_ints  ( spi_messages_t* this, int* message, int size_of_message );
void push_back_message_hex   ( spi_messages_t* this, char* message, int size_of_message );
vector_int_t* get_message_at ( spi_messages_t* this, int idx);
void change_message_size     ( spi_messages_t* this, int desired_size );
void spi_messages_print      ( spi_messages_t* this );
void spi_messages_print_hex  ( spi_messages_t* this );

#endif // SPI_SPI_MESSAGES