#include "fletcher32-ref.h"

int fletcher32_ref( short *a ){
  int sum1 = 0;
  int sum2 = 0;
  for ( int i = 0; i < 8; i++ ) {
    sum1 = ( sum1 + a[i] ) % 65536;
    sum2 = ( sum1 + sum2 ) % 65536;
  }
  return ( ( sum2 << 16 ) | sum1 );
}

