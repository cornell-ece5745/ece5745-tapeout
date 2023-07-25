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
from ..interfaces import PushInIfc, PullOutIfc
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL

def mk_miso_msg(nbits):
  @bitstruct
  class MisoMsg:
    val: Bits1
    spc: Bits1
    data: mk_bits(nbits-2)
  return MisoMsg

def mk_mosi_msg(nbits):
  @bitstruct
  class MosiMsg:
    val_wrt: Bits1
    val_rd: Bits1
    data: mk_bits(nbits-2)
  return MosiMsg


class SPIMinionAdapterVRTL( VerilogPlaceholder, Component ):

  # Constructor

  def construct( s, nbits=8, num_entries=1 ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, f'SPIMinionAdapterRTL__{nbits}nbits__{num_entries}num_entries' )

    s.recv = RecvIfcRTL( mk_bits(nbits-2))
    s.send = SendIfcRTL( mk_bits(nbits-2))

    s.pull_en = InPort(1)
    s.pull_msg_val   = OutPort(1)
    s.pull_msg_spc   = OutPort(1) 
    s.pull_msg_data  = OutPort(nbits-2)
    s.push_en = InPort(1)
    s.push_msg_val_wrt  = InPort(1)
    s.push_msg_val_rd   = InPort(1)
    s.push_msg_data     = InPort(nbits-2) 

    s.parity = OutPort()

    s.set_metadata( VerilogPlaceholderPass.port_map, {
        s.pull_en          : 'pull_en',
        s.pull_msg_val     : 'pull_msg_val',
        s.pull_msg_spc     : 'pull_msg_spc',
        s.pull_msg_data    : 'pull_msg_data',
        s.push_en          : 'push_en',
        s.push_msg_val_wrt : 'push_msg_val_wrt',
        s.push_msg_val_rd  : 'push_msg_val_rd',
        s.push_msg_data    : 'push_msg_data',
        s.recv.msg         : 'recv_msg',
        s.recv.rdy         : 'recv_rdy',
        s.recv.val         : 'recv_val',
        s.send.msg         : 'send_msg',
        s.send.rdy         : 'send_rdy',
        s.send.val         : 'send_val',
        s.parity           : 'parity'
    })

class SPIMinionAdapterOuterVRTL( Component ):

  def construct( s, nbits=8, num_entries=1 ):
    s.push = PushInIfc( mk_mosi_msg(nbits) ) #interfaces from perspective of SPIMinion
    s.pull = PullOutIfc( mk_miso_msg(nbits) )

    s.recv = RecvIfcRTL( mk_bits(nbits-2))
    s.send = SendIfcRTL( mk_bits(nbits-2))

    s.adapter = a = SPIMinionAdapterVRTL(nbits, num_entries)

    s.recv //= a.recv
    s.send //= a.send
    s.push.en //= a.push_en
    s.push.msg.val_wrt //= a.push_msg_val_wrt
    s.push.msg.val_rd //= a.push_msg_val_rd
    s.push.msg.data //= a.push_msg_data
    s.pull.en //= a.pull_en
    s.pull.msg.val //= a.pull_msg_val
    s.pull.msg.spc //= a.pull_msg_spc 
    s.pull.msg.data //= a.pull_msg_data

# For to force testing a specific RTL language
import sys
if hasattr( sys, '_called_from_test' ):
  if sys._pymtl_rtl_override:
    rtl_language = sys._pymtl_rtl_override

# Import the appropriate version based on the rtl_language variable

if rtl_language == 'pymtl':
  from .SPIMinionAdapterPRTL import SPIMinionAdapterPRTL as SPIMinionAdapterRTL
elif rtl_language == 'verilog':
  SPIMinionAdapterRTL = SPIMinionAdapterOuterVRTL
else:
  raise Exception("Invalid RTL language!")