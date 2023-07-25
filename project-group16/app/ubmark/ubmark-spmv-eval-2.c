//========================================================================
// ubmark-spmv
//========================================================================

#include "common.h"
#include "ubmark-spmv.h"
#include "ubmark-spmv-2.dat"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  int dest[num_rows];

  for ( int i = 0; i < num_rows; i++ )
    dest[i] = 0;

  test_stats_on();
  spmv( num_rows, rows, cols, vals, v, dest );
  test_stats_off();

  for ( int i = 0; i < num_rows; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }

  test_pass();
  return 0;
}
