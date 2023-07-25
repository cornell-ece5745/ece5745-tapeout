#=========================================================================
# WrapperRTL_test.py
#=========================================================================

import pytest 
import random
import struct 
import numpy as np

random.seed(0xdeadbeef)

from pymtl3                   import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.test_utils import run_test_vector_sim, mk_test_case_table, run_sim
from systolic_accelerator.top.WrapperRTL import WrapperRTL
from systolic_accelerator.top.WrapperMsgs    import *

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s ):

    # instantiate models

    s.src  = stream.SourceRTL( WrapperMsgs.recv )
    s.sink = stream.SinkRTL( WrapperMsgs.send ) 
    s.dut = WrapperRTL()

    # connect
    s.src.send //= s.dut.recv
    s.dut.send //= s.sink.recv

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.dut.line_trace()

#-------------------------------------------------------------------------
# make messages
#-------------------------------------------------------------------------

FRAC_WIDTH = 8

def recv( data, chip_select, mode, run, run_final ):
  return WrapperMsgs.recv( data, chip_select, mode, run, run_final )

def send( r0, r1 ):
  return WrapperMsgs.send( r0, r1 )

def make_very_long_msgs():
  len = 784

  # read in trained data in fixed point
  WEIGHTPATH_0 = "../../python/data/systolic_array_inputs/fixed_point/pe0_fc1_fixed.dat"
  WEIGHTPATH_1 = "../../python/data/systolic_array_inputs/fixed_point/pe1_fc1_fixed.dat"
  DATAPATH_0 = "../../python/data/systolic_array_inputs/fixed_point/pe0_img_fixed.dat"
  DATAPATH_1 = "../../python/data/systolic_array_inputs/fixed_point/pe1_img_fixed.dat"
  
  weight_0 = np.genfromtxt(WEIGHTPATH_0, delimiter=",")
  weight_1 = np.genfromtxt(WEIGHTPATH_1, delimiter=",")
  data_0 = np.genfromtxt(DATAPATH_0, delimiter=",")
  data_1 = np.genfromtxt(DATAPATH_1, delimiter=",")
  weight = np.vstack((weight_0, weight_1)).T
  data = np.vstack((data_0, data_1)).T
  fix_weight = weight[:784].astype('int')
  fix_data = data[:784].reshape(-1, 784).astype('int')

  fix_answer = []
  for i in range(2):
    tmp_lst = []
    for j in range(2):
      tmp = 0
      for k in range(784):
        tmp += (fix_data[i][k]*fix_weight[k][j]) >> FRAC_WIDTH
      tmp_lst.append((int)(tmp))
    fix_answer.append(tmp_lst)

  fix_data = fix_data.tolist()
  fix_weight = fix_weight.tolist()
  final_msg = []

  recv_msg_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b0)]
  recv_msg_final_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b1)]
  send_msg = [send(fix_answer[1][0], fix_answer[1][1]), send(fix_answer[0][0], fix_answer[0][1])]

  for m in range(int(len/DATA_ENTRIES)):
    recv_msg_0 = [recv( fix_data[0][n+m*DATA_ENTRIES], 0b0001, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    recv_msg_1 = [recv( fix_data[1][n+m*DATA_ENTRIES], 0b0010, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    recv_msg_2 = [recv( fix_weight[n+m*DATA_ENTRIES][0], 0b0100, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    recv_msg_3 = [recv( fix_weight[n+m*DATA_ENTRIES][1], 0b1000, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    if m != len/DATA_ENTRIES-1:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3 + recv_msg_run
    else:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3

  final_msg = final_msg + recv_msg_final_run + send_msg

  return final_msg

def make_msgs( weight, data, len):
  fix_data = np.array(data)
  fix_weight = np.array(weight)
  fix_data = fix_data.astype('int') << FRAC_WIDTH
  fix_data = fix_data.tolist()
  fix_weight = fix_weight.astype('int') << FRAC_WIDTH
  fix_weight = fix_weight.tolist()
  fix_answer = np.matmul(fix_weight, fix_data)
  fix_answer = fix_answer.astype('int') >> FRAC_WIDTH
  fix_answer = fix_answer.tolist()
  final_msg = []

  recv_msg_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b0)]
  recv_msg_final_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b1)]
  send_msg = [send(fix_answer[1][0], fix_answer[1][1]), send(fix_answer[0][0], fix_answer[0][1])]

  for m in range(int(len/2)):
    recv_msg_0 = [recv( fix_weight[0][n+m*2], 0b0001, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_1 = [recv( fix_weight[1][n+m*2], 0b0010, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_2 = [recv( fix_data[n+m*2][0], 0b0100, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_3 = [recv( fix_data[n+m*2][1], 0b1000, 0b0, 0b0, 0b0) for n in range(2)]
    if m != len/2-1:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3 + recv_msg_run
    else:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3

  final_msg = final_msg + recv_msg_final_run + send_msg

  return final_msg



#----------------------------------------------------------------------
# Test Case: initial_test 
#----------------------------------------------------------------------
weight_2x4 = [[1, 2, 4 ,-1], 
              [2, -1.5, 3.4, -2.33]]

data_4x2 = [[1,   -2.5], 
            [1.5, 2.5],
            [2,   4], 
            [3, -10]]

weight_2x2 = [[2, 4], 
              [-1.5, 3.4]]

data_2x2 = [[1,   -2.5], 
            [1.5, 2.5]]

#-------------------------------------------------------------------------
# test_case_table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  ( "                              msgs                                                 src_delay              sink_delay"          ),
  # [ "very_long_data_no_delay",     make_very_long_msgs(),                               0,                     0                    ],
  # [ "very_long_data_random_delay", make_very_long_msgs(),                               random.randint(1, 10), random.randint(1, 10)],
  [ "2x2_data_no_delay",           make_msgs(weight_2x2, data_2x2, len(weight_2x2[0])), 0,                     0                    ],
  [ "2x2_data_random_delay",       make_msgs(weight_2x2, data_2x2, len(weight_2x2[0])), random.randint(1, 10), random.randint(1, 10)],
  [ "4x2_data_no_delay",           make_msgs(weight_2x4, data_4x2, len(weight_2x4[0])), 0,                     0                    ],
  [ "4x2_data_random_delay",       make_msgs(weight_2x4, data_4x2, len(weight_2x4[0])), random.randint(1, 10), random.randint(1, 10)],
])

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):
  th = TestHarness()

  th.set_param("top.src.construct", msgs=test_params.msgs[:-2], 
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )
  
  th.set_param("top.sink.construct", msgs=test_params.msgs[-2:],
    initial_delay=test_params.src_delay,
    interval_delay=test_params.src_delay )
  
  run_sim( th, cmdline_opts, duts=['dut'] )

def test_multiple(cmdline_opts):
  th = TestHarness()

  weight_2x4 = [[1, 2, 4 ,-1], 
              [2, -1.5, 3.4, -2.33]]

  data_4x2 = [[1,   -2.5], 
              [1.5, 2.5],
              [2,   4], 
              [3, -10]]

  fix_data = np.array(data_4x2)
  fix_weight = np.array(weight_2x4)
  fix_data = (fix_data * 2**FRAC_WIDTH).astype('int')
  fix_weight = (fix_weight * 2**FRAC_WIDTH).astype('int')
  fix_answer = np.matmul(fix_weight, fix_data)
  fix_data = fix_data.tolist()
  fix_weight = fix_weight.tolist()
  fix_answer = fix_answer.astype('int') >> FRAC_WIDTH
  fix_answer = fix_answer.tolist()
  final_msg = []

  recv_msg_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b0)]
  recv_msg_final_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b1)]
  send_msg0 = [send(fix_answer[1][0], fix_answer[1][1]), send(fix_answer[0][0], fix_answer[0][1])]

  length = len(fix_weight[0])
  for m in range(length>>1):
    recv_msg_0 = [recv( fix_weight[0][n+m*2], 0b0001, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_1 = [recv( fix_weight[1][n+m*2], 0b0010, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_2 = [recv( fix_data[n+m*2][0], 0b0100, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_3 = [recv( fix_data[n+m*2][1], 0b1000, 0b0, 0b0, 0b0) for n in range(2)]
    if m != (length>>1)-1:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3 + recv_msg_run
    else:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3

  final_msg = final_msg + recv_msg_final_run

  weight_2x2 = [[2, 4], 
                [-1.5, 3.4]]

  data_2x2 = [[1,   -2.5], 
              [1.5, 2.5]]

  fix_data = np.array(data_2x2)
  fix_weight = np.array(weight_2x2)
  fix_data = (fix_data * 2**FRAC_WIDTH).astype('int')
  fix_weight = (fix_weight * 2**FRAC_WIDTH).astype('int')
  fix_answer = np.matmul(fix_weight, fix_data)
  fix_data = fix_data.tolist()
  fix_weight = fix_weight.tolist()
  fix_answer = fix_answer.astype('int') >> FRAC_WIDTH
  fix_answer = fix_answer.tolist()

  send_msg1 = [send(fix_answer[1][0], fix_answer[1][1]), send(fix_answer[0][0], fix_answer[0][1])]

  length = len(fix_weight[0])
  print(fix_weight)
  print(fix_data)
  for m in range(length>>1):
    recv_msg_0 = [recv( fix_weight[0][n+m*2], 0b0001, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_1 = [recv( fix_weight[1][n+m*2], 0b0010, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_2 = [recv( fix_data[n+m*2][0], 0b0100, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_3 = [recv( fix_data[n+m*2][1], 0b1000, 0b0, 0b0, 0b0) for n in range(2)]
    if m != (length>>1)-1:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3 + recv_msg_run
    else:
      final_msg = final_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3

  final_msg = final_msg + recv_msg_final_run + send_msg0 + send_msg1
  

  th.set_param("top.src.construct", msgs=final_msg[:-4], 
    # initial_delay=random.randint(1, 10),
    # interval_delay=random.randint(1, 10) 
    )

  th.set_param("top.sink.construct", msgs=final_msg[-4:],
    # initial_delay=random.randint(1, 10),
    # interval_delay=random.randint(1, 10) 
    )

  run_sim( th, cmdline_opts, duts=['dut'] )