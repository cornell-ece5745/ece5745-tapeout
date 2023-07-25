#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdbool.h>
#include "mlp.c"
#include "../python/data/parameters/parameters.dat"

int main() {
    int overflow;

    int input[INPUTSIZE] = {};
    int layer1[LAYER1SIZE] = {};
    overflow = MLP_1_calc(input, layer1, fc1_weights, fc1_bias);
    printf("layer1 overflow? : %s\n", overflow ? "NO" : "YES");

    relu(LAYER1SIZE, layer1);

    int layer2[LAYER2SIZE] = {};
    overflow = MLP_2_calc(layer1, layer2, fc2_weights, fc2_bias);
    printf("layer2 overflow? : %s\n", overflow ? "NO" : "YES");

    relu(LAYER2SIZE, layer2);

    int layer3[LAYER3SIZE] = {};
    overflow = MLP_3_calc(layer2, layer3, fc3_weights, fc3_bias);
    printf("layer3 nodes are: ");
    for (int i = 0; i < LAYER3SIZE; i++) {
        printf("%f ", fixed_to_double(layer3[i]));
    }
    printf("\n");
    printf("overflow? : %s\n", overflow ? "NO" : "YES");

    relu(LAYER3SIZE, layer3);

    double output [LAYER3SIZE] = {};

    for (int i = 0; i < LAYER3SIZE; i++) {
        output [i] = fixed_to_double(layer3[i]);
    }

    printf("final nodes are: ");
    for (int i = 0; i < LAYER3SIZE; i++) {
        printf("%f ", output[i]);
    }
    printf("\n");
}
