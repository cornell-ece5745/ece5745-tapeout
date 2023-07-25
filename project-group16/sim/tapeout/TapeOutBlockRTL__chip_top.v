`include "SPI_TapeOutBlockRTL__32bits_5entries__pickled.v"

//A wrapper module used to instantiate I/O pads and connect them with the block-level design

//----------------------------------------------------------------------
// Pads
//----------------------------------------------------------------------
//     EN     : If 1, DOUT writes to PAD, if 0, short from PAD to DIN
//     DOUT   : Output of the chip, to the iocell, on the chip side
//     DIN    : Input to the chip from the iocell, on the chip side
//     PAD    : Signal pin on the pad side, (to the outside world)
//
//                                   _______________________________________
//                                  |
//         ______________  EN       |
//        |              |----------|
//  PAD---| Iocell Pad   | DIN      |     Chip Core Area
//        |              |----------|
//        |              | DOUT     |
//        |______________|----------|
//                                  |
//         ______________           |
//        |              |          |   


`define OUTPUT_PAD(name, pad, signal)     \
BidirectionalIOPad name                   \
(                                         \
  .EN  (1'b1  ),                          \
  .DOUT(signal),                          \
  .DIN (      ),                          \
  .PAD (pad   )                           \
);

`define INPUT_PAD(name, pad, signal)      \
BidirectionalIOPad name                   \
(                                         \
  .EN  (1'b0  ),                          \
  .DOUT(      ),                          \
  .DIN (signal),                          \
  .PAD (pad   )                           \
);

//----------------------------------------------------------------------
// Design
//----------------------------------------------------------------------

module TapeOutBlockRTL__chip_top
(
  input  wire clk ,
  input  wire reset ,
  input  wire cs ,
  output wire miso ,
  input  wire mosi ,
  input  wire sclk ,
  input  wire loopthrough_sel,
  output wire minion_parity,
  output wire adapter_parity
);

  // From iocell to core area
  logic clk_core;
  logic cs_core;
  logic miso_core;
  logic mosi_core;
  logic reset_core;
  logic sclk_core;
  logic minion_parity_core;
  logic adapter_parity_core;

              //name                 pad              signal
  `INPUT_PAD(   clk_pad,             clk,             clk_core             )
  `INPUT_PAD(   reset_pad,           reset,           reset_core           )
  `INPUT_PAD(   cs_pad,              cs,              cs_core              )
  `OUTPUT_PAD(  miso_pad,            miso,            miso_core            )
  `INPUT_PAD(   mosi_pad,            mosi,            mosi_core            )
  `INPUT_PAD(   sclk_pad,            sclk,            sclk_core            )
  `INPUT_PAD(   loopthrough_sel_pad, loopthrough_sel, loopthrough_sel_core )
  `OUTPUT_PAD(  minion_parity_pad,   minion_parity,   minion_parity_core   )
  `OUTPUT_PAD(  adapter_parity_pad,  adapter_parity,  adapter_parity_core  )

// MODIFY THIS MODULE INSTANTIATION TO BE THE APPROPRIATE PARAMETER VALUES FOR YOUR DESIGN

  SPI_TapeOutBlockRTL_32bits_5entries TapeOutBlock
  (
      .clk(clk_core),
      .reset(reset_core),
      .cs(cs_core),
      .miso(miso_core),
      .mosi(mosi_core),
      .sclk(sclk_core),
      .loopthrough_sel(loopthrough_sel_core),
      .minion_parity(minion_parity_core),
      .adapter_parity(adapter_parity_core)
  );

endmodule


