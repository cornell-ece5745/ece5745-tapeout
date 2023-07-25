#include "echo3-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo3_int)( ac_channel<ac_int<11,false> > &in1,
                           ac_channel<ac_int<11,false> > &in2,
                           ac_channel<ac_int<11,false> > &out )
{
  if ( in1.available(1) )
    out.write( in1.read() );
  
}