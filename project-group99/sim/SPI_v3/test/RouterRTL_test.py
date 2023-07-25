'''
==========================================================================
RouterRTL_test.py
==========================================================================
Unit test for Router.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.RouterRTL import RouterRTL

num_assems = 0

# Helper function
def t( dut, req_val, req_rdy, resp_val, resp_rdy, in_addr, in_data, out):

  # Write input value to input port
  dut.recv.msg.addr   @= in_addr
  dut.recv.msg.data   @= in_data
  dut.recv.val    @= req_val
  for i in range(num_assems):
    dut.send[i].rdy   @= resp_rdy[i]
  dut.sim_eval_combinational()

  if req_rdy != '?':
    assert dut.recv.rdy == req_rdy
  
  if out != '?':
    for i in range(num_assems):
        assert dut.send[i].msg == out 

  for i in range(num_assems):
    assert dut.send[i].val == resp_val[i]

  # Tick simulator one cycle
  dut.sim_tick()

# # Test vectors


def test_basic(cmdline_opts):
  '''
  This test is for Router(4,1) (4 bits input and only 1 PacketAssembler)
  '''
  global num_assems 
  num_assems = 1
  dut = RouterRTL(4, num_assems)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg.addr  @= 0 
  dut.recv.msg.data  @= 0 
  dut.recv.val   @= 0
  for i in range(num_assems):
    dut.send[i].rdy   @= 0
  dut.sim_reset()
  #       req_val req_rdy resp_val resp_rdy  in_addr   in_data     out
  t( dut,    1,      0,      [0],      [0],    0x0,      0x1,     '?' ) # not req rdy because the response is not ready
  t( dut,    1,      1,      [1],      [1],    0x0,      0x1,     0x1 )
  t( dut,    1,      1,      [1],      [1],    0x0,      0x3,     0x3 ) 
  t( dut,    1,      1,      [1],      [1],    0x0,      0x7,     0x7 ) 
  t( dut,    0,      0,      [0],      [0],    0x0,      0x0,     '?' )
  t( dut,    1,      0,      [0],      [0],    0x0,      0x0,     '?' ) 
  t( dut,    1,      0,      [0],      [0],    0x0,      0x0,     '?' ) 
  t( dut,    1,      0,      [0],      [0],    0x0,      0x0,     '?' ) 
  t( dut,    1,      1,      [1],      [1],    0x0,      0x2,     0x2 ) 
  t( dut,    0,      0,      [0],      [1],    0x0,      0x0,     '?' ) 
  t( dut,    0,      0,      [0],      [1],    0x0,      0x0,     '?' ) 


def test_2assems(cmdline_opts):
  '''
  This test is for Router(4,2) (4 bits input and 2 PacketAssemblers)
  '''
  global num_assems 
  num_assems = 2
  dut = RouterRTL(4, num_assems)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg.addr  @= 0 
  dut.recv.msg.data  @= 0 
  dut.recv.val   @= 0
  for i in range(num_assems):
    dut.send[i].rdy   @= 0
  dut.sim_reset()
  #       req_val req_rdy  resp_val    resp_rdy  in_addr in_data     out
  t( dut,    1,      0,      [0,0],      [1,0],   0x1,     0x0,    '?' ) # not req rdy because the response is not ready
  t( dut,    1,      1,      [0,1],      [0,1],   0x1,     0x7,    0x7 ) 
  t( dut,    1,      1,      [1,0],      [1,0],   0x0,     0x3,    0x3 ) 
  t( dut,    0,      0,      [0,0],      [1,1],   0x0,     0x0,    '?' )
  t( dut,    1,      1,      [1,0],      [1,0],   0x0,     0x2,    0x2 ) 
  t( dut,    1,      1,      [1,0],      [1,1],   0x0,     0x6,    0x6 ) 
  t( dut,    1,      0,      [0,0],      [0,1],   0x0,     0x0,    '?' ) 
  t( dut,    0,      0,      [0,0],      [1,0],   0x0,     0x0,    '?' ) 
  t( dut,    0,      0,      [0,0],      [0,0],   0x0,     0x0,    '?' )
  t( dut,    1,      0,      [0,0],      [0,0],   0x0,     0x0,    '?' ) 
  t( dut,    1,      0,      [0,0],      [0,1],   0x0,     0x0,    '?' ) 
  t( dut,    1,      0,      [0,0],      [0,1],   0x0,     0x0,    '?' ) 
  t( dut,    0,      0,      [0,0],      [1,1],   0x0,     0x0,    '?' ) 
  t( dut,    0,      0,      [0,0],      [1,1],   0x0,     0x0,    '?' ) 
  t( dut,    1,      1,      [0,1],      [0,1],   0x1,     0x0,    0x0 ) 
  t( dut,    0,      0,      [0,0],      [0,1],   0x1,     0x7,    '?' )
   

def test_4assems(cmdline_opts):
  '''
  This test is for Router(4,4) (4 bits input and 4 PacketAssemblers)
  '''
  global num_assems 
  num_assems = 4
  dut = RouterRTL(4, num_assems)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg.addr  @= 0 
  dut.recv.msg.data  @= 0 
  dut.recv.val   @= 0
  for i in range(num_assems):
    dut.send[i].rdy   @= 0
  dut.sim_reset()
  #       req_val req_rdy  resp_val     resp_rdy  in_addr  in_data  out
  t( dut,    1,      0,    [0,0,0,0],   [1,1,0,1],  0x2,   0x0,    '?' ) # not req rdy because the response is not ready
  t( dut,    1,      1,    [0,0,0,1],   [0,0,0,1],  0x3,   0x3,    0x3 ) 
  t( dut,    1,      1,    [1,0,0,0],   [1,0,0,0],  0x0,   0x3,    0x3 ) 
  t( dut,    0,      0,    [0,0,0,0],   [1,0,0,0],  0x0,   0x0,    '?' )
  t( dut,    1,      1,    [1,0,0,0],   [1,0,0,0],  0x0,   0x2,    0x2 ) 
  t( dut,    1,      1,    [0,1,0,0],   [0,1,0,0],  0x1,   0x2,    0x2 ) 
  t( dut,    1,      0,    [0,0,0,0],   [0,1,1,1],  0x0,   0x0,    '?' ) 
  t( dut,    0,      0,    [0,0,0,0],   [0,0,1,0],  0x2,   0x2,    '?' ) 
  t( dut,    0,      0,    [0,0,0,0],   [0,0,0,0],  0x0,   0x0,    '?' )
  t( dut,    1,      0,    [0,0,0,0],   [0,1,1,1],  0x0,   0x0,    '?' ) 
  t( dut,    1,      0,    [0,0,0,0],   [0,0,0,1],  0x0,   0x0,    '?' ) 
  t( dut,    1,      0,    [0,0,0,0],   [0,1,1,0],  0x0,   0x0,    '?' ) 
  t( dut,    0,      0,    [0,0,0,0],   [1,0,0,0],  0x0,   0x0,    '?' ) 
  t( dut,    0,      0,    [0,0,0,0],   [1,0,0,0],  0x0,   0x0,    '?' ) 
  t( dut,    1,      1,    [0,0,1,0],   [0,0,1,0],  0x2,   0x0,    0x0 ) 
  t( dut,    0,      0,    [0,0,0,0],   [0,0,0,1],  0x3,   0x3,    '?' )




