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
from pymtl3.stdlib.stream.ifcs import MinionIfcRTL, MasterIfcRTL


class LoopThroughVRTL( VerilogPlaceholder, Component ):
    
  def construct( s, nbits=32):

    # Local Parameters
    s.nbits = nbits

    # Ports

    s.sel = InPort() # select bit, if 1 then loopback, if 0 pass through

    # Upstream   req  (Recv Ifc): Input from the upstream Send ifc (can be looped back or passed to the downstream block)
    # Upstream   resp (Send Ifc): Output to the upstream Recv ifc (can be looped back or passed in from the downstream block)
    # Downstream req  (Send Ifc): Output to the downstream Recv ifc (0 if loopback is selected) 
    # Downstream resp (Recv Ifc): Input from the downstream Send ifc (Not used if loopback is selected)

    s.upstream   = MinionIfcRTL( mk_bits(s.nbits), mk_bits(s.nbits) ) 
    s.downstream = MasterIfcRTL( mk_bits(s.nbits), mk_bits(s.nbits) )

    s.set_metadata( VerilogPlaceholderPass.params, { 'nbits' : nbits } )
    s.set_metadata( VerilogPlaceholderPass.port_map, {
      s.sel                 : 'sel',

      s.upstream.req.val    : 'upstream_req_val',
      s.upstream.req.msg    : 'upstream_req_msg',
      s.upstream.req.rdy    : 'upstream_req_rdy',

      s.upstream.resp.val   : 'upstream_resp_val',
      s.upstream.resp.msg   : 'upstream_resp_msg',
      s.upstream.resp.rdy   : 'upstream_resp_rdy',

      s.downstream.req.val  : 'downstream_req_val',
      s.downstream.req.msg  : 'downstream_req_msg',
      s.downstream.req.rdy  : 'downstream_req_rdy',

      s.downstream.resp.val : 'downstream_resp_val',
      s.downstream.resp.msg : 'downstream_resp_msg',
      s.downstream.resp.rdy : 'downstream_resp_rdy',
    })

        
# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .LoopThroughPRTL import LoopThroughPRTL as LoopThroughRTL
elif rtl_language == 'verilog':
  LoopThroughRTL = LoopThroughVRTL
else:
  raise Exception("Invalid RTL language!")