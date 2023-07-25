#include "echo6-int-ref.h"

void echo6_int_ref( unsigned int in,
                    unsigned int *out )
{
  out[0] = in;
}