`ifndef MEMORYENGINE
`define MEMORYENGINE

`include "vc/trace.v"
`include "vc/regfiles.v"
`include "systolic_accelerator/msg_structs/me_msg.v"

module MemoryEngine #(
    parameter DATA_ENTRIES
)
(
    input clk,
    input reset,

    output logic recv_rdy,
    input logic recv_val,
    input memory_engine_recv_msg recv_msg,

    input logic send_rdy,
    output logic send_val,
    output memory_engine_send_msg send_msg
);
logic [INT_WIDTH + FRAC_WIDTH - 1:0] recv_msg_wrt_data;
logic recv_msg_run;
parameter MODE = 1;
parameter RUN = 0;
assign recv_msg_wrt_data = recv_msg.data;
assign recv_msg_run = recv_msg.mode && recv_msg.run && recv_val;
logic [$clog2(DATA_ENTRIES)-1 : 0] wrt_addr;
always@(posedge clk) begin
    if (reset) begin
        wrt_addr <= 'b0;
    end
    else if (recv_val && recv_rdy) begin
        if (recv_msg_run)
            wrt_addr <= 'b0;
        else
            wrt_addr <= wrt_addr + 1;
    end
    else
        wrt_addr <= wrt_addr;
end

logic stop_output;
logic counter_full;
logic [ INT_WIDTH + FRAC_WIDTH - 1: 0 ] data_temp;
logic send_val_temp;
assign send_msg.data = send_val ? data_temp : 'b0;
assign send_val = ~counter_full && send_val_temp;
regfile_ReadRegfileDpath #(
    .DATA_WIDTH(INT_WIDTH + FRAC_WIDTH),
    .DATA_ENTRIES(DATA_ENTRIES)
) dpath
(
    .clk(clk),
    .reset(reset),
    .wrt_en(recv_val&&~recv_msg.mode),
    .stop_output(stop_output),
    .send_rdy(send_rdy),
    .wrt_addr(wrt_addr),
    .wrt_data(recv_msg_wrt_data),
    .data(data_temp),
    .counter_full(counter_full)
);

read_regfile_Cpath #(
    .DATA_WIDTH(INT_WIDTH + FRAC_WIDTH),
    .DATA_ENTRIES(DATA_ENTRIES)
) cpath
(
    .clk(clk),
    .reset(reset),
    .run(recv_msg_run),
    .counter_full(counter_full),
    .stop_output(stop_output),
    .send_val(send_val_temp),
    .recv_rdy(recv_rdy)
);

endmodule;

module regfile_ReadRegfileDpath
#(
    parameter DATA_WIDTH,
    parameter DATA_ENTRIES
)
(
    input logic clk,
    input logic reset,

    input logic wrt_en,
    input logic stop_output,
    input logic send_rdy,
    input logic [ $clog2(DATA_ENTRIES) - 1: 0 ] wrt_addr,
    input logic [ DATA_WIDTH - 1: 0 ] wrt_data,

    output logic [ DATA_WIDTH - 1: 0 ] data,
    output logic counter_full

);
    logic [$clog2(DATA_ENTRIES) : 0] counter;

    vc_Regfile_1r1w #(.p_data_nbits(DATA_WIDTH),
                      .p_num_entries(DATA_ENTRIES)) regFile (
        .clk(clk),
        .reset(reset),
        .read_addr(counter[$clog2(DATA_ENTRIES)-1 : 0]),
        .read_data(data),
        .write_en(wrt_en),
        .write_addr(wrt_addr),
        .write_data(wrt_data)
    );

    assign counter_full = counter == DATA_ENTRIES;

    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
        end
        else begin
            if (send_rdy)
                counter <= stop_output ? 'b0 : counter + 1;
            else
                counter <= stop_output ? 'b0 : counter;
        end 
    end 

endmodule


module read_regfile_Cpath
#(
    parameter DATA_WIDTH,
    parameter DATA_ENTRIES
)
(
    input logic clk,
    input logic reset,

    input logic run,
    input logic counter_full,
    output logic stop_output,
    output logic send_val,
    output logic recv_rdy
);
    typedef enum
    {   STATE_WAIT,
        STATE_READ  } states;

    states state_reg;
    states state_next;

    always @(posedge clk) begin
        if (reset)
            state_reg <= STATE_WAIT;
        else begin
            state_reg <= state_next;
        end
    end 

    always @(*) begin
        state_next = state_reg;
        stop_output = 'b1;
        send_val = 'b0;
        recv_rdy = 'b0;
        case ( state_reg )
            STATE_WAIT: 
            begin
                recv_rdy = 1'b1;
                if (run) begin
                    state_next = STATE_READ;
                end
            end
            STATE_READ:
            begin
                send_val = 'b1;
                if (counter_full) begin
                    state_next = STATE_WAIT;
                end
                else begin
                    stop_output = 'b0;
                end
            end 
            default: state_next = STATE_WAIT;
        endcase 
    end 

endmodule

`endif /*MEMORYENGINE*/