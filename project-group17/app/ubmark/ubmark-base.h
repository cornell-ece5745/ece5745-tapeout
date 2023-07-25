//========================================================================
// ubmark-dtofixed
//========================================================================
// ubmark-dtofixed
#include "common.h"
#include "parameters.dat"
#include "ref_result.dat"

//for debug only
//#include"stdio.h"

#define FIXED_POINT_FRACTIONAL_BITS 16
#define MAX_LEN 32
// #define MAX_VALUE_MULT (1 << (MAX_LEN - 1)) << FIXED_POINT_FRACTIONAL_BITS
#define LAYER3SIZE 10
#define LAYER2SIZE 512
#define LAYER1SIZE 512
#define INPUTSIZE 784


#define ROW_0 3
#define COL_0 3

typedef int fixed_point_t;
struct tuple
{
    int b;
    int value;
} ;

tuple fixed_multiplication(int input1, int input2);
void relu(int num, int* input[]);
tuple fixed_addition(int input1, int input2);
int MLP_1_calc(int* input, int* output, int weight[LAYER1SIZE][INPUTSIZE], int* bias);
int MLP_2_calc(int* input, int* output, int weight[LAYER2SIZE][LAYER1SIZE], int* bias);
int MLP_3_calc(int* input, int* output, int weight[LAYER3SIZE][LAYER2SIZE], int* bias);
