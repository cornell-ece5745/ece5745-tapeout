#include "echo2-int.h"
#include "echo2-int-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;

  // Initialize in and in channel
  ac_int<11,false> in;
  ac_channel< ac_int<11,false> > in_chan;

  // Initialize out channel
  ac_channel< ac_int<11,false> > out1_chan;
  ac_int<11,false> out1;
  ac_channel< ac_int<11,false> > out2_chan;
  ac_int<11,false> out2;                    

  for ( int i = 0; i < 20; i++ ) {
    in = rand();

    // Initialize reference in & out variables
    unsigned int in_ref = in;
    unsigned int out1_ref;
    unsigned int out2_ref;

    // Write to channel
    in_chan.write(in);

    // Call actual and reference functions
    echo2_int    ( in_chan, out1_chan, out2_chan );
    echo2_int_ref( in_ref,  out1_ref,  out2_ref  );

    // Read from output channel
    if ( out1_chan.available(1) )
      out1 = out1_chan.read();
    
    if ( out2_chan.available(1) )
      out2 = out2_chan.read();

    // Check results
    if ( out1_ref != out1 || out2_ref != out2 ) {
      printf( "ERROR MISMATCH! Iteration: %d, in_ref = %d, out1_ref = %d, out1 = %d, out2_ref = %d, out2 = %d\n\n", i, in_ref, out1_ref, out1.to_uint(), out2_ref, out2.to_uint() );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, in_ref = %d, out1_ref = %d, out1 = %d, out2_ref = %d, out2 = %d\n\n", i, in_ref, out1_ref, out1.to_uint(), out2_ref, out2.to_uint() );
    }
  }

  CCS_RETURN( errCnt );
}

