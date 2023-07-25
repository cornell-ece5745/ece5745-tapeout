// ==========================================================================
// LoopThroughVRTL.py
// ==========================================================================
// This module is meant to either loopback data to the the upstream module, 
// or pass data to the downstream module, depending on the select bit. 
// If sel = 1, no data is passed to the downstream block, it is simply 
// looped to the upstream.
// If sel = 0, this module essentially connects the upstream to the 
// downstream blocks.

// Author: Dilan Lakhani, Updated by Jack Brzozowski
//     February 25, 2022

module SPI_v3_components_LoopThroughVRTL 
#(
    parameter nbits = 32 // the size of the val/rdy msg
)(
    input logic clk,
    input logic reset,
    input logic sel,

    // upstream Minion Ifc
    input  logic             upstream_req_val, 
    input  logic [nbits-1:0] upstream_req_msg, 
    output logic             upstream_req_rdy, 

    output logic             upstream_resp_val,
    output logic [nbits-1:0] upstream_resp_msg,
    input  logic             upstream_resp_rdy,

    // downstream Master Ifc
    output logic             downstream_req_val, 
    output logic [nbits-1:0] downstream_req_msg, 
    input  logic             downstream_req_rdy, 

    input  logic             downstream_resp_val,
    input  logic [nbits-1:0] downstream_resp_msg,
    output logic             downstream_resp_rdy
);

    assign upstream_resp_val= (sel) ? upstream_req_val : downstream_resp_val;
    assign upstream_resp_msg= (sel) ? upstream_req_msg : downstream_resp_msg;

    assign downstream_req_val= (sel) ? 0 : upstream_req_val;
    assign downstream_req_msg= upstream_req_msg;

    assign upstream_req_rdy= (sel) ? upstream_resp_rdy : downstream_req_rdy;

    assign downstream_resp_rdy= (sel) ? 0 : upstream_resp_rdy;

endmodule