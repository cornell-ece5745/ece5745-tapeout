#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMultBasePRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulBaseVRTL).

rtl_language = 'pymtl'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# PyMTL wrappers for the corresponding Verilog RTL models.

from os import path
from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL

def mk_arb_msg(addr_nbits, data_nbits):
  @bitstruct
  class ArbitratorMsg:
    addr: mk_bits(addr_nbits)
    data: mk_bits(data_nbits)
  return ArbitratorMsg

class ArbitratorVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits, num_inputs ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'ArbitratorRTL_{nbits}nbits_{num_inputs}num_inputs' )

    s.nbits = nbits
    s.num_inputs = num_inputs
    s.addr_nbits = clog2(num_inputs)

    # interface
    s.recv = [ RecvIfcRTL(mk_bits(s.nbits)) for _ in range(s.num_inputs) ]
    s.send = SendIfcRTL(mk_arb_msg(s.addr_nbits, s.nbits))


# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .ArbitratorPRTL import ArbitratorPRTL as ArbitratorRTL
elif rtl_language == 'verilog':
  ArbitratorRTL = ArbitratorVRTL
else:
  raise Exception("Invalid RTL language!")
