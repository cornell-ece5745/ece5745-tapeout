#include "lz77simple.h"
#include <mc_scverify.h>

#pragma hls_design top
void CCS_BLOCK(lz77simple)( ac_channel<unsigned int > &dest, ac_channel<unsigned int > &src) 
{
    unsigned int c_len = 0; // compressed sequence length
    int N = src.read(); // get original sequence length from input channel
    if (N == 0) return;
    int srcbuf[512]; int s;
    #pragma hls_unroll 32
    for (s=0; s<N; s++) {
        srcbuf[s] = src.read();
    }
    dest.write(0);
    dest.write(0);
    dest.write(srcbuf[0]); // the first literal never matches
    c_len = 3;
    int i = 1; // index of current position in the input buffer
    while (i < N) {
      int L = 0; // max match length
      int D = 0; // index of max match length
      int j;
      #pragma hls_unroll yes
      for (j=1; j<10; j++) { // Window size set to 10
        int k = 0; // length of match between src[i] and src[i-j]
        while(i+k < N && srcbuf[i+k] == srcbuf[i-j+k]) {
          k++; // increment match length if literals match
        }
        if (k >= 3 && k > L) { // update L and D if longer match found
          L = k;
          D = j;
        }
      }
      dest.write(D);
      dest.write(L);
      if (L == 0) { // no match was found
        dest.write(srcbuf[i]);
        i = i + 1;
      } else { // a match was found
        if (i+L < N) {
          dest.write(srcbuf[i+L]);
        } else {
          dest.write(0);
          i = i + L;
        }
      }
      c_len = c_len + 3;
  }
  return;
}
