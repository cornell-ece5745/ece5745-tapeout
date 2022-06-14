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
`define CYCLE_TIME 4
`define INTRA_CYCLE_TIME (`VTB_OUTPUT_ASSERT_DELAY-`VTB_INPUT_DELAY)

`timescale 1 ns / 1 ps

module adder_test_tb;
	reg clock;
	reg RSTB;
    reg reset;
	reg CSB;
    integer cycle_count;
    reg power1, power2;
	reg power3, power4;

    wire gpio;
	wire [37:0] mprj_io;
	wire [3:0] checkbits;
    reg a;
    assign mprj_io[13:10] = a;
    reg b;
    assign mprj_io[17:14] = b;

	assign checkbits = mprj_io[31:28];

    always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		$dumpfile("adder_test.vcd");
		$dumpvars(0, adder_test_tb);
        #1;

		//Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (25) begin
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
      // Wait for lower edge
      wait(clock == 1);
      wait(clock == 0);
      #6;

      // Basic Test
      a = 4'b0001;
      b = 4'b0001;
      #12.5;
      if(mprj_io[21:18] != 4'b0010) begin
        $display("failed :(");
        $finish;
      end
  
      $display("");
      $display("  [ passed ]");
      $display("");
  
      // Tick one extra cycle for better waveform
      #12.5;
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
		.FILENAME("adder_test.hex")
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
