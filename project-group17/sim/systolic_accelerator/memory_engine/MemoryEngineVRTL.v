`ifndef MemoryEngineVRTL
`define MemoryEngineVRTL

`include "systolic_accelerator/memory_engine/MemoryEngine.v"
`include "systolic_accelerator/msg_structs/me_msg.v"

parameter DATA_ENTRIES = 128;

module systolic_accelerator_memory_engine_MemoryEngineVRTL
(
    input clk,
    input reset,

    output logic recv_rdy,
    input logic recv_val,
    input memory_engine_recv_msg  recv_msg,

    input logic send_rdy,
    output logic send_val,
    output memory_engine_send_msg  send_msg
);

MemoryEngine #(
    DATA_ENTRIES
) memoryEngine
(
    .clk        (clk     ),
    .reset      (reset   ),
    .recv_rdy   (recv_rdy),
    .recv_val   (recv_val),
    .recv_msg   (recv_msg),
    .send_rdy   (send_rdy),
    .send_val   (send_val),
    .send_msg   (send_msg)
);

endmodule

`endif