#include "lz77simple.h"
#include "lz77simple-ref.h"
#include <stdio.h>
#include <mc_scverify.h>
#include <ac_channel.h>

int errCnt = 0;

CCS_MAIN( int argv, char **argc )
{
  // Initialize src, dest, window channels
  ac_channel<unsigned int > src_chan;
  ac_channel<unsigned int > dest_chan;
  
  // Generate data to compress
  unsigned int src[512];
  for (int i = 0; i < 512; i++) {
    src[i] = i;
  }
  unsigned int dest[30];

  // Write input data to uut
  src_chan.write(512);
  for ( int i = 0; i < 512; i++ ) {
      src_chan.write(src[i]);
  }
  
  // Call actual and reference functions
  lz77simple(dest_chan, src_chan);
  lz77simpleref(dest, src, 10, 10);
  
  // Read output from uut
  unsigned int dest_uut[30];
  for ( int i = 0; i < 30; i++) {
    dest_uut[i] = dest_chan.read();
  }

  // Check results
  for (int i = 0; i < 30; i++) {
    if ( dest[i] != dest_uut[i] ) {
      printf( "ERROR MISMATCH! Iteration: %d, out_ref = %d, out = %d\n", i, dest[i], dest_uut[i] );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, out_ref = %d, out = %d\n", i, dest[i], dest_uut[i] );
    }
  }
  CCS_RETURN( errCnt );
}



