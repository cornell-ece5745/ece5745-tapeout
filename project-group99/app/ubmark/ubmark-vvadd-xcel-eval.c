//========================================================================
// ubmark-vvadd
//========================================================================

#include "common.h"
#include "ubmark-vvadd-xcel.h"
#include "ubmark-vvadd.dat"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  int dest[size];

  for ( int i = 0; i < size; i++ )
    dest[i] = 0;

  test_stats_on();
  vvadd_xcel( dest, src0, src1, size );
  test_stats_off();

  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }

  test_pass();
  return 0;
}
