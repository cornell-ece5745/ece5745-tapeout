#include "ubmark-base.h"

tuple fixed_addition(int input1, int input2) {
  int temp;
  temp = input1 + input2;
  if ((temp > 0 && input1 < 0 && input2 < 0) || (temp < 0 && input1 > 0 && input2 > 0)) {
    int result;
    result = temp;
    tuple arr;
    arr.b = 1;
    arr.value = result;
    return arr;
  }
  else
  {
    int result;
    result = temp;
    tuple arr;
    arr.b = 0;
    arr.value = result;
    return arr;
  }
}

// void relu(int num, int* input){
// 	for(int i = 0; i < num; i++){
// 		if(input[i] >= 0){
// 		}
// 		else{
// 			input[i] = 0;
// 		}
// 	}
// }


tuple fixed_multiplication(int input1, int input2) {
  // int temp;
  // temp = input1 * input2;
  //int overflow;
  // if ((temp >= MAX_VALUE_MULT) | (temp <= -MAX_VALUE_MULT)) {
  //   int result;
  //   result = temp >> FIXED_POINT_FRACTIONAL_BITS;
  //   tuple arr;
  //   arr.b = 1;
  //   arr.value = result;
  //   return arr;
  // }
  // else
  // {
  //   int result;
  //   result = temp >> FIXED_POINT_FRACTIONAL_BITS;
  //   tuple arr;
  //   arr.b = 0;
  //   arr.value = result;
  //   return arr;
  // }
  int input1_shifted, input2_shifted;
  input1_shifted = input1;
  input2_shifted = input2;
  int temp, result;
  temp = (input1_shifted*input2_shifted);
  result = temp >> FIXED_POINT_FRACTIONAL_BITS;
  tuple arr;
  arr.b = 0;
  arr.value = result;
  return arr;
}

// int MLP_1_calc(int* input, int* output, int weight[LAYER1SIZE][INPUTSIZE], int* bias) {
//   tuple result;
//   for (int j = 0; j < LAYER1SIZE; j++) {
//     output[j] = 0;
//     for (int i = 0; i < INPUTSIZE; i++) {
//       result = fixed_multiplication(input[i], weight[j][i]);
//       // if (j == 9)
//       //   printf("%d                                                         ", result.value);
//     //     printf("%d, %d, %d, ", input[i], weight[j][i], result.value);
//       if (result.b == 1)
//           return 0;
//       else {
//         tuple temp;
//         temp = fixed_addition(output[j], result.value);
//         // if (j == 9)
//         //   printf("%d\n", temp.value);
//         //     printf("%d, %d, %d\n", output[j], result.value, temp.value);
//         if (temp.b == 1)
//           return 0;
//         else
//           output[j] = temp.value;
//       }
//     }
//     result = fixed_addition(output[j], bias[j]);
//     // if (j == 5)
//     //     printf("%d, %d, %d, %d, %d, %d\n", 0,0,0, output[j], bias[j], result.value);
//     if (result.b == 1)
//       return 0;
//     else
//       output[j] = result.value;
//   }
//   return 1;
// }

// int MLP_2_calc(int* input, int* output, int weight[LAYER2SIZE][LAYER1SIZE], int* bias) {
//     tuple result;
//     for (int j = 0; j < LAYER2SIZE; j++) {
//         output[j] = 0;
//         for (int i = 0; i < LAYER1SIZE; i++) {
//             result = fixed_multiplication(input[i], weight[j][i]);
//             // if (j == 5)
//             //     printf("%d, %d, %d, ", input[i], weight[j][i], result.value);
//             if (result.b == 1)
//                 return 0;
//             else {
//                 tuple temp;
//                 temp = fixed_addition(output[j], result.value);
//                 // if (j == 5)
//                 //     printf("%d, %d, %d\n", output[j], result.value, temp.value);
//                 if (temp.b == 1)
//                     return 0;
//                 else
//                     output[j] = temp.value;
//             }
//         }
//         result = fixed_addition(output[j], bias[j]);
//         // if (j == 5)
//         //     printf("%d, %d, %d, %d, %d, %d\n", 0,0,0, output[j], bias[j], result.value);
//         if (result.b == 1)
//             return 0;
//         else
//             output[j] = result.value;
//     }
//     return 1;
// }

// int MLP_3_calc(int* input, int* output, int weight[LAYER3SIZE][LAYER2SIZE], int* bias) {
//     tuple result;
//     for (int j = 0; j < LAYER3SIZE; j++) {
//         output[j] = 0;
//         for (int i = 0; i < LAYER2SIZE; i++) {
//             result = fixed_multiplication(input[i], weight[j][i]);
//             // if (j == 5)
//             //     printf("%d, %d, %d, ", input[i], weight[j][i], result.value);
//             if (result.b == 1)
//                 return 0;
//             else {
//                 tuple temp;
//                 temp = fixed_addition(output[j], result.value);
//                 // if (j == 5)
//                 //     printf("%d, %d, %d\n", output[j], result.value, temp.value);
//                 if (temp.b == 1)
//                     return 0;
//                 else
//                     output[j] = temp.value;
//             }
//         }
//         result = fixed_addition(output[j], bias[j]);
//         // if (j == 5)
//         //     printf("%d, %d, %d, %d, %d, %d\n", 0,0,0, output[j], bias[j], result.value);
//         if (result.b == 1)
//             return 0;
//         else
//             output[j] = result.value;
//     }
//     return 1;
// }

int MLP_fixed2_calc(int input[1568], int* output, int weight[1568]) {
    tuple result;

    // int input_temp[1568];
    // int counter = 1;
    // for (int i=0; i<1568; i++){
    //   if (counter){
    //     input_temp[i/2] = input[i];
    //     counter = 0;
    //   }
    //   else{
    //     input_temp[784+(i-1)/2] = input[i];
    //     counter = 1;
    //   }
    // }
    // input = input_temp; 

    for (int j = 0; j < 2; j++) {
        for (int i = 0; i < 2; i++) {
          output[2*j+i] = 0;
          for (int k = 0; k < 784; k++){
              result = fixed_multiplication(weight[k+784*j], input[i+2*k]);
              // if (j == 5)
              // printf("%d, %d, %d, %d ", output[0], output[1], output[2], output[3]);
              // printf("%d\n", result.value);
              if (result.b == 1)
                  return 0;
              else {
                  tuple temp;
                  temp = fixed_addition(output[2*j+i], result.value);
                  // if (j == 5)
                  //     printf("%d, %d, %d\n", output[j], result.value, temp.value);
                  if (temp.b == 1)
                      return 0;
                  else
                      output[2*j+i] = temp.value;
              }
          }
            
        }
    }
    return 1;
}

// int MLP_mini_calc(int input[8], int* output, int weight[8]) {
//     tuple result;

//     for (int j = 0; j < 2; j++) {
//         for (int i = 0; i < 2; i++) {
//           output[2*j+i] = 0;
//           for (int k = 0; k < 4; k++){
//               result = fixed_multiplication(weight[k+4*j], input[i+2*k]);
//               // if (j == 5)
//               // printf("%d, %d, %d, %d ", output[0], output[1], output[2], output[3]);
//               // printf("%d\n", result.value);
//               if (result.b == 1)
//                   return 0;
//               else {
//                   tuple temp;
//                   temp = fixed_addition(output[2*j+i], result.value);
//                   // if (j == 5)
//                   //     printf("%d, %d, %d\n", output[j], result.value, temp.value);
//                   if (temp.b == 1)
//                       return 0;
//                   else
//                       output[2*j+i] = temp.value;
//               }
//           }
            
//         }
//     }
//     return 1;
// }

//------------------------------------------------------------------------
// baseline
//------------------------------------------------------------------------
//  __attribute__ ((noinline))

// int baseline(int input[], int layer3[LAYER3SIZE])
// {
//    	int overflow;
//     overflow = 0;
//     int layer1[LAYER1SIZE];
//     for(int k = 0; k<LAYER1SIZE; k++) {
//         layer1[k] = 0;
//     }
//     overflow = MLP_1_calc(input, layer1, fc1_weights, fc1_bias);
//     relu(LAYER1SIZE, layer1);

//     int layer2[LAYER2SIZE];
//     for(int n = 0; n<LAYER2SIZE; n++) {
//         layer2[n] = 0;
//     }
//     overflow = MLP_2_calc(layer1, layer2, fc2_weights, fc2_bias);
//     relu(LAYER2SIZE, layer2);

//     overflow = MLP_3_calc(layer2, layer3, fc3_weights, fc3_bias);

//     return overflow;
// }

// //------------------------------------------------------------------------
// // verify result
// //------------------------------------------------------------------------
// void verify_results( int dest[], int ref[], int size )
// {
// 	for ( int i = 0; i < size; i++ ) {
// 		if ( !( dest[i] == ref[i] ) )
// 			test_fail( i, dest[i], ref[i] );          
//     }
//   test_pass();
// }


//------------------------------------------------------------------------
// Test Case
//------------------------------------------------------------------------
// void test_case(int input[], int ref[])
// {
//   int out[LAYER3SIZE];
//   baseline(input, out);
//   //verify_results(out, ref, 10);
// }

//------------------------------------------------------------------------
// Test Case Output 2*2
//------------------------------------------------------------------------
void test_case2x2(int input[1568], int weight[1568], int ref[4])
{
  int out[4];
  MLP_fixed2_calc(input, out, weight);
  //printf("%d, %d, %d, %d\n", out[0], out[1], out[2], out[3]);
  //printf("%d, %d, %d, %d\n", ref[0], ref[1], ref[2], ref[3]);
  //verify_results(out, ref, 4);
}

//------------------------------------------------------------------------
// Test Case Mini
//------------------------------------------------------------------------
// void test_case_mini(int input[8], int weight[8], int ref[4])
// {
//   int out[4];
//   MLP_mini_calc(input, out, weight);
//   //printf("%d, %d, %d, %d\n", out[0], out[1], out[2], out[3]);
//   //printf("%d, %d, %d, %d\n", ref[0], ref[1], ref[2], ref[3]);
//   //verify_results(out, ref, 4);
// }

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{   
  
    // test_case(input_0,ref_result_0);
    test_case2x2(weight_2, input_2, ref_result_2);
    //test_case_mini(weight_mini, input_mini, ref_result_mini);
    // printf("%d\n", ref_result_1[0]);
    // test_case(input_1,ref_result_1);
    // test_case(input_2,ref_result_2);
    // test_case(input_3,ref_result_3);
    // test_case(input_4,ref_result_4);
    // test_case(input_5,ref_result_5);
    // test_case(input_6,ref_result_6);
    // test_case(input_7,ref_result_7);
    // test_case(input_8,ref_result_8);
    // test_case(input_9,ref_result_9);
    // test_case(input_10,ref_result_10);
    test_pass();

}
