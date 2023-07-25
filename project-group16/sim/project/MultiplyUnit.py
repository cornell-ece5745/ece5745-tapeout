#=========================================================================
# Multiply
#=========================================================================
# This module takes one block of rows and the vector and multiplies them 
# to produce one block of entries in the destination array.

from pymtl3 import *

class MultiplyUnit( Component ):

  # Constructor

  def construct( s, nbits, num_rows ):

    s.row = [ InPort (nbits) for _ in range(num_rows/4) ]
    s.col = [ InPort (nbits) for _ in range(num_rows/4) ]
    s.nnz = InPort(nbits)
    s.vec = InPort(nbits)
    s.res = OutPort(nbits) 

    @update
    def block ():
        for i in len(s.row):
            sum = 0
            for j in (s.row[i], s.row[i+1]):
                sum += s.nnz[j] * s.vec[s.col[j]]
            s.res[i] += sum        
      
  #Line tracing

  def line_trace( s ):

    s.trace = ""

    s.trace = "{} {} | {} {}".format(
      s.in0,
      s.in1,
      s.out_min,
      s.out_max
    )

    return s.trace

