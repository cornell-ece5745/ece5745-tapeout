#include <sys/ipc.h>
#include <sys/shm.h>

// standard C/C++ headers
#include <getopt.h>
#include <sys/time.h>
#include <time.h>
// #include <cassert>
#include <stdio.h>
#include <stdint.h>
#include <math.h>

//datat types
// #include <ap_fixed.h>
//ap_fixed<8, 4>

#define MEMORY_SIZE 100


void unflatten_fixed( unsigned char* myArray, const char* filename, int oneDArraySize)
{
    FILE* fp;
    fp = fopen(filename, "rb");

    fread(myArray, 1, oneDArraySize, fp);
}
int main(int argc, char ** argv) {
  //std::cout << " Initialize shared memory...";
  int input_data [2][MEMORY_SIZE];
  unsigned char arg_0 [2*MEMORY_SIZE];
  
  unflatten_fixed(arg_0,"/work/shared/users/meng/ys566/weight_dat/image.dat", 2*MEMORY_SIZE);

  for (int i0 = 0; i0 < 2; i0++) {
    for (int i1 = 0; i1 < MEMORY_SIZE; i1++) {
        input_data[i0][i1] = (int)(arg_0[i1*MEMORY_SIZE + i0*MEMORY_SIZE*2]) >> 4;
    }
  }
}