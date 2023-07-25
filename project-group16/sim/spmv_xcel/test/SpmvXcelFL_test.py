#=========================================================================
# SpmvXcelFL_test
#=========================================================================

import pytest
import random
import struct

random.seed(0xdeadbeef)

from pymtl3 import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.test_utils import mk_test_case_table, run_sim
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType


from proc.XcelMsg import *

from spmv_xcel  import SpmvXcelFL

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, xcel, num_pe, type_model ):

    s.src  = stream.SourceRTL( XcelMsgs.req )
    s.sink = stream.SinkRTL( XcelMsgs.resp )

    s.xcel = xcel

    if type_model == 'fl':
      s.mem  = stream.MagicMemoryRTL( 1 )
      s.mem.ifc[0] //= s.xcel.mem

    else:

      mem_ifc_dtypes = [ mk_mem_msg(8,32,32) for _ in range(4*num_pe+1) ]
      s.mem    = stream.MagicMemoryRTL( nports = 4*num_pe + 1, mem_ifc_dtypes = mem_ifc_dtypes)
      for i in range(num_pe):
        s.mem.ifc[i*4] //= s.xcel.vals_ctrl_mem[i]
        s.mem.ifc[i*4+1] //= s.xcel.vec_ctrl_mem[i]
        s.mem.ifc[i*4+2] //= s.xcel.write_ctrl_mem[i]
        s.mem.ifc[i*4+3]   //= s.xcel.cols_ctrl_mem[i]

      s.mem.ifc[4*num_pe] //= s.xcel.mem

    s.src.send  //= s.xcel.xcel.req
    s.sink.recv //= s.xcel.xcel.resp


  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return "{} > {} | {}".format(
      s.src.line_trace(), s.xcel.line_trace(), s.sink.line_trace(), 
    )
    #   return "{} {} {} {} {} {} {} {} {} {} {} {} {}".format(
    #   s.src.line_trace(), s.xcel.line_trace(), s.sink.line_trace(), s.xcel.mem.req.msg, s.xcel.mem.resp.msg,
    #   s.xcel.cols_mem[0].req.msg, s.xcel.cols_mem[0].resp.msg, 
    #   s.xcel.vals_mem[0].req.msg, s.xcel.vals_mem[0].resp.msg, s.xcel.vec_mem[0].req.msg, s.xcel.vec_mem[0].resp.msg, 
    #   s.xcel.write_mem[0].req.msg, s.xcel.write_mem[0].resp.msg, 
    # )


#-------------------------------------------------------------------------
# make messages
#-------------------------------------------------------------------------

def req( type_, raddr, data ):
  return XcelReqMsg(XCEL_TYPE_READ if type_ == 'rd' else XCEL_TYPE_WRITE, raddr, data)

def resp( type_, data ):
  return XcelRespMsg(XCEL_TYPE_READ if type_ == 'rd' else XCEL_TYPE_WRITE, data)

#-------------------------------------------------------------------------
# Xcel Protocol
#-------------------------------------------------------------------------
# These are the source sink messages we need to configure the accelerator
# and wait for it to finish. We use the same messages in all of our
# tests. The difference between the tests is the data to be sorted in the
# test memory.

def gen_xcel_protocol_msgs( base_addr, num_rows, num_nnz, num_rows_pe ):
  return [
    req( 'wr', 1, base_addr     ), resp( 'wr', 0 ),
    req( 'wr', 2, num_rows      ), resp( 'wr', 0 ),
    req( 'wr', 3, num_nnz       ), resp( 'wr', 0 ),
    req( 'wr', 4, num_rows_pe   ), resp( 'wr', 0 ),
    req( 'wr', 0, 0             ), resp( 'wr', 0 ),
    req( 'rd', 0, 0             ), resp( 'rd', 1 ),
  ]

#-------------------------------------------------------------------------
# Test Case
#-------------------------------------------------------------------------

# sparsity = 43.75%
rows_mini       = [ 2, 2, 5, 7 ]
cols_mini       = [ 0, 2, 0, 2, 3, 1, 3 ]
vector_mini     = [ 1, 4, 6, 12 ]
vals_mini       = [ 1, 2, 1, 2, 3, 1, 2 ]

# sparsity = 1.95%
rows_mega       = [ 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 8, 9, 9, 9, 10, 12, 13, 13, 14, 15, 15, 16, 16, 17, 18, 19, 19, 19 ]
cols_mega       = [ 2, 6, 9, 21, 18, 15, 15, 10, 6, 21, 5, 1, 27, 26, 31, 27, 11, 3, 2, 17 ]
vals_mega       = [ 25, 41, 27, 2, 61, 95, 41, 61, 35, 32, 46, 72, 50, 9, 51, 23, 93, 24, 74, 66 ]
vector_mega     = [ 700, 234, 640, 523, 164, 794, 398, 229, 72, 372, 792, 14, 772, 771, 77, 853, 816, 981, 439, 372, 303, 797, 34, 141, 547, 441, 596, 778, 439, 672, 824, 114 ]

# sparsity = 2.04%
rows_mega_mega  = [ 1, 4, 7, 9, 10, 12, 16, 20, 23, 26, 29, 33, 38, 41, 42, 46, 49, 57, 59, 62, 65, 71, 74, 76, 78, 80, 82, 85, 96, 99, 102, 106, 108, 113, 115, 118, 119, 124, 128, 129, 131, 133, 137, 143, 145, 149, 154, 156, 160, 165, 169, 172, 174, 176, 178, 182, 183, 189, 191, 194, 199, 203, 204, 207, 209, 214, 219, 224, 226, 229, 233, 234, 235, 241, 243, 245, 247, 252, 256, 258, 260, 262, 263, 265, 271, 277, 280, 284, 287, 290, 296, 300, 305, 307, 311, 314, 317, 319, 321, 324, 330, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334 ]
cols_mega_mega  = [ 122, 28, 72, 108, 35, 67, 127, 26, 113, 107, 74, 98, 2, 97, 98, 111, 92, 98, 99, 114, 37, 72, 81, 26, 46, 114, 53, 63, 87, 1, 66, 118, 123, 28, 62, 119, 124, 126, 60, 75, 119, 94, 33, 48, 95, 100, 15, 67, 75, 8, 39, 41, 72, 73, 96, 102, 117, 28, 48, 1, 16, 125, 64, 75, 126, 5, 37, 45, 64, 96, 107, 24, 102, 124, 14, 113, 68, 118, 79, 123, 87, 88, 35, 55, 70, 23, 45, 46, 52, 78, 79, 80, 88, 104, 110, 118, 41, 106, 118, 34, 93, 105, 11, 64, 71, 116, 11, 33, 28, 63, 89, 104, 120, 89, 93, 15, 46, 125, 113, 0, 1, 8, 12, 90, 26, 30, 86, 101, 100, 52, 99, 55, 73, 18, 19, 62, 100, 21, 48, 53, 67, 90, 97, 60, 95, 14, 58, 79, 80, 12, 48, 55, 90, 106, 26, 45, 20, 41, 69, 88, 48, 55, 60, 91, 93, 28, 46, 109, 117, 8, 9, 92, 89, 103, 18, 46, 32, 44, 14, 36, 53, 94, 60, 41, 63, 71, 79, 114, 123, 13, 88, 26, 30, 51, 4, 48, 52, 79, 96, 40, 47, 88, 113, 45, 17, 49, 122, 18, 109, 22, 50, 61, 65, 76, 1, 57, 83, 122, 125, 1, 39, 42, 95, 100, 12, 80, 14, 26, 123, 33, 40, 116, 123, 102, 54, 9, 13, 32, 98, 107, 121, 16, 125, 8, 113, 7, 24, 4, 10, 45, 61, 117, 2, 21, 25, 30, 1, 111, 63, 79, 56, 114, 57, 47, 96, 3, 7, 51, 67, 116, 121, 0, 8, 12, 48, 64, 100, 10, 23, 52, 2, 83, 109, 115, 74, 79, 100, 22, 42, 89, 12, 37, 73, 84, 99, 106, 13, 60, 79, 123, 0, 41, 46, 48, 113, 13, 126, 85, 92, 100, 108, 76, 94, 95, 62, 67, 122, 53, 60, 12, 61, 5, 69, 97, 39, 61, 75, 86, 104, 119, 12, 27, 79, 115 ]
vals_mega_mega  = [ 65, 78, 29, 91, 67, 54, 65, 82, 34, 97, 60, 83, 11, 48, 11, 96, 25, 83, 69, 61, 17, 6, 22, 50, 52, 72, 88, 31, 30, 18, 30, 53, 79, 77, 1, 51, 11, 82, 52, 88, 3, 6, 99, 50, 19, 9, 63, 46, 59, 17, 88, 54, 11, 7, 14, 98, 65, 9, 37, 8, 42, 13, 15, 90, 95, 3, 77, 61, 40, 56, 80, 17, 44, 28, 5, 60, 72, 38, 13, 97, 100, 27, 86, 44, 16, 46, 51, 13, 43, 23, 89, 87, 19, 18, 29, 28, 72, 53, 41, 68, 38, 49, 76, 80, 62, 38, 79, 98, 31, 80, 59, 64, 98, 41, 3, 41, 83, 17, 53, 20, 12, 83, 72, 59, 95, 6, 31, 20, 74, 87, 53, 23, 4, 88, 19, 1, 1, 45, 30, 21, 40, 38, 64, 10, 78, 68, 44, 22, 5, 62, 85, 68, 30, 38, 34, 28, 57, 84, 63, 76, 20, 65, 71, 79, 88, 69, 97, 60, 87, 82, 79, 34, 75, 8, 4, 4, 9, 96, 18, 15, 49, 63, 67, 5, 5, 43, 23, 76, 74, 58, 100, 53, 26, 25, 21, 33, 69, 6, 34, 95, 7, 8, 87, 18, 13, 85, 11, 88, 83, 21, 85, 11, 1, 20, 8, 47, 85, 54, 17, 19, 42, 22, 29, 9, 14, 89, 19, 100, 22, 4, 77, 27, 15, 85, 51, 47, 37, 44, 56, 64, 53, 19, 85, 59, 12, 89, 53, 1, 80, 61, 46, 5, 68, 83, 70, 5, 22, 12, 19, 2, 18, 52, 3, 32, 57, 10, 68, 99, 41, 33, 58, 92, 10, 34, 8, 19, 90, 16, 72, 89, 23, 82, 23, 96, 58, 47, 65, 32, 41, 6, 1, 80, 50, 39, 79, 32, 3, 49, 47, 70, 61, 29, 67, 62, 75, 79, 64, 81, 100, 46, 37, 44, 3, 44, 13, 49, 12, 36, 86, 43, 7, 52, 1, 99, 58, 91, 57, 2, 8, 55, 31, 47, 83, 33 ]
vector_mega_mega= [ 26, 44, 55, 84, 9, 47, 96, 64, 68, 41, 59, 77, 87, 79, 65, 89, 39, 23, 5, 37, 28, 29, 40, 87, 37, 29, 77, 65, 46, 98, 21, 9, 85, 38, 10, 43, 72, 43, 13, 68, 69, 14, 25, 2, 39, 5, 44, 31, 60, 22, 92, 13, 59, 11, 80, 32, 63, 98, 89, 30, 60, 15, 88, 26, 75, 50, 11, 37, 2, 99, 50, 93, 32, 92, 48, 35, 50, 30, 67, 53, 67, 54, 61, 76, 22, 17, 7, 44, 59, 19, 12, 40, 9, 57, 39, 20, 96, 27, 80, 87, 16, 13, 12, 9, 8, 92, 70, 67, 83, 75, 45, 92, 84, 25, 60, 30, 19, 69, 93, 61, 61, 80, 76, 58, 58, 65, 67, 7 ]

# sparcity = 0.50%
rows_mini_mega =  [1, 3, 4, 8, 9, 12, 13, 16, 20, 23, 24, 25, 27, 28, 30, 31, 34, 38, 40, 42, 45, 46, 47, 49, 52, 54, 57, 59, 60, 62, 65, 68, 69, 71, 73, 79, 80, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82]
cols_mini_mega = [109, 61, 116, 88, 7, 26, 35, 94, 82, 45, 56, 116, 40, 5, 10, 100, 37, 78, 102, 126, 92, 96, 104, 69, 30, 21, 93, 45, 30, 84, 51, 20, 55, 80, 9, 55, 59, 106, 69, 104, 9, 45, 16, 67, 98, 95, 56, 37, 46, 11, 28, 97, 15, 72, 2, 15, 105, 70, 93, 31, 3, 13, 4, 30, 84, 15, 78, 120, 81, 50, 83, 45, 100, 30, 34, 58, 63, 65, 114, 84, 39, 119]
vals_mini_mega = [7, 12, 86, 29, 80, 38, 33, 3, 34, 16, 63, 90, 51, 81, 28, 36, 81, 6, 65, 67, 35, 31, 76, 44, 66, 50, 86, 16, 77, 85, 32, 48, 21, 55, 81, 28, 37, 54, 67, 41, 44, 72, 59, 59, 44, 71, 7, 42, 15, 24, 15, 80, 34, 24, 43, 37, 3, 84, 34, 49, 8, 72, 8, 39, 12, 47, 47, 100, 66, 30, 95, 10, 36, 81, 89, 80, 18, 39, 48, 64, 11, 1]
vector_mini_mega = [54, 31, 46, 74, 38, 12, 37, 18, 82, 89, 51, 40, 35, 93, 96, 7, 22, 19, 5, 79, 11, 36, 61, 18, 35, 67, 2, 46, 8, 53, 88, 99, 32, 1, 47, 9, 11, 100, 58, 81, 1, 22, 31, 97, 7, 61, 87, 31, 49, 14, 78, 82, 9, 15, 88, 62, 99, 64, 81, 58, 96, 51, 16, 1, 3, 27, 83, 67, 78, 68, 37, 71, 95, 40, 54, 65, 20, 80, 39, 43, 96, 8, 66, 64, 72, 12, 95, 99, 89, 70, 17, 68, 76, 24, 71, 24, 48, 31, 33, 45, 33, 71, 26, 86, 3, 40, 64, 79, 84, 30, 73, 97, 99, 80, 96, 5, 30, 59, 94, 18, 21, 38, 58, 71, 16, 32, 68, 66]

# num_nnz_rand_128 = random.randint(164,890)
# rows_rand_128x128 = sorted([random.randint(0,num_nnz_rand_128) for i in range(127)] + [num_nnz_rand_128])
# cols_rand_128x128 = []
# for i in range(len(rows_rand_128x128)):
#   curr = rows_rand_128x128[i-1] if i > 0 else 0 
#   next = rows_rand_128x128[i]
#   cols_rand_128x128 = cols_rand_128x128 + sorted([random.randint(0,127) for k in range(curr,next)])
# vals_rand_128x128 = [random.randint(0,0xffff) for a in range(num_nnz_rand_128)]
# vector_rand_128x128 = [random.randint(0,0xffff) for b in range(128)]

num_nnz_rand_128 = random.randint(0,890)
# num_nnz_rand_128 = random.randint(164,890)
rows_rand_128x128 = sorted([random.randint(0,num_nnz_rand_128) for i in range(128)])
cols_rand_128x128 = [random.randint(0,127) for i in range(num_nnz_rand_128)]
# cols_rand_128x128 = []
# for i in range(1,len(rows_rand_128x128)):
#   cols_rand_128x128 = cols_rand_128x128 +(sorted([random.randint(0,127) for i in range(rows_rand_128x128[i]-rows_rand_128x128[i-1])]))
vals_rand_128x128 = [random.randint(0,0xffff) for i in range(num_nnz_rand_128)]
vector_rand_128x128 = [random.randint(0,0xffff) for i in range(128)]

#-------------------------------------------------------------------------
# Test Case Table
#-------------------------------------------------------------------------

test_case_table = mk_test_case_table([
                         #                delays   test mem
                         #                -------- ---------
  (                      "rows         cols         vals          vector            src sink stall lat num_pe"),
  # [ "mini_1",               rows_mini,   cols_mini,   vals_mini,    vector_mini,      0,  0,   0,    0, 1   ],
  ["mini_2",               rows_mini,   cols_mini,   vals_mini,    vector_mini,      0,  0,   0,    0, 2   ],
  # ["mini_4",               rows_mini,   cols_mini,   vals_mini,    vector_mini,      0,  0,   0,    0, 4   ],
  # [ "mega_1",               rows_mega,   cols_mega,   vals_mega,    vector_mega,      0,  0,   0,    0, 1   ],
  # [ "mega_2",               rows_mega,   cols_mega,   vals_mega,    vector_mega,      0,  0,   0,    0, 2   ],
  # [ "mega_4",               rows_mega,   cols_mega,   vals_mega,    vector_mega,      0,  0,   0,    0, 4   ],
  # [ "mega_8",               rows_mega,   cols_mega,   vals_mega,    vector_mega,      0,  0,   0,    0, 8   ],
  # [ "mega_16",               rows_mega,   cols_mega,   vals_mega,    vector_mega,      0,  0,   0,    0, 16   ],
  # [ "mega_32",               rows_mega,   cols_mega,   vals_mega,    vector_mega,      0,  0,   0,    0, 32   ],
  # ["mega_mega_4",         rows_mega_mega,cols_mega_mega, vals_mega_mega, vector_mega_mega, 0, 0,0,0,     4],
  # ["mega_mega_32",         rows_mega_mega,cols_mega_mega, vals_mega_mega, vector_mega_mega, 0, 0,0,0,     32],
  # ["mega_mega_64",         rows_mega_mega,cols_mega_mega, vals_mega_mega, vector_mega_mega, 0, 0,0,0,     64],
  # ["mini_mega_4",         rows_mini_mega,cols_mini_mega, vals_mini_mega, vector_mini_mega, 0, 0,0,0,     4],
  # ["mini_mega_32",         rows_mini_mega,cols_mini_mega, vals_mini_mega, vector_mini_mega, 0, 0,0,0,     32],
  # ["mini_mega_64",         rows_mini_mega,cols_mini_mega, vals_mini_mega, vector_mini_mega, 0, 0,0,0,     64],
  # ["rand_128x128_4",        rows_rand_128x128, cols_rand_128x128, vals_rand_128x128, vector_rand_128x128, 0, 0, 0, 0, 4],
  # ["rand_128x128_32",        rows_rand_128x128, cols_rand_128x128, vals_rand_128x128, vector_rand_128x128, 0, 0, 0, 0, 32],
  # ["rand_128x128_64",        rows_rand_128x128, cols_rand_128x128, vals_rand_128x128, vector_rand_128x128, 0, 0, 0, 0, 64],
])

def spmv( num_rows, rows, cols, vals, v ):
  rows = [0] + rows
  dest = []
  for i in range(num_rows): 
    dest.append(0)
    sum = 0
    for j in range(rows[i], rows[i+1]):
      sum += vals[j] * v[cols[j]]
    dest[i] = sum
  return dest

#-------------------------------------------------------------------------
# run_test
#-------------------------------------------------------------------------

def run_test( xcel, num_pe, type_model, test_params, cmdline_opts=None ):

  # Convert test data into byte array

  rows = test_params.rows
  cols = test_params.cols
  vals = test_params.vals
  v    = test_params.vector
  num_rows = len(rows)
  num_nnz  = rows[num_rows-1] 
  
  rows_bytes = struct.pack("<{}I".format(len(rows)),*rows)
  cols_bytes = struct.pack("<{}I".format(len(cols)),*cols)
  vals_bytes = struct.pack("<{}I".format(len(vals)),*vals)
  v_bytes    = struct.pack("<{}I".format(len(v)),*v)

  # Protocol messages

  xcel_protocol_msgs = gen_xcel_protocol_msgs( 0x1000, num_rows, num_nnz, num_rows//num_pe )

  # Create test harness with protocol messagse

  th = TestHarness( xcel, num_pe, type_model )

  th.set_param( "top.src.construct", msgs=xcel_protocol_msgs[::2],
    initial_delay=test_params.src+3, interval_delay=test_params.src )

  th.set_param( "top.sink.construct", msgs=xcel_protocol_msgs[1::2],
    initial_delay=test_params.sink+3, interval_delay=test_params.sink )

  th.set_param( "top.mem.construct",
    stall_prob=test_params.stall, extra_latency=test_params.lat+1 )

  # Run the test

  th.elaborate()

  # Load the data into the test memory

  th.mem.write_mem( 0x1000, rows_bytes )
  th.mem.write_mem( 0x1000+4*(num_rows), cols_bytes )
  th.mem.write_mem( 0x1000+4*(num_rows+num_nnz), vals_bytes )
  th.mem.write_mem( 0x1000+4*(num_rows+2*num_nnz), v_bytes )

  # Enlarge max_cycles
  if cmdline_opts is None:
    cmdline_opts = {'dump_vcd': False, 'test_yosys_verilog': False, 'test_verilog': False, 'max_cycles': None, 'dump_vtb': '', 'dump_textwave': False}

  if cmdline_opts['max_cycles'] is None:
    cmdline_opts['max_cycles'] = 20000

  run_sim( th, cmdline_opts, duts=['xcel'] )
  
  
  # Retrieve data from test memory

  result_bytes = th.mem.read_mem( 0x1000+4*(num_rows*2+num_nnz*2), len(v_bytes))

  # Convert result bytes into list of ints

  result = list(struct.unpack("<{}I".format(num_rows),result_bytes))

  # Compare result to sorted reference
  assert result == spmv( num_rows, rows, cols, vals, v )

#-------------------------------------------------------------------------
# Test case
#-------------------------------------------------------------------------

@pytest.mark.parametrize( **test_case_table )
def test( test_params ):
  run_test( SpmvXcelFL(1), 1, 'fl', test_params )
