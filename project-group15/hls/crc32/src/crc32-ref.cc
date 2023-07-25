#include "crc32-ref.h"
#include <stdio.h>

unsigned int crc32_ref(char *message)
{
  unsigned int crc;
  char byte, size;
  crc = 0xFFFFFFFF;
  size = message[0];
  for (int i = 1; i <= size; i++)
  {
    byte = message[i];
    for (int j = 0; j < 8; j++)
    {
      char b = (byte ^ crc) & 1;
      crc >>= 1;
      if (b)
        crc = crc ^ 0xEDB88320;
      byte >>= 1;
    }
  }
  return ~crc;
}
