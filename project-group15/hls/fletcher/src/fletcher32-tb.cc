#include "fletcher32.h"
#include "fletcher32-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;
  
  // Initialize in and num channel
  short *in_ref = (short*) malloc(sizeof(short)*8);
  in_ref[0] = 0x7ffc; in_ref[1] = 0x7ffd; in_ref[2] = 0x7ffe;
  in_ref[3] = 0x7fff; in_ref[4] = 0x7ffc; in_ref[5] = 0x7ffd;
  in_ref[6] = 0x7ffe; in_ref[7] = 0x7fff;
  ac_channel<short > in_chan;

  // Initialize out channel
  ac_channel<int> out_chan;
  int out;
  int out_ref;                    

  for ( int i = 0; i < 8; i++ ) {
    // Write to channel
    in_chan.write(in_ref[i]);
  }

  // Call actual and reference functions
  fletcher32( in_chan, out_chan );
  out_ref = fletcher32_ref( in_ref );

  // Read from output channel
  out = out_chan.read();

  // Check results
  if ( out_ref != out ) {
    printf( "ERROR MISMATCH! in_ref = %d, out_ref = %d, out = %d\n", in_ref, out_ref, out );
    errCnt++;
  } else {
    printf( "SUCCESS! in_ref = %d, out_ref = %d, out = %d\n", in_ref, out_ref, out );
  }

  CCS_RETURN( errCnt );
}



