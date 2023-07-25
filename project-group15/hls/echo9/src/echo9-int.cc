#include "echo9-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo9_int)( ac_channel< pack < ac_int<32,false> > > &in,
                           ac_channel< pack < ac_int<32,false> > > &out )
{
  pack<ac_int<32,false> > a;
  pack<ac_int<32,false> > b;

  if ( in.available(1) )
    a = in.read();
  
  b.data[0] = a.data[1];
  b.data[1] = a.data[0];
  
  out.write( b );

}