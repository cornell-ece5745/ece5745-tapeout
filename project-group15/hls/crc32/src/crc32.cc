#include "crc32.h"
#include <mc_scverify.h>

#pragma hls_design top

void CCS_BLOCK(crc32)(ac_channel<char> &in,
                      ac_channel<unsigned int> &out)
{
  char size_val = in.read();
  unsigned int crc = 0xFFFFFFFF;

  for (char i = 0; i < size_val; ++i)
  {
    char data = in.read();
    for (int j = 0; j < 8; ++j)
    {
      ac_int<1> b = (data ^ crc) & 1;
      crc >>= 1;
      if (b)
        crc = crc ^ 0xEDB88320;
      data >>= 1;
    }
  }
  unsigned int out_val = ~crc;
  out.write(out_val);
}

// x = y.slc<2>(5); // bw 2, 5 is lsb