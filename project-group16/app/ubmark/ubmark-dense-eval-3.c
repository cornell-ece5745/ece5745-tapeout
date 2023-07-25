//========================================================================
// ubmark-dense
//========================================================================

#include "common.h"
#include "ubmark-dense.h"
#include "ubmark-dense-3.dat"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  int dest[num_rows];

  for ( int i = 0; i < num_rows; i++ )
    dest[i] = 0;

  test_stats_on();
  dense( num_rows, num_rows, arr, v, dest );
  test_stats_off();

  for ( int i = 0; i < num_rows; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }

  test_pass();
  return 0;
}