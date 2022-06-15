// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`define VTB_INPUT_DELAY 1
`define VTB_OUTPUT_ASSERT_DELAY 3

// CYCLE_TIME and INTRA_CYCLE_TIME are duration of time.
`define CYCLE_TIME 10
`define INTRA_CYCLE_TIME (`VTB_OUTPUT_ASSERT_DELAY-`VTB_INPUT_DELAY)

`timescale 1 ns / 1 ps

`define T(a0,a1,a2,a3,a4,a5,a6) \
        t(a0,a1,a2,a3,a4,a5,a6,`__LINE__)

// Tick one extra cycle upon an error.
`define VTB_TEST_FAIL(lineno, out, ref, port_name) \
    $display("- Timestamp      : %0d (default unit: ns)", $time); \
    $display("- Cycle number   : %0d (variable: cycle_count)", cycle_count); \
    $display("- line number    : line %0d in grp_99_test_small_tb.v.cases", lineno); \
    $display("- port name      : %s", port_name); \
    $display("- expected value : 0x%x", ref); \
    $display("- actual value   : 0x%x", out); \
    $display(""); \
    #(`CYCLE_TIME-`INTRA_CYCLE_TIME); \
    cycle_count += 1; \
    #`CYCLE_TIME; \
    cycle_count += 1; \
    $fatal;

`define CHECK(lineno, out, ref, port_name) \
  if ((|(out ^ out)) == 1'b0) ; \
  else begin \
    $display(""); \
    $display("The test bench received a value containing X/Z's! Please note"); \
    $display("that the VTB is pessmistic about X's and you should make sure"); \
    $display("all output ports of your DUT does not produce X's after reset."); \
    `VTB_TEST_FAIL(lineno, out, ref, port_name) \
  end \
  if (out != ref) begin \
    $display(""); \
    $display("The test bench received an incorrect value!"); \
    `VTB_TEST_FAIL(lineno, out, ref, port_name) \
  end

module grp_99_test_small_tb;
	reg signal;
    reg clock;
    reg clk;
	reg RSTB;
    reg reset;
	reg CSB;
    integer cycle_count;
    reg power1, power2;
	reg power3, power4;

    wire gpio;
	wire [37:0] mprj_io;
	wire [3:0] checkbits;

	assign checkbits = mprj_io[31:28];

    always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

    reg loopthrough_sel_reg;
    reg spi_min__cs_reg;
    reg spi_min__mosi_reg;
    reg spi_min__sclk_reg;

    assign mprj_io[12] = loopthrough_sel_reg;
    assign mprj_io[15] = spi_min__cs_reg;
    assign mprj_io[16] = spi_min__sclk_reg;
    assign mprj_io[18] = spi_min__mosi_reg;

    // logic [0:0] adapter_parity ;
    // logic [0:0] loopthrough_sel ;
    // logic [0:0] minion_parity ;
    // logic [0:0] spi_min__cs ;
    // logic [0:0] spi_min__miso ;
    // logic [0:0] spi_min__mosi ;
    // logic [0:0] spi_min__sclk ;

    // assign adapter_parity  = mprj_io[14];
    // assign loopthrough_sel = mprj_io[12];
    // assign minion_parity   = mprj_io[13];
    // assign spi_min__cs     = mprj_io[15];
    // assign spi_min__miso   = mprj_io[17];
    // assign spi_min__mosi   = mprj_io[18];
    // assign spi_min__sclk   = mprj_io[16];

    task t(
      input logic [0:0] ref_adapter_parity,
      input logic [0:0] inp_loopthrough_sel,
      input logic [0:0] ref_minion_parity,
      input logic [0:0] inp_spi_min__cs,
      input logic [0:0] ref_spi_min__miso,
      input logic [0:0] inp_spi_min__mosi,
      input logic [0:0] inp_spi_min__sclk,
      input integer lineno
    );
    begin
    //   loopthrough_sel = inp_loopthrough_sel;
      loopthrough_sel_reg <= inp_loopthrough_sel;
    //   spi_min__cs = inp_spi_min__cs;
      spi_min__cs_reg <= inp_spi_min__cs;
    //   spi_min__mosi = inp_spi_min__mosi;
      spi_min__mosi_reg <= inp_spi_min__mosi;
    //   spi_min__sclk = inp_spi_min__sclk;
      spi_min__sclk_reg <= inp_spi_min__sclk;
      #`INTRA_CYCLE_TIME;
    //   `CHECK(lineno, adapter_parity, ref_adapter_parity, "adapter_parity (adapter_parity in Verilog)");
      `CHECK(lineno, mprj_io[14], ref_adapter_parity, "adapter_parity (adapter_parity in Verilog)");
    //   `CHECK(lineno, minion_parity, ref_minion_parity, "minion_parity (minion_parity in Verilog)");
      `CHECK(lineno, mprj_io[13], ref_minion_parity, "minion_parity (minion_parity in Verilog)");
    //   `CHECK(lineno, spi_min__miso, ref_spi_min__miso, "spi_min.miso (spi_min__miso in Verilog)");
      `CHECK(lineno, mprj_io[17], ref_spi_min__miso, "spi_min.miso (spi_min__miso in Verilog)");
      #(`CYCLE_TIME-`INTRA_CYCLE_TIME);
      cycle_count += 1;
    end
    endtask

	always #5 clk = ~clk;

	initial begin
		clk = 1'b0;
	end

	initial begin
		$dumpfile("grp_99_test_small.vcd");
		$dumpvars(0, grp_99_test_small_tb);
        #1;

		//Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (75) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test Mega-Project Loopback (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test Mega-Project Loopback (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	// initial begin
	// 	wait(checkbits == 16'hAB60);
	// 	$display("Monitor: Test 2 MPRJ-Logic Analyzer Started");
	// 	wait(checkbits == 16'hAB61);
	// 	$display("Monitor: Test 2 MPRJ-Logic Analyzer Passed");
	// 	$finish;
	// end

    initial begin
    //   assert(0 <= `VTB_INPUT_DELAY)
    //     else $fatal("\n=====\n\nVTB_INPUT_DELAY should >= 0\n\n=====\n");
  
    //   assert(`VTB_INPUT_DELAY < `VTB_OUTPUT_ASSERT_DELAY)
    //     else $fatal("\n=====\n\nVTB_OUTPUT_ASSERT_DELAY should be larger than VTB_INPUT_DELAY\n\n=====\n");
  
    //   assert(`VTB_OUTPUT_ASSERT_DELAY <= `CYCLE_TIME)
    //     else $fatal("\n=====\n\nVTB_OUTPUT_ASSERT_DELAY should be smaller than or equal to CYCLE_TIME\n\n=====\n");
  
      wait(checkbits == 4'hA);
    //   wait(signal == 1);
      wait(clk == 1);
      wait(clk == 0);
      cycle_count = 0;
    //   RSTB = 1'b1; // TODO reset active low/high
      reset = 1'b1;
      #(`CYCLE_TIME/2);
  
    //   // Now we are talking
      #`VTB_INPUT_DELAY;
      #`CYCLE_TIME;
      cycle_count = 1;
      #`CYCLE_TIME;
      cycle_count = 2;
      // 2 cycles plus input delay
      reset = 1'b0;
 
      // Start test
      `include "grp_99_test_small_tb.v.cases"
  
      $display("");
      $display("  [ passed ]");
      $display("");
  
      // Tick one extra cycle for better waveform
      #`CYCLE_TIME;
      cycle_count += 1;
      $finish;
    end    

	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#300000;
		CSB = 1'b0;		// CSB can be released
	end

	// initial begin
	// 	signal <= 1'b0;
    //     RSTB <= 1'b0;
	// 	// CSB  <= 1'b1;
	// 	#1000;
	// 	RSTB <= 1'b1;
    //     #1000
    //     // RSTB <= 1'b0; //Reset back to initial config
    //     signal <= 1'b1;
	// 	#300000;
	// 	// CSB = 1'b0;		// CSB can be released
	// end

	initial begin		// Power-up sequence
        power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

    	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
    	wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	assign mprj_io[3] = 1;  // Force CSB high.
	assign mprj_io[0] = 0;  // Disable debug mode
    assign mprj_io[27] = reset; //Reset
    assign mprj_io[26] = clk; //Clock

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("grp_99_test_small.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),
		.io3()
	);

endmodule
`default_nettype wire
