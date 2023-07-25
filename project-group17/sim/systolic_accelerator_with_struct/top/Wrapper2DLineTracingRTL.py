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
from systolic_accelerator.top.WrapperMsgs    import WrapperMsgs

class Wrapper2DLineTracingVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):
    s.recv = stream.ifcs.RecvIfcRTL(WrapperMsgs.recv)
    s.send = stream.ifcs.SendIfcRTL(WrapperMsgs.send)

    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'Wrapper2DLineTracingRTL' )


# Import the appropriate version based on the rtl_language variable

if rtl_language == 'verilog':
  Wrapper2DLineTracingRTL = Wrapper2DLineTracingVRTL
else:
  raise Exception("Invalid RTL language!")