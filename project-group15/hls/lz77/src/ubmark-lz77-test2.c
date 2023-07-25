#include "common.h"
#include "ubmark-lz77.h"
#include "ubmark-lz77.dat"

void decompress(unsigned int* uncompressed, unsigned int* compressed, int N)
{
  int counter = 0;
  for ( int i = 0; i < N; i = i + 3){
    if (compressed[i] == 0 && compressed[i+1] == 0){
      uncompressed[counter] = compressed[i+2];
      counter++;
    }
    else{
      for ( int j = 0; j < compressed[i+1]; j++){
        uncompressed[counter+j ] = uncompressed[counter - compressed[i] + j];
      }
      counter = counter + compressed[i+1];
    }
  }
}

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
  unsigned int ref[10];
  int c_len = lz77(dest, src, 10, 10, 10);
  decompress(ref, dest, c_len);
  verify_results(src, ref, 10); 
}

void test2()
{
  wprintf(L"test2\n");
  unsigned int src[10] = { 0, 1, 0, 1, 9, 0, 1, 0, 1, 0};
  unsigned int dest[30];
  unsigned int ref[10];
  int c_len = lz77(dest, src, 10, 10, 10);
  decompress(ref, dest, c_len);
  verify_results(src, ref, 10); 
}

void test3()
{
  wprintf(L"test3\n");
  unsigned int src[10] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
  unsigned int dest[30];
  unsigned int ref[10];
  int c_len = lz77(dest, src, 10, 10, 10);
  decompress(ref, dest, c_len);
  verify_results(src, ref, 10); 
}

void test4()
{
  wprintf(L"test4\n");
  unsigned int src[15] = { 0, 1, 2, 5, 0, 1, 2, 3, 4, 5, 1, 2, 5, 5, 0};
  unsigned int dest[45];
  unsigned int ref[15];
  int c_len = lz77(dest, src, 15, 15, 15);
  decompress(ref, dest, c_len);
  verify_results(src, ref, 10); 
}

void test5()
{
  wprintf(L"test5\n");
  unsigned int dest[600];
  unsigned int ref[200];
  int c_len = lz77(dest, src0, 200, 20, 50);
  decompress(ref, dest, c_len);
  verify_results(src0, ref, 200); 
}

void test6()
{
  wprintf(L"test6\n");
  unsigned int dest[3000];
  unsigned int ref[1000];
  int c_len = lz77(dest, src0, 1000, 20, 100);
  decompress(ref, dest, c_len);
  verify_results(src0, ref, 1000); 
  wprintf(L"%i\n", c_len);
}

int main( int argc, char* argv[] )
{
  test1();
  test2();
  test3();
  test4();
  test5();
  test6();
  test_pass();
  return 0;
}