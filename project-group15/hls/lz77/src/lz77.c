#include <ac_channel.h>

int lz77( ac_channel<unsigned int > &dest, ac_channel<unsigned int > &src, int N, int W) 
{
    unsigned int srcbuf[512];
    unsigned int destbuf[512];
    int s = 0;
    while (s < 512) {
        srcbuf[s] = src.read();
        s++;
    }
    int len, h, i, j;
    unsigned int ht[256][256];
    for( i = 0; i < 256; i ++){
        for( int j = 0; j < 256; j++){
            ht[i][j] = 0;
        }
    }
    unsigned int c_len = 0; // compression length
    if (N == 0) return c_len;
    destbuf[0] = 0;
    destbuf[1] = 0;
    destbuf[2] = srcbuf[0];
    i = 1;
    c_len = 3;
    while (i<N) {
        len = (i+3 <= N) ? 3 : N-i;
        unsigned int x = 0x123456;
        int i;
        for (i=0; i<len; i++) {
          x = ((srcbuf[i] >> 16) ^ srcbuf[i]) * 0x45d9f3b;
          x = (x >> 16) ^ x;
          x = (x*(0xdeadbeef+i)) ^ x;
        }
        h = x % 256;
        int max_len = 0;
        int max_idx = 0;
        for (j=0; j<256; j++) { // check each entry in bucket
            int k = 0; 
            if (ht[h][j] > i-W || i-W < 0) {
                while (i+k<N && k<256 && srcbuf[ht[h][j]+k] == srcbuf[i+k]) {
                    k++; 
                } 
            }
            if (k > max_len) {
                max_len = k;
                max_idx = ht[h][j];
            }
        }

        for (j=256-1; j>0; j--) {
            ht[h][j] = ht[h][j-1];
        }
        ht[h][0] = i;
        if (max_len <= 1) {
            destbuf[c_len] = 0;
            destbuf[c_len+1] = 0;
            destbuf[c_len+2] = srcbuf[i];
            i += 1;
        } else {
            destbuf[c_len] = i - max_idx;
            destbuf[c_len+1] = max_len;
            if ( i + max_len == N ){
                destbuf[c_len+2] = 0;
            } else {
                destbuf[c_len+2] = srcbuf[i+max_len];
            }
            i += max_len;
        }
        c_len += 3;
    }
    return c_len;
}
