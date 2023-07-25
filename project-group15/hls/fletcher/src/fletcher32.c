#include "fletcher32.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(fletcher32)(ac_channel<short > &in, ac_channel<int> &out){
  int sum1 = 0;
  int sum2 = 0;
  #pragma hls_unroll yes
  for ( int i = 0; i < 8; i++ ) {
    sum1 = ( sum1 + in.read() ) % 65536;
    sum2 = ( sum1 + sum2 ) % 65536;
  }
  out.write( ( sum2 << 16 ) | sum1 );
}
