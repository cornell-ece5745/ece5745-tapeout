/*
==========================================================================
RouterVRTL.v
==========================================================================
Router module that receives an input of size nbits from the SPIPushPull2ValRdyAdapter and reads the address bits
to find out which output component to send the packet to. Then it strips off the address bits and sends the data
bits to the corret output component. The router reads the address bits in the input packet (the highest order bits) 
and sends data to correct output. Output components must be connected according to a known scheme so that you know
which output component the router will send the data to, given the address.

Author : Dilan Lakhani
  Date : Jan 17, 2022
*/

module SPI_v3_components_RouterVRTL
#(
  parameter nbits = 4,
  parameter num_outputs = 2,
  parameter addr_nbits = $clog2(num_outputs) < 1 ? 1 : $clog2(num_outputs) 
)(
  input  logic                        clk,
  input  logic                        reset,
  input  logic [addr_nbits+nbits-1:0] recv_msg,
  output logic                        recv_rdy,  
  input  logic                        recv_val,  
  output logic [nbits-1:0]            send_msg [0:num_outputs-1],
  input  logic                        send_rdy [0:num_outputs-1],
  output logic                        send_val [0:num_outputs-1] 
);
  logic [addr_nbits-1:0] addressed_output;

  assign recv_rdy = recv_val & send_rdy[addressed_output];
  
  always_comb begin
    for ( integer i = 0; i < num_outputs; i++ ) begin
      if ( addressed_output == i ) begin
        send_val[i] = recv_val & recv_rdy;
      end else begin
        send_val[i] = 1'd0;
      end
    end

    for ( integer i = 0; i < num_outputs; i++ ) begin
      send_msg[i] = recv_msg[nbits-1:0];
    end
  end

  assign addressed_output = recv_msg[addr_nbits+nbits-1:nbits];

endmodule
