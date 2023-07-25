### As of May 2, 2022

These files are ordered in sequence so that they can be directly read into the 
pe's at the correct cycle, which will be controlled by the corresponding 
memory engines. 

# 2x2 Systolic Array Computation 
```python
#           a0  a1
#           -------        
#         |  A2 A3  |     t1 
#  t1 t0  |  A0 A1  |     t0
# -------   -------
# | x1 x0  | pe0 pe1
# | x2 x3  | pe2 pe3
# -------   -------
#         | om0 om1 |       --> om0 = A0x1+A2x1; om1 = A1x0+A3x1 
#         | om2 om3 |       --> om2 = A0x3+A2x2; om3 = A1x3+A3x2
#           -------
#           out0 out1

# where A   represents weight matrix
#       x   represents input matrix
#       pe  represents processing element
#       om  represents output matrix that represents the output from pe after
#           it finishes its execution 
#       t   represents time (t1 > t0)
#       out represents the actual output read by the output SPI slave
```

# Full Iteration 
matrices:               x                   A_T

```python
# matrices:               x                   A_T

# 1st iteration:

#                     IMAGE_SIZE        MLP_OUTPUT_DIM
#                   --------------     ---------------- 
#                  |  a  a  a  a  |   |a b             | 
#     BATCH_SIZE   |  b  b  b  b  |   |a b             |    IMAGE_SIZE
#                  |              |   |a b             |
#                  |              |   |a b             |
#                   --------------     ----------------

# 2nd iteration:
#                   --------------     ---------------- 
#                  |              |   |  a b           |
#                  |  a  a  a  a  |   |  a b           |
#                  |  b  b  b  b  |   |  a b           |
#                  |              |   |  a b           |
#                   --------------     ----------------

# ...

# (MLP_OUTPUT_DIM+1) iteration:
#                   --------------     ---------------- 
#                  |  b  b  b  b  |   |b              a|
#                  |              |   |b              a|
#                  |              |   |b              a|
#                  |  a  a  a  a  |   |b              a|
#                   --------------     ----------------
```

# Explanation to files

```python
#       fc_weights_a0 --> a0  a1 <-- fc_weights_a1
#                         -------        
#                       |  A2 A3  |     t1 
#                t1 t0  |  A0 A1  |     t0
#               -------   -------
# val_img0 --> | x1 x0  | pe0 pe1
# val_img1 --> | x2 x3  | pe2 pe3
#               -------   -------
#                       | om0 om1 |       --> om0 = A0x1+A2x1; om1 = A1x0+A3x1 
#                       | om2 om3 |       --> om2 = A0x3+A2x2; om3 = A1x3+A3x2
#                         -------
#                        out0 out1
```
                  
