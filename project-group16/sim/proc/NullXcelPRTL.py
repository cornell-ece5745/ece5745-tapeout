#=========================================================================
# Null Accelerator Model
#=========================================================================
# This is an empty accelerator model. It includes a single 32-bit
# register named xr0 for testing purposes. It includes a memory
# interface, but this memory interface is not used. The model is
# synthesizable and can be combined with an processor RTL model.
#
# We use a two-input normal queue to buffer up the xcelreq. This
# eliminates any combinational loops when composing the accelerator with
# the processor. We combinationally connect the en/rdy from the dequeue
# interface of the xcelreq queue to the xcelresp interface. Essentially,
# an xcelreq is buffered up and waits in the queue until the xcelresp
# interface is ready to accept it.
#
# We directly connect the data from an xcelreq to the input of the xr0
# register, and ideally we would directly connect the output of the xr0
# register to the data of an xcelresp; this would work fine because there
# is only a single accelerator register. So if we are reading or writing
# an accelerator register it must be that one. There is one catch though.
# We don't really have wildcards in our test sources, so it is easier if
# we force the xcelresp data to zero on a write. So we have a little bit
# of muxing to do this.
#
# The final part is that we need to figure out when to set the enable on
# the xr0 register. This register is enabled when the transaction at the
# head of the xcelreq queue is a write and when the xcelresp interface is
# ready.
#

from pymtl3 import *
from pymtl3.stdlib.mem  import mk_mem_msg
from pymtl3.stdlib import stream
from pymtl3.stdlib.basic_rtl import RegEn

from .XcelMsg import XcelReqMsg, XcelRespMsg, XCEL_TYPE_READ, XCEL_TYPE_WRITE

class NullXcelPRTL( Component ):

  # Constructor

  def construct( s ):

    # Interface

    s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )
    s.mem  = stream.ifcs.MasterIfcRTL( *mk_mem_msg(8,32,32) )

    # Queues

    s.xcelreq_q = stream.NormalQueueRTL( XcelReqMsg, 2 )
    s.xcelreq_q.recv //= s.xcel.req

    # Single accelerator register

    s.xr0 = RegEn( Bits32 )

    # Direct connections for xcelreq/xcelresp

    s.xr0.in_             //= s.xcelreq_q.send.msg.data
    s.xcel.resp.msg.type_ //= s.xcelreq_q.send.msg.type_

    # Even though memreq/memresp interface is not hooked up, we still
    # need to set the output ports correctly.

    s.mem.req.val  //= 0
    s.mem.req.msg  //= mk_mem_msg(8,32,32)[0]()
    s.mem.resp.rdy //= 0

    s.xcel.resp.val //= s.xcelreq_q.send.val
    s.xcel.resp.rdy //= s.xcelreq_q.send.rdy

    # Combinational block

    @update
    def block():

      # Mux to force xcelresp data to zero on a write
      # Enable xr0 only upon write requests and both val/rdy on resp side

      if s.xcelreq_q.send.msg.type_ == XCEL_TYPE_WRITE:
        s.xr0.en @= s.xcel.resp.val & s.xcel.resp.rdy
        s.xcel.resp.msg.data @= 0
      else:
        s.xr0.en @= 0
        s.xcel.resp.msg.data @= s.xr0.out

  # Line tracing

  def line_trace( s ):
    return f"{s.xcel}"

