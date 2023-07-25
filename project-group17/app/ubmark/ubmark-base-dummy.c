#include "ubmark-base.h"
#include "common.h"


//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{   
  int load_data[1568];
  int load_weight[1568];
  int i;
  for(i=0; i<1568; i++) {
    load_data[i] = input_2[i];
    load_weight[i] = weight_2[i];
  }
  test_pass();

}
