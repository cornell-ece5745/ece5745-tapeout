#=========================================================================
# ProcRTL_test.py
#=========================================================================

import pytest

from pymtl3   import *
from .harness import *
from proc.ProcRTL import ProcRTL

#-------------------------------------------------------------------------
# jal
#-------------------------------------------------------------------------

from . import inst_jal

@pytest.mark.parametrize( "name,test", [
  asm_test( inst_jal.gen_basic_test        ) ,

  # ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  # Add more rows to the test case table to test more complicated
  # scenarios.
  # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  asm_test( inst_jal.gen_link_dep_test     ) ,
  asm_test( inst_jal.gen_jump_test         ) ,
  asm_test( inst_jal.gen_back_to_back_test ) ,
  asm_test( inst_jal.gen_value_test_0      ) ,
  asm_test( inst_jal.gen_value_test_1      ) ,
  asm_test( inst_jal.gen_value_test_2      ) ,
  asm_test( inst_jal.gen_value_test_3      ) ,
  asm_test( inst_jal.gen_jal_stall_test    ) ,

  #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\
])

def test_jal( name, test, cmdline_opts ):
  run_test( ProcRTL, test, cmdline_opts=cmdline_opts )

# ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# random stall and delay
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/
def test_jal_rand_delays( cmdline_opts ):
  run_test( ProcRTL, inst_jal.gen_jump_test,
            src_delay=3, sink_delay=5, mem_stall_prob=.5, mem_latency=3, cmdline_opts=cmdline_opts )
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

#-------------------------------------------------------------------------
# jalr
#-------------------------------------------------------------------------

from . import inst_jalr

@pytest.mark.parametrize( "name,test", [
  asm_test( inst_jalr.gen_basic_test        ) ,

  # ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  # Add more rows to the test case table to test more complicated
  # scenarios.
  # ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  asm_test( inst_jalr.gen_link_dep_test     ) ,
  asm_test( inst_jalr.gen_jump_test         ) ,
  asm_test( inst_jalr.gen_lsb_test          ) ,
  asm_test( inst_jalr.gen_value_test_0      ) ,
  asm_test( inst_jalr.gen_value_test_1      ) ,
  asm_test( inst_jalr.gen_value_test_2      ) ,
  asm_test( inst_jalr.gen_value_test_3      ) ,

  #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\
])

def test_jalr( name, test, cmdline_opts ):
  run_test( ProcRTL, test, cmdline_opts=cmdline_opts )

# ''' LAB TASK '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# random stall and delay
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

def test_jalr_rand_delays( cmdline_opts ):
  run_test( ProcRTL, inst_jalr.gen_jump_test,
            src_delay=3, sink_delay=5, mem_stall_prob=.5, mem_latency=3, cmdline_opts=cmdline_opts )

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\
