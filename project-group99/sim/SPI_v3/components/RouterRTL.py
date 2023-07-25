#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMulBasePRTL) or set this variable to
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
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL, MinionIfcRTL

def mk_router_msg(addr_nbits, nbits):
  @bitstruct
  class RouterMsg:
    addr: mk_bits(addr_nbits)
    data: mk_bits(nbits)
  return RouterMsg


class RouterVRTL( VerilogPlaceholder, Component ):
    
  def construct( s, nbits, num_outputs ):

    # Local Parameters
    s.nbits = nbits
    s.num_outputs = num_outputs # parameterized by number of components the router outputs to
    s.addr_nbits = max(1, clog2(num_outputs)) # allow 1 output to still work

    # Interface
    s.recv = RecvIfcRTL(mk_router_msg(s.addr_nbits, s.nbits)) # recv msg will be (s.nbits + s.addr_nbits) long
    s.send = [ SendIfcRTL(mk_bits(s.nbits)) for _ in range(s.num_outputs) ]

        
# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .RouterPRTL import RouterPRTL as RouterRTL
elif rtl_language == 'verilog':
  RouterRTL = RouterVRTL
else:
  raise Exception("Invalid RTL language!")