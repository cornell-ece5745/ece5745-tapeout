// ==========================================================================
// PacketAssemblerVRTL.v
// ==========================================================================
// PacketAssembler with variable nbits_in and nbits_out. 
// Input: small packets of size nbits_in Output: one big packet of size nbits_out.
//
// The input bit length must be less than or equal to the output bit length.
// PacketAssembler with variable nbits_in and nbits_out. nbits_in <= nbits_out, and we bring data from the input into 
// separate registers (over multiple cycles), then concatenate the output of each register and send to the output of module.

module SPI_v3_components_PacketAssemblerVRTL
#(
    parameter nbits_in = 8,
    parameter nbits_out = 8,
    //Do not set parameters below this line. They are calculated using above parameters
    parameter num_regs = (nbits_out % nbits_in == 0) ? (nbits_out/nbits_in) : (nbits_out/nbits_in + 1)
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

  logic [num_regs-1:0][nbits_in-1:0] regs;
  logic [$clog2(num_regs):0]         counter; // the +1 is because we count up to num_regs e.g. if num_regs=2 then counter must go from 0->1->2
  logic [(nbits_in*num_regs)-1:0]    temp_out; // bigger than out, holds the concatenated reg[i].out values

  assign req_rdy  = counter != num_regs;
  assign resp_val = counter == num_regs;
  assign resp_msg = temp_out[nbits_out-1:0];


  always_ff @(posedge clk) begin
    if (reset | (resp_val & resp_rdy)) begin // if reset or you have sent the packet
      counter <= 0;
    end
    else if (resp_val & ~resp_rdy) begin // if response is valid but can't send yet
      counter <= counter;
    end
    else if (req_val & req_rdy) begin // if you receive another piece of the packet
      counter <= counter + 1;
    end
    else begin
      counter <= counter;
    end
  end

  genvar i;
  generate
    for (i=0; i<num_regs; i++) begin

      always_ff @(posedge clk) begin
        if (reset) begin
          regs[i] <= 0;
        end
        else if (counter == i) begin
          regs[i] <= req_msg;
        end
        else begin
          regs[i] <= regs[i];
        end
      end

      always_comb begin
        // Need to put the first req_msg into the upper bits of the output because we write the most-significant part of the packet first
        temp_out[(nbits_in*(num_regs-1-i) + nbits_in - 1) : (nbits_in*(num_regs-1-i))] = regs[i];
      end

    end
  endgenerate

endmodule