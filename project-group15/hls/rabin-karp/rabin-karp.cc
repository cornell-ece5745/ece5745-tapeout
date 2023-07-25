// Rabin-Karp algorithm in C++

#include <string.h>

#include <iostream>
using namespace std;

#define d 10

void rabinKarp(int* pattern, int* text, int q, int text_size, int pattern_size) {
  int m = pattern_size;
  int n = text_size;
  int i, j;
  int p = 0;
  int t = 0;
  int h = 1;

  for (i = 0; i < m - 1; i++)
    h = (h * d) % q;

  // Calculate hash value for pattern and text
  for (i = 0; i < m; i++) {
    p = (d * p + pattern[i]) % q;
    t = (d * t + text[i]) % q;
  }

  // Find the match
  for (i = 0; i <= n - m; i++) {
    if (p == t) {
      for (j = 0; j < m; j++) {
        if (text[i + j] != pattern[j])
          break;
      }

      if (j == m)
        cout << "Pattern is found at position: " << i + 1 << endl;
    }

    if (i < n - m) {
      t = (d * (t - text[i] * h) + text[i + m]) % q;

      if (t < 0)
        t = (t + q);
    }
  }
}

int main() {
  int text[] = {10, 4, 6, 9, 2, 43, 98, 1, 7, 31};
  int pattern[] = {4, 6, 9};
  int q = 13;
  rabinKarp(pattern, text, q, 10, 3);
}