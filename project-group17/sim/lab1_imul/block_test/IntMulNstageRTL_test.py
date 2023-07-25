#=========================================================================
# IntMulNstageRTL_test
#=========================================================================

import pytest

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_sim
from lab1_imul.IntMulNstageRTL import IntMulNstageRTL

#-------------------------------------------------------------------------
# Reuse tests from fixed-latency RTL model
#-------------------------------------------------------------------------

from .IntMulFixedLatRTL_test import TestHarness, test_case_table

@pytest.mark.parametrize( **test_case_table )
def test_1stage( test_params, cmdline_opts ):

  th = TestHarness( IntMulNstageRTL( nstages=1 ) )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['imul'] )

@pytest.mark.parametrize( **test_case_table )
def test_2stage( test_params, cmdline_opts ):

  th = TestHarness( IntMulNstageRTL( nstages=2 ) )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['imul'] )

@pytest.mark.parametrize( **test_case_table )
def test_4stage( test_params, cmdline_opts ):

  th = TestHarness( IntMulNstageRTL( nstages=4 ) )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['imul'] )

@pytest.mark.parametrize( **test_case_table )
def test_8stage( test_params, cmdline_opts ):

  th = TestHarness( IntMulNstageRTL( nstages=8 ) )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['imul'] )

@pytest.mark.parametrize( **test_case_table )
def test_16stage( test_params, cmdline_opts ):

  th = TestHarness( IntMulNstageRTL( nstages=16 ) )

  th.set_param("top.src.construct",
    msgs=test_params.msgs[::2],
    initial_delay=test_params.src_delay+3,
    interval_delay=test_params.src_delay )

  th.set_param("top.sink.construct",
    msgs=test_params.msgs[1::2],
    initial_delay=test_params.sink_delay+3,
    interval_delay=test_params.sink_delay )

  run_sim( th, cmdline_opts, duts=['imul'] )
