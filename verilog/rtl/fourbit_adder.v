// 4-bit adder test design
module fourbit_adder (
`ifdef USE_POWER_PINS
    inout vccd1, // User area 1 1.8V supply
    inout vssd1, // User area 1 digital ground
`endif
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] y,
    output [7:0] input_en,
    output [3:0] output_en,
    input clk
);
    reg y;
    always @(posedge clk) begin
        y <= a + b;
    end
    assign input_en = 8'hff;
    assign output_en = 4'b0;
endmodule