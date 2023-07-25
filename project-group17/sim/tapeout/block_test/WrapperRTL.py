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
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib import stream
from tapeout.block_test.WrapperMsgs    import WrapperMsgs

class WrapperVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):
    s.recv = stream.ifcs.RecvIfcRTL( Bits32 )
    s.send = stream.ifcs.SendIfcRTL( Bits50 )

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'WrapperRTL' )


# Import the appropriate version based on the rtl_language variable

if rtl_language == 'verilog':
  WrapperRTL = WrapperVRTL
else:
  raise Exception("Invalid RTL language!")