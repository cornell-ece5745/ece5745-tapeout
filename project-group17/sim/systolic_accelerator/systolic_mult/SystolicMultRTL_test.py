#=========================================================================
# SystolicMult_test
#=========================================================================

import pytest 
import random
import struct 
import numpy as np

random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.test_utils import run_test_vector_sim, mk_test_case_table, run_sim
from systolic_accelerator.systolic_mult.SystolicMultRTL import SystolicMultRTL
from systolic_accelerator.systolic_mult.SystolicMsgs    import SystolicMsgs

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s ):

    # instantiate models

    s.src  = stream.SourceRTL( SystolicMsgs.recv )
    s.sink = stream.SinkRTL( SystolicMsgs.send ) 
    s.dut = SystolicMultRTL()

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

def recv( w0, w1, inp0, inp1, mode, run, run_final ):
  return SystolicMsgs.recv( w0, w1, inp0, inp1, mode, run, run_final )

def send( r0, r1 ):
  return SystolicMsgs.send( r0, r1 )

# make_msgs: works for formal_test 
def make_msgs( weight, data ):
  length = len(weight[0])
  multiple = 2**FRAC_WIDTH
  fix_data = []
  fix_weight = [[],[]]
  for i in range(length):
    fix_data.append([int(hex(int(x * (multiple))), 16) for x in data[i]])
  fix_weight[0] = [int(hex(int(x * (multiple))), 16) for x in weight[0]]
  fix_weight[1] = [int(hex(int(x * (multiple))), 16) for x in weight[1]]

  print(len(fix_data[0]))
  print(len(fix_data))
  print(fix_data)

  fix_answer = []
  for i in range(2):
    tmp_lst = []
    for j in range(2):
      tmp = 0
      for k in range(length):
        tmp += (fix_weight[i][k]*fix_data[k][j]) >> FRAC_WIDTH
      tmp_lst.append((int)(tmp))
    fix_answer.append(tmp_lst)

  msgs_0 = [
    recv( 0x00000,           0x0,              0x00000,         0x0,             0x1, 0x1, 0x1 ), 
    recv( fix_weight[0][0],  0x0,              fix_data[0][0],  0x0,             0x0, 0x0, 0x0 ), 
    ]
  msgs_1 = [
    recv( fix_weight[0][1+n],  fix_weight[1][0+n], fix_data[1+n][0],  fix_data[0+n][1],  0x0, 0x0, 0x0 ) for n in range(length-1)
    ]
  msgs_2 = [
    recv( 0x0,               fix_weight[1][length-1], 0x0,             fix_data[length-1][1],  0x0, 0x0, 0x0 ), 
    recv( 0x00000,           0x0,              0x00000,         0x0,             0x0, 0x0, 0x0 ), 
    send(fix_answer[1][0], fix_answer[1][1]),
    send(fix_answer[0][0], fix_answer[0][1]),
    ]
  msgs = msgs_0 + msgs_1 + msgs_2
  return msgs

#----------------------------------------------------------------------
# Test Case: formal_test 
#----------------------------------------------------------------------

formal_weight = [[1,  2,   1,  2, -2, 4  ], 
                 [2, -1.5, 2, -1.5, 3 ,-1]]

formal_data = [[1,   -2.5], 
               [1.5,  2.5],
               [1,   -2.5], 
               [1.5,  2.5],
               [1,   -3.5], 
               [2.5,  1.5]]

truncate_weight = [[1,  2,   0, 0, 0, 0], 
                   [2, -1.5, 0, 0, 0, 0]]

truncate_data = [[1,   -2.5], 
                 [1.5,  2.5],
                 [0,    0  ], 
                 [0,    0  ],
                 [0,    0  ], 
                 [0,    0  ]]

interleaving_weight = [[1,  2,   0, 0, -2, 4], 
                       [2, -1.5, 0, 0, 3 ,-1]]

interleaving_data = [[1,   -2.5 ], 
                     [1.5, 2.5 ],
                     [0,   0   ], 
                     [0,   0   ],
                     [1,   -3.5], 
                     [2.5, 1.5 ]]

#-------------------------------------------------------------------------
# test_case_table: 
# Note that the accommodation for delays are accommodated by "higher"
# modules in module hierarchy 
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
  (                  "msgs                                 "),
  [ "full_test",   make_msgs(formal_weight, formal_data)  ],
  [ "truncate_test",   make_msgs(truncate_weight, truncate_data)  ],
  [ "interleaving_test",   make_msgs(interleaving_weight, interleaving_data)  ],
])

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test( test_params, cmdline_opts ):

  th = TestHarness()

  th.set_param("top.src.construct", msgs=test_params.msgs[:-2:])
  
  th.set_param("top.sink.construct", msgs=test_params.msgs[-2::])
  
  run_sim( th, cmdline_opts, duts=['dut'] )


def test_multiple(cmdline_opts):

  th = TestHarness()

  weight = [[1, 2, 1, 2.3, 1, 2.1, -2, 4.2, 4 ,-1, 2, 1], 
              [2, -1.5, 3.4, -2.33, 2, -1.5, 2, -1.5, 3, -1, -3.6, 2.2]]

  data = [[1,   -2.5], 
              [1.5, 2.5],
              [2,   4], 
              [3, -10],
              [1,   -2.5], 
              [1.5, 2.5],
              [2,   4], 
              [3, -10],
              [1,   -2.5], 
              [1.5, 2.5],
              [2,   4], 
              [3, -10]]

  length = len(weight[0])
  multiple = 2**FRAC_WIDTH
  fix_data = []
  fix_weight = [[],[]]
  for i in range(length):
    fix_data.append([int(hex(int(x * (multiple))), 16) for x in data[i]])
  fix_weight[0] = [int(hex(int(x * (multiple))), 16) for x in weight[0]]
  fix_weight[1] = [int(hex(int(x * (multiple))), 16) for x in weight[1]]

  fix_answer = []
  for i in range(2):
    tmp_lst = []
    for j in range(2):
      tmp = 0
      for k in range(length):
        tmp += (fix_weight[i][k]*fix_data[k][j]) >> FRAC_WIDTH
      tmp_lst.append((int)(tmp))
    fix_answer.append(tmp_lst)

  print(fix_weight)
  print(fix_data)

  msgs_0 = [
    recv( 0x00000,           0x0,              0x00000,         0x0,             0x1, 0x1, 0x0 ), 
    recv( fix_weight[0][0],  0x0,              fix_data[0][0],  0x0,             0x0, 0x0, 0x0 ), 
    ]
  msgs_1 = [
    recv( fix_weight[0][1+n],  fix_weight[1][0+n], fix_data[1+n][0],  fix_data[0+n][1],  0x0, 0x0, 0x0 ) for n in range((length>>1)-1)
    ]
  msgs_2 = [
    recv( 0x0,               fix_weight[1][(length>>1)-1], 0x0,             fix_data[(length>>1)-1][1],  0x0, 0x0, 0x0 ), 
    ]
  msgs_3 = [
    recv( 0x00000,           0x0,              0x00000,         0x0,             0x1, 0x1, 0x1 ), 
    recv( fix_weight[0][6],  0x0,              fix_data[6][0],  0x0,             0x0, 0x0, 0x0 ), 
    ]
  msgs_4 = [
    recv( fix_weight[0][7+n],  fix_weight[1][6+n], fix_data[7+n][0],  fix_data[6+n][1],  0x0, 0x0, 0x0 ) for n in range((length>>1)-1)
    ]
  msgs_5 = [
    recv( 0x0,               fix_weight[1][6+(length>>1)-1], 0x0,             fix_data[6+(length>>1)-1][1],  0x0, 0x0, 0x0 ), 
    send(fix_answer[1][0], fix_answer[1][1]),
    send(fix_answer[0][0], fix_answer[0][1]),
    ]

  final_msg = msgs_0 + msgs_1 + msgs_2 + msgs_3 + msgs_4 + msgs_5
  
  th.set_param("top.src.construct", msgs=final_msg[:-2])

  th.set_param("top.sink.construct", msgs=final_msg[-2:])

  run_sim( th, cmdline_opts, duts=['dut'] )
