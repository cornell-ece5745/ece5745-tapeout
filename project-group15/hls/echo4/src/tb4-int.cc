#include "echo4-int.h"
#include "echo4-int-ref.h"
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
  ac_channel< ac_int<11,false> > out1_chan;
  ac_int<11,false> out1;
  ac_channel< ac_int<11,false> > out2_chan;
  ac_int<11,false> out2;                 

  for ( int i = 0; i < 20; i++ ) {
    in1 = rand();
    in2 = rand();

    // Initialize reference in & out variables
    unsigned int in1_ref = in1;
    unsigned int in2_ref = in2;
    unsigned int out1_ref;
    unsigned int out2_ref;

    // Write to channel
    in1_chan.write(in1);
    in2_chan.write(in2);

    // Call actual and reference functions
    echo4_int    ( in1_chan, in2_chan, out1_chan, out2_chan );
    echo4_int_ref( in1_ref,  in2_ref,  out1_ref,  out2_ref  );

    // Read from output channel
    if ( out1_chan.available(1) )
      out1 = out1_chan.read();
    
    if ( out2_chan.available(1) )
      out2 = out2_chan.read();

    // Check results
    if ( out1_ref != out1 || out2_ref != out2 ) {
      printf( "ERROR MISMATCH! Iteration: %d, in1_ref = %d, in2_ref = %d, out1_ref = %d, out1 = %d\n\n", i, in1_ref, in2_ref, out1_ref, out1.to_uint(), out2_ref, out2.to_uint() );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, in1_ref = %d, in2_ref = %d, out1_ref = %d, out1 = %d\n\n", i, in1_ref, in2_ref, out1_ref, out1.to_uint(), out2_ref, out2.to_uint() );
    }
  }

  CCS_RETURN( errCnt );
}

