'''
==========================================================================
LoopBackRTL_test.py
==========================================================================
Unit test for Loopback.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.LoopBackRTL import LoopBackRTL

# Helper function
def t( dut, recv_val, recv_rdy, send_val, send_rdy, recv_msg, send_msg):

  # Write input value to input port
  dut.recv.msg        @= recv_msg
  dut.recv.val        @= recv_val
  dut.send.rdy        @= send_rdy

  dut.sim_eval_combinational()

  if recv_rdy != '?':
    assert dut.recv.rdy == recv_rdy
  
  if send_msg != '?':
    assert dut.send.msg == send_msg

  if send_val != '?':
    assert dut.send.val == send_val

  # Tick simulator one cycle
  dut.sim_tick()

# Test vectors

# This test is for Loopback(32)
def test_basic(cmdline_opts):

  dut = LoopBackRTL(32)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.recv.msg  @= 0 
  dut.recv.val  @= 0
  dut.send.rdy  @= 0
  dut.sim_reset()
  #       recv_val recv_rdy send_val send_rdy recv_msg   send_msg
  t( dut,    1,      1,        0,       0,     0xABCD,    '?' ) # start transaction
  t( dut,    1,      1,        1,       1,     0xDCBA,    0xABCD ) 
  t( dut,    0,      1,        1,       1,     0x0001,    0xDCBA )
  t( dut,    1,      1,        0,       0,     0x0400,    '?' ) 
  t( dut,    0,      0,        1,       0,     0x0000,    '?' ) 
  t( dut,    0,      0,        1,       0,     0x0000,    '?' ) 
  t( dut,    0,      1,        1,       1,     0x0000,    0x0400 ) 




