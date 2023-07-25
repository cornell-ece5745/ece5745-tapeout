// ==========================================================================
// SPIstackVRTL.py
// ==========================================================================
// 
// Author: Jack Brzozowski
//     May 7, 2022

`include "SPI_v3/components/LoopThroughVRTL.v"
`include "SPI_v3/components/SPIMinionAdapterCompositeVRTL.v"

module SPI_v3_components_SPIstackVRTL 
#(
    parameter nbits = 34, // the size of the val/rdy msg for the SPI minion
    parameter num_entries = 1
)(
    input  logic clk,
    input  logic reset,

    input  logic loopthrough_sel,
    output logic minion_parity,
    output logic adapter_parity,

    // SPI Minion Ifc
    input  logic sclk,
    input  logic cs,
    input  logic mosi,
    output logic miso,

    // Send/Recv Ifc
    output logic                 send_val,
    output logic [(nbits-2)-1:0] send_msg,
    input  logic                 send_rdy,

    input  logic                 recv_val, 
    input  logic [(nbits-2)-1:0] recv_msg, 
    output logic                 recv_rdy
);

  logic              minion_out_val;
  logic [nbits-3:0]  minion_out_msg;
  logic              minion_out_rdy;

  logic              minion_in_val;
  logic [nbits-3:0]  minion_in_msg;
  logic              minion_in_rdy;


  SPI_v3_components_SPIMinionAdapterCompositeVRTL #(nbits, num_entries) minion
  (
    .clk( clk ),
    .reset( reset ),
    .cs( cs ),
    .miso( miso ),
    .mosi( mosi ),
    .sclk( sclk ),
    .minion_parity( minion_parity ),
    .adapter_parity( adapter_parity ),
    .recv_val( minion_in_val ),
    .recv_msg( minion_in_msg ),
    .recv_rdy( minion_in_rdy ),
    .send_val( minion_out_val ),
    .send_msg( minion_out_msg ),
    .send_rdy( minion_out_rdy )
  );

  SPI_v3_components_LoopThroughVRTL #(nbits-2) loopthrough
  (
    .clk( clk ),
    .reset( reset ),
    .sel( loopthrough_sel ),

    .upstream_req_val( minion_out_val ), 
    .upstream_req_msg( minion_out_msg ), 
    .upstream_req_rdy( minion_out_rdy ), 

    .upstream_resp_val( minion_in_val ),
    .upstream_resp_msg( minion_in_msg ),
    .upstream_resp_rdy( minion_in_rdy ),

    .downstream_req_val( send_val ), 
    .downstream_req_msg( send_msg ), 
    .downstream_req_rdy( send_rdy ), 

    .downstream_resp_val( recv_val ),
    .downstream_resp_msg( recv_msg ),
    .downstream_resp_rdy( recv_rdy )
  );


endmodule