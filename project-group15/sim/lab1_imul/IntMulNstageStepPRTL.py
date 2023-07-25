#=========================================================================
# IntMulNstageStepRTL
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.basic_rtl import Mux, LeftLogicalShifter, RightLogicalShifter, Adder

class IntMulNstageStepPRTL( Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'IntMulNstageStepRTL' )

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    s.in_val     = InPort  ()
    s.in_a       = InPort  (32)
    s.in_b       = InPort  (32)
    s.in_result  = InPort  (32)

    s.out_val    = OutPort ()
    s.out_a      = OutPort (32)
    s.out_b      = OutPort (32)
    s.out_result = OutPort (32)

    #---------------------------------------------------------------------
    # Logic
    #---------------------------------------------------------------------

    # Right shifter

    s.rshifter = m = RightLogicalShifter(Bits32)
    m.in_   //= s.in_b
    m.shamt //= 1
    m.out   //= s.out_b

    # Left shifter

    s.lshifter = m = LeftLogicalShifter(Bits32)
    m.in_   //= s.in_a
    m.shamt //= 1
    m.out   //= s.out_a

    # Adder

    s.add = m = Adder(Bits32)
    m.in0 //= s.in_a
    m.in1 //= s.in_result

    # Result mux

    s.result_mux = m = Mux(Bits32,2)
    m.sel //= s.in_b[0]
    m.in_[0] //= s.in_result
    m.in_[1] //= s.add.out
    m.out //= s.out_result

    # Connect the valid bits

    s.in_val //= s.out_val

  # Line tracing

  def line_trace( s ):
    return "{}|{}|{}(){}|{}|{}".format(
      s.in_a,  s.in_b,  s.in_result,
      s.out_a, s.out_b, s.out_result
    )

