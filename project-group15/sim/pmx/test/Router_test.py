#=========================================================================
# Router_test.py
#=========================================================================

from pymtl3      import *
from pymtl3.stdlib.mem import mk_mem_msg
from pymtl3.stdlib.test_utils import TestVectorSimulator
from pmx.Router import Router

#-------------------------------------------------------------------------
# test_basic_1x2
#-------------------------------------------------------------------------
# Test driver for the Router model with two inputs

def test_basic_1x2( cmdline_opts ):

  msg = mk_mem_msg(8,32,32)[1]

  # Instantiate and elaborate the model
  model = Router( msg, 2 )

  # Helper function
  def tv_in( m, tv ):
    m.in_.val    @= tv[0]
    m.in_.msg    @= tv[1]
    m.out[0].rdy @= tv[2]
    m.out[1].rdy @= tv[3]

  def tv_out( m, tv ):
    assert tv[4] == '?' or m.in_.rdy    == tv[4]
    assert tv[5] == '?' or m.out[0].val == tv[5]
    assert tv[6] == '?' or m.out[0].msg == tv[6]
    assert tv[7] == '?' or m.out[1].val == tv[7]
    assert tv[8] == '?' or m.out[1].msg == tv[8]

  tv = [
    # in_      in_         out[0] out[1]  in_  out[0]     out[0]    out[1]    out[1]
    # .val     .msg        .rdy    rdy    .rdy  .val      .msg      .val      .msg
    [ 1,  msg(0,0,0,0,4),     1,    1,     1,   1, msg(0,0,0,0,4),  0, msg(0,0,0,0,0)],
    [ 1,  msg(0,1,0,0,5),     1,    1,     1,   0, msg(0,0,0,0,0),  1, msg(0,1,0,0,5)],
    [ 0,  msg(0,1,0,0,5),     1,    1,     1,   0, '?',             0, '?'           ],
    [ 1,  msg(0,1,0,0,6),     1,    1,     1,   0, msg(0,0,0,0,0),  1, msg(0,1,0,0,6)],
    [ 1,  msg(0,0,0,0,7),     0,    1,     0,   1, msg(0,0,0,0,7),  0, msg(0,0,0,0,0)],
    [ 0,  msg(0,1,0,0,8),     0,    1,     1,   0, '?',             0, '?'           ],
    [ 0,  msg(0,1,0,0,8),     1,    1,     1,   0, '?',             0, '?'           ],
    [ 1,  msg(0,1,0,0,9),     0,    1,     1,   0, msg(0,0,0,0,0),  1, msg(0,1,0,0,9)],
  ]

  sim = TestVectorSimulator( model, tv, tv_in, tv_out )
  sim.run_test( cmdline_opts )
