#ifndef _ECHO9_INT_H_
#define _ECHO9_INT_H_

#include <ac_fixed.h>   // Algortihmic C fixed-point data types
#include <ac_channel.h> // Algorithmic C channel class

template<typename T>
struct pack {
  T data[2];
};

void echo9_int( ac_channel< pack <ac_int<32,false> > > &in, 
                ac_channel< pack <ac_int<32,false> > > &out );

#endif // _ECHO9_H_