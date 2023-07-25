// ==========================================================================
// PacketDisassemblerVRTL.py
// ==========================================================================
// PacketDisassembler with variable nbits_in and nbits_out. 
// Input: one big packet of size nbits_in Output: small packets of size nbits_out.
//
// The input bit length must be greater than the output bit length.
// PacketDisassembler with variable nbits_in and nbits_out. nbits_in > nbits_out, and we bring data from the input into 
// separate registers (in one cycle), then send one register's output to the module's output per cycle.
// Eg: 16 bit input packet, we want 8 bit output packets.
//     Input is 0xABCD. 0xAB will go into reg[1] and 0xCD will go into reg[0].
//     Next cycle the Disassembler will output 0xAB. The cycle after that 0xCD will be outputted

`include "vc/muxes.v" 

module SPI_v3_components_PacketDisassemblerVRTL
#(
  parameter nbits_in = 8,
  parameter nbits_out = 8,
  //Do not set parameters below this line. They are calculated using above parameters
  parameter num_regs = ((nbits_in % nbits_out) == 0) ? (nbits_in/nbits_out) : (nbits_in/nbits_out + 1),
  parameter reg_bits = $clog2(num_regs)
)(
  input  logic                  clk,
  input  logic                  reset,
                                 
  input  logic                  req_val,
  output logic                  req_rdy,
  input  logic [nbits_in-1:0]   req_msg,
                                 
  output logic                  resp_val,
  input  logic                  resp_rdy,
  output logic [nbits_out-1:0]  resp_msg
);

  logic [num_regs-1:0][nbits_out-1:0] regs;
  logic [$clog2(num_regs):0]          counter; // the +1 is because we count up to num_regs e.g. if num_regs=2 then counter must go from 0->1->2
  logic                               transaction_val;

  // // Mux
  logic [num_regs-1:0][nbits_out-1:0] reg_mux_in_;
  logic [reg_bits-1:0]                reg_mux_sel;
  logic [nbits_out-1:0]               reg_mux_out;

  vc_MuxN #(nbits_out, num_regs) reg_mux ( // muxes each part of the input packet to the output
    .in(reg_mux_in_),
    .sel(reg_mux_sel),
    .out(reg_mux_out)
  );

  // Assigns
  assign req_rdy   = ~transaction_val;
  assign resp_val  = transaction_val;

  // Counter Update Logic
  always_ff @(posedge clk) begin
    if (reset | ((counter == (num_regs-1)) & resp_rdy)) begin // if reset or you have sent the last packet
      counter <= 0;
    end
    else if (resp_val & resp_rdy) begin // if we send a packet
      counter <= counter + 1;
    end
    else begin
      counter <= counter;
    end
  end

  // Transaction Val Logic
  always_ff @(posedge clk) begin
    if (reset) begin
      transaction_val <= 0;
    end
    else if ((req_val & req_rdy) | ((counter == (num_regs-1)) & resp_rdy)) begin // if there is an input packet or you have sent the last output packet
      transaction_val <= req_val & req_rdy; // set transaction val to 1 if it is an input packet
    end
    else begin
      transaction_val <= transaction_val;
    end
  end
  
  genvar i;
  generate 
    for (i=0; i < num_regs; i++) begin

      // Sequential Reg Update Logic
      if (i == (num_regs - 1)) begin // this is the top register
        localparam zext_len = 0 ? (nbits_in%nbits_out == 0) : (nbits_out - (nbits_in - (nbits_out*num_regs-nbits_out) )); // value to zero extend to result in an nbits_out long vector;
        always_ff @(posedge clk) begin
          if (req_val & req_rdy) begin
            regs[i] <= { {zext_len{1'b0}} , req_msg[ nbits_in-1 : (nbits_out*num_regs-nbits_out) ] }; // holds MSb, zext to fit register size 
          end
        end
      end 
      else begin // not top register
        always_ff @(posedge clk) begin
          if (req_val & req_rdy) begin
            regs[i] <= req_msg[ (nbits_out*i + nbits_out -1) : (nbits_out*(i)) ];
          end
        end 
      end

      // Mux and Output Logic
      always_comb begin
        reg_mux_in_[i] = regs[i];
        reg_mux_sel = num_regs - counter - 1; //value truncated to reg_bits
        resp_msg = reg_mux_out;
      end
    end
  endgenerate

endmodule

