'''
==========================================================================
LoopBackPRTL.py
==========================================================================
This takes receives a packet from the SPIMinionAdapter module and sends it back the next cycle to the 
SPIMinionAdapter module. Uses val/rdy microprotocol.

Author: Dilan Lakhani
    December 13, 2021

'''

from pymtl3 import *
from pymtl3.stdlib.basic_rtl import RegEnRst
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL, SendIfcRTL


class LoopBackPRTL( Component ):
    
  def construct( s, nbits=32):
    # Local Parameters
    s.nbits = nbits
  
    # Interface
  
    s.recv = RecvIfcRTL( mk_bits(s.nbits) )
    s.send = SendIfcRTL( mk_bits(s.nbits) )
  
    # Variables
    s.reg_ = RegEnRst(s.nbits)
    s.transaction_val = RegEnRst(1)
  
    # Assigns
    s.recv.rdy   //= lambda: (s.transaction_val.out == 0) | (s.send.val & s.send.rdy)
    s.send.val   //= lambda: s.transaction_val.out
    s.send.msg   //= lambda: s.reg_.out
  
    # Logic
  
    @update
    def up_comb():
      s.transaction_val.en @= (s.recv.val & s.recv.rdy) | (s.send.val & s.send.rdy)
      s.transaction_val.in_ @=  (s.recv.val & s.recv.rdy)
  
      s.reg_.en @= s.recv.val & s.recv.rdy
      s.reg_.in_ @= s.recv.msg
        

  def line_trace( s ):
    return f"reg_in {s.reg_.in_} reg_out {s.reg_.out}"