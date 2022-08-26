//========================================================================
// spi_messages.h
//========================================================================
// Implementations for SPI Message functions
// Author: Aidan McNay

#include "spi_messages.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

//------------------------------------------------------------------------
// spi_messages_construct
//------------------------------------------------------------------------
// Construct the spi_messages_t data type

void spi_messages_construct( spi_messages_t* this, int num_expected, int expected_size )
{
    this->expected_num_messages = num_expected;
    this->expected_message_size = expected_size;

    this->messages = malloc( sizeof( vector_vector_int_t ) );
    vector_vector_int_construct( this->messages );
}

//------------------------------------------------------------------------
// spi_messages_destruct
//------------------------------------------------------------------------
// Destructs the spi_messages_t data type

void spi_messages_destruct( spi_messages_t* this )
{
    this->expected_num_messages = 0;

    vector_vector_int_destruct( this->messages );
    free( this->messages );
}

//------------------------------------------------------------------------
// get_num_messages
//------------------------------------------------------------------------
// Gets the number of messages stored

int get_num_messages( spi_messages_t* this )
{
    return vector_vector_int_size( this->messages );
}

//------------------------------------------------------------------------
// get_message_size
//------------------------------------------------------------------------
// Gets the size of messages stored

int get_message_size( spi_messages_t* this )
{
    return vector_vector_int_size_of_vectors( this->messages );
}

//------------------------------------------------------------------------
// set_expected_messages
//------------------------------------------------------------------------
// Sets the number of messages we expect

void set_expected_messages( spi_messages_t* this, int num_expected )
{
    this->expected_num_messages = num_expected;
}

//------------------------------------------------------------------------
// get_expected_messages
//------------------------------------------------------------------------
// Returns the number of expected messages

int get_expected_messages( spi_messages_t* this )
{
    return this->expected_num_messages;
}

//------------------------------------------------------------------------
// set_expected_size
//------------------------------------------------------------------------
// Sets the expected size of messages

void set_expected_size( spi_messages_t* this, int expected_size )
{
    this->expected_message_size = expected_size;
}

//------------------------------------------------------------------------
// get_expected_size
//------------------------------------------------------------------------
// Returns the expected size of messages

int get_expected_size( spi_messages_t* this )
{
    return this->expected_message_size;
}

//------------------------------------------------------------------------
// push_back_message_vector
//------------------------------------------------------------------------
// Pushes a new message to the end of the vector of messages

void push_back_message_vector( spi_messages_t* this, vector_int_t* message )
{
    vector_vector_int_push_back( this->messages, message );
}

//------------------------------------------------------------------------
// push_back_message_ints
//------------------------------------------------------------------------
// Pushes a new message with the data from the array of ints to the end of
// the vector of messages

void push_back_message_ints( spi_messages_t* this, int* message, int size_of_message )
{
    vector_int_t* new_message = malloc( sizeof( vector_int_t ) );
    vector_int_construct( new_message );
    
    for ( int i = 0; i < size_of_message; i++ )
    {
        vector_int_push_back( new_message, message[i] );
    }

    push_back_message_vector( this, new_message );
}

//------------------------------------------------------------------------
// push_back_message_hex
//------------------------------------------------------------------------
// Pushes a new message with the data from the hex string to the end of
// the vector of messages

void push_back_message_hex( spi_messages_t* this, char* message, int size_of_message )
{
    vector_int_t* new_message = malloc( sizeof( vector_int_t ) );
    vector_int_construct( new_message );
    char character;
    int character_binary[4];


    for( int i = 0; i < size_of_message; i++ )
    {
        character = tolower( message[i] );

        //Convert from hexadecimal to binary
        switch( character )
        {
            case '0' :
              character_binary[0] = 0;
              character_binary[1] = 0;
              character_binary[2] = 0;
              character_binary[3] = 0;
              break;
            case '1' :
              character_binary[0] = 1;
              character_binary[1] = 0;
              character_binary[2] = 0;
              character_binary[3] = 0;
              break;
            case '2' :
              character_binary[0] = 0;
              character_binary[1] = 1;
              character_binary[2] = 0;
              character_binary[3] = 0;
              break;
            case '3' :
              character_binary[0] = 1;
              character_binary[1] = 1;
              character_binary[2] = 0;
              character_binary[3] = 0;
              break;
            case '4' :
              character_binary[0] = 0;
              character_binary[1] = 0;
              character_binary[2] = 1;
              character_binary[3] = 0;
              break;
            case '5' :
              character_binary[0] = 1;
              character_binary[1] = 0;
              character_binary[2] = 1;
              character_binary[3] = 0;
              break;
            case '6' :
              character_binary[0] = 0;
              character_binary[1] = 1;
              character_binary[2] = 1;
              character_binary[3] = 0;
              break;
            case '7' :
              character_binary[0] = 1;
              character_binary[1] = 1;
              character_binary[2] = 1;
              character_binary[3] = 0;
              break;
            case '8' :
              character_binary[0] = 0;
              character_binary[1] = 0;
              character_binary[2] = 0;
              character_binary[3] = 1;
              break;
            case '9' :
              character_binary[0] = 1;
              character_binary[1] = 0;
              character_binary[2] = 0;
              character_binary[3] = 1;
              break;
            case 'a' :
              character_binary[0] = 0;
              character_binary[1] = 1;
              character_binary[2] = 0;
              character_binary[3] = 1;
              break;
            case 'b' :
              character_binary[0] = 1;
              character_binary[1] = 1;
              character_binary[2] = 0;
              character_binary[3] = 1;
              break;
            case 'c' :
              character_binary[0] = 0;
              character_binary[1] = 0;
              character_binary[2] = 1;
              character_binary[3] = 1;
              break;
            case 'd' :
              character_binary[0] = 1;
              character_binary[1] = 0;
              character_binary[2] = 1;
              character_binary[3] = 1;
              break;
            case 'e' :
              character_binary[0] = 0;
              character_binary[1] = 1;
              character_binary[2] = 1;
              character_binary[3] = 1;
              break;
            case 'f' :
              character_binary[0] = 1;
              character_binary[1] = 1;
              character_binary[2] = 1;
              character_binary[3] = 1;
              break;
            default :
              printf( "Error: %c is not a hexadecimal character!\n", character );
              assert( 0 ); // Character isn't hexadecimal
        }

        for (int j = 0; j < 4; j++ )
        {
            // Push back most significant first
            vector_int_push_back( new_message, character_binary[ 3 - j ] );
        }
    }

    push_back_message_vector( this, new_message );
}

//------------------------------------------------------------------------
// get_message_at
//------------------------------------------------------------------------
// Returns the message vector at the given index in the vector of vectors

vector_int_t* get_message_at( spi_messages_t* this, int idx)
{
    return vector_vector_int_at( this->messages, idx );
}

//------------------------------------------------------------------------
// change_message_size
//------------------------------------------------------------------------
// Changes the size of the messages contained in the spi_messages_t

void change_message_size( spi_messages_t* this, int desired_size )
{
    vector_vector_int_resize( this->messages, desired_size );
}

//------------------------------------------------------------------------
// spi_messages_print
//------------------------------------------------------------------------
// Prints the SPI messages data structure

void spi_messages_print( spi_messages_t* this )
{
    printf( "\033[0;35m" ); // Sets color to purple
    printf( "Expected Number of Messages: %d\n", this->expected_num_messages );
    printf( "Expected Message Size: %d\n", this->expected_message_size );
    printf( "\033[0m" );
    vector_vector_int_print( this->messages );
}

//------------------------------------------------------------------------
// spi_messages_print_hex
//------------------------------------------------------------------------
// Prints the SPI messages data structure in hexadecimal format

void spi_messages_print_hex( spi_messages_t* this )
{
    if( !vector_vector_is_binary( this->messages ))
    {
        printf( "Error: All vectors must be binary to print in hex!\n" );
        return;
    }
    
    printf( "\033[0;35m" ); // Sets color to purple
    printf( "Expected Number of Messages: %d\n", this->expected_num_messages );
    printf( "Expected Message Size: %d\n", this->expected_message_size );
    printf( "\033[0m" );
    vector_vector_int_print_hex( this->messages );
}