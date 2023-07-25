#ifndef _ECHO2_INT_H_
#define _ECHO2_INT_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

void echo2_int( ac_channel<ac_int<11,false> > &in, 
                ac_channel<ac_int<11,false> > &out1,
                ac_channel<ac_int<11,false> > &out2 );

#endif // _ECHO2_H_