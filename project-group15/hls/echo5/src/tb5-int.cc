#include "echo5-int.h"
#include "echo5-int-ref.h"
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;

  // Initialize in and in channel
  pack< ac_int<11,false> > in;
  ac_channel< pack <ac_int<11,false> > > in_chan;

  // Initialize out channel
  ac_channel< ac_int<11,false> > out_chan;
  ac_int<11,false> out;              

  for ( int i = 0; i < 20; i++ ) {
    in.data[0] = rand();

    // Initialize reference in & out variables
    unsigned int in_ref[] = { in.data[0] };
    unsigned int out_ref;

    // Write to channel
    in_chan.write(in);

    // Call actual and reference functions
    echo5_int    ( in_chan, out_chan );
    echo5_int_ref( in_ref,  out_ref  );

    // Read from output channel
    if ( out_chan.available(1) )
      out = out_chan.read();

    // Check results
    if ( out_ref != out ) {
      printf( "ERROR MISMATCH! Iteration: %d, in_ref[0] = %d, out_ref = %d, out = %d\n\n", i, in_ref[0], out_ref, out.to_uint() );
      errCnt++;
    } else {
      printf( "SUCCESS! Iteration: %d, in_ref[0] = %d, out_ref = %d, out = %d\n\n", i, in_ref[0], out_ref, out.to_uint() );
    }
  }

  CCS_RETURN( errCnt );
}

