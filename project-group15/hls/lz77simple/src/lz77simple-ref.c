#include "lz77simple-ref.h"

int lz77simpleref( unsigned int* dest, unsigned int* src, int N, int W) 
{
    unsigned int c_len = 0; // compressed sequence length
    if (N == 0) return 0;
    dest[0] = 0;
    dest[1] = 0;
    dest[2] = src[0]; // the first literal never matches
    c_len = 3;
    int i = 1; // index of current position in the input buffer
    while (i < N) {
      int L = 0; // max match length
      int D = 0; // index of max match length
      int j;
      for (j=1; j<W; j++) {
        int k = 0; // length of match between src[i] and src[i-j]
        while(i+k < N && src[i+k] == src[i-j+k]) {
          k++; // increment match length if literals match
        }
        if (k >= 3 && k > L) { // update L and D if longer match found
          L = k;
          D = j;
        }
      }
      dest[c_len] = D;
      dest[c_len+1] = L;
      if (L == 0) { // no match was found
        dest[c_len+2] = src[i];
        i = i + 1;
      } else { // a match was found
        if (i+L < N) {
          dest[c_len+2] = src[i+L];
        } else {
          dest[c_len+2] = 0;
          i = i + L;
        }
      }
      c_len = c_len + 3;
  }
  return c_len;
}
