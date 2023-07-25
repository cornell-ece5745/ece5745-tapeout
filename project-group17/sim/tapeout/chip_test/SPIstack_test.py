'''
==========================================================================
SPIstack_test.py
==========================================================================
Simple loopback test for SPIstack in the context of the SPI_TapeOutBlock,
this time using the SPITestHarness. Note that this test will fail until
you connect your block to this one.
'''
import pytest
import random
import numpy as np

from pymtl3 import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from tapeout.SPI_TapeOutBlockRTL import SPI_TapeOutBlockRTL
from SPI_v3.components.SPITestHarness import SPITestHarness
from tapeout.block_test.WrapperMsgs import *

BITWIDTH_INT = 16
FRAC_WIDTH = 8

def recv( data, chip_select, mode, run, run_final ):
  return  ((data << 7) | chip_select << 3 | mode << 2 | run << 1 | run_final) \
    & 8388607 # 23'h7F_FFFF
  # return WrapperMsgs.recv( data, chip_select, mode, run, run_final )

def send( r0, r1 ):
  return ((r0 & 65535) << BITWIDTH_INT) | (r1 & 65535) # 32'h0000FFFF
  # return WrapperMsgs.send( r0, r1 )

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
  recv_msg = []

  recv_msg_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b0)]
  recv_msg_final_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b1)]
  send_msg = [send(fix_answer[1][0], fix_answer[1][1]), send(fix_answer[0][0], fix_answer[0][1])]

  for m in range(int(len/2)):
    recv_msg_0 = [recv( fix_weight[0][n+m*2], 0b0001, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_1 = [recv( fix_weight[1][n+m*2], 0b0010, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_2 = [recv( fix_data[n+m*2][0], 0b0100, 0b0, 0b0, 0b0) for n in range(2)]
    recv_msg_3 = [recv( fix_data[n+m*2][1], 0b1000, 0b0, 0b0, 0b0) for n in range(2)]
    if m != len/2-1:
      recv_msg = recv_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3 + recv_msg_run
    else:
      recv_msg = recv_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3

  recv_msg = recv_msg + recv_msg_final_run

  return recv_msg, send_msg

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
  recv_msg = []

  recv_msg_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b0)]
  recv_msg_final_run = [recv( 0x00000, 0b1111, 0b1, 0b1, 0b1)]
  send_msg = [send(fix_answer[1][0], fix_answer[1][1]), send(fix_answer[0][0], fix_answer[0][1])]

  for m in range(int(len/DATA_ENTRIES)):
    recv_msg_0 = [recv( fix_data[0][n+m*DATA_ENTRIES], 0b0001, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    recv_msg_1 = [recv( fix_data[1][n+m*DATA_ENTRIES], 0b0010, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    recv_msg_2 = [recv( fix_weight[n+m*DATA_ENTRIES][0], 0b0100, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    recv_msg_3 = [recv( fix_weight[n+m*DATA_ENTRIES][1], 0b1000, 0b0, 0b0, 0b0) for n in range(DATA_ENTRIES)]
    if m != len/DATA_ENTRIES-1:
      recv_msg = recv_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3 + recv_msg_run
    else:
      recv_msg = recv_msg + recv_msg_0 + recv_msg_1 + recv_msg_2 + recv_msg_3

  recv_msg = recv_msg + recv_msg_final_run

  return recv_msg, send_msg

def test_loopback( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 1 # loopback mode

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses
  for i in range(10):
    requests.append(i*10)
    responses.append(i*10)

def test_2x2( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0 # loopback mode

  weight_2x2 = [[2, 4],
              [-1.5, 3.4]]

  data_2x2 = [[1,   -2.5],
            [1.5, 2.5]]

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses

  requests, responses = make_msgs(weight_2x2, data_2x2, len(weight_2x2[0]))

  harness.t_mult_msg(32, requests, 32, responses)

def test_2x4( cmdline_opts ):

  harness = SPITestHarness(SPI_TapeOutBlockRTL(), 1, 34, cmdline_opts)
  harness.dut.loopthrough_sel @= 0 # loopback mode

  weight_2x4 = [[1, 2, 4 ,-1],
              [2, -1.5, 3.4, -2.33]]

  data_4x2 = [[1,   -2.5],
            [1.5, 2.5],
            [2,   4],
            [3, -10]]

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses

  requests, responses = make_msgs(weight_2x4, data_4x2, len(weight_2x4[0]))

  harness.t_mult_msg(32, requests, 32, responses)

# def test_very_long( cmdline_opts ):

#   # InstantiateTest Harness         DUT               # components  spi_bits
#   harness = SPITestHarness(SPI_TapeOutBlockRTL(32, 5), 1, 34, cmdline_opts)
#   harness.dut.loopthrough_sel @= 0 # loopback mode

#   requests, responses = make_very_long_msgs()

#   harness.t_mult_msg(32, requests, 50, responses)
