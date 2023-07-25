#include "echo5-int.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(echo5_int)( ac_channel<pack<ac_int<11,false> > > &in,
                           ac_channel<ac_int<11,false> >  &out )
{
  pack<ac_int<11,false> > a;

  if ( in.available(1) )
    a = in.read();
  
  out.write( a.data[0] );
  
}