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
module tapeout_BlockPlaceholderVRTL (
	send_val,
	send_msg,
	send_rdy,
	recv_val,
	recv_msg,
	recv_rdy
);
	parameter nbits = 32;
	output wire send_val;
	output wire [nbits - 1:0] send_msg;
	input wire send_rdy;
	input wire recv_val;
	input wire [nbits - 1:0] recv_msg;
	output wire recv_rdy;
	assign send_val = recv_val;
	assign send_msg = recv_msg;
	assign recv_rdy = send_rdy;
endmodule
module vc_Adder (
	in0,
	in1,
	cin,
	out,
	cout
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire cin;
	output wire [p_nbits - 1:0] out;
	output wire cout;
	assign {cout, out} = (in0 + in1) + {{p_nbits - 1 {1'b0}}, cin};
endmodule
module vc_SimpleAdder (
	in0,
	in1,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	output wire [p_nbits - 1:0] out;
	assign out = in0 + in1;
endmodule
module vc_Subtractor (
	in0,
	in1,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	output wire [p_nbits - 1:0] out;
	assign out = in0 - in1;
endmodule
module vc_Incrementer (
	in,
	out
);
	parameter p_nbits = 1;
	parameter p_inc_value = 1;
	input wire [p_nbits - 1:0] in;
	output wire [p_nbits - 1:0] out;
	assign out = in + p_inc_value;
endmodule
module vc_ZeroExtender (
	in,
	out
);
	parameter p_in_nbits = 1;
	parameter p_out_nbits = 8;
	input wire [p_in_nbits - 1:0] in;
	output wire [p_out_nbits - 1:0] out;
	assign out = {{p_out_nbits - p_in_nbits {1'b0}}, in};
endmodule
module vc_SignExtender (
	in,
	out
);
	parameter p_in_nbits = 1;
	parameter p_out_nbits = 8;
	input wire [p_in_nbits - 1:0] in;
	output wire [p_out_nbits - 1:0] out;
	assign out = {{p_out_nbits - p_in_nbits {in[p_in_nbits - 1]}}, in};
endmodule
module vc_ZeroComparator (
	in,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in;
	output wire out;
	assign out = in == {p_nbits {1'b0}};
endmodule
module vc_EqComparator (
	in0,
	in1,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	output wire out;
	assign out = in0 == in1;
endmodule
module vc_LtComparator (
	in0,
	in1,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	output wire out;
	assign out = in0 < in1;
endmodule
module vc_GtComparator (
	in0,
	in1,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	output wire out;
	assign out = in0 > in1;
endmodule
module vc_LeftLogicalShifter (
	in,
	shamt,
	out
);
	parameter p_nbits = 1;
	parameter p_shamt_nbits = 1;
	input wire [p_nbits - 1:0] in;
	input wire [p_shamt_nbits - 1:0] shamt;
	output wire [p_nbits - 1:0] out;
	assign out = in << shamt;
endmodule
module vc_RightLogicalShifter (
	in,
	shamt,
	out
);
	parameter p_nbits = 1;
	parameter p_shamt_nbits = 1;
	input wire [p_nbits - 1:0] in;
	input wire [p_shamt_nbits - 1:0] shamt;
	output wire [p_nbits - 1:0] out;
	assign out = in >> shamt;
endmodule
module tut4_verilog_gcd_GcdUnitDpath (
	clk,
	reset,
	recv_msg,
	send_msg,
	a_reg_en,
	b_reg_en,
	a_mux_sel,
	b_mux_sel,
	is_b_zero,
	is_a_lt_b
);
	input wire clk;
	input wire reset;
	input wire [31:0] recv_msg;
	output wire [15:0] send_msg;
	input wire a_reg_en;
	input wire b_reg_en;
	input wire [1:0] a_mux_sel;
	input wire b_mux_sel;
	output wire is_b_zero;
	output wire is_a_lt_b;
	localparam c_nbits = 16;
	wire [15:0] recv_msg_a;
	assign recv_msg_a = recv_msg[31:16];
	wire [15:0] recv_msg_b;
	assign recv_msg_b = recv_msg[15:0];
	wire [15:0] b_reg_out;
	wire [15:0] sub_out;
	wire [15:0] a_mux_out;
	vc_Mux3 #(.p_nbits(c_nbits)) a_mux(
		.sel(a_mux_sel),
		.in0(recv_msg_a),
		.in1(b_reg_out),
		.in2(sub_out),
		.out(a_mux_out)
	);
	wire [15:0] a_reg_out;
	vc_EnReg #(.p_nbits(c_nbits)) a_reg(
		.clk(clk),
		.reset(reset),
		.en(a_reg_en),
		.d(a_mux_out),
		.q(a_reg_out)
	);
	wire [15:0] b_mux_out;
	vc_Mux2 #(.p_nbits(c_nbits)) b_mux(
		.sel(b_mux_sel),
		.in0(recv_msg_b),
		.in1(a_reg_out),
		.out(b_mux_out)
	);
	vc_EnReg #(.p_nbits(c_nbits)) b_reg(
		.clk(clk),
		.reset(reset),
		.en(b_reg_en),
		.d(b_mux_out),
		.q(b_reg_out)
	);
	vc_LtComparator #(.p_nbits(c_nbits)) a_lt_b(
		.in0(a_reg_out),
		.in1(b_reg_out),
		.out(is_a_lt_b)
	);
	vc_ZeroComparator #(.p_nbits(c_nbits)) b_zero(
		.in(b_reg_out),
		.out(is_b_zero)
	);
	vc_Subtractor #(.p_nbits(c_nbits)) sub(
		.in0(a_reg_out),
		.in1(b_reg_out),
		.out(sub_out)
	);
	assign send_msg = sub_out;
endmodule
module tut4_verilog_gcd_GcdUnitCtrl (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	a_reg_en,
	b_reg_en,
	a_mux_sel,
	b_mux_sel,
	is_b_zero,
	is_a_lt_b
);
	input wire clk;
	input wire reset;
	input wire recv_val;
	output reg recv_rdy;
	output reg send_val;
	input wire send_rdy;
	output reg a_reg_en;
	output reg b_reg_en;
	output reg [1:0] a_mux_sel;
	output reg b_mux_sel;
	input wire is_b_zero;
	input wire is_a_lt_b;
	localparam STATE_IDLE = 2'd0;
	localparam STATE_CALC = 2'd1;
	localparam STATE_DONE = 2'd2;
	reg [1:0] state_reg;
	reg [1:0] state_next;
	always @(posedge clk)
		if (reset)
			state_reg <= STATE_IDLE;
		else
			state_reg <= state_next;
	wire req_go;
	wire resp_go;
	wire is_calc_done;
	assign req_go = recv_val && recv_rdy;
	assign resp_go = send_val && send_rdy;
	assign is_calc_done = !is_a_lt_b && is_b_zero;
	always @(*) begin
		state_next = state_reg;
		case (state_reg)
			STATE_IDLE:
				if (req_go)
					state_next = STATE_CALC;
			STATE_CALC:
				if (is_calc_done)
					state_next = STATE_DONE;
			STATE_DONE:
				if (resp_go)
					state_next = STATE_IDLE;
			default: state_next = 1'sbx;
		endcase
	end
	localparam a_x = 2'bxx;
	localparam a_ld = 2'd0;
	localparam a_b = 2'd1;
	localparam a_sub = 2'd2;
	localparam b_x = 1'bx;
	localparam b_ld = 1'd0;
	localparam b_a = 1'd1;
	task cs;
		input reg cs_recv_rdy;
		input reg cs_send_val;
		input reg [1:0] cs_a_mux_sel;
		input reg cs_a_reg_en;
		input reg cs_b_mux_sel;
		input reg cs_b_reg_en;
		begin
			recv_rdy = cs_recv_rdy;
			send_val = cs_send_val;
			a_reg_en = cs_a_reg_en;
			b_reg_en = cs_b_reg_en;
			a_mux_sel = cs_a_mux_sel;
			b_mux_sel = cs_b_mux_sel;
		end
	endtask
	wire do_swap;
	wire do_sub;
	assign do_swap = is_a_lt_b;
	assign do_sub = !is_b_zero;
	always @(*) begin
		cs(0, 0, a_x, 0, b_x, 0);
		case (state_reg)
			STATE_IDLE:
				cs(1, 0, a_ld, 1, b_ld, 1);
			STATE_CALC:
				if (do_swap)
					cs(0, 0, a_b, 1, b_a, 1);
				else if (do_sub)
					cs(0, 0, a_sub, 1, b_x, 0);
			STATE_DONE:
				cs(0, 1, a_x, 0, b_x, 0);
			default:
				cs(1'sbx, 1'sbx, a_x, 1'sbx, b_x, 1'sbx);
		endcase
	end
endmodule
module tut4_verilog_gcd_GcdUnitRTL (
	clk,
	reset,
	recv_val,
	recv_rdy,
	recv_msg,
	send_val,
	send_rdy,
	send_msg
);
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	input wire [31:0] recv_msg;
	output wire send_val;
	input wire send_rdy;
	output wire [15:0] send_msg;
	wire a_reg_en;
	wire b_reg_en;
	wire [1:0] a_mux_sel;
	wire b_mux_sel;
	wire is_b_zero;
	wire is_a_lt_b;
	tut4_verilog_gcd_GcdUnitCtrl ctrl(
		.clk(clk),
		.reset(reset),
		.recv_val(recv_val),
		.recv_rdy(recv_rdy),
		.send_val(send_val),
		.send_rdy(send_rdy),
		.a_reg_en(a_reg_en),
		.b_reg_en(b_reg_en),
		.a_mux_sel(a_mux_sel),
		.b_mux_sel(b_mux_sel),
		.is_b_zero(is_b_zero),
		.is_a_lt_b(is_a_lt_b)
	);
	tut4_verilog_gcd_GcdUnitDpath dpath(
		.clk(clk),
		.reset(reset),
		.recv_msg(recv_msg),
		.send_msg(send_msg),
		.a_reg_en(a_reg_en),
		.b_reg_en(b_reg_en),
		.a_mux_sel(a_mux_sel),
		.b_mux_sel(b_mux_sel),
		.is_b_zero(is_b_zero),
		.is_a_lt_b(is_a_lt_b)
	);
	wire [4095:0] str;
	// vc_Trace vc_trace(
	// 	.clk(clk),
	// 	.reset(reset)
	// );
	// task line_trace;
	// 	output reg [4095:0] trace_str;
	// 	begin
	// 		$sformat(str, "%x:%x", recv_msg[31:16], recv_msg[15:0]);
	// 		vc_trace.append_val_rdy_str(trace_str, recv_val, recv_rdy, str);
	// 		vc_trace.append_str(trace_str, "(");
	// 		$sformat(str, "%x", dpath.a_reg_out);
	// 		vc_trace.append_str(trace_str, str);
	// 		vc_trace.append_str(trace_str, " ");
	// 		$sformat(str, "%x", dpath.b_reg_out);
	// 		vc_trace.append_str(trace_str, str);
	// 		vc_trace.append_str(trace_str, " ");
	// 		case (ctrl.state_reg)
	// 			ctrl.STATE_IDLE:
	// 				vc_trace.append_str(trace_str, "I ");
	// 			ctrl.STATE_CALC:
	// 				if (ctrl.do_swap)
	// 					vc_trace.append_str(trace_str, "Cs");
	// 				else if (ctrl.do_sub)
	// 					vc_trace.append_str(trace_str, "C-");
	// 				else
	// 					vc_trace.append_str(trace_str, "C ");
	// 			ctrl.STATE_DONE:
	// 				vc_trace.append_str(trace_str, "D ");
	// 			default:
	// 				vc_trace.append_str(trace_str, "? ");
	// 		endcase
	// 		vc_trace.append_str(trace_str, ")");
	// 		$sformat(str, "%x", send_msg);
	// 		vc_trace.append_val_rdy_str(trace_str, send_val, send_rdy, str);
	// 	end
	// endtask
	// task display_trace;
	// 	begin
	// 		if (vc_trace.level > 0) begin
	// 			vc_trace.storage[15:0] = vc_trace.nchars - 1;
	// 			line_trace(vc_trace.storage);
	// 			$write("%4d: ", vc_trace.cycles);
	// 			vc_trace.idx0 = vc_trace.storage[15:0];
	// 			for (vc_trace.idx1 = vc_trace.nchars - 1; vc_trace.idx1 > vc_trace.idx0; vc_trace.idx1 = vc_trace.idx1 - 1)
	// 				$write("%s", vc_trace.storage[vc_trace.idx1 * 8+:8]);
	// 			$write("\n");
	// 		end
	// 		vc_trace.cycles_next = vc_trace.cycles + 1;
	// 	end
	// endtask
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
	parameter nbits = 34;
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
	parameter packet_nbits = nbits - 2;
	parameter gcd_msg_size = packet_nbits / 2;
	wire send_val;
	wire [packet_nbits - 1:0] send_msg;
	wire send_rdy;
	wire recv_val;
	reg [packet_nbits - 1:0] recv_msg;
	wire [gcd_msg_size - 1:0] gcd_msg;
	wire recv_rdy;
	reg reset_presync;
	reg reset_sync;
	always @(posedge clk) begin
		reset_presync <= reset;
		reset_sync <= reset_presync;
	end
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
		.send_val(send_val),
		.send_msg(send_msg),
		.send_rdy(send_rdy),
		.recv_val(recv_val),
		.recv_msg(recv_msg),
		.recv_rdy(recv_rdy)
	);
	always @(*) recv_msg = {{gcd_msg_size {gcd_msg[gcd_msg_size - 1]}}, gcd_msg};
	tut4_verilog_gcd_GcdUnitRTL GCD(
		.clk(clk),
		.reset(reset_sync),
		.recv_val(send_val),
		.recv_rdy(send_rdy),
		.recv_msg(send_msg),
		.send_val(recv_val),
		.send_rdy(recv_rdy),
		.send_msg(gcd_msg)
	);
endmodule
module tapeout_SPI_TapeOutBlockVRTL_sv2v (
	output adapter_parity,
	input clk,
	input loopthrough_sel,
	output minion_parity,
	input reset,
	input spi_min_cs,
	output spi_min_miso,
	input spi_min_mosi,
	input spi_min_sclk
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