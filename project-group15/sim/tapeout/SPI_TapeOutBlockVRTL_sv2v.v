module SPI_v3_components_LoopThroughVRTL (
	clk,
	reset,
	sel,
	upstream_req_val,
	upstream_req_msg,
	upstream_req_rdy,
	upstream_resp_val,
	upstream_resp_msg,
	upstream_resp_rdy,
	downstream_req_val,
	downstream_req_msg,
	downstream_req_rdy,
	downstream_resp_val,
	downstream_resp_msg,
	downstream_resp_rdy
);
	parameter nbits = 32;
	input wire clk;
	input wire reset;
	input wire sel;
	input wire upstream_req_val;
	input wire [nbits - 1:0] upstream_req_msg;
	output wire upstream_req_rdy;
	output wire upstream_resp_val;
	output wire [nbits - 1:0] upstream_resp_msg;
	input wire upstream_resp_rdy;
	output wire downstream_req_val;
	output wire [nbits - 1:0] downstream_req_msg;
	input wire downstream_req_rdy;
	input wire downstream_resp_val;
	input wire [nbits - 1:0] downstream_resp_msg;
	output wire downstream_resp_rdy;
	assign upstream_resp_val = (sel ? upstream_req_val : downstream_resp_val);
	assign upstream_resp_msg = (sel ? upstream_req_msg : downstream_resp_msg);
	assign downstream_req_val = (sel ? 0 : upstream_req_val);
	assign downstream_req_msg = upstream_req_msg;
	assign upstream_req_rdy = (sel ? upstream_resp_rdy : downstream_req_rdy);
	assign downstream_resp_rdy = (sel ? 0 : upstream_resp_rdy);
endmodule
module ShiftReg (
	clk,
	in_,
	load_data,
	load_en,
	out,
	reset,
	shift_en
);
	parameter nbits = 8;
	input wire clk;
	input wire in_;
	input wire [nbits - 1:0] load_data;
	input wire load_en;
	output reg [nbits - 1:0] out;
	input wire reset;
	input wire shift_en;
	always @(posedge clk)
		if (reset)
			out <= {nbits {1'b0}};
		else if (load_en)
			out <= load_data;
		else if (~load_en & shift_en)
			out <= {out[nbits - 2:0], in_};
endmodule
module Synchronizer (
	clk,
	in_,
	negedge_,
	out,
	posedge_,
	reset
);
	parameter reset_value = 1'b0;
	input wire clk;
	input wire in_;
	output reg negedge_;
	output wire out;
	output reg posedge_;
	input wire reset;
	reg [2:0] shreg;
	always @(*) begin
		negedge_ = shreg[2] & ~shreg[1];
		posedge_ = ~shreg[2] & shreg[1];
	end
	always @(posedge clk)
		if (reset)
			shreg <= {3 {reset_value}};
		else
			shreg <= {shreg[1:0], in_};
	assign out = shreg[1];
endmodule
module SPI_v3_components_SPIMinionVRTL (
	clk,
	cs,
	miso,
	mosi,
	reset,
	sclk,
	pull_en,
	pull_msg,
	push_en,
	push_msg,
	parity
);
	parameter nbits = 8;
	input wire clk;
	input wire cs;
	output wire miso;
	input wire mosi;
	input wire reset;
	input wire sclk;
	output wire pull_en;
	input wire [nbits - 1:0] pull_msg;
	output wire push_en;
	output wire [nbits - 1:0] push_msg;
	output wire parity;
	wire cs_sync_clk;
	wire cs_sync_in_;
	wire cs_sync_negedge_;
	wire cs_sync_out;
	wire cs_sync_posedge_;
	wire cs_sync_reset;
	Synchronizer #(.reset_value(1'b1)) cs_sync(
		.clk(cs_sync_clk),
		.in_(cs_sync_in_),
		.negedge_(cs_sync_negedge_),
		.out(cs_sync_out),
		.posedge_(cs_sync_posedge_),
		.reset(cs_sync_reset)
	);
	wire mosi_sync_clk;
	wire mosi_sync_in_;
	wire mosi_sync_negedge_;
	wire mosi_sync_out;
	wire mosi_sync_posedge_;
	wire mosi_sync_reset;
	Synchronizer #(.reset_value(1'b0)) mosi_sync(
		.clk(mosi_sync_clk),
		.in_(mosi_sync_in_),
		.negedge_(mosi_sync_negedge_),
		.out(mosi_sync_out),
		.posedge_(mosi_sync_posedge_),
		.reset(mosi_sync_reset)
	);
	wire sclk_sync_clk;
	wire sclk_sync_in_;
	wire sclk_sync_negedge_;
	wire sclk_sync_out;
	wire sclk_sync_posedge_;
	wire sclk_sync_reset;
	Synchronizer #(.reset_value(1'b0)) sclk_sync(
		.clk(sclk_sync_clk),
		.in_(sclk_sync_in_),
		.negedge_(sclk_sync_negedge_),
		.out(sclk_sync_out),
		.posedge_(sclk_sync_posedge_),
		.reset(sclk_sync_reset)
	);
	wire shreg_in_clk;
	wire shreg_in_in_;
	wire [nbits - 1:0] shreg_in_load_data;
	wire shreg_in_load_en;
	wire [nbits - 1:0] shreg_in_out;
	wire shreg_in_reset;
	reg shreg_in_shift_en;
	ShiftReg #(.nbits(nbits)) shreg_in(
		.clk(shreg_in_clk),
		.in_(shreg_in_in_),
		.load_data(shreg_in_load_data),
		.load_en(shreg_in_load_en),
		.out(shreg_in_out),
		.reset(shreg_in_reset),
		.shift_en(shreg_in_shift_en)
	);
	wire shreg_out_clk;
	wire shreg_out_in_;
	wire [nbits - 1:0] shreg_out_load_data;
	wire shreg_out_load_en;
	wire [nbits - 1:0] shreg_out_out;
	wire shreg_out_reset;
	reg shreg_out_shift_en;
	ShiftReg #(.nbits(nbits)) shreg_out(
		.clk(shreg_out_clk),
		.in_(shreg_out_in_),
		.load_data(shreg_out_load_data),
		.load_en(shreg_out_load_en),
		.out(shreg_out_out),
		.reset(shreg_out_reset),
		.shift_en(shreg_out_shift_en)
	);
	always @(*) begin
		shreg_in_shift_en = ~cs_sync_out & sclk_sync_posedge_;
		shreg_out_shift_en = ~cs_sync_out & sclk_sync_negedge_;
	end
	assign cs_sync_clk = clk;
	assign cs_sync_reset = reset;
	assign cs_sync_in_ = cs;
	assign sclk_sync_clk = clk;
	assign sclk_sync_reset = reset;
	assign sclk_sync_in_ = sclk;
	assign mosi_sync_clk = clk;
	assign mosi_sync_reset = reset;
	assign mosi_sync_in_ = mosi;
	assign shreg_in_clk = clk;
	assign shreg_in_reset = reset;
	assign shreg_in_in_ = mosi_sync_out;
	assign shreg_in_load_en = 1'b0;
	assign shreg_in_load_data = {nbits {1'b0}};
	assign shreg_out_clk = clk;
	assign shreg_out_reset = reset;
	assign shreg_out_in_ = 1'b0;
	assign shreg_out_load_en = pull_en;
	assign shreg_out_load_data = pull_msg;
	assign miso = shreg_out_out[nbits - 1];
	assign pull_en = cs_sync_negedge_;
	assign push_en = cs_sync_posedge_;
	assign push_msg = shreg_in_out;
	assign parity = ^push_msg[nbits - 3:0] & push_en;
endmodule
module vc_Reg (
	clk,
	q,
	d
);
	parameter p_nbits = 1;
	input wire clk;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	always @(posedge clk) q <= d;
endmodule
module vc_ResetReg (
	clk,
	reset,
	q,
	d
);
	parameter p_nbits = 1;
	parameter p_reset_value = 0;
	input wire clk;
	input wire reset;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	always @(posedge clk) q <= (reset ? p_reset_value : d);
endmodule
module vc_EnReg (
	clk,
	reset,
	q,
	d,
	en
);
	parameter p_nbits = 1;
	input wire clk;
	input wire reset;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	input wire en;
	always @(posedge clk)
		if (en)
			q <= d;
endmodule
module vc_EnResetReg (
	clk,
	reset,
	q,
	d,
	en
);
	parameter p_nbits = 1;
	parameter p_reset_value = 0;
	input wire clk;
	input wire reset;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	input wire en;
	always @(posedge clk)
		if (reset || en)
			q <= (reset ? p_reset_value : d);
endmodule
module vc_Mux2 (
	in0,
	in1,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			1'd0: out = in0;
			1'd1: out = in1;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux3 (
	in0,
	in1,
	in2,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [1:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			2'd0: out = in0;
			2'd1: out = in1;
			2'd2: out = in2;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux4 (
	in0,
	in1,
	in2,
	in3,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [1:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			2'd0: out = in0;
			2'd1: out = in1;
			2'd2: out = in2;
			2'd3: out = in3;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux5 (
	in0,
	in1,
	in2,
	in3,
	in4,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux6 (
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [p_nbits - 1:0] in5;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			3'd5: out = in5;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux7 (
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [p_nbits - 1:0] in5;
	input wire [p_nbits - 1:0] in6;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			3'd5: out = in5;
			3'd6: out = in6;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux8 (
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [p_nbits - 1:0] in5;
	input wire [p_nbits - 1:0] in6;
	input wire [p_nbits - 1:0] in7;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			3'd5: out = in5;
			3'd6: out = in6;
			3'd7: out = in7;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_MuxN (
	in,
	sel,
	out
);
	parameter p_nbits = 1;
	parameter p_ninputs = 2;
	input wire [(p_ninputs * p_nbits) - 1:0] in;
	input wire [$clog2(p_ninputs) - 1:0] sel;
	output wire [p_nbits - 1:0] out;
	assign out = in[sel * p_nbits+:p_nbits];
endmodule
module vc_Regfile_1r1w (
	clk,
	reset,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr;
	output wire [p_data_nbits - 1:0] read_data;
	input wire write_en;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [p_data_nbits - 1:0] write_data;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data = rfile[read_addr];
	always @(posedge clk)
		if (write_en)
			rfile[write_addr] <= write_data;
endmodule
module vc_ResetRegfile_1r1w (
	clk,
	reset,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter p_reset_value = 0;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr;
	output wire [p_data_nbits - 1:0] read_data;
	input wire write_en;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [p_data_nbits - 1:0] write_data;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data = rfile[read_addr];
	genvar i;
	generate
		for (i = 0; i < p_num_entries; i = i + 1) begin : wport
			always @(posedge clk)
				if (reset)
					rfile[i] <= p_reset_value;
				else if (write_en && (i[c_addr_nbits - 1:0] == write_addr))
					rfile[i] <= write_data;
		end
	endgenerate
endmodule
module vc_Regfile_2r1w (
	clk,
	reset,
	read_addr0,
	read_data0,
	read_addr1,
	read_data1,
	write_en,
	write_addr,
	write_data
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr0;
	output wire [p_data_nbits - 1:0] read_data0;
	input wire [c_addr_nbits - 1:0] read_addr1;
	output wire [p_data_nbits - 1:0] read_data1;
	input wire write_en;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [p_data_nbits - 1:0] write_data;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data0 = rfile[read_addr0];
	assign read_data1 = rfile[read_addr1];
	always @(posedge clk)
		if (write_en)
			rfile[write_addr] <= write_data;
endmodule
module vc_Regfile_2r2w (
	clk,
	reset,
	read_addr0,
	read_data0,
	read_addr1,
	read_data1,
	write_en0,
	write_addr0,
	write_data0,
	write_en1,
	write_addr1,
	write_data1
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr0;
	output wire [p_data_nbits - 1:0] read_data0;
	input wire [c_addr_nbits - 1:0] read_addr1;
	output wire [p_data_nbits - 1:0] read_data1;
	input wire write_en0;
	input wire [c_addr_nbits - 1:0] write_addr0;
	input wire [p_data_nbits - 1:0] write_data0;
	input wire write_en1;
	input wire [c_addr_nbits - 1:0] write_addr1;
	input wire [p_data_nbits - 1:0] write_data1;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data0 = rfile[read_addr0];
	assign read_data1 = rfile[read_addr1];
	always @(posedge clk) begin
		if (write_en0)
			rfile[write_addr0] <= write_data0;
		if (write_en1)
			rfile[write_addr1] <= write_data1;
	end
endmodule
module vc_Regfile_2r1w_zero (
	clk,
	reset,
	rd_addr0,
	rd_data0,
	rd_addr1,
	rd_data1,
	wr_en,
	wr_addr,
	wr_data
);
	input wire clk;
	input wire reset;
	input wire [4:0] rd_addr0;
	output wire [31:0] rd_data0;
	input wire [4:0] rd_addr1;
	output wire [31:0] rd_data1;
	input wire wr_en;
	input wire [4:0] wr_addr;
	input wire [31:0] wr_data;
	wire [31:0] rf_read_data0;
	wire [31:0] rf_read_data1;
	vc_Regfile_2r1w #(
		.p_data_nbits(32),
		.p_num_entries(32)
	) rfile(
		.clk(clk),
		.reset(reset),
		.read_addr0(rd_addr0),
		.read_data0(rf_read_data0),
		.read_addr1(rd_addr1),
		.read_data1(rf_read_data1),
		.write_en(wr_en),
		.write_addr(wr_addr),
		.write_data(wr_data)
	);
	assign rd_data0 = (rd_addr0 == 5'd0 ? 32'd0 : rf_read_data0);
	assign rd_data1 = (rd_addr1 == 5'd0 ? 32'd0 : rf_read_data1);
endmodule
module vc_Trace (
	clk,
	reset
);
	input wire clk;
	input wire reset;
	integer len0;
	integer len1;
	integer idx0;
	integer idx1;
	localparam nchars = 512;
	localparam nbits = 4096;
	wire [4095:0] storage;
	integer cycles_next = 0;
	integer cycles = 0;
	reg [3:0] level;
	initial if (!$value$plusargs("trace=%d", level))
		level = 0;
	always @(posedge clk) cycles <= (reset ? 0 : cycles_next);
	task append_str;
		output reg [4095:0] trace;
		input reg [4095:0] str;
		begin
			len0 = 1;
			while (str[len0 * 8+:8] != 0) len0 = len0 + 1;
			idx0 = trace[31:0];
			for (idx1 = len0 - 1; idx1 >= 0; idx1 = idx1 - 1)
				begin
					trace[idx0 * 8+:8] = str[idx1 * 8+:8];
					idx0 = idx0 - 1;
				end
			trace[31:0] = idx0;
		end
	endtask
	task append_str_ljust;
		output reg [4095:0] trace;
		input reg [4095:0] str;
		begin
			idx0 = trace[31:0];
			idx1 = nchars;
			while (str[(idx1 * 8) - 1-:8] != 0) begin
				trace[idx0 * 8+:8] = str[(idx1 * 8) - 1-:8];
				idx0 = idx0 - 1;
				idx1 = idx1 - 1;
			end
			trace[31:0] = idx0;
		end
	endtask
	task append_chars;
		output reg [4095:0] trace;
		input reg [7:0] char;
		input integer num;
		begin
			idx0 = trace[31:0];
			for (idx1 = 0; idx1 < num; idx1 = idx1 + 1)
				begin
					trace[idx0 * 8+:8] = char;
					idx0 = idx0 - 1;
				end
			trace[31:0] = idx0;
		end
	endtask
	task append_val_str;
		output reg [4095:0] trace;
		input reg val;
		input reg [4095:0] str;
		begin
			len1 = 0;
			while (str[len1 * 8+:8] != 0) len1 = len1 + 1;
			if (val)
				append_str(trace, str);
			else if (!val)
				append_chars(trace, " ", len1);
			else begin
				append_str(trace, "x");
				append_chars(trace, " ", len1 - 1);
			end
		end
	endtask
	task append_val_rdy_str;
		output reg [4095:0] trace;
		input reg val;
		input reg rdy;
		input reg [4095:0] str;
		begin
			len1 = 0;
			while (str[len1 * 8+:8] != 0) len1 = len1 + 1;
			if (val & rdy)
				append_str(trace, str);
			else if (rdy && !val)
				append_chars(trace, " ", len1);
			else if (!rdy && !val) begin
				append_str(trace, ".");
				append_chars(trace, " ", len1 - 1);
			end
			else if (!rdy && val) begin
				append_str(trace, "#");
				append_chars(trace, " ", len1 - 1);
			end
			else begin
				append_str(trace, "x");
				append_chars(trace, " ", len1 - 1);
			end
		end
	endtask
endmodule
module vc_QueueCtrl1 (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	write_en,
	bypass_mux_sel,
	num_free_entries
);
	parameter p_type = 4'b0000;
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	output wire send_val;
	input wire send_rdy;
	output wire write_en;
	output wire bypass_mux_sel;
	output wire num_free_entries;
	reg full;
	wire full_next;
	always @(posedge clk) full <= (reset ? 1'b0 : full_next);
	assign num_free_entries = (full ? 1'b0 : 1'b1);
	localparam c_pipe_en = |(p_type & 4'b0001);
	localparam c_bypass_en = |(p_type & 4'b0010);
	wire do_enq;
	assign do_enq = recv_rdy && recv_val;
	wire do_deq;
	assign do_deq = send_rdy && send_val;
	wire empty;
	assign empty = ~full;
	wire do_pipe;
	assign do_pipe = ((c_pipe_en && full) && do_enq) && do_deq;
	wire do_bypass;
	assign do_bypass = ((c_bypass_en && empty) && do_enq) && do_deq;
	assign write_en = do_enq && ~do_bypass;
	assign bypass_mux_sel = empty;
	assign recv_rdy = ~full || ((c_pipe_en && full) && send_rdy);
	assign send_val = ~empty || ((c_bypass_en && empty) && recv_val);
	assign full_next = (do_deq && ~do_pipe ? 1'b0 : (do_enq && ~do_bypass ? 1'b1 : full));
endmodule
module vc_QueueDpath1 (
	clk,
	reset,
	write_en,
	bypass_mux_sel,
	recv_msg,
	send_msg
);
	parameter p_type = 4'b0000;
	parameter p_msg_nbits = 1;
	input wire clk;
	input wire reset;
	input wire write_en;
	input wire bypass_mux_sel;
	input wire [p_msg_nbits - 1:0] recv_msg;
	output wire [p_msg_nbits - 1:0] send_msg;
	wire [p_msg_nbits - 1:0] qstore;
	vc_EnReg #(.p_nbits(p_msg_nbits)) qstore_reg(
		.clk(clk),
		.reset(reset),
		.en(write_en),
		.d(recv_msg),
		.q(qstore)
	);
	generate
		if (|(p_type & 4'b0010)) begin : genblk1
			vc_Mux2 #(.p_nbits(p_msg_nbits)) bypass_mux(
				.in0(qstore),
				.in1(recv_msg),
				.sel(bypass_mux_sel),
				.out(send_msg)
			);
		end
		else begin : genblk1
			assign send_msg = qstore;
		end
	endgenerate
endmodule
module vc_QueueCtrl (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	write_en,
	write_addr,
	read_addr,
	bypass_mux_sel,
	num_free_entries
);
	parameter p_type = 4'b0000;
	parameter p_num_msgs = 2;
	parameter c_addr_nbits = $clog2(p_num_msgs);
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	output wire send_val;
	input wire send_rdy;
	output wire write_en;
	output wire [c_addr_nbits - 1:0] write_addr;
	output wire [c_addr_nbits - 1:0] read_addr;
	output wire bypass_mux_sel;
	output wire [c_addr_nbits:0] num_free_entries;
	wire [c_addr_nbits - 1:0] enq_ptr;
	wire [c_addr_nbits - 1:0] enq_ptr_next;
	vc_ResetReg #(.p_nbits(c_addr_nbits)) enq_ptr_reg(
		.clk(clk),
		.reset(reset),
		.d(enq_ptr_next),
		.q(enq_ptr)
	);
	wire [c_addr_nbits - 1:0] deq_ptr;
	wire [c_addr_nbits - 1:0] deq_ptr_next;
	vc_ResetReg #(.p_nbits(c_addr_nbits)) deq_ptr_reg(
		.clk(clk),
		.reset(reset),
		.d(deq_ptr_next),
		.q(deq_ptr)
	);
	assign write_addr = enq_ptr;
	assign read_addr = deq_ptr;
	wire full;
	wire full_next;
	vc_ResetReg #(.p_nbits(1)) full_reg(
		.clk(clk),
		.reset(reset),
		.d(full_next),
		.q(full)
	);
	localparam c_pipe_en = |(p_type & 4'b0001);
	localparam c_bypass_en = |(p_type & 4'b0010);
	wire do_enq;
	assign do_enq = recv_rdy && recv_val;
	wire do_deq;
	assign do_deq = send_rdy && send_val;
	wire empty;
	assign empty = ~full && (enq_ptr == deq_ptr);
	wire do_pipe;
	assign do_pipe = ((c_pipe_en && full) && do_enq) && do_deq;
	wire do_bypass;
	assign do_bypass = ((c_bypass_en && empty) && do_enq) && do_deq;
	assign write_en = do_enq && ~do_bypass;
	assign bypass_mux_sel = empty;
	assign recv_rdy = ~full || ((c_pipe_en && full) && send_rdy);
	assign send_val = ~empty || ((c_bypass_en && empty) && recv_val);
	wire [c_addr_nbits - 1:0] deq_ptr_plus1;
	assign deq_ptr_plus1 = deq_ptr + 1'b1;
	wire [c_addr_nbits - 1:0] deq_ptr_inc;
	assign deq_ptr_inc = (deq_ptr_plus1 == p_num_msgs ? {c_addr_nbits {1'b0}} : deq_ptr_plus1);
	wire [c_addr_nbits - 1:0] enq_ptr_plus1;
	assign enq_ptr_plus1 = enq_ptr + 1'b1;
	wire [c_addr_nbits - 1:0] enq_ptr_inc;
	assign enq_ptr_inc = (enq_ptr_plus1 == p_num_msgs ? {c_addr_nbits {1'b0}} : enq_ptr_plus1);
	assign deq_ptr_next = (do_deq && ~do_bypass ? deq_ptr_inc : deq_ptr);
	assign enq_ptr_next = (do_enq && ~do_bypass ? enq_ptr_inc : enq_ptr);
	assign full_next = ((do_enq && ~do_deq) && (enq_ptr_inc == deq_ptr) ? 1'b1 : ((do_deq && full) && ~do_pipe ? 1'b0 : full));
	assign num_free_entries = (full ? {c_addr_nbits + 1 {1'b0}} : (empty ? p_num_msgs[c_addr_nbits:0] : (enq_ptr > deq_ptr ? p_num_msgs[c_addr_nbits:0] - (enq_ptr - deq_ptr) : (deq_ptr > enq_ptr ? deq_ptr - enq_ptr : {c_addr_nbits + 1 {1'bx}}))));
endmodule
module vc_QueueDpath (
	clk,
	reset,
	write_en,
	bypass_mux_sel,
	write_addr,
	read_addr,
	recv_msg,
	send_msg
);
	parameter p_type = 4'b0000;
	parameter p_msg_nbits = 4;
	parameter p_num_msgs = 2;
	parameter c_addr_nbits = $clog2(p_num_msgs);
	input wire clk;
	input wire reset;
	input wire write_en;
	input wire bypass_mux_sel;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [c_addr_nbits - 1:0] read_addr;
	input wire [p_msg_nbits - 1:0] recv_msg;
	output wire [p_msg_nbits - 1:0] send_msg;
	wire [p_msg_nbits - 1:0] read_data;
	vc_Regfile_1r1w #(
		.p_data_nbits(p_msg_nbits),
		.p_num_entries(p_num_msgs)
	) qstore(
		.clk(clk),
		.reset(reset),
		.read_addr(read_addr),
		.read_data(read_data),
		.write_en(write_en),
		.write_addr(write_addr),
		.write_data(recv_msg)
	);
	generate
		if (|(p_type & 4'b0010)) begin : genblk1
			vc_Mux2 #(.p_nbits(p_msg_nbits)) bypass_mux(
				.in0(read_data),
				.in1(recv_msg),
				.sel(bypass_mux_sel),
				.out(send_msg)
			);
		end
		else begin : genblk1
			assign send_msg = read_data;
		end
	endgenerate
endmodule
module vc_Queue (
	clk,
	reset,
	recv_val,
	recv_rdy,
	recv_msg,
	send_val,
	send_rdy,
	send_msg,
	num_free_entries
);
	parameter p_type = 4'b0000;
	parameter p_msg_nbits = 1;
	parameter p_num_msgs = 2;
	parameter c_addr_nbits = $clog2(p_num_msgs);
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	input wire [p_msg_nbits - 1:0] recv_msg;
	output wire send_val;
	input wire send_rdy;
	output wire [p_msg_nbits - 1:0] send_msg;
	output wire [c_addr_nbits:0] num_free_entries;
	generate
		if (p_num_msgs == 1) begin : genblk1
			wire write_en;
			wire bypass_mux_sel;
			vc_QueueCtrl1 #(.p_type(p_type)) ctrl(
				.clk(clk),
				.reset(reset),
				.recv_val(recv_val),
				.recv_rdy(recv_rdy),
				.send_val(send_val),
				.send_rdy(send_rdy),
				.write_en(write_en),
				.bypass_mux_sel(bypass_mux_sel),
				.num_free_entries(num_free_entries)
			);
			vc_QueueDpath1 #(
				.p_type(p_type),
				.p_msg_nbits(p_msg_nbits)
			) dpath(
				.clk(clk),
				.reset(reset),
				.write_en(write_en),
				.bypass_mux_sel(bypass_mux_sel),
				.recv_msg(recv_msg),
				.send_msg(send_msg)
			);
		end
		else begin : genblk1
			wire write_en;
			wire bypass_mux_sel;
			wire [c_addr_nbits - 1:0] write_addr;
			wire [c_addr_nbits - 1:0] read_addr;
			vc_QueueCtrl #(
				.p_type(p_type),
				.p_num_msgs(p_num_msgs)
			) ctrl(
				.clk(clk),
				.reset(reset),
				.recv_val(recv_val),
				.recv_rdy(recv_rdy),
				.send_val(send_val),
				.send_rdy(send_rdy),
				.write_en(write_en),
				.write_addr(write_addr),
				.read_addr(read_addr),
				.bypass_mux_sel(bypass_mux_sel),
				.num_free_entries(num_free_entries)
			);
			vc_QueueDpath #(
				.p_type(p_type),
				.p_msg_nbits(p_msg_nbits),
				.p_num_msgs(p_num_msgs)
			) dpath(
				.clk(clk),
				.reset(reset),
				.write_en(write_en),
				.bypass_mux_sel(bypass_mux_sel),
				.write_addr(write_addr),
				.read_addr(read_addr),
				.recv_msg(recv_msg),
				.send_msg(send_msg)
			);
		end
	endgenerate
endmodule
module SPI_v3_components_SPIMinionAdapterVRTL (
	clk,
	reset,
	pull_en,
	pull_msg_val,
	pull_msg_spc,
	pull_msg_data,
	push_en,
	push_msg_val_wrt,
	push_msg_val_rd,
	push_msg_data,
	recv_msg,
	recv_rdy,
	recv_val,
	send_msg,
	send_rdy,
	send_val,
	parity
);
	parameter nbits = 8;
	parameter num_entries = 1;
	input wire clk;
	input wire reset;
	input wire pull_en;
	output reg pull_msg_val;
	output reg pull_msg_spc;
	output reg [nbits - 3:0] pull_msg_data;
	input wire push_en;
	input wire push_msg_val_wrt;
	input wire push_msg_val_rd;
	input wire [nbits - 3:0] push_msg_data;
	input wire [nbits - 3:0] recv_msg;
	output wire recv_rdy;
	input wire recv_val;
	output wire [nbits - 3:0] send_msg;
	input wire send_rdy;
	output wire send_val;
	output wire parity;
	reg open_entries;
	wire [$clog2(num_entries):0] cm_q_num_free;
	wire [nbits - 3:0] cm_q_send_msg;
	reg cm_q_send_rdy;
	wire cm_q_send_val;
	vc_Queue #(
		.p_type(4'b0000),
		.p_msg_nbits(nbits - 2),
		.p_num_msgs(num_entries)
	) cm_q(
		.clk(clk),
		.num_free_entries(cm_q_num_free),
		.reset(reset),
		.recv_msg(recv_msg),
		.recv_rdy(recv_rdy),
		.recv_val(recv_val),
		.send_msg(cm_q_send_msg),
		.send_rdy(cm_q_send_rdy),
		.send_val(cm_q_send_val)
	);
	wire [$clog2(num_entries):0] mc_q_num_free;
	wire mc_q_recv_rdy;
	reg mc_q_recv_val;
	vc_Queue #(
		.p_type(4'b0000),
		.p_msg_nbits(nbits - 2),
		.p_num_msgs(num_entries)
	) mc_q(
		.clk(clk),
		.num_free_entries(mc_q_num_free),
		.reset(reset),
		.recv_msg(push_msg_data),
		.recv_rdy(mc_q_recv_rdy),
		.recv_val(mc_q_recv_val),
		.send_msg(send_msg),
		.send_rdy(send_rdy),
		.send_val(send_val)
	);
	assign parity = ^send_msg & send_val;
	always @(*) begin : comb_block
		open_entries = mc_q_num_free > 1;
		mc_q_recv_val = push_msg_val_wrt & push_en;
		pull_msg_spc = mc_q_recv_rdy & (~mc_q_recv_val | open_entries);
		cm_q_send_rdy = push_msg_val_rd & pull_en;
		pull_msg_val = cm_q_send_rdy & cm_q_send_val;
		pull_msg_data = cm_q_send_msg & {nbits - 2 {pull_msg_val}};
	end
endmodule
module SPI_v3_components_SPIMinionAdapterCompositeVRTL (
	clk,
	cs,
	miso,
	mosi,
	reset,
	sclk,
	recv_msg,
	recv_rdy,
	recv_val,
	send_msg,
	send_rdy,
	send_val,
	minion_parity,
	adapter_parity
);
	parameter nbits = 8;
	parameter num_entries = 1;
	input wire clk;
	input wire cs;
	output wire miso;
	input wire mosi;
	input wire reset;
	input wire sclk;
	input wire [nbits - 3:0] recv_msg;
	output wire recv_rdy;
	input wire recv_val;
	output wire [nbits - 3:0] send_msg;
	input wire send_rdy;
	output wire send_val;
	output wire minion_parity;
	output wire adapter_parity;
	wire pull_en;
	wire pull_msg_val;
	wire pull_msg_spc;
	wire [nbits - 3:0] pull_msg_data;
	wire push_en;
	wire push_msg_val_wrt;
	wire push_msg_val_rd;
	wire [nbits - 3:0] push_msg_data;
	wire [nbits - 1:0] pull_msg;
	wire [nbits - 1:0] push_msg;
	SPI_v3_components_SPIMinionAdapterVRTL #(
		.nbits(nbits),
		.num_entries(num_entries)
	) adapter(
		.clk(clk),
		.reset(reset),
		.pull_en(pull_en),
		.pull_msg_val(pull_msg_val),
		.pull_msg_spc(pull_msg_spc),
		.pull_msg_data(pull_msg_data),
		.push_en(push_en),
		.push_msg_val_wrt(push_msg_val_wrt),
		.push_msg_val_rd(push_msg_val_rd),
		.push_msg_data(push_msg_data),
		.recv_msg(recv_msg),
		.recv_rdy(recv_rdy),
		.recv_val(recv_val),
		.send_msg(send_msg),
		.send_rdy(send_rdy),
		.send_val(send_val),
		.parity(adapter_parity)
	);
	SPI_v3_components_SPIMinionVRTL #(.nbits(nbits)) minion(
		.clk(clk),
		.cs(cs),
		.miso(miso),
		.mosi(mosi),
		.reset(reset),
		.sclk(sclk),
		.pull_en(pull_en),
		.pull_msg(pull_msg),
		.push_en(push_en),
		.push_msg(push_msg),
		.parity(minion_parity)
	);
	assign pull_msg[nbits - 1] = pull_msg_val;
	assign pull_msg[nbits - 2] = pull_msg_spc;
	assign pull_msg[nbits - 3:0] = pull_msg_data;
	assign push_msg_val_wrt = push_msg[nbits - 1];
	assign push_msg_val_rd = push_msg[nbits - 2];
	assign push_msg_data = push_msg[nbits - 3:0];
endmodule
module SPI_v3_components_SPIstackVRTL (
	clk,
	reset,
	loopthrough_sel,
	minion_parity,
	adapter_parity,
	sclk,
	cs,
	mosi,
	miso,
	send_val,
	send_msg,
	send_rdy,
	recv_val,
	recv_msg,
	recv_rdy
);
	parameter nbits = 34;
	parameter num_entries = 1;
	input wire clk;
	input wire reset;
	input wire loopthrough_sel;
	output wire minion_parity;
	output wire adapter_parity;
	input wire sclk;
	input wire cs;
	input wire mosi;
	output wire miso;
	output wire send_val;
	output wire [nbits - 3:0] send_msg;
	input wire send_rdy;
	input wire recv_val;
	input wire [nbits - 3:0] recv_msg;
	output wire recv_rdy;
	wire minion_out_val;
	wire [nbits - 3:0] minion_out_msg;
	wire minion_out_rdy;
	wire minion_in_val;
	wire [nbits - 3:0] minion_in_msg;
	wire minion_in_rdy;
	SPI_v3_components_SPIMinionAdapterCompositeVRTL #(
		.nbits(nbits),
		.num_entries(num_entries)
	) minion(
		.clk(clk),
		.reset(reset),
		.cs(cs),
		.miso(miso),
		.mosi(mosi),
		.sclk(sclk),
		.minion_parity(minion_parity),
		.adapter_parity(adapter_parity),
		.recv_val(minion_in_val),
		.recv_msg(minion_in_msg),
		.recv_rdy(minion_in_rdy),
		.send_val(minion_out_val),
		.send_msg(minion_out_msg),
		.send_rdy(minion_out_rdy)
	);
	SPI_v3_components_LoopThroughVRTL #(.nbits(nbits - 2)) loopthrough(
		.clk(clk),
		.reset(reset),
		.sel(loopthrough_sel),
		.upstream_req_val(minion_out_val),
		.upstream_req_msg(minion_out_msg),
		.upstream_req_rdy(minion_out_rdy),
		.upstream_resp_val(minion_in_val),
		.upstream_resp_msg(minion_in_msg),
		.upstream_resp_rdy(minion_in_rdy),
		.downstream_req_val(send_val),
		.downstream_req_msg(send_msg),
		.downstream_req_rdy(send_rdy),
		.downstream_resp_val(recv_val),
		.downstream_resp_msg(recv_msg),
		.downstream_resp_rdy(recv_rdy)
	);
endmodule
module ccs_in_wait_v1 (
	idat,
	rdy,
	ivld,
	dat,
	irdy,
	vld
);
	parameter integer rscid = 1;
	parameter integer width = 8;
	output wire [width - 1:0] idat;
	output wire rdy;
	output wire ivld;
	input [width - 1:0] dat;
	input irdy;
	input vld;
	localparam stallOff = 0;
	wire stall_ctrl;
	assign stall_ctrl = stallOff;
	assign idat = dat;
	assign rdy = irdy && !stall_ctrl;
	assign ivld = vld && !stall_ctrl;
endmodule
module ccs_out_wait_v1 (
	dat,
	irdy,
	vld,
	idat,
	rdy,
	ivld
);
	parameter integer rscid = 1;
	parameter integer width = 8;
	output wire [width - 1:0] dat;
	output wire irdy;
	output wire vld;
	input [width - 1:0] idat;
	input rdy;
	input ivld;
	localparam stallOff = 0;
	wire stall_ctrl;
	assign stall_ctrl = stallOff;
	assign dat = idat;
	assign irdy = rdy && !stall_ctrl;
	assign vld = ivld && !stall_ctrl;
endmodule
module crc32_core_core_fsm (
	clk,
	rst,
	core_wen,
	fsm_output,
	main_C_0_tr0,
	for_C_0_tr0
);
	input clk;
	input rst;
	input core_wen;
	output reg [3:0] fsm_output;
	input main_C_0_tr0;
	input for_C_0_tr0;
	parameter core_rlp_C_0 = 2'd0;
	parameter main_C_0 = 2'd1;
	parameter for_C_0 = 2'd2;
	parameter main_C_1 = 2'd3;
	reg [1:0] state_var;
	reg [1:0] state_var_NS;
	always @(*) begin : crc32_core_core_fsm_1
		case (state_var)
			main_C_0: begin
				fsm_output = 4'b0010;
				if (main_C_0_tr0)
					state_var_NS = main_C_1;
				else
					state_var_NS = for_C_0;
			end
			for_C_0: begin
				fsm_output = 4'b0100;
				if (for_C_0_tr0)
					state_var_NS = main_C_1;
				else
					state_var_NS = for_C_0;
			end
			main_C_1: begin
				fsm_output = 4'b1000;
				state_var_NS = main_C_0;
			end
			default: begin
				fsm_output = 4'b0001;
				state_var_NS = main_C_0;
			end
		endcase
	end
	always @(posedge clk)
		if (rst)
			state_var <= core_rlp_C_0;
		else if (core_wen)
			state_var <= state_var_NS;
endmodule
module crc32_core_staller (
	core_wen,
	in_rsci_wen_comp,
	out_rsci_wen_comp
);
	output wire core_wen;
	input in_rsci_wen_comp;
	input out_rsci_wen_comp;
	assign core_wen = in_rsci_wen_comp & out_rsci_wen_comp;
endmodule
module crc32_core_out_rsci_out_wait_ctrl (
	out_rsci_iswt0,
	out_rsci_biwt,
	out_rsci_irdy
);
	input out_rsci_iswt0;
	output wire out_rsci_biwt;
	input out_rsci_irdy;
	assign out_rsci_biwt = out_rsci_iswt0 & out_rsci_irdy;
endmodule
module crc32_core_in_rsci_in_wait_ctrl (
	in_rsci_iswt0,
	in_rsci_biwt,
	in_rsci_ivld
);
	input in_rsci_iswt0;
	output wire in_rsci_biwt;
	input in_rsci_ivld;
	assign in_rsci_biwt = in_rsci_iswt0 & in_rsci_ivld;
endmodule
module crc32_core_out_rsci (
	out_rsc_dat,
	out_rsc_vld,
	out_rsc_rdy,
	out_rsci_oswt,
	out_rsci_wen_comp,
	out_rsci_idat
);
	output wire [31:0] out_rsc_dat;
	output wire out_rsc_vld;
	input out_rsc_rdy;
	input out_rsci_oswt;
	output wire out_rsci_wen_comp;
	input [31:0] out_rsci_idat;
	wire out_rsci_biwt;
	wire out_rsci_irdy;
	ccs_out_wait_v1 #(
		.rscid(32'sd2),
		.width(32'sd32)
	) out_rsci(
		.irdy(out_rsci_irdy),
		.ivld(out_rsci_oswt),
		.idat(out_rsci_idat),
		.rdy(out_rsc_rdy),
		.vld(out_rsc_vld),
		.dat(out_rsc_dat)
	);
	crc32_core_out_rsci_out_wait_ctrl crc32_core_out_rsci_out_wait_ctrl_inst(
		.out_rsci_iswt0(out_rsci_oswt),
		.out_rsci_biwt(out_rsci_biwt),
		.out_rsci_irdy(out_rsci_irdy)
	);
	assign out_rsci_wen_comp = ~out_rsci_oswt | out_rsci_biwt;
endmodule
module crc32_core_in_rsci (
	in_rsc_dat,
	in_rsc_vld,
	in_rsc_rdy,
	in_rsci_oswt,
	in_rsci_wen_comp,
	in_rsci_idat_mxwt
);
	input [7:0] in_rsc_dat;
	input in_rsc_vld;
	output wire in_rsc_rdy;
	input in_rsci_oswt;
	output wire in_rsci_wen_comp;
	output wire [7:0] in_rsci_idat_mxwt;
	wire in_rsci_biwt;
	wire in_rsci_ivld;
	wire [7:0] in_rsci_idat;
	ccs_in_wait_v1 #(
		.rscid(32'sd1),
		.width(32'sd8)
	) in_rsci(
		.rdy(in_rsc_rdy),
		.vld(in_rsc_vld),
		.dat(in_rsc_dat),
		.irdy(in_rsci_oswt),
		.ivld(in_rsci_ivld),
		.idat(in_rsci_idat)
	);
	crc32_core_in_rsci_in_wait_ctrl crc32_core_in_rsci_in_wait_ctrl_inst(
		.in_rsci_iswt0(in_rsci_oswt),
		.in_rsci_biwt(in_rsci_biwt),
		.in_rsci_ivld(in_rsci_ivld)
	);
	assign in_rsci_idat_mxwt = in_rsci_idat;
	assign in_rsci_wen_comp = ~in_rsci_oswt | in_rsci_biwt;
endmodule
module crc32_core (
	clk,
	rst,
	in_rsc_dat,
	in_rsc_vld,
	in_rsc_rdy,
	out_rsc_dat,
	out_rsc_vld,
	out_rsc_rdy
);
	input clk;
	input rst;
	input [7:0] in_rsc_dat;
	input in_rsc_vld;
	output wire in_rsc_rdy;
	output wire [31:0] out_rsc_dat;
	output wire out_rsc_vld;
	input out_rsc_rdy;
	wire core_wen;
	wire in_rsci_wen_comp;
	wire [7:0] in_rsci_idat_mxwt;
	wire out_rsci_wen_comp;
	reg out_rsci_idat_31;
	reg out_rsci_idat_30;
	reg out_rsci_idat_29;
	reg out_rsci_idat_28;
	reg out_rsci_idat_27;
	reg out_rsci_idat_26;
	reg out_rsci_idat_25;
	reg out_rsci_idat_24;
	reg out_rsci_idat_23;
	reg out_rsci_idat_22;
	reg out_rsci_idat_21;
	reg out_rsci_idat_20;
	reg out_rsci_idat_19;
	reg out_rsci_idat_18;
	reg out_rsci_idat_17;
	reg out_rsci_idat_16;
	reg out_rsci_idat_15;
	reg out_rsci_idat_14;
	reg out_rsci_idat_13;
	reg out_rsci_idat_12;
	reg out_rsci_idat_11;
	reg out_rsci_idat_10;
	reg out_rsci_idat_9;
	reg out_rsci_idat_8;
	reg out_rsci_idat_7;
	reg out_rsci_idat_6;
	reg out_rsci_idat_5;
	reg out_rsci_idat_4;
	reg out_rsci_idat_3;
	reg out_rsci_idat_2;
	reg out_rsci_idat_1;
	reg out_rsci_idat_0;
	wire [3:0] fsm_output;
	wire for_for_8_b_xor_tmp;
	wire for_for_7_b_xor_tmp;
	wire for_for_6_b_xor_tmp;
	wire for_for_5_b_xor_tmp;
	wire for_for_4_b_xor_tmp;
	wire not_tmp_3;
	wire not_tmp_4;
	wire not_tmp_5;
	wire not_tmp_6;
	wire not_tmp_7;
	wire not_tmp_8;
	wire not_tmp_9;
	wire not_tmp_10;
	wire or_tmp_32;
	wire or_tmp_40;
	wire or_tmp_52;
	wire or_tmp_56;
	wire or_tmp_60;
	wire exit_for_sva_mx0;
	reg crc_2_1_sva;
	reg crc_1_1_sva;
	reg crc_0_1_sva;
	wire and_314_cse;
	reg reg_out_rsci_iswt0_cse;
	reg reg_in_rsci_iswt0_cse;
	wire crc_mux_140_cse;
	wire [8:0] z_out;
	wire [9:0] nl_z_out;
	reg [7:0] size_val_sva;
	reg crc_15_1_sva;
	reg crc_16_1_sva;
	reg crc_14_1_sva;
	reg crc_17_1_sva;
	reg crc_13_1_sva;
	reg crc_18_1_sva;
	reg crc_12_1_sva;
	reg crc_19_1_sva;
	reg crc_11_1_sva;
	reg crc_20_1_sva;
	reg crc_10_1_sva;
	reg crc_21_1_sva;
	reg crc_9_1_sva;
	reg crc_22_1_sva;
	reg crc_8_1_sva;
	reg crc_23_1_sva;
	reg crc_7_1_sva;
	reg crc_24_1_sva;
	reg crc_6_1_sva;
	reg crc_25_1_sva;
	reg crc_5_1_sva;
	reg crc_26_1_sva;
	reg crc_4_1_sva;
	reg crc_27_1_sva;
	reg crc_3_1_sva;
	reg crc_28_1_sva;
	reg crc_29_1_sva;
	reg crc_30_1_sva;
	reg crc_31_1_sva;
	reg [7:0] for_i_sva;
	wire crc_5_4_lpi_2_dfm_mx0;
	wire crc_8_2_lpi_2_dfm_mx0;
	wire crc_8_3_lpi_2_dfm_mx0;
	wire crc_8_4_lpi_2_dfm_mx0;
	wire crc_8_5_lpi_2_dfm_mx0;
	wire crc_8_6_lpi_2_dfm_mx0;
	wire crc_9_6_lpi_2_dfm_mx0;
	wire crc_9_7_lpi_2_dfm_mx0;
	wire crc_9_lpi_2_dfm_mx0;
	wire crc_15_3_lpi_2_dfm_mx0;
	wire crc_15_4_lpi_2_dfm_mx0;
	wire crc_15_5_lpi_2_dfm_mx0;
	wire crc_19_2_lpi_2_dfm_mx0;
	wire crc_19_3_lpi_2_dfm_mx0;
	wire crc_19_4_lpi_2_dfm_mx0;
	wire crc_19_5_lpi_2_dfm_mx0;
	wire crc_20_5_lpi_2_dfm_mx0;
	wire crc_20_6_lpi_2_dfm_mx0;
	wire crc_20_7_lpi_2_dfm_mx0;
	wire crc_20_lpi_2_dfm_mx0;
	wire crc_21_lpi_2_dfm_mx0;
	wire crc_23_7_lpi_2_dfm_mx0;
	wire crc_24_7_lpi_2_dfm_mx0;
	wire crc_24_lpi_2_dfm_mx0;
	wire crc_26_7_lpi_2_dfm_mx0;
	wire crc_27_7_lpi_2_dfm_mx0;
	wire crc_27_lpi_2_dfm_mx0;
	wire crc_29_7_lpi_2_dfm_mx0;
	wire crc_30_7_lpi_2_dfm_mx0;
	wire crc_30_lpi_2_dfm_mx0;
	wire for_for_b_2_sva_1;
	wire crc_15_2_lpi_2_dfm_mx0;
	wire crc_21_7_lpi_2_dfm_mx0;
	wire crc_23_6_lpi_2_dfm_mx0;
	wire crc_26_6_lpi_2_dfm_mx0;
	wire crc_29_6_lpi_2_dfm_mx0;
	wire for_for_b_1_sva_1;
	wire crc_21_6_lpi_2_dfm_mx0;
	wire crc_23_5_lpi_2_dfm_mx0;
	wire crc_24_6_lpi_2_dfm_mx0;
	wire crc_26_5_lpi_2_dfm_mx0;
	wire crc_27_6_lpi_2_dfm_mx0;
	wire crc_29_5_lpi_2_dfm_mx0;
	wire crc_30_6_lpi_2_dfm_mx0;
	wire crc_9_5_lpi_2_dfm_mx0;
	wire crc_21_5_lpi_2_dfm_mx0;
	wire crc_23_4_lpi_2_dfm_mx0;
	wire crc_24_5_lpi_2_dfm_mx0;
	wire crc_26_4_lpi_2_dfm_mx0;
	wire crc_27_5_lpi_2_dfm_mx0;
	wire crc_29_4_lpi_2_dfm_mx0;
	wire crc_30_5_lpi_2_dfm_mx0;
	wire crc_9_4_lpi_2_dfm_mx0;
	wire crc_20_4_lpi_2_dfm_mx0;
	wire crc_21_4_lpi_2_dfm_mx0;
	wire crc_23_3_lpi_2_dfm_mx0;
	wire crc_24_4_lpi_2_dfm_mx0;
	wire crc_26_3_lpi_2_dfm_mx0;
	wire crc_27_4_lpi_2_dfm_mx0;
	wire crc_29_3_lpi_2_dfm_mx0;
	wire crc_30_4_lpi_2_dfm_mx0;
	wire for_for_b_3_sva_1;
	wire crc_9_3_lpi_2_dfm_mx0;
	wire crc_20_3_lpi_2_dfm_mx0;
	wire crc_21_3_lpi_2_dfm_mx0;
	wire crc_23_2_lpi_2_dfm_mx0;
	wire crc_24_3_lpi_2_dfm_mx0;
	wire crc_26_2_lpi_2_dfm_mx0;
	wire crc_27_3_lpi_2_dfm_mx0;
	wire crc_29_2_lpi_2_dfm_mx0;
	wire crc_30_3_lpi_2_dfm_mx0;
	wire crc_9_2_lpi_2_dfm_mx0;
	wire crc_20_2_lpi_2_dfm_mx0;
	wire crc_21_2_lpi_2_dfm_mx0;
	wire crc_24_2_lpi_2_dfm_mx0;
	wire crc_27_2_lpi_2_dfm_mx0;
	wire crc_30_2_lpi_2_dfm_mx0;
	wire xor_cse_1;
	wire xor_cse_5;
	wire crc_mux_142_nl;
	wire crc_mux_144_nl;
	wire crc_mux_146_nl;
	wire crc_mux_148_nl;
	wire crc_mux_150_nl;
	wire crc_mux_152_nl;
	wire crc_mux_154_nl;
	wire crc_mux_156_nl;
	wire crc_mux_160_nl;
	wire crc_mux_162_nl;
	wire crc_mux_164_nl;
	wire crc_mux_166_nl;
	wire crc_mux_165_nl;
	wire crc_mux_163_nl;
	wire crc_mux_161_nl;
	wire crc_mux_159_nl;
	wire crc_mux_158_nl;
	wire crc_mux_157_nl;
	wire crc_mux_155_nl;
	wire crc_mux_153_nl;
	wire crc_mux_151_nl;
	wire crc_mux_149_nl;
	wire crc_mux_147_nl;
	wire crc_mux_145_nl;
	wire crc_mux_143_nl;
	wire crc_mux_141_nl;
	wire crc_mux_nl;
	wire crc_mux_167_nl;
	wire crc_mux_168_nl;
	wire crc_mux_169_nl;
	wire crc_mux_170_nl;
	wire crc_mux_171_nl;
	wire crc_mux_172_nl;
	wire crc_mux_173_nl;
	wire crc_mux_174_nl;
	wire crc_mux_175_nl;
	wire crc_mux_176_nl;
	wire crc_mux_177_nl;
	wire crc_mux_178_nl;
	wire crc_mux_179_nl;
	wire crc_mux_180_nl;
	wire crc_mux_181_nl;
	wire crc_mux_182_nl;
	wire crc_mux_183_nl;
	wire crc_mux_184_nl;
	wire crc_mux_185_nl;
	wire crc_mux_186_nl;
	wire crc_mux_187_nl;
	wire crc_mux_188_nl;
	wire crc_mux_189_nl;
	wire crc_mux_190_nl;
	wire crc_mux_191_nl;
	wire crc_mux_192_nl;
	wire crc_mux_193_nl;
	wire [8:0] for_acc_nl;
	wire [7:0] for_mux_2_nl;
	wire [31:0] nl_crc32_core_out_rsci_inst_out_rsci_idat;
	assign nl_crc32_core_out_rsci_inst_out_rsci_idat = {out_rsci_idat_31, out_rsci_idat_30, out_rsci_idat_29, out_rsci_idat_28, out_rsci_idat_27, out_rsci_idat_26, out_rsci_idat_25, out_rsci_idat_24, out_rsci_idat_23, out_rsci_idat_22, out_rsci_idat_21, out_rsci_idat_20, out_rsci_idat_19, out_rsci_idat_18, out_rsci_idat_17, out_rsci_idat_16, out_rsci_idat_15, out_rsci_idat_14, out_rsci_idat_13, out_rsci_idat_12, out_rsci_idat_11, out_rsci_idat_10, out_rsci_idat_9, out_rsci_idat_8, out_rsci_idat_7, out_rsci_idat_6, out_rsci_idat_5, out_rsci_idat_4, out_rsci_idat_3, out_rsci_idat_2, out_rsci_idat_1, out_rsci_idat_0};
	crc32_core_in_rsci crc32_core_in_rsci_inst(
		.in_rsc_dat(in_rsc_dat),
		.in_rsc_vld(in_rsc_vld),
		.in_rsc_rdy(in_rsc_rdy),
		.in_rsci_oswt(reg_in_rsci_iswt0_cse),
		.in_rsci_wen_comp(in_rsci_wen_comp),
		.in_rsci_idat_mxwt(in_rsci_idat_mxwt)
	);
	crc32_core_out_rsci crc32_core_out_rsci_inst(
		.out_rsc_dat(out_rsc_dat),
		.out_rsc_vld(out_rsc_vld),
		.out_rsc_rdy(out_rsc_rdy),
		.out_rsci_oswt(reg_out_rsci_iswt0_cse),
		.out_rsci_wen_comp(out_rsci_wen_comp),
		.out_rsci_idat(nl_crc32_core_out_rsci_inst_out_rsci_idat[31:0])
	);
	crc32_core_staller crc32_core_staller_inst(
		.core_wen(core_wen),
		.in_rsci_wen_comp(in_rsci_wen_comp),
		.out_rsci_wen_comp(out_rsci_wen_comp)
	);
	crc32_core_core_fsm crc32_core_core_fsm_inst(
		.clk(clk),
		.rst(rst),
		.core_wen(core_wen),
		.fsm_output(fsm_output),
		.main_C_0_tr0(exit_for_sva_mx0),
		.for_C_0_tr0(exit_for_sva_mx0)
	);
	assign and_314_cse = core_wen & ~((fsm_output[0] | fsm_output[3]) | ~exit_for_sva_mx0);
	function automatic MUX_s_1_2_2;
		input input_0;
		input input_1;
		input sel;
		reg result;
		begin
			case (sel)
				1'b0: result = input_0;
				default: result = input_1;
			endcase
			MUX_s_1_2_2 = result;
		end
	endfunction
	assign crc_mux_140_cse = MUX_s_1_2_2(~crc_8_2_lpi_2_dfm_mx0, crc_8_2_lpi_2_dfm_mx0, not_tmp_4);
	assign for_acc_nl = $signed(z_out[7:0]) - $signed(size_val_sva);
	function automatic [0:0] readslicef_9_1_8;
		input [8:0] vector;
		reg [8:0] tmp;
		begin
			tmp = vector >> 8;
			readslicef_9_1_8 = tmp[0:0];
		end
	endfunction
	assign exit_for_sva_mx0 = MUX_s_1_2_2(~z_out[8], ~readslicef_9_1_8(for_acc_nl), fsm_output[2]);
	assign crc_5_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_8_1_sva, crc_8_1_sva, not_tmp_8);
	assign crc_8_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_9_1_sva, crc_9_1_sva, not_tmp_9);
	assign for_for_4_b_xor_tmp = in_rsci_idat_mxwt[3] ^ crc_3_1_sva;
	assign crc_8_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_9_2_lpi_2_dfm_mx0, crc_9_2_lpi_2_dfm_mx0, not_tmp_10);
	assign for_for_5_b_xor_tmp = in_rsci_idat_mxwt[4] ^ crc_4_1_sva;
	assign crc_8_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_9_3_lpi_2_dfm_mx0, crc_9_3_lpi_2_dfm_mx0, not_tmp_8);
	assign for_for_6_b_xor_tmp = in_rsci_idat_mxwt[5] ^ crc_5_1_sva;
	assign crc_8_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_9_4_lpi_2_dfm_mx0, crc_9_4_lpi_2_dfm_mx0, not_tmp_4);
	assign for_for_7_b_xor_tmp = in_rsci_idat_mxwt[6] ^ xor_cse_5;
	assign crc_8_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_9_5_lpi_2_dfm_mx0, crc_9_5_lpi_2_dfm_mx0, not_tmp_5);
	assign for_for_8_b_xor_tmp = in_rsci_idat_mxwt[7] ^ xor_cse_1;
	assign crc_9_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_14_1_sva, crc_14_1_sva, not_tmp_5);
	assign crc_9_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_15_1_sva, crc_15_1_sva, not_tmp_7);
	assign crc_9_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_15_2_lpi_2_dfm_mx0, crc_15_2_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_15_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_17_1_sva, crc_17_1_sva, not_tmp_10);
	assign crc_15_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_18_1_sva, crc_18_1_sva, not_tmp_8);
	assign crc_15_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_19_1_sva, crc_19_1_sva, not_tmp_4);
	assign crc_19_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_20_1_sva, crc_20_1_sva, not_tmp_9);
	assign crc_19_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_20_2_lpi_2_dfm_mx0, crc_20_2_lpi_2_dfm_mx0, not_tmp_10);
	assign crc_19_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_20_3_lpi_2_dfm_mx0, crc_20_3_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_19_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_20_4_lpi_2_dfm_mx0, crc_20_4_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_20_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_4_lpi_2_dfm_mx0, crc_21_4_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_20_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_5_lpi_2_dfm_mx0, crc_21_5_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_20_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_6_lpi_2_dfm_mx0, crc_21_6_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_20_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_7_lpi_2_dfm_mx0, crc_21_7_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_21_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_23_6_lpi_2_dfm_mx0, crc_23_6_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_23_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_24_6_lpi_2_dfm_mx0, crc_24_6_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_24_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_26_5_lpi_2_dfm_mx0, crc_26_5_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_24_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_26_6_lpi_2_dfm_mx0, crc_26_6_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_26_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_27_6_lpi_2_dfm_mx0, crc_27_6_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_27_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_29_5_lpi_2_dfm_mx0, crc_29_5_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_27_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_29_6_lpi_2_dfm_mx0, crc_29_6_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_29_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_30_6_lpi_2_dfm_mx0, crc_30_6_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_30_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~for_for_5_b_xor_tmp, for_for_5_b_xor_tmp, not_tmp_7);
	assign crc_30_lpi_2_dfm_mx0 = MUX_s_1_2_2(~for_for_6_b_xor_tmp, for_for_6_b_xor_tmp, not_tmp_6);
	assign for_for_b_2_sva_1 = in_rsci_idat_mxwt[1] ^ crc_1_1_sva;
	assign crc_15_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_16_1_sva, crc_16_1_sva, not_tmp_9);
	assign crc_21_7_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_23_5_lpi_2_dfm_mx0, crc_23_5_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_23_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_24_5_lpi_2_dfm_mx0, crc_24_5_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_26_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_27_5_lpi_2_dfm_mx0, crc_27_5_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_29_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_30_5_lpi_2_dfm_mx0, crc_30_5_lpi_2_dfm_mx0, not_tmp_5);
	assign for_for_b_1_sva_1 = in_rsci_idat_mxwt[0] ^ crc_0_1_sva;
	assign crc_21_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_23_4_lpi_2_dfm_mx0, crc_23_4_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_23_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_24_4_lpi_2_dfm_mx0, crc_24_4_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_24_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_26_4_lpi_2_dfm_mx0, crc_26_4_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_26_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_27_4_lpi_2_dfm_mx0, crc_27_4_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_27_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_29_4_lpi_2_dfm_mx0, crc_29_4_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_29_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_30_4_lpi_2_dfm_mx0, crc_30_4_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_30_6_lpi_2_dfm_mx0 = MUX_s_1_2_2(~for_for_4_b_xor_tmp, for_for_4_b_xor_tmp, not_tmp_5);
	assign crc_9_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_13_1_sva, crc_13_1_sva, not_tmp_4);
	assign crc_21_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_23_3_lpi_2_dfm_mx0, crc_23_3_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_23_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_24_3_lpi_2_dfm_mx0, crc_24_3_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_24_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_26_3_lpi_2_dfm_mx0, crc_26_3_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_26_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_27_3_lpi_2_dfm_mx0, crc_27_3_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_27_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_29_3_lpi_2_dfm_mx0, crc_29_3_lpi_2_dfm_mx0, not_tmp_4);
	assign crc_29_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_30_3_lpi_2_dfm_mx0, crc_30_3_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_30_5_lpi_2_dfm_mx0 = MUX_s_1_2_2(~for_for_b_3_sva_1, for_for_b_3_sva_1, not_tmp_4);
	assign crc_9_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_12_1_sva, crc_12_1_sva, not_tmp_8);
	assign crc_20_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_3_lpi_2_dfm_mx0, crc_21_3_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_21_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_23_2_lpi_2_dfm_mx0, crc_23_2_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_23_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_24_2_lpi_2_dfm_mx0, crc_24_2_lpi_2_dfm_mx0, not_tmp_10);
	assign crc_24_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_26_2_lpi_2_dfm_mx0, crc_26_2_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_26_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_27_2_lpi_2_dfm_mx0, crc_27_2_lpi_2_dfm_mx0, not_tmp_10);
	assign crc_27_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_29_2_lpi_2_dfm_mx0, crc_29_2_lpi_2_dfm_mx0, not_tmp_8);
	assign crc_29_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_30_2_lpi_2_dfm_mx0, crc_30_2_lpi_2_dfm_mx0, not_tmp_10);
	assign crc_30_4_lpi_2_dfm_mx0 = MUX_s_1_2_2(~for_for_b_2_sva_1, for_for_b_2_sva_1, not_tmp_8);
	assign for_for_b_3_sva_1 = in_rsci_idat_mxwt[2] ^ crc_2_1_sva;
	assign crc_9_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_11_1_sva, crc_11_1_sva, not_tmp_10);
	assign crc_20_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_2_lpi_2_dfm_mx0, crc_21_2_lpi_2_dfm_mx0, not_tmp_10);
	assign crc_21_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_23_1_sva, crc_23_1_sva, not_tmp_10);
	assign crc_23_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_24_1_sva, crc_24_1_sva, not_tmp_9);
	assign crc_24_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_26_1_sva, crc_26_1_sva, not_tmp_10);
	assign crc_26_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_27_1_sva, crc_27_1_sva, not_tmp_9);
	assign crc_27_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_29_1_sva, crc_29_1_sva, not_tmp_10);
	assign crc_29_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_30_1_sva, crc_30_1_sva, not_tmp_9);
	assign crc_30_3_lpi_2_dfm_mx0 = MUX_s_1_2_2(~for_for_b_1_sva_1, for_for_b_1_sva_1, not_tmp_10);
	assign crc_9_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_10_1_sva, crc_10_1_sva, not_tmp_9);
	assign crc_20_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_21_1_sva, crc_21_1_sva, not_tmp_9);
	assign crc_21_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_22_1_sva, crc_22_1_sva, not_tmp_9);
	assign crc_24_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_25_1_sva, crc_25_1_sva, not_tmp_9);
	assign crc_27_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_28_1_sva, crc_28_1_sva, not_tmp_9);
	assign crc_30_2_lpi_2_dfm_mx0 = MUX_s_1_2_2(~crc_31_1_sva, crc_31_1_sva, not_tmp_9);
	assign or_tmp_32 = exit_for_sva_mx0 & (fsm_output[2:1] != 2'b00);
	assign or_tmp_40 = not_tmp_3 & fsm_output[2];
	assign or_tmp_52 = not_tmp_5 & fsm_output[2];
	assign or_tmp_56 = not_tmp_6 & fsm_output[2];
	assign or_tmp_60 = not_tmp_7 & fsm_output[2];
	assign xor_cse_1 = MUX_s_1_2_2(crc_7_1_sva, ~crc_7_1_sva, for_for_b_2_sva_1);
	assign not_tmp_3 = ~(in_rsci_idat_mxwt[7] ^ xor_cse_1);
	assign not_tmp_4 = ~(in_rsci_idat_mxwt[3] ^ crc_3_1_sva);
	assign not_tmp_5 = ~(in_rsci_idat_mxwt[4] ^ crc_4_1_sva);
	assign xor_cse_5 = MUX_s_1_2_2(crc_6_1_sva, ~crc_6_1_sva, for_for_b_1_sva_1);
	assign not_tmp_6 = ~(in_rsci_idat_mxwt[6] ^ xor_cse_5);
	assign not_tmp_7 = ~(in_rsci_idat_mxwt[5] ^ crc_5_1_sva);
	assign not_tmp_8 = ~(in_rsci_idat_mxwt[2] ^ crc_2_1_sva);
	assign not_tmp_9 = ~(in_rsci_idat_mxwt[0] ^ crc_0_1_sva);
	assign not_tmp_10 = ~(in_rsci_idat_mxwt[1] ^ crc_1_1_sva);
	always @(posedge clk)
		if (rst) begin
			out_rsci_idat_0 <= 1'b0;
			out_rsci_idat_1 <= 1'b0;
			out_rsci_idat_2 <= 1'b0;
			out_rsci_idat_3 <= 1'b0;
			out_rsci_idat_4 <= 1'b0;
			out_rsci_idat_5 <= 1'b0;
			out_rsci_idat_6 <= 1'b0;
			out_rsci_idat_7 <= 1'b0;
			out_rsci_idat_8 <= 1'b0;
			out_rsci_idat_9 <= 1'b0;
			out_rsci_idat_10 <= 1'b0;
			out_rsci_idat_11 <= 1'b0;
			out_rsci_idat_12 <= 1'b0;
			out_rsci_idat_13 <= 1'b0;
			out_rsci_idat_14 <= 1'b0;
			out_rsci_idat_15 <= 1'b0;
			out_rsci_idat_16 <= 1'b0;
			out_rsci_idat_17 <= 1'b0;
			out_rsci_idat_18 <= 1'b0;
			out_rsci_idat_19 <= 1'b0;
			out_rsci_idat_20 <= 1'b0;
			out_rsci_idat_21 <= 1'b0;
			out_rsci_idat_22 <= 1'b0;
			out_rsci_idat_23 <= 1'b0;
			out_rsci_idat_24 <= 1'b0;
			out_rsci_idat_25 <= 1'b0;
			out_rsci_idat_26 <= 1'b0;
			out_rsci_idat_27 <= 1'b0;
			out_rsci_idat_28 <= 1'b0;
			out_rsci_idat_29 <= 1'b0;
			out_rsci_idat_30 <= 1'b0;
			out_rsci_idat_31 <= 1'b0;
		end
		else if (and_314_cse) begin
			out_rsci_idat_0 <= ~(crc_5_4_lpi_2_dfm_mx0 | ~fsm_output[2]);
			out_rsci_idat_1 <= ~(crc_mux_140_cse | ~fsm_output[2]);
			out_rsci_idat_2 <= ~(crc_mux_142_nl | ~fsm_output[2]);
			out_rsci_idat_3 <= ~(crc_mux_144_nl | ~fsm_output[2]);
			out_rsci_idat_4 <= ~(crc_mux_146_nl | ~fsm_output[2]);
			out_rsci_idat_5 <= ~(crc_mux_148_nl | ~fsm_output[2]);
			out_rsci_idat_6 <= ~(crc_mux_150_nl | ~fsm_output[2]);
			out_rsci_idat_7 <= ~(crc_mux_152_nl | ~fsm_output[2]);
			out_rsci_idat_8 <= ~(crc_mux_154_nl | ~fsm_output[2]);
			out_rsci_idat_9 <= ~(crc_mux_156_nl | ~fsm_output[2]);
			out_rsci_idat_10 <= ~(crc_15_4_lpi_2_dfm_mx0 | ~fsm_output[2]);
			out_rsci_idat_11 <= ~(crc_15_5_lpi_2_dfm_mx0 | ~fsm_output[2]);
			out_rsci_idat_12 <= ~(crc_mux_160_nl | ~fsm_output[2]);
			out_rsci_idat_13 <= ~(crc_mux_162_nl | ~fsm_output[2]);
			out_rsci_idat_14 <= ~(crc_mux_164_nl | ~fsm_output[2]);
			out_rsci_idat_15 <= ~(crc_mux_166_nl | ~fsm_output[2]);
			out_rsci_idat_16 <= ~(crc_mux_165_nl | ~fsm_output[2]);
			out_rsci_idat_17 <= ~(crc_mux_163_nl | ~fsm_output[2]);
			out_rsci_idat_18 <= ~(crc_mux_161_nl | ~fsm_output[2]);
			out_rsci_idat_19 <= ~(crc_mux_159_nl | ~fsm_output[2]);
			out_rsci_idat_20 <= ~(crc_mux_158_nl | ~fsm_output[2]);
			out_rsci_idat_21 <= ~(crc_mux_157_nl | ~fsm_output[2]);
			out_rsci_idat_22 <= ~(crc_mux_155_nl | ~fsm_output[2]);
			out_rsci_idat_23 <= ~(crc_mux_153_nl | ~fsm_output[2]);
			out_rsci_idat_24 <= ~(crc_mux_151_nl | ~fsm_output[2]);
			out_rsci_idat_25 <= ~(crc_mux_149_nl | ~fsm_output[2]);
			out_rsci_idat_26 <= ~(crc_mux_147_nl | ~fsm_output[2]);
			out_rsci_idat_27 <= ~(crc_mux_145_nl | ~fsm_output[2]);
			out_rsci_idat_28 <= ~(crc_mux_143_nl | ~fsm_output[2]);
			out_rsci_idat_29 <= ~(crc_mux_141_nl | ~fsm_output[2]);
			out_rsci_idat_30 <= ~(crc_mux_nl | ~fsm_output[2]);
			out_rsci_idat_31 <= ~(for_for_8_b_xor_tmp | ~fsm_output[2]);
		end
	function automatic [7:0] MUX_v_8_2_2;
		input [7:0] input_0;
		input [7:0] input_1;
		input sel;
		reg [7:0] result;
		begin
			case (sel)
				1'b0: result = input_0;
				default: result = input_1;
			endcase
			MUX_v_8_2_2 = result;
		end
	endfunction
	always @(posedge clk)
		if (rst) begin
			reg_out_rsci_iswt0_cse <= 1'b0;
			reg_in_rsci_iswt0_cse <= 1'b0;
			crc_31_1_sva <= 1'b0;
			crc_0_1_sva <= 1'b0;
			crc_30_1_sva <= 1'b0;
			crc_1_1_sva <= 1'b0;
			crc_29_1_sva <= 1'b0;
			crc_2_1_sva <= 1'b0;
			crc_28_1_sva <= 1'b0;
			crc_3_1_sva <= 1'b0;
			crc_27_1_sva <= 1'b0;
			crc_4_1_sva <= 1'b0;
			crc_26_1_sva <= 1'b0;
			crc_5_1_sva <= 1'b0;
			crc_25_1_sva <= 1'b0;
			crc_6_1_sva <= 1'b0;
			crc_24_1_sva <= 1'b0;
			crc_7_1_sva <= 1'b0;
			crc_23_1_sva <= 1'b0;
			crc_8_1_sva <= 1'b0;
			crc_22_1_sva <= 1'b0;
			crc_9_1_sva <= 1'b0;
			crc_21_1_sva <= 1'b0;
			crc_10_1_sva <= 1'b0;
			crc_20_1_sva <= 1'b0;
			crc_11_1_sva <= 1'b0;
			crc_19_1_sva <= 1'b0;
			crc_12_1_sva <= 1'b0;
			crc_18_1_sva <= 1'b0;
			crc_13_1_sva <= 1'b0;
			crc_17_1_sva <= 1'b0;
			crc_14_1_sva <= 1'b0;
			crc_16_1_sva <= 1'b0;
			crc_15_1_sva <= 1'b0;
			for_i_sva <= 8'b00000000;
		end
		else if (core_wen) begin
			reg_out_rsci_iswt0_cse <= or_tmp_32;
			reg_in_rsci_iswt0_cse <= ~or_tmp_32;
			crc_31_1_sva <= for_for_8_b_xor_tmp | ~fsm_output[2];
			crc_0_1_sva <= crc_5_4_lpi_2_dfm_mx0 | ~fsm_output[2];
			crc_30_1_sva <= crc_mux_167_nl | ~fsm_output[2];
			crc_1_1_sva <= crc_mux_140_cse | ~fsm_output[2];
			crc_29_1_sva <= crc_mux_168_nl | ~fsm_output[2];
			crc_2_1_sva <= crc_mux_169_nl | ~fsm_output[2];
			crc_28_1_sva <= crc_mux_170_nl | ~fsm_output[2];
			crc_3_1_sva <= crc_mux_171_nl | ~fsm_output[2];
			crc_27_1_sva <= crc_mux_172_nl | ~fsm_output[2];
			crc_4_1_sva <= crc_mux_173_nl | ~fsm_output[2];
			crc_26_1_sva <= crc_mux_174_nl | ~fsm_output[2];
			crc_5_1_sva <= crc_mux_175_nl | ~fsm_output[2];
			crc_25_1_sva <= crc_mux_176_nl | ~fsm_output[2];
			crc_6_1_sva <= crc_mux_177_nl | ~fsm_output[2];
			crc_24_1_sva <= crc_mux_178_nl | ~fsm_output[2];
			crc_7_1_sva <= crc_mux_179_nl | ~fsm_output[2];
			crc_23_1_sva <= crc_mux_180_nl | ~fsm_output[2];
			crc_8_1_sva <= crc_mux_181_nl | ~fsm_output[2];
			crc_22_1_sva <= crc_mux_182_nl | ~fsm_output[2];
			crc_9_1_sva <= crc_mux_183_nl | ~fsm_output[2];
			crc_21_1_sva <= crc_mux_184_nl | ~fsm_output[2];
			crc_10_1_sva <= crc_15_4_lpi_2_dfm_mx0 | ~fsm_output[2];
			crc_20_1_sva <= crc_mux_185_nl | ~fsm_output[2];
			crc_11_1_sva <= crc_15_5_lpi_2_dfm_mx0 | ~fsm_output[2];
			crc_19_1_sva <= crc_mux_186_nl | ~fsm_output[2];
			crc_12_1_sva <= crc_mux_187_nl | ~fsm_output[2];
			crc_18_1_sva <= crc_mux_188_nl | ~fsm_output[2];
			crc_13_1_sva <= crc_mux_189_nl | ~fsm_output[2];
			crc_17_1_sva <= crc_mux_190_nl | ~fsm_output[2];
			crc_14_1_sva <= crc_mux_191_nl | ~fsm_output[2];
			crc_16_1_sva <= crc_mux_192_nl | ~fsm_output[2];
			crc_15_1_sva <= crc_mux_193_nl | ~fsm_output[2];
			for_i_sva <= MUX_v_8_2_2(8'b00000000, z_out[7:0], fsm_output[2]);
		end
	always @(posedge clk)
		if (rst)
			size_val_sva <= 8'b00000000;
		else if (core_wen & ~fsm_output[2])
			size_val_sva <= in_rsci_idat_mxwt;
	assign crc_mux_142_nl = MUX_s_1_2_2(~crc_8_3_lpi_2_dfm_mx0, crc_8_3_lpi_2_dfm_mx0, or_tmp_52);
	assign crc_mux_144_nl = MUX_s_1_2_2(~crc_8_4_lpi_2_dfm_mx0, crc_8_4_lpi_2_dfm_mx0, or_tmp_60);
	assign crc_mux_146_nl = MUX_s_1_2_2(~crc_8_5_lpi_2_dfm_mx0, crc_8_5_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_148_nl = MUX_s_1_2_2(~crc_8_6_lpi_2_dfm_mx0, crc_8_6_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_150_nl = MUX_s_1_2_2(~crc_9_6_lpi_2_dfm_mx0, crc_9_6_lpi_2_dfm_mx0, or_tmp_60);
	assign crc_mux_152_nl = MUX_s_1_2_2(~crc_9_7_lpi_2_dfm_mx0, crc_9_7_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_154_nl = MUX_s_1_2_2(~crc_9_lpi_2_dfm_mx0, crc_9_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_156_nl = MUX_s_1_2_2(~crc_15_3_lpi_2_dfm_mx0, crc_15_3_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_160_nl = MUX_s_1_2_2(~crc_19_2_lpi_2_dfm_mx0, crc_19_2_lpi_2_dfm_mx0, or_tmp_52);
	assign crc_mux_162_nl = MUX_s_1_2_2(~crc_19_3_lpi_2_dfm_mx0, crc_19_3_lpi_2_dfm_mx0, or_tmp_60);
	assign crc_mux_164_nl = MUX_s_1_2_2(~crc_19_4_lpi_2_dfm_mx0, crc_19_4_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_166_nl = MUX_s_1_2_2(~crc_19_5_lpi_2_dfm_mx0, crc_19_5_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_165_nl = MUX_s_1_2_2(~crc_20_5_lpi_2_dfm_mx0, crc_20_5_lpi_2_dfm_mx0, or_tmp_52);
	assign crc_mux_163_nl = MUX_s_1_2_2(~crc_20_6_lpi_2_dfm_mx0, crc_20_6_lpi_2_dfm_mx0, or_tmp_60);
	assign crc_mux_161_nl = MUX_s_1_2_2(~crc_20_7_lpi_2_dfm_mx0, crc_20_7_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_159_nl = MUX_s_1_2_2(~crc_20_lpi_2_dfm_mx0, crc_20_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_158_nl = MUX_s_1_2_2(~crc_21_lpi_2_dfm_mx0, crc_21_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_157_nl = MUX_s_1_2_2(~crc_23_7_lpi_2_dfm_mx0, crc_23_7_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_155_nl = MUX_s_1_2_2(~crc_24_7_lpi_2_dfm_mx0, crc_24_7_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_153_nl = MUX_s_1_2_2(~crc_24_lpi_2_dfm_mx0, crc_24_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_151_nl = MUX_s_1_2_2(~crc_26_7_lpi_2_dfm_mx0, crc_26_7_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_149_nl = MUX_s_1_2_2(~crc_27_7_lpi_2_dfm_mx0, crc_27_7_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_147_nl = MUX_s_1_2_2(~crc_27_lpi_2_dfm_mx0, crc_27_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_145_nl = MUX_s_1_2_2(~crc_29_7_lpi_2_dfm_mx0, crc_29_7_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_143_nl = MUX_s_1_2_2(~crc_30_7_lpi_2_dfm_mx0, crc_30_7_lpi_2_dfm_mx0, or_tmp_56);
	assign crc_mux_141_nl = MUX_s_1_2_2(~crc_30_lpi_2_dfm_mx0, crc_30_lpi_2_dfm_mx0, or_tmp_40);
	assign crc_mux_nl = MUX_s_1_2_2(~for_for_7_b_xor_tmp, for_for_7_b_xor_tmp, or_tmp_40);
	assign crc_mux_167_nl = MUX_s_1_2_2(~for_for_7_b_xor_tmp, for_for_7_b_xor_tmp, not_tmp_3);
	assign crc_mux_168_nl = MUX_s_1_2_2(~crc_30_lpi_2_dfm_mx0, crc_30_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_169_nl = MUX_s_1_2_2(~crc_8_3_lpi_2_dfm_mx0, crc_8_3_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_mux_170_nl = MUX_s_1_2_2(~crc_30_7_lpi_2_dfm_mx0, crc_30_7_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_171_nl = MUX_s_1_2_2(~crc_8_4_lpi_2_dfm_mx0, crc_8_4_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_mux_172_nl = MUX_s_1_2_2(~crc_29_7_lpi_2_dfm_mx0, crc_29_7_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_173_nl = MUX_s_1_2_2(~crc_8_5_lpi_2_dfm_mx0, crc_8_5_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_174_nl = MUX_s_1_2_2(~crc_27_lpi_2_dfm_mx0, crc_27_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_175_nl = MUX_s_1_2_2(~crc_8_6_lpi_2_dfm_mx0, crc_8_6_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_176_nl = MUX_s_1_2_2(~crc_27_7_lpi_2_dfm_mx0, crc_27_7_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_177_nl = MUX_s_1_2_2(~crc_9_6_lpi_2_dfm_mx0, crc_9_6_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_mux_178_nl = MUX_s_1_2_2(~crc_26_7_lpi_2_dfm_mx0, crc_26_7_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_179_nl = MUX_s_1_2_2(~crc_9_7_lpi_2_dfm_mx0, crc_9_7_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_180_nl = MUX_s_1_2_2(~crc_24_lpi_2_dfm_mx0, crc_24_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_181_nl = MUX_s_1_2_2(~crc_9_lpi_2_dfm_mx0, crc_9_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_182_nl = MUX_s_1_2_2(~crc_24_7_lpi_2_dfm_mx0, crc_24_7_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_183_nl = MUX_s_1_2_2(~crc_15_3_lpi_2_dfm_mx0, crc_15_3_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_184_nl = MUX_s_1_2_2(~crc_23_7_lpi_2_dfm_mx0, crc_23_7_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_185_nl = MUX_s_1_2_2(~crc_21_lpi_2_dfm_mx0, crc_21_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_186_nl = MUX_s_1_2_2(~crc_20_lpi_2_dfm_mx0, crc_20_lpi_2_dfm_mx0, not_tmp_3);
	assign crc_mux_187_nl = MUX_s_1_2_2(~crc_19_2_lpi_2_dfm_mx0, crc_19_2_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_mux_188_nl = MUX_s_1_2_2(~crc_20_7_lpi_2_dfm_mx0, crc_20_7_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_189_nl = MUX_s_1_2_2(~crc_19_3_lpi_2_dfm_mx0, crc_19_3_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_mux_190_nl = MUX_s_1_2_2(~crc_20_6_lpi_2_dfm_mx0, crc_20_6_lpi_2_dfm_mx0, not_tmp_7);
	assign crc_mux_191_nl = MUX_s_1_2_2(~crc_19_4_lpi_2_dfm_mx0, crc_19_4_lpi_2_dfm_mx0, not_tmp_6);
	assign crc_mux_192_nl = MUX_s_1_2_2(~crc_20_5_lpi_2_dfm_mx0, crc_20_5_lpi_2_dfm_mx0, not_tmp_5);
	assign crc_mux_193_nl = MUX_s_1_2_2(~crc_19_5_lpi_2_dfm_mx0, crc_19_5_lpi_2_dfm_mx0, not_tmp_3);
	assign for_mux_2_nl = MUX_v_8_2_2(~in_rsci_idat_mxwt, for_i_sva, fsm_output[2]);
	function automatic [8:0] conv_s2u_8_9;
		input [7:0] vector;
		conv_s2u_8_9 = {vector[7], vector};
	endfunction
	assign nl_z_out = conv_s2u_8_9(for_mux_2_nl) + 9'b000000001;
	assign z_out = nl_z_out[8:0];
endmodule
module crc32 (
	clk,
	rst,
	in_rsc_dat,
	in_rsc_vld,
	in_rsc_rdy,
	out_rsc_dat,
	out_rsc_vld,
	out_rsc_rdy
);
	input clk;
	input rst;
	input [7:0] in_rsc_dat;
	input in_rsc_vld;
	output wire in_rsc_rdy;
	output wire [31:0] out_rsc_dat;
	output wire out_rsc_vld;
	input out_rsc_rdy;
	crc32_core crc32_core_inst(
		.clk(clk),
		.rst(rst),
		.in_rsc_dat(in_rsc_dat),
		.in_rsc_vld(in_rsc_vld),
		.in_rsc_rdy(in_rsc_rdy),
		.out_rsc_dat(out_rsc_dat),
		.out_rsc_vld(out_rsc_vld),
		.out_rsc_rdy(out_rsc_rdy)
	);
endmodule
module tapeout_SPI_TapeOutBlockVRTL (
	clk,
	reset,
	loopthrough_sel,
	minion_parity,
	adapter_parity,
	spi_min_sclk,
	spi_min_cs,
	spi_min_mosi,
	spi_min_miso
);
	parameter nbits = 32;
	parameter num_entries = 5;
	input wire clk;
	input wire reset;
	input wire loopthrough_sel;
	output wire minion_parity;
	output wire adapter_parity;
	input wire spi_min_sclk;
	input wire spi_min_cs;
	input wire spi_min_mosi;
	output wire spi_min_miso;
	reg reset_presync;
	reg reset_sync;
	always @(posedge clk) begin
		reset_presync <= reset;
		reset_sync <= reset_presync;
	end
	wire in_rsc_vld;
	wire [31:0] in_rsc_dat;
	wire in_rsc_rdy;
	wire out_rsc_vld;
	wire [31:0] out_rsc_dat;
	wire out_rsc_rdy;
	SPI_v3_components_SPIstackVRTL #(
		.nbits(nbits),
		.num_entries(num_entries)
	) SPIstack(
		.clk(clk),
		.reset(reset_sync),
		.loopthrough_sel(loopthrough_sel),
		.minion_parity(minion_parity),
		.adapter_parity(adapter_parity),
		.sclk(spi_min_sclk),
		.cs(spi_min_cs),
		.mosi(spi_min_mosi),
		.miso(spi_min_miso),
		.recv_val(out_rsc_vld),
		.recv_msg(out_rsc_dat),
		.recv_rdy(out_rsc_rdy),
		.send_val(in_rsc_vld),
		.send_msg(in_rsc_dat),
		.send_rdy(in_rsc_rdy)
	);
	wire [7:0] truncated_in_rsc_dat;
	assign truncated_in_rsc_dat = in_rsc_dat[7:0];
	crc32 crc32_inst(
		.clk(clk),
		.rst(reset_sync),
		.in_rsc_dat(truncated_in_rsc_dat),
		.in_rsc_vld(in_rsc_vld),
		.in_rsc_rdy(in_rsc_rdy),
		.out_rsc_dat(out_rsc_dat),
		.out_rsc_vld(out_rsc_vld),
		.out_rsc_rdy(out_rsc_rdy)
	);
endmodule
module tapeout_SPI_TapeOutBlockVRTL_sv2v (
  output adapter_parity,
  input  clk,
  input  loopthrough_sel,
  output minion_parity,
  input  reset,
  input  spi_min_cs,
  output spi_min_miso,
  input  spi_min_mosi,
  input  spi_min_sclk
);
	tapeout_SPI_TapeOutBlockVRTL #(
		.nbits(34),
		.num_entries(5)
	) v(
		.adapter_parity(adapter_parity),
		.clk(clk),
		.loopthrough_sel(loopthrough_sel),
		.minion_parity(minion_parity),
		.reset(reset),
		.spi_min_cs(spi_min_cs),
		.spi_min_miso(spi_min_miso),
		.spi_min_mosi(spi_min_mosi),
		.spi_min_sclk(spi_min_sclk)
	);
endmodule
