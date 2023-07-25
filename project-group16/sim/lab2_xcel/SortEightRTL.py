#=========================================================================
# SortEightRTL
#=========================================================================
# This model sorts four nbit elements into ascending order using a
# bitonic sorting network. We break the four elements into two pairs and
# sort each pair independently. Then we compare the smaller elements from
# each pair and the larger elements from each pair before arranging the
# middle two elements. This implementation uses structural composition of
# Reg and MinMax child models.

from pymtl3 import *
from pymtl3.stdlib.basic_rtl import Reg, RegRst

from .MinMaxUnit import MinMaxUnit
from .SortUnitStructRTL import SortUnitStructRTL


class SortEightRTL( Component ):

  #=======================================================================
  # Constructor
  #=======================================================================

  def construct( s, nbits=32 ):

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.in_val  = InPort ()
    s.in_     = [ InPort (nbits) for _ in range(8) ]

    s.out_val = OutPort()
    s.out     = [ OutPort(nbits) for _ in range(8) ]

    s.val_temp1 = Wire(1)
    s.val_temp2 = Wire(1)
    s.val_temp3 = Wire(1)

    #---------------------------------------------------------------------
    # Stage S0->S1 pipeline registers
    #---------------------------------------------------------------------

    # s.val_S0S1 = RegRst(Bits1)
    # s.val_S0S1.in_ //= s.in_val

    # s.elm_S0S1 = [ Reg(mk_bits(nbits)) for i in range(8) ]

    # for i in range(8):
      # s.elm_S0S1[i].in_ //= s.in_[i]
   
      
    #---------------------------------------------------------------------
    # Stage S1 combinational logicortEightRTL
    #---------------------------------------------------------------------

    s.minmax0_S1 = m = SortUnitStructRTL(nbits)
    m.in_[0] //= s.in_[0]
    m.in_[1] //= s.in_[1]
    m.in_[2] //= s.in_[2]
    m.in_[3] //= s.in_[3]
    m.in_val //= s.in_val

    s.minmax1_S1 = m = SortUnitStructRTL(nbits)
    m.in_[0] //= s.in_[4]
    m.in_[1] //= s.in_[5]
    m.in_[2] //= s.in_[6]
    m.in_[3] //= s.in_[7]
    m.in_val //= s.in_val

    # s.minmax0_S1 = m = SortUnitStructRTL(nbits)
    # m.in_[0] //= s.elm_S0S1[0].out
    # m.in_[1] //= s.elm_S0S1[1].out
    # m.in_[2] //= s.elm_S0S1[2].out
    # m.in_[3] //= s.elm_S0S1[3].out
    # m.in_val //= s.val_S0S1.out

    # s.minmax1_S1 = m = SortUnitStructRTL(nbits)
    # m.in_[0] //= s.elm_S0S1[4].out
    # m.in_[1] //= s.elm_S0S1[5].out
    # m.in_[2] //= s.elm_S0S1[6].out
    # m.in_[3] //= s.elm_S0S1[7].out
    # m.in_val //= s.val_S0S1.out

    #---------------------------------------------------------------------
    # Stage S1->S2 pipeline registers
    #---------------------------------------------------------------------

    s.val_S1S2 = RegRst(Bits1)

    s.val_S1S2.in_ //= s.val_temp1

    s.elm_S1S2 = [ Reg(mk_bits(nbits)) for _ in range(8) ]

    s.elm_S1S2[0].in_ //= s.minmax0_S1.out[0]
    s.elm_S1S2[1].in_ //= s.minmax0_S1.out[1]
    s.elm_S1S2[2].in_ //= s.minmax0_S1.out[2]
    s.elm_S1S2[3].in_ //= s.minmax0_S1.out[3]
    s.elm_S1S2[4].in_ //= s.minmax1_S1.out[0]
    s.elm_S1S2[5].in_ //= s.minmax1_S1.out[1]
    s.elm_S1S2[6].in_ //= s.minmax1_S1.out[2]
    s.elm_S1S2[7].in_ //= s.minmax1_S1.out[3]

    #----------------------------------------------------------------------
    # Stage S2 combinational logic
    #----------------------------------------------------------------------

    s.minmax0_S2 = m = SortUnitStructRTL(nbits)
    m.in_[0] //= s.elm_S1S2[0].out
    m.in_[1] //= s.elm_S1S2[1].out
    m.in_[2] //= s.elm_S1S2[6].out
    m.in_[3] //= s.elm_S1S2[7].out
    m.in_val //= s.val_S1S2.out

    s.minmax1_S2 = m = SortUnitStructRTL(nbits)
    m.in_[0] //= s.elm_S1S2[2].out
    m.in_[1] //= s.elm_S1S2[3].out
    m.in_[2] //= s.elm_S1S2[4].out
    m.in_[3] //= s.elm_S1S2[5].out
    m.in_val //= s.val_S1S2.out

    #---------------------------------------------------------------------
    # Stage S2->S3 pipeline registers
    #---------------------------------------------------------------------

    s.val_S2S3 = RegRst(Bits1)
    
    s.val_S2S3.in_ //= s.val_temp2

    s.elm_S2S3 = [ Reg(mk_bits(nbits)) for _ in range(8) ]

    s.elm_S2S3[0].in_ //= s.minmax0_S2.out[0]
    s.elm_S2S3[1].in_ //= s.minmax0_S2.out[1]
    s.elm_S2S3[2].in_ //= s.minmax0_S2.out[2]
    s.elm_S2S3[3].in_ //= s.minmax0_S2.out[3]
    s.elm_S2S3[4].in_ //= s.minmax1_S2.out[0]
    s.elm_S2S3[5].in_ //= s.minmax1_S2.out[1]
    s.elm_S2S3[6].in_ //= s.minmax1_S2.out[2]
    s.elm_S2S3[7].in_ //= s.minmax1_S2.out[3]

    #----------------------------------------------------------------------
    # Stage S3 combinational logic
    #----------------------------------------------------------------------

    s.minmax0_S3 = m = SortUnitStructRTL(nbits)
    m.in_[0] //= s.elm_S2S3[0].out
    m.in_[1] //= s.elm_S2S3[1].out
    m.in_[2] //= s.elm_S2S3[4].out
    m.in_[3] //= s.elm_S2S3[5].out
    m.in_val //= s.val_S2S3.out

    s.minmax1_S3 = m = SortUnitStructRTL(nbits)
    m.in_[0] //= s.elm_S2S3[2].out
    m.in_[1] //= s.elm_S2S3[3].out
    m.in_[2] //= s.elm_S2S3[6].out
    m.in_[3] //= s.elm_S2S3[7].out
    m.in_val //= s.val_S2S3.out

    # Assign output ports

    @update
    def block(): 
      s.val_temp1 @= s.minmax0_S1.out_val & s.minmax1_S1.out_val
      s.val_temp2 @= s.minmax0_S2.out_val & s.minmax1_S2.out_val
      s.val_temp3 @= s.minmax0_S3.out_val & s.minmax1_S3.out_val
      
    s.out_val //= s.val_temp3
    s.out[0]  //= s.minmax0_S3.out[0]
    s.out[1]  //= s.minmax0_S3.out[1]
    s.out[2]  //= s.minmax0_S3.out[2]
    s.out[3]  //= s.minmax0_S3.out[3]
    s.out[4]  //= s.minmax1_S3.out[0]
    s.out[5]  //= s.minmax1_S3.out[1]
    s.out[6]  //= s.minmax1_S3.out[2]
    s.out[7]  //= s.minmax1_S3.out[3]

  #=======================================================================
  # Line tracing
  #=======================================================================

  def line_trace( s ):

    def trace_val_elm( val, elm ):
      str_ = '{{{},{},{},{},{},{},{},{}}}'.format( elm[0], elm[1], elm[2], elm[3], elm[4], elm[5], elm[6], elm[7] )
      if not val:
        str_ = ' '*len(str_)
      return str_

    return "{}|{}|{}|{}".format(
      trace_val_elm( s.in_val,        s.in_                         ),
     # trace_val_elm( s.val_S0S1.out,  [ m.out for m in s.elm_S0S1 ] ),
      trace_val_elm( s.val_S1S2.out,  [ m.out for m in s.elm_S1S2 ] ),
      trace_val_elm( s.val_S2S3.out,  [ m.out for m in s.elm_S2S3 ] ),
      trace_val_elm( s.out_val,       s.out                         ),
    )

