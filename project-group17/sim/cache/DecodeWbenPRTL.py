#========================================================================
# lab3-mem Decoder for Write Byte Enable
#========================================================================

from pymtl3 import *

#------------------------------------------------------------------------
# Decoder for Wben
#------------------------------------------------------------------------

class DecodeWbenPRTL( Component ):

  # interface

  def construct( s, in_nbits=2, out_nbits=(1 << (2+2)) ):

    s.in_ = InPort  ( in_nbits  )
    s.out = OutPort ( out_nbits )

  # Combinational logic

    @s.update
    def comb_logic():
      s.out @= 0

      for i in range(out_nbits):
        if s.in_ == i >> 2:
          s.out[i] @= 1
