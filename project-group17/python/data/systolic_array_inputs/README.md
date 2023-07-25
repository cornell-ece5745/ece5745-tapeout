### As of May 5, 2022

First, run the dataloading_sequence.py to generate a .dat file that contains the ordered sequence of the input data to the weight buffers. 
Second, run the systolic_array_result_generation.py to generate a .dat file that contains the expected results in the output buffers. 

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
#         | om0 om1 |       --> om0 = A0x0+A2x1; om1 = A1x0+A3x1     --> om0 = A0x0+A2x1; om1 = A1x0+A3x1 
#         | om2 om3 |       --> om2 = A0x3+A2x2; om3 = A1x3+A3x2     --> om2 = A0x3+A2x2; om3 = A1x3+A3x2
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

#                       WEIGHT                    INPUT            TEMPOUT                       TEMPOUT                       OUTPUT            
#                   ----------------------     ------------     ------------------------      ------------------------      --------------------------  
#                  |  w00  w01  w02  w03  |   |a0  b0      |   |w00a0+w01a1  w00b0+w01b1|    |w02a2+w03a3  w02b2+w03b3|    |w0x*A  w0x*B              |       
#     BATCH_SIZE   |  w10  w11  w12  w13  |   |a1  b1      |   |w10a0+w11a1  w10b0+w11b1|    |w12a2+w13a3  w12b2+w13b3|    |w1x*A  w1x*B              |    
#                  |                      |   |a2  b2      |   |                        |    |                        |    |                          |              
#                  |                      |   |a3  b3      |   |                        |    |                        |    |                          |              
#                   ----------------------     ------------     ------------------------      ------------------------      --------------------------             

#                       WEIGHT                    INPUT            TEMPOUT                       TEMPOUT                       OUTPUT            
#                   ----------------------     ------------     ------------------------      ------------------------      --------------------------  
#                  |                      |   |a0  b0      |   |                        |    |                        |    |                          |       
#     BATCH_SIZE   |                      |   |a1  b1      |   |                        |    |                        |    |                          |    
#                  |  w20  w21  w22  w23  |   |a2  b2      |   |w20a0+w21a1  w20b0+w21b1|    |w22a2+w23a3  w22b2+w23b3|    |w2x*A  w2x*B              |              
#                  |  w30  w31  w32  w33  |   |a3  b3      |   |w30a0+w31a1  w30b0+w31b1|    |w32a2+w33a3  w32b2+w33b3|    |w3x*A  w3x*B              |              
#                   ----------------------     ------------     ------------------------      ------------------------      --------------------------   

# 2nd iteration:
#                  ----------------------     -------------         --------------------------                      
#                 |                      |   |      c0  d0 |       |                          |                   
#                 |                      |   |      c1  d1 |       |                          |      
#                 |  w20  w21  w22  w23  |   |      c2  d2 |       |             w2x*c  w2x*d |  
#                 |  w30  w31  w32  w33  |   |      c3  d3 |       |             w3x*c  w3x*d | 
#                  ----------------------     -------------         -------------------------- 

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
                  
