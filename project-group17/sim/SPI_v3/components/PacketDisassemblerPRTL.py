'''
==========================================================================
PacketDisassemblerPRTL.py
==========================================================================
PacketDisassembler with variable nbits_in and nbits_out. 
Input: one big packet of size nbits_in Output: small packets of size nbits_out.

The input bit length must be greater than the output bit length.
PacketDisassembler with variable nbits_in and nbits_out. nbits_in > nbits_out, and we bring data from the input into 
separate registers (in one cycle), then send one register's output to the module's output per cycle.
Eg: 16 bit input packet, we want 8 bit output packets.
    Input is 0xABCD. 0xAB will go into reg[1] and 0xCD will go into reg[0].
    Next cycle the Disassembler will output 0xAB. The cycle after that 0xCD will be outputted

'''

from pymtl3 import *
from pymtl3.stdlib.basic_rtl import Mux
from pymtl3.stdlib.stream.ifcs import MinionIfcRTL
from math import ceil

class PacketDisassemblerPRTL( Component ):

  def construct( s, nbits_in, nbits_out ):

    # Local Parameters
    s.nbits_in = nbits_in
    s.nbits_out = nbits_out
    s.num_regs = ceil(nbits_in / nbits_out)
    s.reg_bits = clog2(s.num_regs)

    # Interface
    s.disassem_ifc = MinionIfcRTL(mk_bits(s.nbits_in), mk_bits(s.nbits_out))

    # Variables
    s.regs = [ Wire(s.nbits_out) for _ in range(s.num_regs) ]

    s.counter = Wire(clog2(s.num_regs)+1) # the +1 is because we count up to s.num_regs e.g. if num_regs=2 then counter must go from 0->1->2

    s.transaction_val = Wire(1) # 1 if there is an ongoing transaction

    # Mux
    s.reg_mux = Mux(s.nbits_out, s.num_regs) # muxes each part of the input packet to the output

    # Assigns
    s.disassem_ifc.req.rdy   //= lambda: (s.transaction_val == 0)
    s.disassem_ifc.resp.val  //= lambda: (s.transaction_val == 1)

    # Counter Update Logic
    @update_ff
    def up_counter():
      if s.reset | (s.counter == (s.num_regs-1)) & s.disassem_ifc.resp.rdy: # if reset or you have sent the last packet
        s.counter <<= 0
      elif s.disassem_ifc.resp.val & s.disassem_ifc.resp.rdy: # if we send a packet
        s.counter <<= s.counter + 1
      else:
        s.counter <<= s.counter

    # Transaction Val Logic
    @update_ff
    def up_transaction_val():
      if s.reset:
        s.transaction_val <<= 0
      elif (s.disassem_ifc.req.val & s.disassem_ifc.req.rdy) | ((s.counter == (s.num_regs-1)) & s.disassem_ifc.resp.rdy): # if there is an input packet or you have sent the last output packet
        s.transaction_val <<= s.disassem_ifc.req.val & s.disassem_ifc.req.rdy # set transaction val to 1 if it is an input packet
      else:
        s.transaction_val <<= s.transaction_val

    # Sequential Reg Update Logic
    @update_ff
    def up_regs():
      for i in range(s.num_regs):
        if s.disassem_ifc.req.val & s.disassem_ifc.req.rdy: # if valid input packet
          if i == (s.num_regs - 1): # this is the top register
            s.regs[i] <<= zext(s.disassem_ifc.req.msg[ (s.nbits_out*s.num_regs-s.nbits_out) : s.nbits_in ], s.nbits_out) # holds MSb, zext to fit register size 
          else:
            s.regs[i] <<= s.disassem_ifc.req.msg[s.nbits_out*(i) : (s.nbits_out*i + s.nbits_out) ]

    # Mux and Output Logic
    @update
    def up_comb():
      for i in range(s.num_regs):
        s.reg_mux.in_[i] @= s.regs[i]
      s.reg_mux.sel @= trunc(s.num_regs - s.counter - 1, s.reg_bits)
      s.disassem_ifc.resp.msg @= s.reg_mux.out


  def line_trace( s ):
    return f'{s.disassem_ifc.req.msg}(){s.disassem_ifc.resp.msg}'