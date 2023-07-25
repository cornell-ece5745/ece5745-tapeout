#include "crc32.h"
#include "crc32-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

#define SIZE 8

CCS_MAIN(int argv, char **argc)
{
  int errCnt = 0;

  // Initialize in and in channel
  char in;
  char in_ref[9];
  char size = SIZE;
  ac_channel<char> in_chan;

  // Initialize out channel
  ac_channel<unsigned int> out_chan;
  unsigned int out;

  for ( int i = 0; i < 20; i++ ) {

    in_ref[0] = size;
    in_chan.write(size);

    for ( int j = 0; j < size; j++ ) {
      in = rand() % (255);
      in_ref[j+1] = in;
      in_chan.write(in);
    }
    // Call actual and reference functions
    unsigned int out_ref = crc32_ref( in_ref );
    crc32( in_chan, out_chan );

    // Read from output channel
    if (out_chan.available(1))
      out = out_chan.read();

    // Check results
    if (out != out_ref)
    {
      printf("ERROR MISMATCH! Iteration: %d, out = %x, out_ref = %x\n", i, (unsigned int)out, out_ref);
      errCnt++;
    }
    else
    {
      printf("SUCCESS! Iteration: %d, out = %x, out_ref = %x\n", i, (unsigned int)out, out_ref);
    }
  }

  CCS_RETURN(errCnt);
}
