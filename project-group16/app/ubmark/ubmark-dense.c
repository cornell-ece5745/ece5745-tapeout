//========================================================================
// ubmark-dense
//========================================================================

#include "common.h"
//------------------------------------------------------------------------
// dense
//------------------------------------------------------------------------

__attribute__ ((noinline))
void dense( int num_row, int num_col, int* arr, int* v, int* dest ){
  for ( int i = 0; i < num_row ; i++ ){
    int sum = 0;
    for ( int j = 0; j < num_col ; j++ ){
      sum += v[j] * arr[i*num_col+j];
    }
    dest[i] = sum;
  }
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int dest[], int ref[], int size ){
  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }
}

