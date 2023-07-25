`ifndef MEMORYENGINELAT
`define MEMORYENGINELAT

`include "vc/trace.v"
`include "vc/regfiles.v"
`include "systolic_accelerator/msg_structs/data_type.v"

module MemoryEngineLat #(
    parameter DATA_ENTRIES,
    parameter DATA_LAT
)
(
    input clk,
    input reset,

    output logic recv_rdy,
    input logic recv_val,
    input [INT_WIDTH + FRAC_WIDTH+2-1:0] recv_msg,

    input logic send_rdy,
    output logic send_val,
    output [INT_WIDTH + FRAC_WIDTH-1:0] send_msg
);
logic [INT_WIDTH+FRAC_WIDTH-1 : 0] recv_msg_wrt_data;
logic recv_msg_run;
parameter MODE = 1;
parameter RUN = 0;
assign recv_msg_wrt_data = recv_msg[INT_WIDTH + FRAC_WIDTH+2-1:2];
assign recv_msg_run = recv_msg[1] && recv_msg[0] && recv_val;
logic [$clog2(DATA_ENTRIES)-1 : 0] wrt_addr;

logic stop_output;
logic lat_en;
logic counter_full;
logic counter_lat_finish;

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

logic [ INT_WIDTH+FRAC_WIDTH - 1: 0 ] data_temp;
assign send_msg = send_val ? data_temp : 'b0;

regfile_ReadRegfileLatDpath #(
    .DATA_WIDTH(INT_WIDTH+FRAC_WIDTH),
    .DATA_ENTRIES(DATA_ENTRIES),
    .DATA_LAT(DATA_LAT)
) dpath
(
    .clk(clk),
    .reset(reset),
    .wrt_en(recv_val&&~recv_msg[1]),
    .stop_output(stop_output),
    .send_rdy(send_rdy),
    .wrt_addr(wrt_addr),
    .wrt_data(recv_msg_wrt_data),
    .data(data_temp),
    .counter_full(counter_full),
    .counter_lat_finish(counter_lat_finish),
    .lat_en(lat_en)
);

read_regfileLat_Cpath #(
    .DATA_WIDTH(INT_WIDTH+FRAC_WIDTH),
    .DATA_ENTRIES(DATA_ENTRIES)
) cpath
(
    .clk(clk),
    .reset(reset),
    .run(recv_msg_run),
    .counter_full(counter_full),
    .stop_output(stop_output),
    .counter_lat_finish(counter_lat_finish),
    .lat_en(lat_en),
    .send_val(send_val),
    .recv_rdy(recv_rdy)
);

endmodule

module regfile_ReadRegfileLatDpath
#(
    parameter DATA_WIDTH,
    parameter DATA_ENTRIES,
    parameter DATA_LAT
)
(
    input logic clk,
    input logic reset,

    input logic wrt_en,
    input logic lat_en,
    input logic stop_output,
    input logic send_rdy,
    input logic [ $clog2(DATA_ENTRIES) - 1: 0 ] wrt_addr,
    input logic [ DATA_WIDTH - 1: 0 ] wrt_data,

    output logic [ DATA_WIDTH - 1: 0 ] data,
    output logic counter_full,
    output logic counter_lat_finish

);

    logic [$clog2(DATA_ENTRIES) - 1: 0] counter;
    logic [$clog2(DATA_ENTRIES) - 1: 0] counter_lat;

    vc_Regfile_1r1w #(.p_data_nbits(DATA_WIDTH),
                      .p_num_entries(DATA_ENTRIES)) regFile (
        .clk(clk),
        .reset(reset),
        .read_addr(counter),
        .read_data(data),
        .write_en(wrt_en),
        .write_addr(wrt_addr),
        .write_data(wrt_data)
    );

    assign counter_full = counter == DATA_ENTRIES-1;
    assign counter_lat_finish = counter_lat == DATA_LAT;

    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
            counter_lat <= 0;
        end
        else begin 
            if (send_rdy)
                counter <= stop_output ? 'b0 : counter + 1;
            else
                counter <= stop_output ? 'b0 : counter;
            counter_lat <= lat_en ? counter_lat + 1 : 'b0;
        end 
    end 

endmodule


module read_regfileLat_Cpath
#(
    parameter DATA_WIDTH,
    parameter DATA_ENTRIES
)
(
    input logic clk,
    input logic reset,

    input logic run,
    input logic counter_full,
    input logic counter_lat_finish,

    output logic lat_en,
    output logic stop_output,
    output logic send_val,
    output logic recv_rdy
);

    typedef enum
    {   STATE_WAIT,
        STATE_READ,
        STATE_LAT
    } states;

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
        lat_en = 'b0;
        send_val = 'b0;
        recv_rdy = 'b0;
        case ( state_reg )
            STATE_WAIT: 
            begin
                recv_rdy = 'b1;
                if (run) begin
                    state_next = STATE_LAT;
                end
            end

            STATE_LAT:
            begin
                lat_en = 'b1;
                if (counter_lat_finish) begin
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

`endif /*MEMORYENGINELAT*/