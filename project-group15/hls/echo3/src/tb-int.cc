#include "echo3-int.h"
#include "echo3-int-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;

  // Initialize in and in channel
  ac_int<11,false> in1;
  ac_channel< ac_int<11,false> > in1_chan;
  ac_int<11,false> in2;
  ac_channel< ac_int<11,false> > in2_chan;

  // Initialize out channel
  ac_channel< ac_int<11,false> > out_chan;
  ac_int<11,false> out;                   

  for ( int i = 0; i < 20; i++ ) {
    in1 = rand();
    in2 = rand();

    // Initialize reference in & out variables
    unsigned int in1_ref = in1;
    unsigned int in2_ref = in2;
    unsigned int out_ref;

    // Write to channel
    in1_chan.write(in1);
    in2_chan.write(in2);

    // Call actual and reference functions
    echo3_int    ( in1_chan, in2_chan, out_chan );
    echo3_int_ref( in1_ref,  in2_ref,  out_ref  );

    // Read from output channel
    if ( out_chan.available(1) )
      out = out_chan.read();

    // Check results
    if ( out_ref != out ) {
      printf( "ERROR MISMATCH! Iteration: %d, in1_ref = %d, in2_ref = %d, out_ref = %d, out = %d\n\n", i, in1_ref, in2_ref, out_ref, out.to_uint() );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, in1_ref = %d, in2_ref = %d, out_ref = %d, out = %d\n\n", i, in1_ref, in2_ref, out_ref, out.to_uint() );
    }
  }

  CCS_RETURN( errCnt );
}

