/*
==========================================================================
PacketSerDesVRTL.v
==========================================================================
Generic packet serialized/deserializer. 
Instantiates either a PacketAssembler or PacketDisassembler based on the 
nbits_in and nbits_out parameters.

Author: Kyle Infantino
October 29, 2022
*/

`ifndef SPI_V3_COMPONENTS_PACKETSERDES_V
`define SPI_V3_COMPONENTS_PACKETSERDES_V

`include "SPI_v3/components/PacketDisassemblerVRTL.v"
`include "SPI_v3/components/PacketAssemblerVRTL.v"

module SPI_v3_components_PacketSerDesVRTL
#(
  parameter nbits_in = 8,
  parameter nbits_out = 8
)(
  input  logic                 clk,
  input  logic                 reset,

  input  logic                 recv_val,
  output logic                 recv_rdy,
  input  logic [nbits_in-1:0]  recv_msg,

  output logic                 send_val,
  input  logic                 send_rdy,
  output logic [nbits_out-1:0] send_msg
);

  if (nbits_in > nbits_out) begin
    SPI_v3_components_PacketDisassemblerVRTL #(nbits_in, nbits_out) disassem ( .* );
  end else begin
    SPI_v3_components_PacketAssemblerVRTL #(nbits_in, nbits_out) assem ( .* );
  end

endmodule

`endif // SPI_V3_COMPONENTS_PACKETSERDES_V