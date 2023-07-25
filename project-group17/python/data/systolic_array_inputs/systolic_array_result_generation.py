# ============================================================
# systolic_array_result_generation.py:
# Generates the expected results of the 2x2 systolic array 
# RTL implementation 

# REQUIRES: the input data files in fixed-point and in case of 
#   weight files, use dataloading_sequence.py to be in the
#   right order 

# OUTPUT: the expected results in the output buffers (out0 and 
#   out1) in each cycle

# Currently, only supports A*x 

    # pe0_sum     pe1_sum
    # pe2_sum     pe3_sum

# ============================================================

import numpy as np

# Load files
PE0WEIGHTFILEPATH = "/home/ja499/ece5745/project-group17/python/data/systolic_array_inputs/fixed_point/pe0_fc1_fixed.dat"
PE1WEIGHTFILEPATH = "/home/ja499/ece5745/project-group17/python/data/systolic_array_inputs/fixed_point/pe1_fc1_fixed.dat"
PE0INPFILEPATH = "/home/ja499/ece5745/project-group17/python/data/systolic_array_inputs/fixed_point/pe0_img_fixed.dat"
PE1INPFILEPATH = "/home/ja499/ece5745/project-group17/python/data/systolic_array_inputs/fixed_point/pe1_img_fixed.dat"

# Systolic array implementation 
ACCNUM = 3      # accumulate until ACCNUM number of inputs are processed in a PE (should be the length of a single input)
FRACWIDTH = 16  # number of fractional bitwidth used 

# pe0_w = np.genfromtxt(PE0WEIGHTFILEPATH, delimiter=",") 
# pe1_w = np.genfromtxt(PE1WEIGHTFILEPATH, delimiter=",") 
# pe0_inp = np.genfromtxt(PE0INPFILEPATH, delimiter=",") 
# pe1_inp = np.genfromtxt(PE1INPFILEPATH, delimiter=",") 


# TESTING
pe0_w = np.array([442, 842, 442, 842])
pe1_w = np.array([-866, -2230, -866, -2230])
pe0_inp = np.array([50887, 13364, 50887, 13364])
pe1_inp = np.array([17219, 65279, 17219, 65279])

assert len(pe0_w) == len(pe1_w)
assert len(pe0_inp) == len(pe1_inp)
# Timing insensitive
pe0_sum = 0
pe1_sum = 0
pe2_sum = 0
pe3_sum = 0
out0 = 0
out1 = 0

print(pe0_w.shape[0])

for i in range(pe0_w.shape[0]):
  
  pe0_sum += ((pe0_w[i]*pe0_inp[i]) >> FRACWIDTH)
  pe1_sum += ((pe1_w[i]*pe0_inp[i]) >> FRACWIDTH)
  pe2_sum += ((pe0_w[i]*pe1_inp[i]) >> FRACWIDTH)
  pe3_sum += ((pe1_w[i]*pe1_inp[i]) >> FRACWIDTH)
  print 'data_in {}:'.format(i)
  print 'pe0_sum: {} | pe1_sum: {}'.format(pe0_sum, pe1_sum)
  print 'pe2_sum: {} | pe3_sum: {}'.format(pe2_sum, pe3_sum)

  if (i % ACCNUM == (ACCNUM-1)):
    out0 = pe2_sum
    out1 = pe3_sum
    print 'output cycle 1: out0: {}    | out1: {}'.format(out0, out1)
    out0 = pe0_sum
    out1 = pe1_sum
    print 'output cycle 2: out0: {}    | out1: {}'.format(out0, out1)
    pe0_sum = 0
    pe1_sum = 0
    pe2_sum = 0
    pe3_sum = 0
  else: 
    out0 = 0
    out1 = 0
    print 'output cycle 1: out0: {}    | out1: {}'.format(out0, out1)
    print 'output cycle 2: out0: {}    | out1: {}'.format(out0, out1)

  print '========================='

# print 'shape of pe0_w: ', str(len(pe0_w))
# print 'shape of pe1_w: ', str(len(pe1_w))
# print 'shape of pe0_inp: ', str(len(pe0_inp))
# print 'shape of pe1_inp: ', str(len(pe1_inp))

