// ubmark-dtofixed

#include "common.h"
#include "parameters.dat"

#define FIXED_POINT_FRACTIONAL_BITS 5
#define MAX_LEN 16
#define MAX_VALUE_MULT (1 << (MAX_LEN - 1)) << FIXED_POINT_FRACTIONAL_BITS
#define MAX_VALUE_ADD (1 << (MAX_LEN - 1))
#define LAYER3SIZE 10
#define LAYER2SIZE 512
#define LAYER1SIZE 512
#define INPUTSIZE 784

//struct
typedef struct
{
    int b;
    int value;
} tuple;

tuple fixed_addition(int input1, int input2) {
		int temp;
		temp = input1 + input2;
		if ((temp >= MAX_VALUE_ADD) | (temp <= -MAX_VALUE_ADD)) {
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

void relu(int num, int* input){
	for(int i = 0; i < num; i++){
		if(input[i] < 0){
            input[i] = 0;
		}
	}
}

tuple fixed_multiplication(int input1, int input2) {
		int temp;
		temp = input1 * input2;
		if ((temp >= MAX_VALUE_MULT) | (temp <= -MAX_VALUE_MULT)) {
				int result;
				result = temp >> FIXED_POINT_FRACTIONAL_BITS;
				tuple arr;
				arr.b = 1;
				arr.value = result;
				return arr;
		}
		else
		{
				int result;
				result = temp >> FIXED_POINT_FRACTIONAL_BITS;
				tuple arr;
				arr.b = 0;
				arr.value = result;
				return arr;
		}
}

int MLP_1_calc(int* input, int* output, int weight[INPUTSIZE][LAYER1SIZE], int* bias) {
    tuple result;
    for (int j = 0; j < LAYER1SIZE; j++) {
        output[j] = 0;
        for (int i = 0; i < INPUTSIZE; i++) {
            result = fixed_multiplication(input[i], weight[i][j]);
            if (result.b == 1)
                return 0;
            else {
                result = fixed_addition(output[j], result.value);
                if (result.b == 1)
                    return 0;
                else
                    output[j] = result.value;
            }
        }
        result = fixed_addition(output[j], bias[j]);
        if (result.b == 1)
            return 0;
        else
            output[j] = result.value;
    }
    return 1;
}

int MLP_2_calc(int* input, int* output, int weight[LAYER1SIZE][LAYER2SIZE], int* bias) {
    tuple result;
    for (int j = 0; j < LAYER2SIZE; j++) {
        output[j] = 0;
        for (int i = 0; i < LAYER1SIZE; i++) {
            result = fixed_multiplication(input[i], weight[i][j]);
            if (result.b == 1)
                return 0;
            else {
                result = fixed_addition(output[j], result.value);
                if (result.b == 1)
                    return 0;
                else
                    output[j] = result.value;
            }
        }
        result = fixed_addition(output[j], bias[j]);
        if (result.b == 1)
            return 0;
        else
            output[j] = result.value;
    }
    return 1;
}

int MLP_3_calc(int* input, int* output, int weight[LAYER2SIZE][LAYER3SIZE], int* bias) {
    tuple result;
    for (int j = 0; j < LAYER3SIZE; j++) {
        output[j] = 0;
        for (int i = 0; i < LAYER2SIZE; i++) {
            result = fixed_multiplication(input[i], weight[i][j]);
            if (result.b == 1)
                return 0;
            else {
                result = fixed_addition(output[j], result.value);
                if (result.b == 1)
                    return 0;
                else
                    output[j] = result.value;
            }
        }
        result = fixed_addition(output[j], bias[j]);
        if (result.b == 1)
            return 0;
        else
            output[j] = result.value;
    }
    return 1;
}


int main() {
    int overflow;

    int input[INPUTSIZE] = {};
    int layer1[LAYER1SIZE] = {};
    overflow = MLP_1_calc(input, layer1, fc1_weights, fc1_bias);
   
    // relu(LAYER1SIZE, layer1);

    int layer2[LAYER2SIZE] = {};
    overflow = MLP_2_calc(layer1, layer2, fc2_weights, fc2_bias);
   

    // relu(LAYER2SIZE, layer2);

    int layer3[LAYER3SIZE] = {};
    overflow = MLP_3_calc(layer2, layer3, fc3_weights, fc3_bias);
    

    // relu(LAYER3SIZE, layer3);
   return overflow;
}
