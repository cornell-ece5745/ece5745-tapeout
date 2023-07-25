'''
==========================================================================
ArbitratorPRTL.py
==========================================================================
This module is used to pick which component gets to output to the val/rdy SPI wrapper if multiple components can send a valid message.
The arbitrator puts an address header on the outgoing packet so that downstream components can tell which component sent the response
The nbits parameter is the length of the message received by the arbitrator.
The num_inputs parameter is the number of input components that the Arbitrator is selecting from. MUST be >= 2

Author : Dilan Lakhani
  Date : Dec 19, 2021
'''

from pymtl3 import *
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL


def mk_arb_msg(addr_nbits, data_nbits):
  @bitstruct
  class ArbitratorMsg:
    addr: mk_bits(addr_nbits)
    data: mk_bits(data_nbits)
  return ArbitratorMsg


class ArbitratorPRTL( Component ):

  def construct( s, nbits, num_inputs=2 ):

    # Local Parameters
    s.nbits = nbits
    s.num_inputs = num_inputs # parameterized by number of inputs in design
    s.num_inputs_minus_1 = num_inputs-1
    s.addr_nbits = clog2(num_inputs)

    # Interface
    s.recv = [ RecvIfcRTL(mk_bits(s.nbits)) for _ in range(s.num_inputs) ]
    s.send = SendIfcRTL(mk_arb_msg(s.addr_nbits, s.nbits))

    # Variables
    s.grants_index = Wire(s.addr_nbits) # which input is granted access to send to SPI
    s.encoder_out = Wire(s.addr_nbits)

    # Assigns
    s.send.val       //= lambda: s.recv[s.grants_index].val & s.recv[s.grants_index].rdy # valid response if there is a valid request from the granted PacketDisassembler
    s.send.msg.data  //= lambda: s.recv[s.grants_index].msg
    s.send.msg.addr  //= lambda: s.grants_index

    @update
    def up_grants_index():
      # change grants_index if the last cycle's grant index is 0 (that component has finished sending its message)
      if ~s.recv[s.old_grants_index].val:
        s.grants_index @= s.encoder_out
      else:
        s.grants_index @= s.grants_index
        
    @update
    def up_recv_rdy():
      # Only tell one input that the arbitrator is ready for it
      for i in range(s.num_inputs):
        if s.grants_index == i:
          s.recv[i].rdy @= s.send.rdy
        else:
          s.recv[i].rdy @= 0

    @update
    def encode():
      # priority encoder that gives highest priority to the LSB and lowest to MSB
      s.encoder_out @= 0
      for i in range( s.num_inputs):
        if s.recv[s.num_inputs_minus_1 - i].val:
          s.encoder_out @= s.num_inputs_minus_1 - i  

    # One issue arises with having multiple Disassemblers. Since the SPI width is normally less than the size of a response,
    # a PacketDisassembler component needs multiple cycles to fully send a message to the arbitrator. Thus, we do not want to 
    # change which Disassembler is allowed to send to the Arbitrator in the middle of a message.
    # Fix this by holding a trailing value of the grants_index.
    # We need to be able to check the req_val of the old grants_index to make sure that it is not 1, then we can allow a different
    # Disassembler to send a message
    s.old_grants_index = Wire(s.addr_nbits)
    @update_ff
    def up_old_grants_index():
      if s.reset:
        s.old_grants_index <<= 0
      else:
        s.old_grants_index <<= s.grants_index


  def line_trace( s ):
    return f'temp {s.old_grants_index}'
