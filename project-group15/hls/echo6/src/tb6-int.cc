#include "echo6-int.h"
#include "echo6-int-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;

  // Initialize in and in channel
  ac_channel< ac_int<11,false> > in_chan;
  ac_int<11,false> in; 

  // Initialize out channel
  pack< ac_int<11,false> > out;
  ac_channel< pack <ac_int<11,false> > > out_chan;             

  for ( int i = 0; i < 20; i++ ) {
    in = rand();

    // Initialize reference in & out variables
    unsigned int in_ref = in;
    unsigned int out_ref[1];

    // Write to channel
    in_chan.write(in);

    // Call actual and reference functions
    echo6_int    ( in_chan, out_chan );
    echo6_int_ref( in_ref,  out_ref  );

    // Read from output channel
    if ( out_chan.available(1) )
      out = out_chan.read();

    // Check results
    if ( out_ref[0] != out.data[0] ) {
      printf( "ERROR MISMATCH! Iteration: %d, in_ref = %d, out_ref[0] = %d, out[0] = %d\n\n", i, in_ref, out_ref[0], out.data[0].to_uint() );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, in_ref = %d, out_ref[0] = %d, out[0] = %d\n\n", i, in_ref, out_ref[0], out.data[0].to_uint() );
    }
  }

  CCS_RETURN( errCnt );
}

