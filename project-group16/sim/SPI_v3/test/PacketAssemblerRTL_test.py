'''
==========================================================================
PacketAssemblerRTL_test.py
==========================================================================
Unit test for PacketAssembler.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.PacketAssemblerRTL import PacketAssemblerRTL

# Helper function
def t( dut, req_val, req_rdy, resp_val, resp_rdy, in_, out):

  # Write input value to input port
  dut.assem_ifc.req.msg        @= in_
  dut.assem_ifc.req.val        @= req_val
  dut.assem_ifc.resp.rdy       @= resp_rdy

  dut.sim_eval_combinational()

  if req_rdy != '?':
    assert dut.assem_ifc.req.rdy == req_rdy
  
  if out != '?':
    assert dut.assem_ifc.resp.msg == out

  if resp_val != '?':
    assert dut.assem_ifc.resp.val == resp_val

  # Tick simulator one cycle
  dut.sim_tick()

# # Test vectors

def test_8x16(cmdline_opts):

  dut = PacketAssemblerRTL(8, 16)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.assem_ifc.req.msg       @= 0 
  dut.assem_ifc.req.val       @= 0
  dut.assem_ifc.resp.rdy      @= 0
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

  dut = PacketAssemblerRTL(8, 32)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.assem_ifc.req.msg       @= 0 
  dut.assem_ifc.req.val       @= 0
  dut.assem_ifc.resp.rdy      @= 0
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

  dut = PacketAssemblerRTL(7, 25)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.assem_ifc.req.msg       @= 0 
  dut.assem_ifc.req.val       @= 0
  dut.assem_ifc.resp.rdy      @= 0
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

  dut = PacketAssemblerRTL(3, 7)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.assem_ifc.req.msg       @= 0 
  dut.assem_ifc.req.val       @= 0
  dut.assem_ifc.resp.rdy      @= 0
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

  dut = PacketAssemblerRTL(7, 7)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.assem_ifc.req.msg       @= 0 
  dut.assem_ifc.req.val       @= 0
  dut.assem_ifc.resp.rdy      @= 0
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

  dut = PacketAssemblerRTL(1, 4)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.assem_ifc.req.msg       @= 0 
  dut.assem_ifc.req.val       @= 0
  dut.assem_ifc.resp.rdy      @= 0
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
