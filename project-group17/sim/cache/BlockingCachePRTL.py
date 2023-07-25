#=========================================================================
# BlockingCachePRTL.py
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib.mem import mk_mem_msg
from pymtl3.stdlib import stream

from .BlockingCacheCtrlPRTL  import BlockingCacheCtrlPRTL
from .BlockingCacheDpathPRTL import BlockingCacheDpathPRTL

# Note on num_banks:
# In a multi-banked cache design, cache lines are interleaved to
# different cache banks, so that consecutive cache lines correspond to a
# different bank. The following is the addressing structure in our
# four-banked data caches:
#
# +--------------------------+--------------+--------+--------+--------+
# |        22b               |     4b       |   2b   |   2b   |   2b   |
# |        tag               |   index      |bank idx| offset | subwd  |
# +--------------------------+--------------+--------+--------+--------+
#
# In this lab you don't have to consider multi-banked cache design. We
# will compose four-banked cache in lab5 multi-core lab. You can modify
# your cache to multi-banked by slightly modifying the address structure.
# For now you can simply assume num_banks == 0.

class BlockingCachePRTL( Component ):

  def construct( s, num_banks = 0 ):

    CacheReqType, CacheRespType = mk_mem_msg( 8, 32, 32 )
    MemReqType,   MemRespType   = mk_mem_msg( 8, 32, 128 )

    if num_banks <= 0:
      idx_shamt = 0
    else:
      idx_shamt = clog2( num_banks )

    # Proc <-> Cache

    s.cache = stream.ifcs.MinionIfcRTL( CacheReqType, CacheRespType )

    # Cache <-> Mem

    s.mem = stream.ifcs.MasterIfcRTL( MemReqType, MemRespType )

    s.cacheresp_bypass = stream.BypassQueueRTL( CacheRespType, 1 )
    s.cache.resp.val //= s.cacheresp_bypass.send.val
    s.cache.resp.rdy //= s.cacheresp_bypass.send.rdy
    s.cache.resp.msg.type_  //= lambda: s.cacheresp_bypass.send.msg.type_  & (sext(s.cacheresp_bypass.send.val, 4))
    s.cache.resp.msg.opaque //= lambda: s.cacheresp_bypass.send.msg.opaque & (sext(s.cacheresp_bypass.send.val, 8))
    s.cache.resp.msg.test   //= lambda: s.cacheresp_bypass.send.msg.test & (sext(s.cacheresp_bypass.send.val, 2))
    s.cache.resp.msg.len    //= lambda: s.cacheresp_bypass.send.msg.len  & (sext(s.cacheresp_bypass.send.val, 2))
    s.cache.resp.msg.data   //= lambda: s.cacheresp_bypass.send.msg.data & (sext(s.cacheresp_bypass.send.val, 32))

    s.ctrl = BlockingCacheCtrlPRTL ( idx_shamt )

    # Cache request
    s.ctrl.cachereq_val //= s.cache.req.val
    s.ctrl.cachereq_rdy //= s.cache.req.rdy

    # Cache response
    s.ctrl.cacheresp_val //= s.cacheresp_bypass.recv.val
    s.ctrl.cacheresp_rdy //= s.cacheresp_bypass.recv.rdy

    # Memory request
    s.ctrl.memreq_val //= s.mem.req.val
    s.ctrl.memreq_rdy //= s.mem.req.rdy

    # Memory response
    s.ctrl.memresp_val //= s.mem.resp.val
    s.ctrl.memresp_rdy //= s.mem.resp.rdy

    s.dpath = BlockingCacheDpathPRTL( idx_shamt )

    # Cache request
    s.dpath.cachereq_msg //= s.cache.req.msg

    # Cache response
    s.dpath.cacheresp_msg //= s.cacheresp_bypass.recv.msg

    # Memory request
    s.mem.req.msg.type_  //= lambda: s.dpath.memreq_msg.type_  & (sext(s.ctrl.memreq_val, 4))
    s.mem.req.msg.opaque //= lambda: s.dpath.memreq_msg.opaque & (sext(s.ctrl.memreq_val, 8))
    s.mem.req.msg.addr   //= lambda: s.dpath.memreq_msg.addr   & (sext(s.ctrl.memreq_val, 32))
    s.mem.req.msg.len    //= lambda: s.dpath.memreq_msg.len    & (sext(s.ctrl.memreq_val, 4))
    s.mem.req.msg.data   //= lambda: s.dpath.memreq_msg.data   & (sext(s.ctrl.memreq_val, 128)) if (s.ctrl.memreq_val & (s.dpath.memreq_msg.type_ == Bits4(0x1)) ) else Bits128(0x0)

    # Memory response
    s.dpath.memresp_msg //= s.mem.resp.msg

    # control signals (ctrl->dpath)

    s.dpath.amo_sel            //= s.ctrl.amo_sel
    s.dpath.cachereq_enable    //= s.ctrl.cachereq_enable
    s.dpath.memresp_enable     //= s.ctrl.memresp_enable
    s.dpath.is_refill          //= s.ctrl.is_refill
    s.dpath.tag_array_0_wen    //= s.ctrl.tag_array_0_wen
    s.dpath.tag_array_0_ren    //= s.ctrl.tag_array_0_ren
    s.dpath.tag_array_1_wen    //= s.ctrl.tag_array_1_wen
    s.dpath.tag_array_1_ren    //= s.ctrl.tag_array_1_ren
    s.dpath.way_sel            //= s.ctrl.way_sel
    s.dpath.way_sel_current    //= s.ctrl.way_sel_current
    s.dpath.data_array_wen     //= s.ctrl.data_array_wen
    s.dpath.data_array_ren     //= s.ctrl.data_array_ren
    s.dpath.skip_read_data_reg //= s.ctrl.skip_read_data_reg

    # width of cacheline divided by number of bits per byte

    s.dpath.data_array_wben  //= s.ctrl.data_array_wben
    s.dpath.read_data_reg_en //= s.ctrl.read_data_reg_en
    s.dpath.read_tag_reg_en  //= s.ctrl.read_tag_reg_en
    s.dpath.read_byte_sel    //= s.ctrl.read_byte_sel
    s.dpath.memreq_type      //= s.ctrl.memreq_type
    s.dpath.cacheresp_type   //= s.ctrl.cacheresp_type
    s.dpath.cacheresp_hit    //= s.ctrl.cacheresp_hit

    # status signals (dpath->ctrl)

    s.ctrl.cachereq_type //= s.dpath.cachereq_type
    s.ctrl.cachereq_addr //= s.dpath.cachereq_addr
    s.ctrl.tag_match_0   //= s.dpath.tag_match_0
    s.ctrl.tag_match_1   //= s.dpath.tag_match_1

    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  def line_trace( s ):

    #: return ""

    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    # LAB TASK: Create line tracing
    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    state = s.ctrl.state

    if   state == s.ctrl.STATE_IDLE:                   state_str = "(I )"
    elif state == s.ctrl.STATE_TAG_CHECK:              state_str = "(TC)"
    elif state == s.ctrl.STATE_WRITE_CACHE_RESP_HIT:   state_str = "(WR)"
    elif state == s.ctrl.STATE_WRITE_DATA_ACCESS_HIT:  state_str = "(WD)"
    elif state == s.ctrl.STATE_READ_DATA_ACCESS_MISS:  state_str = "(RD)"
    elif state == s.ctrl.STATE_WRITE_DATA_ACCESS_MISS: state_str = "(WD)"
    elif state == s.ctrl.STATE_AMO_READ_DATA_ACCESS:   state_str = "(AR)"
    elif state == s.ctrl.STATE_AMO_WRITE_DATA_ACCESS:  state_str = "(AW)"
    elif state == s.ctrl.STATE_INIT_DATA_ACCESS:       state_str = "(IN)"
    elif state == s.ctrl.STATE_REFILL_REQUEST:         state_str = "(RR)"
    elif state == s.ctrl.STATE_REFILL_WAIT:            state_str = "(RW)"
    elif state == s.ctrl.STATE_REFILL_UPDATE:          state_str = "(RU)"
    elif state == s.ctrl.STATE_EVICT_PREPARE:          state_str = "(EP)"
    elif state == s.ctrl.STATE_EVICT_REQUEST:          state_str = "(ER)"
    elif state == s.ctrl.STATE_EVICT_WAIT:             state_str = "(EW)"
    elif state == s.ctrl.STATE_WAIT_HIT:               state_str = "(Wh)"
    elif state == s.ctrl.STATE_WAIT_MISS:              state_str = "(Wm)"
    else :                                             state_str = "(? )"

    return state_str

    #'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

