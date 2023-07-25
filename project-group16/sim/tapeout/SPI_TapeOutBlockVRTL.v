//===============================================================================================
// SPI_TapeOutBlockVRTL
//===============================================================================================
// A composition module combining the SPI stack (SPI Minion, SPI Minion Adapter, and Loopthrough)
// that connects to the individual project group's block module. This was used for the 
// efabless tapeout in Spring 2022.
//
// Author : Jack Brzozowski
//   Date : May 9th, 2022

`include "SPI_v3/components/SPIstackVRTL.v"
`include "tapeout/BlockPlaceholderVRTL.v"
// ADD INCLUDES HERE FOR YOUR MODULE

module tapeout_SPI_TapeOutBlockVRTL
#(
    parameter nbits = 34, // the size of the val/rdy msg for the SPI Minion (includes the two flow control bits)
    parameter num_entries = 5
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
    output logic miso
);

parameter packet_nbits = nbits - 2; //remove control flow bits

logic                    send_val;
logic [packet_nbits-1:0] send_msg;
logic                    send_rdy;

logic                    recv_val; 
logic [packet_nbits-1:0] recv_msg;
logic                    recv_rdy;

// We add two to nbits for the two SPI minion flow control bits 
SPI_v3_components_SPIstackVRTL #(nbits, num_entries) SPIstack
(
    .clk(clk),
    .reset(reset),
    .loopthrough_sel(loopthrough_sel),
    .minion_parity(minion_parity),
    .adapter_parity(adapter_parity),

    // SPI Minion Ifc
    .sclk(sclk),
    .cs(cs),
    .mosi(mosi),
    .miso(miso),

    // Send/Recv Ifc
    .send_val(send_val),
    .send_msg(send_msg),
    .send_rdy(send_rdy),

    .recv_val(recv_val), 
    .recv_msg(recv_msg), 
    .recv_rdy(recv_rdy)
);

//=============================================================================
// TAPEOUT TASK: Instantiate your module below and connect it to the SPI stack
//=============================================================================

tapeout_BlockPlaceholderVRTL #(packet_nbits) Placeholder
(
    // Send/Recv Ifc
    .send_val(send_val),
    .send_msg(send_msg),
    .send_rdy(send_rdy),

    .recv_val(recv_val), 
    .recv_msg(recv_msg), 
    .recv_rdy(recv_rdy)
);

endmodule