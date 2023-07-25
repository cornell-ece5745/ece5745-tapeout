#=========================================================================
# ProcRTL_test.py
#=========================================================================

import pytest

from pymtl3   import *
from .harness import *
from proc.ProcRTL import ProcRTL

#-------------------------------------------------------------------------
# lw
#-------------------------------------------------------------------------

from . import inst_lw

@pytest.mark.parametrize( "name,test", [
  asm_test( inst_lw.gen_basic_test     ) ,
  asm_test( inst_lw.gen_dest_dep_test  ) ,
  asm_test( inst_lw.gen_base_dep_test  ) ,
  asm_test( inst_lw.gen_srcs_dest_test ) ,
  asm_test( inst_lw.gen_addr_test      ) ,
  asm_test( inst_lw.gen_random_test    ) ,
])
def test_lw( name, test, cmdline_opts ):
  run_test( ProcRTL, test, cmdline_opts=cmdline_opts )

def test_lw_rand_delays( cmdline_opts ):
  run_test( ProcRTL, inst_lw.gen_random_test,
            src_delay=3, sink_delay=5, mem_stall_prob=0.5, mem_latency=3, cmdline_opts=cmdline_opts )

#-------------------------------------------------------------------------
# sw
#-------------------------------------------------------------------------

from . import inst_sw

@pytest.mark.parametrize( "name,test", [
  asm_test( inst_sw.gen_basic_test     ),

  # ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  # Add more rows to the test case table to test more complicated
  # scenarios.
  # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  asm_test( inst_sw.gen_dest_dep_test  ),
  asm_test( inst_sw.gen_base_dep_test  ),
  asm_test( inst_sw.gen_src_dep_test   ),
  asm_test( inst_sw.gen_srcs_dep_test  ),
  asm_test( inst_sw.gen_srcs_dest_test ),
  asm_test( inst_sw.gen_addr_test      ),
  asm_test( inst_sw.gen_random_test    ),

  #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\
])
def test_sw( name, test, cmdline_opts ):
  run_test( ProcRTL, test, cmdline_opts=cmdline_opts )

# ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# random stall and delay
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

def test_sw_rand_delays( cmdline_opts ):
  run_test( ProcRTL, inst_sw.gen_random_test,
            src_delay=3, sink_delay=5, mem_stall_prob=0.5, mem_latency=3, cmdline_opts=cmdline_opts )

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\
