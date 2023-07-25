#========================================================================
# SRAM Minion Wrapper
#========================================================================
# This is a simple latency-insensitive minion wrapper around an SRAM that
# is supposed to be generated using a memory compiler. We add a skid
# buffer in order to support the latency-insensitive val/rdy protocol. A
# correct solution will have two or more elements of buffering in the
# memory response queue _and_ stall M0 if there are less than two free
# elements in the queue. Thus in the worst case, if M2 stalls we have
# room for two messages in the response queue: the message currently in
# M1 and the message currently in M0. Here is the updated design:
#
#         .------.          .------.
#         |      |          | 2elm |
#   M0 -> | sram | -> M1 -> | bypq | -> M2
#         |      |       .- |      |
#         '^-----'       |  '^-----'
#                        |
#  rdy <-(if count == 0)-'
#
# Here is the updated pipeline diagram.
#
#  cycle : 0  1  2  3  4  5
#  msg a : M0 M2
#  msg b :    M0 M2
#  msg c :       M0 M1 M2 M2 M2
#  msg d :          M0 q  q  q   # msg c is in skid buffer
#  msg e :             M0 M0 M0
#
#  cycle M0 M1 [q ] M2
#     0: a
#     1: b  a       a  # a is flows through bypass queue
#     2: c  b       b  # b is flows through bypass queue
#     3: d  c          # M2 is stalled, c will need to go into bypq
#     4: e  d    c     #
#     5: e      dc     # d skids behind c into the bypq
#
# Note, with a pipe queue you still need two elements of buffering.
# There could be a message in the response queue when M2 stalls and then
# you still don't have anywhere to put the message currently in M1.

from pymtl3                  import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib           import stream
from pymtl3.stdlib.mem       import mk_mem_msg, MemMsgType
from pymtl3.stdlib.basic_rtl import Reg, RegRst, RegisterFile

from sram import SramRTL

class SynthMemSimple( Component ):

  def construct( s ):
    s.set_metadata( VerilogTranslationPass.explicit_module_name, "SynthMemSimple" )

    # size is fixed as 32x128

    num_bits   = 32
    num_words  = 32 # 128
    addr_width = clog2( num_words )
    addr_start = clog2( num_bits / 8 )
    addr_end   = addr_start + addr_width
    rd_ports   = 1
    wr_ports   = 1

    BitsAddr   = mk_bits( addr_width )
    BitsData   = mk_bits( num_bits )

    # Default memory message has 8 bits opaque field and 32 bits address.

    MemReqType, MemRespType = mk_mem_msg( 8, 32, num_bits )

    # Interface

    s.minion = stream.ifcs.MinionIfcRTL( MemReqType, MemRespType )

    #=====================================================================
    # 4 state sim fixes
    #=====================================================================

    s.minion_resp_msg_raw = Wire ( MemRespType )

    s.minion.resp.msg.type_  //= lambda: s.minion_resp_msg_raw.type_  & (sext(s.minion.resp.val, 4))
    s.minion.resp.msg.opaque //= lambda: s.minion_resp_msg_raw.opaque & (sext(s.minion.resp.val, 8))
    s.minion.resp.msg.test   //= lambda: s.minion_resp_msg_raw.test   & (sext(s.minion.resp.val, 2))
    s.minion.resp.msg.len    //= lambda: s.minion_resp_msg_raw.len    & (sext(s.minion.resp.val, addr_start))
    s.minion.resp.msg.data   //= lambda: s.minion_resp_msg_raw.data   & (sext(s.minion.resp.val, num_bits))


    #---------------------------------------------------------------------
    # M0 stage (Normal Queue)
    #---------------------------------------------------------------------

    s.reg_addr_M0    = Wire( BitsAddr )
    s.reg_wen_M0     = Wire( Bits1    )
    s.reg_en_M0      = Wire( Bits1    )
    s.reg_wdata_M0   = Wire( BitsData )
    s.reg_opaque     = Wire( 8 )
    s.req_type       = Wire( 4 )

    # translation work around
    MEM_MSG_TYPE_WRITE = b4(MemMsgType.WRITE)
    MEM_MSG_TYPE_READ = b4(MemMsgType.READ)


    # Normal queue

    s.memreq_q = stream.NormalQueueRTL( MemReqType, num_entries=2 )
    s.memreq_q.recv  //= s.minion.req

    @update
    def comb_M0():

      s.minion.resp.val  @= s.memreq_q.send.val
      s.memreq_q.send.rdy @= s.minion.resp.rdy
      s.req_type     @= s.memreq_q.send.msg.type_
      s.reg_addr_M0  @= s.memreq_q.send.msg.addr[addr_start:addr_end] # s.minion.req.msg.addr[addr_start:addr_end]
      s.reg_wen_M0   @= s.memreq_q.send.val & ( s.req_type == MEM_MSG_TYPE_WRITE ) # s.minion.req.val & ( s.minion.req.msg.type_ == MEM_MSG_TYPE_WRITE )
      s.reg_en_M0    @= s.memreq_q.send.val & s.memreq_q.send.rdy # s.minion.req.val & s.minion.req.rdy
      s.reg_wdata_M0 @= s.memreq_q.send.msg.data # s.minion.req.msg.data
      s.reg_opaque   @= s.memreq_q.send.msg.opaque

      if ( s.memreq_q.send.msg.type_ == 0 ):
        s.minion_resp_msg_raw @= MemRespType( MEM_MSG_TYPE_READ, s.memreq_q.send.msg.opaque, b2(0), 0, s.reg_file.rdata[0] )
      elif ( s.memreq_q.send.msg.type_ == 1 ):
        s.minion_resp_msg_raw @= MemRespType( MEM_MSG_TYPE_WRITE, s.memreq_q.send.msg.opaque, b2(0), 0, 0 )


    # RegFile

    # s.reg = m = RegRst( num_bits, num_words )
    s.reg_file = m = RegisterFile( Bits32, nregs=32, rd_ports=1, wr_ports=1 )
    m.waddr[0]   //= s.reg_addr_M0
    m.raddr[0]   //= s.reg_addr_M0
    m.wen[0]  //= s.reg_wen_M0
    # m.port0_val   //= s.reg_en_M0
    m.wdata[0] //= s.reg_wdata_M0

    # s.memreq_val_reg_M1 = m = RegRst( Bits1 )
    # m.in_ //= s.regfile_en_M0

  def line_trace( s ):
    # return '*' if s.memreq_val_reg_M1.out else ' '
    s.trace = "(wdata {}, rdata {}, en {}, addr {}, type {})".format(
      s.reg_file.wdata[0],
      s.reg_file.rdata[0],
      s.reg_file.wen,
      s.reg_file.waddr[0],
      s.memreq_q.send.msg.type_,
    )

    return s.trace
