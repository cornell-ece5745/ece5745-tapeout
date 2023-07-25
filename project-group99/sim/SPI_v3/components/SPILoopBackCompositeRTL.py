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
from ..interfaces.SPIIfc import SPIMinionIfc

class SPILoopBackCompositeVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits=32 ):

    #Local parameters

    s.nbits = nbits  # size of SPI packet including 2 bit flow control

    #Interface

    s.spi_min = SPIMinionIfc()
    s.minion_parity = OutPort()
    s.adapter_parity = OutPort()


    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.spi_min.cs    : 'cs',
      s.spi_min.sclk  : 'sclk',
      s.spi_min.mosi  : 'mosi',
      s.spi_min.miso  : 'miso',

      s.minion_parity   : 'minion_parity',
      s.adapter_parity  : 'adapter_parity',
    })

# Import the appropriate version based on the rtl_language variable

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

if rtl_language == 'pymtl':
  from .SPILoopBackCompositePRTL import SPILoopBackCompositePRTL as SPILoopBackCompositeRTL
elif rtl_language == 'verilog':
  SPILoopBackCompositeRTL = SPILoopBackCompositeVRTL
else:
  raise Exception("Invalid RTL language!")