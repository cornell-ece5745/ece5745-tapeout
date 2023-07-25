//-------------------------------------------------------------------------
// SPIMinionAdapterVRTL.v
//-------------------------------------------------------------------------
`include "vc/queues.v"

module SPI_v3_components_SPIMinionAdapterVRTL
#(
  parameter nbits = 8,
  parameter num_entries = 1
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    pull_en,
  output logic                    pull_msg_val,
  output logic                    pull_msg_spc,
  output logic [nbits-1:0]        pull_msg_data,
  input  logic                    push_en,
  input  logic                    push_msg_val_wrt,
  input  logic                    push_msg_val_rd,
  input  logic [nbits-1:0]        push_msg_data,
  input  logic [nbits-3:0]        recv_msg,
  output logic                    recv_rdy,
  input  logic                    recv_val,
  output logic [nbits-3:0]        send_msg,
  input  logic                    send_rdy,
  output logic                    send_val,
  output logic                    parity  
);

  logic open_entries;

  logic [$clog2(num_entries):0] cm_q_num_free;
  logic [nbits-3:0]             cm_q_send_msg;
  logic                         cm_q_send_rdy;
  logic                         cm_q_send_val;

  vc_Queue #(4'b0, nbits, num_entries) cm_q
  (
    .clk( clk ),
    .num_free_entries( cm_q_num_free ),
    .reset( reset ),
    .recv_msg( recv_msg ),
    .recv_rdy( recv_rdy ),
    .recv_val( recv_val ),
    .send_msg( cm_q_send_msg ),
    .send_rdy( cm_q_send_rdy ),
    .send_val( cm_q_send_val )
  );

  logic [$clog2(num_entries):0] mc_q_num_free;
  logic                         mc_q_recv_rdy;
  logic                         mc_q_recv_val;

  vc_Queue #(4'b0, nbits, num_entries) mc_q
  (
    .clk( clk ),
    .num_free_entries( mc_q_num_free ),
    .reset( reset ),
    .recv_msg( push_msg_data ),
    .recv_rdy( mc_q_recv_rdy ),
    .recv_val( mc_q_recv_val ),
    .send_msg( send_msg ),
    .send_rdy( send_rdy ),
    .send_val( send_val )
  );

  assign parity = (^send_msg) & send_val;
  
  always_comb begin : comb_block
    open_entries = mc_q_num_free > 1;
    mc_q_recv_val = push_msg_val_wrt & push_en;
    pull_msg_spc = mc_q_recv_rdy & ( ( ~mc_q_recv_val ) | open_entries );
    cm_q_send_rdy = push_msg_val_rd & pull_en;
    pull_msg_val = cm_q_send_rdy & cm_q_send_val;
    pull_msg_data = cm_q_send_msg & { (nbits-2){pull_msg_val} };
  end

endmodule
