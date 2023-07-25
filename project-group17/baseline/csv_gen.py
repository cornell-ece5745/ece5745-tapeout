import csv
import numpy as np
import warnings

# fixed point constants
frac_bits = 5
int_bits = 11 # include sign bit

#suppress warnings
warnings.filterwarnings('ignore')

# sigmoid float
def sigmoid(x):
    sig = 1 / (1 + np.exp(-x))
    return sig

def addr_to_signed(addr, int_bits, frac_bits):
    step = 2 **(-frac_bits) 
    unsigned_val = addr*step
    if(unsigned_val < (1<<(int_bits-1))):
        return unsigned_val
    else:
        return unsigned_val - (1<<(int_bits))

# initialize lists
data = ['']
addr = ['']

# open the file in the write mode
f = open('sigmoid.csv', 'w')

# create the csv writer
writer = csv.writer(f)

for i in range(0, 2**(frac_bits + int_bits)):
    addr[0] = i 
    # write the addr to a row (addr range: 0 to 2^(all bits) -1)
    writer.writerow(addr)
    # write result to a row
    data[0] =int(np.trunc(sigmoid(addr_to_signed(i, int_bits, frac_bits)) * 2**(frac_bits)))
    writer.writerow(data)

# close the file
f.close()