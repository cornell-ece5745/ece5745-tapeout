#include "echo8-int-ref.h"

void echo8_int_ref( unsigned int *in,
                    unsigned int *out )
{
  out[0] = in[0];
  out[1] = in[1];
}