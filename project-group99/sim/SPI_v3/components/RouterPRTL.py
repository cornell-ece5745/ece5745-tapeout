'''
==========================================================================
RouterPRTL.py
==========================================================================
Router module that receives an input of size nbits from the SPIPushPull2ValRdyAdapter and reads the address bits
to find out which output component to send the packet to. Then it strips off the address bits and sends the data
bits to the corret output component. The router reads the address bits in the input packet (the highest order bits) 
and sends data to correct output. Output components must be connected according to a known scheme so that you know
which output component the router will send the data to, given the address.

Author : Dilan Lakhani
  Date : Jan 17, 2022
'''

from pymtl3 import *
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL, MinionIfcRTL

def mk_router_msg(addr_nbits, nbits):
  @bitstruct
  class RouterMsg:
    addr: mk_bits(addr_nbits)
    data: mk_bits(nbits)
  return RouterMsg

class RouterPRTL( Component ):

  def construct( s, nbits, num_outputs ):

    # Local Parameters
    s.nbits = nbits
    s.num_outputs = num_outputs # parameterized by number of components the router outputs to
    s.addr_nbits = max(1, clog2(num_outputs)) # allow 1 output to still work

    # Interface
    s.recv = RecvIfcRTL(mk_router_msg(s.addr_nbits, s.nbits)) # recv msg will be (s.nbits + s.addr_nbits) long
    s.send = [ SendIfcRTL(mk_bits(s.nbits)) for _ in range(s.num_outputs) ]


    # Variables
    s.addressed_output = Wire(s.addr_nbits) # holds the number of the output that current message is addressed to

    # Assigns
    s.addressed_output //= s.recv.msg.addr
    
    s.recv.rdy  //= lambda: s.recv.val & s.send[s.addressed_output].rdy # can accept request if it can immediately send it to the correct output. Check req_val also bc we dont want to say the router is not ready if an invalid request specifies a wrong addressed_output

    @update
    def up_comb():
      for i in range(s.num_outputs):
        if (s.addressed_output == i):
          s.send[i].val  @= s.recv.val & s.recv.rdy
        else:
          s.send[i].val  @= 0

      for i in range(s.num_outputs):
        s.send[i].msg  @= s.recv.msg.data


  def line_trace( s ):
    return f'addr {s.recv.msg.addr} data {s.recv.msg.data} addressed_output {s.addressed_output} resp_val0 {s.send[0].val}'