#=========================================================================
# BlockingCacheDpathPRTL.py
#=========================================================================

from pymtl3 import *
from pymtl3.stdlib.mem import mk_mem_msg

from pymtl3.stdlib.basic_rtl import Mux, RegEnRst, EqComparator
from sram.SramRTL import SramRTL

size           = 8192             # Cache size in bytes
p_opaque_nbits = 8

# local parameters not meant to be set from outside

dbw            = 32                # Short name for data bitwidth
abw            = 32                # Short name for addr bitwidth
clw            = 128               # Short name for cacheline bitwidth
nblocks        = size*8//clw        # Number of blocks in the cache
idw            = clog2(nblocks)-1  # Short name for index width
idw_off        = idw+4
o              = p_opaque_nbits

#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

class BlockingCacheDpathPRTL( Component ):

  def construct( s, idx_shamt=0 ):

    CacheReqType, CacheRespType = mk_mem_msg( 8, 32, 32 )
    MemReqType,   MemRespType   = mk_mem_msg( 8, 32, 128 )

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    # Cache request
    s.cachereq_msg       = InPort ( CacheReqType   )

    # Cache response
    s.cacheresp_msg      = OutPort( CacheRespType  )

    # Memory request
    s.memreq_msg         = OutPort( MemReqType  )

    # Memory response
    s.memresp_msg        = InPort ( MemRespType )

    # control signals (ctrl->dpath)

    s.amo_sel            = InPort(2)
    s.cachereq_enable    = InPort()
    s.memresp_enable     = InPort()
    s.is_refill          = InPort()
    s.tag_array_0_wen    = InPort()
    s.tag_array_0_ren    = InPort()
    s.tag_array_1_wen    = InPort()
    s.tag_array_1_ren    = InPort()
    s.way_sel            = InPort()
    s.way_sel_current    = InPort()
    s.data_array_wen     = InPort()
    s.data_array_ren     = InPort()
    s.skip_read_data_reg = InPort()

    # width of cacheline divided by number of bits per byte

    s.data_array_wben    = InPort( clw//8//4 )
    s.read_data_reg_en   = InPort()
    s.read_tag_reg_en    = InPort()
    s.read_byte_sel      = InPort( clog2(clw/dbw) )
    s.memreq_type        = InPort(4)
    s.cacheresp_type     = InPort(4)
    s.cacheresp_hit      = InPort()

    # status signals (dpath->ctrl)

    s.cachereq_type      = OutPort (4)
    s.cachereq_addr      = OutPort ( abw )
    s.tag_match_0        = OutPort ()
    s.tag_match_1        = OutPort ()

    # Register the unpacked cachereq_msg

    s.cachereq_type_reg = m = RegEnRst( Bits4, reset_value=0 )
    m.en  //= s.cachereq_enable
    m.in_ //= s.cachereq_msg.type_
    m.out //= s.cachereq_type

    s.cachereq_addr_reg = m = RegEnRst( mk_bits(abw), reset_value=0 )
    m.en  //= s.cachereq_enable
    m.in_ //= s.cachereq_msg.addr
    m.out //= s.cachereq_addr

    s.cachereq_opaque_reg = m = RegEnRst( mk_bits(o), reset_value=0 )
    m.en  //= s.cachereq_enable
    m.in_ //= s.cachereq_msg.opaque
    m.out //= s.cacheresp_msg.opaque

    s.cachereq_data_reg = m = RegEnRst( mk_bits(dbw), reset_value=0 )
    m.en  //= s.cachereq_enable
    m.in_ //= s.cachereq_msg.data

    # Register the unpacked data from memresp_msg

    s.memresp_data_reg = m = RegEnRst( mk_bits(clw), reset_value=0 )
    m.en  //= s.memresp_enable
    m.in_ //= s.memresp_msg.data

    # Generate cachereq write data which will be the data field or some
    # calculation with the read data for amos

    s.cachereq_data_reg_out_add = Wire( mk_bits(dbw) )
    s.cachereq_data_reg_out_and = Wire( mk_bits(dbw) )
    s.cachereq_data_reg_out_or  = Wire( mk_bits(dbw) )

    @update
    def comb_connect_wires():
      s.cachereq_data_reg_out_add @= s.cachereq_data_reg.out + s.read_byte_sel_mux.out
      s.cachereq_data_reg_out_and @= s.cachereq_data_reg.out & s.read_byte_sel_mux.out
      s.cachereq_data_reg_out_or  @= s.cachereq_data_reg.out | s.read_byte_sel_mux.out

    s.amo_sel_mux = m = Mux( mk_bits(dbw), ninputs=4 )
    m.in_[0] //= s.cachereq_data_reg.out
    m.in_[1] //= s.cachereq_data_reg_out_add
    m.in_[2] //= s.cachereq_data_reg_out_and
    m.in_[3] //= s.cachereq_data_reg_out_or
    m.sel //= s.amo_sel

    # Replicate cachereq_write_data

    s.cachereq_write_data_replicated = Wire( dbw*clw//dbw )

    for i in range(0, clw, dbw):
      s.cachereq_write_data_replicated[i:i+dbw] //= s.amo_sel_mux.out

    # Refill mux

    s.refill_mux = m = Mux( mk_bits(clw), ninputs=2 )
    m.in_[0] //= s.cachereq_write_data_replicated
    m.in_[1] //= s.memresp_msg.data
    m.sel //= s.is_refill

    # Taking slices of the cache request address
    #     byte offset: 2 bits wide
    #     word offset: 2 bits wide
    #     index: $clog2(nblocks) bits wide - 1 bits wide
    #     nbits: width of tag = width of addr - $clog2(nblocks) - 4
    #     entries: 256*8/128 = 16

    s.cachereq_tag = Wire( abw-4 )
    s.cachereq_idx = Wire( idw )

    s.cachereq_tag //= s.cachereq_addr_reg.out[4:abw]
    s.cachereq_idx //= s.cachereq_addr_reg.out[4:idw_off]

    # Concat

    s.temp_cachereq_tag = Wire( abw )
    s.cachereq_msg_addr = Wire( abw )
    s.cur_cachereq_idx  = Wire( idw )

    s.data_array_0_wen = Wire()
    s.data_array_1_wen = Wire()
    s.sram_tag_0_en    = Wire()
    s.sram_tag_1_en    = Wire()
    s.sram_data_0_en   = Wire()
    s.sram_data_1_en   = Wire()

    @update
    def comb_tag():
      s.cachereq_msg_addr @= s.cachereq_msg.addr
      s.temp_cachereq_tag @= zext(s.cachereq_tag, abw)
      if s.cachereq_enable:
        s.cur_cachereq_idx @= s.cachereq_msg_addr[4:idw_off]
      else:
        s.cur_cachereq_idx @= s.cachereq_idx

      s.data_array_0_wen @= s.data_array_wen & (s.way_sel_current == 0)
      s.data_array_1_wen @= s.data_array_wen & (s.way_sel_current == 1)
      s.sram_tag_0_en    @= s.tag_array_0_wen | s.tag_array_0_ren
      s.sram_tag_1_en    @= s.tag_array_1_wen | s.tag_array_1_ren
      s.sram_data_0_en   @= s.data_array_0_wen | s.data_array_ren
      s.sram_data_1_en   @= s.data_array_1_wen | s.data_array_ren

    # Tag array 0

    s.tag_array_0_read_out = Wire( abw )

    s.tag_array_0 = m = SramRTL( 32, 256 )
    m.port0_val   //= s.sram_tag_0_en
    m.port0_type  //= s.tag_array_0_wen
    m.port0_idx   //= s.cur_cachereq_idx
    m.port0_rdata //= s.tag_array_0_read_out
    m.port0_wdata //= s.temp_cachereq_tag

    # Tag array 1

    s.tag_array_1_read_out = Wire( abw )

    s.tag_array_1 = m = SramRTL( 32, 256 )
    m.port0_val   //= s.sram_tag_1_en
    m.port0_type  //= s.tag_array_1_wen
    m.port0_idx   //= s.cur_cachereq_idx
    m.port0_rdata //= s.tag_array_1_read_out
    m.port0_wdata //= s.temp_cachereq_tag

    # Data array 0

    s.data_array_0_read_out = Wire( clw )

    s.data_array_0 = m = SramRTL( 128, 256, mask_size=4 )
    m.port0_val   //= s.sram_data_0_en
    m.port0_type  //= s.data_array_0_wen
    m.port0_idx   //= s.cur_cachereq_idx
    m.port0_rdata //= s.data_array_0_read_out
    m.port0_wben  //= s.data_array_wben
    m.port0_wdata //= s.refill_mux.out

    # Data array 1

    s.data_array_1_read_out = Wire( clw )

    s.data_array_1 = m = SramRTL( 128, 256, mask_size=4 )
    m.port0_val   //= s.sram_data_1_en
    m.port0_type  //= s.data_array_1_wen
    m.port0_idx   //= s.cur_cachereq_idx
    m.port0_rdata //= s.data_array_1_read_out
    m.port0_wben  //= s.data_array_wben
    m.port0_wdata //= s.refill_mux.out

    # Data read mux

    s.data_read_mux = m = Mux( clw, ninputs=2 )
    m.in_[0] //= s.data_array_0_read_out
    m.in_[1] //= s.data_array_1_read_out
    m.sel //= s.way_sel_current

    # Eq comparator to check for tag matching (tag_compare_0)

    s.tag_compare_0 = m = EqComparator( mk_bits(abw - 4) )
    m.in0 //= s.cachereq_tag
    m.in1 //= s.tag_array_0_read_out[0:abw-4]
    m.out //= s.tag_match_0

    # Eq comparator to check for tag matching (tag_compare_1)

    s.tag_compare_1 = m = EqComparator( mk_bits(abw - 4) )
    m.in0 //= s.cachereq_tag
    m.in1 //= s.tag_array_1_read_out[0:abw-4]
    m.out //= s.tag_match_1

    # Mux that selects between the ways for requesting from memory

    s.way_sel_mux = m = Mux( mk_bits(abw - 4), ninputs = 2 )
    m.in_[0] //= s.tag_array_0_read_out[0:abw-4]
    m.in_[1] //= s.tag_array_1_read_out[0:abw-4]
    m.sel //= s.way_sel_current

    # Read data register

    s.read_data_reg = m = RegEnRst( mk_bits(clw), reset_value=0 )
    m.en  //= s.read_data_reg_en
    m.in_ //= s.data_read_mux.out
    m.out //= s.memreq_msg.data

    # Read tag register

    s.read_tag_reg = m = RegEnRst( mk_bits(abw - 4), reset_value=0 )
    m.en  //= s.read_tag_reg_en
    m.in_ //= s.way_sel_mux.out

    # Memreq Type Mux

    s.memreq_type_mux_out = Wire( mk_bits(abw - 4) )

    s.tag_mux = m = Mux( mk_bits(abw - 4), ninputs = 2 )
    m.in_[0] //= s.cachereq_tag
    m.in_[1] //= s.read_tag_reg.out
    m.sel //= s.memreq_type[0]
    m.out //= s.memreq_type_mux_out

    # Pack address for memory request

    s.memreq_addr = Wire( abw )

    @update
    def comb_addr_evict():
      s.memreq_addr @= zext(s.memreq_type_mux_out, abw) << 4 # 16B cacheline

    # Skip read data reg mux

    s.read_data = Wire( clw )

    s.skip_read_data_mux = m = Mux( mk_bits(clw), ninputs=2 )
    m.in_[0] //= s.read_data_reg.out
    m.in_[1] //= s.data_read_mux.out
    m.sel //= s.skip_read_data_reg
    m.out //= s.read_data

    # Select byte for cache response

    s.read_byte_sel_mux = m = Mux( mk_bits(dbw), ninputs=4 )
    m.in_[0] //= s.read_data[0:       dbw]
    m.in_[1] //= s.read_data[1*dbw: 2*dbw]
    m.in_[2] //= s.read_data[2*dbw: 3*dbw]
    m.in_[3] //= s.read_data[3*dbw: 4*dbw]
    m.sel //= s.read_byte_sel

    @update
    def comb_cacherespmsgpack():
      if s.cacheresp_type == 0:
        s.cacheresp_msg.data @= s.read_byte_sel_mux.out
      else:
        s.cacheresp_msg.data @= 0
      s.cacheresp_msg.type_ @= s.cacheresp_type
      s.cacheresp_msg.test  @= concat( b1(0), s.cacheresp_hit )
      s.cacheresp_msg.len   @= 0

    @update
    def comb_memrespmsgpack():
      s.memreq_msg.type_  @= s.memreq_type
      s.memreq_msg.opaque @= 0
      s.memreq_msg.addr   @= s.memreq_addr
      s.memreq_msg.len    @= 0

