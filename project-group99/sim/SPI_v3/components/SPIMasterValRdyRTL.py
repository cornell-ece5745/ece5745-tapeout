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
from ..interfaces.SPIIfc import SPIMasterIfc

class SPIMasterValRdyVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits=34, ncs=1 ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'SPIMasterValRdyRTL_{nbits}nbits_{ncs}ncs' )

    # Local parameters
    s.nbits = nbits                      # size of message
    s.ncs = ncs                          # number of chip select lines
    s.logBitsN = mk_bits(clog2(nbits)+1) # number of bits required to count to packet size

    # Interface
    s.spi_ifc = SPIMasterIfc( ncs )

    s.send = SendIfcRTL( mk_bits(s.nbits) )
    s.recv = RecvIfcRTL( mk_bits(s.nbits) )

    s.packet_size_ifc = RecvIfcRTL( s.logBitsN ) # size of spi packet (up to nbits)
    s.cs_addr_ifc = RecvIfcRTL( mk_bits(clog2(s.ncs) if s.ncs > 1 else 1) )

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .SPIMasterValRdyPRTL import SPIMasterValRdyPRTL as SPIMasterValRdyRTL
elif rtl_language == 'verilog':
  SPIMasterValRdyRTL = SPIMasterValRdyVRTL
else:
  raise Exception("Invalid RTL language!")