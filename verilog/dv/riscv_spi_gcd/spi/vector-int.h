//========================================================================
// vector-int.h
//========================================================================
// Interfaces for resizable vector

#ifndef SPI_VECTOR_INT_H
#define SPI_VECTOR_INT_H

typedef struct {
  int* data;     // The data containes in the vector
  int  maxsize;  // The current maxsize of the vector. This will be changed
  // accordingly if we ever allocate more memory for the vector
  int size;  // The current size of the vector
} vector_int_t;

void vector_int_construct ( vector_int_t* this  );
void vector_int_destruct  ( vector_int_t* this  );
int  vector_int_size      ( vector_int_t* this  );
void vector_int_push_back ( vector_int_t* this, int value );
int  vector_int_at        ( vector_int_t* this, int idx   );
int  vector_int_contains  ( vector_int_t* this, int value );
void vector_int_print     ( vector_int_t* this  );
void vector_int_extend    ( vector_int_t* this, int value );
int  vector_is_binary     ( vector_int_t* this );
void vector_int_print_hex ( vector_int_t* this );

#endif  // VECTOR_INT_H