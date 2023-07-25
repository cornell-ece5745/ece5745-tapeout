'''
==========================================================================
PacketSerDesPRTL.py
==========================================================================
Generic packet serialized/deserializer. 
Instantiates either a PacketAssembler or PacketDisassembler based on the 
nbits_in and nbits_out parameters.

Author: Kyle Infantino
May 31, 2022
'''

from pymtl3 import *
from pymtl3.stdlib.basic_rtl import Mux
from pymtl3.stdlib.stream.ifcs import RecvIfcRTL
from pymtl3.stdlib.stream.ifcs import SendIfcRTL
from math import ceil
from .PacketAssemblerPRTL import PacketAssemblerPRTL
from .PacketDisassemblerPRTL import PacketDisassemblerPRTL

class PacketSerDesPRTL( Component ):

  def construct( s, nbits_in, nbits_out ):

    # Local Parameters
    s.nbits_in = nbits_in
    s.nbits_out = nbits_out

    # Interface
    s.serdes_recv = RecvIfcRTL(mk_bits(s.nbits_in))
    s.serdes_send = SendIfcRTL(mk_bits(s.nbits_out))

    if nbits_in > nbits_out:
      s.mod = PacketDisassemblerPRTL(s.nbits_in, s.nbits_out)
      s.mod.recv //= s.serdes_recv
      s.mod.send //= s.serdes_send
    else:
      s.mod = PacketAssemblerPRTL(s.nbits_in, s.nbits_out)
      s.mod.recv //= s.serdes_recv
      s.mod.send //= s.serdes_send

  def line_trace( s ):
    return f'{s.serdes_recv.msg}(){s.serdes_send.msg}'