#include "common.h"
#include "ubmark-lz77.h"

void verify_results( unsigned int dest[], unsigned int ref[], int size )
{
  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) )
      test_fail( i, dest[i], ref[i] );
  }
}

void test1()
{
  wprintf(L"test1\n");
  unsigned int src[10] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  unsigned int dest[30];
  unsigned int ref[30] = { 0, 0, 0, 0, 0, 1, 
  0, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 5, 0, 0, 6, 0, 0, 7, 
  0, 0, 8, 0, 0, 9};
  int c_len = lz77(dest, src, 10, 10, 10);
  verify_results(dest, ref, c_len); 
}

void test2()
{
  wprintf(L"test2\n");
  unsigned int src[10] = { 0, 1, 0, 1, 9, 0, 1, 0, 1, 0};
  unsigned int dest[30];
  unsigned int ref[21] = { 0, 0, 0, 0, 0, 1, 
  2, 2, 9, 0, 0, 9, 5, 4, 0, 0, 0, 0 };
  int c_len = lz77(dest, src, 10, 10, 10);
  verify_results(dest, ref, c_len); 
}

void test3()
{
  wprintf(L"test3\n");
  unsigned int src[10] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
  unsigned int dest[30];
  unsigned int ref[6] = { 0, 0, 1, 1, 9, 0};
  int c_len = lz77(dest, src, 10, 10, 10);
  verify_results(dest, ref, c_len); 
}

void test4()
{
  wprintf(L"test4\n");
  unsigned int src[15] = { 0, 1, 2, 5, 0, 1, 2, 3, 4, 5, 1, 2, 5, 5, 0};
  unsigned int dest[45];
  unsigned int ref[33] = { 0, 0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 5, 
  4, 3, 3, 0, 0, 3, 0, 0, 4, 0, 0, 5, 9, 3, 5, 0, 0, 5, 0, 0, 0};
  int c_len = lz77(dest, src, 15, 15, 15);
  verify_results(dest, ref, c_len); 
}

void test5()
{
  wprintf(L"test5\n");
  unsigned int src[13] = {0, 1, 2, 3, 8, 9, 0, 1, 2, 0, 1, 2, 3};
  unsigned int dest[39];
  unsigned int ref[27] = {0, 0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0, 8,
  0, 0, 9, 6, 3, 0, 3, 3, 3, 0, 0, 3};
  int c_len = lz77(dest, src, 13, 13, 8);
  verify_results(dest, ref, c_len);
}

int main( int argc, char* argv[] )
{
  test1();
  test2(); 
  test3();
  test4();
  test5();
  test_pass();
  return 0;
}