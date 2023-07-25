//========================================================================
// ubmark-dummy
//========================================================================

#include "common.h"
#include "ubmark-sort.dat"

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int dest[], int ref[], int size )
{
  int i;
  for ( i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) ) {
      test_fail( i, dest[i], ref[i] );
    }
  }
  test_pass();
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  int dest[size];

  int i;
  for ( i = 0; i < size; i++ )
    dest[i] = ref[i];

  test_stats_on();
  // dummy to estimate energy outside function
  test_stats_off();

  verify_results( dest, ref, size );

  return 0;
}
