#ifndef _ECHO4_INT_H_
#define _ECHO4_INT_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

void echo4_int( ac_channel<ac_int<11,false> > &in1, 
                ac_channel<ac_int<11,false> > &in2,
                ac_channel<ac_int<11,false> > &out1,
                ac_channel<ac_int<11,false> > &out2 );

#endif // _ECHO4_H_