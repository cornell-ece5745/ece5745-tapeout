// ==========================================================================
// ArbitratorVRTL.v
// ==========================================================================
// This module is used to pick which component gets to output to the val/rdy SPI wrapper if multiple components can send a valid message.
// The arbitrator puts an address header on the outgoing packet so that downstream components can tell which component sent the response
// The nbits parameter is the length of the message.
// The num_inputs parameter is the number of input components that the Arbitrator is selecting from. MUST be >= 2

// Author : Dilan Lakhani
//   Date : Dec 19, 2021


module SPI_v3_components_ArbitratorVRTL
#(
  parameter nbits = 4,
  parameter num_inputs = 2,
  parameter addr_nbits = $clog2(num_inputs)
)
(
  input logic clk,
  input logic reset,

  // Receive Interface - need recv signals for each component connected to arbitrator
  input   logic                       recv_val [0:num_inputs-1],
  output  logic                       recv_rdy [0:num_inputs-1],
  input   logic [nbits-1:0]           recv_msg [0:num_inputs-1],

  // Send Interface
  output logic                        send_val,
  input  logic                        send_rdy,
  output logic [addr_nbits+nbits-1:0] send_msg
);

  logic [addr_nbits-1:0] grants_index; // which input is granted access to send to SPI
  logic [addr_nbits-1:0] old_grants_index;
  logic [addr_nbits-1:0] encoder_out;
  logic [nbits-1:0]      send_msg_data;
  logic [addr_nbits-1:0] send_msg_addr;

  assign send_msg_data = recv_msg[grants_index];
  assign send_msg_addr = grants_index;
  assign send_val = recv_val[grants_index] & recv_rdy[grants_index];
  assign send_msg = {send_msg_addr, send_msg_data}; // append component address to the beginning of the message
    
  always_comb begin
    // change grants_index if the last cycle's grant index is 0 (that component has finished sending its message)
    if (!recv_val[old_grants_index]) begin
      grants_index = encoder_out;
    end else begin
      grants_index = grants_index;
    end
  end

  always_comb begin
    for (integer j=0; j<num_inputs;j++) begin
      // Only tell one input that the arbitrator is ready for it
      if(grants_index == j) begin
        recv_rdy[j] = send_rdy;
      end else begin
        recv_rdy[j] = 1'b0;
      end
    end
  end
      
  always_comb begin
    // priority encoder that gives highest priority to the LSB and lowest to MSB
    encoder_out = 0;
    for(integer i=0; i<num_inputs; i++) begin
      if (recv_val[num_inputs-1-i]) begin
        encoder_out = num_inputs-1-i;
      end
    end
  end

  // One issue arises with having multiple Disassemblers. Since the SPI width is normally less than the size of a response,
  // a PacketDisassembler component needs multiple cycles to fully send a message to the arbitrator. Thus, we do not want to 
  // change which Disassembler is allowed to send to the Arbitrator in the middle of a message.
  // Fix this by holding a trailing value of the grants_index.
  // We need to be able to check the recv_val of the old grants_index to make sure that it is not 1, then we can allow a different
  // Disassembler to send a message
  always_ff @(posedge clk) begin
    if (reset) begin
      old_grants_index <= 0;
    end
    else begin
      old_grants_index <= grants_index;
    end
  end

endmodule


