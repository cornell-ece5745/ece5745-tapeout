/*
==========================================================================
SPILoopBackCompositeVRTL.v
==========================================================================
A composition module consisting of SPIMinionAdapterComposite and Loopback modules.
For use with testing SPI communication

Author : Kyle Infantino
  Date : Oct 31, 2022

*/
`ifndef SPI_V3_COMPONENTS_LOOPBACKCOMPOSITE_V
`define SPI_V3_COMPONENTS_LOOPBACKCOMPOSITE_V

`include "SPI_v3/components/LoopBackVRTL.v"
`include "SPI_v3/components/SPIMinionAdapterCompositeVRTL.v"

module SPI_v3_components_SPILoopBackCompositeVRTL
#(
  parameter nbits = 32
)(
  input  logic clk,
  input  logic reset,
  input  logic cs,
  input  logic sclk,
  input  logic mosi,
  output logic miso,
  output logic minion_parity,
  output logic adapter_parity
);

  logic spi_send_val;
  logic spi_send_rdy;
  logic [nbits-3:0] spi_send_msg;

  logic spi_recv_val;
  logic spi_recv_rdy;
  logic [nbits-3:0] spi_recv_msg;

  SPI_v3_components_SPIMinionAdapterCompositeVRTL #(nbits, 1) spi (
    .clk(clk),
    .cs(cs),
    .miso(miso),
    .mosi(mosi),
    .reset(reset),
    .sclk(sclk),
    .recv_msg(spi_send_msg),
    .recv_rdy(spi_send_rdy),
    .recv_val(spi_send_val),
    .send_msg(spi_recv_msg),
    .send_rdy(spi_recv_rdy),
    .send_val(spi_recv_val),
    .minion_parity(minion_parity),
    .adapter_parity(adapter_parity)
  );

  SPI_v3_components_LoopBackVRTL #(nbits) loopback (
    .clk(clk),
    .reset(reset),
    .recv_val(spi_recv_val),
    .recv_rdy(spi_recv_rdy),
    .recv_msg(spi_recv_msg),
    .send_val(spi_send_val),
    .send_rdy(spi_send_rdy),
    .send_msg(spi_send_msg)
  );

endmodule

`endif //SPI_V3_COMPONENTS_LOOPBACKCOMPOSITE_V