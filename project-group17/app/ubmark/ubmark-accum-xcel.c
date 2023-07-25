//========================================================================
// ubmark-accum-xcel
//========================================================================

#include "common.h"
#include "ubmark-accum.dat"

//------------------------------------------------------------------------
// accum_xcel
//------------------------------------------------------------------------

#ifdef _RISCV

__attribute__ ((noinline))
int accum_xcel( int* src, int size )
{
  int result = 0;

  asm volatile (
    "csrw 0x7E1, %[src]; \n"
    "csrw 0x7E2, %[size];\n"
    "csrw 0x7E0, x0     ;\n"
    "csrr %[result], 0x7E0;\n"

    // Outputs from the inline assembly block

    : [result] "=r"(result)

    // Inputs to the inline assembly block

    : [src]    "r"(src),
      [size]   "r"(size)

    // Tell the compiler this accelerator read/writes memory

    : "memory"
  );

  return result;
}

#else

// for native

__attribute__ ((noinline))
int accum_xcel( int* src, int size )
{
  int sum = 0;
  for ( int i = 0; i < size; i++ )
    sum += src[i];
  return sum;
}
#endif

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
  int sum = accum_xcel( src, size );
  test_stats_off();

  verify_results( sum, ref );

  return 0;
}

