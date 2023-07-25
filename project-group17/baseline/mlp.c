#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdbool.h>
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
		if (temp >= MAX_VALUE_ADD | temp <= -MAX_VALUE_ADD) {
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

int relu(int num, int* input){
	for(int i = 0; i < num; i++){
		if(input[i] < 0){
            input[i] = 0;
		}
	}
}

tuple fixed_multiplication(int input1, int input2) {
		int temp;
		temp = input1 * input2;
		int overflow;
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

int double_to_fixed(double input);
inline int double_to_fixed(double input) {
    return (int)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

void double_to_fixed_arr(int col, int row, double input[row][col],int arr_out[row][col]);
void double_to_fixed_arr(int col, int row, double input[row][col],int arr_out[row][col]) {
    for (int i = 0; i < row; i++) {
        for (int j = 0; j < col; j++) {
            if(row == 1){
                printf("%f\n",input[i][j]);
            }
            else{
                printf("%f ", input[i][j]);
                if (j == col-1){
                    printf("\n");
                }
            }
            arr_out[i][j] = double_to_fixed(input[i][j]);
        }
    }
    printf("\n");
}

double fixed_to_double(int input);
double fixed_to_double(int input) {
    double temp;
    temp = input;
    return temp / (1 << FIXED_POINT_FRACTIONAL_BITS);
}