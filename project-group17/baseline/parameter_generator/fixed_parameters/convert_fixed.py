import numpy as np
import os
from decimal import Decimal
import sys
import argparse


NUM_ARGV_EXPECTED = 3
ARG_NAME = ['castNum', 'flatFlag', 'imgnum']
ARG_TYPES = [int, int, int]
METAVARS = ['fw', 'ff', 'in']
DESCRIPTIONS = ['width of fraction part in fixed point', 'generate 2d or 1d .dat', 'number of test images']

if len(ARG_NAME) != NUM_ARGV_EXPECTED:
    print ('ARG_NAME initialization error!');
    sys.exit(1)
if len(ARG_TYPES) != NUM_ARGV_EXPECTED:
    print ('ARG_TYPES initialization error!');
    sys.exit(1)
if len(METAVARS) != NUM_ARGV_EXPECTED:
    print ('METAVARS initialization error!');
    sys.exit(1)
if len(DESCRIPTIONS) != NUM_ARGV_EXPECTED:
    print ('DESCRIPTIONS initialization error!');
    sys.exit(1)

parser=argparse.ArgumentParser(
    description="Description")
for i in range(0,NUM_ARGV_EXPECTED):
    parser.add_argument(ARG_NAME[i], metavar=METAVARS[i], type=ARG_TYPES[i], help=DESCRIPTIONS[i])
args=parser.parse_args()

data_weight_0 = np.genfromtxt("../trained_parameters/fc1_double_weights.dat", delimiter = ",")
data_weight_1 = np.genfromtxt("../trained_parameters/fc2_double_weights.dat", delimiter = ",")
data_weight_2 = np.genfromtxt("../trained_parameters/fc3_double_weights.dat", delimiter = ",")

data_bias_0 = np.genfromtxt("../trained_parameters/fc1_double_bias.dat", delimiter = ",")
data_bias_1 = np.genfromtxt("../trained_parameters/fc2_double_bias.dat", delimiter = ",")
data_bias_2 = np.genfromtxt("../trained_parameters/fc3_double_bias.dat", delimiter = ",")

image = []
for i in range(args.imgnum):
    image.append(np.genfromtxt("../test_images/val_img"+str(i)+".dat", delimiter = ","))


# data = list(data_in)
# data = np.array([data_list]).T
# print(type(data_weight_0))
# print("shape of data_weight_0", data_weight_0.shape)
# print("shape of data_weight_1", data_weight_1.shape)
# print("shape of data_weight_2", data_weight_2.shape)

# print("shape of data_bias_0", data_bias_0.shape)
# print("shape of data_bias_1", data_bias_1.shape)
# print("shape of data_bias_2", data_bias_2.shape)

# print("First 5 rows data_weight_0:\n", data_weight_0[:5])
# print("First 5 rows data_weight_1:\n", data_weight_1[:5])
# print("First 5 rows data_weight_2:\n", data_weight_2[:5])

# print("First 5 rows data_bias_0:\n", data_bias_0[:5])
# print("First 5 rows data_bias_1:\n", data_bias_1[:5])
# print("First 5 rows data_bias_2:\n", data_bias_2[:5])

# data = data.astype('int32')
castNumInt = int(args.castNum)
data_weight_0 = data_weight_0*(2**castNumInt)
data_weight_1 = data_weight_1*(2**castNumInt)
data_weight_2 = data_weight_2*(2**castNumInt)

data_bias_0 = data_bias_0*(2**castNumInt)
data_bias_1 = data_bias_1*(2**castNumInt)
data_bias_2 = data_bias_2*(2**castNumInt)

data_weight_0 = np.round(data_weight_0, 0)
data_weight_1 = np.round(data_weight_1, 0)
data_weight_2 = np.round(data_weight_2, 0)

data_bias_0 = np.round(data_bias_0, 0)
data_bias_1 = np.round(data_bias_1, 0)
data_bias_2 = np.round(data_bias_2, 0)

for i in range(args.imgnum):
    image[i] = image[i]*(2**castNumInt)
    image[i] = np.round(image[i], 0)

os.makedirs(os.path.dirname("./" + str(args.castNum) + '/'), exist_ok=True)


if args.flatFlag:
    
    data_weight_0 = data_weight_0.flatten()
    # data_weight_0 = np.array(temp)
    # print("shape of array", data_weight_0.shape)
    # print("First 5 rows:\n", data_weight_0[:5])
    # print(data_weight_0.shape)
    # print(type(data_weight_0))
    PATH = './' + str(args.castNum) + '/fc1_fixed_weights_1d.dat'
    np.savetxt(PATH, data_weight_0, fmt='%d,', delimiter = ", ", newline = "")
    x = open(PATH).read()
    xp = x[:-1]
    text_file = open(PATH, "w")
    n = text_file.write(xp)
    text_file.close()
    
    data_weight_1 = data_weight_1.flatten()
    # print("shape of array", data_weight_1.shape)
    # print("First 5 rows:\n", data_weight_1[:5])
    
    PATH = './' + str(args.castNum) + '/fc2_fixed_weights_1d.dat'
    np.savetxt(PATH, data_weight_1, fmt='%d,', newline = "")
    x = open(PATH).read()
    xp = x[:-1]
    text_file = open(PATH, "w")
    n = text_file.write(xp)
    text_file.close()
    
    data_weight_2 = data_weight_2.flatten()
    # print("shape of array", data_weight_2.shape)
    # print("First 5 rows:\n", data_weight_2[:5])
    
    PATH = './' + str(args.castNum) + '/fc3_fixed_weights_1d.dat'
    np.savetxt(PATH, data_weight_2, fmt='%d,', newline = "")
    x = open(PATH).read()
    xp = x[:-1]
    text_file = open(PATH, "w")
    n = text_file.write(xp)
    text_file.close()
    
    data_bias_0 = data_bias_0.flatten()
    # print("shape of array", data_bias_0.shape)
    # print("First 5 rows:\n", data_bias_0[:5])
    
    PATH = './' + str(args.castNum) + '/fc1_fixed_bias_1d.dat'
    np.savetxt(PATH, data_bias_0, fmt='%d,', newline = "")
    x = open(PATH).read()
    xp = x[:-1]
    text_file = open(PATH, "w")
    n = text_file.write(xp)
    text_file.close()
    
    data_bias_1 = data_bias_1.flatten()
    # print("shape of array", data_bias_1.shape)
    # print("First 5 rows:\n", data_bias_1[:5])
    
    PATH = './' + str(args.castNum) + '/fc2_fixed_bias_1d.dat'
    np.savetxt(PATH, data_bias_1, fmt='%d,', newline = "")
    x = open(PATH).read()
    xp = x[:-1]
    text_file = open(PATH, "w")
    n = text_file.write(xp)
    text_file.close()
    
    data_bias_2 = data_bias_2.flatten()
    # print("shape of array", data_bias_2.shape)
    # print("First 5 rows:\n", data_bias_2[:5])
    
    PATH = './' + str(args.castNum) + '/fc3_fixed_bias_1d.dat'
    np.savetxt(PATH, data_bias_2, fmt='%d,', newline = "")
    x = open(PATH).read()
    xp = x[:-1]
    text_file = open(PATH, "w")
    n = text_file.write(xp)
    text_file.close()

    for i in range(args.imgnum):
        PATH = "./" + str(args.castNum) + "/test_img" + str(i) + "_1d.dat"
        np.savetxt(PATH, image[i], fmt='%d,', newline = "")
        x = open(PATH).read()
        xp = x[:-1]
        text_file = open(PATH, "w")
        n = text_file.write(xp)
        text_file.close()
    
else:
    # data_weight_0 = data_weight_0.flatten()
    # print("shape of array", data_weight_0.shape)
    # print("First 5 rows:\n", data_weight_0[:5])
    
    np.savetxt('./' + str(args.castNum) + '/fc1_fixed_weights_2d.dat', data_weight_0, fmt='%d', delimiter = ", ")

    
    # data_weight_1 = data_weight_1.flatten()
    # print("shape of array", data_weight_1.shape)
    # print("First 5 rows:\n", data_weight_1[:5])
    
    np.savetxt('./' + str(args.castNum) + '/fc2_fixed_weights_2d.dat', data_weight_1, fmt='%d', delimiter = ", ")

    
    # data_weight_2 = data_weight_2.flatten()
    # print("shape of array", data_weight_2.shape)
    # print("First 5 rows:\n", data_weight_2[:5])
    np.savetxt('./' + str(args.castNum) + '/fc3_fixed_weights_2d.dat', data_weight_2, fmt='%d', delimiter = ", ")

    
    # data_bias_0 = data_bias_0.flatten()
    # print("shape of array", data_bias_0.shape)
    # print("First 5 rows:\n", data_bias_0[:5])
    np.savetxt('./' + str(args.castNum) + '/fc1_fixed_bias_2d.dat', data_bias_0, fmt='%d', delimiter = ", ")

    
    # data_bias_1 = data_bias_1.flatten()
    # print("shape of array", data_bias_1.shape)
    # print("First 5 rows:\n", data_bias_1[:5])
    
    np.savetxt('./' + str(args.castNum) + '/fc2_fixed_bias_2d.dat', data_bias_0, fmt='%d', delimiter = ", ")

    # data_bias_2 = data_bias_2.flatten()
    # print("shape of array", data_bias_2.shape)
    # print("First 5 rows:\n", data_bias_2[:5])
    np.savetxt('./' + str(args.castNum) + '/fc2_fixed_bias_2d.dat', data_bias_0, fmt='%d', delimiter = ", ")

    for i in range(args.imgnum):
        np.savetxt("./" + str(args.castNum) + "/test_img" + str(i) + "_2d.dat", image[i], fmt='%d', delimiter = ", ")


    

#Use newline = ", " for 1D array
# np.savetxt('../float64/fc1_fixed_weights.dat', data_fxp, fmt='%d', newline = ", ")