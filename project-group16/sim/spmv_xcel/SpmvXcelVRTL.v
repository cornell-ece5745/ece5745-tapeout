`ifndef SPMV_XCEL_V
`define SPMV_XCEL_V

`include "vc/trace.v"

module SpmvXcelVRTL(
    input logic clk,
    input logic reset,
    
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

    input  logic         memresp_val,
    input  mem_resp_4B_t memresp_msg,
    output logic         memresp_rdy
);

)