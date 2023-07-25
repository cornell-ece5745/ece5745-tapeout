'''
==========================================================================
SPIMinionAdapterPRTL.py
==========================================================================
An Adapter that converts push/pull interface from SPI to val/rdy interfaces. 

Author : Kyle Infantino
Date : Nov 30, 2021

'''
from pymtl3 import *
from pymtl3.stdlib.stream.queues import NormalQueueRTL
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

class SPIMinionAdapterPRTL( Component ):

  def construct( s, nbits=32, num_entries=2 ):
    s.nbits = nbits
    s.nbits_minus2 = nbits-2  # we need this param bc the sign extend function didnt like when we wrote s.nbits-2 as the second arg
    s.push = PushInIfc( mk_mosi_msg(nbits) ) #interfaces from perspective of SPIMinion
    s.pull = PullOutIfc( mk_miso_msg(nbits) )

    s.recv = RecvIfcRTL( mk_bits(nbits-2))
    s.send = SendIfcRTL( mk_bits(nbits-2))

    s.parity = OutPort()

    s.mc_recv_val = Wire(1) 
    s.cm_send_rdy = Wire(1) 
    s.open_entries = Wire(1)

    s.mc_q = NormalQueueRTL( mk_bits(nbits-2), num_entries ) # mc = master->chip (mosi) 
    s.mc_q.send.val //= s.send.val
    s.mc_q.send.msg //= s.send.msg
    s.mc_q.send.rdy //= s.send.rdy
    s.mc_q.recv.val //= s.mc_recv_val
    s.mc_q.recv.msg //= s.push.msg.data

    s.cm_q = NormalQueueRTL( mk_bits(nbits-2), num_entries ) # cm = chip->master (miso) 
    s.cm_q.recv.val //= s.recv.val
    s.cm_q.recv.rdy //= s.recv.rdy
    s.cm_q.recv.msg //= s.recv.msg
    s.cm_q.send.rdy //= s.cm_send_rdy

    s.parity //= lambda: reduce_xor(s.send.msg) & s.send.val
 
    @update
    def comb_block():
      s.open_entries @= s.mc_q.count < (num_entries-1)
      s.mc_recv_val @= s.push.msg.val_wrt & s.push.en
      s.pull.msg.spc @= s.mc_q.recv.rdy & (~s.mc_q.recv.val | s.open_entries) # there is space if the queue outputs recv.rdy and if this cycle there is no valid input to queue or there are more than 1 open entries

      s.cm_send_rdy @= s.push.msg.val_rd & s.pull.en
      s.pull.msg.val @= s.cm_send_rdy & s.cm_q.send.val
      s.pull.msg.data @= s.cm_q.send.msg & (sext(s.pull.msg.val, s.nbits_minus2))
      
      

  def line_trace( s ):
    return f"mc_recv_rdy {s.mc_q.recv.rdy} mc_recv_val {s.mc_q.recv.val} cm_send_rdy {s.cm_q.send.rdy} cm_send_val {s.cm_q.send.val} mc_count {s.mc_q.count} cm_count {s.cm_q.count}"
