#=========================================================================
#=========================================================================
# Sort Unit RTL Model
#=========================================================================
# Sort array in memory containing positive integers.
# Accelerator register interface:
#
#  xr0 : go/done
#  xr1 : base address of array
#  xr2 : number of elements in array
#
# Accelerator protocol involves the following steps:
#  1. Write the base address of array via xr1
#  2. Write the number of elements in array via xr2
#  3. Tell accelerator to go by writing xr0
#  4. Wait for accelerator to finish by reading xr0, result will be 1
#

from pymtl3      import *

from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType
from pymtl3.stdlib.basic_rtl  import RegRst
from pymtl3.passes.backends.verilog import *

from proc.XcelMsg import *

class SortXcelPRTL( Component ):

  # Constructor

  def construct( s ):

    s.set_metadata( VerilogTranslationPass.explicit_module_name, 'SortXcelRTL' )

    MemReqMsg, MemRespMsg = mk_mem_msg( 8,32,32 )
    MEM_TYPE_READ  = b4(MemMsgType.READ)
    MEM_TYPE_WRITE = b4(MemMsgType.WRITE)

    # Interface

    s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )

    s.mem  = stream.ifcs.MasterIfcRTL( MemReqMsg, MemRespMsg )

    # Queues Buffer input

    s.xcelreq_q = stream.PipeQueueRTL( XcelReqMsg, 1 )
    s.xcelreq_q.recv //= s.xcel.req
    s.memresp_q = stream.PipeQueueRTL( MemRespMsg, 1 )
    s.memresp_q.recv //= s.mem.resp

    # ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    # Create RTL model for sorting xcel
    # '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    # This bypass queue is to cut the ready path
    s.memreq_q = stream.BypassQueueRTL( MemReqMsg, 1 )
    # s.memreq_q.send //= s.mem.req
    s.memreq_q.send.val //= s.mem.req.val
    s.memreq_q.send.rdy //= s.mem.req.rdy
    # Connect Msg in 4 state fixes

    # Internal state

    s.base_addr   = RegRst( Bits32 )
    s.size        = RegRst( Bits32 )
    s.inner_count = RegRst( Bits32 )
    s.outer_count = RegRst( Bits32 )
    s.a           = RegRst( Bits32 )

    # Line tracing

    s.prev_state = 0
    s.xcfg_trace = "  "

    #=====================================================================
    # 4 state sim fixes
    #=====================================================================

    # s.mem_req_msg_raw = Wire( MemReqMsg )

    s.mem.req.msg.type_  //= lambda: s.memreq_q.send.msg.type_  & (sext(s.mem.req.val, 4))
    s.mem.req.msg.opaque //= lambda: s.memreq_q.send.msg.opaque & (sext(s.mem.req.val, 8))
    s.mem.req.msg.addr   //= lambda: s.memreq_q.send.msg.addr   & (sext(s.mem.req.val, 32))
    s.mem.req.msg.len    //= lambda: s.memreq_q.send.msg.len    & (sext(s.mem.req.val, 2))
    s.mem.req.msg.data   //= lambda: s.memreq_q.send.msg.data   & (sext(s.mem.req.val, 32))

    s.xcel_resp_msg_raw = Wire ( XcelRespMsg )

    s.xcel.resp.msg.type_  //= lambda: s.xcel_resp_msg_raw.type_  & s.xcel.resp.val
    s.xcel.resp.msg.data   //= lambda: s.xcel_resp_msg_raw.data   & (sext(s.xcel.resp.val, 32))

    #=====================================================================
    # State Update
    #=====================================================================

    s.STATE_XCFG    = 0
    s.STATE_FIRST0  = 1
    s.STATE_FIRST1  = 2
    s.STATE_BUBBLE0 = 3
    s.STATE_BUBBLE1 = 4
    s.STATE_LAST    = 5

    s.state         = Wire(8)
    s.go            = Wire()

    @update_ff
    def block0():

      if s.reset:
        s.state <<= s.STATE_XCFG

      elif s.state == s.STATE_XCFG:
        if s.go & s.xcel.resp.rdy:
          s.state <<= s.STATE_FIRST0

      elif s.state == s.STATE_FIRST0:
        if s.memreq_q.recv.rdy:
          s.state <<= s.STATE_FIRST1

      elif s.state == s.STATE_FIRST1:
        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          s.state <<= s.STATE_BUBBLE0

      elif s.state == s.STATE_BUBBLE0:
        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          s.state <<= s.STATE_BUBBLE1

      elif s.state == s.STATE_BUBBLE1:
        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          if s.inner_count.out+1 < s.size.out:
            s.state <<= s.STATE_BUBBLE0
          else:
            s.state <<= s.STATE_LAST

      elif s.state == s.STATE_LAST:
        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          if s.outer_count.out+1 < s.size.out:
            s.state <<= s.STATE_FIRST1
          else:
            s.state <<= s.STATE_XCFG

    #=====================================================================
    # State Outputs
    #=====================================================================

    @update
    def block1():

      s.xcelreq_q.send.rdy @= 0
      s.xcel.resp.val      @= 0
      s.memreq_q.recv.val  @= 0
      s.memreq_q.recv.msg  @= MemReqMsg()
      s.memresp_q.send.rdy @= 0
      s.go                 @= 0

      s.outer_count.in_ @= s.outer_count.out
      s.inner_count.in_ @= s.inner_count.out
      s.a.in_           @= s.a.out
      s.size.in_        @= s.size.out
      s.base_addr.in_   @= s.base_addr.out

      #-------------------------------------------------------------------
      # STATE: XCFG
      #-------------------------------------------------------------------

      if s.state == s.STATE_XCFG:
        s.xcelreq_q.send.rdy @= s.xcel.resp.rdy
        s.xcel.resp.val      @= s.xcelreq_q.send.val

        if s.xcelreq_q.send.val:

          if s.xcelreq_q.send.msg.type_ == XCEL_TYPE_WRITE:

            if   s.xcelreq_q.send.msg.addr == 0:
              s.outer_count.in_ @= 0
              s.inner_count.in_ @= 0
              s.go              @= 1

            elif s.xcelreq_q.send.msg.addr == 1:
              s.base_addr.in_ @= s.xcelreq_q.send.msg.data

            elif s.xcelreq_q.send.msg.addr == 2:
              s.size.in_ @= s.xcelreq_q.send.msg.data

            # Send xcel response message

            s.xcel_resp_msg_raw @= XcelRespMsg( XCEL_TYPE_WRITE, 0 )

          else:

            # Send xcel response message, obviously you only want to
            # send the response message when accelerator is done

            s.xcel_resp_msg_raw @= XcelRespMsg( XCEL_TYPE_READ, 1 )

      #-------------------------------------------------------------------
      # STATE: FIRST0
      #-------------------------------------------------------------------
      # Send the first memory read request for the very first
      # element in the array.

      elif s.state == s.STATE_FIRST0:
        s.memreq_q.recv.val @= 1
        s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_READ, 0, s.base_addr.out + 4*s.inner_count.out, 0, 0 )

        if s.memreq_q.recv.rdy:
          s.inner_count.in_ @= 1

      #-------------------------------------------------------------------
      # STATE: FIRST1
      #-------------------------------------------------------------------
      # Wait for the memory response for the first element in the array,
      # and once it arrives store this element in a, and send the memory
      # read request for the second element.

      elif s.state == s.STATE_FIRST1:

        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          s.memresp_q.send.rdy @= 1
          s.memreq_q.recv.val  @= 1

          s.a.in_ @= s.memresp_q.send.msg.data

          s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_READ, 0, s.base_addr.out + 4*s.inner_count.out, 0, 0 )

      #-------------------------------------------------------------------
      # STATE: BUBBLE0
      #-------------------------------------------------------------------
      # Wait for the memory read response to get the next element,
      # compare the new value to the previous max value, update b with
      # the new max value, and send a memory request to store the new min
      # value. Notice how we decrement the write address by four since we
      # want to store to the new min value _previous_ element.

      elif s.state == s.STATE_BUBBLE0:

        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          s.memresp_q.send.rdy @= 1
          s.memreq_q.recv.val  @= 1

          if s.a.out > s.memresp_q.send.msg.data:
            s.a.in_ @= s.a.out
            s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_WRITE, 0,
                                              s.base_addr.out + 4*(s.inner_count.out-1), 0,
                                              s.memresp_q.send.msg.data )
          else:
            s.a.in_ @= s.memresp_q.send.msg.data
            s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_WRITE, 0,
                                              s.base_addr.out + 4*(s.inner_count.out-1), 0,
                                              s.a.out )

      #-------------------------------------------------------------------
      # STATE: BUBBLE1
      #-------------------------------------------------------------------
      # Wait for the memory write response, and then check to see if we
      # have reached the end of the array. If we have not reached the end
      # of the array, then make a new memory read request for the next
      # element; if we have reached the end of the array, then make a
      # final write request (with value from a) to update the final
      # element in the array.

      elif s.state == s.STATE_BUBBLE1:
        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          s.memresp_q.send.rdy @= 1
          s.memreq_q.recv.val  @= 1

          s.inner_count.in_ @= s.inner_count.out + 1
          if s.inner_count.out + 1 < s.size.out:
            s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_READ, 0,
                                              s.base_addr.out + 4*(s.inner_count.out+1), 0, 0 )

          else:
            s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_WRITE, 0,
                                              s.base_addr.out + 4*s.inner_count.out, 0,
                                              s.a.out )

      #-------------------------------------------------------------------
      # STATE: LAST
      #-------------------------------------------------------------------
      # Wait for the last response, and then check to see if we need to
      # go through the array again. If we do need to go through array
      # again, then make a new memory read request for the very first
      # element in the array; if we do not need to go through the array
      # again, then we are all done and we can go back to accelerator
      # configuration.

      elif s.state == s.STATE_LAST:
        if s.memreq_q.recv.rdy & s.memresp_q.send.val:
          s.memresp_q.send.rdy @= 1

          s.outer_count.in_ @= s.outer_count.out + 1

          if s.outer_count.out + 1 < s.size.out:

            s.memreq_q.recv.val @= 1
            s.memreq_q.recv.msg @= MemReqMsg( MEM_TYPE_READ, 0, s.base_addr.out, 0, 0 )
            s.inner_count.in_ @= 1

    # '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  # Line tracing

  def line_trace( s ):

    s.trace = ""

    # ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    # Define line trace here
    # '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    state2char = {
      s.STATE_XCFG    : "X ",
      s.STATE_FIRST0  : "F0",
      s.STATE_FIRST1  : "F1",
      s.STATE_BUBBLE0 : "B0",
      s.STATE_BUBBLE1 : "B1",
      s.STATE_LAST    : "L ",
    }

    s.state_str = state2char[s.state.uint()]

    s.trace = "({!s:2}:{!s:2}:{}:{})".format(
      s.outer_count.out, s.inner_count.out,
      s.state_str ,s.xcel.resp.val
    )

    # '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

    return s.trace

