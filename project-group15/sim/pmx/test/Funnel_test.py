#=========================================================================
# Funnel_test.py
#=========================================================================

from pymtl3      import *
from pymtl3.stdlib.mem import mk_mem_msg
from pymtl3.stdlib.test_utils import TestVectorSimulator
from pmx.Funnel import Funnel

#-------------------------------------------------------------------------
# test_basic_2x1
#-------------------------------------------------------------------------
# Test driver for the Funnel model with two inputs

def test_basic_2x1( cmdline_opts ):

  msg = mk_mem_msg(8,32,32)[1]

  # Instantiate and elaborate the model
  model = Funnel( msg, 2 )

  # Helper function
  def tv_in( m, tv ):
    m.in_[0].val @= tv[0]
    m.in_[0].msg @= tv[1]
    m.in_[1].val @= tv[2]
    m.in_[1].msg @= tv[3]
    m.out.rdy    @= tv[4]

  def tv_out( m, tv ):
    m.in_[0].rdy == tv[5]
    m.in_[1].rdy == tv[6]
    m.out.val    == tv[7]
    m.out.msg    == tv[8]

  # Cycle-by-cycle tests
  tv = [
    # in_[0]    in_[0]    in_[1]    in_[1]        out   in_[0] in_[1] out        out
    # .val      .msg       .en      .msg          rdy     .rdy   .rdy val        msg
    [  1,   msg(1,0,1,0,2),  1,   msg(1,0,2,0,7),  1,       1,     1,  1, msg(1,0,1,0,2)],
    [  1,   msg(1,0,1,0,3),  0,   msg(1,0,2,0,8),  1,       1,     0,  1, msg(1,1,2,0,7)],
    [  0,   msg(1,0,1,0,4),  1,   msg(1,0,2,0,8),  0,       0,     1,  0, msg(0,0,0,0,0)],
    [  0,   msg(1,0,1,0,4),  0,   msg(1,0,2,0,8),  1,       0,     0,  1, msg(1,0,1,0,3)],
    [  1,   msg(1,0,1,0,4),  0,   msg(1,0,2,0,9),  1,       1,     0,  1, msg(1,1,2,0,8)],
    [  0,   msg(1,0,1,0,5),  0,   msg(1,0,2,0,9),  1,       0,     1,  1, msg(1,0,1,0,4)],
    [  1,   msg(1,0,1,0,5),  0,   msg(1,0,2,0,9),  1,       1,     1,  1, msg(1,0,1,0,5)],
  ]

  sim = TestVectorSimulator( model, tv, tv_in, tv_out )
  sim.run_test( cmdline_opts )
