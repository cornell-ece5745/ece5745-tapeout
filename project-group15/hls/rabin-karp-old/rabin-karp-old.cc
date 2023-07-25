#include <iostream>
#include <string>

using namespace std;

const int P_B = 227;
const int P_M = 1000005;

int hash( int* input, int size ) {
  int r = 0;
  for (int i = 0; i < size; i++) {
    r = r* P_B + input[i];
    r %= P_M;
  }
  return r;
}

int rabin_karp_ref( int* find_, int* input, int size2, int size1 ) {
  int h1 = hash(find_, size1);
  int h2 = 0;
  int power = 1;
  for (int i = 0; i < size1; i++) {
    power = (power * P_B) % P_M;
  }
  for (int i = 0; i < size2; i++) {
    h2 = h2*P_B + input[i];
    h2 %= P_M;
    if (i >= size1) {
      h2 -= power * input[i-size1] % P_M;
      if (h2 < 0)
      h2 += P_M;
    }
    if (i >= size1-1 && h1 == h2)
      return i - (size1-1);
  }
  return -1;
}

int main() {
  int s1[] = {1, 2, 3, 4, 5};
  int s2[] = {2};
  if(rabin_karp_ref(s2, s1, 5, 1) == -1)
    cout<<"String not found"<<endl;
  else
    cout << "String " << s2 << " found at position " << rabin_karp_ref(s2, s1, 5, 1) << endl;
  return 0;
}