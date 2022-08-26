//========================================================================
// grp_99_test_loopback_tb
//========================================================================

`default_nettype none

//========================================================================
// Top-Level Test Harness
//========================================================================

module riscv_increment_tb;

  //----------------------------------------------------------------------
  // Create clocks
  //----------------------------------------------------------------------

  // Clock for Caravel

  reg clock = 1'b0;
  always #12.5 clock = ~clock;

  //----------------------------------------------------------------------
  // Instantiate Caravel and SPI Flash
  //----------------------------------------------------------------------

  wire        VDD3V3;
  wire        VDD1V8;
  wire        VSS;
  reg         RSTB;
  reg         CSB;

  wire        gpio;
  wire [37:0] mprj_io;

  wire        flash_csb;
  wire        flash_clk;
  wire        flash_io0;
  wire        flash_io1;

  caravel uut
  (
    .vddio     (VDD3V3),
    .vddio_2   (VDD3V3),
    .vssio     (VSS),
    .vssio_2   (VSS),
    .vdda      (VDD3V3),
    .vssa      (VSS),
    .vccd      (VDD1V8),
    .vssd      (VSS),
    .vdda1     (VDD3V3),
    .vdda1_2   (VDD3V3),
    .vdda2     (VDD3V3),
    .vssa1     (VSS),
    .vssa1_2   (VSS),
    .vssa2     (VSS),
    .vccd1     (VDD1V8),
    .vccd2     (VDD1V8),
    .vssd1     (VSS),
    .vssd2     (VSS),
    .clock     (clock),
    .gpio      (gpio),
    .mprj_io   (mprj_io),
    .flash_csb (flash_csb),
    .flash_clk (flash_clk),
    .flash_io0 (flash_io0),
    .flash_io1 (flash_io1),
    .resetb    (RSTB)
  );

  spiflash
  #(
    .FILENAME ("riscv_increment.hex")
  )
  spiflash
  (
    .csb (flash_csb),
    .clk (flash_clk),
    .io0 (flash_io0),
    .io1 (flash_io1),
    .io2 (),
    .io3 ()
  );

  //----------------------------------------------------------------------
  // Power-up and reset sequence
  //----------------------------------------------------------------------

  initial begin
    RSTB <= 1'b0;
    CSB  <= 1'b1;   // Force CSB high
    #2000;
    RSTB <= 1'b1;   // Release reset
    #300000;
    CSB = 1'b0;     // CSB can be released
  end

  reg power1;
  reg power2;
  reg power3;
  reg power4;

  initial begin
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

  assign VDD3V3 = power1;
  assign VDD1V8 = power2;
  assign VSS    = 1'b0;
  wire  [3:0] checkbits;
  assign checkbits      = mprj_io[31:28];
  wire  [3:0] count;
  assign count          = mprj_io[3:0];

  //----------------------------------------------------------------------
  // Setup VCD dumping and overall timeout
  //----------------------------------------------------------------------

  initial begin
    $dumpfile("riscv_increment.vcd");
    $dumpvars(0, riscv_increment_tb);
    #1;

    // Repeat cycles of 1000 clock edges as needed to complete testbench
    repeat (75) begin
      repeat (1000) @(posedge clock);
    end
    $display("%c[1;31m",27);
    `ifdef GL
      $display ("Monitor: Timeout GL");
    `else
      $display ("Monitor: Timeout RTL");
    `endif
    $display("%c[0m",27);
    $finish;
  end

  //----------------------------------------------------------------------
  // Wait for firmware to finish
  //----------------------------------------------------------------------

  initial begin

    // Check counting
    wait (count == 4'h0);
    wait (count == 4'h1);
    wait (count == 4'h2);
    wait (count == 4'h3);
    wait (count == 4'h4);
    wait (count == 4'h5);
    wait (count == 4'h6);
    wait (count == 4'h7);
    wait (count == 4'h8);
    wait (count == 4'h9);
    wait (count == 4'hA);
    wait (count == 4'hB);
    wait (count == 4'hC);
    wait (count == 4'hD);
    wait (count == 4'hE);
    wait (count == 4'hF);
    
    // Wait for the firmware to finish
    wait (checkbits == 4'hA);
    $display("%c[1;32m",27);
    $display("*********************************************");
    $display("*********** RISCV_INCREMENT PASS ************");
    $display("*********************************************");
    $display("%c[0m",27);
    repeat (10) @(posedge clock);
    $finish;

  end

endmodule

`default_nettype wire

