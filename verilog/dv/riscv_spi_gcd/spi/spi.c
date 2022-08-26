//========================================================================
// spi.c
//========================================================================
// Implementations for SPI functions
// Author: Aidan McNay

#include "spi.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

void short_delay()
{
    for (int i = 0; i<5; i++);
}

//------------------------------------------------------------------------
// get_message_to_send
//------------------------------------------------------------------------
// Formulates the SPI message to send over the data line

uint32_t get_message_to_send ( spi_controller_t* this, int reset, int sclk, int cs, int mosi)
{
    uint32_t message = 0x0000;
    message += ( sclk           << (this->sclk_index)  );
    message += ( cs             << (this->cs_index)    );
    message += ( mosi           << (this->mosi_index)  );
    //Account for loopthrough
    message += ( (this->lt_sel) << (this->lt_index)    );
    //Account for reset
    message += ( reset          << (this->reset_index) );

    return message;
}

//------------------------------------------------------------------------
// get_miso
//------------------------------------------------------------------------
// Gets the MISO data

int get_miso ( spi_controller_t* this )
{
    int mask = 1 << this->miso_index;
    int masked_data = mask & *(this->data_addr);
    int miso = masked_data >> this->miso_index;
    return miso;
}

//------------------------------------------------------------------------
// assert_data
//------------------------------------------------------------------------
// Asserts the data to the data register. Uses delay_num as the number of
// cycles to wait if clk_en is enabled

void assert_data ( spi_controller_t* this, uint32_t data, int delay_num )
{
    if ( this->clk_en )
    {
        uint32_t request_clock_low  = data;
        uint32_t request_clock_high = data + ( 1 << (this->clk_index) );
        
        for ( int i = 0; i < delay_num; i++ )
        {
            *(this->data_addr) = request_clock_low;
            *(this->data_addr) = request_clock_high;
        }
    }
    else
    {
        *(this->data_addr) = data;
        short_delay();
    }
}

//------------------------------------------------------------------------
// start_transaction
//------------------------------------------------------------------------
// Begins an SPI transaction

void start_transaction ( spi_controller_t* this )
{
    uint32_t request = get_message_to_send( this, 0, 0, 1, 1 );
    assert_data( this, request, 3 );
    request = get_message_to_send( this, 0, 0, 0, 1);
    assert_data( this, request, 3 );

}

//------------------------------------------------------------------------
// end_transaction
//------------------------------------------------------------------------
// Ends an SPI transaction

void end_transaction ( spi_controller_t* this )
{
    uint32_t request = get_message_to_send( this, 0, 0, 1, 1 );
    assert_data( this, request, 3 );

}

//------------------------------------------------------------------------
// send_bit
//------------------------------------------------------------------------
// Sends a bit over SPI

int send_bit ( spi_controller_t* this, int mosi )
{
    uint32_t request = get_message_to_send( this, 0, 0, 0, mosi );
    assert_data( this, request, 3 );
    request = get_message_to_send( this, 0, 1, 0, mosi );
    assert_data( this, request, 3 );
    return get_miso( this );
}

//------------------------------------------------------------------------
// send_packet
//------------------------------------------------------------------------
// Sends an SPI packet

void send_packet (spi_controller_t* this, int* packet, int packet_size, int* response)
{
    start_transaction( this );
    for (int i = 0; i < packet_size; i++)
    {
        response[packet_size - i - 1] = send_bit( this, packet[packet_size - i - 1] ); // Send most significant bits first
    }
    end_transaction( this );
}

//------------------------------------------------------------------------
// is_valid
//------------------------------------------------------------------------
// Checks whether a SPI response is valid

int is_valid (int* response, int response_size)
{
    return response[response_size-1];
}

//------------------------------------------------------------------------
// is_space
//------------------------------------------------------------------------
// Checks whether the receiver has space

int is_space (int* response, int response_size)
{
    return response[response_size-2];
}

//------------------------------------------------------------------------
// construct_request
//------------------------------------------------------------------------
// Processes a vector message into an SPI request

void construct_request ( spi_controller_t* this, int valid, int space, vector_int_t* message, int* request )
{
    request[this->spi_bits - 1] = valid;
    request[this->spi_bits - 2] = space;

    for( int i = 0; i < this->spi_msg_bits; i++ )
    {
        // First element in vector is most significant
        request[spi_msg_bits - i - 1] = vector_int_at( message, i );
    }
}

//------------------------------------------------------------------------
// process_response
//------------------------------------------------------------------------
// Processes an SPI response into a message vector

vector_int_t* process_response ( int* response, int response_size )
{
    vector_int_t* new_message = malloc( sizeof( vector_int_t ) );
    vector_int_construct( new_message );

    for( int i = 0; i < response_size; i++ )
    {
        // Most significant element is first in the vector
        vector_int_push_back( new_message, response[spi_msg_bits - i - 1] ); 
    }
    return new_message;
}

//------------------------------------------------------------------------
// response_handler
//------------------------------------------------------------------------
// Deals with all SPI responses that could contain data. If the data is
// valid, it creates a vector for it, and once there are enough vectors
// to make a message, it includes it in spi_responses

void response_handler ( spi_messages_t* spi_responses, int* response, int response_size, vector_vector_int_t* partial_msg_holder )
{
    if( is_valid( response, response_size ) )
    {
        vector_int_t* response_vector = process_response( response, response_size );
        vector_vector_int_push_back( partial_msg_holder, response_vector );
    }

    int num_msg_required;
    num_msg_required =  (spi_responses->expected_message_size / response_size);
    num_msg_required += ( (spi_responses->expected_message_size % response_size) > 0 );

    if( vector_vector_int_size( partial_msg_holder ) == num_msg_required )
    {
        // We have enough responses to make a message
        vector_int_t* message_vector = malloc( sizeof( vector_int_t ) );
        vector_int_construct( message_vector );

        for( int i = 0; i < num_msg_required; i++ )
        {
            vector_int_t* current_vector = vector_vector_int_at( partial_msg_holder, i );
                
            // If the response vector contained extended data, then we may not need it all

            int msg_overflow = (spi_responses->expected_message_size % vector_int_size( current_vector ));
            if( ( msg_overflow > 0 ) && (i == 0))
            {
                int offset = response_size - msg_overflow;

                // Only get relevant data
                for( int j = 0; j < msg_overflow; j++ )
                {
                    vector_int_push_back( message_vector, vector_int_at( current_vector, offset+j ));
                }
            }
            else
            {
                // Copy over all data
                for( int j = 0; j < vector_int_size( current_vector ); j++ )
                {
                    vector_int_push_back( message_vector, vector_int_at( current_vector, j ));
                }
            }
        }

        // Our message vector is complete - can include in overall messages

        push_back_message_vector( spi_responses, message_vector );

        // Clear old responses
        vector_vector_int_destruct ( partial_msg_holder );
        vector_vector_int_construct( partial_msg_holder );
    }
}

//========================================================================
// FUNCTIONS FROM SPI.H
//========================================================================

//------------------------------------------------------------------------
// spi_controller_construct
//------------------------------------------------------------------------
// Constructs an instance of an SPI controller

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
)
{
    assert( this != NULL );

    this->data_addr    = data_addr;
    this->cs_index     = cs_index;
    this->sclk_index   = sclk_index;
    this->mosi_index   = mosi_index;
    this->miso_index   = miso_index;
    this->lt_sel       = lt_sel;
    this->lt_index     = lt_index;
    this->reset_index  = reset_index;
    this->spi_bits     = spi_bits;
    this->spi_msg_bits = spi_bits - 2;
    this->clk_en       = clk_en;
    this->clk_index    = clk_index;
}

//------------------------------------------------------------------------
// spi_controller_destructs
//------------------------------------------------------------------------
// Destructs an instance of an SPI controller
//  - currently no need to

void spi_controller_destruct( spi_controller_t* this ){}

//------------------------------------------------------------------------
// send_messages
//------------------------------------------------------------------------
// Sends messages across SPI

void send_messages ( spi_controller_t* this, spi_messages_t* spi_requests, spi_messages_t* spi_responses )
{
    assert( this          != NULL );
    assert( spi_requests  != NULL );
    assert( spi_responses != NULL );

    int message[this->spi_bits];

    if ( this->spi_msg_bits != get_message_size( spi_requests ) )
    {
        // The size of the messages don't match the size that we want to send
        change_message_size( spi_requests, this->spi_msg_bits );
    }

    // Send initial message to get status bit

    message[this->spi_bits - 1] = 0; // Not valid
    message[this->spi_bits - 2] = 0; // No space to receive yet
    for (int i = 0; i < this->spi_msg_bits; i++ )
    {
        message[i] = 0; // Data doesn't matter
    }

    int response[this->spi_bits];
    vector_vector_int_t partial_msg_holder;
    vector_vector_int_construct( &partial_msg_holder );

    send_packet( this, message, this->spi_bits, response );

    // Poll until space is available

    while ( !(is_space( response, this->spi_bits )))
    {
        send_packet( this, message, this->spi_bits, response );
    }

    // Space is available - begin sending messages

    for( int i = 0; i < get_num_messages( spi_requests ); i++ ) // For each message
    {
        construct_request( this, 1, 1, get_message_at( spi_requests, i ), message );
        send_packet( this, message, this->spi_bits, response );
        response_handler( spi_responses, response, this->spi_bits, &partial_msg_holder );

        // Poll until space is available again
        if ( !is_space( response, this->spi_bits ) )
        {
            message[this->spi_bits - 1] = 0; // Not valid
            message[this->spi_bits - 2] = 1; // Space to receive
            for (int i = 0; i < this->spi_msg_bits; i++ )
            {
                message[i] = 0; // Data doesn't matter
            }
            while ( !is_space( response, this->spi_bits ) )
            {
                send_packet( this, message, this->spi_bits, response );
                response_handler( spi_responses, response, this->spi_bits, &partial_msg_holder );
            }
        }
    }

    // continue until we get all the messages we expect
    if ( get_num_messages( spi_responses ) < get_expected_messages ( spi_responses ) )
    {
        message[this->spi_bits - 1] = 0; // Not valid
        message[this->spi_bits - 2] = 1; // Space to receive
        for (int i = 0; i < this->spi_msg_bits; i++ )
        {
            message[i] = 0;
        }
        while ( get_num_messages( spi_responses ) < get_expected_messages ( spi_responses ) )
        {
            send_packet( this, message, this->spi_bits, response );
            response_handler( spi_responses, response, this->spi_bits, &partial_msg_holder );
        }
    }

    vector_vector_int_destruct( &partial_msg_holder );
}

//------------------------------------------------------------------------
// design_reset
//------------------------------------------------------------------------
// Resets the design

void design_reset( spi_controller_t* this )
{
    assert ( this != NULL );
    
    // Reset is active high, so assert, delay, then de-assert
    uint32_t request = get_message_to_send( this, 1, 0, 1, 0 );
    assert_data( this, request, 3 );
    request = get_message_to_send( this, 0, 0, 1, 0 );
    assert_data( this, request, 3 );
}