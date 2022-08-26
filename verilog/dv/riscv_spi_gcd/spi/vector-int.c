//========================================================================
// vector-int.c
//========================================================================
// Baseline implementation of the vector functions


#include "vector-int.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
//------------------------------------------------------------------------
// vector_int_construct
//------------------------------------------------------------------------
// Construct the vector_int_t and initialize the fields inside

void vector_int_construct( vector_int_t* this )
{
  assert( this != NULL );
  // The initial size of a vector is 0, as it contains no elements
  this->size = 0;

  // To start off with, I will arbitrarily allocate memory for 8 ints
  // in our data array.

  this->data    = malloc( ( size_t )( 8 ) * sizeof( int ) );
  this->maxsize = 8;  // Currently space for 8 ints
}

//------------------------------------------------------------------------
// vector_int_destruct
//------------------------------------------------------------------------
// Destruct the vector_int_t, freeing any dynamically allocated memory if
// necessary

void vector_int_destruct( vector_int_t* this )
{
  assert( this != NULL );
  // First, we must free all of the data in the array.
  free( this->data );

  // As of now, our size and maxsize have no real meaning, but I
  // will set them to 0 to indicate no data
  this->size    = 0;
  this->maxsize = 0;
}

//------------------------------------------------------------------------
// vector_int_size
//------------------------------------------------------------------------
// Get the number of elements in the vector.

int vector_int_size( vector_int_t* this )
{
  assert( this != NULL );
  // This data is already stored in this->size

  return this->size;
}

//------------------------------------------------------------------------
// vector_int_push_back
//------------------------------------------------------------------------
// Push a new value into the vector_int_t. For this implementation, I will
// use v2 from PA2, as it prooved to have better amortized time complexity

void vector_int_push_back( vector_int_t* this, int value )
{
  assert( this != NULL );

  // First, we will check if we need to allocate new memory.

  int* temp;

  if ( this->size == this->maxsize ) {
    // Create the new array and use it instead

    temp = malloc( ( size_t )( this->maxsize * 2 ) * sizeof( int ) );

    for ( int i = 0; i < this->maxsize; i++ ) {
      temp[i] = this->data[i];
    }

    free( this->data );

    this->data    = temp;
    this->maxsize = this->maxsize * 2;
  }

  // Now, we can add the new value to the data array

  this->data[this->size] = value;
  this->size             = this->size + 1;
}

//------------------------------------------------------------------------
// vector_int_at
//------------------------------------------------------------------------
// Access the internal array and return the value at the given index
// If the index is out of bound, then return 0

int vector_int_at( vector_int_t* this, int idx )
{
  assert( this != NULL );

  // If the index isn't within our size, we should return 0

  if ( ( idx < 0 ) || ( idx >= this->size ) ) {
    return 0;
  }
  // We can just return the appropriate value from the data array
  return this->data[idx];
}

//------------------------------------------------------------------------
// vector_int_contains
//------------------------------------------------------------------------
// Search the vector for a value and return whether a value is found or
// not. Returning 1 means found, and 0 means not found.

int vector_int_contains( vector_int_t* this, int value )
{
  assert( this != NULL );
  // We iterate through the data array, and if any element contains the
  // value, we return 1

  for ( int i = 0; i < this->size; i++ ) {
    if ( this->data[i] == value ) {
      return 1;
    }
  }

  // If we get here, the value isn't in the array

  return 0;
}

//------------------------------------------------------------------------
// vector_int_print
//------------------------------------------------------------------------
// Print out the content of vector_int_t

void vector_int_print( vector_int_t* this )
{
  assert( this != NULL );
  // This function will just go through and print each element of the list
  // like you might see an array in Python (because it's what I'm most
  // familiar with)

  // Start with beginning bracket

  printf( "[" );

  // Iterate through the list, printing values along with appropriate syntax

  for ( int i = 0; i < ( this->size ); i++ ) {
    printf( "%d", this->data[i] );
    if ( i != ( this->size - 1 ) ) {
      // This indicates that it isn't the last element, so we should
      // include a ", " after
      printf( ", " );
    }
  }

  // Print closing bracket

  printf( "]\n" );
}

//------------------------------------------------------------------------
// vector_int_extend
//------------------------------------------------------------------------
// Pads the vector_int_t to the desired size with zeros

void vector_int_extend ( vector_int_t* this, int value )
{    
    assert( value >= this->size ); // Can only extend
    if ( value == this->size ){ return; } // No changes necessary
    
    int old_size = this->size;
    int offset = value - this->size;

    // Take all data out to an array

    int temp[this->size];

    for ( int i = 0; i < this->size; i++ )
    {
        temp[i] = this->data[i];
    }

    // Reconstruct the vector with the new added zeros

    vector_int_destruct ( this );
    vector_int_construct( this );

    for ( int i = 0; i < offset; i++ )
    {
        vector_int_push_back( this, 0 );
    }

    for ( int i = 0; i < old_size; i++ )
    {
        vector_int_push_back( this, temp[i] );
    }
}

//------------------------------------------------------------------------
// vector_is_binary
//------------------------------------------------------------------------
// Checks whether a vector contains only 1's and 0's

int vector_is_binary( vector_int_t* this )
{
    for( int i = 0; i < this->size; i++ )
    {
        int value = vector_int_at( this, i );
        if( (value != 1) & (value != 0) )
        {
            return 0;
        }
    }

    return 1;
}

//------------------------------------------------------------------------
// vector_int_print_hex
//------------------------------------------------------------------------
// Prints the vector in hex format

void vector_int_print_hex( vector_int_t* this )
{
    assert( vector_is_binary( this ) );

    vector_int_t* current_vector = this;
    if( this->size % 4 != 0 )
    {
        //Pad with zeros before printing
        vector_int_t* temp = malloc( sizeof( vector_int_t ) );
        vector_int_construct( temp );

        for( int i = 0; i < ( 4 - ( this->size % 4) ); i++ )
        {
            vector_int_push_back( temp, 0 );
        }

        for( int i = 0; i < this->size; i++ )
        {
            vector_int_push_back( temp, vector_int_at( this, i ));
        }

        current_vector = temp;
    }

    printf( "0x" );

    for( int i = 0; i < (current_vector->size / 4); i++ )
    {
        int bit3 = vector_int_at( current_vector, (i*4)   );
        int bit2 = vector_int_at( current_vector, (i*4)+1 );
        int bit1 = vector_int_at( current_vector, (i*4)+2 );
        int bit0 = vector_int_at( current_vector, (i*4)+3 );

        int value = 0;
        value += (bit3 * 8);
        value += (bit2 * 4);
        value += (bit1 * 2);
        value += (bit0    );

        printf("%x", value);
    }

    printf("\n");

    // If we used a temporary vector, we need to free it
    if( this->size % 4 != 0 )
    {
        vector_int_destruct( current_vector );
        free( current_vector );
    }
}