#ifndef _CRC32_H_
#define _CRC32_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

void crc32(ac_channel<char> &in,
           ac_channel<unsigned int> &out);

#endif // _CRC32_H_