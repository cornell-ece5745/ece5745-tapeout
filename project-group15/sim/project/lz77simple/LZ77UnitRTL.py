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

from .LZ77UnitMsg import LZ77UnitMsgs

class LZ77UnitVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'LZ77UnitRTL' )

    # Interface

    s.recv = stream.ifcs.RecvIfcRTL( LZ77UnitMsgs.req )
    s.send = stream.ifcs.SendIfcRTL( LZ77UnitMsgs.resp )

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .LZ77UnitPRTL import LZ77UnitPRTL as LZ77UnitRTL
elif rtl_language == 'verilog':
  LZ77UnitRTL = LZ77UnitVRTL
else:
  raise Exception("Invalid RTL language!")
