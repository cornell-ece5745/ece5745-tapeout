import numpy as np
import os
from decimal import Decimal
# from fxpmath import Fxp

castNum = input("Enter your intended cast: ")
flatFlag = input("Will you need flatten: ")

flatFlag = int(flatFlag)

data_weight_0 = np.genfromtxt("./fc1_double_weights.dat", delimiter = ",")
data_weight_1 = np.genfromtxt("./fc2_double_weights.dat", delimiter = ",")
data_weight_2 = np.genfromtxt("./fc3_double_weights.dat", delimiter = ",")

data_bias_0 = np.genfromtxt("./fc1_double_weights.dat", delimiter = ",")
data_bias_1 = np.genfromtxt("./fc2_double_weights.dat", delimiter = ",")
data_bias_2 = np.genfromtxt("./fc3_double_weights.dat", delimiter = ",")

image = np.genfromtxt("./test_img0.dat", delimiter = ",")


# data = list(data_in)
# data = np.array([data_list]).T
print(type(data_weight_0))
print("shape of data_weight_0", data_weight_0.shape)
print("shape of data_weight_1", data_weight_1.shape)
print("shape of data_weight_2", data_weight_2.shape)

print("shape of data_bias_0", data_bias_0.shape)
print("shape of data_bias_1", data_bias_1.shape)
print("shape of data_bias_2", data_bias_2.shape)

print("First 5 rows data_weight_0:\n", data_weight_0[:5])
print("First 5 rows data_weight_1:\n", data_weight_1[:5])
print("First 5 rows data_weight_2:\n", data_weight_2[:5])

print("First 5 rows data_bias_0:\n", data_bias_0[:5])
print("First 5 rows data_bias_1:\n", data_bias_1[:5])
print("First 5 rows data_bias_2:\n", data_bias_2[:5])

# data = data.astype('int32')
castNumInt = int(castNum)
data_weight_0 = data_weight_0*(2**castNumInt)
data_weight_1 = data_weight_1*(2**castNumInt)
data_weight_2 = data_weight_2*(2**castNumInt)

data_bias_0 = data_bias_0*(2**castNumInt)
data_bias_1 = data_bias_1*(2**castNumInt)
data_bias_2 = data_bias_2*(2**castNumInt)

image = image*(2**castNumInt)

data_weight_0 = np.round(data_weight_0, 0)
data_weight_1 = np.round(data_weight_1, 0)
data_weight_2 = np.round(data_weight_2, 0)

data_bias_0 = np.round(data_bias_0, 0)
data_bias_1 = np.round(data_bias_1, 0)
data_bias_2 = np.round(data_bias_2, 0)

image = np.round(image, 0)

os.makedirs(os.path.dirname("./" + str(castNum) + '/'), exist_ok=True)


if flatFlag:
    
    
    data_weight_0 = data_weight_0.flatten()
    print("shape of array", data_weight_0.shape)
    print("First 5 rows:\n", data_weight_0[:5])
    
    np.savetxt('./' + str(castNum) + '/fc1_fixed_weights_1d.dat', data_weight_0, fmt='%d', newline = ", ")
    
    data_weight_1 = data_weight_1.flatten()
    print("shape of array", data_weight_1.shape)
    print("First 5 rows:\n", data_weight_1[:5])
    
    np.savetxt('./' + str(castNum) + '/fc2_fixed_weights_1d.dat', data_weight_1, fmt='%d', newline = ", ")
    
    data_weight_2 = data_weight_2.flatten()
    print("shape of array", data_weight_2.shape)
    print("First 5 rows:\n", data_weight_2[:5])
    
    np.savetxt('./' + str(castNum) + '/fc3_fixed_weights_1d.dat', data_weight_2, fmt='%d', newline = ", ")
    
    data_bias_0 = data_bias_0.flatten()
    print("shape of array", data_bias_0.shape)
    print("First 5 rows:\n", data_bias_0[:5])
    
    np.savetxt('./' + str(castNum) + '/fc1_fixed_bias_1d.dat', data_bias_0, fmt='%d', newline = ", ")
    
    data_bias_1 = data_bias_1.flatten()
    print("shape of array", data_bias_1.shape)
    print("First 5 rows:\n", data_bias_1[:5])
    
    np.savetxt('./' + str(castNum) + '/fc2_fixed_bias_1d.dat', data_bias_1, fmt='%d', newline = ", ")
    
    data_bias_2 = data_bias_2.flatten()
    print("shape of array", data_bias_2.shape)
    print("First 5 rows:\n", data_bias_2[:5])
    
    np.savetxt('./' + str(castNum) + '/fc3_fixed_bias_1d.dat', data_bias_2, fmt='%d', newline = ", ")
    
    image = image.flatten()
    np.savetxt("./" + str(castNum) + "/test_img0_1d.dat", image, fmt='%d', newline = ", ")
    
else:
    # data_weight_0 = data_weight_0.flatten()
    print("shape of array", data_weight_0.shape)
    print("First 5 rows:\n", data_weight_0[:5])
    
    np.savetxt('./' + str(castNum) + '/fc1_fixed_weights_2d.dat', data_weight_0, fmt='%d', delimiter = ", ")

    
    # data_weight_1 = data_weight_1.flatten()
    print("shape of array", data_weight_1.shape)
    print("First 5 rows:\n", data_weight_1[:5])
    
    np.savetxt('./' + str(castNum) + '/fc2_fixed_weights_2d.dat', data_weight_1, fmt='%d', delimiter = ", ")

    
    # data_weight_2 = data_weight_2.flatten()
    print("shape of array", data_weight_2.shape)
    print("First 5 rows:\n", data_weight_2[:5])
    np.savetxt('./' + str(castNum) + '/fc3_fixed_weights_2d.dat', data_weight_2, fmt='%d', delimiter = ", ")

    
    # data_bias_0 = data_bias_0.flatten()
    print("shape of array", data_bias_0.shape)
    print("First 5 rows:\n", data_bias_0[:5])
    np.savetxt('./' + str(castNum) + '/fc1_fixed_bias_2d.dat', data_bias_0, fmt='%d', delimiter = ", ")

    
    # data_bias_1 = data_bias_1.flatten()
    print("shape of array", data_bias_1.shape)
    print("First 5 rows:\n", data_bias_1[:5])
    
    np.savetxt('./' + str(castNum) + '/fc2_fixed_bias_2d.dat', data_bias_0, fmt='%d', delimiter = ", ")

    # data_bias_2 = data_bias_2.flatten()
    print("shape of array", data_bias_2.shape)
    print("First 5 rows:\n", data_bias_2[:5])
    np.savetxt('./' + str(castNum) + '/fc2_fixed_bias_2d.dat', data_bias_0, fmt='%d', delimiter = ", ")

    np.savetxt("./" + str(castNum) + "/test_img0_2d.dat", image, fmt='%d', delimiter = ", ")


    

#Use newline = ", " for 1D array
# np.savetxt('../float64/fc1_fixed_weights.dat', data_fxp, fmt='%d', newline = ", ")