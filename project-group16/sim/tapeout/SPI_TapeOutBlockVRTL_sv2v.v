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
module NormalQueueCtrlRTL__num_entries_2 (
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
	output reg [1:0] count;
	output wire [0:0] raddr;
	output reg [0:0] recv_rdy;
	input wire [0:0] recv_val;
	input wire [0:0] reset;
	input wire [0:0] send_rdy;
	output reg [0:0] send_val;
	output wire [0:0] waddr;
	output wire [0:0] wen;
	localparam [1:0] __const__num_entries_at__lambda__s_synthmem_memreq_q_ctrl_recv_rdy = 2'd2;
	localparam [1:0] __const__num_entries_at_up_reg = 2'd2;
	reg [0:0] head;
	reg [0:0] recv_xfer;
	reg [0:0] send_xfer;
	reg [0:0] tail;
	always @(*) begin : _lambda__s_synthmem_memreq_q_ctrl_recv_rdy
		recv_rdy = count < __const__num_entries_at__lambda__s_synthmem_memreq_q_ctrl_recv_rdy;
	end
	always @(*) begin : _lambda__s_synthmem_memreq_q_ctrl_recv_xfer
		recv_xfer = recv_val & recv_rdy;
	end
	always @(*) begin : _lambda__s_synthmem_memreq_q_ctrl_send_val
		send_val = count > 2'd0;
	end
	always @(*) begin : _lambda__s_synthmem_memreq_q_ctrl_send_xfer
		send_xfer = send_val & send_rdy;
	end
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	always @(posedge clk) begin : up_reg
		if (reset) begin
			head <= 1'd0;
			tail <= 1'd0;
			count <= 2'd0;
		end
		else begin
			if (recv_xfer)
				tail <= (tail < (sv2v_cast_1(__const__num_entries_at_up_reg) - 1'd1) ? tail + 1'd1 : 1'd0);
			if (send_xfer)
				head <= (head < (sv2v_cast_1(__const__num_entries_at_up_reg) - 1'd1) ? head + 1'd1 : 1'd0);
			if (recv_xfer & ~send_xfer)
				count <= count + 2'd1;
			else if (~recv_xfer & send_xfer)
				count <= count - 2'd1;
		end
	end
	assign wen = recv_xfer;
	assign waddr = tail;
	assign raddr = head;
endmodule
module RegisterFile__db0945d550cc0f5f (
	clk,
	raddr,
	rdata,
	reset,
	waddr,
	wdata,
	wen
);
	input wire [0:0] clk;
	input wire [0:0] raddr;
	output reg [77:0] rdata;
	input wire [0:0] reset;
	input wire [0:0] waddr;
	input wire [77:0] wdata;
	input wire [0:0] wen;
	localparam [0:0] __const__rd_ports_at_up_rf_read = 1'd1;
	localparam [0:0] __const__wr_ports_at_up_rf_write = 1'd1;
	reg [77:0] regs [0:1];
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	always @(*) begin : up_rf_read
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 1'd0; i < __const__rd_ports_at_up_rf_read; i = i + 1'd1)
				rdata[sv2v_cast_1(i) * 78+:78] = regs[raddr[sv2v_cast_1(i)+:1]];
		end
	end
	always @(posedge clk) begin : up_rf_write
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 1'd0; i < __const__wr_ports_at_up_rf_write; i = i + 1'd1)
				if (wen[sv2v_cast_1(i)+:1])
					regs[waddr[sv2v_cast_1(i)+:1]] <= wdata[sv2v_cast_1(i) * 78+:78];
		end
	end
endmodule
module NormalQueueDpathRTL__b8bb4da201e26f4e (
	clk,
	raddr,
	recv_msg,
	reset,
	send_msg,
	waddr,
	wen
);
	input wire [0:0] clk;
	input wire [0:0] raddr;
	input wire [77:0] recv_msg;
	input wire [0:0] reset;
	output wire [77:0] send_msg;
	input wire [0:0] waddr;
	input wire [0:0] wen;
	wire [0:0] rf__clk;
	wire [0:0] rf__raddr;
	wire [77:0] rf__rdata;
	wire [0:0] rf__reset;
	wire [0:0] rf__waddr;
	wire [77:0] rf__wdata;
	wire [0:0] rf__wen;
	RegisterFile__db0945d550cc0f5f rf(
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
	assign rf__raddr[0+:1] = raddr;
	assign send_msg = rf__rdata[0+:78];
	assign rf__wen[0+:1] = wen;
	assign rf__waddr[0+:1] = waddr;
	assign rf__wdata[0+:78] = recv_msg;
endmodule
module NormalQueueRTL__b8bb4da201e26f4e (
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
	output wire [1:0] count;
	input wire [0:0] reset;
	input wire [77:0] recv__msg;
	output wire [0:0] recv__rdy;
	input wire [0:0] recv__val;
	output wire [77:0] send__msg;
	input wire [0:0] send__rdy;
	output wire [0:0] send__val;
	wire [0:0] ctrl__clk;
	wire [1:0] ctrl__count;
	wire [0:0] ctrl__raddr;
	wire [0:0] ctrl__recv_rdy;
	wire [0:0] ctrl__recv_val;
	wire [0:0] ctrl__reset;
	wire [0:0] ctrl__send_rdy;
	wire [0:0] ctrl__send_val;
	wire [0:0] ctrl__waddr;
	wire [0:0] ctrl__wen;
	NormalQueueCtrlRTL__num_entries_2 ctrl(
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
	wire [0:0] dpath__raddr;
	wire [77:0] dpath__recv_msg;
	wire [0:0] dpath__reset;
	wire [77:0] dpath__send_msg;
	wire [0:0] dpath__waddr;
	wire [0:0] dpath__wen;
	NormalQueueDpathRTL__b8bb4da201e26f4e dpath(
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
module RegisterFile__8c50dafb5bf22f7b (
	clk,
	raddr,
	rdata,
	reset,
	waddr,
	wdata,
	wen
);
	input wire [0:0] clk;
	input wire [4:0] raddr;
	output reg [31:0] rdata;
	input wire [0:0] reset;
	input wire [4:0] waddr;
	input wire [31:0] wdata;
	input wire [0:0] wen;
	localparam [0:0] __const__rd_ports_at_up_rf_read = 1'd1;
	localparam [0:0] __const__wr_ports_at_up_rf_write = 1'd1;
	reg [31:0] regs [0:31];
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	always @(*) begin : up_rf_read
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 1'd0; i < __const__rd_ports_at_up_rf_read; i = i + 1'd1)
				rdata[sv2v_cast_1(i) * 32+:32] = regs[raddr[sv2v_cast_1(i) * 5+:5]];
		end
	end
	always @(posedge clk) begin : up_rf_write
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 1'd0; i < __const__wr_ports_at_up_rf_write; i = i + 1'd1)
				if (wen[sv2v_cast_1(i)+:1])
					regs[waddr[sv2v_cast_1(i) * 5+:5]] <= wdata[sv2v_cast_1(i) * 32+:32];
		end
	end
endmodule
module SynthMemSimple (
	clk,
	reset,
	minion__req__msg,
	minion__req__rdy,
	minion__req__val,
	minion__resp__msg,
	minion__resp__rdy,
	minion__resp__val
);
	input wire [0:0] clk;
	input wire [0:0] reset;
	input wire [77:0] minion__req__msg;
	output wire [0:0] minion__req__rdy;
	input wire [0:0] minion__req__val;
	output reg [47:0] minion__resp__msg;
	input wire [0:0] minion__resp__rdy;
	output reg [0:0] minion__resp__val;
	localparam [1:0] __const__addr_start_at_comb_M0 = 2'd2;
	localparam [2:0] __const__addr_end_at_comb_M0 = 3'd7;
	localparam [3:0] __const__MEM_MSG_TYPE_WRITE_at_comb_M0 = 4'd1;
	localparam [3:0] __const__MEM_MSG_TYPE_READ_at_comb_M0 = 4'd0;
	reg [47:0] minion_resp_msg_raw;
	reg [4:0] reg_addr_M0;
	reg [0:0] reg_en_M0;
	reg [7:0] reg_opaque;
	reg [31:0] reg_wdata_M0;
	reg [0:0] reg_wen_M0;
	reg [3:0] req_type;
	wire [0:0] memreq_q__clk;
	wire [1:0] memreq_q__count;
	wire [0:0] memreq_q__reset;
	wire [77:0] memreq_q__recv__msg;
	wire [0:0] memreq_q__recv__rdy;
	wire [0:0] memreq_q__recv__val;
	wire [77:0] memreq_q__send__msg;
	reg [0:0] memreq_q__send__rdy;
	wire [0:0] memreq_q__send__val;
	NormalQueueRTL__b8bb4da201e26f4e memreq_q(
		.clk(memreq_q__clk),
		.count(memreq_q__count),
		.reset(memreq_q__reset),
		.recv__msg(memreq_q__recv__msg),
		.recv__rdy(memreq_q__recv__rdy),
		.recv__val(memreq_q__recv__val),
		.send__msg(memreq_q__send__msg),
		.send__rdy(memreq_q__send__rdy),
		.send__val(memreq_q__send__val)
	);
	wire [0:0] reg_file__clk;
	wire [4:0] reg_file__raddr;
	wire [31:0] reg_file__rdata;
	wire [0:0] reg_file__reset;
	wire [4:0] reg_file__waddr;
	wire [31:0] reg_file__wdata;
	wire [0:0] reg_file__wen;
	RegisterFile__8c50dafb5bf22f7b reg_file(
		.clk(reg_file__clk),
		.raddr(reg_file__raddr),
		.rdata(reg_file__rdata),
		.reset(reg_file__reset),
		.waddr(reg_file__waddr),
		.wdata(reg_file__wdata),
		.wen(reg_file__wen)
	);
	always @(*) begin : _lambda__s_synthmem_minion_resp_msg_data
		minion__resp__msg[31-:32] = minion_resp_msg_raw[31-:32] & {{31 {minion__resp__val[0]}}, minion__resp__val};
	end
	always @(*) begin : _lambda__s_synthmem_minion_resp_msg_len
		minion__resp__msg[33-:2] = minion_resp_msg_raw[33-:2] & {{minion__resp__val[0]}, minion__resp__val};
	end
	always @(*) begin : _lambda__s_synthmem_minion_resp_msg_opaque
		minion__resp__msg[43-:8] = minion_resp_msg_raw[43-:8] & {{7 {minion__resp__val[0]}}, minion__resp__val};
	end
	always @(*) begin : _lambda__s_synthmem_minion_resp_msg_test
		minion__resp__msg[35-:2] = minion_resp_msg_raw[35-:2] & {{minion__resp__val[0]}, minion__resp__val};
	end
	always @(*) begin : _lambda__s_synthmem_minion_resp_msg_type_
		minion__resp__msg[47-:4] = minion_resp_msg_raw[47-:4] & {{3 {minion__resp__val[0]}}, minion__resp__val};
	end
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	always @(*) begin : comb_M0
		minion__resp__val = memreq_q__send__val;
		memreq_q__send__rdy = minion__resp__rdy;
		req_type = memreq_q__send__msg[77-:4];
		reg_addr_M0 = memreq_q__send__msg[34 + 5'd6:34 + sv2v_cast_5(__const__addr_start_at_comb_M0)];
		reg_wen_M0 = memreq_q__send__val & (req_type == __const__MEM_MSG_TYPE_WRITE_at_comb_M0);
		reg_en_M0 = memreq_q__send__val & memreq_q__send__rdy;
		reg_wdata_M0 = memreq_q__send__msg[31-:32];
		reg_opaque = memreq_q__send__msg[73-:8];
		if (memreq_q__send__msg[77-:4] == 4'd0)
			minion_resp_msg_raw = {__const__MEM_MSG_TYPE_READ_at_comb_M0, memreq_q__send__msg[73-:8], 2'd0, 2'd0, reg_file__rdata[1'd0 * 32+:32]};
		else if (memreq_q__send__msg[77-:4] == 4'd1)
			minion_resp_msg_raw = {__const__MEM_MSG_TYPE_WRITE_at_comb_M0, memreq_q__send__msg[73-:8], 2'd0, 2'd0, 32'd0};
	end
	assign memreq_q__clk = clk;
	assign memreq_q__reset = reset;
	assign memreq_q__recv__msg = minion__req__msg;
	assign minion__req__rdy = memreq_q__recv__rdy;
	assign memreq_q__recv__val = minion__req__val;
	assign reg_file__clk = clk;
	assign reg_file__reset = reset;
	assign reg_file__waddr[0+:5] = reg_addr_M0;
	assign reg_file__raddr[0+:5] = reg_addr_M0;
	assign reg_file__wen[0+:1] = reg_wen_M0;
	assign reg_file__wdata[0+:32] = reg_wdata_M0;
endmodule
module PacketAssemblerPRTL__nbits_in_32__nbits_out_78 (
	clk,
	reset,
	assem_ifc__req__msg,
	assem_ifc__req__rdy,
	assem_ifc__req__val,
	assem_ifc__resp__msg,
	assem_ifc__resp__rdy,
	assem_ifc__resp__val
);
	input wire [0:0] clk;
	input wire [0:0] reset;
	input wire [31:0] assem_ifc__req__msg;
	output reg [0:0] assem_ifc__req__rdy;
	input wire [0:0] assem_ifc__req__val;
	output reg [77:0] assem_ifc__resp__msg;
	input wire [0:0] assem_ifc__resp__rdy;
	output reg [0:0] assem_ifc__resp__val;
	reg [2:0] counter;
	reg [31:0] regs [0:2];
	reg [95:0] temp_out;
	always @(*) begin : _lambda__s_synthmem_assem_assem_ifc_req_rdy
		assem_ifc__req__rdy = counter != 3'd3;
	end
	always @(*) begin : _lambda__s_synthmem_assem_assem_ifc_resp_msg
		assem_ifc__resp__msg = temp_out[7'd77:7'd0];
	end
	always @(*) begin : _lambda__s_synthmem_assem_assem_ifc_resp_val
		assem_ifc__resp__val = counter == 3'd3;
	end
	function automatic [6:0] sv2v_cast_7;
		input reg [6:0] inp;
		sv2v_cast_7 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	always @(*) begin : up_resp_msg
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 1'd0; i < 2'd3; i = i + 1'd1)
				temp_out[7'd32 * ((7'd3 - 7'd1) - sv2v_cast_7(i))+:32] = regs[sv2v_cast_2(i)];
		end
	end
	always @(posedge clk) begin : up_counter
		if (reset)
			counter <= 3'd0;
		else if (assem_ifc__resp__val & assem_ifc__resp__rdy)
			counter <= 3'd0;
		else if (assem_ifc__resp__val & ~assem_ifc__resp__rdy)
			counter <= counter;
		else if (assem_ifc__req__val & assem_ifc__req__rdy)
			counter <= counter + 3'd1;
		else
			counter <= counter;
	end
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	always @(posedge clk) begin : up_regs
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 1'd0; i < 2'd3; i = i + 1'd1)
				if (reset)
					regs[sv2v_cast_2(i)] <= 32'd0;
				else if (counter == sv2v_cast_3(i))
					regs[sv2v_cast_2(i)] <= assem_ifc__req__msg;
				else
					regs[sv2v_cast_2(i)] <= regs[sv2v_cast_2(i)];
		end
	end
endmodule
module Mux__Type_32__ninputs_2 (
	clk,
	in_,
	out,
	reset,
	sel
);
	input wire [0:0] clk;
	input wire [63:0] in_;
	output reg [31:0] out;
	input wire [0:0] reset;
	input wire [0:0] sel;
	always @(*) begin : up_mux
		out = in_[(1 - sel) * 32+:32];
	end
endmodule
module PacketDisassemblerPRTL__nbits_in_48__nbits_out_32 (
	clk,
	reset,
	disassem_ifc__req__msg,
	disassem_ifc__req__rdy,
	disassem_ifc__req__val,
	disassem_ifc__resp__msg,
	disassem_ifc__resp__rdy,
	disassem_ifc__resp__val
);
	input wire [0:0] clk;
	input wire [0:0] reset;
	input wire [47:0] disassem_ifc__req__msg;
	output reg [0:0] disassem_ifc__req__rdy;
	input wire [0:0] disassem_ifc__req__val;
	output reg [31:0] disassem_ifc__resp__msg;
	input wire [0:0] disassem_ifc__resp__rdy;
	output reg [0:0] disassem_ifc__resp__val;
	reg [1:0] counter;
	reg [31:0] regs [0:1];
	reg [0:0] transaction_val;
	wire [0:0] reg_mux__clk;
	reg [63:0] reg_mux__in_;
	wire [31:0] reg_mux__out;
	wire [0:0] reg_mux__reset;
	reg [0:0] reg_mux__sel;
	Mux__Type_32__ninputs_2 reg_mux(
		.clk(reg_mux__clk),
		.in_(reg_mux__in_),
		.out(reg_mux__out),
		.reset(reg_mux__reset),
		.sel(reg_mux__sel)
	);
	always @(*) begin : _lambda__s_synthmem_disassem_disassem_ifc_req_rdy
		disassem_ifc__req__rdy = transaction_val == 1'd0;
	end
	always @(*) begin : _lambda__s_synthmem_disassem_disassem_ifc_resp_val
		disassem_ifc__resp__val = transaction_val == 1'd1;
	end
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	always @(*) begin : up_comb
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 1'd0; i < 2'd2; i = i + 1'd1)
				reg_mux__in_[(1 - sv2v_cast_1(i)) * 32+:32] = regs[sv2v_cast_1(i)];
		end
		reg_mux__sel = sv2v_cast_1((2'd2 - counter) - 2'd1);
		disassem_ifc__resp__msg = reg_mux__out;
	end
	always @(posedge clk) begin : up_counter
		if (reset)
			counter <= 2'd0;
		else if ((counter == (2'd2 - 2'd1)) & disassem_ifc__resp__rdy)
			counter <= 2'd0;
		else if (disassem_ifc__resp__val & disassem_ifc__resp__rdy)
			counter <= counter + 2'd1;
		else
			counter <= counter;
	end
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	always @(posedge clk) begin : up_regs
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 1'd0; i < 2'd2; i = i + 1'd1)
				if (disassem_ifc__req__val & disassem_ifc__req__rdy)
					if (sv2v_cast_1(i) == (1'd0 - 1'd1))
						regs[sv2v_cast_1(i)] <= {{16 {1'b0}}, disassem_ifc__req__msg[6'd47:(6'd32 * 6'd2) - 7'd32]};
					else
						regs[sv2v_cast_1(i)] <= disassem_ifc__req__msg[6'd32 * sv2v_cast_6(i)+:32];
		end
	end
	always @(posedge clk) begin : up_transaction_val
		if (reset)
			transaction_val <= 1'd0;
		else if ((disassem_ifc__req__val & disassem_ifc__req__rdy) | ((counter == (2'd2 - 2'd1)) & disassem_ifc__resp__rdy))
			transaction_val <= disassem_ifc__req__val & disassem_ifc__req__rdy;
		else
			transaction_val <= transaction_val;
	end
	assign reg_mux__clk = clk;
	assign reg_mux__reset = reset;
endmodule

module tapeout_SPI_TapeOutBlockVRTL_sv2v (
  output adapter_parity,
  input  clk,
  input  loopthrough_sel,
  output minion_parity,
  input  reset,
  input  spi_min__cs,
  output spi_min__miso,
  input  spi_min__mosi,
  input  spi_min__sclk
);
  reg reset_presync;
  reg reset_sync;

  always @(posedge clk) begin
    reset_presync <= reset;
    reset_sync    <= reset_presync;
  end

	wire [0:0] spi_min_stack__adapter_parity;
	wire [0:0] spi_min_stack__clk;
	wire [0:0] spi_min_stack__loopthrough_sel;
	wire [0:0] spi_min_stack__minion_parity;
	wire [0:0] spi_min_stack__reset;
	wire [31:0] spi_min_stack__recv__msg;
	wire [0:0] spi_min_stack__recv__rdy;
	wire [0:0] spi_min_stack__recv__val;
	wire [31:0] spi_min_stack__send__msg;
	wire [0:0] spi_min_stack__send__rdy;
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
	wire [0:0] synthmem__clk;
	wire [0:0] synthmem__reset;
	reg [77:0] synthmem__minion__req__msg;
	wire [0:0] synthmem__minion__req__rdy;
	reg [0:0] synthmem__minion__req__val;
	wire [47:0] synthmem__minion__resp__msg;
	reg [0:0] synthmem__minion__resp__rdy;
	wire [0:0] synthmem__minion__resp__val;
	SynthMemSimple synthmem(
		.clk(synthmem__clk),
		.reset(synthmem__reset),
		.minion__req__msg(synthmem__minion__req__msg),
		.minion__req__rdy(synthmem__minion__req__rdy),
		.minion__req__val(synthmem__minion__req__val),
		.minion__resp__msg(synthmem__minion__resp__msg),
		.minion__resp__rdy(synthmem__minion__resp__rdy),
		.minion__resp__val(synthmem__minion__resp__val)
	);
	wire [0:0] synthmem_assem__clk;
	wire [0:0] synthmem_assem__reset;
	wire [31:0] synthmem_assem__assem_ifc__req__msg;
	wire [0:0] synthmem_assem__assem_ifc__req__rdy;
	wire [0:0] synthmem_assem__assem_ifc__req__val;
	wire [77:0] synthmem_assem__assem_ifc__resp__msg;
	reg [0:0] synthmem_assem__assem_ifc__resp__rdy;
	wire [0:0] synthmem_assem__assem_ifc__resp__val;
	PacketAssemblerPRTL__nbits_in_32__nbits_out_78 synthmem_assem(
		.clk(synthmem_assem__clk),
		.reset(synthmem_assem__reset),
		.assem_ifc__req__msg(synthmem_assem__assem_ifc__req__msg),
		.assem_ifc__req__rdy(synthmem_assem__assem_ifc__req__rdy),
		.assem_ifc__req__val(synthmem_assem__assem_ifc__req__val),
		.assem_ifc__resp__msg(synthmem_assem__assem_ifc__resp__msg),
		.assem_ifc__resp__rdy(synthmem_assem__assem_ifc__resp__rdy),
		.assem_ifc__resp__val(synthmem_assem__assem_ifc__resp__val)
	);
	wire [0:0] synthmem_disassem__clk;
	wire [0:0] synthmem_disassem__reset;
	reg [47:0] synthmem_disassem__disassem_ifc__req__msg;
	wire [0:0] synthmem_disassem__disassem_ifc__req__rdy;
	reg [0:0] synthmem_disassem__disassem_ifc__req__val;
	wire [31:0] synthmem_disassem__disassem_ifc__resp__msg;
	wire [0:0] synthmem_disassem__disassem_ifc__resp__rdy;
	wire [0:0] synthmem_disassem__disassem_ifc__resp__val;
	PacketDisassemblerPRTL__nbits_in_48__nbits_out_32 synthmem_disassem(
		.clk(synthmem_disassem__clk),
		.reset(synthmem_disassem__reset),
		.disassem_ifc__req__msg(synthmem_disassem__disassem_ifc__req__msg),
		.disassem_ifc__req__rdy(synthmem_disassem__disassem_ifc__req__rdy),
		.disassem_ifc__req__val(synthmem_disassem__disassem_ifc__req__val),
		.disassem_ifc__resp__msg(synthmem_disassem__disassem_ifc__resp__msg),
		.disassem_ifc__resp__rdy(synthmem_disassem__disassem_ifc__resp__rdy),
		.disassem_ifc__resp__val(synthmem_disassem__disassem_ifc__resp__val)
	);
	always @(*) begin : up_assembler
		synthmem__minion__req__msg = synthmem_assem__assem_ifc__resp__msg;
		synthmem__minion__req__val = synthmem_assem__assem_ifc__resp__val;
		synthmem_assem__assem_ifc__resp__rdy = synthmem__minion__req__rdy;
	end
	always @(*) begin : up_dissassembler
		synthmem_disassem__disassem_ifc__req__msg = synthmem__minion__resp__msg;
		synthmem_disassem__disassem_ifc__req__val = synthmem__minion__resp__val;
		synthmem__minion__resp__rdy = synthmem_disassem__disassem_ifc__req__rdy;
	end
	assign spi_min_stack__clk = clk;
	assign spi_min_stack__reset = reset_sync;
	assign spi_min_stack__spi_min__cs = spi_min__cs;
	assign spi_min_stack__spi_min__sclk = spi_min__sclk;
	assign spi_min_stack__spi_min__mosi = spi_min__mosi;
	assign spi_min__miso = spi_min_stack__spi_min__miso;
	assign spi_min_stack__loopthrough_sel = loopthrough_sel;
	assign minion_parity = spi_min_stack__minion_parity;
	assign adapter_parity = spi_min_stack__adapter_parity;
	assign synthmem_assem__clk = clk;
	assign synthmem_assem__reset = reset_sync;
	assign synthmem_disassem__clk = clk;
	assign synthmem_disassem__reset = reset_sync;
	assign synthmem__clk = clk;
	assign synthmem__reset = reset_sync;
	assign synthmem_assem__assem_ifc__req__msg = spi_min_stack__send__msg;
	assign spi_min_stack__send__rdy = synthmem_assem__assem_ifc__req__rdy;
	assign synthmem_assem__assem_ifc__req__val = spi_min_stack__send__val;
	assign spi_min_stack__recv__msg = synthmem_disassem__disassem_ifc__resp__msg;
	assign synthmem_disassem__disassem_ifc__resp__rdy = spi_min_stack__recv__rdy;
	assign spi_min_stack__recv__val = synthmem_disassem__disassem_ifc__resp__val;
endmodule
