#ifndef _ECHO3_INT_H_
#define _ECHO3_INT_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

void echo3_int( ac_channel<ac_int<11,false> > &in1, 
                ac_channel<ac_int<11,false> > &in2,
                ac_channel<ac_int<11,false> > &out );

#endif // _ECHO3_H_