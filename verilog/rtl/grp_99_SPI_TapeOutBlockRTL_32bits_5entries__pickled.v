module BlockPlaceholderPRTL__nbits_32 (
	clk,
	reset,
	recv__msg,
	recv__rdy,
	recv__val,
	send__msg,
	send__rdy,
	send__val
);
	input wire [0:0] clk;
	input wire [0:0] reset;
	input wire [31:0] recv__msg;
	output wire [0:0] recv__rdy;
	input wire [0:0] recv__val;
	output wire [31:0] send__msg;
	input wire [0:0] send__rdy;
	output wire [0:0] send__val;
	assign send__msg = recv__msg;
	assign recv__rdy = send__rdy;
	assign send__val = recv__val;
endmodule
module LoopThroughPRTL__nbits_32 (
	clk,
	reset,
	sel,
	downstream__req__msg,
	downstream__req__rdy,
	downstream__req__val,
	downstream__resp__msg,
	downstream__resp__rdy,
	downstream__resp__val,
	upstream__req__msg,
	upstream__req__rdy,
	upstream__req__val,
	upstream__resp__msg,
	upstream__resp__rdy,
	upstream__resp__val
);
	input wire [0:0] clk;
	input wire [0:0] reset;
	input wire [0:0] sel;
	output wire [31:0] downstream__req__msg;
	input wire [0:0] downstream__req__rdy;
	output reg [0:0] downstream__req__val;
	input wire [31:0] downstream__resp__msg;
	output reg [0:0] downstream__resp__rdy;
	input wire [0:0] downstream__resp__val;
	input wire [31:0] upstream__req__msg;
	output reg [0:0] upstream__req__rdy;
	input wire [0:0] upstream__req__val;
	output reg [31:0] upstream__resp__msg;
	input wire [0:0] upstream__resp__rdy;
	output reg [0:0] upstream__resp__val;
	always @(*) begin : _lambda__s_spi_min_stack_loopthrough_downstream_req_val
		downstream__req__val = (sel ? 1'd0 : upstream__req__val);
	end
	always @(*) begin : _lambda__s_spi_min_stack_loopthrough_downstream_resp_rdy
		downstream__resp__rdy = (sel ? 1'd0 : upstream__resp__rdy);
	end
	always @(*) begin : _lambda__s_spi_min_stack_loopthrough_upstream_req_rdy
		upstream__req__rdy = (sel ? upstream__resp__rdy : downstream__req__rdy);
	end
	always @(*) begin : _lambda__s_spi_min_stack_loopthrough_upstream_resp_msg
		upstream__resp__msg = (sel ? upstream__req__msg : downstream__resp__msg);
	end
	always @(*) begin : _lambda__s_spi_min_stack_loopthrough_upstream_resp_val
		upstream__resp__val = (sel ? upstream__req__val : downstream__resp__val);
	end
	assign downstream__req__msg = upstream__req__msg;
endmodule
module NormalQueueCtrlRTL__num_entries_5 (
	clk,
	count,
	raddr,
	recv_rdy,
	recv_val,
	reset,
	send_rdy,
	send_val,
	waddr,
	wen
);
	input wire [0:0] clk;
	output reg [2:0] count;
	output wire [2:0] raddr;
	output reg [0:0] recv_rdy;
	input wire [0:0] recv_val;
	input wire [0:0] reset;
	input wire [0:0] send_rdy;
	output reg [0:0] send_val;
	output wire [2:0] waddr;
	output wire [0:0] wen;
	localparam [2:0] __const__num_entries_at__lambda__s_spi_min_stack_minion_adapter_cm_q_ctrl_recv_rdy = 3'd5;
	localparam [2:0] __const__num_entries_at_up_reg = 3'd5;
	reg [2:0] head;
	reg [0:0] recv_xfer;
	reg [0:0] send_xfer;
	reg [2:0] tail;
	always @(*) begin : _lambda__s_spi_min_stack_minion_adapter_cm_q_ctrl_recv_rdy
		recv_rdy = count < __const__num_entries_at__lambda__s_spi_min_stack_minion_adapter_cm_q_ctrl_recv_rdy;
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_adapter_cm_q_ctrl_recv_xfer
		recv_xfer = recv_val & recv_rdy;
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_adapter_cm_q_ctrl_send_val
		send_val = count > 3'd0;
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_adapter_cm_q_ctrl_send_xfer
		send_xfer = send_val & send_rdy;
	end
	always @(posedge clk) begin : up_reg
		if (reset) begin
			head <= 3'd0;
			tail <= 3'd0;
			count <= 3'd0;
		end
		else begin
			if (recv_xfer)
				tail <= (tail < (__const__num_entries_at_up_reg - 3'd1) ? tail + 3'd1 : 3'd0);
			if (send_xfer)
				head <= (head < (__const__num_entries_at_up_reg - 3'd1) ? head + 3'd1 : 3'd0);
			if (recv_xfer & ~send_xfer)
				count <= count + 3'd1;
			else if (~recv_xfer & send_xfer)
				count <= count - 3'd1;
		end
	end
	assign wen = recv_xfer;
	assign waddr = tail;
	assign raddr = head;
endmodule
module RegisterFile__35272b4450df532b (
	clk,
	raddr,
	rdata,
	reset,
	waddr,
	wdata,
	wen
);
	input wire [0:0] clk;
	input wire [2:0] raddr;
	output reg [31:0] rdata;
	input wire [0:0] reset;
	input wire [2:0] waddr;
	input wire [31:0] wdata;
	input wire [0:0] wen;
	localparam [0:0] __const__rd_ports_at_up_rf_read = 1'd1;
	localparam [0:0] __const__wr_ports_at_up_rf_write = 1'd1;
	reg [31:0] regs [0:4];
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	always @(*) begin : up_rf_read
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 1'd0; i < __const__rd_ports_at_up_rf_read; i = i + 1'd1)
				rdata[sv2v_cast_1(i) * 32+:32] = regs[raddr[sv2v_cast_1(i) * 3+:3]];
		end
	end
	always @(posedge clk) begin : up_rf_write
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 1'd0; i < __const__wr_ports_at_up_rf_write; i = i + 1'd1)
				if (wen[sv2v_cast_1(i)+:1])
					regs[waddr[sv2v_cast_1(i) * 3+:3]] <= wdata[sv2v_cast_1(i) * 32+:32];
		end
	end
endmodule
module NormalQueueDpathRTL__EntryType_Bits32__num_entries_5 (
	clk,
	raddr,
	recv_msg,
	reset,
	send_msg,
	waddr,
	wen
);
	input wire [0:0] clk;
	input wire [2:0] raddr;
	input wire [31:0] recv_msg;
	input wire [0:0] reset;
	output wire [31:0] send_msg;
	input wire [2:0] waddr;
	input wire [0:0] wen;
	wire [0:0] rf__clk;
	wire [2:0] rf__raddr;
	wire [31:0] rf__rdata;
	wire [0:0] rf__reset;
	wire [2:0] rf__waddr;
	wire [31:0] rf__wdata;
	wire [0:0] rf__wen;
	RegisterFile__35272b4450df532b rf(
		.clk(rf__clk),
		.raddr(rf__raddr),
		.rdata(rf__rdata),
		.reset(rf__reset),
		.waddr(rf__waddr),
		.wdata(rf__wdata),
		.wen(rf__wen)
	);
	assign rf__clk = clk;
	assign rf__reset = reset;
	assign rf__raddr[0+:3] = raddr;
	assign send_msg = rf__rdata[0+:32];
	assign rf__wen[0+:1] = wen;
	assign rf__waddr[0+:3] = waddr;
	assign rf__wdata[0+:32] = recv_msg;
endmodule
module NormalQueueRTL__EntryType_Bits32__num_entries_5 (
	clk,
	count,
	reset,
	recv__msg,
	recv__rdy,
	recv__val,
	send__msg,
	send__rdy,
	send__val
);
	input wire [0:0] clk;
	output wire [2:0] count;
	input wire [0:0] reset;
	input wire [31:0] recv__msg;
	output wire [0:0] recv__rdy;
	input wire [0:0] recv__val;
	output wire [31:0] send__msg;
	input wire [0:0] send__rdy;
	output wire [0:0] send__val;
	wire [0:0] ctrl__clk;
	wire [2:0] ctrl__count;
	wire [2:0] ctrl__raddr;
	wire [0:0] ctrl__recv_rdy;
	wire [0:0] ctrl__recv_val;
	wire [0:0] ctrl__reset;
	wire [0:0] ctrl__send_rdy;
	wire [0:0] ctrl__send_val;
	wire [2:0] ctrl__waddr;
	wire [0:0] ctrl__wen;
	NormalQueueCtrlRTL__num_entries_5 ctrl(
		.clk(ctrl__clk),
		.count(ctrl__count),
		.raddr(ctrl__raddr),
		.recv_rdy(ctrl__recv_rdy),
		.recv_val(ctrl__recv_val),
		.reset(ctrl__reset),
		.send_rdy(ctrl__send_rdy),
		.send_val(ctrl__send_val),
		.waddr(ctrl__waddr),
		.wen(ctrl__wen)
	);
	wire [0:0] dpath__clk;
	wire [2:0] dpath__raddr;
	wire [31:0] dpath__recv_msg;
	wire [0:0] dpath__reset;
	wire [31:0] dpath__send_msg;
	wire [2:0] dpath__waddr;
	wire [0:0] dpath__wen;
	NormalQueueDpathRTL__EntryType_Bits32__num_entries_5 dpath(
		.clk(dpath__clk),
		.raddr(dpath__raddr),
		.recv_msg(dpath__recv_msg),
		.reset(dpath__reset),
		.send_msg(dpath__send_msg),
		.waddr(dpath__waddr),
		.wen(dpath__wen)
	);
	assign ctrl__clk = clk;
	assign ctrl__reset = reset;
	assign dpath__clk = clk;
	assign dpath__reset = reset;
	assign dpath__wen = ctrl__wen;
	assign dpath__waddr = ctrl__waddr;
	assign dpath__raddr = ctrl__raddr;
	assign ctrl__recv_val = recv__val;
	assign recv__rdy = ctrl__recv_rdy;
	assign dpath__recv_msg = recv__msg;
	assign send__val = ctrl__send_val;
	assign ctrl__send_rdy = send__rdy;
	assign send__msg = dpath__send_msg;
	assign count = ctrl__count;
endmodule
module SPIMinionAdapterPRTL__nbits_34__num_entries_5 (
	clk,
	parity,
	reset,
	pull__en,
	pull__msg,
	push__en,
	push__msg,
	recv__msg,
	recv__rdy,
	recv__val,
	send__msg,
	send__rdy,
	send__val
);
	input wire [0:0] clk;
	output reg [0:0] parity;
	input wire [0:0] reset;
	input wire [0:0] pull__en;
	output reg [33:0] pull__msg;
	input wire [0:0] push__en;
	input wire [33:0] push__msg;
	input wire [31:0] recv__msg;
	output wire [0:0] recv__rdy;
	input wire [0:0] recv__val;
	output wire [31:0] send__msg;
	input wire [0:0] send__rdy;
	output wire [0:0] send__val;
	localparam [2:0] __const__num_entries_at_comb_block = 3'd5;
	reg [0:0] cm_send_rdy;
	reg [0:0] mc_recv_val;
	reg [0:0] open_entries;
	wire [0:0] cm_q__clk;
	wire [2:0] cm_q__count;
	wire [0:0] cm_q__reset;
	wire [31:0] cm_q__recv__msg;
	wire [0:0] cm_q__recv__rdy;
	wire [0:0] cm_q__recv__val;
	wire [31:0] cm_q__send__msg;
	wire [0:0] cm_q__send__rdy;
	wire [0:0] cm_q__send__val;
	NormalQueueRTL__EntryType_Bits32__num_entries_5 cm_q(
		.clk(cm_q__clk),
		.count(cm_q__count),
		.reset(cm_q__reset),
		.recv__msg(cm_q__recv__msg),
		.recv__rdy(cm_q__recv__rdy),
		.recv__val(cm_q__recv__val),
		.send__msg(cm_q__send__msg),
		.send__rdy(cm_q__send__rdy),
		.send__val(cm_q__send__val)
	);
	wire [0:0] mc_q__clk;
	wire [2:0] mc_q__count;
	wire [0:0] mc_q__reset;
	wire [31:0] mc_q__recv__msg;
	wire [0:0] mc_q__recv__rdy;
	wire [0:0] mc_q__recv__val;
	wire [31:0] mc_q__send__msg;
	wire [0:0] mc_q__send__rdy;
	wire [0:0] mc_q__send__val;
	NormalQueueRTL__EntryType_Bits32__num_entries_5 mc_q(
		.clk(mc_q__clk),
		.count(mc_q__count),
		.reset(mc_q__reset),
		.recv__msg(mc_q__recv__msg),
		.recv__rdy(mc_q__recv__rdy),
		.recv__val(mc_q__recv__val),
		.send__msg(mc_q__send__msg),
		.send__rdy(mc_q__send__rdy),
		.send__val(mc_q__send__val)
	);
	always @(*) begin : _lambda__s_spi_min_stack_minion_adapter_parity
		parity = ^send__msg & send__val;
	end
	always @(*) begin : comb_block
		open_entries = mc_q__count < (__const__num_entries_at_comb_block - 3'd1);
		mc_recv_val = push__msg[33] & push__en;
		pull__msg[32] = mc_q__recv__rdy & (~mc_q__recv__val | open_entries);
		cm_send_rdy = push__msg[32] & pull__en;
		pull__msg[33] = cm_send_rdy & cm_q__send__val;
		pull__msg[31-:32] = cm_q__send__msg & {{31 {pull__msg[33]}}, pull__msg[33]};
	end
	assign mc_q__clk = clk;
	assign mc_q__reset = reset;
	assign send__val = mc_q__send__val;
	assign send__msg = mc_q__send__msg;
	assign mc_q__send__rdy = send__rdy;
	assign mc_q__recv__val = mc_recv_val;
	assign mc_q__recv__msg = push__msg[31-:32];
	assign cm_q__clk = clk;
	assign cm_q__reset = reset;
	assign cm_q__recv__val = recv__val;
	assign recv__rdy = cm_q__recv__rdy;
	assign cm_q__recv__msg = recv__msg;
	assign cm_q__send__rdy = cm_send_rdy;
endmodule
module Synchronizer__reset_value_1 (
	clk,
	in_,
	negedge_,
	out,
	posedge_,
	reset
);
	input wire [0:0] clk;
	input wire [0:0] in_;
	output reg [0:0] negedge_;
	output wire [0:0] out;
	output reg [0:0] posedge_;
	input wire [0:0] reset;
	reg [2:0] shreg;
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_cs_sync_negedge_
		negedge_ = shreg[2'd2] & ~shreg[2'd1];
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_cs_sync_posedge_
		posedge_ = ~shreg[2'd2] & shreg[2'd1];
	end
	always @(posedge clk) begin : up_shreg
		if (reset)
			shreg <= 3'h7;
		else
			shreg <= {shreg[2'd1:2'd0], in_};
	end
	assign out = shreg[1:1];
endmodule
module Synchronizer__reset_value_0 (
	clk,
	in_,
	negedge_,
	out,
	posedge_,
	reset
);
	input wire [0:0] clk;
	input wire [0:0] in_;
	output reg [0:0] negedge_;
	output wire [0:0] out;
	output reg [0:0] posedge_;
	input wire [0:0] reset;
	reg [2:0] shreg;
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_mosi_sync_negedge_
		negedge_ = shreg[2'd2] & ~shreg[2'd1];
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_mosi_sync_posedge_
		posedge_ = ~shreg[2'd2] & shreg[2'd1];
	end
	always @(posedge clk) begin : up_shreg
		if (reset)
			shreg <= 3'h0;
		else
			shreg <= {shreg[2'd1:2'd0], in_};
	end
	assign out = shreg[1:1];
endmodule
module ShiftReg__nbits_34 (
	clk,
	in_,
	load_data,
	load_en,
	out,
	reset,
	shift_en
);
	input wire [0:0] clk;
	input wire [0:0] in_;
	input wire [33:0] load_data;
	input wire [0:0] load_en;
	output reg [33:0] out;
	input wire [0:0] reset;
	input wire [0:0] shift_en;
	always @(posedge clk) begin : up_shreg
		if (reset)
			out <= {{33 {1'b0}}, 1'd0};
		else if (load_en)
			out <= load_data;
		else if (~load_en & shift_en)
			out <= {out[6'd32:6'd0], in_};
	end
endmodule
module SPIMinionPRTL__nbits_34 (
	clk,
	parity,
	reset,
	pull__en,
	pull__msg,
	push__en,
	push__msg,
	spi_min__cs,
	spi_min__miso,
	spi_min__mosi,
	spi_min__sclk
);
	input wire [0:0] clk;
	output reg [0:0] parity;
	input wire [0:0] reset;
	output wire [0:0] pull__en;
	input wire [33:0] pull__msg;
	output wire [0:0] push__en;
	output wire [33:0] push__msg;
	input wire [0:0] spi_min__cs;
	output wire [0:0] spi_min__miso;
	input wire [0:0] spi_min__mosi;
	input wire [0:0] spi_min__sclk;
	wire [0:0] cs_sync__clk;
	wire [0:0] cs_sync__in_;
	wire [0:0] cs_sync__negedge_;
	wire [0:0] cs_sync__out;
	wire [0:0] cs_sync__posedge_;
	wire [0:0] cs_sync__reset;
	Synchronizer__reset_value_1 cs_sync(
		.clk(cs_sync__clk),
		.in_(cs_sync__in_),
		.negedge_(cs_sync__negedge_),
		.out(cs_sync__out),
		.posedge_(cs_sync__posedge_),
		.reset(cs_sync__reset)
	);
	wire [0:0] mosi_sync__clk;
	wire [0:0] mosi_sync__in_;
	wire [0:0] mosi_sync__negedge_;
	wire [0:0] mosi_sync__out;
	wire [0:0] mosi_sync__posedge_;
	wire [0:0] mosi_sync__reset;
	Synchronizer__reset_value_0 mosi_sync(
		.clk(mosi_sync__clk),
		.in_(mosi_sync__in_),
		.negedge_(mosi_sync__negedge_),
		.out(mosi_sync__out),
		.posedge_(mosi_sync__posedge_),
		.reset(mosi_sync__reset)
	);
	wire [0:0] sclk_sync__clk;
	wire [0:0] sclk_sync__in_;
	wire [0:0] sclk_sync__negedge_;
	wire [0:0] sclk_sync__out;
	wire [0:0] sclk_sync__posedge_;
	wire [0:0] sclk_sync__reset;
	Synchronizer__reset_value_0 sclk_sync(
		.clk(sclk_sync__clk),
		.in_(sclk_sync__in_),
		.negedge_(sclk_sync__negedge_),
		.out(sclk_sync__out),
		.posedge_(sclk_sync__posedge_),
		.reset(sclk_sync__reset)
	);
	wire [0:0] shreg_in__clk;
	wire [0:0] shreg_in__in_;
	wire [33:0] shreg_in__load_data;
	wire [0:0] shreg_in__load_en;
	wire [33:0] shreg_in__out;
	wire [0:0] shreg_in__reset;
	reg [0:0] shreg_in__shift_en;
	ShiftReg__nbits_34 shreg_in(
		.clk(shreg_in__clk),
		.in_(shreg_in__in_),
		.load_data(shreg_in__load_data),
		.load_en(shreg_in__load_en),
		.out(shreg_in__out),
		.reset(shreg_in__reset),
		.shift_en(shreg_in__shift_en)
	);
	wire [0:0] shreg_out__clk;
	wire [0:0] shreg_out__in_;
	wire [33:0] shreg_out__load_data;
	wire [0:0] shreg_out__load_en;
	wire [33:0] shreg_out__out;
	wire [0:0] shreg_out__reset;
	reg [0:0] shreg_out__shift_en;
	ShiftReg__nbits_34 shreg_out(
		.clk(shreg_out__clk),
		.in_(shreg_out__in_),
		.load_data(shreg_out__load_data),
		.load_en(shreg_out__load_en),
		.out(shreg_out__out),
		.reset(shreg_out__reset),
		.shift_en(shreg_out__shift_en)
	);
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_parity
		parity = ^push__msg[6'd31:6'd0] & push__en;
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_shreg_in_shift_en
		shreg_in__shift_en = ~cs_sync__out & sclk_sync__posedge_;
	end
	always @(*) begin : _lambda__s_spi_min_stack_minion_minion_shreg_out_shift_en
		shreg_out__shift_en = ~cs_sync__out & sclk_sync__negedge_;
	end
	assign cs_sync__clk = clk;
	assign cs_sync__reset = reset;
	assign cs_sync__in_ = spi_min__cs;
	assign sclk_sync__clk = clk;
	assign sclk_sync__reset = reset;
	assign sclk_sync__in_ = spi_min__sclk;
	assign mosi_sync__clk = clk;
	assign mosi_sync__reset = reset;
	assign mosi_sync__in_ = spi_min__mosi;
	assign shreg_in__clk = clk;
	assign shreg_in__reset = reset;
	assign shreg_in__in_ = mosi_sync__out;
	assign shreg_in__load_en = 1'd0;
	assign shreg_in__load_data = 34'd0;
	assign shreg_out__clk = clk;
	assign shreg_out__reset = reset;
	assign shreg_out__in_ = 1'd0;
	assign shreg_out__load_en = pull__en;
	assign shreg_out__load_data = pull__msg;
	assign spi_min__miso = shreg_out__out[33:33];
	assign pull__en = cs_sync__negedge_;
	assign push__en = cs_sync__posedge_;
	assign push__msg = shreg_in__out;
endmodule
module SPIMinionAdapterCompositePRTL__nbits_34__num_entries_5 (
	adapter_parity,
	clk,
	minion_parity,
	reset,
	recv__msg,
	recv__rdy,
	recv__val,
	send__msg,
	send__rdy,
	send__val,
	spi_min__cs,
	spi_min__miso,
	spi_min__mosi,
	spi_min__sclk
);
	output wire [0:0] adapter_parity;
	input wire [0:0] clk;
	output wire [0:0] minion_parity;
	input wire [0:0] reset;
	input wire [31:0] recv__msg;
	output wire [0:0] recv__rdy;
	input wire [0:0] recv__val;
	output wire [31:0] send__msg;
	input wire [0:0] send__rdy;
	output wire [0:0] send__val;
	input wire [0:0] spi_min__cs;
	output wire [0:0] spi_min__miso;
	input wire [0:0] spi_min__mosi;
	input wire [0:0] spi_min__sclk;
	wire [0:0] adapter__clk;
	wire [0:0] adapter__parity;
	wire [0:0] adapter__reset;
	wire [0:0] adapter__pull__en;
	wire [33:0] adapter__pull__msg;
	wire [0:0] adapter__push__en;
	wire [33:0] adapter__push__msg;
	wire [31:0] adapter__recv__msg;
	wire [0:0] adapter__recv__rdy;
	wire [0:0] adapter__recv__val;
	wire [31:0] adapter__send__msg;
	wire [0:0] adapter__send__rdy;
	wire [0:0] adapter__send__val;
	SPIMinionAdapterPRTL__nbits_34__num_entries_5 adapter(
		.clk(adapter__clk),
		.parity(adapter__parity),
		.reset(adapter__reset),
		.pull__en(adapter__pull__en),
		.pull__msg(adapter__pull__msg),
		.push__en(adapter__push__en),
		.push__msg(adapter__push__msg),
		.recv__msg(adapter__recv__msg),
		.recv__rdy(adapter__recv__rdy),
		.recv__val(adapter__recv__val),
		.send__msg(adapter__send__msg),
		.send__rdy(adapter__send__rdy),
		.send__val(adapter__send__val)
	);
	wire [0:0] minion__clk;
	wire [0:0] minion__parity;
	wire [0:0] minion__reset;
	wire [0:0] minion__pull__en;
	wire [33:0] minion__pull__msg;
	wire [0:0] minion__push__en;
	wire [33:0] minion__push__msg;
	wire [0:0] minion__spi_min__cs;
	wire [0:0] minion__spi_min__miso;
	wire [0:0] minion__spi_min__mosi;
	wire [0:0] minion__spi_min__sclk;
	SPIMinionPRTL__nbits_34 minion(
		.clk(minion__clk),
		.parity(minion__parity),
		.reset(minion__reset),
		.pull__en(minion__pull__en),
		.pull__msg(minion__pull__msg),
		.push__en(minion__push__en),
		.push__msg(minion__push__msg),
		.spi_min__cs(minion__spi_min__cs),
		.spi_min__miso(minion__spi_min__miso),
		.spi_min__mosi(minion__spi_min__mosi),
		.spi_min__sclk(minion__spi_min__sclk)
	);
	assign minion__clk = clk;
	assign minion__reset = reset;
	assign minion__spi_min__cs = spi_min__cs;
	assign spi_min__miso = minion__spi_min__miso;
	assign minion__spi_min__mosi = spi_min__mosi;
	assign minion__spi_min__sclk = spi_min__sclk;
	assign minion_parity = minion__parity;
	assign adapter__clk = clk;
	assign adapter__reset = reset;
	assign adapter__pull__en = minion__pull__en;
	assign minion__pull__msg[33:33] = adapter__pull__msg[33];
	assign minion__pull__msg[32:32] = adapter__pull__msg[32];
	assign minion__pull__msg[31:0] = adapter__pull__msg[31-:32];
	assign adapter__push__en = minion__push__en;
	assign adapter__push__msg[33] = minion__push__msg[33:33];
	assign adapter__push__msg[32] = minion__push__msg[32:32];
	assign adapter__push__msg[31-:32] = minion__push__msg[31:0];
	assign adapter_parity = adapter__parity;
	assign send__msg = adapter__send__msg;
	assign adapter__send__rdy = send__rdy;
	assign send__val = adapter__send__val;
	assign adapter__recv__msg = recv__msg;
	assign recv__rdy = adapter__recv__rdy;
	assign adapter__recv__val = recv__val;
endmodule
module SPIstackPRTL__nbits_34__num_entries_5 (
	adapter_parity,
	clk,
	loopthrough_sel,
	minion_parity,
	reset,
	recv__msg,
	recv__rdy,
	recv__val,
	send__msg,
	send__rdy,
	send__val,
	spi_min__cs,
	spi_min__miso,
	spi_min__mosi,
	spi_min__sclk
);
	output wire [0:0] adapter_parity;
	input wire [0:0] clk;
	input wire [0:0] loopthrough_sel;
	output wire [0:0] minion_parity;
	input wire [0:0] reset;
	input wire [31:0] recv__msg;
	output wire [0:0] recv__rdy;
	input wire [0:0] recv__val;
	output wire [31:0] send__msg;
	input wire [0:0] send__rdy;
	output wire [0:0] send__val;
	input wire [0:0] spi_min__cs;
	output wire [0:0] spi_min__miso;
	input wire [0:0] spi_min__mosi;
	input wire [0:0] spi_min__sclk;
	wire [0:0] loopthrough__clk;
	wire [0:0] loopthrough__reset;
	wire [0:0] loopthrough__sel;
	wire [31:0] loopthrough__downstream__req__msg;
	wire [0:0] loopthrough__downstream__req__rdy;
	wire [0:0] loopthrough__downstream__req__val;
	wire [31:0] loopthrough__downstream__resp__msg;
	wire [0:0] loopthrough__downstream__resp__rdy;
	wire [0:0] loopthrough__downstream__resp__val;
	wire [31:0] loopthrough__upstream__req__msg;
	wire [0:0] loopthrough__upstream__req__rdy;
	wire [0:0] loopthrough__upstream__req__val;
	wire [31:0] loopthrough__upstream__resp__msg;
	wire [0:0] loopthrough__upstream__resp__rdy;
	wire [0:0] loopthrough__upstream__resp__val;
	LoopThroughPRTL__nbits_32 loopthrough(
		.clk(loopthrough__clk),
		.reset(loopthrough__reset),
		.sel(loopthrough__sel),
		.downstream__req__msg(loopthrough__downstream__req__msg),
		.downstream__req__rdy(loopthrough__downstream__req__rdy),
		.downstream__req__val(loopthrough__downstream__req__val),
		.downstream__resp__msg(loopthrough__downstream__resp__msg),
		.downstream__resp__rdy(loopthrough__downstream__resp__rdy),
		.downstream__resp__val(loopthrough__downstream__resp__val),
		.upstream__req__msg(loopthrough__upstream__req__msg),
		.upstream__req__rdy(loopthrough__upstream__req__rdy),
		.upstream__req__val(loopthrough__upstream__req__val),
		.upstream__resp__msg(loopthrough__upstream__resp__msg),
		.upstream__resp__rdy(loopthrough__upstream__resp__rdy),
		.upstream__resp__val(loopthrough__upstream__resp__val)
	);
	wire [0:0] minion__adapter_parity;
	wire [0:0] minion__clk;
	wire [0:0] minion__minion_parity;
	wire [0:0] minion__reset;
	wire [31:0] minion__recv__msg;
	wire [0:0] minion__recv__rdy;
	wire [0:0] minion__recv__val;
	wire [31:0] minion__send__msg;
	wire [0:0] minion__send__rdy;
	wire [0:0] minion__send__val;
	wire [0:0] minion__spi_min__cs;
	wire [0:0] minion__spi_min__miso;
	wire [0:0] minion__spi_min__mosi;
	wire [0:0] minion__spi_min__sclk;
	SPIMinionAdapterCompositePRTL__nbits_34__num_entries_5 minion(
		.adapter_parity(minion__adapter_parity),
		.clk(minion__clk),
		.minion_parity(minion__minion_parity),
		.reset(minion__reset),
		.recv__msg(minion__recv__msg),
		.recv__rdy(minion__recv__rdy),
		.recv__val(minion__recv__val),
		.send__msg(minion__send__msg),
		.send__rdy(minion__send__rdy),
		.send__val(minion__send__val),
		.spi_min__cs(minion__spi_min__cs),
		.spi_min__miso(minion__spi_min__miso),
		.spi_min__mosi(minion__spi_min__mosi),
		.spi_min__sclk(minion__spi_min__sclk)
	);
	assign minion__clk = clk;
	assign minion__reset = reset;
	assign minion__spi_min__cs = spi_min__cs;
	assign spi_min__miso = minion__spi_min__miso;
	assign minion__spi_min__mosi = spi_min__mosi;
	assign minion__spi_min__sclk = spi_min__sclk;
	assign minion_parity = minion__minion_parity;
	assign adapter_parity = minion__adapter_parity;
	assign loopthrough__clk = clk;
	assign loopthrough__reset = reset;
	assign loopthrough__sel = loopthrough_sel;
	assign loopthrough__upstream__req__msg = minion__send__msg;
	assign minion__send__rdy = loopthrough__upstream__req__rdy;
	assign loopthrough__upstream__req__val = minion__send__val;
	assign minion__recv__msg = loopthrough__upstream__resp__msg;
	assign loopthrough__upstream__resp__rdy = minion__recv__rdy;
	assign minion__recv__val = loopthrough__upstream__resp__val;
	assign send__msg = loopthrough__downstream__req__msg;
	assign loopthrough__downstream__req__rdy = send__rdy;
	assign send__val = loopthrough__downstream__req__val;
	assign loopthrough__downstream__resp__msg = recv__msg;
	assign recv__rdy = loopthrough__downstream__resp__rdy;
	assign loopthrough__downstream__resp__val = recv__val;
endmodule
module grp_99_SPI_TapeOutBlockRTL_32bits_5entries (
	`ifdef USE_POWER_PINS
      inout vccd1, // User area 1 1.8V supply
      inout vssd1, // User area 1 digital ground
    `endif
    output adapter_parity,
	input clk,
	input loopthrough_sel,
	output minion_parity,
	input reset,
	input spi_min__cs,
	output spi_min__miso,
	input spi_min__mosi,
	input spi_min__sclk,
    output clk_en,
    output reset_en,
    output lt_sel_en,
    output mp_en,
    output ap_en,
    output cs_en,
    output sclk_en,
    output miso_en,
    output mosi_en
);
	assign lt_sel_en = 1; //Input
    assign mp_en = 0; //Output
    assign ap_en = 0; //Output
    assign cs_en = 1; //Input
    assign sclk_en = 1; //Input
    assign miso_en = 0; //Output
    assign mosi_en = 1; //Input
    assign clk_en = 1; //Input
    assign reset_en = 1; //Input
    // output wire [0:0] adapter_parity;
	// input wire [0:0] clk;
	// input wire [0:0] loopthrough_sel;
	// output wire [0:0] minion_parity;
	// input wire [0:0] reset;
	// input wire [0:0] spi_min__cs;
	// output wire [0:0] spi_min__miso;
	// input wire [0:0] spi_min__mosi;
	// input wire [0:0] spi_min__sclk;
	wire [0:0] block__clk;
	wire [0:0] block__reset;
	reg [31:0] block__recv__msg;
	wire [0:0] block__recv__rdy;
	reg [0:0] block__recv__val;
	wire [31:0] block__send__msg;
	reg [0:0] block__send__rdy;
	wire [0:0] block__send__val;
	BlockPlaceholderPRTL__nbits_32 block(
		.clk(block__clk),
		.reset(block__reset),
		.recv__msg(block__recv__msg),
		.recv__rdy(block__recv__rdy),
		.recv__val(block__recv__val),
		.send__msg(block__send__msg),
		.send__rdy(block__send__rdy),
		.send__val(block__send__val)
	);
	wire [0:0] spi_min_stack__adapter_parity;
	wire [0:0] spi_min_stack__clk;
	wire [0:0] spi_min_stack__loopthrough_sel;
	wire [0:0] spi_min_stack__minion_parity;
	wire [0:0] spi_min_stack__reset;
	reg [31:0] spi_min_stack__recv__msg;
	wire [0:0] spi_min_stack__recv__rdy;
	reg [0:0] spi_min_stack__recv__val;
	wire [31:0] spi_min_stack__send__msg;
	reg [0:0] spi_min_stack__send__rdy;
	wire [0:0] spi_min_stack__send__val;
	wire [0:0] spi_min_stack__spi_min__cs;
	wire [0:0] spi_min_stack__spi_min__miso;
	wire [0:0] spi_min_stack__spi_min__mosi;
	wire [0:0] spi_min_stack__spi_min__sclk;
	SPIstackPRTL__nbits_34__num_entries_5 spi_min_stack(
		.adapter_parity(spi_min_stack__adapter_parity),
		.clk(spi_min_stack__clk),
		.loopthrough_sel(spi_min_stack__loopthrough_sel),
		.minion_parity(spi_min_stack__minion_parity),
		.reset(spi_min_stack__reset),
		.recv__msg(spi_min_stack__recv__msg),
		.recv__rdy(spi_min_stack__recv__rdy),
		.recv__val(spi_min_stack__recv__val),
		.send__msg(spi_min_stack__send__msg),
		.send__rdy(spi_min_stack__send__rdy),
		.send__val(spi_min_stack__send__val),
		.spi_min__cs(spi_min_stack__spi_min__cs),
		.spi_min__miso(spi_min_stack__spi_min__miso),
		.spi_min__mosi(spi_min_stack__spi_min__mosi),
		.spi_min__sclk(spi_min_stack__spi_min__sclk)
	);
	always @(*) begin : combinational
		block__recv__msg = spi_min_stack__send__msg;
		block__recv__val = spi_min_stack__send__val;
		spi_min_stack__send__rdy = block__recv__rdy;
		spi_min_stack__recv__msg = block__send__msg;
		spi_min_stack__recv__val = block__send__val;
		block__send__rdy = spi_min_stack__recv__rdy;
	end
	assign spi_min_stack__clk = clk;
	assign spi_min_stack__reset = reset;
	assign spi_min_stack__spi_min__cs = spi_min__cs;
	assign spi_min_stack__spi_min__sclk = spi_min__sclk;
	assign spi_min_stack__spi_min__mosi = spi_min__mosi;
	assign spi_min__miso = spi_min_stack__spi_min__miso;
	assign spi_min_stack__loopthrough_sel = loopthrough_sel;
	assign minion_parity = spi_min_stack__minion_parity;
	assign adapter_parity = spi_min_stack__adapter_parity;
	assign block__clk = clk;
	assign block__reset = reset;
endmodule
