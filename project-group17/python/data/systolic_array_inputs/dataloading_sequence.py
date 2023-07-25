# ======================================================
# dataloading_sequence.py:
# Generates the ordered data for input buffer of the 
# systolic array so that each file is directly read
# into each input buffer
#
# Currently, only weights are supported
# ======================================================

import sys
import numpy as np
from numpy.testing import assert_array_equal

# Load file
FILEDIM = 1         # {1, 2} = 1-dim or 2-dim
FILEPATH = "/home/ja499/ece5745/project-group17/baseline/parameter_generator/fixed_parameters/16/fc1_fixed_weights_1d.dat"
FILETYPE = "weight" # {weight, bias, input}
LAYERNUM = 1        # {1, 2, 3} where layer 1 is the first layer (nn.Linear(28*28, 512))

# Save file
FILESAVEDIR = "/home/ja499/ece5745/project-group17/python/data/systolic_array_inputs/fixed_point"
FILESAVENAME = "fc1_fixed"    # will be saved in the format: "pe{x}_{FILESAVENAME}.dat" where x = {0, 1}

# Reading in files
if FILEDIM == 1: 
  print("file contains 1D array")
  data = np.genfromtxt(FILEPATH, delimiter=",") 
  data_r = data.reshape(512, -1)
elif FILEDIM == 2:
  print("file contains 2D array")
  data_r = np.genfromtxt(FILEPATH, delimiter=",") 
else:
  raise ValueError("ERROR: FILEDIM should be either 1 or 2")
print 'original shape of array: ', str(data_r.shape)

if FILETYPE == "weight":
  data_t = np.transpose(data_r)
  print 'transposed data shape check: ', str(data_t.shape)
  pe0 = data_t[:, ::2] #even columns 
  pe1 = data_t[:, 1::2]  #odd columns
  print('shape of pe0: ', pe0.shape)
  print('shape of pe1: ', pe1.shape)

  print('data_t: ')
  print(data_t[:3, :6])
  print('pe0: ')
  print(pe0[:3, :3])
  print('pe1: ')
  print(pe1[:3, :3])
  # for i in range(data_t.shape[1]):
  #   pe0.extend(data_t[:, (i % data_t.shape[1])].tolist())
  #   pe1.extend(data_t[:, ((i + 1) % data_t.shape[1])].tolist())


  pe0_t = np.transpose(pe0).reshape(1, -1).squeeze()
  print(pe0_t.shape)
  print(pe0_t[:6])
  pe1_t = np.transpose(pe1).reshape(1, -1).squeeze()
  print(pe1_t.shape)
  print(pe1_t[:6])
  print("==================")

  # pe0
  assert_array_equal(data_t[:3, 0], pe0_t[:3])  # first row 
  assert_array_equal(data_t[:3, 2], pe0_t[data_t.shape[0]*1:data_t.shape[0]*1+3]) # second row
  assert_array_equal(data_t[:3, data_t.shape[1]-2],
    pe0_t[data_t.shape[0]*(data_t.shape[1]/2-1):data_t.shape[0]*(data_t.shape[1]/2-1)+3]) 
    # last row

  # pe1
  assert_array_equal(data_t[:3, 1], pe1_t[:3]) # first row 
  assert_array_equal(data_t[:3, 3], pe1_t[data_t.shape[0]*1:data_t.shape[0]*1+3]) # second rows
  assert_array_equal(data_t[:3, data_t.shape[1]-1],
    pe1_t[data_t.shape[0]*(data_t.shape[1]/2-1):data_t.shape[0]*(data_t.shape[1]/2-1)+3])
    # last row

  assert len(pe0_t) == len(pe1_t) == (data_t.shape[0]*data_t.shape[1] / 2)

# elif FILETYPE == "input":


# else:

np.savetxt('{}/pe0_{}.dat'.format(FILESAVEDIR, FILESAVENAME), [pe0_t], fmt='%d', delimiter=',') 
print 'Saved in ', '{}/pe0_{}.dat'.format(FILESAVEDIR, FILESAVENAME)
  # %10.5f : total length = 10 and 5 floating points
np.savetxt('{}/pe1_{}.dat'.format(FILESAVEDIR, FILESAVENAME), [pe1_t], fmt='%d', delimiter=',')
print 'Saved in ', '{}/pe1_{}.dat'.format(FILESAVEDIR, FILESAVENAME)

