#=========================================================================
# SortUnitFlatRTL
#=========================================================================
# A register-transfer-level model explicitly represents state elements
# with s.tick concurrent blocks and uses s.combinational concurrent
# blocks to model how data transfers between state elements.

from pymtl3 import *

class SortUnitFlatRTL( Component ):

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

    # SORT UNIT 1
    #---------------------------------------------------------------------
    # Stage S0->S1 pipeline registers
    #---------------------------------------------------------------------

    s.val_S1 = Wire()
    s.elm_S1 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S0S1():

      if s.reset:
        s.val_S1 <<= 0
      else:
        s.val_S1 <<= s.in_val

      for i in range(4):
        s.elm_S1[i] <<= s.in_[i]

    #---------------------------------------------------------------------
    # Stage S1 combinational logic
    #---------------------------------------------------------------------

    s.elm_next_S1 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S1():

      # Sort elements 0 and 1

      if s.elm_S1[0] <= s.elm_S1[1]:
        s.elm_next_S1[0] @= s.elm_S1[0]
        s.elm_next_S1[1] @= s.elm_S1[1]
      else:
        s.elm_next_S1[0] @= s.elm_S1[1]
        s.elm_next_S1[1] @= s.elm_S1[0]

      # Sort elements 2 and 3

      if s.elm_S1[2] <= s.elm_S1[3]:
        s.elm_next_S1[2] @= s.elm_S1[2]
        s.elm_next_S1[3] @= s.elm_S1[3]
      else:
        s.elm_next_S1[2] @= s.elm_S1[3]
        s.elm_next_S1[3] @= s.elm_S1[2]

    #---------------------------------------------------------------------
    # Stage S1->S2 pipeline registers
    #---------------------------------------------------------------------

    s.val_S2 = Wire()
    s.elm_S2 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S1S2():
      if s.reset:
        s.val_S2 <<= 0
      else:
        s.val_S2 <<= s.val_S1

      for i in range(4):
        s.elm_S2[i] <<= s.elm_next_S1[i]

    #----------------------------------------------------------------------
    # Stage S2 combinational logic
    #----------------------------------------------------------------------

    s.elm_next_S2 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S2():

      # Sort elements 0 and 2

      if s.elm_S2[0] <= s.elm_S2[2]:
        s.elm_next_S2[0] @= s.elm_S2[0]
        s.elm_next_S2[2] @= s.elm_S2[2]
      else:
        s.elm_next_S2[0] @= s.elm_S2[2]
        s.elm_next_S2[2] @= s.elm_S2[0]

      # Sort elements 1 and 3

      if s.elm_S2[1] <= s.elm_S2[3]:
        s.elm_next_S2[1] @= s.elm_S2[1]
        s.elm_next_S2[3] @= s.elm_S2[3]
      else:
        s.elm_next_S2[1] @= s.elm_S2[3]
        s.elm_next_S2[3] @= s.elm_S2[1]

    #----------------------------------------------------------------------
    # Stage S2->S3 pipeline registers
    #----------------------------------------------------------------------

    s.val_S3 = Wire()
    s.elm_S3 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S2S3():
      if s.reset:
        s.val_S3 <<= 0
      else:
        s.val_S3 <<= s.val_S2

      for i in range(4):
        s.elm_S3[i] <<= s.elm_next_S2[i]

    #----------------------------------------------------------------------
    # Stage S3 combinational logic
    #----------------------------------------------------------------------

    s.elm_next_S3 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S3():

      # Pass through elements 0 and 3

      s.elm_next_S3[0] @= s.elm_S3[0]
      s.elm_next_S3[3] @= s.elm_S3[3]

      # Sort elements 1 and 2

      if s.elm_S3[1] <= s.elm_S3[2]:
        s.elm_next_S3[1] @= s.elm_S3[1]
        s.elm_next_S3[2] @= s.elm_S3[2]
      else:
        s.elm_next_S3[1] @= s.elm_S3[2]
        s.elm_next_S3[2] @= s.elm_S3[1]


    # SORT UNIT 2
    #---------------------------------------------------------------------
    # Stage S0->S1 pipeline registers
    #---------------------------------------------------------------------

    s.elm_S21 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S20S21():
      for i in range(4):
        s.elm_S21[i] <<= s.in_[i+4]

    #---------------------------------------------------------------------
    # Stage S1 combinational logic
    #---------------------------------------------------------------------

    s.elm_next_S21 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S21():

      # Sort elements 4 and 5

      if s.elm_S21[0] <= s.elm_S21[1]:
        s.elm_next_S21[0] @= s.elm_S21[0]
        s.elm_next_S21[1] @= s.elm_S21[1]
      else:
        s.elm_next_S21[0] @= s.elm_S21[1]                       
        s.elm_next_S21[1] @= s.elm_S21[0]

      # Sort elements 2 and 3

      if s.elm_S21[2] <= s.elm_S21[3]:
        s.elm_next_S21[2] @= s.elm_S21[2]
        s.elm_next_S21[3] @= s.elm_S21[3]
      else:
        s.elm_next_S21[2] @= s.elm_S21[3]
        s.elm_next_S21[3] @= s.elm_S21[2]

    #---------------------------------------------------------------------
    # Stage S1->S2 pipeline registers
    #---------------------------------------------------------------------

    s.elm_S22 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S21S22():
      for i in range(4):
        s.elm_S22[i] <<= s.elm_next_S21[i]

    #----------------------------------------------------------------------
    # Stage S2 combinational logic
    #----------------------------------------------------------------------

    s.elm_next_S22 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S22():

      # Sort elements 0 and 2

      if s.elm_S22[0] <= s.elm_S22[2]:
        s.elm_next_S22[0] @= s.elm_S22[0]
        s.elm_next_S22[2] @= s.elm_S22[2]
      else:
        s.elm_next_S22[0] @= s.elm_S22[2]
        s.elm_next_S22[2] @= s.elm_S22[0]

      # Sort elements 1 and 3

      if s.elm_S22[1] <= s.elm_S22[3]:
        s.elm_next_S22[1] @= s.elm_S22[1]
        s.elm_next_S22[3] @= s.elm_S22[3]
      else:
        s.elm_next_S22[1] @= s.elm_S22[3]
        s.elm_next_S22[3] @= s.elm_S22[1]

    #----------------------------------------------------------------------
    # Stage S2->S3 pipeline registers
    #----------------------------------------------------------------------

    s.elm_S23 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S22S23():
      for i in range(4):
        s.elm_S23[i] <<= s.elm_next_S22[i]

    #----------------------------------------------------------------------
    # Stage S3 combinational logic
    #----------------------------------------------------------------------

    s.elm_next_S23 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S23():

      # Pass through elements 0 and 3

      s.elm_next_S23[0] @= s.elm_S23[0]
      s.elm_next_S23[3] @= s.elm_S23[3]

      # Sort elements 1 and 2

      if s.elm_S23[1] <= s.elm_S23[2]:
        s.elm_next_S23[1] @= s.elm_S23[1]
        s.elm_next_S23[2] @= s.elm_S23[2]
      else:
        s.elm_next_S23[1] @= s.elm_S23[2]
        s.elm_next_S23[2] @= s.elm_S23[1]



    # SORT UNIT 3
    #---------------------------------------------------------------------
    # Stage S3->S4 pipeline registers
    #---------------------------------------------------------------------
    s.val_S4 = Wire()
    s.elm_S34 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S33S34():

      if s.reset:
        s.val_S4 <<= 0
      else:
        s.val_S4 <<= s.val_S3

      for i in range(4):
        s.elm_S34[i] <<= s.elm_next_S3[i]

    #---------------------------------------------------------------------
    # Stage S1 combinational logic
    #---------------------------------------------------------------------

    s.elm_next_S21 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S21():

      # Sort elements 4 and 5

      if s.elm_S21[0] <= s.elm_S21[1]:
        s.elm_next_S21[0] @= s.elm_S21[0]
        s.elm_next_S21[1] @= s.elm_S21[1]
      else:
        s.elm_next_S21[0] @= s.elm_S21[1]
        s.elm_next_S21[1] @= s.elm_S21[0]

      # Sort elements 2 and 3

      if s.elm_S21[2] <= s.elm_S21[3]:
        s.elm_next_S21[2] @= s.elm_S21[2]
        s.elm_next_S21[3] @= s.elm_S21[3]
      else:
        s.elm_next_S21[2] @= s.elm_S21[3]
        s.elm_next_S21[3] @= s.elm_S21[2]

    #---------------------------------------------------------------------
    # Stage S4->S5 pipeline registers
    #---------------------------------------------------------------------

    s.elm_S22 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S21S22():
      for i in range(4):
        s.elm_S22[i] <<= s.elm_next_S21[i]

    #----------------------------------------------------------------------
    # Stage S2 combinational logic
    #----------------------------------------------------------------------

    s.elm_next_S22 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S22():

      # Sort elements 0 and 2

      if s.elm_S22[0] <= s.elm_S22[2]:
        s.elm_next_S22[0] @= s.elm_S22[0]
        s.elm_next_S22[2] @= s.elm_S22[2]
      else:
        s.elm_next_S22[0] @= s.elm_S22[2]
        s.elm_next_S22[2] @= s.elm_S22[0]

      # Sort elements 1 and 3

      if s.elm_S22[1] <= s.elm_S22[3]:
        s.elm_next_S22[1] @= s.elm_S22[1]
        s.elm_next_S22[3] @= s.elm_S22[3]
      else:
        s.elm_next_S22[1] @= s.elm_S22[3]
        s.elm_next_S22[3] @= s.elm_S22[1]

    #----------------------------------------------------------------------
    # Stage S5->S6 pipeline registers
    #----------------------------------------------------------------------

    s.elm_S23 = [ Wire(nbits) for _ in range(4) ]

    @update_ff
    def pipereg_S22S23():
      for i in range(4):
        s.elm_S23[i] <<= s.elm_next_S22[i]

    #----------------------------------------------------------------------
    # Stage S3 combinational logic
    #----------------------------------------------------------------------

    s.elm_next_S23 = [ Wire(nbits) for _ in range(4) ]

    @update
    def stage_S23():

      # Pass through elements 0 and 3

      s.elm_next_S23[0] @= s.elm_S23[0]
      s.elm_next_S23[3] @= s.elm_S23[3]

      # Sort elements 1 and 2

      if s.elm_S23[1] <= s.elm_S23[2]:
        s.elm_next_S23[1] @= s.elm_S23[1]
        s.elm_next_S23[2] @= s.elm_S23[2]
      else:
        s.elm_next_S23[1] @= s.elm_S23[2]
        s.elm_next_S23[2] @= s.elm_S23[1]

    # Assign output ports

    s.out_val //= s.val_S3
    for i in range(4):
      s.out[i] //= s.elm_next_S3[i]

  #=======================================================================
  # Line tracing
  #=======================================================================

  def line_trace( s ):

    def trace_val_elm( val, elm ):
      str_ = f'{{{elm[0]},{elm[1]},{elm[2]},{elm[3]}}}'
      if not val:
        str_ = ' '*len(str_)
      return str_

    return "{}|{}|{}|{}|{}".format(
      trace_val_elm( s.in_val,  s.in_    ),
      trace_val_elm( s.val_S1,  s.elm_S1 ),
      trace_val_elm( s.val_S2,  s.elm_S2 ),
      trace_val_elm( s.val_S3,  s.elm_S3 ),
      trace_val_elm( s.out_val, s.out    ),
    )

