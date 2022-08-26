//========================================================================
// vector-vector-int.h
//========================================================================
// Interfaces for resizable vector of vectors

// Note: My dad wants me to call this victor_vector from the movie 
// "Airplane", but in the interest of being able to understand
// names, I did not

#ifndef SPI_VECTOR_VECTOR_INT_H
#define SPI_VECTOR_VECTOR_INT_H

#include "vector-int.h"

typedef struct {
  vector_int_t** data;            // The data containes in the vector
  int            maxsize;         // The current maxsize of the vector. This will be changed
  // accordingly if we ever allocate more memory for the vector
  int            size;            // The current size of the vector
  int            size_of_vectors; // The size of vectors stored
} vector_vector_int_t;

void          vector_vector_int_construct       ( vector_vector_int_t* this  );
void          vector_vector_int_destruct        ( vector_vector_int_t* this  );
int           vector_vector_int_size            ( vector_vector_int_t* this  );
int           vector_vector_int_size_of_vectors ( vector_vector_int_t* this  );
void          vector_vector_int_push_back       ( vector_vector_int_t* this, vector_int_t* value );
vector_int_t* vector_vector_int_at              ( vector_vector_int_t* this, int idx             );
void          vector_vector_int_resize          ( vector_vector_int_t* this, int new_size );
void          vector_vector_int_print           ( vector_vector_int_t* this );
int           vector_vector_is_binary           ( vector_vector_int_t* this );
void          vector_vector_int_print_hex       ( vector_vector_int_t* this );

#endif  // VECTOR_VECTOR_INT_H