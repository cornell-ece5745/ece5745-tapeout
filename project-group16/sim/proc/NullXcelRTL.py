#=========================================================================
# Choose PyMTL or Verilog version
#=========================================================================
# Set this variable to 'pymtl' if you are using PyMTL for your RTL design
# (i.e., your design is in VvaddXcelPRTL) or set this variable to
# 'verilog' if you are using Verilog for your RTL design (i.e., your
# design is in VvaddXcelVRTL).

rtl_language = 'pymtl'

#-------------------------------------------------------------------------
# Do not edit below this line
#-------------------------------------------------------------------------

# This is the PyMTL wrapper for the corresponding Verilog RTL model.

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.passes.backends.verilog import *

from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType

from proc.XcelMsg import XcelReqMsg, XcelRespMsg

class NullXcelVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s ):
    # If translated into Verilog, we use the explicit name

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'NullXcelRTL' )

    # Interface

    s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )
    s.mem  = stream.ifcs.MasterIfcRTL( *mk_mem_msg(8,32,32) )

    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.xcel.req.val  : 'xcelreq_val',
      s.xcel.req.rdy  : 'xcelreq_rdy',
      s.xcel.req.msg  : 'xcelreq_msg',

      s.xcel.resp.val : 'xcelresp_val',
      s.xcel.resp.rdy : 'xcelresp_rdy',
      s.xcel.resp.msg : 'xcelresp_msg',

      s.mem.req.val   : 'memreq_val',
      s.mem.req.rdy   : 'memreq_rdy',
      s.mem.req.msg   : 'memreq_msg',

      s.mem.resp.val  : 'memresp_val',
      s.mem.resp.rdy  : 'memresp_rdy',
      s.mem.resp.msg  : 'memresp_msg',
    })

# See if the course staff want to force testing a specific RTL language
# for their own testing.

import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .NullXcelPRTL import NullXcelPRTL as NullXcelRTL
elif rtl_language == 'verilog':
  NullXcelRTL = NullXcelVRTL
else:
  raise Exception("Invalid RTL language!")
