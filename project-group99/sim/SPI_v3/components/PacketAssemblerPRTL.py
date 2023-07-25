'''
==========================================================================
PacketAssemblerPRTL.py
==========================================================================
PacketAssembler with variable nbits_in and nbits_out. 
Input: small packets of size nbits_in Output: one big packet of size nbits_out.

The input bit length must be less than or equal to the output bit length.
PacketAssembler with variable nbits_in and nbits_out. nbits_in <= nbits_out, and we bring data from the input into 
separate registers (over multiple cycles), then concatenate the output of each register and send to the output of module.

'''

from pymtl3 import *
from math import ceil
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL
from pymtl3.stdlib.stream.ifcs import SendIfcRTL

class PacketAssemblerPRTL( Component ):

  def construct( s, nbits_in, nbits_out ):

    # Local Parameters
    s.nbits_in = nbits_in
    s.nbits_out = nbits_out
    s.num_regs = ceil(nbits_out / nbits_in)

    # Interface

    s.recv = RecvIfcRTL(mk_bits(s.nbits_in))
    s.send = SendIfcRTL(mk_bits(s.nbits_out))

    # Variables

    s.regs     = [ Wire(s.nbits_in) for _ in range(s.num_regs) ]
    s.counter  = Wire(clog2(s.num_regs)+1) # the +1 is because we count up to s.num_regs e.g. if num_regs=2 then counter must go from 0->1->2
    s.temp_out = Wire(s.nbits_in * s.num_regs) # bigger than s.out, holds the concatenated reg[i].out values

    # Assigns

    s.recv.rdy   //= lambda: s.counter != s.num_regs
    s.send.val  //= lambda: s.counter == s.num_regs 
    s.send.msg  //= lambda: s.temp_out[0:s.nbits_out]

    # Counter Update Logic

    @update_ff
    def up_counter():
      if s.reset | (s.send.val & s.send.rdy): # if reset or you have sent the packet
        s.counter <<= 0
      elif s.send.val & ~s.send.rdy: # if response is valid but can't send yet
        s.counter <<= s.counter
      elif s.recv.val & s.recv.rdy: # if you receive another piece of the packet
        s.counter <<= s.counter + 1
      else:
        s.counter <<= s.counter

    # Regs Update Logic

    @update_ff
    def up_regs():
      for i in range(s.num_regs):
        if s.reset:
          s.regs[i] <<= 0
        elif s.counter == i:
          s.regs[i] <<= s.recv.msg
        else:
          s.regs[i] <<= s.regs[i]

    # Combinational Update Resp Msg

    @update
    def up_resp_msg():
      for i in range(s.num_regs):
        # Need to put the first req_msg into the upper bits of the output because we write the most-significant part of the packet first
        s.temp_out[s.nbits_in*(s.num_regs-1-i) : (s.nbits_in*(s.num_regs-1-i) + s.nbits_in)] @= s.regs[i]
      

  def line_trace( s ):
    return f'{s.recv.msg}(){s.send.msg}'