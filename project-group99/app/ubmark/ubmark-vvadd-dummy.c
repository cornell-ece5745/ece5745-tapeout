//========================================================================
// ubmark-vvadd
//========================================================================

#include "common.h"
#include "ubmark-vvadd.h"
#include "ubmark-vvadd.dat"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  int dest[size];

  for ( int i = 0; i < size; i++ )
    dest[i] = ref[i];

  test_stats_on();
  // dummy to estimate energy outside function
  test_stats_off();

  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }

  test_pass();
  return 0;
}
