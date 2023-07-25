#include "echo5-int-ref.h"

void echo5_int_ref( unsigned int *in,
                    unsigned int &out )
{
  out = in[0];
}