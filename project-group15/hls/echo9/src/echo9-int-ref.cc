#include "echo9-int-ref.h"

void echo9_int_ref( unsigned int *in,
                    unsigned int *out )
{
  out[0] = in[1];
  out[1] = in[0];
}