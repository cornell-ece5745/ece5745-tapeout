'''
==========================================================================
PacketSerDesRTL_test.py
==========================================================================
Unit test for PacketSerDes.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.PacketSerDesRTL import PacketSerDesRTL

# Helper function
def t( dut, recv_val, recv_rdy, send_val, send_rdy, in_, out):

  # Write input value to input port
  dut.serdes_recv.msg        @= in_
  dut.serdes_recv.val        @= recv_val
  dut.serdes_send.rdy        @= send_rdy

  dut.sim_eval_combinational()

  if recv_rdy != '?':
    assert dut.serdes_recv.rdy == recv_rdy
  
  if out != '?':
    assert dut.serdes_send.msg == out

  if send_val != '?':
    assert dut.serdes_send.val == send_val

  # Tick simulator one cycle
  dut.sim_tick()

# Test vectors

#Assembler Tests
def test_8x16(cmdline_opts):

  dut = PacketSerDesRTL(8, 16)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t(   dut,  1,      1,      0,       1,     0xAA,    '?' ) # start transactiojn
  t(   dut,  1,      1,      0,       0,     0xBB,    '?' ) # second half of input data sent
  t(   dut,  0,      0,      1,       0,     0xBB,    '?' ) # stall bc resp not ready
  t(   dut,  0,      0,      1,       0,     0xBB,    '?' ) # stall
  t(   dut,  0,      0,      1,       0,     0xBB,    '?' ) # stall
  t(   dut,  0,      0,      1,       1,     0xBB,    0xAABB )  # resp_rdy is 1 and message is outputted correctly

  t(   dut,  1,      1,      0,       1,     0xDD,    '?' ) 
  t(   dut,  1,      1,      0,       1,     0xEE,    '?' )
  t(   dut,  0,      0,      1,       1,     0xCC,    0xDDEE )  

  t(   dut,  1,      1,      0,       1,     0xFF,    '?' ) 
  t(   dut,  1,      1,      0,       1,     0xAF,    '?' )
  t(   dut,  0,      0,      1,       1,     0xCC,    0xFFAF )  

  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xDD,    '?' ) 
  t(   dut,  1,      1,      0,       0,     0xEE,    '?' )
  t(   dut,  0,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  0,      0,      1,       1,     0xCC,    0xDDEE ) 

  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  
  t(   dut,  1,      1,      0,       1,     0xDD,    '?' )  # first half of message
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  # req not valid
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  # req not valid
  t(   dut,  0,      1,      0,       1,     0xCC,    '?' )  # req not valid
  t(   dut,  1,      1,      0,       0,     0xEE,    '?' )  # second half of message
  t(   dut,  0,      0,      1,       0,     0xCC,    '?' )  
  t(   dut,  0,      0,      1,       1,     0xCC,    0xDDEE ) 

def test_8x32(cmdline_opts):

  dut = PacketSerDesRTL(8, 32)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t( dut,    1,      1,      0,       1,     0xAA,    '?' ) # start transactiojn
  t( dut,    1,      1,      0,       0,     0xBB,    '?' ) # second quarter of input data sent
  t( dut,    1,      1,      0,       0,     0xCC,    '?' ) # third quarter of input data sent
  t( dut,    1,      1,      0,       0,     0xDD,    '?' ) # last quarter of input data sent
  t( dut,    0,      0,      1,       0,     0xBB,    '?' ) # stall bc resp not ready
  t( dut,    0,      0,      1,       0,     0xBB,    '?' ) # stall
  t( dut,    0,      0,      1,       0,     0xBB,    '?' ) # stall
  t( dut,    0,      0,      1,       1,     0xBB,    0xAABBCCDD )  # resp_rdy is 1 and message is outputted correctly

  t( dut,    1,      1,      0,       1,     0xDD,    '?' ) 
  t( dut,    1,      1,      0,       1,     0xEE,    '?' )
  t( dut,    1,      1,      0,       1,     0xDD,    '?' ) 
  t( dut,    1,      1,      0,       1,     0xEE,    '?' )
  t( dut,    0,      0,      1,       1,     0xCC,    0xDDEEDDEE )  

  t( dut,    1,      1,      0,       1,     0xAB,    '?' ) 
  t( dut,    1,      1,      0,       1,     0xCD,    '?' )
  t( dut,    1,      1,      0,       1,     0xEF,    '?' )
  t( dut,    1,      1,      0,       1,     0xAE,    '?' )
  t( dut,    0,      0,      1,       1,     0xCC,    0xABCDEFAE )  

  t( dut,    0,      1,      0,       1,     0xCC,    '?' )  
  t( dut,    0,      1,      0,       1,     0xCC,    '?' )  
  t( dut,    1,      1,      0,       1,     0xAC,    '?' ) 
  t( dut,    1,      1,      0,       0,     0xBD,    '?' )
  t( dut,    1,      1,      0,       0,     0xEF,    '?' )
  t( dut,    1,      1,      0,       0,     0xCD,    '?' )
  t( dut,    0,      0,      1,       0,     0xCC,    '?' )  
  t( dut,    0,      0,      1,       1,     0xCC,    0xACBDEFCD ) 

def test_7x25(cmdline_opts):

  dut = PacketSerDesRTL(7, 25)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t( dut,    1,      1,      0,       1,     0x01,    '?' ) # start transactiojn
  t( dut,    1,      1,      0,       0,     0x0A,    '?' )
  t( dut,    1,      1,      0,       0,     0x1C,    '?' ) 
  t( dut,    1,      1,      0,       0,     0x55,    '?' ) 
  t( dut,    0,      0,      1,       0,     0x1B,    '?' ) # stall bc resp not ready
  t( dut,    0,      0,      1,       0,     0x1B,    '?' ) # stall
  t( dut,    0,      0,      1,       0,     0x1B,    '?' ) # stall
  t( dut,    0,      0,      1,       1,     0x1B,    0x0228E55 )  # resp_rdy is 1 and message is outputted correctly

def test_3x7(cmdline_opts):

  dut = PacketSerDesRTL(3, 7)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t( dut,    1,      1,      0,       1,     0x1,    '?' ) # start transactiojn
  t( dut,    1,      1,      0,       0,     0x1,    '?' ) 
  t( dut,    1,      1,      0,       0,     0x1,    '?' )
  t( dut,    0,      0,      1,       0,     0x0,    '?' ) # stall bc resp not ready
  t( dut,    0,      0,      1,       0,     0x0,    '?' ) # stall
  t( dut,    0,      0,      1,       0,     0x0,    '?' ) # stall
  t( dut,    0,      0,      1,       1,     0x2,    0x49) # resp_rdy is 1 and message is outputted correctly

  t( dut,    1,      1,      0,       1,     0x7,    '?' ) # start transactiojn
  t( dut,    1,      1,      0,       0,     0x7,    '?' ) 
  t( dut,    1,      1,      0,       0,     0x7,    '?' )
  t( dut,    0,      0,      1,       1,     0x0,   0x7F )  

  t( dut,    0,      1,      0,       1,     0x7,    '?' )  
  t( dut,    0,      1,      0,       1,     0x7,    '?' )  
  t( dut,    1,      1,      0,       1,     0x4,    '?' )  
  t( dut,    1,      1,      0,       1,     0x5,    '?' )  
  t( dut,    1,      1,      0,       1,     0x6,    '?' ) 
  t( dut,    0,      0,      1,       0,     0x0,    '?' )  
  t( dut,    0,      0,      1,       1,     0x0,   0x2E ) 

  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  1,      1,      0,       1,     0x6,    '?' )  # 1/3 of message
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  # req not valid
  t(   dut,  1,      1,      0,       1,     0x5,    '?' )  # 2/3 of message
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  # req not valid
  t(   dut,  1,      1,      0,       0,     0x4,    '?' )  # 3/3 of message
  t(   dut,  0,      0,      1,       0,     0x0,    '?' )  
  t(   dut,  0,      0,      1,       1,     0x0,    0x2C ) 

def test_7x7(cmdline_opts):

  dut = PacketSerDesRTL(7, 7)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t( dut,    1,      1,      0,       1,     0x08,    '?' ) # start transactiojn
  t( dut,    0,      0,      1,       0,     0x1B,    '?' ) # stall bc resp not ready
  t( dut,    0,      0,      1,       0,     0x1B,    '?' ) # stall
  t( dut,    0,      0,      1,       0,     0x1B,    '?' ) # stall
  t( dut,    0,      0,      1,       1,     0x1B,    0x08)  # resp_rdy is 1 and message is outputted correctly

  t( dut,    0,      1,      0,       1,     0x1C,    '?' )  
  t( dut,    0,      1,      0,       1,     0x1C,    '?' )  
  t( dut,    1,      1,      0,       1,     0x1B,    '?' )  
  t( dut,    0,      0,      1,       1,     0x0,     0x1B) 

def test_1x4(cmdline_opts):

  dut = PacketSerDesRTL(1, 4)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy   in_     out
  t( dut,    1,      1,      0,       1,     0x1,    '?' ) # start transactiojn
  t( dut,    1,      1,      0,       0,     0x0,    '?' ) # second quarter of input data sent
  t( dut,    1,      1,      0,       0,     0x1,    '?' ) # third quarter of input data sent
  t( dut,    1,      1,      0,       0,     0x0,    '?' ) # last quarter of input data sent
  t( dut,    0,      0,      1,       0,     0x0,    '?' ) # stall bc resp not ready
  t( dut,    0,      0,      1,       0,     0x0,    '?' ) # stall
  t( dut,    0,      0,      1,       0,     0x0,    '?' ) # stall
  t( dut,    0,      0,      1,       1,     0x0,    0xA )  # resp_rdy is 1 and message is outputted correctly

  t( dut,    1,      1,      0,       1,     0x0,    '?' ) 
  t( dut,    1,      1,      0,       1,     0x1,    '?' )
  t( dut,    1,      1,      0,       1,     0x1,    '?' ) 
  t( dut,    1,      1,      0,       1,     0x1,    '?' )
  t( dut,    0,      0,      1,       1,     0x0,    0x7 )  

  t( dut,    1,      1,      0,       1,     0x1,    '?' ) 
  t( dut,    1,      1,      0,       1,     0x1,    '?' )
  t( dut,    1,      1,      0,       1,     0x1,    '?' )
  t( dut,    1,      1,      0,       1,     0x1,    '?' )
  t( dut,    0,      0,      1,       1,     0x0,    0xF )  

  t( dut,    0,      1,      0,       1,     0x0,    '?' )  
  t( dut,    0,      1,      0,       1,     0x0,    '?' )  
  t( dut,    1,      1,      0,       1,     0x0,    '?' ) 
  t( dut,    1,      1,      0,       0,     0x0,    '?' )
  t( dut,    1,      1,      0,       0,     0x1,    '?' )
  t( dut,    1,      1,      0,       0,     0x1,    '?' )
  t( dut,    0,      0,      1,       0,     0x0,    '?' )  
  t( dut,    0,      0,      1,       1,     0x0,    0x3 ) 

  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  1,      1,      0,       1,     0x1,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x0,    '?' ) 
  t(   dut,  1,      1,      0,       1,     0x1,    '?' )  
  t(   dut,  0,      1,      0,       1,     0x0,    '?' )  
  t(   dut,  1,      1,      0,       0,     0x1,    '?' )  
  t(   dut,  0,      1,      0,       0,     0x0,    '?' )  
  t(   dut,  1,      1,      0,       0,     0x0,    '?' )  
  t(   dut,  0,      0,      1,       0,     0x0,    '?' )
  t(   dut,  0,      0,      1,       1,     0x0,    0xE ) 

#Disassembler Tests
def test_16x8(cmdline_opts):

  dut = PacketSerDesRTL(16, 8)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
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

  dut = PacketSerDesRTL(16, 4)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
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

  dut = PacketSerDesRTL(5, 1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
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

  dut = PacketSerDesRTL(7,3)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
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

  dut = PacketSerDesRTL(8,3)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.serdes_recv.msg       @= 0 
  dut.serdes_recv.val       @= 0
  dut.serdes_send.rdy       @= 0
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
  