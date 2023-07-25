// Rabin-Karp algorithm in C++

#include <string.h>
#include <iostream>
#include <ac_channel.h>
#include <mc_scverify.h>

using namespace std;

#pragma hls_design top
void CCS_BLOCK(rabinKarp)(ac_channel<int > &pattern, ac_channel<int > &text, 
                ac_channel<int > &q, ac_channel<int > &text_size, 
                ac_channel<int > &pattern_size, ac_channel<int > &out) {
  int m = pattern_size.read();
  int n = text_size.read();
  int i, j, p, t = 0;
  int h = 1;
  int d = 10;
  int q_value = q.read();
  
  int pattern_array[128];
  for (i = 0; i < 1; i++) {
    pattern_array[0] = pattern.read();
  }
  int text_array[128];
  for (j = 0; j < n; j++) {
    text_array[j] = text.read();
  }

  for (i = 0; i < m - 1; i++)
    h = (h * d) % q_value;

  // Calculate hash value for pattern and text
  for (i = 0; i < m; i++) {
    p = (d * p + pattern_array[i]) % q_value;
    t = (d * t + text_array[i]) % q_value;
  }

  // Find the match
  for (i = 0; i <= n - m; i++) {
    if (p == t) {
      for (j = 0; j < m; j++) {
        if (text_array[i + j] != pattern_array[j])
          break;
      }

      if (j == m) {
        cout << "Pattern is found at position: " << i + 1 << endl;
        out.write(i+1);
      }
    }

    if (i < n - m) {
      t = (d * (t - text_array[i] * h) + text_array[i + m]) % q_value;

      if (t < 0)
        t = (t + q_value);
    }
  }
  out.write(-1);
}
