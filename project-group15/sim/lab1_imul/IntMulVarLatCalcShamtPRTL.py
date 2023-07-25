#=========================================================================
# CalcShamtPRTL
#=========================================================================
# Looking at least significant eight bits, calculate how many bits we
# want to shift.

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class IntMulVarLatCalcShamtPRTL( Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'IntMulVarLatCalcShamtRTL' )

    s.in_ = InPort (8)
    s.out = OutPort(4)

    @update
    def up_calc_shamt():
      if   s.in_ == 0: s.out @= 8
      elif s.in_[0]:   s.out @= 1
      elif s.in_[1]:   s.out @= 1
      elif s.in_[2]:   s.out @= 2
      elif s.in_[3]:   s.out @= 3
      elif s.in_[4]:   s.out @= 4
      elif s.in_[5]:   s.out @= 5
      elif s.in_[6]:   s.out @= 6
      elif s.in_[7]:   s.out @= 7
      else:            s.out @= 1 # default

  # Line tracing

  def line_trace( s ):
    return f"{s.in_}(){s.out}"

