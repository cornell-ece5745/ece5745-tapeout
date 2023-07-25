#=========================================================================
# PE_RTL_test
#=========================================================================

import pytest
import random
import struct

from pymtl3  import *
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType


from pymtl3.stdlib import stream
from ..AutonomousReaderRTL  import ReaderUnitRTL
from ..ReaderUnitMsgs       import ReaderUnitMsgs
from ..SpmvPeRTL            import SpmvPeRTL
from ..PeConfigMsg          import PeConfigMsgs
from ..PeRowsMsgs           import PeRowsMsgs

# To ensure reproducible testing

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, PE ):

    # Instantiate models

    s.src_config    = stream.SourceRTL( PeConfigMsgs.req )
    s.src_rows      = stream.SourceRTL( PeRowsMsgs.req )

    s.sink_config   = stream.SinkRTL  ( PeConfigMsgs.resp )
    s.sink_rows     = stream.SinkRTL  ( PeRowsMsgs.resp )

    s.mem    = stream.MagicMemoryRTL( nports = 4, mem_ifc_dtypes = [mk_mem_msg(8,32,32), mk_mem_msg(8,32,32), mk_mem_msg(8,32,32), mk_mem_msg(8,32,32)] )
    s.PE     = PE
    s.mem.ifc[0] //= s.PE.cols_mem
    s.mem.ifc[1] //= s.PE.vals_mem
    s.mem.ifc[2] //= s.PE.vec_mem
    s.mem.ifc[3] //= s.PE.write_mem

    # Connect

    s.src_config.send //= s.PE.config_recv
    s.src_rows.send   //= s.PE.rows_recv
    s.PE.config_send  //= s.sink_config.recv
    s.PE.rows_send    //= s.sink_rows.recv

  def done( s ):
    return s.src_config.done() and s.sink_config.done() and s.src_rows.done() and s.sink_rows.done()

  def line_trace( s ):
    return s.src_config.line_trace() + " > " + s.src_rows.line_trace() + " > " +  s.PE.line_trace() + \
      " > " + s.sink_config.line_trace() + " > " + s.sink_rows.line_trace()
    # return s.src.line_trace() + " > " + s.reader.line_trace() + " > " + s.sink.line_trace()
#-------------------------------------------------------------------------
# Test Case
#-------------------------------------------------------------------------
cols_one_el     = [0]
vector_one_el   = [1]
vals_one_el     = [2]
res_one_el      = [2]

cols_two_el     = [1, 0]
vector_two_el   = [1, 1]
vals_two_el     = [2, 3]
row_st_two_el   = [0, 1]
row_end_two_el  = [1, 2]
res_two_el      = [2, 3]

row_st_4        = [0, 2, 2, 5]
row_end_4       = [2, 2, 5, 7]
cols_mini       = [ 0, 2, 0, 2, 3, 1, 3 ]
vector_mini     = [ 1, 4, 6, 12 ]
vals_mini       = [ 1, 2, 1, 2, 3, 1, 2 ]
res_mini        = [13, 0, 49, 28]

cols_f          = [0, 1, 1, 2, 2, 3, 0, 3]
vector_f        = [1, 2, 3, 4]
vals_f          = [1, 2, 3, 4, 5, 6, 7, 8]
row_st_f        = [0, 2, 4, 6]
row_end_f       = [2, 4, 6, 8]
res_f           = [5, 18, 39, 39]

cols_ff         = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]
vector_ff       = [1, 2, 3, 4]
vals_ff         = [1, 2, 3, 4, 1, 2, 4, 3, 1, 3, 2, 4, 1, 3, 4, 2]
row_st_ff       = [0, 4, 8, 12]
row_end_ff      = [4, 8, 12, 16]
res_ff          = [30, 29, 29, 27]

cols_32         = [2, 6, 9, 21, 18, 15, 15, 10, 6, 21, 5, 1, 27, 26, 31, 27, 11, 3, 2, 17]
vals_32         = [25, 41, 27, 2, 61, 95, 41, 61, 35, 32, 46, 72, 50, 9, 51, 23, 93, 24, 74, 66]
vector_32       = [700, 234, 640, 523, 164, 794, 398, 229, 72, 372, 792, 14, 772, 771, 77, 853, 816, 981, 439, 372, 303, 797, 34, 141, 547, 441, 596, 778, 439, 672, 824, 114]
row_st_32       = [0, 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 8, 9, 9, 9, 10, 12, 13, 13, 14, 15, 15, 16, 16, 17, 18, 19, 19, 19]
row_end_32      = [0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 8, 9, 9, 9, 10, 12, 13, 13, 14, 15, 15, 16, 16, 17, 18, 19, 19, 19, 20]
res_32          = [0, 0, 16000, 0, 16318, 0, 10044, 1594, 0, 26779, 81035, 34973, 0, 48312, 0, 13930, 0, 0, 25504, 53372, 38900, 0, 5364, 5814, 0, 17894, 0, 1302, 12552, 47360, 0, 0]


#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
(                       "num_rows   num_nnz    row_start        row_end            cols          vals           vector          res src     sink stall lat"),
[ "one_element",            1,         1,              [0],           [1],     cols_one_el,  vals_one_el,   vector_one_el,    res_one_el,     0,  0,     0,  0],
[ "two_element",            2,         2,    row_st_two_el, row_end_two_el,    cols_two_el,  vals_two_el,   vector_two_el,    res_two_el,     0,  0,     0,  0],
[ "4_element",              4,         7,         row_st_4,      row_end_4,      cols_mini,    vals_mini,     vector_mini,      res_mini,     0,  0,     0,  0],
[ "matrix_32x32",          32,        20,        row_st_32,     row_end_32,        cols_32,      vals_32,       vector_32,        res_32,     0,  0,     0,  0],
[ "2_nnz_per_row",          4,         8,         row_st_f,      row_end_f,         cols_f,       vals_f,        vector_f,         res_f,     0,  0,     0,  0],
[ "4_nnz_per_row",          4,        16,        row_st_ff,     row_end_ff,        cols_ff,      vals_ff,       vector_ff,        res_ff,     0,  0,     0,  0],
[ "matrix_32x32_delay",    32,        20,        row_st_32,     row_end_32,        cols_32,      vals_32,       vector_32,        res_32,     3, 14,   0.5,  2],
[ "two_element_delay",      2,         2,    row_st_two_el, row_end_two_el,    cols_two_el,  vals_two_el,   vector_two_el,    res_two_el,     5,  7,   0.5,  4],
[ "4_element_delay",        4,         7,         row_st_4,      row_end_4,      cols_mini,    vals_mini,     vector_mini,      res_mini,     3, 14,   0.5,  2],
[ "2_nnz_per_row_delay",    4,         8,         row_st_f,      row_end_f,         cols_f,       vals_f,        vector_f,         res_f,     5,  7,   0.5,  4],
[ "4_nnz_per_row_delay",    4,        16,        row_st_ff,     row_end_ff,        cols_ff,      vals_ff,       vector_ff,        res_ff,     3, 14,   0.5,  2],
[ "one_element_delay",      1,         1,              [0],            [1],    cols_one_el,  vals_one_el,   vector_one_el,    res_one_el,     5,  7,   0.5,  4]
])

#-------------------------------------------------------------------------
# Test Case
#-------------------------------------------------------------------------

def run_test(PE, test_params, cmdline_opts=None):

  # Create test harness with messages for the src/sink

  th = TestHarness( PE )
  num_rows = test_params.num_rows
  num_nnz  = test_params.num_nnz

  req_config  = PeConfigMsgs.req(0x1000, num_rows, num_nnz, num_rows)
  resp_config = PeConfigMsgs.resp(1)

  req_rows = []
  for i in range(len(test_params.row_start)):
    req_rows.append(PeRowsMsgs.req(test_params.row_start[i], test_params.row_end[i], i))

  resp_rows = PeRowsMsgs.resp(1) 

  th.set_param( "top.src_config.construct", msgs=[req_config],
    initial_delay=2, interval_delay=2 )

  th.set_param( "top.sink_config.construct", msgs=[resp_config],
    initial_delay=2, interval_delay=2 )

  th.set_param( "top.src_rows.construct", msgs=req_rows,
    initial_delay=2, interval_delay=2 )

  th.set_param( "top.sink_rows.construct", msgs=[resp_rows],
    initial_delay=2, interval_delay=2 )

  # s.base_src.out + (s.num_rows.out + s.num_nnz.out) * 8
  cols = test_params.cols
  vals = test_params.vals
  v    = test_params.vector

  cols_bytes = struct.pack("<{}I".format(len(cols)),*cols)
  vals_bytes = struct.pack("<{}I".format(len(vals)),*vals)
  v_bytes = struct.pack("<{}I".format(len(v)),*v)

  # Elaborate the model

  th.elaborate()

  # Load the data into the test memory

  th.mem.write_mem( 0x1000+4*(num_rows), cols_bytes )
  th.mem.write_mem( 0x1000+4*(num_rows+num_nnz), vals_bytes )
  th.mem.write_mem( 0x1000+4*(num_rows+2*num_nnz), v_bytes )

  # Run the test
  if cmdline_opts['max_cycles'] is None:
    cmdline_opts['max_cycles'] = 200
  run_sim( th, cmdline_opts, duts=['PE'] )
  
  # Retrieve data from test memory

  result_bytes = th.mem.read_mem( 0x1000+4*(num_rows*2+num_nnz*2), len(v_bytes))
    
  # Convert result bytes into list of ints

  result = list(struct.unpack("<{}I".format(num_rows),result_bytes))

  for i in range(num_rows):
    assert result[i] == test_params.res[i]

@pytest.mark.parametrize( **test_case_table )

def test(test_params, cmdline_opts ):
  run_test( SpmvPeRTL(), test_params, cmdline_opts )