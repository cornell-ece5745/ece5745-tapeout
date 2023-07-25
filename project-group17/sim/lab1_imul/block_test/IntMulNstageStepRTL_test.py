#=========================================================================
# IntMulNstageStepRTL_test
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib.test_utils import run_test_vector_sim
from lab1_imul.IntMulNstageStepRTL import IntMulNstageStepRTL

#-------------------------------------------------------------------------
# test_basic
#-------------------------------------------------------------------------

def test_basic( cmdline_opts ):
  dut = IntMulNstageStepRTL()

  run_test_vector_sim( dut, [
    ('in_val in_a        in_b        in_result   out_val* out_a*      out_b*      out_result*'),
    [ 0,     0x00000000, 0x00000000, 0x00000000, 0,       0x00000000, 0x00000000, 0x00000000  ],
    [ 1,     0x00000000, 0x00000000, 0x00000000, 1,       0x00000000, 0x00000000, 0x00000000  ],
    [ 1,     0x10101010, 0x00000000, 0x00000000, 1,       0x20202020, 0x00000000, 0x00000000  ],
    [ 1,     0x10101010, 0x00000001, 0x00000000, 1,       0x20202020, 0x00000000, 0x10101010  ],
    [ 1,     0x10101010, 0x00000000, 0x00000001, 1,       0x20202020, 0x00000000, 0x00000001  ],
    [ 1,     0x10101010, 0x00000001, 0x00000001, 1,       0x20202020, 0x00000000, 0x10101011  ],
  ], cmdline_opts )

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------
# Create a 32b x 4b multiplier

class TestHarness( Component ):

  def construct( s ):

    s.a      = InPort(32)
    s.b      = InPort(4)
    s.result = OutPort(32)

    # Instantiate steps

    s.steps = [ IntMulNstageStepRTL() for _ in range(4) ]

    # Structural composition for first step

    s.steps[0].in_b //= lambda: zext(s.b, 32)

    s.steps[0].in_val //= 1
    s.steps[0].in_a   //= s.a
    s.steps[0].in_result //= 0

    # Structural composition for intermediate steps

    for i in range(3):
      s.steps[i+1].in_val    //= s.steps[i].out_val
      s.steps[i+1].in_a      //= s.steps[i].out_a
      s.steps[i+1].in_b      //= s.steps[i].out_b
      s.steps[i+1].in_result //= s.steps[i].out_result

    # Structural composition for last step

    s.steps[3].out_result //= s.result

  def line_trace( s ):
    return "{}:{}({} {} {} {})".format(
      s.a, s.b,
      s.steps[0].out_result,
      s.steps[1].out_result,
      s.steps[2].out_result,
      s.steps[3].out_result,
    )

#-------------------------------------------------------------------------
# test_32b_x_4b_mult
#-------------------------------------------------------------------------

def test_32b_x_4b_mult( cmdline_opts ):
  th = TestHarness()

  run_test_vector_sim( th, [
    ('a   b   result*'),
    [  0,  0,   0 ],
    [  2,  3,   6 ],
    [  4,  5,  20 ],
    [  3,  4,  12 ],
    [ 10, 13, 130 ],
    [  8,  7,  56 ],
  ], cmdline_opts, [f'steps[{i}]' for i in range(4)] )
