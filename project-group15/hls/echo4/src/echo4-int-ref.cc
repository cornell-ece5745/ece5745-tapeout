#include "echo4-int-ref.h"

void echo4_int_ref( unsigned int in1,
                    unsigned int in2,
                    unsigned int &out1,
                    unsigned int &out2 )
{
  out1 = in2;
  out2 = in1;
}