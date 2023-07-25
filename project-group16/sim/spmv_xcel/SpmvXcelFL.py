#=========================================================================
# Spmv FL Model
#=========================================================================
# Sort array in memory containing positive integers.
# Accelerator register interface:
#
#  xr0 : go/done
#  xr1 : base address of data (sparse matrix and vector)
#  xr2 : vector and matrix dimension (number of rows and dense vector elements)
#  xr3 : number of non-zero elements
#
# Accelerator protocol involves the following steps:
#  1. Write the base address of data via xr1
#  2. Write the dimension (number of rows) via xr2
#  3. Write the number of non-zero elements via xr3
#  3. Tell accelerator to go by writing xr0
#  4. Wait for accelerator to finish by reading xr0, result will be 1
#

from pymtl3        import *
from pymtl3.stdlib import stream
from pymtl3.stdlib.mem  import mk_mem_msg, MemMsgType
from proc.XcelMsg import *

# from proc.XcelMsg import *

def spmv( num_rows, rows, cols, vals, v ):
  dest = []
  rows = [0] + rows
  for i in range(num_rows): 
      dest.append(0)
      sum = 0
      for j in range(rows[i], rows[i+1]):
          sum += vals[j] * v[cols[j]]
      dest[i] = sum
  return dest

class SpmvXcelFL( Component ):


  def construct( s, num_pe = 1 ):

    # Interface

    s.xcel = stream.ifcs.MinionIfcRTL( XcelReqMsg, XcelRespMsg )
    s.mem  = stream.ifcs.MasterIfcRTL( *mk_mem_msg( 8,32,32 ) )

    s.xcelreq_q  = stream.fl.RecvQueueAdapter(XcelReqMsg)
    s.xcelresp_q = stream.fl.SendQueueAdapter(XcelRespMsg)
    s.xcelreq_q.recv  //= s.xcel.req
    s.xcelresp_q.send //= s.xcel.resp

    s.mem_adapter = stream.fl.MemMasterAdapter( *mk_mem_msg( 8,32,32 ) )
    s.mem_adapter.master //= s.mem

    # Storage
    s.base_addr  = 0
    s.num_rows = 0
    s.num_nnz = 0
    s.num_rows_pe = 0

    @update_once
    def up_spmv_xcel():

      # We loop handling accelerator requests. We are only expecting
      # writes to xr0-4, so any other requests are an error. We exit the
      # loop when we see the write to xr0.

      go = False
      while not go:

        xcelreq_msg = s.xcelreq_q.deq()

        if xcelreq_msg.type_ == XCEL_TYPE_WRITE:
          assert xcelreq_msg.addr in [0,1,2,3,4], "Only reg writes to 0,1,2,3 allowed during setup!"

          # Use xcel register address to configure accelerator

          if   xcelreq_msg.addr == 0: go = True
          if   xcelreq_msg.addr == 1: s.base_addr  = xcelreq_msg.data
          elif xcelreq_msg.addr == 2: s.num_rows = xcelreq_msg.data
          elif xcelreq_msg.addr == 3: s.num_nnz = xcelreq_msg.data
          elif xcelreq_msg.addr == 4: s.num_rows_pe = xcelreq_msg.data

          # Send xcel response message
          s.xcelresp_q.enq( XcelRespMsg( XCEL_TYPE_WRITE, 0 ) )

      rows = []
      cols = []
      vals = []
      v = []
      dest_vect = []

      for i in range(s.num_rows):
        
        rows.append(s.mem_adapter.read( s.base_addr + i*4, 4 ))
        v.append(s.mem_adapter.read( s.base_addr + (i+s.num_rows+2*s.num_nnz)*4, 4 ))
        
      rows.append(s.mem_adapter.read( s.base_addr + s.num_rows*4, 4 ))

      for i in range(s.num_nnz):
        cols.append(s.mem_adapter.read( s.base_addr + (i+s.num_rows)*4, 4 ))
        vals.append(s.mem_adapter.read( s.base_addr + (i+s.num_nnz+s.num_rows)*4, 4 ))
        
      
      dest_vect = spmv( s.num_rows, rows, cols, vals, v )
      dest_addr = s.base_addr + (2*s.num_rows + 2*s.num_nnz) * 4

      for i in range(s.num_rows):
        s.mem_adapter.write( dest_addr + i*4, 4, dest_vect[i] )

      # Now wait for read of xr0

      xcelreq_msg = s.xcelreq_q.deq()

      # Only expecting read from xr0, so any other request is an xcel
      # protocol error.

      assert xcelreq_msg.type_ == XCEL_TYPE_READ, "Only reg reads allowed during done phase!"

      assert xcelreq_msg.addr == 0, "Only reg read to 0 allowed during done phase!"

      # Send xcel response message indicating xcel is done
      s.xcelresp_q.enq( XcelRespMsg( XCEL_TYPE_READ, 1 ) )

  # Line tracing

  def line_trace( s ):
    return f"{s.xcel}|{s.mem}"
