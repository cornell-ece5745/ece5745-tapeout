#include "echo3-int-ref.h"

void echo3_int_ref( unsigned int in1,
                    unsigned int in2,
                    unsigned int &out )
{
  out = in1;
  int dump = in2;
}