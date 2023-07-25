#include "echo8-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo8_int)( ac_channel< pack < ac_int<32,false> > > &in,
                           ac_channel< pack < ac_int<32,false> > > &out )
{
  pack<ac_int<32,false> > a;

  if ( in.available(1) )
    a = in.read();
  
  out.write( a );

}