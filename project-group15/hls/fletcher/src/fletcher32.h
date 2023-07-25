#ifndef _FLETCHER_32_H_
#define _FLETCHER_32_H_

#include <stdio.h>
#include <stdbool.h>
#include <ac_channel.h> // Algorithmic C channel class

void fletcher32(ac_channel<short > &in, ac_channel<int> &out);

#endif // _FLETCHER_32_H_
