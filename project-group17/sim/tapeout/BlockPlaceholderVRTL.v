//===============================================================================
// BlockPlaceholderVRTL
//===============================================================================
// This module is connected to the SPI_stack upon release of the Tapeout folder.
// It will be replaced by the module the group is hoping to put onto the chip.
// The reason for this is that smoke tests will not pass in pymtl3 unless all the
// ports are connected.
//
// This module is simply another loopback
//
// Author : Jack Brzozowski
//   Date : May 18th, 2022


module tapeout_BlockPlaceholderVRTL
#(
    parameter nbits = 32
)(

    output logic             send_val,
    output logic [nbits-1:0] send_msg,
    input  logic             send_rdy,

    input  logic             recv_val, 
    input  logic [nbits-1:0] recv_msg, 
    output logic             recv_rdy
);

// Simple Loopback
assign send_val = recv_val;
assign send_msg = recv_msg;
assign recv_rdy = send_rdy;

endmodule