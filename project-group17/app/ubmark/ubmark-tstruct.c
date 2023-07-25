// ubmark-dtofixed

#include "common.h"
#include "ubmark-dtofixed.h"


//custom define
#define FIXED_POINT_FRACTIONAL_BITS 5
#define MAX_LEN 16
#define MAX_VALUE_MULT (1 << (MAX_LEN - 1)) << FIXED_POINT_FRACTIONAL_BITS
#define MAX_VALUE_ADD (1 << (MAX_LEN - 1))


//------------------------------------------------------------------------
// double-to-fixed
//------------------------------------------------------------------------
__attribute__ ((noinline))

//------------------------------------------------------------------------
// verify result
//------------------------------------------------------------------------
void verify_results( int dest[], int ref[], int size )
{
  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }
}

//------------------------------------------------------------------------
// Test Cases
//------------------------------------------------------------------------
void test_size3()
{
  int src[3] = { 1, 2, 3 };
  int dest[3] = { 0, 0, 0 };
  int ref[3]  = { 1,2,3  };
  
  struct tuple dest_tup[3];
  
  for ( int k = 0; k < 3; k++ ) {
    dest_tup[k].value = src[k] ;
  }
 
  for ( int i = 0; i < 3; i++ ) {
    if ( !( dest_tup[i].value == ref[i] ) )
      test_fail( i, dest_tup[i].value, ref[i] );
  }
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  test_size3();
  test_pass();
  return 0;
}