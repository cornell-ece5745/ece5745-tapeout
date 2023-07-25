#include "echo2-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo2_int)( ac_channel<ac_int<11,false> > &in,
                           ac_channel<ac_int<11,false> > &out1,
                           ac_channel<ac_int<11,false> > &out2 )
{
  if ( in.available(1) ) {
    ac_int<11,false> temp = in.read();
    out1.write( temp );
    out2.write( temp ); 
  }
  
  
}