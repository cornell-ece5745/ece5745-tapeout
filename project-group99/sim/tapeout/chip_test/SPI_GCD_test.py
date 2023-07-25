#=========================================================================
# GcdUnitRTL_test
#=========================================================================

import pytest
import os

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_sim

from tut3_pymtl.gcd.GcdUnitRTL import GcdUnitRTL

# Reuse tests from FL model

from tut3_pymtl.gcd.test.GcdUnitFL_test import TestHarness, test_case_table
# from tapeout.chip_test.SPI_TestHarness_Output import SPITestHarness
from SPI_v3.components.SPITestHarness import SPITestHarness
from tapeout.SPI_TapeOutBlockRTL import SPI_TapeOutBlockRTL
# from tapeout.grp_99_SPI_TapeOutBlockRTL_32bits_5entries import grp_99_SPI_TapeOutBlockRTL_32bits_5entries

def get_req_resp(file_path):
    '''
    This function generates the requests and responses
    to be sent to t_mult_msg from the data in the given
    file

    Preconditions: file_path must be an absolute path to
    a .txt file of the given template:

    Request-Response:
    <Req1>-<Resp1>
    <Req2>-<Resp2>
    ...

    '''

    file = open(file_path, "r")
    first_line = True
    requests = []
    responses = []
    for line in file:
        if not first_line:
            data_text = line.strip()
            data = data_text.split("-")
            data = [Bits32(int(x,16)) for x in data]
            requests.append(data[0])
            responses.append(data[1])
        else:
            first_line = False
    file.close()
    return (requests, responses)

#-------------------------------------------------------------------------
# Test cases
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test_gcd_rtl( test_params, cmdline_opts ):
  harness = SPITestHarness( SPI_TapeOutBlockRTL(),    1,           34,   cmdline_opts)

  harness.dut.loopthrough_sel @= 0 # passthrough mode

  requests  = [] # Create empty list for requests
  responses = [] # Create empty list for responses

  requests  = test_params.msgs[::2]
  responses = test_params.msgs[1::2]
 
  for i in range(len(requests)):
      requests[i] = concat(requests[i].a, requests[i].b)
  
  for i in range(len(responses)):
      responses[i] = sext(responses[i], 32)

  harness.t_mult_msg(32, requests, 32, responses)

def test_gcd_file( cmdline_opts ):
  harness = SPITestHarness( SPI_TapeOutBlockRTL(),    1,           34,   cmdline_opts)

  harness.dut.loopthrough_sel @= 0 # passthrough mode

  file_dir = os.path.dirname(os.path.realpath(__file__))
  requests, responses = get_req_resp( os.path.join( file_dir, "GCD_Data.txt" ) )
  harness.t_mult_msg(32, requests, 32, responses)
