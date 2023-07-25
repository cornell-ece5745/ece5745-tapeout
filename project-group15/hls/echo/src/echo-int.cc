#include "echo-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo_int)( ac_channel<ac_int<11,false> > &in,
                      ac_channel<ac_int<11,false> > &out )
{
  out.write( in.read() ); 
}