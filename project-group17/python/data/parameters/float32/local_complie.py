import numpy as np
from decimal import Decimal

data_bias1 = np.genfromtxt("./fc1_bias.dat", delimiter = ",")
print("shape of array", data_bias1.shape)

data_bias2 = np.genfromtxt("./fc2_bias.dat", delimiter = ",")
print("shape of array", data_bias2.shape)

data_bias3 = np.genfromtxt("./fc3_bias.dat", delimiter = ",")
print("shape of array", data_bias3.shape)


data_weight1 = np.genfromtxt("./fc1_weights.dat", delimiter = ",").reshape(784, 512)
print("shape of array", data_weight1.shape)

data_weight2 = np.genfromtxt("./fc2_weights.dat", delimiter = ",").reshape(512, 512)
print("shape of array", data_weight2.shape)

data_weight3 = np.genfromtxt("./fc3_weights.dat", delimiter = ",").reshape(512, 10)
print("shape of array", data_weight3.shape)


image_in = np.genfromtxt("../test_images/test_img0_fixed.dat", delimiter = ",")
print("shape of array", image_in.shape)


results1 = np.add(np.matmul(image_in, data_weight1), data_bias1)
results2 = np.add(np.matmul(results1, data_weight2), data_bias2)
results3 = np.add(np.matmul(results2, data_weight3), data_bias3)


print(results3)