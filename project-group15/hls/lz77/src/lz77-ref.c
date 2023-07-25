unsigned int hash_elt(unsigned int x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return x;
}

unsigned int hash(unsigned int *arr, int len) {
    unsigned int x = 0x123456;
    int i;
    for (i=0; i<len; i++) {
        x = (hash_elt(arr[i])*(0xdeadbeef+i)) ^ x;
    }
    return x % 256;
}

__attribute__ ((noinline))
int lz77ref( unsigned int* dest, unsigned int* src, int N, int D, int W) 
{
    int len, h, i, j;
    unsigned int ht[256][D];
    for( i = 0; i < 256; i ++){
        for( int j = 0; j < D; j++){
            ht[i][j] = 0;
        }
    }
    unsigned int c_len = 0; // compression length
    if (N == 0) return c_len;
    dest[0] = 0;
    dest[1] = 0;
    dest[2] = src[0];
    i = 1;
    c_len = 3;
    while (i<N) {
        len = (i+3 <= N) ? 3 : N-i;
        h = hash(&src[i], len);
        int max_len = 0;
        int max_idx = 0;
        for (j=0; j<D; j++) { // check each entry in bucket
            int k = 0; 
            if (ht[h][j] > i-W || i-W < 0) {
                while (i+k<N && k<D && src[ht[h][j]+k] == src[i+k]) {
                    k++; 
                } 
            }
            if (k > max_len) {
                max_len = k;
                max_idx = ht[h][j];
            }
        }

        for (j=D-1; j>0; j--) {
            ht[h][j] = ht[h][j-1];
        }
        ht[h][0] = i;
        if (max_len <= 1) {
            dest[c_len] = 0;
            dest[c_len+1] = 0;
            dest[c_len+2] = src[i];
            i += 1;
        } else {
            dest[c_len] = i - max_idx;
            dest[c_len+1] = max_len;
            if ( i + max_len == N ){
                dest[c_len+2] = 0;
            } else {
                dest[c_len+2] = src[i+max_len];
            }
            i += max_len;
        }
        c_len += 3;
    }
    return c_len;
}
