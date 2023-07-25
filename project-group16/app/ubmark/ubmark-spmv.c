//========================================================================
// ubmark-spmv
//========================================================================

#include "common.h"

//------------------------------------------------------------------------
// spmv
//------------------------------------------------------------------------

__attribute__ ((noinline))
void spmv(int num_rows, int* rows, int* cols, int* vals, int* v, int* dest) {
  for ( int i = 0; i < num_rows; i++ ) {
    int sum = 0;
    for ( int j = rows[i]; j < rows[i+1]; j++ ) {
      sum += vals[j] * v[cols[j]];
    }
    dest[i] = sum;
  }
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int dest[], int ref[], int size )
{
  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }
}

