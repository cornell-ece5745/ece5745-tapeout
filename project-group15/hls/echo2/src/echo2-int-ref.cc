#include "echo2-int-ref.h"

void echo2_int_ref( unsigned int in,
                    unsigned int &out1,
                    unsigned int &out2 )
{
  out1 = in;
  out2 = in;
}