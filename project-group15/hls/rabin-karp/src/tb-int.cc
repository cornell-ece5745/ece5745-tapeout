#include "rabin-karp.h"
#include "rabin-karp-ref.h"
#include <ac_channel.h>
#include <stdio.h>
#include <mc_scverify.h>

CCS_MAIN( int argv, char **argc )
{
  int errCnt = 0;
  int i, j;
  int k;
  int q = 13;
  ac_channel<int > text_length_chan;
  ac_channel<int > text_chan;
  ac_channel<int > pattern_length_chan;
  ac_channel<int > pattern_chan;
  ac_channel<int > q_chan;
  ac_channel<int > out_chan;
  int *out_ref = (int *) malloc(sizeof(int)*128);
  int *out_rtl;
  
  
  // Test module with 5 arrays of different length and 5 patterns.
  int** inputs = (int**) malloc(sizeof(int*)*5);
  inputs[0] = (int *) malloc(sizeof(int)*10);
  for (k=0; k<10; k++) {
    inputs[0][k] = k;
    text_length_chan.write(10);
  }
  for (j=1; j < 5; j++) {
    inputs[j] = (int *) malloc(sizeof(int)*10*j);
    for (k=0; k<10*j; k++)
      inputs[j][k] = k;
      text_length_chan.write(10*j);
  }
  
  int** patterns = (int**) malloc(sizeof(int*)*5);
  patterns[0] = (int *) malloc(sizeof(int)*3);
  for (k=0; k<3; k++) {
    patterns[0][k] = k+1;
  }
  for (j=1; j < 5; j++) {
    patterns[j] = (int *) malloc(sizeof(int)*3);
    for (k=0; k<3; k++)
      patterns[j][k] = j+k;
  }
  pattern_length_chan.write(3);
  
  q_chan.write(q);
  

  // Call actual and reference functions
  for (i=0; i<5; i++) {
    rabinKarpRef(patterns[i], inputs[i], q, (i+1)*10, 3, out_ref);
    for (j=0; j<3; j++) {
      pattern_chan.write(patterns[i][j]);
    }
    
    if (i==0) {
      text_length_chan.write(10);
      for (j=0; j<10; j++) {
        text_chan.write(inputs[i][j]);
      }
    } else {
      text_length_chan.write(i*10);
      for (j=0; j<i*10; j++) {
          text_chan.write(inputs[i][j]);
      }
    }
    
  }
  rabinKarp(pattern_chan, text_chan, q_chan, text_length_chan,
            pattern_length_chan, out_chan );
    
  // Read from output channel
  out_rtl = (int *) malloc(sizeof(int)*(i+1)*10);
  i = 0;
  while (!out_chan.empty()) {
    out_rtl[i] = out_chan.read();
  
    // Check results
    if (out_rtl[i] == -1) {
      printf( "Cosim finished \n");
    } else if ( out_ref[i] != out_rtl[i] ) {
      printf( "ERROR MISMATCH! out_ref = %d, out = %d\n", out_ref[i], out_rtl[i] );
      errCnt++;
    } else {
      printf( "SUCCESS! out_ref = %d, out = %d\n", out_ref[i], out_rtl[i] );
    }
    i++;
  }

  CCS_RETURN( errCnt );
}



