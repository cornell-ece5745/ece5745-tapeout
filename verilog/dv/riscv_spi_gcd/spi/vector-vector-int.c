//========================================================================
// vector-vector-int.c
//========================================================================
// Baseline implementation of the vector-vector functions

#include "vector-vector-int.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

//------------------------------------------------------------------------
// vector_vector_int_construct
//------------------------------------------------------------------------
// Construct the vector_int_t and initialize the fields inside

void vector_vector_int_construct( vector_vector_int_t* this )
{
  assert( this != NULL );
  // The initial size of a vector is 0, as it contains no elements
  this->size = 0;

  // To start off with, I will arbitrarily allocate memory for 8 vectors
  // in our data array.

  this->data    = malloc( ( size_t )( 8 ) * sizeof( vector_int_t* ) );
  this->maxsize = 8;  // Currently space for 8 vector_int_t
  this->size_of_vectors = 0;
}

//------------------------------------------------------------------------
// vector_vector_int_destruct
//------------------------------------------------------------------------
// Destruct the vector_vector-int_t, freeing any dynamically allocated 
// memory if necessary

void vector_vector_int_destruct( vector_vector_int_t* this )
{
  assert( this != NULL );

  for (int i = 0; i < this->size; i++)
  {
    vector_int_destruct(this->data[i]);
    free(this->data[i]);
  }
  free( this->data );

  // As of now, our size and maxsize have no real meaning, but I
  // will set them to 0 to indicate no data
  this->size    = 0;
  this->maxsize = 0;
  this->size_of_vectors = 0;
}

//------------------------------------------------------------------------
// vector_vector_int_size
//------------------------------------------------------------------------
// Get the number of vectors in the vector.

int vector_vector_int_size( vector_vector_int_t* this )
{
  assert( this != NULL );
  // This data is already stored in this->size

  return this->size;
}

//------------------------------------------------------------------------
// vector_vector_int_size_of_vectors
//------------------------------------------------------------------------
// Get the size of vectors in the vector.

int vector_vector_int_size_of_vectors( vector_vector_int_t* this )
{
  assert( this != NULL );
  // This data is already stored in this->size_of_vectors

  return this->size_of_vectors;
}

//------------------------------------------------------------------------
// vector_vector_int_push_back
//------------------------------------------------------------------------
// Push a new vector into the vector_vector_int_t

void vector_vector_int_push_back( vector_vector_int_t* this, vector_int_t* value )
{
  assert( this != NULL );

  // Ensure that our vectors all have the same size
  if ( this->size == 0 ) {
    this->size_of_vectors = vector_int_size( value );
  }
  else {
    assert( vector_int_size( value ) == this->size_of_vectors );
  }

  // First, we will check if we need to allocate new memory.

  vector_int_t** temp;

  if ( this->size == this->maxsize ) {
    // Create the new array and use it instead

    temp = malloc( ( size_t )( this->maxsize * 2 ) * sizeof( vector_int_t* ) );

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
// vector_vector_int_at
//------------------------------------------------------------------------
// Access the internal array and return the value at the given index
// If the index is out of bound, then return NULL

vector_int_t* vector_vector_int_at( vector_vector_int_t* this, int idx )
{
  assert( this != NULL );

  // If the index isn't within our size, we should return 0

  if ( ( idx < 0 ) || ( idx >= this->size ) ) {
    return NULL;
  }
  // We can just return the appropriate value from the data array
  return this->data[idx];
}

//------------------------------------------------------------------------
// vector_vector_int_resize
//------------------------------------------------------------------------
// Resizes the vector array to the desired size. 
//  - pads with zeros if a larger size is desired
//  - breaks each vector into multiple vectors if a smaller size is desired
//    (relative order maintainted)

void vector_vector_int_resize( vector_vector_int_t* this, int new_size )
{
    assert( this != NULL );
    assert( new_size > 0 );
    
    // Trivial case of being the same size
    if (this->size_of_vectors == new_size ){ return; }

    if (new_size > this->size_of_vectors) // Need to pad each vector
    {
        for (int i = 0; i < this->size; i++)
        {
            vector_int_t* current_vector = vector_vector_int_at( this, i );
            vector_int_extend( current_vector, new_size );
        }
        this->size_of_vectors = new_size;
        return;
    }

    // If we got here, we need to break each vector down to the appropriate size
    // To do this, we will construct a helper vector_vector_int to hold our
    // smaller vectors before we put them back in the original vector_vector

    vector_vector_int_t* temp = malloc( sizeof( vector_vector_int_t ) );
    vector_vector_int_construct( temp );
    int old_size_of_vectors = this->size_of_vectors;

    for ( int i = 0; i < this->size; i++ ) // For each vector
    {
        // vector_vector_int_t* temp_2 = malloc( sizeof( vector_vector_int_t ) );
        // vector_vector_int_construct( temp_2 );

        vector_int_t* current_vector = vector_vector_int_at( this, i );
        //Break into vectors, pushing back into temp as we go

        // Account for the fact that some vectors may not fit exatcly, where we will have to
        // pad with zeros
        if ( old_size_of_vectors % new_size != 0 )
        {
            vector_int_t* new_message = malloc( sizeof( vector_int_t ) );
            vector_int_construct( new_message );

            for( int h = 0; h < ( new_size - ( old_size_of_vectors % new_size ) ); h++ )
            {
                vector_int_push_back( new_message, 0 );
            }
            for( int h = 0; h < ( old_size_of_vectors % new_size ); h++ )
            {
                int value = vector_int_at( current_vector, h );
                vector_int_push_back( new_message, value );
            }
            vector_vector_int_push_back( temp, new_message );
        }

        // Now, we account for the rest of the values

        int j = 0;
        while ( j < (old_size_of_vectors / new_size) )
        {
            vector_int_t* new_message = malloc( sizeof( vector_int_t ) );
            vector_int_construct( new_message );
            int offset = ( old_size_of_vectors % new_size );

            for ( int k = 0; k < new_size; k++)
            {
                int value = vector_int_at( current_vector, k + (new_size * j) + offset );
                vector_int_push_back( new_message, value );
            }
            vector_vector_int_push_back( temp, new_message );
            j += 1;
        }

    }

    // Copy vectors from temp back over to this

    vector_vector_int_destruct ( this );
    vector_vector_int_construct( this );

    for( int i = 0; i < temp->size; i++ )
    {
        vector_int_t* current_vector = vector_vector_int_at( temp, i );
        vector_vector_int_push_back( this, current_vector );
    }

    // Like before, free all data from temp except for the vectors

    free( temp->data );
    free( temp );
}

//------------------------------------------------------------------------
// vector_vector_int_print
//------------------------------------------------------------------------
// Prints a visual representation of the vector_vector_int_t

void vector_vector_int_print( vector_vector_int_t* this )
{    
    printf( "\033[0;36m" ); // Sets color to cyan
    printf( "************************\n" );
    for( int i = 0; i < this->size; i++ )
    {
        printf( "* %d. ", i );
        printf( "\033[0m" );
        vector_int_t* current_vector = vector_vector_int_at( this, i );
        vector_int_print( current_vector );
        printf( "\033[0;36m" );
    }
    printf( "************************\n" );
    printf( "\033[0m" );
}

//------------------------------------------------------------------------
// vector_vector_is_binary
//------------------------------------------------------------------------
// Checks whether the vectors in the vector_vector only contain 1's
// and 0's

int vector_vector_is_binary ( vector_vector_int_t* this )
{
    for( int i = 0; i < this->size; i++ )
    {
        if( !(vector_is_binary( vector_vector_int_at( this, i ) )))
        {
            return 0;
        }
    }

    return 1;
}

//------------------------------------------------------------------------
// vector_vector_int_print_hex
//------------------------------------------------------------------------
// Prints a visual representation of the vector_vector_int_t, with
// vectors in hex format

void vector_vector_int_print_hex( vector_vector_int_t* this )
{    
    assert( vector_vector_is_binary( this ));
    
    printf( "\033[0;36m" ); // Sets color to cyan
    printf( "************************\n" );
    for( int i = 0; i < this->size; i++ )
    {
        printf( "* %d. ", i );
        printf( "\033[0m" );
        vector_int_t* current_vector = vector_vector_int_at( this, i );
        vector_int_print_hex( current_vector );
        printf( "\033[0;36m" );
    }
    printf( "************************\n" );
    printf( "\033[0m" );
}