'''
==========================================================================
SPIMinionAdapterRTL_test.py
==========================================================================
Unit test for SPIAdapterRTL.
'''

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from ..components.SPIMinionAdapterRTL import SPIMinionAdapterRTL

def test_basic( cmdline_opts ):

  dut = SPIMinionAdapterRTL(4, 1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.pull.en @= 0
  dut.push.en @= 0
  dut.push.msg.val_rd @= 0
  dut.push.msg.val_wrt @= 0
  dut.push.msg.data @= 0
  dut.recv.val @= 0
  dut.recv.msg @= 0
  dut.send.rdy @= 0
  dut.sim_reset()

  # Test vectors
  #      pull_en, pull_val, pull_spc, pull_data, push_en, push_val_wrt, push_val_rd, push_data, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg 
  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       0,         0,      '?') #init
  t( dut,  0,       0,         1,         0x0,       0,         1,             1,      0x3,         0,        1,      0x3,       0,         0,      '?') #add msg no write
  t( dut,  0,       0,         0,         0x0,       1,         1,             0,      0x3,         0,        1,      0x0,       0,         0,      '?') #MOSI msg
  t( dut,  1,       0,         0,         0x0,       0,         1,             0,      0x3,         0,        1,      0x0,       1,         0,      '?') #MOSI msg
  t( dut,  0,       0,         0,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       1,         0,      0x3) #send msg
  t( dut,  0,       0,         0,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       1,         1,      0x3) #accept send msg
                                                                                                                              
  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       0,         1,      '?') #empty
  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         1,        1,      0x3,       0,         1,      '?') #recv msg
  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        0,      0x0,       0,         1,      '?') #MISO msg not accepted
  t( dut,  0,       0,         1,         0x0,       1,         0,             1,      0x0,         0,        0,      0x0,       0,         1,      '?') #accept MISO msg push
  t( dut,  1,       1,         1,         0x3,       0,         0,             1,      0x0,         0,        0,      0x0,       0,         1,      '?') #accept MISO msg pull
                                                                                                                                                               
  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       0,         1,      '?') #empty
  t( dut,  0,       0,         0,         0x0,       1,         1,             0,      0x2,         1,        1,      0x1,       0,         1,      '?') #write both queues push
  t( dut,  1,       0,         0,         0x0,       0,         1,             0,      0x2,         1,        0,      0x1,       1,         0,      '?') #write both queues pull
  t( dut,  0,       0,         0,         0x0,       1,         0,             1,      0x0,         0,        0,      0x0,       1,         1,      0x2) #read both queues push
  t( dut,  1,       1,         1,         0x1,       0,         0,             1,      0x0,         0,        0,      0x0,       0,         1,      '?') #read both queues push

  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       0,         1,      '?') #empty
  t( dut,  0,       0,         0,         0x0,       1,         1,             0,      0x2,         1,        1,      0x1,       0,         1,      '?') #write both queues push
  t( dut,  1,       0,         0,         0x0,       0,         1,             0,      0x2,         1,        0,      0x1,       1,         0,      '?') #write both queues pull
  t( dut,  0,       0,         0,         0x0,       1,         0,             1,      0x0,         0,        0,      0x0,       1,         0,      '?') #read both queues push
  t( dut,  1,       1,         0,         0x1,       0,         0,             1,      0x0,         0,        0,      0x0,       1,         1,      0x2) #read both queues push

  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       0,         1,      '?') #empty
  t( dut,  0,       0,         1,         0x0,       1,         0,             1,      0x0,         0,        1,      0x0,       0,         1,      '?') #read both queues push
  t( dut,  1,       0,         1,         0x0,       0,         0,             1,      0x0,         0,        1,      0x0,       0,         1,      '?') #read both queues push

  t( dut,  0,       0,         1,         0x0,       0,         0,             0,      0x0,         0,        1,      0x0,       0,         1,      '?') #empty
  t( dut,  0,       0,         0,         0x0,       1,         1,             0,      0x2,         0,        1,      0x1,       0,         1,      '?') #write mosi push
  t( dut,  1,       0,         0,         0x0,       0,         1,             0,      0x2,         0,        1,      0x1,       1,         1,      0x2) #write mosi pull
  t( dut,  0,       0,         1,         0x0,       1,         0,             1,      0x0,         0,        1,      0x0,       0,         1,      '?') #read miso push
  t( dut,  1,       0,         1,         0x0,       0,         0,             1,      0x0,         0,        1,      0x0,       0,         1,      '?') #read miso push
                                                                                                                                                               
def test_queue_len2( cmdline_opts ):

  dut = SPIMinionAdapterRTL(4, 2)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.pull.en @= 0
  dut.push.en @= 0
  dut.push.msg.val_rd @= 0
  dut.push.msg.val_wrt @= 0
  dut.push.msg.data @= 0
  dut.recv.val @= 0
  dut.recv.msg @= 0
  dut.send.rdy @= 0
  dut.sim_reset()
  
  # Test vectors
  #     pull_en, pull_val, pull_spc, pull_data, push_en, push_val_wrt, push_val_rd, push_data, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg 
  t( dut,  0,        0,        1,       0x0,       0,         0,            0,         0x0,         0,        1,      0x0,       0,         0,      '?') #init
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x3,         0,        1,      0x0,       0,         0,      '?') #MOSI msg push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x3,         0,        1,      0x0,       1,         0,      '?') #MOSI msg pull
  t( dut,  0,        0,        1,       0x0,       0,         1,            0,         0x0,         0,        1,      0x0,       1,         1,      0x3) #send msg
  
  t( dut,  0,        0,        1,       0x0,       0,         1,            0,         0x0,         1,        1,      0x3,       0,         1,      '?') #recv msg
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #accept MISO msg push
  t( dut,  1,        1,        1,       0x3,       0,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #accept MISO msg pull
  
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x2,         1,        1,      0x1,       0,         1,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x2,         0,        1,      0x1,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x2) #read both queues push
  t( dut,  1,        1,        1,       0x1,       0,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #read both queues pull
  
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x1,         0,        1,      0x2,       0,         0,      '?') #write mosi push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x1,         1,        1,      0x2,       1,         0,      '?') #write miso pull
  t( dut,  0,        0,        0,       0x0,       1,         1,            0,         0x2,         1,        1,      0x1,       1,         0,      '?') #write both queues push
  t( dut,  1,        0,        0,       0x0,       0,         1,            0,         0x2,         0,        0,      0x1,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        0,       0x0,       1,         0,            1,         0x0,         0,        0,      0x0,       1,         1,      0x1) #read both queues push
  t( dut,  1,        1,        1,       0x2,       0,         0,            1,         0x0,         0,        0,      0x0,       1,         1,      0x2) #read both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #read miso queues push
  t( dut,  1,        1,        1,       0x1,       0,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #read miso queues pull

  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x1,         1,        1,      0x1,       0,         0,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x1,         1,        1,      0x2,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        0,       0x0,       1,         1,            0,         0x2,         1,        0,      0x0,       1,         0,      '?') #write both queues push
  t( dut,  1,        0,        0,       0x0,       0,         1,            0,         0x2,         1,        0,      0x0,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        0,       0x0,       1,         0,            1,         0x0,         0,        0,      0x0,       1,         1,      0x1) #read both queues push
  t( dut,  1,        1,        1,       0x1,       0,         0,            1,         0x0,         0,        0,      0x0,       1,         0,      '?') #read both queues pull
  t( dut,  0,        0,        0,       0x0,       1,         1,            0,         0x3,         0,        1,      0x3,       1,         0,      '?') #write both queues push
  t( dut,  1,        0,        0,       0x0,       1,         1,            0,         0x3,         1,        1,      0x3,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        0,       0x0,       1,         0,            1,         0x0,         0,        0,      0x0,       1,         1,      0x2) #read both queues push
  t( dut,  1,        1,        1,       0x2,       0,         0,            1,         0x0,         0,        0,      0x0,       1,         0,      '?') #read both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         0,      '?') #read both queues push
  t( dut,  1,        1,        1,       0x3,       0,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x3) #read both queues pull

def test_queue_len5( cmdline_opts ):

  dut = SPIMinionAdapterRTL(4, 5)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.pull.en @= 0
  dut.push.en @= 0
  dut.push.msg.val_rd @= 0
  dut.push.msg.val_wrt @= 0
  dut.push.msg.data @= 0
  dut.recv.val @= 0
  dut.recv.msg @= 0
  dut.send.rdy @= 0
  dut.sim_reset()
  
  # Test vectors
  #     pull_en, pull_val, pull_spc, pull_data, push_en, push_val_wrt, push_val_rd, push_data, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg 
  t( dut,  0,        0,        1,       0x0,       0,         0,            0,         0x0,         0,        1,      0x0,       0,         0,      '?') #init
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x3,         0,        1,      0x0,       0,         0,      '?') #MOSI msg push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x3,         0,        1,      0x0,       1,         0,      '?') #MOSI msg pull
  t( dut,  0,        0,        1,       0x0,       0,         1,            0,         0x0,         0,        1,      0x0,       1,         1,      0x3) #send msg
  
  t( dut,  0,        0,        1,       0x0,       0,         1,            0,         0x0,         1,        1,      0x3,       0,         1,      '?') #recv msg
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #accept MISO msg push
  t( dut,  1,        1,        1,       0x3,       0,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #accept MISO msg pull
  
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x2,         1,        1,      0x1,       0,         1,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x2,         0,        1,      0x1,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x2) #read both queues push
  t( dut,  1,        1,        1,       0x1,       0,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #read both queues pull
  
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x1,         0,        1,      0x2,       0,         0,      '?') #write mosi push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x1,         1,        1,      0x2,       1,         0,      '?') #write miso pull
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x2,         1,        1,      0x1,       1,         0,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x2,         0,        1,      0x1,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x1) #read both queues push
  t( dut,  1,        1,        1,       0x2,       0,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x2) #read both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #read miso queues push
  t( dut,  1,        1,        1,       0x1,       0,         0,            1,         0x0,         0,        1,      0x0,       0,         1,      '?') #read miso queues pull

  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x1,         1,        1,      0x1,       0,         0,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x1,         1,        1,      0x2,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x2,         1,        1,      0x3,       1,         0,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       0,         1,            0,         0x2,         1,        1,      0x0,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x1) #read both queues push
  t( dut,  1,        1,        1,       0x1,       0,         0,            1,         0x0,         0,        1,      0x0,       1,         0,      '?') #read both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         1,            0,         0x3,         0,        1,      0x3,       1,         0,      '?') #write both queues push
  t( dut,  1,        0,        1,       0x0,       1,         1,            0,         0x3,         1,        1,      0x3,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x2) #read both queues push
  t( dut,  1,        1,        1,       0x2,       0,         0,            1,         0x0,         0,        1,      0x0,       1,         0,      '?') #read both queues pull
  t( dut,  0,        0,        1,       0x0,       1,         0,            1,         0x0,         0,        1,      0x0,       1,         0,      '?') #read both queues push
  t( dut,  1,        1,        1,       0x3,       0,         0,            1,         0x0,         0,        1,      0x0,       1,         1,      0x3) #read both queues pull


def test_more_bits( cmdline_opts ):

  dut = SPIMinionAdapterRTL(6, 1)
  dut = config_model_with_cmdline_opts( dut, cmdline_opts, duts=[] )
  dut.apply( DefaultPassGroup( linetrace=True ) )

  dut.pull.en @= 0
  dut.push.en @= 0
  dut.push.msg.val_rd @= 0
  dut.push.msg.val_wrt @= 0
  dut.push.msg.data @= 0
  dut.recv.val @= 0
  dut.recv.msg @= 0
  dut.send.rdy @= 0
  dut.sim_reset()
  
  # Test vectors
  #       pull_en, pull_val, pull_spc, pull_data, push_en, push_val_wrt, push_val_rd, push_data, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg 
  t( dut,  0,        0,        1,       0x0,       0,         0,            0,         0x0,         0,        1,      0x0,       0,         0,      '?') #init
  t( dut,  0,        0,        0,       0x0,       1,         1,            0,         0xF,         1,        1,      0xE,       0,         0,      '?') #write both queues push
  t( dut,  1,        0,        0,       0x0,       0,         1,            0,         0xF,         1,        0,      0xE,       1,         0,      '?') #write both queues pull
  t( dut,  0,        0,        0,       0x0,       1,         0,            1,         0x0,         0,        0,      0x0,       1,         1,      0xF) #read both queues push
  t( dut,  1,        1,        1,       0xE,       1,         0,            1,         0x0,         0,        0,      0x0,       0,         1,      '?') #read both queues pull
  

# Helper function
def t( dut, pull_en, pull_val, pull_spc, pull_data, push_en, push_val_wrt, push_val_rd, push_data, recv_val, recv_rdy, recv_msg, send_val, send_rdy, send_msg ):

  # Write input value to input port
  dut.pull.en @= pull_en
  dut.push.en @= push_en
  dut.push.msg.val_wrt @= push_val_wrt
  dut.push.msg.val_rd @= push_val_rd
  dut.push.msg.data @= push_data
  dut.recv.val @= recv_val
  dut.recv.msg @= recv_msg
  dut.send.rdy @= send_rdy
  dut.sim_eval_combinational()

  assert dut.pull.msg.data == pull_data

  if pull_val != '?':
    assert dut.pull.msg.val == pull_val
  
  if pull_spc != '?':
    assert dut.pull.msg.spc == pull_spc

  if recv_rdy != '?':
     assert dut.recv.rdy == recv_rdy

  if send_val != '?':
    assert dut.send.val == send_val

  if send_msg != '?':
    assert dut.send.msg == send_msg

  # Tick simulator one cycle
  dut.sim_tick()