'''
==========================================================================
PacketDisassemblerRTL_test.py
==========================================================================
Unit test for PacketDisassembler.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.PacketDisassemblerRTL import PacketDisassemblerRTL

# Helper function
def t( dut, req_val, req_rdy, resp_val, resp_rdy, in_, out):

  # Write input value to input port
  dut.recv.msg        @= in_
  dut.recv.val        @= req_val
  dut.send.rdy       @= resp_rdy

  dut.sim_eval_combinational()

  if req_rdy != '?':
    assert dut.recv.rdy == req_rdy
  
  if out != '?':
    assert dut.send.msg == out

  if resp_val != '?':
    assert dut.send.val == resp_val

  # Tick simulator one cycle
  dut.sim_tick()

# # Test vectors

def test_16x8(cmdline_opts):

  dut = PacketDisassemblerRTL(16, 8)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg       @= 0 
  dut.recv.val       @= 0
  dut.send.rdy      @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t(   dut,  1,      1,      0,       1,     0xABCD,  '?' ) # start transaction, fill registers with 16 bits of input
  t(   dut,  0,      0,      1,       1,     0xBB,    0xAB) # send out first 8 bits 
  t(   dut,  0,      0,      1,       1,     0xBB,    0xCD) # send out second 8 bits
  t(   dut,  0,      1,      0,       1,     0xBB,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0xABCD,  '?' ) # start transaction, fill registers with 16 bits of input
  t(   dut,  0,      0,      1,       0,     0xBB,    '?' ) # stall bc resp not ready
  t(   dut,  1,      0,      1,       0,     0xBB,    '?' ) # stall
  t(   dut,  1,      0,      1,       0,     0xBB,    '?' ) # stall
  t(   dut,  1,      0,      1,       1,     0xBB,    0xAB) # send out first 8 bits 
  t(   dut,  1,      0,      1,       1,     0xBB,    0xCD) # send out second 8 bits

  t(   dut,  1,      1,      0,       1,     0xDDEE,  '?' ) 
  t(   dut,  0,      0,      1,       1,     0xCC,    0xDD)  
  t(   dut,  0,      0,      1,       1,     0xCC,    0xEE) 

  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xDEAD,  '?' ) 
  t(   dut,  0,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       1,     0xCC,    0xDE ) 
  t(   dut,  1,      0,      1,       1,     0xCC,    0xAD) 

  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xBEEF,  '?' )  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       1,     0xCC,    0xBE)  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       1,     0xCC,    0xEF) 
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' ) 

def test_16x4(cmdline_opts):

  dut = PacketDisassemblerRTL(16, 4)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg       @= 0 
  dut.recv.val       @= 0
  dut.send.rdy      @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t(   dut,  1,      1,      0,       1,     0xABCD,  '?' ) # start transaction, fill registers with 16 bits of input
  t(   dut,  0,      0,      1,       1,     0xBB,    0xA) # send out first 8 bits 
  t(   dut,  0,      0,      1,       1,     0xBB,    0xB)
  t(   dut,  0,      0,      1,       1,     0xBB,    0xC)
  t(   dut,  0,      0,      1,       1,     0xBB,    0xD)
  t(   dut,  0,      1,      0,       1,     0xBB,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0xABCD,  '?' ) # start transaction, fill registers with 16 bits of input
  t(   dut,  0,      0,      1,       0,     0xBB,    '?' ) # stall bc resp not ready
  t(   dut,  1,      0,      1,       0,     0xBB,    '?' ) # stall
  t(   dut,  1,      0,      1,       0,     0xBB,    '?' ) # stall
  t(   dut,  0,      0,      1,       1,     0xBB,    0xA) # send out first 8 bits 
  t(   dut,  0,      0,      1,       1,     0xBB,    0xB)
  t(   dut,  0,      0,      1,       1,     0xBB,    0xC)
  t(   dut,  0,      0,      1,       1,     0xBB,    0xD)

  t(   dut,  1,      1,      0,       1,     0xDDEE,  '?' ) 
  t(   dut,  0,      0,      1,       1,     0xCC,    0xD)  
  t(   dut,  0,      0,      1,       1,     0xCC,    0xD)  
  t(   dut,  0,      0,      1,       1,     0xCC,    0xE)  
  t(   dut,  0,      0,      1,       1,     0xCC,    0xE)  

  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xDEAD,  '?' ) 
  t(   dut,  0,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       1,     0xCC,    0xD ) 
  t(   dut,  1,      0,      1,       1,     0xCC,    0xE ) 
  t(   dut,  1,      0,      1,       1,     0xCC,    0xA) 
  t(   dut,  1,      0,      1,       1,     0xCC,    0xD) 

  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xBEEF,  '?' )  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       1,     0xCC,    0xB)  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  1,      0,      1,       1,     0xCC,    0xE)  
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )
  t(   dut,  1,      0,      1,       1,     0xCC,    0xE) 
  t(   dut,  1,      0,      1,       0,     0xCC,    '?' )
  t(   dut,  1,      0,      1,       1,     0xCC,    0xF) 
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' ) 

def test_5x1(cmdline_opts):

  dut = PacketDisassemblerRTL(5, 1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg       @= 0 
  dut.recv.val       @= 0
  dut.send.rdy      @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t(   dut,  1,      1,      0,       1,     0x1F,  '?' ) # start transaction, fill registers with 16 bits of input
  t(   dut,  0,      0,      1,       1,     0x0,    0x1) 
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0x0F,  '?' ) 
  t(   dut,  0,      0,      1,       0,     0x0,    '?' ) # stall bc resp not ready
  t(   dut,  1,      0,      1,       0,     0x0,    '?' ) # stall
  t(   dut,  1,      0,      1,       0,     0x0,    '?' ) # stall
  t(   dut,  0,      0,      1,       1,     0x0,    0x0)  
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)

  t(   dut,  1,      1,      0,       1,     0x11,  '?' ) 
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)  
  t(   dut,  0,      0,      1,       1,     0x0,    0x0)  
  t(   dut,  0,      0,      1,       1,     0x0,    0x0)  
  t(   dut,  0,      0,      1,       1,     0x0,    0x0) 
  t(   dut,  0,      0,      1,       1,     0x0,    0x1)  

  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  1,      1,      0,       1,     0x12,  '?' ) 
  t(   dut,  0,      0,      1,       0,     0x0,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x0,    0x1 ) 
  t(   dut,  1,      0,      1,       1,     0x0,    0x0 ) 
  t(   dut,  1,      0,      1,       1,     0x0,    0x0) 
  t(   dut,  1,      0,      1,       1,     0x0,    0x1) 
  t(   dut,  1,      0,      1,       1,     0x0,    0x0) 

  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  1,      1,      0,       1,     0x15,  '?' )  
  t(   dut,  1,      0,      1,       0,     0x0,    '?' )  
  t(   dut,  1,      0,      1,       0,     0x0,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0x0,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x0,    0x1)  
  t(   dut,  1,      0,      1,       0,     0x0,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x0,    0x0)  
  t(   dut,  1,      0,      1,       0,     0x0,    '?' )
  t(   dut,  1,      0,      1,       1,     0x0,    0x1) 
  t(   dut,  1,      0,      1,       0,     0x0,    '?' )
  t(   dut,  1,      0,      1,       1,     0x0,    0x0) 
  t(   dut,  0,      0,      1,       0,     0x0,    '?' ) 
  t(   dut,  1,      0,      1,       1,     0x0,    0x1) 
  t(   dut,  0,      1,      0,       1,     0x0,    '?' ) 

def test_7x3(cmdline_opts):

  dut = PacketDisassemblerRTL(7,3)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg       @= 0 
  dut.recv.val       @= 0
  dut.send.rdy      @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t(   dut,  1,      1,      0,       1,     0x11,    '?' ) # start transaction, fill registers with 7 bits of input
  t(   dut,  0,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  0,      0,      1,       1,     0x00,   0x0) # send out first 3 bits 
  t(   dut,  0,      0,      1,       1,     0x00,   0x2) # send out second 3 bits
  t(   dut,  0,      0,      1,       1,     0x00,   0x1) # send out leftover bit
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0x55,  '?' ) # start transaction, fill registers with 7 bits of input
  t(   dut,  0,      0,      1,       1,     0x00,   0x1) # send out first 3 bits 
  t(   dut,  0,      0,      1,       1,     0x00,   0x2) # send out second 3 bits
  t(   dut,  0,      0,      1,       1,     0x00,   0x5) # send out leftover bit
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0x14,    '?' ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' )
  t(   dut,  1,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )
  t(   dut,  1,      0,      1,       1,     0x00,    0x0 ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x4 ) 

  t(   dut,  1,      1,      0,       1,     0x00,  '?' ) 
  t(   dut,  0,      0,      1,       1,     0x00,    0x0)  
  t(   dut,  0,      0,      1,       1,     0x00,    0x0) 
  t(   dut,  0,      0,      1,       1,     0x00,    0x0) 

  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  1,      1,      0,       1,     0x7F,    '?' ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x00,    0x1 ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x7) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x7) 

  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  1,      1,      0,       1,     0x32,    '?' )  
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x00,    0x0 )  
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x00,    0x6 ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 ) 
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )

def test_8x3(cmdline_opts):

  dut = PacketDisassemblerRTL(8,3)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg       @= 0 
  dut.recv.val       @= 0
  dut.send.rdy      @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t(   dut,  1,      1,      0,       1,     0x82,    '?' ) # start transaction, fill registers with 8 bits of input
  t(   dut,  0,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  0,      0,      1,       1,     0x00,   0x2) # send out first 3 bits 
  t(   dut,  0,      0,      1,       1,     0x00,   0x0) # send out second 3 bits
  t(   dut,  0,      0,      1,       1,     0x00,   0x2) # send out leftover bit
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0xD5,  '?' ) # start transaction, fill registers with 7 bits of input
  t(   dut,  0,      0,      1,       1,     0x00,   0x3) # send out first 3 bits 
  t(   dut,  0,      0,      1,       1,     0x00,   0x2) # send out second 3 bits
  t(   dut,  0,      0,      1,       1,     0x00,   0x5) # send out leftover bit
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  # req should now be ready

  t(   dut,  1,      1,      0,       1,     0x94,    '?' ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' )
  t(   dut,  1,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x4 ) 

  t(   dut,  1,      1,      0,       1,     0x00,    '?' ) 
  t(   dut,  0,      0,      1,       1,     0x00,    0x0)  
  t(   dut,  0,      0,      1,       1,     0x00,    0x0) 
  t(   dut,  0,      0,      1,       1,     0x00,    0x0) 

  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xAD,    '?' ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x5) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x5) 

  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xA2,    '?' )  
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 )  
  t(   dut,  1,      0,      1,       0,     0x00,    '?' )  
  t(   dut,  1,      0,      1,       1,     0x00,    0x4 ) 
  t(   dut,  0,      0,      1,       0,     0x00,    '?' ) 
  t(   dut,  1,      0,      1,       1,     0x00,    0x2 ) 
  t(   dut,  0,      1,      0,       1,     0x00,    '?' )  
  