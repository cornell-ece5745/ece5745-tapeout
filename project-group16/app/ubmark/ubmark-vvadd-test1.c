//========================================================================
// ubmark-vvadd
//========================================================================

#include "common.h"
#include "ubmark-vvadd.h"

//------------------------------------------------------------------------
// Test Cases
//------------------------------------------------------------------------

void test_size3()
{
  wprintf(L"test_size3\n");

  int src0[3] = { 1, 2, 3 };
  int src1[3] = { 4, 5, 6 };
  int dest[3] = { 0, 0, 0 };
  int ref[3]  = { 5, 7, 9 };

  vvadd_scalar( dest, src0, src1, 3 );

  for ( int i = 0; i < 3; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }
}

void test_size8()
{
  wprintf(L"test_size8\n");

  int src0[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
  int src1[8] = { 4, 5, 6, 7, 8, 9, 0, 1 };
  int dest[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
  int ref[8]  = { 5, 7, 9,11,13,15, 7, 9 };

  vvadd_scalar( dest, src0, src1, 8 );

  for ( int i = 0; i < 8; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  test_size3();
  test_size8();
  test_pass();
  return 0;
}
