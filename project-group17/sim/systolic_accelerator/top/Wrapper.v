`ifndef TOP_WRAPPER_V
`define TOP_WRAPPER_V

`include "systolic_accelerator/memory_engine/MemoryEngine.v"
`include "systolic_accelerator/memory_engine/MemoryEngineLat.v"
`include "systolic_accelerator/systolic_mult/SystolicMult.v"
`include "systolic_accelerator/msg_structs/data_type.v"

module Wrapper #
(
    parameter DATA_ENTRIES,
    parameter DATA_LAT,

    parameter INT_WIDTH,
	parameter FRAC_WIDTH,
    parameter SYSTOLIC_SIZE,
    parameter SYSTOLIC_STEP_SIZE
)
(
    input clk,
    input reset,

    input logic send_rdy, // TODO, need halt
    output logic send_val,
    output [(INT_WIDTH+FRAC_WIDTH)*2-1:0] send_msg,

    input logic recv_val,
	output logic recv_rdy,
    input [INT_WIDTH+FRAC_WIDTH+4+3-1:0] recv_msg // share by 4
);
logic [(INT_WIDTH + FRAC_WIDTH)*4+3-1:0] systolic_mult_0_recv_msg;
logic [(INT_WIDTH + FRAC_WIDTH)*2-1:0] systolic_mult_0_send_msg;
logic systolic_mult_0_send_val;
logic systolic_mult_0_send_rdy;
logic systolic_mult_0_recv_val;
logic systolic_mult_0_recv_rdy;

logic [INT_WIDTH + FRAC_WIDTH+2-1:0] memory_engine_in_0_recv_msg;
logic [INT_WIDTH + FRAC_WIDTH+2-1:0] memory_engine_in_1_recv_msg;
logic [INT_WIDTH + FRAC_WIDTH+2-1:0] memory_engine_in_2_recv_msg;
logic [INT_WIDTH + FRAC_WIDTH+2-1:0] memory_engine_in_3_recv_msg;
logic [INT_WIDTH + FRAC_WIDTH-1:0] memory_engine_in_0_send_msg;
logic [INT_WIDTH + FRAC_WIDTH-1:0] memory_engine_in_1_send_msg;
logic [INT_WIDTH + FRAC_WIDTH-1:0] memory_engine_in_2_send_msg;
logic [INT_WIDTH + FRAC_WIDTH-1:0] memory_engine_in_3_send_msg;
logic memory_engine_in_0_send_val;
logic memory_engine_in_1_send_val;
logic memory_engine_in_2_send_val;
logic memory_engine_in_3_send_val;
logic memory_engine_in_0_send_rdy;
logic memory_engine_in_1_send_rdy;
logic memory_engine_in_2_send_rdy;
logic memory_engine_in_3_send_rdy;
logic memory_engine_in_0_recv_val;
logic memory_engine_in_1_recv_val;
logic memory_engine_in_2_recv_val;
logic memory_engine_in_3_recv_val;
logic memory_engine_in_0_recv_rdy;
logic memory_engine_in_1_recv_rdy;
logic memory_engine_in_2_recv_rdy;
logic memory_engine_in_3_recv_rdy;

logic [INT_WIDTH + FRAC_WIDTH+2-1:0] memory_engine_out_0_recv_msg;
logic [INT_WIDTH + FRAC_WIDTH-1:0] memory_engine_out_0_send_msg;
logic [INT_WIDTH + FRAC_WIDTH+2-1:0] memory_engine_out_1_recv_msg;
logic [INT_WIDTH + FRAC_WIDTH-1:0]  memory_engine_out_1_send_msg;
logic memory_engine_out_0_send_val;
logic memory_engine_out_1_send_val;
logic memory_engine_out_0_send_rdy;
logic memory_engine_out_1_send_rdy;
logic memory_engine_out_0_recv_val;
logic memory_engine_out_1_recv_val;
logic memory_engine_out_0_recv_rdy;
logic memory_engine_out_1_recv_rdy;

assign send_val = memory_engine_out_0_send_val && memory_engine_out_1_send_val;
assign recv_rdy = systolic_mult_0_recv_rdy&&memory_engine_in_3_recv_rdy;

assign send_msg[(INT_WIDTH+FRAC_WIDTH)*2-1:(INT_WIDTH+FRAC_WIDTH)*1] = memory_engine_out_0_send_msg;
assign send_msg[(INT_WIDTH+FRAC_WIDTH)*1-1:0] = memory_engine_out_1_send_msg;

assign memory_engine_in_0_recv_msg[INT_WIDTH+FRAC_WIDTH+2-1:2] = recv_msg[INT_WIDTH+FRAC_WIDTH+4+3-1:7];
assign memory_engine_in_0_recv_msg[1] = recv_msg[2];
assign memory_engine_in_0_recv_msg[0] = recv_msg[1];
// From left to right 
MemoryEngine #(
    .DATA_ENTRIES(DATA_ENTRIES)
) memoryEngine_a
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(recv_val&&recv_msg[3]&&recv_rdy),
    .recv_msg(memory_engine_in_0_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_0_send_msg)
);

assign memory_engine_in_1_recv_msg[INT_WIDTH+FRAC_WIDTH+2-1:2] = recv_msg[INT_WIDTH+FRAC_WIDTH+4+3-1:7];
assign memory_engine_in_1_recv_msg[1] = recv_msg[2];
assign memory_engine_in_1_recv_msg[0] = recv_msg[1];
MemoryEngineLat #(
    .DATA_ENTRIES(DATA_ENTRIES),
    .DATA_LAT(DATA_LAT)
) memoryEngineLat_a
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(recv_val&&recv_msg[4]&&recv_rdy),
    .recv_msg(memory_engine_in_1_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_1_send_msg)
);

// From top to bottom
assign memory_engine_in_2_recv_msg[INT_WIDTH+FRAC_WIDTH+2-1:2] = recv_msg[INT_WIDTH+FRAC_WIDTH+4+3-1:7];
assign memory_engine_in_2_recv_msg[1] = recv_msg[2];
assign memory_engine_in_2_recv_msg[0] = recv_msg[1];
MemoryEngine #(
    .DATA_ENTRIES(DATA_ENTRIES)
) memoryEngine_b
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(recv_val&&recv_msg[5]&&recv_rdy),
    .recv_msg(memory_engine_in_2_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_2_send_msg)
);

assign memory_engine_in_3_recv_msg[INT_WIDTH+FRAC_WIDTH+2-1:2] = recv_msg[INT_WIDTH+FRAC_WIDTH+4+3-1:7];
assign memory_engine_in_3_recv_msg[1] = recv_msg[2];
assign memory_engine_in_3_recv_msg[0] = recv_msg[1];
MemoryEngineLat #(
    .DATA_ENTRIES(DATA_ENTRIES),
    .DATA_LAT(DATA_LAT)
) memoryEngineLat_b
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(memory_engine_in_3_recv_rdy),
    .recv_val(recv_val&&recv_msg[6]&&recv_rdy),
    .recv_msg(memory_engine_in_3_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_3_send_msg)
);

// Systolic multiplication 
logic produce_run;
assign systolic_mult_0_recv_msg[(INT_WIDTH+FRAC_WIDTH)*4+3-1:(INT_WIDTH+FRAC_WIDTH)*3+3] = memory_engine_in_0_send_msg;
assign systolic_mult_0_recv_msg[(INT_WIDTH+FRAC_WIDTH)*3+3-1:(INT_WIDTH+FRAC_WIDTH)*2+3] = memory_engine_in_1_send_msg;
assign systolic_mult_0_recv_msg[(INT_WIDTH+FRAC_WIDTH)*2+3-1:(INT_WIDTH+FRAC_WIDTH)*1+3] = memory_engine_in_2_send_msg;
assign systolic_mult_0_recv_msg[(INT_WIDTH+FRAC_WIDTH)*1+3-1:(INT_WIDTH+FRAC_WIDTH)*0+3] = memory_engine_in_3_send_msg;
assign systolic_mult_0_recv_msg[2] = recv_msg[2];
assign systolic_mult_0_recv_msg[1] = recv_msg[1];
assign systolic_mult_0_recv_msg[0] = recv_msg[0];
SystolicMult #(
    .INT_WIDTH(INT_WIDTH),
	.FRAC_WIDTH(FRAC_WIDTH),
    .SYSTOLIC_SIZE(SYSTOLIC_SIZE),
    .SYSTOLIC_STEP_SIZE(SYSTOLIC_STEP_SIZE)
) systolicMult
(
    .reset(reset),
    .clk(clk),
    .recv_msg(systolic_mult_0_recv_msg),
    .recv_rdy(systolic_mult_0_recv_rdy),
    .recv_val(),

    .send_msg(systolic_mult_0_send_msg),
    .produce_run(produce_run),
    .send_val(systolic_mult_0_send_val),
    .send_rdy()

);

assign memory_engine_out_0_recv_msg[INT_WIDTH + FRAC_WIDTH+2-1:2] = systolic_mult_0_send_msg[(INT_WIDTH+FRAC_WIDTH)*2-1:(INT_WIDTH+FRAC_WIDTH)];
assign memory_engine_out_0_recv_msg[1] = produce_run;
assign memory_engine_out_0_recv_msg[0] = produce_run;
assign memory_engine_out_0_send_rdy = send_rdy;
MemoryEngine #(
    .DATA_ENTRIES(2)
) memoryEngineOut0
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(systolic_mult_0_send_val||produce_run),
    .recv_msg(memory_engine_out_0_recv_msg),
    .send_rdy(memory_engine_out_0_send_rdy),
    .send_val(memory_engine_out_0_send_val),
    .send_msg(memory_engine_out_0_send_msg)
);

assign memory_engine_out_1_recv_msg[INT_WIDTH + FRAC_WIDTH+2-1:2] = systolic_mult_0_send_msg[(INT_WIDTH+FRAC_WIDTH)*1-1:0];
assign memory_engine_out_1_recv_msg[1] = produce_run;
assign memory_engine_out_1_recv_msg[0] = produce_run;
assign memory_engine_out_1_send_rdy = send_rdy;
MemoryEngine #(
    .DATA_ENTRIES(2)
) memoryEngineOut1
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(systolic_mult_0_send_val||produce_run),
    .recv_msg(memory_engine_out_1_recv_msg),
    .send_rdy(memory_engine_out_1_send_rdy),
    .send_val(memory_engine_out_1_send_val),
    .send_msg(memory_engine_out_1_send_msg)
);

endmodule


`endif /* TOP_WRAPPER_V */
