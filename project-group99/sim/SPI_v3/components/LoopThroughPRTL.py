'''
==========================================================================
LoopThroughPRTL.py
==========================================================================
This module is meant to either loopback data to the the upstream module, 
or pass data to the downstream module, depending on the select bit. 
If sel = 1, no data is passed to the downstream block, it is simply 
looped to the upstream.
If sel = 0, this module essentially connects the upstream to the 
downstream blocks.

Author: Dilan Lakhani, Updated by Jack Brzozowski
    February 25, 2022

'''

from pymtl3 import *
from pymtl3.stdlib.stream.ifcs import MinionIfcRTL, MasterIfcRTL


class LoopThroughPRTL( Component ):
    
  def construct( s, nbits=32):
    # Local Parameters
    s.nbits = nbits

    # Ports

    s.sel = InPort() # select bit, if 1 then loopback, if 0 pass through

    # Upstream req   (Recv Ifc): Input from the upstream Send ifc (can be looped back or passed to the downstream block)
    # Upstream resp  (Send Ifc): Output to the upstream Recv ifc (can be looped back or passed in from the downstream block)
    # Downstream req (Send Ifc): Output to the downstream Recv ifc (0 if loopback is selected) 
    # Downstream resp(Recv Ifc): Input from the downstream Send ifc (Not used if loopback is selected)

    s.upstream   = MinionIfcRTL( mk_bits(s.nbits), mk_bits(s.nbits) ) 
    s.downstream = MasterIfcRTL( mk_bits(s.nbits), mk_bits(s.nbits) )

    s.upstream.resp.val //= lambda: s.upstream.req.val if (s.sel) else s.downstream.resp.val
    s.upstream.resp.msg //= lambda: s.upstream.req.msg if (s.sel) else s.downstream.resp.msg

    s.downstream.req.val //= lambda: 0 if (s.sel) else s.upstream.req.val
    s.downstream.req.msg //=  s.upstream.req.msg

    s.upstream.req.rdy //= lambda: s.upstream.resp.rdy if (s.sel) else s.downstream.req.rdy 

    s.downstream.resp.rdy //= lambda: 0 if (s.sel) else s.upstream.resp.rdy 

        
  def line_trace( s ):
    return f"upstream.req {s.upstream.req.val}|{s.upstream.req.rdy}|{s.upstream.req.msg}\
            downstream.req {s.downstream.req.val}|{s.downstream.req.rdy}|{s.downstream.req.msg}\
            downstream.resp {s.downstream.resp.val}|{s.downstream.resp.rdy}|{s.downstream.resp.msg}\
            upstream.resp {s.upstream.resp.val}|{s.upstream.resp.rdy}|{s.upstream.resp.msg}"