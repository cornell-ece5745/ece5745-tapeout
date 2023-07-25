//========================================================================
// ubmark-accum
//========================================================================

#include "common.h"
#include "ubmark-accum.dat"

//------------------------------------------------------------------------
// accum-scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
int accum_scalar( int* src, int size )
{
  int sum = 0;
  for ( int i = 0; i < size; i++ )
    sum += src[i];
  return sum;
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int sum, int ref )
{
  if ( sum != ref )
    test_fail( 0, sum, ref );
  test_pass();
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  test_stats_on();
  int sum = accum_scalar( src, size );
  test_stats_off();

  verify_results( sum, ref );

  return 0;
}
