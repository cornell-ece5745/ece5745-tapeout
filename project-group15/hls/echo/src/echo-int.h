#ifndef _ECHO_INT_H_
#define _ECHO_INT_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

void echo_int( ac_channel<ac_int<11,false> > &in, 
           ac_channel<ac_int<11,false> > &out );

#endif // _ECHO_H_