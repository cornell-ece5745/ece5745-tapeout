#include "echo-int.h"
#include "echo-int-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;

  // Initialize in and in channel
  ac_int<11,false> in;
  ac_channel< ac_int<11,false> > in_chan;

  // Initialize out channel
  ac_channel< ac_int<11,false> > out_chan;
  ac_int<11,false> out;                    // out_chan.read()

  for ( int i = 0; i < 20; i++ ) {
    in = rand();

    // Initialize reference in & out variables
    unsigned int in_ref = in;
    unsigned int out_ref;

    // Write to channel
    in_chan.write(in);

    // Call actual and reference functions
    echo_int    ( in_chan, out_chan );
    echo_int_ref( in_ref,  out_ref  );

    // Read from output channel
    out = out_chan.read();

    // Check results
    if ( out_ref != out ) {
      printf( "ERROR MISMATCH! Iteration: %d, in_ref = %d, out_ref = %d, out = %d\n", i, in_ref, out_ref, out.to_uint() );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, in_ref = %d, out_ref = %d, out = %d\n", i, in_ref, out_ref, out.to_uint() );
    }
  }

  CCS_RETURN( errCnt );
}

