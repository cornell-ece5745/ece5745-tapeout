#include "echo-int-ref.h"

void echo_int_ref( unsigned int in,
                   unsigned int &out )
{
  out = in;
}