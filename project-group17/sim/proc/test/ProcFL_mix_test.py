#=========================================================================
# ProcFL_mix_test.py
#=========================================================================

import pytest

from pymtl3   import *
from .harness import *
from proc.ProcFL import ProcFL

#-------------------------------------------------------------------------
# jal_beq
#-------------------------------------------------------------------------

from . import inst_jal_beq

@pytest.mark.parametrize( "name,test", [
  asm_test( inst_jal_beq.gen_basic_test     ) ,
])
def test_jal_beq( name, test ):
  run_test( ProcFL, test )

def test_jal_beq_rand_delays():
  run_test( ProcFL, inst_jal_beq.gen_basic_test,
            src_delay=3, sink_delay=5, mem_stall_prob=0.5, mem_latency=3 )

#-------------------------------------------------------------------------
# mul_mem
#-------------------------------------------------------------------------

from . import inst_mul_mem

@pytest.mark.parametrize( "name,test", [
  asm_test( inst_mul_mem.gen_basic_test     ) ,
  asm_test( inst_mul_mem.gen_more_test      ) ,
])
def test_mul_mem( name, test ):
  run_test( ProcFL, test )

def test_mul_mem_rand_delays():
  run_test( ProcFL, inst_mul_mem.gen_more_test,
            src_delay=3, sink_delay=5, mem_stall_prob=0.5, mem_latency=3 )
