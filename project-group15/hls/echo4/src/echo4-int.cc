#include "echo4-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo4_int)( ac_channel<ac_int<11,false> > &in1,
                           ac_channel<ac_int<11,false> > &in2,
                           ac_channel<ac_int<11,false> > &out1,
                           ac_channel<ac_int<11,false> > &out2 )
{
  if ( in1.available(1) )
    out2.write( in1.read() );
  
  if ( in2.available(1) )
    out1.write( in2.read() );
  
}