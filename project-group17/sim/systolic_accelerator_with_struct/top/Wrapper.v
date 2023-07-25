`ifndef TOP_WRAPPER_V
`define TOP_WRAPPER_V

`include "systolic_accelerator/memory_engine/MemoryEngine.v"
`include "systolic_accelerator/memory_engine/MemoryEngineLat.v"
`include "systolic_accelerator/systolic_mult/SystolicMult.v"
`include "systolic_accelerator/msg_structs/systolic_msgs.v"
`include "systolic_accelerator/msg_structs/me_msg.v"
`include "systolic_accelerator/msg_structs/wrapper_msg.v"

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
    output wrapper_send_msg send_msg,

    input logic recv_val,
	output logic recv_rdy,
    input wrapper_recv_msg recv_msg // share by 4
);
systolic_mult_recv_msg systolic_mult_0_recv_msg;
systolic_mult_send_msg systolic_mult_0_send_msg;
logic systolic_mult_0_send_val;
logic systolic_mult_0_send_rdy;
logic systolic_mult_0_recv_val;
logic systolic_mult_0_recv_rdy;

memory_engine_recv_msg memory_engine_in_0_recv_msg;
memory_engine_recv_msg memory_engine_in_1_recv_msg;
memory_engine_recv_msg memory_engine_in_2_recv_msg;
memory_engine_recv_msg memory_engine_in_3_recv_msg;
memory_engine_send_msg memory_engine_in_0_send_msg;
memory_engine_send_msg memory_engine_in_1_send_msg;
memory_engine_send_msg memory_engine_in_2_send_msg;
memory_engine_send_msg memory_engine_in_3_send_msg;
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

memory_engine_recv_msg memory_engine_out_0_recv_msg;
memory_engine_send_msg memory_engine_out_0_send_msg;
memory_engine_recv_msg memory_engine_out_1_recv_msg;
memory_engine_send_msg memory_engine_out_1_send_msg;
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

assign send_msg.result_0 = memory_engine_out_0_send_msg.data;
assign send_msg.result_1 = memory_engine_out_1_send_msg.data;

assign memory_engine_in_0_recv_msg.data = recv_msg.data;
assign memory_engine_in_0_recv_msg.mode = recv_msg.mode;
assign memory_engine_in_0_recv_msg.run = recv_msg.run;
// From left to right 
MemoryEngine #(
    .DATA_ENTRIES(DATA_ENTRIES)
) memoryEngine_a
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(recv_val&&recv_msg.chip_select[0]&&recv_rdy),
    .recv_msg(memory_engine_in_0_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_0_send_msg)
);

assign memory_engine_in_1_recv_msg.data = recv_msg.data;
assign memory_engine_in_1_recv_msg.mode = recv_msg.mode;
assign memory_engine_in_1_recv_msg.run = recv_msg.run;
MemoryEngineLat #(
    .DATA_ENTRIES(DATA_ENTRIES),
    .DATA_LAT(DATA_LAT)
) memoryEngineLat_a
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(recv_val&&recv_msg.chip_select[1]&&recv_rdy),
    .recv_msg(memory_engine_in_1_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_1_send_msg)
);

// From top to bottom
assign memory_engine_in_2_recv_msg.data = recv_msg.data;
assign memory_engine_in_2_recv_msg.mode = recv_msg.mode;
assign memory_engine_in_2_recv_msg.run = recv_msg.run;
MemoryEngine #(
    .DATA_ENTRIES(DATA_ENTRIES)
) memoryEngine_b
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(),
    .recv_val(recv_val&&recv_msg.chip_select[2]&&recv_rdy),
    .recv_msg(memory_engine_in_2_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_2_send_msg)
);

assign memory_engine_in_3_recv_msg.data = recv_msg.data;
assign memory_engine_in_3_recv_msg.mode = recv_msg.mode;
assign memory_engine_in_3_recv_msg.run = recv_msg.run;
MemoryEngineLat #(
    .DATA_ENTRIES(DATA_ENTRIES),
    .DATA_LAT(DATA_LAT)
) memoryEngineLat_b
(
    .clk(clk),
    .reset(reset),
    .recv_rdy(memory_engine_in_3_recv_rdy),
    .recv_val(recv_val&&recv_msg.chip_select[3]&&recv_rdy),
    .recv_msg(memory_engine_in_3_recv_msg),
    .send_rdy(1'b1),
    .send_val(),
    .send_msg(memory_engine_in_3_send_msg)
);

// Systolic multiplication 
logic produce_run;
assign systolic_mult_0_recv_msg.weight_0 = memory_engine_in_0_send_msg.data;
assign systolic_mult_0_recv_msg.weight_1 = memory_engine_in_1_send_msg.data;
assign systolic_mult_0_recv_msg.data_0 = memory_engine_in_2_send_msg.data;
assign systolic_mult_0_recv_msg.data_1 = memory_engine_in_3_send_msg.data;
assign systolic_mult_0_recv_msg.mode = recv_msg.mode;
assign systolic_mult_0_recv_msg.run = recv_msg.run;
assign systolic_mult_0_recv_msg.final_run = recv_msg.final_run;
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

assign memory_engine_out_0_recv_msg.data = systolic_mult_0_send_msg.result_0;
assign memory_engine_out_0_recv_msg.mode = produce_run;
assign memory_engine_out_0_recv_msg.run = produce_run;
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

assign memory_engine_out_1_recv_msg.data = systolic_mult_0_send_msg.result_1;
assign memory_engine_out_1_recv_msg.mode = produce_run;
assign memory_engine_out_1_recv_msg.run = produce_run;
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
