#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in IntMultFixedLatPRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in IntMulFixedLatVRTL).

rtl_language = 'verilog'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

from project.crc32.CRC32UnitMsg import CRC32UnitMsgs

class CRC32UnitVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'CRC32UnitRTL' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( CRC32UnitMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( CRC32UnitMsgs.resp )

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .CRC32UnitPRTL import CRC32UnitPRTL as CRC32UnitRTL
elif rtl_language == 'verilog':
  CRC32UnitRTL = CRC32UnitVRTL
else:
  raise Exception("Invalid RTL language!")