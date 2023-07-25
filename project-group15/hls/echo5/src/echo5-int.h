#ifndef _ECHO5_INT_H_
#define _ECHO5_INT_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

template<typename T>
struct pack {
  T data[1];
};

void echo5_int( ac_channel< pack <ac_int<11,false> > > &in, 
                ac_channel< ac_int<11,false> > &out );

#endif // _ECHO5_H_