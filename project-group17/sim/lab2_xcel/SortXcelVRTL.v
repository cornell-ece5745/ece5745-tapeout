//=========================================================================
// Sorting Accelerator Implementation
//=========================================================================
// Sort array in memory containing positive integers.
// Accelerator register interface:
//
//  xr0 : go/done
//  xr1 : base address of array
//  xr2 : number of elements in array
//
// Accelerator protocol involves the following steps:
//  1. Write the base address of array via xr1
//  2. Write the number of elements in array via xr2
//  3. Tell accelerator to go by writing xr0
//  4. Wait for accelerator to finish by reading xr0, result will be 1
//

`ifndef LAB2_SORT_SORT_XCEL_V
`define LAB2_SORT_SORT_XCEL_V

`include "vc/trace.v"

`include "vc/mem-msgs.v"
`include "vc/queues.v"
`include "proc/XcelMsg.v"

//=========================================================================
// Sorting Accelerator Implementation
//=========================================================================

module lab2_xcel_SortXcelVRTL
(
  input  logic         clk,
  input  logic         reset,

  // look at XcelMsg for bit definition
  output logic         xcelreq_rdy,
  input  logic         xcelreq_val,
  input  XcelReqMsg    xcelreq_msg,

  input  logic         xcelresp_rdy,
  output logic         xcelresp_val,
  output XcelRespMsg   xcelresp_msg,

  // look at MemMsg in stdlib.ifcs for bit definition
  input  logic         memreq_rdy,
  output logic         memreq_val,
  output mem_req_4B_t  memreq_msg,

  output logic         memresp_rdy,
  input  logic         memresp_val,
  input  mem_resp_4B_t memresp_msg
);

  // Accelerator ports and queues

  logic        xcelreq_send_val;
  logic        xcelreq_send_rdy;
  XcelReqMsg   xcelreq_send_msg;

  vc_Queue#(`VC_QUEUE_PIPE,$bits(xcelreq_msg),1) xcelreq_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(),
    .recv_val (xcelreq_val),
    .recv_rdy (xcelreq_rdy),
    .recv_msg (xcelreq_msg),
    .send_val (xcelreq_send_val),
    .send_rdy (xcelreq_send_rdy),
    .send_msg (xcelreq_send_msg)
  );

  // Memory ports and queues

  logic           memresp_send_val;
  logic           memresp_send_rdy;
  mem_resp_4B_t   memresp_send_msg;

  vc_Queue#(`VC_QUEUE_PIPE,$bits(memresp_msg),1) memresp_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(),
    .recv_val (memresp_val),
    .recv_rdy (memresp_rdy),
    .recv_msg (memresp_msg),
    .send_val (memresp_send_val),
    .send_rdy (memresp_send_rdy),
    .send_msg (memresp_send_msg)
  );

  // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Create RTL model for sorting xcel
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

  // This bypass queue is to cut the ready path

  logic          memreq_recv_val;
  logic          memreq_recv_rdy;
  mem_req_4B_t   memreq_recv_msg;

  mem_req_4B_t memreq_msg_raw; //4-state sim fix
  assign memreq_msg = memreq_msg_raw & {78{memreq_val}};

  vc_Queue#(`VC_QUEUE_BYPASS,$bits(memreq_msg),1) memreq_q
  (
    .clk     (clk),
    .reset   (reset),
    .num_free_entries(),
    .recv_val (memreq_recv_val),
    .recv_rdy (memreq_recv_rdy),
    .recv_msg (memreq_recv_msg),
    .send_val (memreq_val),
    .send_rdy (memreq_rdy),
    .send_msg (memreq_msg_raw)
  );
  // Extra state registers

  logic [31:0] base_addr,   base_addr_in;
  logic [31:0] size,        size_in;
  logic [31:0] inner_count, inner_count_in;
  logic [31:0] outer_count, outer_count_in;
  logic [31:0] a,           a_in;

  always_ff @(posedge clk) begin
    if (reset) begin
      outer_count <= 0;
      inner_count <= 0;
      base_addr   <= 0;
      size        <= 0;
      a           <= 0;
    end
    else begin 
      outer_count <= outer_count_in;
      inner_count <= inner_count_in;
      base_addr   <= base_addr_in;
      size        <= size_in;
      a           <= a_in;
    end
  end

 
  XcelRespMsg xcelresp_msg_raw; //4-state sim fix
  assign xcelresp_msg = xcelresp_msg_raw & {33{xcelresp_val}};

  //======================================================================
  // State Update
  //======================================================================

  typedef enum logic [$clog2(6)-1:0] {
    STATE_XCFG,
    STATE_FIRST0,
    STATE_FIRST1,
    STATE_BUBBLE0,
    STATE_BUBBLE1,
    STATE_LAST
  } state_t;

  state_t state_reg;

  logic go;

  always_ff @(posedge clk) begin

    if ( reset )
      state_reg <= STATE_XCFG;
    else begin
      state_reg <= state_reg;

      case ( state_reg )

        STATE_XCFG:
          if ( go && xcelresp_rdy )
            state_reg <= STATE_FIRST0;

        STATE_FIRST0:
          if ( memreq_recv_rdy )
            state_reg <= STATE_FIRST1;

        STATE_FIRST1:
          if ( memreq_recv_rdy && memresp_send_val )
            state_reg <= STATE_BUBBLE0;

        STATE_BUBBLE0:
          if ( memreq_recv_rdy && memresp_send_val )
            state_reg <= STATE_BUBBLE1;

        STATE_BUBBLE1:
          if ( memreq_recv_rdy && memresp_send_val )
            if ( inner_count+1 < size )
              state_reg <= STATE_BUBBLE0;
            else
              state_reg <= STATE_LAST;

        STATE_LAST:
          if ( memreq_recv_rdy && memresp_send_val )
            if ( outer_count+1 < size )
              state_reg <= STATE_FIRST1;
            else
              state_reg <= STATE_XCFG;

        default:
          state_reg <= STATE_XCFG;

      endcase
    end
  end

  //======================================================================
  // State Outputs
  //======================================================================

  always_comb begin

    xcelreq_send_rdy = 0;
    xcelresp_val     = 0;
    memreq_recv_val  = 0;
    memreq_recv_msg  = 0;
    memresp_send_rdy = 0;
    go             = 0;

    a_in = a;
    outer_count_in = outer_count;
    inner_count_in = inner_count;
    base_addr_in = base_addr;
    size_in = size;

    //--------------------------------------------------------------------
    // STATE: XCFG
    //--------------------------------------------------------------------

    if ( state_reg == STATE_XCFG ) begin

      if ( xcelreq_send_val & xcelresp_rdy ) begin
        xcelreq_send_rdy = 1;
      end
      if ( xcelreq_send_val ) begin
        xcelresp_val     = 1;
      // end

        // Send xcel response message, obviously you only want to
        // send the response message when accelerator is done

        if ( xcelreq_send_msg.type_ == `XcelReqMsg_TYPE_READ ) begin
          xcelresp_msg_raw.type_ = `XcelRespMsg_TYPE_READ;
          xcelresp_msg_raw.data  = 1;
        end
        else begin
          if ( xcelreq_send_msg.addr == 0 ) begin
            outer_count_in = 0;
            inner_count_in = 0;
            go             = 1;
          end
          else if ( xcelreq_send_msg.addr == 1 )
            base_addr_in = xcelreq_send_msg.data;

          else if ( xcelreq_send_msg.addr == 2 )
            size_in = xcelreq_send_msg.data;

          xcelresp_msg_raw.type_ = `XcelRespMsg_TYPE_WRITE;
          xcelresp_msg_raw.data  = 0;
        end
      end
    end

    //--------------------------------------------------------------------
    // STATE: FIRST0
    //--------------------------------------------------------------------
    // Send the first memory read request for the very first element in
    // the array.

    else if ( state_reg == STATE_FIRST0 ) begin
      memreq_recv_val = 1;
      memreq_recv_msg.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
      memreq_recv_msg.addr  = base_addr + (inner_count << 2);
      memreq_recv_msg.len   = 0;
      memreq_recv_msg.data  = 0;

      if ( memreq_recv_rdy ) begin
        inner_count_in = 1;
      end
    end

    //--------------------------------------------------------------------
    // STATE: FIRST1
    //--------------------------------------------------------------------
    // Wait for the memory response for the first element in the array,
    // and once it arrives store this element in a, and send the memory
    // read request for the second element.

    else if ( state_reg == STATE_FIRST1 ) begin

      if ( memreq_recv_rdy && memresp_send_val ) begin
        memresp_send_rdy = 1;
        memreq_recv_val  = 1;

        a_in = memresp_send_msg.data;

        memreq_recv_msg.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
        memreq_recv_msg.addr  = base_addr + (inner_count << 2);
        memreq_recv_msg.len   = 0;
        memreq_recv_msg.data  = 0;

      end
    end

    //--------------------------------------------------------------------
    // STATE: BUBBLE0
    //--------------------------------------------------------------------
    // Wait for the memory read response to get the next element, compare
    // the new value to the previous max value, update b with the new max
    // value, and send a memory request to store the new min value.
    // Notice how we decrement the write address by four since we want to
    // store to the new min value _previous_ element.

    else if ( state_reg == STATE_BUBBLE0 ) begin

      if ( memreq_recv_rdy && memresp_send_val ) begin
        memresp_send_rdy = 1;
        memreq_recv_val  = 1;

        if ( a > memresp_send_msg.data ) begin
          a_in = a;
          memreq_recv_msg.data = memresp_send_msg.data;
        end
        else begin
          a_in = memresp_send_msg.data;
          memreq_recv_msg.data = a;
        end

        memreq_recv_msg.type_ = `VC_MEM_REQ_MSG_TYPE_WRITE;
        memreq_recv_msg.addr  = base_addr + ((inner_count-1) << 2);
        memreq_recv_msg.len   = 0;

      end
    end

    //--------------------------------------------------------------------
    // STATE: BUBBLE1
    //--------------------------------------------------------------------
    // Wait for the memory write response, and then check to see if we
    // have reached the end of the array. If we have not reached the end
    // of the array, then make a new memory read request for the next
    // element; if we have reached the end of the array, then make a
    // final write request (with value from a) to update the final
    // element in the array.

    else if ( state_reg == STATE_BUBBLE1 ) begin

      if ( memreq_recv_rdy && memresp_send_val ) begin
        memresp_send_rdy = 1;
        memreq_recv_val  = 1;

        inner_count_in = inner_count + 1;
        if ( inner_count+1 < size ) begin

          memreq_recv_msg.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
          memreq_recv_msg.addr  = base_addr + ((inner_count+1) << 2);
          memreq_recv_msg.len   = 0;
          memreq_recv_msg.data  = 0;

        end
        else begin

          memreq_recv_msg.type_ = `VC_MEM_REQ_MSG_TYPE_WRITE;
          memreq_recv_msg.addr  = base_addr + (inner_count << 2);
          memreq_recv_msg.len   = 0;
          memreq_recv_msg.data  = a;

        end

      end
    end

    //--------------------------------------------------------------------
    // STATE: LAST
    //--------------------------------------------------------------------
    // Wait for the last response, and then check to see if we need to go
    // through the array again. If we do need to go through array again,
    // then make a new memory read request for the very first element in
    // the array; if we do not need to go through the array again, then
    // we are all done and we can go back to accelerator configuration.

    else if ( state_reg == STATE_LAST ) begin

      if ( memreq_recv_rdy && memresp_send_val ) begin
        memresp_send_rdy = 1;

        outer_count_in = outer_count + 1;
        if ( outer_count+1 < size ) begin

          memreq_recv_val  = 1;
          memreq_recv_msg.type_ = `VC_MEM_REQ_MSG_TYPE_READ;
          memreq_recv_msg.addr  = base_addr;
          memreq_recv_msg.len   = 0;
          memreq_recv_msg.data  = 0;

          inner_count_in       = 1;

        end

      end

    end

  end

  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    vc_trace.append_str( trace_str, "(" );

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Define line trace here
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/

    $sformat( str, "%x", outer_count );
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, ":" );

    $sformat( str, "%x", inner_count );
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, ":" );

    case ( state_reg )
      STATE_XCFG:      vc_trace.append_str( trace_str, "X " );
      STATE_FIRST0:    vc_trace.append_str( trace_str, "F0" );
      STATE_FIRST1:    vc_trace.append_str( trace_str, "F1" );
      STATE_BUBBLE0:   vc_trace.append_str( trace_str, "B0" );
      STATE_BUBBLE1:   vc_trace.append_str( trace_str, "B1" );
      STATE_LAST:      vc_trace.append_str( trace_str, "L " );
      default:         vc_trace.append_str( trace_str, "? " );
    endcase

    $sformat( str, "xr%2x = %x", xcelreq_msg.addr, xcelreq_msg.data );
    vc_trace.append_val_rdy_str( trace_str, xcelreq_val, xcelreq_rdy, str );

    vc_trace.append_str( trace_str, "(" );
    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", xcelresp_msg.data );
    vc_trace.append_val_rdy_str( trace_str, xcelresp_val, xcelresp_rdy, str );

    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

    vc_trace.append_str( trace_str, ")" );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB2_XCEL_SORT_XCEL_V */

