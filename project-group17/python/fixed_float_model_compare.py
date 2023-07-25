import numpy as np
import csv

DECIMAL_WIDTH = 16
THIRD_LAYBER_SIZE=10
TWO_LAYBER_SIZE=512
FIRST_LAYBER_SIZE=512
IMAGE_SIZE=28
INPUT_SIZE=IMAGE_SIZE*IMAGE_SIZE

input_data = np.ones(INPUT_SIZE)

def inference_step_double(input_data, weight0, bias0, relu):
    out0 = np.matmul(weight0, input_data)
    # print(weight0.shape, input_data.shape, out0.shape)
    out0_b = np.add(out0, bias0)
    # print(out0.shape, out0_b.shape)
    # return out0_b
    if relu:
      return np.clip (out0_b, 0, np.inf)
    else:
      return out0_b

def inference_step_fixed(input_data, weight0, bias0, relu):
    weight0_list = list(weight0)
    input_data_list = list(input_data)
    row=len(weight0)
    column=len(weight0[0])
    out = []
    for i in range(row):
      temp_sum = 0
      for j in range(column):
        # print(temp_sum)
        temp = (weight0_list[i][j] * input_data_list[j]) >> DECIMAL_WIDTH
        temp_sum = temp_sum + temp
      out.append(temp_sum)
      # print(out)
    out0 = np.array(out, dtype=np.int32)
    out0_b = np.add(out0, bias0)
    if relu:
      out0_b[out0_b < 0] = 0
      return out0_b
    else:
      return out0_b

def double_inference(input_data, weight0, weight1,    weight2, bias0, bias1, bias2):
    out0 = inference_step_double(input_data, weight0, bias0, True)
    out1 = inference_step_double(out0, weight1, bias1, True)
    out2 = inference_step_double(out1, weight2, bias2, False)
    return out2

def fixed_inference(input_data, weight0, weight1, weight2, bias0, bias1, bias2):
    out0 = inference_step_fixed(input_data, weight0, bias0, True)
    # temp = out0.reshape(-1,1)
    # print(str(weight0[9,:].reshape(-1,1)).replace(' [', '').replace('[', '').replace(']', ''))
    # print(str(out0.reshape(-1,1)).replace(' [', '').replace('[', '').replace(']', ''))
    out1 = inference_step_fixed(out0, weight1, bias1, True)
    # print(str(weight1[0,:].reshape(-1,1)).replace(' [', '').replace('[', '').replace(']', ''))
    # print(str(out1.reshape(-1,1)).replace(' [', '').replace('[', '').replace(']', ''))
    out2 = inference_step_fixed(out1, weight2, bias2, False)
    return out2

#################################################################################################
################################## double read ##################################################
#################################################################################################

data = []
with open('./data/parameters/float64/fc1_double_bias.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])

bias1_double = np.squeeze(np.array(data, dtype=float))

data = []
with open('./data/parameters/float64/fc2_double_bias.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])

bias2_double = np.squeeze(np.array(data, dtype=float))

data = []
with open('./data/parameters/float64/fc3_double_bias.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])

bias3_double = np.squeeze(np.array(data, dtype=float))

data = []
with open('./data/parameters/float64/fc1_double_weights.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])

weights1_double = np.array(data, dtype=float)

data = []
with open('./data/parameters/float64/fc2_double_weights.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])

weights2_double = np.array(data, dtype=float)

data = []
with open('./data/parameters/float64/fc3_double_weights.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])

weights3_double = np.array(data, dtype=float)

#################################################################################################
################################### Fixed read ##################################################
#################################################################################################

data = []
with open('./data/parameters/float64/fc1_fixed_bias_1d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])

bias1_fixed = np.squeeze(np.array(data, dtype=np.int32))

data = []
with open('./data/parameters/float64/fc2_fixed_bias_1d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])

bias2_fixed = np.squeeze(np.array(data, dtype=np.int32))

data = []
with open('./data/parameters/float64/fc3_fixed_bias_1d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])

bias3_fixed = np.squeeze(np.array(data, dtype=np.int32))

data = []
with open('./data/parameters/float64/fc1_fixed_weights_2d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])

weights1_fixed = np.array(data, dtype=np.int32)

data = []
with open('./data/parameters/float64/fc2_fixed_weights_2d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])

weights2_fixed = np.array(data, dtype=np.int32)

data = []
with open('./data/parameters/float64/fc3_fixed_weights_2d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])

weights3_fixed = np.array(data, dtype=np.int32)


#################################################################################################
#################################### inference ##################################################
#################################################################################################

data = []
with open('./data/test_images/float64/test_img0.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([float(i) for i in k])
test_image = np.array(data, dtype=float)
test_image_s = np.squeeze(test_image)

data = []
with open('./data/test_images/float32/test_img0_fixed_1d.dat', 'r') as f:
  d = f.readlines()
  for i in d:
    k = i.rstrip().split(",")
    data.append([int(i) for i in k])
test_image_fixed = np.array(data, dtype=np.int32)
test_image_fixed_s = np.squeeze(test_image_fixed)

print("fixed model fixed output:")
out = fixed_inference(test_image_fixed_s, weights1_fixed, weights2_fixed, weights3_fixed, bias1_fixed, bias2_fixed, bias3_fixed)
print(out)
print(type(out[0]))
print("fixed model double output:")
out = fixed_inference(test_image_fixed_s, weights1_fixed, weights2_fixed, weights3_fixed, bias1_fixed, bias2_fixed, bias3_fixed)
print(out.astype(float)/(2**16))
out = double_inference(test_image_s, weights1_double, weights2_double, weights3_double, bias1_double, bias2_double, bias3_double)
print("double model double output:")
print(out)

# data = []
# with open('./data/parameters/test/fc1_784x10_double_bias.dat', 'r') as f:
#   d = f.readlines()
#   for i in d:
#     k = i.rstrip().split(",")
#     data.append([float(i) for i in k])

# bias =  np.squeeze(np.array(data, dtype=float))
# bias_fixed = np.floor(bias * (2**DECIMAL_WIDTH))

# data = []
# with open('./data/parameters/test/fc1_784x10_double_weights.dat', 'r') as f:
#   d = f.readlines()
#   for i in d:
#     k = i.rstrip().split(",")
#     data.append([float(i) for i in k])

# weights =  np.squeeze(np.array(data, dtype=float))
# weights_fixed = np.floor(weights * (2**DECIMAL_WIDTH))
# # np.savetxt('weights.csv',weights,delimiter=",")


# out = inference_step_double(test_image_s, weights, bias)
# print(out)
# out = inference_step_fixed(test_image_s_fixed, weights_fixed, bias_fixed)
# print(out/(2**DECIMAL_WIDTH))
