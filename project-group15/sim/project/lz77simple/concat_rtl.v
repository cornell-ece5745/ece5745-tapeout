
//------> /opt/MentorGraphics/catapult/pkgs/siflibs/ccs_out_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module ccs_out_wait_v1 (dat, irdy, vld, idat, rdy, ivld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] dat;
  output             irdy;
  output             vld;
  input  [width-1:0] idat;
  input              rdy;
  input              ivld;

  wire   [width-1:0] dat;
  wire               irdy;
  wire               vld;

  localparam stallOff = 0; 
  wire stall_ctrl;
  assign stall_ctrl = stallOff;

  assign dat = idat;
  assign irdy = rdy && !stall_ctrl;
  assign vld = ivld && !stall_ctrl;

endmodule



//------> /opt/MentorGraphics/catapult/pkgs/siflibs/ccs_in_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module ccs_in_wait_v1 (idat, rdy, ivld, dat, irdy, vld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  output             rdy;
  output             ivld;
  input  [width-1:0] dat;
  input              irdy;
  input              vld;

  wire   [width-1:0] idat;
  wire               rdy;
  wire               ivld;

  localparam stallOff = 0; 
  wire                  stall_ctrl;
  assign stall_ctrl = stallOff;

  assign idat = dat;
  assign rdy = irdy && !stall_ctrl;
  assign ivld = vld && !stall_ctrl;

endmodule


//------> /opt/MentorGraphics/catapult/pkgs/siflibs/ram_register-file_be.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module register_file_be( 
      data_in,
      addr_rd,
      addr_wr,
      re,
      we,     
      data_out,
      clk, 
      arst, 
      srst, 
      en  
      );

  // PARAMETERS
  parameter ram_id = 1;
  parameter words  = 8;
  parameter width  = 2;
  parameter addr_width  = 3;
  parameter a_reset_active = 0;
  parameter s_reset_active = 1;
  parameter enable_active = 1;
  parameter re_active = 1;
  parameter we_active = 1;
  parameter num_byte_enables = 1;
  parameter clock_edge = 1;
  parameter no_of_REGISTER_FILE_read_port = 3;
  parameter no_of_REGISTER_FILE_write_port = 3;
  parameter generate_addr_rd_reg = 1;
 
  localparam byte_width = width / num_byte_enables;

  // PORTS
  input [(no_of_REGISTER_FILE_write_port * width) - 1:0] data_in;
  input [(no_of_REGISTER_FILE_read_port * addr_width) - 1 :0] addr_rd;
  input [(no_of_REGISTER_FILE_write_port * addr_width) - 1:0] addr_wr;
  input [(num_byte_enables*no_of_REGISTER_FILE_read_port)-1:0] re;
  input [(num_byte_enables*no_of_REGISTER_FILE_write_port)-1:0] we;
  output [(no_of_REGISTER_FILE_read_port * width)-1:0] data_out; 
  // reg [no_of_REGISTER_FILE_read_port * width-1:0] data_out;
  input clk;
  input arst;
  input srst;
  input en;

  reg [width-1:0] mem[words-1:0]; 
  reg [(no_of_REGISTER_FILE_read_port * addr_width)-1:0]         addr_rd_reg;
  wire [(no_of_REGISTER_FILE_read_port * addr_width)-1:0]        addr_rd_tmp;
  reg [(no_of_REGISTER_FILE_read_port * num_byte_enables)-1:0]   re_reg;
  wire [(no_of_REGISTER_FILE_read_port * num_byte_enables)-1:0]  re_tmp;

  reg [words-1:0] mem_t1;

  integer i, j;
  generate
    if ((a_reset_active == 1'b1) && (clock_edge == 1'b1))
    begin: POSARST_POSCLK
          always@(posedge clk or posedge arst)
          begin: POSARST_POSCLK_ALWAYS
            if(arst==1'b1) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end
            else if(srst == s_reset_active) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end else begin
              if ( en == enable_active ) begin
                addr_rd_reg <= addr_rd;
                re_reg      <= re;
                for(i=0;i<no_of_REGISTER_FILE_write_port;i=i+1)
                  for (j=0; j<num_byte_enables; j=j+1)
                    if (we[(i*num_byte_enables)+j] == we_active)
                      mem[addr_wr[i*addr_width+:addr_width]][j*byte_width+:byte_width] <= data_in[(i*width)+(j*byte_width)+:byte_width];
              end
            end 
          end 
    end
    else if ((a_reset_active == 1'b0) && (clock_edge == 1'b1))
    begin: NEGARST_POSCLK
          always@(posedge clk or negedge arst)
          begin: NEGARST_POSCLK_ALWAYS
            if(arst==1'b0) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end
            else if(srst == s_reset_active) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end else begin
              if ( en == enable_active ) begin
                addr_rd_reg <= addr_rd;
                re_reg      <= re;
                for(i=0;i<no_of_REGISTER_FILE_write_port;i=i+1)
                  for (j=0; j<num_byte_enables; j=j+1)
                    if (we[(i*num_byte_enables)+j] == we_active)
                      mem[addr_wr[i*addr_width+:addr_width]][j*byte_width+:byte_width] <= data_in[(i*width)+(j*byte_width)+:byte_width];
              end 
            end 
          end 
    end 
    else if ((a_reset_active == 1'b1) && (clock_edge == 1'b0))
    begin: POSARST_NEGCLK
          always@(negedge clk or posedge arst)
          begin: POSARST_NEGCLK_ALWAYS
            if(arst==1'b1) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end
            else if(srst == s_reset_active) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end else begin
              if ( en == enable_active ) begin
                addr_rd_reg <= addr_rd;
                re_reg      <= re;
                for(i=0;i<no_of_REGISTER_FILE_write_port;i=i+1)
                  for (j=0; j<num_byte_enables; j=j+1)
                    if (we[(i*num_byte_enables)+j] == we_active)
                      mem[addr_wr[i*addr_width+:addr_width]][j*byte_width+:byte_width] <= data_in[(i*width)+(j*byte_width)+:byte_width];
              end 
            end 
          end 
    end
    else
    begin: NEGARST_NEGCLK
          always@(negedge clk or negedge arst)
          begin: NEGARST_NEGCLK_ALWAYS
            if(arst==1'b0) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end
            else if(srst == s_reset_active) begin
              for(i=0;i<words;i=i+1)
                mem[i] <= {width{1'b0}};
              addr_rd_reg <= {(no_of_REGISTER_FILE_read_port * addr_width){1'b0}};
              re_reg      <= {(no_of_REGISTER_FILE_read_port * num_byte_enables){1'b0}};
            end else begin
              if ( en == enable_active ) begin
                addr_rd_reg <= addr_rd;
                re_reg      <= re;
                for(i=0;i<no_of_REGISTER_FILE_write_port;i=i+1)
                  for (j=0; j<num_byte_enables; j=j+1)
                    if (we[(i*num_byte_enables)+j] == we_active)
                      mem[addr_wr[i*addr_width+:addr_width]][j*byte_width+:byte_width] <= data_in[(i*width)+(j*byte_width)+:byte_width];
              end 
            end 
          end 
    end
  endgenerate

  generate
    if (generate_addr_rd_reg == 1'b1)
    begin: GENERATE_ADDR_REG_TRUE
      assign addr_rd_tmp = addr_rd_reg;
      assign re_tmp      = re_reg;
    end
    else
    begin: GENERATE_ADDR_REG_FALSE
      assign addr_rd_tmp = addr_rd;
      assign re_tmp      = re;
    end
  endgenerate


  genvar k, l;
  generate
    for(k=0; k<no_of_REGISTER_FILE_read_port;k=k+1)
    begin : READ_PORTS // Verilog 2000 syntax requires that GENERATE_
      for (l=0; l<num_byte_enables;l=l+1)
      begin : BYTE_ENABLES // Verilog 2000 syntax requires that GENERATE_
        assign data_out[(k*width)+l*byte_width+:byte_width] =
               re_tmp[(k*num_byte_enables)+l] == re_active ?
                 mem[addr_rd_tmp[addr_width*k+:addr_width]][l*byte_width+:byte_width] :
                 {(byte_width){1'bX}};
      end
    end
  endgenerate
endmodule

//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2021.1/950854 Production Release
//  HLS Date:       Mon Aug  2 21:36:02 PDT 2021
// 
//  Generated by:   ct652@en-ec-ecelinux-13.coecis.cornell.edu
//  Generated date: Tue May 17 17:42:24 2022
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    lz77simple_ram_nangate_45nm_register_file_beh_REGISTER_FILE_rwport_en_3_512_32_9_0_1_0_0_0_1_1_1_1_gen
// ------------------------------------------------------------------


module lz77simple_ram_nangate_45nm_register_file_beh_REGISTER_FILE_rwport_en_3_512_32_9_0_1_0_0_0_1_1_1_1_gen
    (
  en, we, addr_wr, data_in, data_out, re, addr_rd, data_in_d, addr_rd_d, addr_wr_d,
      re_d, we_d, data_out_d, en_d
);
  output en;
  output we;
  output [8:0] addr_wr;
  output [31:0] data_in;
  input [31:0] data_out;
  output re;
  output [8:0] addr_rd;
  input [31:0] data_in_d;
  input [8:0] addr_rd_d;
  input [8:0] addr_wr_d;
  input re_d;
  input we_d;
  output [31:0] data_out_d;
  input en_d;



  // Interconnect Declarations for Component Instantiations 
  assign en = (en_d);
  assign we = (we_d);
  assign addr_wr = (addr_wr_d);
  assign data_in = (data_in_d);
  assign data_out_d = data_out;
  assign re = (re_d);
  assign addr_rd = (addr_rd_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module lz77simple_core_core_fsm (
  clk, rst, core_wen, fsm_output, main_C_0_tr0, for_C_1_tr0, for_C_3_tr0, for_C_5_tr0,
      for_C_7_tr0, for_C_9_tr0, for_C_11_tr0, for_C_13_tr0, for_C_15_tr0, for_C_17_tr0,
      for_C_19_tr0, for_C_21_tr0, for_C_23_tr0, for_C_25_tr0, for_C_27_tr0, for_C_29_tr0,
      for_C_31_tr0, for_C_33_tr0, for_C_35_tr0, for_C_37_tr0, for_C_39_tr0, for_C_41_tr0,
      for_C_43_tr0, for_C_45_tr0, for_C_47_tr0, for_C_49_tr0, for_C_51_tr0, for_C_53_tr0,
      for_C_55_tr0, for_C_57_tr0, for_C_59_tr0, for_C_61_tr0, for_C_63_tr0, main_C_3_tr0,
      while_for_1_while_C_3_tr0, while_for_2_while_C_3_tr0, while_for_3_while_C_3_tr0,
      while_for_4_while_C_3_tr0, while_for_5_while_C_3_tr0, while_for_6_while_C_3_tr0,
      while_for_7_while_C_3_tr0, while_for_8_while_C_3_tr0, while_for_9_while_C_3_tr0,
      while_C_21_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [6:0] fsm_output;
  reg [6:0] fsm_output;
  input main_C_0_tr0;
  input for_C_1_tr0;
  input for_C_3_tr0;
  input for_C_5_tr0;
  input for_C_7_tr0;
  input for_C_9_tr0;
  input for_C_11_tr0;
  input for_C_13_tr0;
  input for_C_15_tr0;
  input for_C_17_tr0;
  input for_C_19_tr0;
  input for_C_21_tr0;
  input for_C_23_tr0;
  input for_C_25_tr0;
  input for_C_27_tr0;
  input for_C_29_tr0;
  input for_C_31_tr0;
  input for_C_33_tr0;
  input for_C_35_tr0;
  input for_C_37_tr0;
  input for_C_39_tr0;
  input for_C_41_tr0;
  input for_C_43_tr0;
  input for_C_45_tr0;
  input for_C_47_tr0;
  input for_C_49_tr0;
  input for_C_51_tr0;
  input for_C_53_tr0;
  input for_C_55_tr0;
  input for_C_57_tr0;
  input for_C_59_tr0;
  input for_C_61_tr0;
  input for_C_63_tr0;
  input main_C_3_tr0;
  input while_for_1_while_C_3_tr0;
  input while_for_2_while_C_3_tr0;
  input while_for_3_while_C_3_tr0;
  input while_for_4_while_C_3_tr0;
  input while_for_5_while_C_3_tr0;
  input while_for_6_while_C_3_tr0;
  input while_for_7_while_C_3_tr0;
  input while_for_8_while_C_3_tr0;
  input while_for_9_while_C_3_tr0;
  input while_C_21_tr0;


  // FSM State Type Declaration for lz77simple_core_core_fsm_1
  parameter
    core_rlp_C_0 = 7'd0,
    main_C_0 = 7'd1,
    for_C_0 = 7'd2,
    for_C_1 = 7'd3,
    for_C_2 = 7'd4,
    for_C_3 = 7'd5,
    for_C_4 = 7'd6,
    for_C_5 = 7'd7,
    for_C_6 = 7'd8,
    for_C_7 = 7'd9,
    for_C_8 = 7'd10,
    for_C_9 = 7'd11,
    for_C_10 = 7'd12,
    for_C_11 = 7'd13,
    for_C_12 = 7'd14,
    for_C_13 = 7'd15,
    for_C_14 = 7'd16,
    for_C_15 = 7'd17,
    for_C_16 = 7'd18,
    for_C_17 = 7'd19,
    for_C_18 = 7'd20,
    for_C_19 = 7'd21,
    for_C_20 = 7'd22,
    for_C_21 = 7'd23,
    for_C_22 = 7'd24,
    for_C_23 = 7'd25,
    for_C_24 = 7'd26,
    for_C_25 = 7'd27,
    for_C_26 = 7'd28,
    for_C_27 = 7'd29,
    for_C_28 = 7'd30,
    for_C_29 = 7'd31,
    for_C_30 = 7'd32,
    for_C_31 = 7'd33,
    for_C_32 = 7'd34,
    for_C_33 = 7'd35,
    for_C_34 = 7'd36,
    for_C_35 = 7'd37,
    for_C_36 = 7'd38,
    for_C_37 = 7'd39,
    for_C_38 = 7'd40,
    for_C_39 = 7'd41,
    for_C_40 = 7'd42,
    for_C_41 = 7'd43,
    for_C_42 = 7'd44,
    for_C_43 = 7'd45,
    for_C_44 = 7'd46,
    for_C_45 = 7'd47,
    for_C_46 = 7'd48,
    for_C_47 = 7'd49,
    for_C_48 = 7'd50,
    for_C_49 = 7'd51,
    for_C_50 = 7'd52,
    for_C_51 = 7'd53,
    for_C_52 = 7'd54,
    for_C_53 = 7'd55,
    for_C_54 = 7'd56,
    for_C_55 = 7'd57,
    for_C_56 = 7'd58,
    for_C_57 = 7'd59,
    for_C_58 = 7'd60,
    for_C_59 = 7'd61,
    for_C_60 = 7'd62,
    for_C_61 = 7'd63,
    for_C_62 = 7'd64,
    for_C_63 = 7'd65,
    main_C_1 = 7'd66,
    main_C_2 = 7'd67,
    main_C_3 = 7'd68,
    while_for_1_while_C_0 = 7'd69,
    while_for_1_while_C_1 = 7'd70,
    while_for_1_while_C_2 = 7'd71,
    while_for_1_while_C_3 = 7'd72,
    while_C_0 = 7'd73,
    while_C_1 = 7'd74,
    while_for_2_while_C_0 = 7'd75,
    while_for_2_while_C_1 = 7'd76,
    while_for_2_while_C_2 = 7'd77,
    while_for_2_while_C_3 = 7'd78,
    while_C_2 = 7'd79,
    while_C_3 = 7'd80,
    while_for_3_while_C_0 = 7'd81,
    while_for_3_while_C_1 = 7'd82,
    while_for_3_while_C_2 = 7'd83,
    while_for_3_while_C_3 = 7'd84,
    while_C_4 = 7'd85,
    while_C_5 = 7'd86,
    while_for_4_while_C_0 = 7'd87,
    while_for_4_while_C_1 = 7'd88,
    while_for_4_while_C_2 = 7'd89,
    while_for_4_while_C_3 = 7'd90,
    while_C_6 = 7'd91,
    while_C_7 = 7'd92,
    while_for_5_while_C_0 = 7'd93,
    while_for_5_while_C_1 = 7'd94,
    while_for_5_while_C_2 = 7'd95,
    while_for_5_while_C_3 = 7'd96,
    while_C_8 = 7'd97,
    while_C_9 = 7'd98,
    while_for_6_while_C_0 = 7'd99,
    while_for_6_while_C_1 = 7'd100,
    while_for_6_while_C_2 = 7'd101,
    while_for_6_while_C_3 = 7'd102,
    while_C_10 = 7'd103,
    while_C_11 = 7'd104,
    while_for_7_while_C_0 = 7'd105,
    while_for_7_while_C_1 = 7'd106,
    while_for_7_while_C_2 = 7'd107,
    while_for_7_while_C_3 = 7'd108,
    while_C_12 = 7'd109,
    while_C_13 = 7'd110,
    while_for_8_while_C_0 = 7'd111,
    while_for_8_while_C_1 = 7'd112,
    while_for_8_while_C_2 = 7'd113,
    while_for_8_while_C_3 = 7'd114,
    while_C_14 = 7'd115,
    while_C_15 = 7'd116,
    while_for_9_while_C_0 = 7'd117,
    while_for_9_while_C_1 = 7'd118,
    while_for_9_while_C_2 = 7'd119,
    while_for_9_while_C_3 = 7'd120,
    while_C_16 = 7'd121,
    while_C_17 = 7'd122,
    while_C_18 = 7'd123,
    while_C_19 = 7'd124,
    while_C_20 = 7'd125,
    while_C_21 = 7'd126;

  reg [6:0] state_var;
  reg [6:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : lz77simple_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 7'b0000001;
        if ( main_C_0_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_0;
        end
      end
      for_C_0 : begin
        fsm_output = 7'b0000010;
        state_var_NS = for_C_1;
      end
      for_C_1 : begin
        fsm_output = 7'b0000011;
        if ( for_C_1_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_2;
        end
      end
      for_C_2 : begin
        fsm_output = 7'b0000100;
        state_var_NS = for_C_3;
      end
      for_C_3 : begin
        fsm_output = 7'b0000101;
        if ( for_C_3_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_4;
        end
      end
      for_C_4 : begin
        fsm_output = 7'b0000110;
        state_var_NS = for_C_5;
      end
      for_C_5 : begin
        fsm_output = 7'b0000111;
        if ( for_C_5_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_6;
        end
      end
      for_C_6 : begin
        fsm_output = 7'b0001000;
        state_var_NS = for_C_7;
      end
      for_C_7 : begin
        fsm_output = 7'b0001001;
        if ( for_C_7_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_8;
        end
      end
      for_C_8 : begin
        fsm_output = 7'b0001010;
        state_var_NS = for_C_9;
      end
      for_C_9 : begin
        fsm_output = 7'b0001011;
        if ( for_C_9_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_10;
        end
      end
      for_C_10 : begin
        fsm_output = 7'b0001100;
        state_var_NS = for_C_11;
      end
      for_C_11 : begin
        fsm_output = 7'b0001101;
        if ( for_C_11_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_12;
        end
      end
      for_C_12 : begin
        fsm_output = 7'b0001110;
        state_var_NS = for_C_13;
      end
      for_C_13 : begin
        fsm_output = 7'b0001111;
        if ( for_C_13_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_14;
        end
      end
      for_C_14 : begin
        fsm_output = 7'b0010000;
        state_var_NS = for_C_15;
      end
      for_C_15 : begin
        fsm_output = 7'b0010001;
        if ( for_C_15_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_16;
        end
      end
      for_C_16 : begin
        fsm_output = 7'b0010010;
        state_var_NS = for_C_17;
      end
      for_C_17 : begin
        fsm_output = 7'b0010011;
        if ( for_C_17_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_18;
        end
      end
      for_C_18 : begin
        fsm_output = 7'b0010100;
        state_var_NS = for_C_19;
      end
      for_C_19 : begin
        fsm_output = 7'b0010101;
        if ( for_C_19_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_20;
        end
      end
      for_C_20 : begin
        fsm_output = 7'b0010110;
        state_var_NS = for_C_21;
      end
      for_C_21 : begin
        fsm_output = 7'b0010111;
        if ( for_C_21_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_22;
        end
      end
      for_C_22 : begin
        fsm_output = 7'b0011000;
        state_var_NS = for_C_23;
      end
      for_C_23 : begin
        fsm_output = 7'b0011001;
        if ( for_C_23_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_24;
        end
      end
      for_C_24 : begin
        fsm_output = 7'b0011010;
        state_var_NS = for_C_25;
      end
      for_C_25 : begin
        fsm_output = 7'b0011011;
        if ( for_C_25_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_26;
        end
      end
      for_C_26 : begin
        fsm_output = 7'b0011100;
        state_var_NS = for_C_27;
      end
      for_C_27 : begin
        fsm_output = 7'b0011101;
        if ( for_C_27_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_28;
        end
      end
      for_C_28 : begin
        fsm_output = 7'b0011110;
        state_var_NS = for_C_29;
      end
      for_C_29 : begin
        fsm_output = 7'b0011111;
        if ( for_C_29_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_30;
        end
      end
      for_C_30 : begin
        fsm_output = 7'b0100000;
        state_var_NS = for_C_31;
      end
      for_C_31 : begin
        fsm_output = 7'b0100001;
        if ( for_C_31_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_32;
        end
      end
      for_C_32 : begin
        fsm_output = 7'b0100010;
        state_var_NS = for_C_33;
      end
      for_C_33 : begin
        fsm_output = 7'b0100011;
        if ( for_C_33_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_34;
        end
      end
      for_C_34 : begin
        fsm_output = 7'b0100100;
        state_var_NS = for_C_35;
      end
      for_C_35 : begin
        fsm_output = 7'b0100101;
        if ( for_C_35_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_36;
        end
      end
      for_C_36 : begin
        fsm_output = 7'b0100110;
        state_var_NS = for_C_37;
      end
      for_C_37 : begin
        fsm_output = 7'b0100111;
        if ( for_C_37_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_38;
        end
      end
      for_C_38 : begin
        fsm_output = 7'b0101000;
        state_var_NS = for_C_39;
      end
      for_C_39 : begin
        fsm_output = 7'b0101001;
        if ( for_C_39_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_40;
        end
      end
      for_C_40 : begin
        fsm_output = 7'b0101010;
        state_var_NS = for_C_41;
      end
      for_C_41 : begin
        fsm_output = 7'b0101011;
        if ( for_C_41_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_42;
        end
      end
      for_C_42 : begin
        fsm_output = 7'b0101100;
        state_var_NS = for_C_43;
      end
      for_C_43 : begin
        fsm_output = 7'b0101101;
        if ( for_C_43_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_44;
        end
      end
      for_C_44 : begin
        fsm_output = 7'b0101110;
        state_var_NS = for_C_45;
      end
      for_C_45 : begin
        fsm_output = 7'b0101111;
        if ( for_C_45_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_46;
        end
      end
      for_C_46 : begin
        fsm_output = 7'b0110000;
        state_var_NS = for_C_47;
      end
      for_C_47 : begin
        fsm_output = 7'b0110001;
        if ( for_C_47_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_48;
        end
      end
      for_C_48 : begin
        fsm_output = 7'b0110010;
        state_var_NS = for_C_49;
      end
      for_C_49 : begin
        fsm_output = 7'b0110011;
        if ( for_C_49_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_50;
        end
      end
      for_C_50 : begin
        fsm_output = 7'b0110100;
        state_var_NS = for_C_51;
      end
      for_C_51 : begin
        fsm_output = 7'b0110101;
        if ( for_C_51_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_52;
        end
      end
      for_C_52 : begin
        fsm_output = 7'b0110110;
        state_var_NS = for_C_53;
      end
      for_C_53 : begin
        fsm_output = 7'b0110111;
        if ( for_C_53_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_54;
        end
      end
      for_C_54 : begin
        fsm_output = 7'b0111000;
        state_var_NS = for_C_55;
      end
      for_C_55 : begin
        fsm_output = 7'b0111001;
        if ( for_C_55_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_56;
        end
      end
      for_C_56 : begin
        fsm_output = 7'b0111010;
        state_var_NS = for_C_57;
      end
      for_C_57 : begin
        fsm_output = 7'b0111011;
        if ( for_C_57_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_58;
        end
      end
      for_C_58 : begin
        fsm_output = 7'b0111100;
        state_var_NS = for_C_59;
      end
      for_C_59 : begin
        fsm_output = 7'b0111101;
        if ( for_C_59_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_60;
        end
      end
      for_C_60 : begin
        fsm_output = 7'b0111110;
        state_var_NS = for_C_61;
      end
      for_C_61 : begin
        fsm_output = 7'b0111111;
        if ( for_C_61_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_62;
        end
      end
      for_C_62 : begin
        fsm_output = 7'b1000000;
        state_var_NS = for_C_63;
      end
      for_C_63 : begin
        fsm_output = 7'b1000001;
        if ( for_C_63_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = for_C_0;
        end
      end
      main_C_1 : begin
        fsm_output = 7'b1000010;
        state_var_NS = main_C_2;
      end
      main_C_2 : begin
        fsm_output = 7'b1000011;
        state_var_NS = main_C_3;
      end
      main_C_3 : begin
        fsm_output = 7'b1000100;
        if ( main_C_3_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = while_for_1_while_C_0;
        end
      end
      while_for_1_while_C_0 : begin
        fsm_output = 7'b1000101;
        state_var_NS = while_for_1_while_C_1;
      end
      while_for_1_while_C_1 : begin
        fsm_output = 7'b1000110;
        state_var_NS = while_for_1_while_C_2;
      end
      while_for_1_while_C_2 : begin
        fsm_output = 7'b1000111;
        state_var_NS = while_for_1_while_C_3;
      end
      while_for_1_while_C_3 : begin
        fsm_output = 7'b1001000;
        if ( while_for_1_while_C_3_tr0 ) begin
          state_var_NS = while_C_0;
        end
        else begin
          state_var_NS = while_for_1_while_C_0;
        end
      end
      while_C_0 : begin
        fsm_output = 7'b1001001;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 7'b1001010;
        state_var_NS = while_for_2_while_C_0;
      end
      while_for_2_while_C_0 : begin
        fsm_output = 7'b1001011;
        state_var_NS = while_for_2_while_C_1;
      end
      while_for_2_while_C_1 : begin
        fsm_output = 7'b1001100;
        state_var_NS = while_for_2_while_C_2;
      end
      while_for_2_while_C_2 : begin
        fsm_output = 7'b1001101;
        state_var_NS = while_for_2_while_C_3;
      end
      while_for_2_while_C_3 : begin
        fsm_output = 7'b1001110;
        if ( while_for_2_while_C_3_tr0 ) begin
          state_var_NS = while_C_2;
        end
        else begin
          state_var_NS = while_for_2_while_C_0;
        end
      end
      while_C_2 : begin
        fsm_output = 7'b1001111;
        state_var_NS = while_C_3;
      end
      while_C_3 : begin
        fsm_output = 7'b1010000;
        state_var_NS = while_for_3_while_C_0;
      end
      while_for_3_while_C_0 : begin
        fsm_output = 7'b1010001;
        state_var_NS = while_for_3_while_C_1;
      end
      while_for_3_while_C_1 : begin
        fsm_output = 7'b1010010;
        state_var_NS = while_for_3_while_C_2;
      end
      while_for_3_while_C_2 : begin
        fsm_output = 7'b1010011;
        state_var_NS = while_for_3_while_C_3;
      end
      while_for_3_while_C_3 : begin
        fsm_output = 7'b1010100;
        if ( while_for_3_while_C_3_tr0 ) begin
          state_var_NS = while_C_4;
        end
        else begin
          state_var_NS = while_for_3_while_C_0;
        end
      end
      while_C_4 : begin
        fsm_output = 7'b1010101;
        state_var_NS = while_C_5;
      end
      while_C_5 : begin
        fsm_output = 7'b1010110;
        state_var_NS = while_for_4_while_C_0;
      end
      while_for_4_while_C_0 : begin
        fsm_output = 7'b1010111;
        state_var_NS = while_for_4_while_C_1;
      end
      while_for_4_while_C_1 : begin
        fsm_output = 7'b1011000;
        state_var_NS = while_for_4_while_C_2;
      end
      while_for_4_while_C_2 : begin
        fsm_output = 7'b1011001;
        state_var_NS = while_for_4_while_C_3;
      end
      while_for_4_while_C_3 : begin
        fsm_output = 7'b1011010;
        if ( while_for_4_while_C_3_tr0 ) begin
          state_var_NS = while_C_6;
        end
        else begin
          state_var_NS = while_for_4_while_C_0;
        end
      end
      while_C_6 : begin
        fsm_output = 7'b1011011;
        state_var_NS = while_C_7;
      end
      while_C_7 : begin
        fsm_output = 7'b1011100;
        state_var_NS = while_for_5_while_C_0;
      end
      while_for_5_while_C_0 : begin
        fsm_output = 7'b1011101;
        state_var_NS = while_for_5_while_C_1;
      end
      while_for_5_while_C_1 : begin
        fsm_output = 7'b1011110;
        state_var_NS = while_for_5_while_C_2;
      end
      while_for_5_while_C_2 : begin
        fsm_output = 7'b1011111;
        state_var_NS = while_for_5_while_C_3;
      end
      while_for_5_while_C_3 : begin
        fsm_output = 7'b1100000;
        if ( while_for_5_while_C_3_tr0 ) begin
          state_var_NS = while_C_8;
        end
        else begin
          state_var_NS = while_for_5_while_C_0;
        end
      end
      while_C_8 : begin
        fsm_output = 7'b1100001;
        state_var_NS = while_C_9;
      end
      while_C_9 : begin
        fsm_output = 7'b1100010;
        state_var_NS = while_for_6_while_C_0;
      end
      while_for_6_while_C_0 : begin
        fsm_output = 7'b1100011;
        state_var_NS = while_for_6_while_C_1;
      end
      while_for_6_while_C_1 : begin
        fsm_output = 7'b1100100;
        state_var_NS = while_for_6_while_C_2;
      end
      while_for_6_while_C_2 : begin
        fsm_output = 7'b1100101;
        state_var_NS = while_for_6_while_C_3;
      end
      while_for_6_while_C_3 : begin
        fsm_output = 7'b1100110;
        if ( while_for_6_while_C_3_tr0 ) begin
          state_var_NS = while_C_10;
        end
        else begin
          state_var_NS = while_for_6_while_C_0;
        end
      end
      while_C_10 : begin
        fsm_output = 7'b1100111;
        state_var_NS = while_C_11;
      end
      while_C_11 : begin
        fsm_output = 7'b1101000;
        state_var_NS = while_for_7_while_C_0;
      end
      while_for_7_while_C_0 : begin
        fsm_output = 7'b1101001;
        state_var_NS = while_for_7_while_C_1;
      end
      while_for_7_while_C_1 : begin
        fsm_output = 7'b1101010;
        state_var_NS = while_for_7_while_C_2;
      end
      while_for_7_while_C_2 : begin
        fsm_output = 7'b1101011;
        state_var_NS = while_for_7_while_C_3;
      end
      while_for_7_while_C_3 : begin
        fsm_output = 7'b1101100;
        if ( while_for_7_while_C_3_tr0 ) begin
          state_var_NS = while_C_12;
        end
        else begin
          state_var_NS = while_for_7_while_C_0;
        end
      end
      while_C_12 : begin
        fsm_output = 7'b1101101;
        state_var_NS = while_C_13;
      end
      while_C_13 : begin
        fsm_output = 7'b1101110;
        state_var_NS = while_for_8_while_C_0;
      end
      while_for_8_while_C_0 : begin
        fsm_output = 7'b1101111;
        state_var_NS = while_for_8_while_C_1;
      end
      while_for_8_while_C_1 : begin
        fsm_output = 7'b1110000;
        state_var_NS = while_for_8_while_C_2;
      end
      while_for_8_while_C_2 : begin
        fsm_output = 7'b1110001;
        state_var_NS = while_for_8_while_C_3;
      end
      while_for_8_while_C_3 : begin
        fsm_output = 7'b1110010;
        if ( while_for_8_while_C_3_tr0 ) begin
          state_var_NS = while_C_14;
        end
        else begin
          state_var_NS = while_for_8_while_C_0;
        end
      end
      while_C_14 : begin
        fsm_output = 7'b1110011;
        state_var_NS = while_C_15;
      end
      while_C_15 : begin
        fsm_output = 7'b1110100;
        state_var_NS = while_for_9_while_C_0;
      end
      while_for_9_while_C_0 : begin
        fsm_output = 7'b1110101;
        state_var_NS = while_for_9_while_C_1;
      end
      while_for_9_while_C_1 : begin
        fsm_output = 7'b1110110;
        state_var_NS = while_for_9_while_C_2;
      end
      while_for_9_while_C_2 : begin
        fsm_output = 7'b1110111;
        state_var_NS = while_for_9_while_C_3;
      end
      while_for_9_while_C_3 : begin
        fsm_output = 7'b1111000;
        if ( while_for_9_while_C_3_tr0 ) begin
          state_var_NS = while_C_16;
        end
        else begin
          state_var_NS = while_for_9_while_C_0;
        end
      end
      while_C_16 : begin
        fsm_output = 7'b1111001;
        state_var_NS = while_C_17;
      end
      while_C_17 : begin
        fsm_output = 7'b1111010;
        state_var_NS = while_C_18;
      end
      while_C_18 : begin
        fsm_output = 7'b1111011;
        state_var_NS = while_C_19;
      end
      while_C_19 : begin
        fsm_output = 7'b1111100;
        state_var_NS = while_C_20;
      end
      while_C_20 : begin
        fsm_output = 7'b1111101;
        state_var_NS = while_C_21;
      end
      while_C_21 : begin
        fsm_output = 7'b1111110;
        if ( while_C_21_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = while_for_1_while_C_0;
        end
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 7'b0000000;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_staller
// ------------------------------------------------------------------


module lz77simple_core_staller (
  core_wen, dest_rsci_wen_comp, src_rsci_wen_comp
);
  output core_wen;
  input dest_rsci_wen_comp;
  input src_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = dest_rsci_wen_comp & src_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_wait_dp
// ------------------------------------------------------------------


module lz77simple_core_wait_dp (
  srcbuf_rsci_en_d, core_wen, srcbuf_rsci_cgo, srcbuf_rsci_cgo_ir_unreg
);
  output srcbuf_rsci_en_d;
  input core_wen;
  input srcbuf_rsci_cgo;
  input srcbuf_rsci_cgo_ir_unreg;



  // Interconnect Declarations for Component Instantiations 
  assign srcbuf_rsci_en_d = ~(core_wen & (srcbuf_rsci_cgo | srcbuf_rsci_cgo_ir_unreg));
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_src_rsci_src_wait_ctrl
// ------------------------------------------------------------------


module lz77simple_core_src_rsci_src_wait_ctrl (
  src_rsci_iswt0, src_rsci_biwt, src_rsci_ivld
);
  input src_rsci_iswt0;
  output src_rsci_biwt;
  input src_rsci_ivld;



  // Interconnect Declarations for Component Instantiations 
  assign src_rsci_biwt = src_rsci_iswt0 & src_rsci_ivld;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_dest_rsci_dest_wait_ctrl
// ------------------------------------------------------------------


module lz77simple_core_dest_rsci_dest_wait_ctrl (
  dest_rsci_iswt0, dest_rsci_biwt, dest_rsci_irdy
);
  input dest_rsci_iswt0;
  output dest_rsci_biwt;
  input dest_rsci_irdy;



  // Interconnect Declarations for Component Instantiations 
  assign dest_rsci_biwt = dest_rsci_iswt0 & dest_rsci_irdy;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_src_rsci
// ------------------------------------------------------------------


module lz77simple_core_src_rsci (
  src_rsc_dat, src_rsc_vld, src_rsc_rdy, src_rsci_oswt, src_rsci_wen_comp, src_rsci_idat_mxwt
);
  input [31:0] src_rsc_dat;
  input src_rsc_vld;
  output src_rsc_rdy;
  input src_rsci_oswt;
  output src_rsci_wen_comp;
  output [31:0] src_rsci_idat_mxwt;


  // Interconnect Declarations
  wire src_rsci_biwt;
  wire src_rsci_ivld;
  wire [31:0] src_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd2),
  .width(32'sd32)) src_rsci (
      .rdy(src_rsc_rdy),
      .vld(src_rsc_vld),
      .dat(src_rsc_dat),
      .irdy(src_rsci_oswt),
      .ivld(src_rsci_ivld),
      .idat(src_rsci_idat)
    );
  lz77simple_core_src_rsci_src_wait_ctrl lz77simple_core_src_rsci_src_wait_ctrl_inst
      (
      .src_rsci_iswt0(src_rsci_oswt),
      .src_rsci_biwt(src_rsci_biwt),
      .src_rsci_ivld(src_rsci_ivld)
    );
  assign src_rsci_idat_mxwt = src_rsci_idat;
  assign src_rsci_wen_comp = (~ src_rsci_oswt) | src_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core_dest_rsci
// ------------------------------------------------------------------


module lz77simple_core_dest_rsci (
  dest_rsc_dat, dest_rsc_vld, dest_rsc_rdy, dest_rsci_oswt, dest_rsci_wen_comp, dest_rsci_idat
);
  output [31:0] dest_rsc_dat;
  output dest_rsc_vld;
  input dest_rsc_rdy;
  input dest_rsci_oswt;
  output dest_rsci_wen_comp;
  input [31:0] dest_rsci_idat;


  // Interconnect Declarations
  wire dest_rsci_biwt;
  wire dest_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_wait_v1 #(.rscid(32'sd1),
  .width(32'sd32)) dest_rsci (
      .irdy(dest_rsci_irdy),
      .ivld(dest_rsci_oswt),
      .idat(dest_rsci_idat),
      .rdy(dest_rsc_rdy),
      .vld(dest_rsc_vld),
      .dat(dest_rsc_dat)
    );
  lz77simple_core_dest_rsci_dest_wait_ctrl lz77simple_core_dest_rsci_dest_wait_ctrl_inst
      (
      .dest_rsci_iswt0(dest_rsci_oswt),
      .dest_rsci_biwt(dest_rsci_biwt),
      .dest_rsci_irdy(dest_rsci_irdy)
    );
  assign dest_rsci_wen_comp = (~ dest_rsci_oswt) | dest_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple_core
// ------------------------------------------------------------------


module lz77simple_core (
  clk, rst, dest_rsc_dat, dest_rsc_vld, dest_rsc_rdy, src_rsc_dat, src_rsc_vld, src_rsc_rdy,
      srcbuf_rsci_data_in_d, srcbuf_rsci_addr_rd_d, srcbuf_rsci_addr_wr_d, srcbuf_rsci_re_d,
      srcbuf_rsci_we_d, srcbuf_rsci_data_out_d, srcbuf_rsci_en_d
);
  input clk;
  input rst;
  output [31:0] dest_rsc_dat;
  output dest_rsc_vld;
  input dest_rsc_rdy;
  input [31:0] src_rsc_dat;
  input src_rsc_vld;
  output src_rsc_rdy;
  output [31:0] srcbuf_rsci_data_in_d;
  output [8:0] srcbuf_rsci_addr_rd_d;
  output [8:0] srcbuf_rsci_addr_wr_d;
  output srcbuf_rsci_re_d;
  output srcbuf_rsci_we_d;
  input [31:0] srcbuf_rsci_data_out_d;
  output srcbuf_rsci_en_d;


  // Interconnect Declarations
  wire core_wen;
  wire dest_rsci_wen_comp;
  reg [31:0] dest_rsci_idat;
  wire src_rsci_wen_comp;
  wire [31:0] src_rsci_idat_mxwt;
  wire [6:0] fsm_output;
  wire [31:0] while_for_mux_16_tmp;
  wire while_for_3_while_aif_equal_tmp;
  wire nor_tmp_1;
  wire mux_tmp_2;
  wire nor_tmp_6;
  wire mux_tmp_13;
  wire mux_tmp_42;
  wire and_tmp;
  wire and_dcpl_12;
  wire mux_tmp_74;
  wire or_dcpl_298;
  wire or_tmp_68;
  wire not_tmp_193;
  wire mux_tmp_119;
  wire or_tmp_73;
  wire mux_tmp_120;
  wire mux_tmp_122;
  wire mux_tmp_125;
  wire mux_tmp_147;
  wire and_dcpl_116;
  wire and_dcpl_117;
  wire and_dcpl_118;
  wire and_dcpl_120;
  wire and_dcpl_124;
  wire and_dcpl_127;
  wire and_dcpl_128;
  wire and_dcpl_129;
  wire and_dcpl_130;
  wire and_dcpl_168;
  wire and_dcpl_169;
  wire and_dcpl_171;
  wire and_dcpl_172;
  wire nor_tmp_46;
  wire or_tmp_113;
  wire or_tmp_114;
  wire or_tmp_116;
  wire mux_tmp_262;
  wire nor_tmp_49;
  wire nor_tmp_53;
  wire nor_tmp_54;
  wire nor_tmp_56;
  wire nor_tmp_57;
  wire nor_tmp_59;
  wire nor_tmp_61;
  wire and_dcpl_177;
  wire and_dcpl_178;
  wire and_dcpl_179;
  wire and_dcpl_180;
  wire and_dcpl_181;
  wire and_dcpl_182;
  wire and_dcpl_183;
  wire and_dcpl_184;
  wire and_dcpl_185;
  wire and_dcpl_186;
  wire and_dcpl_187;
  wire and_dcpl_188;
  wire and_dcpl_190;
  wire and_dcpl_191;
  wire and_dcpl_192;
  wire and_dcpl_194;
  wire and_dcpl_195;
  wire and_dcpl_196;
  wire and_dcpl_198;
  wire and_dcpl_200;
  wire and_dcpl_201;
  wire and_dcpl_204;
  wire and_dcpl_205;
  wire and_dcpl_207;
  wire and_dcpl_211;
  wire and_dcpl_213;
  wire and_dcpl_217;
  wire and_dcpl_219;
  wire mux_tmp_300;
  wire nor_tmp_71;
  wire or_tmp_133;
  wire not_tmp_299;
  wire mux_tmp_309;
  wire and_dcpl_228;
  wire and_dcpl_231;
  wire and_dcpl_239;
  wire and_dcpl_241;
  wire or_dcpl_365;
  wire or_tmp_138;
  wire and_dcpl_281;
  wire and_dcpl_283;
  wire and_dcpl_284;
  wire and_dcpl_287;
  wire or_tmp_144;
  wire mux_tmp_326;
  wire not_tmp_348;
  wire mux_tmp_331;
  wire and_dcpl_291;
  wire mux_tmp_335;
  wire or_tmp_154;
  wire or_tmp_158;
  wire mux_tmp_349;
  wire mux_tmp_351;
  wire mux_tmp_353;
  wire mux_tmp_354;
  wire and_dcpl_302;
  wire mux_tmp_357;
  wire mux_tmp_358;
  wire mux_tmp_368;
  wire mux_tmp_374;
  wire or_tmp_168;
  wire or_tmp_170;
  wire mux_tmp_383;
  wire and_dcpl_315;
  wire and_dcpl_316;
  wire and_dcpl_321;
  wire mux_tmp_403;
  wire mux_tmp_406;
  wire mux_tmp_434;
  wire mux_tmp_456;
  wire mux_tmp_457;
  wire nor_tmp_98;
  wire or_tmp_204;
  wire mux_tmp_468;
  wire mux_tmp_471;
  wire or_tmp_205;
  reg for_10_slc_32_itm;
  reg for_slc_for_acc_3_30_itm;
  reg for_13_slc_32_itm;
  reg for_14_slc_32_itm;
  reg for_15_slc_32_itm;
  reg for_slc_for_acc_4_28_itm;
  reg for_17_slc_32_itm;
  reg for_18_slc_32_itm;
  reg for_19_slc_32_itm;
  reg for_slc_for_acc_2_29_itm;
  reg while_for_while_for_while_for_nor_1_itm_2;
  reg for_11_slc_32_itm;
  reg for_slc_for_acc_6_29_itm;
  reg for_25_slc_32_itm;
  reg for_26_slc_32_itm;
  reg for_27_slc_32_itm;
  reg for_31_slc_32_itm;
  reg for_slc_for_acc_8_27_itm;
  reg for_1_slc_32_itm;
  reg [31:0] N_sva;
  reg [31:0] while_for_k_1_sva;
  wire while_and_rgt;
  reg reg_srcbuf_rsci_cgo_ir_cse;
  reg reg_src_rsci_iswt0_cse;
  reg reg_dest_rsci_iswt0_cse;
  wire nor_201_cse;
  wire or_461_cse;
  wire or_291_cse;
  wire nor_110_cse;
  wire nor_268_cse;
  wire and_441_cse;
  wire and_443_cse;
  wire or_533_cse;
  wire or_538_cse;
  wire or_529_cse;
  wire nor_208_cse;
  wire or_584_cse;
  wire mux_220_cse;
  wire mux_219_cse;
  wire mux_206_cse;
  wire and_396_cse;
  wire mux_218_cse;
  wire mux_200_cse;
  wire or_602_cse;
  wire and_378_cse;
  wire nor_128_cse;
  wire and_436_cse;
  wire mux_48_cse;
  wire mux_199_cse;
  wire mux_197_cse;
  wire mux_44_cse;
  wire mux_24_cse;
  wire mux_223_cse;
  wire mux_132_rmff;
  reg [3:0] for_slc_s_1_31_5_3_0_30_itm;
  wire srcbuf_rsci_addr_wr_d_mx0c32;
  wire srcbuf_rsci_addr_wr_d_mx0c0;
  reg [8:0] while_for_1_while_aif_acc_3_itm;
  wire while_L_lpi_2_dfm_mx0c1;
  wire [26:0] s_1_31_5_sva_2;
  wire [27:0] nl_s_1_31_5_sva_2;
  wire [31:0] while_for_1_while_acc_3;
  wire [32:0] nl_while_for_1_while_acc_3;
  wire or_607_tmp;
  wire and_dcpl_356;
  wire and_dcpl_357;
  wire and_dcpl_361;
  wire and_dcpl_365;
  wire and_dcpl_368;
  wire and_dcpl_370;
  wire [32:0] z_out_1;
  wire and_dcpl_372;
  wire and_dcpl_381;
  wire and_dcpl_404;
  wire and_dcpl_405;
  wire and_dcpl_409;
  wire and_dcpl_414;
  wire and_dcpl_415;
  wire and_dcpl_417;
  wire and_dcpl_419;
  wire and_dcpl_421;
  wire and_dcpl_425;
  wire and_dcpl_430;
  wire and_dcpl_434;
  wire and_dcpl_436;
  wire and_dcpl_437;
  wire and_dcpl_439;
  wire and_dcpl_442;
  wire and_dcpl_446;
  wire [32:0] z_out_5;
  wire and_dcpl_454;
  wire and_dcpl_457;
  wire and_dcpl_460;
  wire and_dcpl_463;
  wire and_dcpl_469;
  wire and_dcpl_471;
  wire and_dcpl_475;
  wire and_dcpl_478;
  wire and_dcpl_484;
  wire and_dcpl_490;
  wire and_dcpl_494;
  wire and_dcpl_496;
  wire and_dcpl_499;
  wire and_dcpl_504;
  wire and_dcpl_506;
  wire and_dcpl_512;
  wire and_dcpl_515;
  wire and_dcpl_519;
  wire and_dcpl_524;
  wire and_dcpl_526;
  wire and_dcpl_527;
  wire and_dcpl_536;
  wire and_dcpl_542;
  wire and_dcpl_544;
  wire and_dcpl_548;
  wire [8:0] z_out_12;
  wire [9:0] nl_z_out_12;
  wire [8:0] z_out_13;
  wire [9:0] nl_z_out_13;
  wire and_dcpl_567;
  reg [31:0] while_for_while_aelse_asn_36_itm;
  reg [31:0] while_for_1_while_acc_2_itm;
  wire dest_rsci_idat_mx0c1;
  wire dest_rsci_idat_mx0c4;
  wire dest_rsci_idat_mx0c5;
  wire while_for_land_3_lpi_2_dfm_mx0w2;
  wire [31:0] while_L_lpi_2_dfm_8_mx0;
  wire mux_493_cse;
  wire [7:0] while_for_while_aelse_acc_11_sdt;
  wire [8:0] nl_while_for_while_aelse_acc_11_sdt;
  wire and_519_ssc;
  wire for_or_2_ssc;
  wire mux_486_cse;
  wire or_tmp_219;
  wire [31:0] i_mux1h_5_rgt;
  wire not_tmp_535;
  wire mux_tmp_513;
  wire mux_tmp_517;
  wire not_tmp_537;
  wire mux_tmp_523;
  wire or_tmp_236;
  wire [31:0] mux1h_rgt;
  reg [4:0] i_sva_31_27;
  reg [26:0] i_sva_26_0;
  reg [4:0] reg_while_L_lpi_2_dfm_reg;
  reg [26:0] reg_while_L_lpi_2_dfm_1_reg;
  wire nor_204_cse;
  wire and_698_cse;
  wire and_696_cse;
  wire and_702_cse;
  wire nor_359_cse;
  wire or_642_cse;
  wire nand_66_cse;
  wire mux_508_cse;
  wire mux_194_itm;
  wire for_or_30_itm;
  wire for_or_36_itm;
  wire for_or_39_itm;
  wire for_or_43_itm;
  wire for_or_45_itm;
  wire while_else_acc_itm_32;
  wire while_for_3_aif_acc_1_itm_32;
  wire for_1_acc_2_itm_32_1;
  wire [2:0] z_out_4_32_30;
  wire [5:0] z_out_6_32_27;
  wire z_out_7_32;
  wire z_out_8_32;
  wire [2:0] z_out_9_32_30;
  wire [2:0] z_out_10_32_30;
  wire z_out_11_32;
  wire [1:0] z_out_14_29_28;

  wire mux_131_nl;
  wire mux_130_nl;
  wire mux_129_nl;
  wire mux_128_nl;
  wire mux_127_nl;
  wire or_376_nl;
  wire nand_40_nl;
  wire mux_126_nl;
  wire mux_121_nl;
  wire mux_118_nl;
  wire mux_117_nl;
  wire mux_116_nl;
  wire mux_115_nl;
  wire and_417_nl;
  wire and_122_nl;
  wire mux_114_nl;
  wire mux_113_nl;
  wire mux_112_nl;
  wire mux_111_nl;
  wire mux_164_nl;
  wire nor_172_nl;
  wire mux_163_nl;
  wire mux_162_nl;
  wire mux_161_nl;
  wire mux_160_nl;
  wire mux_159_nl;
  wire and_418_nl;
  wire nor_173_nl;
  wire mux_150_nl;
  wire and_123_nl;
  wire mux_149_nl;
  wire nor_174_nl;
  wire mux_148_nl;
  wire mux_146_nl;
  wire mux_145_nl;
  wire and_420_nl;
  wire mux_205_nl;
  wire mux_204_nl;
  wire mux_203_nl;
  wire mux_202_nl;
  wire mux_201_nl;
  wire mux_217_nl;
  wire mux_216_nl;
  wire mux_215_nl;
  wire mux_214_nl;
  wire mux_213_nl;
  wire mux_212_nl;
  wire nor_37_nl;
  wire mux_198_nl;
  wire mux_196_nl;
  wire nor_207_nl;
  wire or_592_nl;
  wire mux_222_nl;
  wire mux_221_nl;
  wire or_590_nl;
  wire[31:0] i_mux1h_nl;
  wire while_for_while_for_or_nl;
  wire while_for_while_for_and_4_nl;
  wire while_for_while_for_and_5_nl;
  wire while_for_while_for_or_2_nl;
  wire mux_225_nl;
  wire nor_280_nl;
  wire mux_224_nl;
  wire mux_211_nl;
  wire and_456_nl;
  wire mux_210_nl;
  wire nor_203_nl;
  wire and_457_nl;
  wire mux_209_nl;
  wire and_184_nl;
  wire mux_208_nl;
  wire nor_281_nl;
  wire mux_207_nl;
  wire nor_282_nl;
  wire mux_195_nl;
  wire nor_209_nl;
  wire mux_315_nl;
  wire and_437_nl;
  wire[26:0] for_for_and_nl;
  wire mux_317_nl;
  wire mux_316_nl;
  wire mux_321_nl;
  wire mux_320_nl;
  wire and_301_nl;
  wire i_and_2_nl;
  wire i_and_3_nl;
  wire mux_507_nl;
  wire mux_506_nl;
  wire or_620_nl;
  wire mux_505_nl;
  wire or_619_nl;
  wire mux_504_nl;
  wire or_618_nl;
  wire mux_nl;
  wire mux_512_nl;
  wire and_703_nl;
  wire mux_511_nl;
  wire and_699_nl;
  wire nor_nl;
  wire mux_510_nl;
  wire nand_63_nl;
  wire mux_509_nl;
  wire mux_329_nl;
  wire mux_328_nl;
  wire mux_327_nl;
  wire mux_325_nl;
  wire or_508_nl;
  wire or_506_nl;
  wire mux_330_nl;
  wire and_440_nl;
  wire[32:0] for_1_acc_nl;
  wire[33:0] nl_for_1_acc_nl;
  wire and_306_nl;
  wire mux_333_nl;
  wire mux_332_nl;
  wire or_99_nl;
  wire or_515_nl;
  wire[32:0] while_for_2_while_acc_2_nl;
  wire[33:0] nl_while_for_2_while_acc_2_nl;
  wire for_or_6_nl;
  wire and_309_nl;
  wire and_310_nl;
  wire and_311_nl;
  wire and_298_nl;
  wire and_313_nl;
  wire mux_355_nl;
  wire mux_352_nl;
  wire and_315_nl;
  wire mux_348_nl;
  wire mux_347_nl;
  wire mux_346_nl;
  wire mux_345_nl;
  wire mux_344_nl;
  wire or_523_nl;
  wire mux_343_nl;
  wire mux_342_nl;
  wire nor_259_nl;
  wire mux_341_nl;
  wire mux_340_nl;
  wire mux_339_nl;
  wire mux_338_nl;
  wire or_519_nl;
  wire mux_337_nl;
  wire mux_336_nl;
  wire mux_360_nl;
  wire mux_359_nl;
  wire or_526_nl;
  wire nor_261_nl;
  wire mux_356_nl;
  wire and_460_nl;
  wire mux_523_nl;
  wire mux_522_nl;
  wire mux_521_nl;
  wire or_632_nl;
  wire mux_520_nl;
  wire and_704_nl;
  wire mux_519_nl;
  wire mux_516_nl;
  wire mux_515_nl;
  wire and_705_nl;
  wire mux_513_nl;
  wire and_706_nl;
  wire mux_531_nl;
  wire mux_530_nl;
  wire mux_529_nl;
  wire mux_528_nl;
  wire or_641_nl;
  wire mux_527_nl;
  wire nand_69_nl;
  wire mux_526_nl;
  wire nand_64_nl;
  wire mux_525_nl;
  wire or_640_nl;
  wire mux_365_nl;
  wire nand_50_nl;
  wire mux_369_nl;
  wire mux_367_nl;
  wire mux_366_nl;
  wire and_444_nl;
  wire and_326_nl;
  wire and_327_nl;
  wire mux_377_nl;
  wire mux_376_nl;
  wire mux_375_nl;
  wire mux_373_nl;
  wire mux_372_nl;
  wire mux_371_nl;
  wire mux_370_nl;
  wire while_for_while_for_while_for_or_2_nl;
  wire while_for_while_for_while_for_nor_1_nl;
  wire for_or_9_nl;
  wire and_329_nl;
  wire mux_389_nl;
  wire mux_388_nl;
  wire mux_387_nl;
  wire mux_386_nl;
  wire mux_385_nl;
  wire nand_12_nl;
  wire mux_384_nl;
  wire mux_380_nl;
  wire mux_378_nl;
  wire while_for_and_1_nl;
  wire while_for_while_for_while_for_or_1_nl;
  wire while_for_while_for_while_for_nor_3_nl;
  wire for_or_11_nl;
  wire and_336_nl;
  wire and_337_nl;
  wire mux_399_nl;
  wire mux_398_nl;
  wire mux_397_nl;
  wire mux_396_nl;
  wire mux_395_nl;
  wire mux_394_nl;
  wire mux_393_nl;
  wire nor_271_nl;
  wire mux_392_nl;
  wire mux_391_nl;
  wire mux_390_nl;
  wire or_540_nl;
  wire or_539_nl;
  wire and_340_nl;
  wire and_341_nl;
  wire mux_414_nl;
  wire mux_413_nl;
  wire mux_412_nl;
  wire mux_411_nl;
  wire mux_410_nl;
  wire mux_409_nl;
  wire mux_408_nl;
  wire mux_407_nl;
  wire mux_404_nl;
  wire mux_402_nl;
  wire mux_401_nl;
  wire while_while_while_or_nl;
  wire and_342_nl;
  wire and_343_nl;
  wire mux_424_nl;
  wire mux_423_nl;
  wire mux_422_nl;
  wire mux_421_nl;
  wire mux_420_nl;
  wire mux_419_nl;
  wire and_447_nl;
  wire mux_418_nl;
  wire mux_417_nl;
  wire mux_416_nl;
  wire or_549_nl;
  wire and_344_nl;
  wire mux_433_nl;
  wire mux_432_nl;
  wire mux_431_nl;
  wire or_554_nl;
  wire mux_430_nl;
  wire or_553_nl;
  wire mux_429_nl;
  wire mux_428_nl;
  wire mux_427_nl;
  wire nor_113_nl;
  wire mux_426_nl;
  wire and_346_nl;
  wire mux_437_nl;
  wire mux_436_nl;
  wire or_559_nl;
  wire mux_435_nl;
  wire nand_51_nl;
  wire mux_445_nl;
  wire mux_444_nl;
  wire mux_443_nl;
  wire mux_442_nl;
  wire mux_441_nl;
  wire mux_440_nl;
  wire mux_439_nl;
  wire mux_438_nl;
  wire and_452_nl;
  wire while_for_if_while_for_if_and_nl;
  wire while_for_while_for_while_for_or_nl;
  wire while_for_while_for_while_for_nor_4_nl;
  wire and_347_nl;
  wire mux_454_nl;
  wire mux_453_nl;
  wire mux_452_nl;
  wire mux_451_nl;
  wire mux_450_nl;
  wire mux_449_nl;
  wire mux_448_nl;
  wire mux_447_nl;
  wire mux_446_nl;
  wire or_562_nl;
  wire mux_458_nl;
  wire mux_455_nl;
  wire or_566_nl;
  wire mux_460_nl;
  wire mux_459_nl;
  wire mux_461_nl;
  wire[31:0] while_for_k_mux_1_nl;
  wire and_362_nl;
  wire nand_nl;
  wire mux_464_nl;
  wire mux_463_nl;
  wire mux_462_nl;
  wire mux_478_nl;
  wire mux_477_nl;
  wire mux_476_nl;
  wire mux_475_nl;
  wire or_573_nl;
  wire mux_474_nl;
  wire mux_470_nl;
  wire mux_469_nl;
  wire nor_279_nl;
  wire mux_480_nl;
  wire mux_479_nl;
  wire[32:0] while_else_acc_nl;
  wire[33:0] nl_while_else_acc_nl;
  wire[32:0] while_for_3_aif_acc_1_nl;
  wire[33:0] nl_while_for_3_aif_acc_1_nl;
  wire mux_124_nl;
  wire mux_123_nl;
  wire or_73_nl;
  wire or_379_nl;
  wire nand_36_nl;
  wire or_89_nl;
  wire nor_160_nl;
  wire mux_308_nl;
  wire nor_161_nl;
  wire mux_382_nl;
  wire and_328_nl;
  wire mux_381_nl;
  wire nand_13_nl;
  wire mux_473_nl;
  wire mux_472_nl;
  wire nand_7_nl;
  wire mux_193_nl;
  wire nor_179_nl;
  wire nor_180_nl;
  wire mux_192_nl;
  wire mux_191_nl;
  wire mux_190_nl;
  wire mux_178_nl;
  wire mux_170_nl;
  wire mux_168_nl;
  wire mux_166_nl;
  wire or_386_nl;
  wire[32:0] for_1_acc_2_nl;
  wire[33:0] nl_for_1_acc_2_nl;
  wire nor_252_nl;
  wire[8:0] while_for_while_aelse_mux1h_nl;
  wire[8:0] while_for_while_aelse_acc_nl;
  wire[9:0] nl_while_for_while_aelse_acc_nl;
  wire[8:0] while_for_while_aelse_mux1h_10_nl;
  wire[8:0] while_for_while_aelse_acc_13_nl;
  wire[9:0] nl_while_for_while_aelse_acc_13_nl;
  wire nand_71_nl;
  wire while_for_while_aelse_or_8_nl;
  wire and_712_nl;
  wire and_713_nl;
  wire and_714_nl;
  wire[8:0] while_for_while_aelse_acc_14_nl;
  wire[9:0] nl_while_for_while_aelse_acc_14_nl;
  wire[6:0] while_for_while_aelse_mux_10_nl;
  wire while_for_while_aelse_mux_11_nl;
  wire[8:0] while_for_5_while_aelse_acc_nl;
  wire[9:0] nl_while_for_5_while_aelse_acc_nl;
  wire[8:0] while_for_8_while_aelse_acc_nl;
  wire[9:0] nl_while_for_8_while_aelse_acc_nl;
  wire mux_304_nl;
  wire nor_228_nl;
  wire and_434_nl;
  wire mux_303_nl;
  wire mux_302_nl;
  wire nand_48_nl;
  wire mux_301_nl;
  wire nand_10_nl;
  wire while_for_while_aelse_or_nl;
  wire while_for_while_aelse_or_1_nl;
  wire and_250_nl;
  wire and_253_nl;
  wire and_291_nl;
  wire and_295_nl;
  wire mux_314_nl;
  wire mux_313_nl;
  wire mux_312_nl;
  wire mux_311_nl;
  wire nor_229_nl;
  wire mux_310_nl;
  wire mux_307_nl;
  wire mux_306_nl;
  wire nor_230_nl;
  wire mux_305_nl;
  wire nor_232_nl;
  wire[3:0] for_and_nl;
  wire[3:0] for_for_mux_nl;
  wire for_not_nl;
  wire[4:0] for_for_nor_nl;
  wire[4:0] for_nor_nl;
  wire[4:0] for_for_nor_1_nl;
  wire[4:0] for_mux1h_50_nl;
  wire and_205_nl;
  wire and_209_nl;
  wire and_213_nl;
  wire and_215_nl;
  wire and_218_nl;
  wire and_219_nl;
  wire and_222_nl;
  wire and_224_nl;
  wire and_225_nl;
  wire and_226_nl;
  wire and_228_nl;
  wire and_230_nl;
  wire and_231_nl;
  wire and_232_nl;
  wire and_234_nl;
  wire and_236_nl;
  wire and_237_nl;
  wire and_238_nl;
  wire and_239_nl;
  wire and_240_nl;
  wire and_241_nl;
  wire and_242_nl;
  wire mux_297_nl;
  wire mux_296_nl;
  wire mux_295_nl;
  wire mux_294_nl;
  wire mux_293_nl;
  wire nor_66_nl;
  wire nor_65_nl;
  wire nor_223_nl;
  wire mux_292_nl;
  wire mux_291_nl;
  wire mux_290_nl;
  wire nor_64_nl;
  wire mux_289_nl;
  wire nor_63_nl;
  wire and_430_nl;
  wire mux_288_nl;
  wire mux_287_nl;
  wire mux_286_nl;
  wire mux_285_nl;
  wire mux_284_nl;
  wire mux_283_nl;
  wire mux_282_nl;
  wire mux_281_nl;
  wire mux_280_nl;
  wire nor_60_nl;
  wire nor_227_nl;
  wire mux_279_nl;
  wire mux_278_nl;
  wire mux_277_nl;
  wire mux_276_nl;
  wire mux_275_nl;
  wire nor_58_nl;
  wire mux_274_nl;
  wire mux_273_nl;
  wire mux_272_nl;
  wire nor_55_nl;
  wire mux_271_nl;
  wire or_483_nl;
  wire mux_270_nl;
  wire mux_269_nl;
  wire mux_268_nl;
  wire mux_267_nl;
  wire nor_52_nl;
  wire mux_266_nl;
  wire nor_51_nl;
  wire nor_50_nl;
  wire nand_47_nl;
  wire mux_265_nl;
  wire mux_264_nl;
  wire mux_263_nl;
  wire and_431_nl;
  wire nor_225_nl;
  wire mux_260_nl;
  wire or_476_nl;
  wire mux_259_nl;
  wire mux_488_nl;
  wire mux_487_nl;
  wire mux_484_nl;
  wire mux_483_nl;
  wire mux_496_nl;
  wire mux_495_nl;
  wire mux_494_nl;
  wire mux_503_nl;
  wire mux_500_nl;
  wire mux_499_nl;
  wire or_625_nl;
  wire and_708_nl;
  wire mux_517_nl;
  wire or_628_nl;
  wire or_636_nl;
  wire or_634_nl;
  wire[33:0] acc_1_nl;
  wire[34:0] nl_acc_1_nl;
  wire for_for_mux_22_nl;
  wire[16:0] for_mux1h_120_nl;
  wire for_for_mux_23_nl;
  wire for_or_48_nl;
  wire for_mux1h_121_nl;
  wire for_for_mux_24_nl;
  wire[5:0] for_mux1h_122_nl;
  wire[1:0] for_mux1h_123_nl;
  wire[2:0] for_for_and_2_nl;
  wire[2:0] for_mux_10_nl;
  wire not_1093_nl;
  wire for_or_49_nl;
  wire[31:0] for_mux1h_124_nl;
  wire[33:0] acc_4_nl;
  wire[34:0] nl_acc_4_nl;
  wire for_mux1h_125_nl;
  wire for_or_50_nl;
  wire[25:0] for_mux1h_126_nl;
  wire[4:0] for_mux1h_127_nl;
  wire for_or_51_nl;
  wire[31:0] for_mux1h_128_nl;
  wire[33:0] acc_5_nl;
  wire[34:0] nl_acc_5_nl;
  wire[26:0] for_mux1h_129_nl;
  wire for_or_52_nl;
  wire[4:0] for_mux1h_130_nl;
  wire for_or_53_nl;
  wire[31:0] for_for_mux_25_nl;
  wire for_or_54_nl;
  wire[33:0] acc_6_nl;
  wire[34:0] nl_acc_6_nl;
  wire[25:0] for_for_mux_26_nl;
  wire[4:0] for_mux1h_131_nl;
  wire and_715_nl;
  wire[31:0] for_for_mux_27_nl;
  wire[33:0] acc_7_nl;
  wire[34:0] nl_acc_7_nl;
  wire[2:0] for_mux1h_132_nl;
  wire for_for_or_9_nl;
  wire[33:0] acc_8_nl;
  wire[34:0] nl_acc_8_nl;
  wire for_for_or_10_nl;
  wire for_for_or_11_nl;
  wire[33:0] acc_9_nl;
  wire[34:0] nl_acc_9_nl;
  wire[25:0] for_for_mux_28_nl;
  wire[1:0] for_mux1h_133_nl;
  wire and_716_nl;
  wire[31:0] for_for_mux_29_nl;
  wire[33:0] acc_10_nl;
  wire[34:0] nl_acc_10_nl;
  wire[25:0] for_for_mux_30_nl;
  wire[1:0] for_for_or_12_nl;
  wire[1:0] for_mux_11_nl;
  wire for_for_or_13_nl;
  wire for_for_or_14_nl;
  wire for_for_or_15_nl;
  wire[31:0] for_for_mux_31_nl;
  wire[33:0] acc_11_nl;
  wire[34:0] nl_acc_11_nl;
  wire for_for_or_16_nl;
  wire[1:0] for_for_mux_32_nl;
  wire while_for_while_aelse_while_for_while_aelse_mux_1_nl;
  wire while_for_while_aelse_mux1h_11_nl;
  wire while_for_while_aelse_or_9_nl;
  wire[5:0] while_for_while_aelse_mux1h_12_nl;
  wire while_for_while_aelse_while_for_while_aelse_or_1_nl;
  wire nand_72_nl;
  wire[30:0] acc_14_nl;
  wire[31:0] nl_acc_14_nl;
  wire[25:0] for_for_mux_33_nl;
  wire for_for_or_17_nl;
  wire[28:0] for_for_mux_34_nl;

  // Interconnect Declarations for Component Instantiations 
  wire  nl_lz77simple_core_core_fsm_inst_main_C_0_tr0;
  assign nl_lz77simple_core_core_fsm_inst_main_C_0_tr0 = ~((~((src_rsci_idat_mxwt==32'b00000000000000000000000000000000)))
      & for_1_acc_2_itm_32_1);
  wire  nl_lz77simple_core_core_fsm_inst_for_C_1_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_1_tr0 = ~ for_10_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_3_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_3_tr0 = ~ for_10_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_5_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_5_tr0 = ~ for_slc_for_acc_3_30_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_7_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_7_tr0 = ~ for_10_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_9_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_9_tr0 = ~ for_13_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_11_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_11_tr0 = ~ for_14_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_13_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_13_tr0 = ~ for_slc_for_acc_2_29_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_15_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_15_tr0 = ~ for_19_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_17_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_17_tr0 = ~ for_10_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_19_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_19_tr0 = ~ for_11_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_21_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_21_tr0 = ~ for_slc_for_acc_3_30_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_23_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_23_tr0 = ~ for_13_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_25_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_25_tr0 = ~ for_14_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_27_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_27_tr0 = ~ for_15_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_29_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_29_tr0 = ~ for_slc_for_acc_4_28_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_31_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_31_tr0 = ~ for_17_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_33_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_33_tr0 = ~ for_18_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_35_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_35_tr0 = ~ for_19_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_37_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_37_tr0 = ~ for_slc_for_acc_2_29_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_39_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_39_tr0 = ~ for_10_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_41_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_41_tr0 = ~ while_for_while_for_while_for_nor_1_itm_2;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_43_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_43_tr0 = ~ for_11_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_45_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_45_tr0 = ~ for_slc_for_acc_6_29_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_47_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_47_tr0 = ~ for_25_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_49_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_49_tr0 = ~ for_26_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_51_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_51_tr0 = ~ for_27_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_53_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_53_tr0 = ~ for_slc_for_acc_3_30_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_55_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_55_tr0 = ~ for_13_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_57_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_57_tr0 = ~ for_14_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_59_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_59_tr0 = ~ for_31_slc_32_itm;
  wire  nl_lz77simple_core_core_fsm_inst_for_C_61_tr0;
  assign nl_lz77simple_core_core_fsm_inst_for_C_61_tr0 = ~ for_slc_for_acc_8_27_itm;
  wire  nl_lz77simple_core_core_fsm_inst_main_C_3_tr0;
  assign nl_lz77simple_core_core_fsm_inst_main_C_3_tr0 = ~((~((N_sva==32'b00000000000000000000000000000000)))
      & for_slc_for_acc_2_29_itm);
  lz77simple_core_dest_rsci lz77simple_core_dest_rsci_inst (
      .dest_rsc_dat(dest_rsc_dat),
      .dest_rsc_vld(dest_rsc_vld),
      .dest_rsc_rdy(dest_rsc_rdy),
      .dest_rsci_oswt(reg_dest_rsci_iswt0_cse),
      .dest_rsci_wen_comp(dest_rsci_wen_comp),
      .dest_rsci_idat(dest_rsci_idat)
    );
  lz77simple_core_src_rsci lz77simple_core_src_rsci_inst (
      .src_rsc_dat(src_rsc_dat),
      .src_rsc_vld(src_rsc_vld),
      .src_rsc_rdy(src_rsc_rdy),
      .src_rsci_oswt(reg_src_rsci_iswt0_cse),
      .src_rsci_wen_comp(src_rsci_wen_comp),
      .src_rsci_idat_mxwt(src_rsci_idat_mxwt)
    );
  lz77simple_core_wait_dp lz77simple_core_wait_dp_inst (
      .srcbuf_rsci_en_d(srcbuf_rsci_en_d),
      .core_wen(core_wen),
      .srcbuf_rsci_cgo(reg_srcbuf_rsci_cgo_ir_cse),
      .srcbuf_rsci_cgo_ir_unreg(mux_132_rmff)
    );
  lz77simple_core_staller lz77simple_core_staller_inst (
      .core_wen(core_wen),
      .dest_rsci_wen_comp(dest_rsci_wen_comp),
      .src_rsci_wen_comp(src_rsci_wen_comp)
    );
  lz77simple_core_core_fsm lz77simple_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .main_C_0_tr0(nl_lz77simple_core_core_fsm_inst_main_C_0_tr0),
      .for_C_1_tr0(nl_lz77simple_core_core_fsm_inst_for_C_1_tr0),
      .for_C_3_tr0(nl_lz77simple_core_core_fsm_inst_for_C_3_tr0),
      .for_C_5_tr0(nl_lz77simple_core_core_fsm_inst_for_C_5_tr0),
      .for_C_7_tr0(nl_lz77simple_core_core_fsm_inst_for_C_7_tr0),
      .for_C_9_tr0(nl_lz77simple_core_core_fsm_inst_for_C_9_tr0),
      .for_C_11_tr0(nl_lz77simple_core_core_fsm_inst_for_C_11_tr0),
      .for_C_13_tr0(nl_lz77simple_core_core_fsm_inst_for_C_13_tr0),
      .for_C_15_tr0(nl_lz77simple_core_core_fsm_inst_for_C_15_tr0),
      .for_C_17_tr0(nl_lz77simple_core_core_fsm_inst_for_C_17_tr0),
      .for_C_19_tr0(nl_lz77simple_core_core_fsm_inst_for_C_19_tr0),
      .for_C_21_tr0(nl_lz77simple_core_core_fsm_inst_for_C_21_tr0),
      .for_C_23_tr0(nl_lz77simple_core_core_fsm_inst_for_C_23_tr0),
      .for_C_25_tr0(nl_lz77simple_core_core_fsm_inst_for_C_25_tr0),
      .for_C_27_tr0(nl_lz77simple_core_core_fsm_inst_for_C_27_tr0),
      .for_C_29_tr0(nl_lz77simple_core_core_fsm_inst_for_C_29_tr0),
      .for_C_31_tr0(nl_lz77simple_core_core_fsm_inst_for_C_31_tr0),
      .for_C_33_tr0(nl_lz77simple_core_core_fsm_inst_for_C_33_tr0),
      .for_C_35_tr0(nl_lz77simple_core_core_fsm_inst_for_C_35_tr0),
      .for_C_37_tr0(nl_lz77simple_core_core_fsm_inst_for_C_37_tr0),
      .for_C_39_tr0(nl_lz77simple_core_core_fsm_inst_for_C_39_tr0),
      .for_C_41_tr0(nl_lz77simple_core_core_fsm_inst_for_C_41_tr0),
      .for_C_43_tr0(nl_lz77simple_core_core_fsm_inst_for_C_43_tr0),
      .for_C_45_tr0(nl_lz77simple_core_core_fsm_inst_for_C_45_tr0),
      .for_C_47_tr0(nl_lz77simple_core_core_fsm_inst_for_C_47_tr0),
      .for_C_49_tr0(nl_lz77simple_core_core_fsm_inst_for_C_49_tr0),
      .for_C_51_tr0(nl_lz77simple_core_core_fsm_inst_for_C_51_tr0),
      .for_C_53_tr0(nl_lz77simple_core_core_fsm_inst_for_C_53_tr0),
      .for_C_55_tr0(nl_lz77simple_core_core_fsm_inst_for_C_55_tr0),
      .for_C_57_tr0(nl_lz77simple_core_core_fsm_inst_for_C_57_tr0),
      .for_C_59_tr0(nl_lz77simple_core_core_fsm_inst_for_C_59_tr0),
      .for_C_61_tr0(nl_lz77simple_core_core_fsm_inst_for_C_61_tr0),
      .for_C_63_tr0(for_10_slc_32_itm),
      .main_C_3_tr0(nl_lz77simple_core_core_fsm_inst_main_C_3_tr0),
      .while_for_1_while_C_3_tr0(or_dcpl_298),
      .while_for_2_while_C_3_tr0(or_dcpl_298),
      .while_for_3_while_C_3_tr0(or_dcpl_298),
      .while_for_4_while_C_3_tr0(or_dcpl_298),
      .while_for_5_while_C_3_tr0(or_dcpl_298),
      .while_for_6_while_C_3_tr0(or_dcpl_298),
      .while_for_7_while_C_3_tr0(or_dcpl_298),
      .while_for_8_while_C_3_tr0(or_dcpl_298),
      .while_for_9_while_C_3_tr0(or_dcpl_298),
      .while_C_21_tr0(for_10_slc_32_itm)
    );
  assign or_376_nl = (or_584_cse & (fsm_output[0])) | (fsm_output[6]);
  assign mux_127_nl = MUX_s_1_2_2(or_376_nl, (fsm_output[6]), for_1_acc_2_itm_32_1);
  assign nand_40_nl = ~((nor_208_cse | (fsm_output[0])) & (fsm_output[6]));
  assign mux_128_nl = MUX_s_1_2_2(mux_127_nl, nand_40_nl, fsm_output[1]);
  assign mux_129_nl = MUX_s_1_2_2(mux_128_nl, or_tmp_73, fsm_output[2]);
  assign mux_130_nl = MUX_s_1_2_2(mux_129_nl, (~ mux_tmp_120), fsm_output[4]);
  assign mux_131_nl = MUX_s_1_2_2(mux_130_nl, mux_tmp_125, fsm_output[5]);
  assign mux_116_nl = MUX_s_1_2_2(not_tmp_193, (fsm_output[6]), fsm_output[0]);
  assign and_417_nl = ((while_for_mux_16_tmp!=32'b00000000000000000000000000000000))
      & (fsm_output[6]);
  assign and_122_nl = (fsm_output[6]) & or_461_cse;
  assign mux_115_nl = MUX_s_1_2_2(and_417_nl, and_122_nl, fsm_output[0]);
  assign mux_117_nl = MUX_s_1_2_2(mux_116_nl, mux_115_nl, fsm_output[1]);
  assign mux_112_nl = MUX_s_1_2_2((~ (fsm_output[6])), or_tmp_68, while_else_acc_itm_32);
  assign mux_111_nl = MUX_s_1_2_2((~ (fsm_output[6])), or_tmp_68, for_10_slc_32_itm);
  assign mux_113_nl = MUX_s_1_2_2(mux_112_nl, mux_111_nl, fsm_output[0]);
  assign mux_114_nl = MUX_s_1_2_2((~ mux_113_nl), (fsm_output[6]), fsm_output[1]);
  assign mux_118_nl = MUX_s_1_2_2(mux_117_nl, mux_114_nl, fsm_output[2]);
  assign mux_121_nl = MUX_s_1_2_2(mux_tmp_120, mux_118_nl, fsm_output[4]);
  assign mux_126_nl = MUX_s_1_2_2(mux_tmp_125, (~ mux_121_nl), fsm_output[5]);
  assign mux_132_rmff = MUX_s_1_2_2(mux_131_nl, mux_126_nl, fsm_output[3]);
  assign nor_201_cse = ~((src_rsci_idat_mxwt!=32'b00000000000000000000000000000000));
  assign or_461_cse = (while_for_k_1_sva!=32'b00000000000000000000000000000000);
  assign nor_208_cse = ~((N_sva!=32'b00000000000000000000000000000000));
  assign mux_220_cse = MUX_s_1_2_2(for_19_slc_32_itm, for_25_slc_32_itm, fsm_output[5]);
  assign mux_219_cse = MUX_s_1_2_2(for_10_slc_32_itm, for_13_slc_32_itm, fsm_output[4]);
  assign mux_204_nl = MUX_s_1_2_2(for_10_slc_32_itm, for_18_slc_32_itm, fsm_output[5]);
  assign mux_203_nl = MUX_s_1_2_2(for_10_slc_32_itm, for_26_slc_32_itm, fsm_output[5]);
  assign mux_205_nl = MUX_s_1_2_2(mux_204_nl, mux_203_nl, fsm_output[4]);
  assign mux_201_nl = MUX_s_1_2_2(for_13_slc_32_itm, while_for_while_for_while_for_nor_1_itm_2,
      fsm_output[5]);
  assign mux_202_nl = MUX_s_1_2_2(mux_201_nl, for_14_slc_32_itm, fsm_output[4]);
  assign mux_206_cse = MUX_s_1_2_2(mux_205_nl, mux_202_nl, fsm_output[3]);
  assign mux_216_nl = MUX_s_1_2_2(for_10_slc_32_itm, for_19_slc_32_itm, fsm_output[5]);
  assign mux_215_nl = MUX_s_1_2_2(for_11_slc_32_itm, for_27_slc_32_itm, fsm_output[5]);
  assign mux_217_nl = MUX_s_1_2_2(mux_216_nl, mux_215_nl, fsm_output[4]);
  assign mux_213_nl = MUX_s_1_2_2(for_14_slc_32_itm, for_11_slc_32_itm, fsm_output[5]);
  assign mux_212_nl = MUX_s_1_2_2(for_15_slc_32_itm, for_31_slc_32_itm, fsm_output[5]);
  assign mux_214_nl = MUX_s_1_2_2(mux_213_nl, mux_212_nl, fsm_output[4]);
  assign mux_218_cse = MUX_s_1_2_2(mux_217_nl, mux_214_nl, fsm_output[3]);
  assign nor_37_nl = ~((fsm_output[5:4]!=2'b10));
  assign mux_199_cse = MUX_s_1_2_2(for_slc_for_acc_3_30_itm, for_slc_for_acc_2_29_itm,
      nor_37_nl);
  assign mux_197_cse = MUX_s_1_2_2(for_slc_for_acc_2_29_itm, for_slc_for_acc_6_29_itm,
      fsm_output[5]);
  assign nor_207_nl = ~((~ for_slc_for_acc_4_28_itm) | (fsm_output[5]));
  assign or_592_nl = for_slc_for_acc_4_28_itm | (fsm_output[5]);
  assign mux_196_nl = MUX_s_1_2_2(nor_207_nl, or_592_nl, for_slc_for_acc_8_27_itm);
  assign mux_198_nl = MUX_s_1_2_2(mux_197_cse, mux_196_nl, fsm_output[4]);
  assign mux_200_cse = MUX_s_1_2_2(mux_199_cse, mux_198_nl, fsm_output[3]);
  assign or_590_nl = nor_201_cse | for_1_acc_2_itm_32_1;
  assign mux_221_nl = MUX_s_1_2_2(or_590_nl, for_17_slc_32_itm, fsm_output[5]);
  assign mux_222_nl = MUX_s_1_2_2(mux_221_nl, mux_220_cse, fsm_output[4]);
  assign mux_223_cse = MUX_s_1_2_2(mux_222_nl, mux_219_cse, fsm_output[3]);
  assign nor_204_cse = ~((fsm_output[5:3]!=3'b000));
  assign and_436_cse = (fsm_output[0]) & (fsm_output[6]);
  assign or_291_cse = (fsm_output[1:0]!=2'b00);
  assign and_396_cse = (fsm_output[5:3]==3'b111);
  assign mux_316_nl = MUX_s_1_2_2(or_tmp_114, or_tmp_138, fsm_output[2]);
  assign mux_317_nl = MUX_s_1_2_2(mux_316_nl, (~ or_dcpl_365), fsm_output[6]);
  assign for_for_and_nl = MUX_v_27_2_2(27'b000000000000000000000000000, reg_while_L_lpi_2_dfm_1_reg,
      mux_317_nl);
  assign mux_320_nl = MUX_s_1_2_2(or_tmp_113, or_tmp_138, fsm_output[2]);
  assign mux_321_nl = MUX_s_1_2_2(mux_320_nl, (~ or_dcpl_365), fsm_output[6]);
  assign and_301_nl = (~ or_tmp_114) & and_dcpl_284;
  assign i_and_2_nl = (~ while_and_rgt) & and_dcpl_287;
  assign i_and_3_nl = while_and_rgt & and_dcpl_287;
  assign i_mux1h_5_rgt = MUX1HOT_v_32_5_2(({5'b00000 , for_for_and_nl}), srcbuf_rsci_data_out_d,
      32'b00000000000000000000000000000001, while_for_1_while_acc_2_itm, ({reg_while_L_lpi_2_dfm_reg
      , reg_while_L_lpi_2_dfm_1_reg}), {mux_321_nl , and_dcpl_283 , and_301_nl ,
      i_and_2_nl , i_and_3_nl});
  assign and_698_cse = for_11_slc_32_itm & while_else_acc_itm_32;
  assign and_696_cse = (fsm_output[1:0]==2'b11);
  assign or_642_cse = (fsm_output[5:4]!=2'b00);
  assign nand_66_cse = ~((fsm_output[5:4]==2'b11));
  assign and_702_cse = (fsm_output[5:4]==2'b11);
  assign nor_359_cse = ~((fsm_output[5:4]!=2'b00));
  assign mux_508_cse = MUX_s_1_2_2(nor_359_cse, and_702_cse, fsm_output[3]);
  assign nor_110_cse = ~((fsm_output[1:0]!=2'b00));
  assign and_441_cse = (fsm_output[6:5]==2'b11);
  assign or_529_cse = (~ while_for_3_aif_acc_1_itm_32) | for_11_slc_32_itm;
  assign or_526_nl = (fsm_output[5:3]!=3'b100);
  assign mux_359_nl = MUX_s_1_2_2(mux_tmp_349, or_526_nl, fsm_output[1]);
  assign mux_360_nl = MUX_s_1_2_2(mux_359_nl, mux_tmp_358, fsm_output[2]);
  assign or_607_tmp = (while_L_lpi_2_dfm_mx0c1 & while_for_while_for_while_for_nor_1_itm_2)
      | ((~ mux_360_nl) & (~ for_11_slc_32_itm) & while_for_3_aif_acc_1_itm_32 &
      and_dcpl_302);
  assign mux_356_nl = MUX_s_1_2_2((~ or_tmp_114), nor_tmp_46, fsm_output[2]);
  assign nor_261_nl = ~(mux_356_nl | (fsm_output[6]));
  assign and_460_nl = while_L_lpi_2_dfm_mx0c1 & (~ or_607_tmp);
  assign mux1h_rgt = MUX1HOT_v_32_4_2(({5'b00000 , s_1_31_5_sva_2}), ({{31{while_for_while_for_while_for_nor_1_itm_2}},
      while_for_while_for_while_for_nor_1_itm_2}), while_for_1_while_acc_3, while_for_k_1_sva,
      {nor_261_nl , and_460_nl , and_dcpl_129 , or_607_tmp});
  assign or_602_cse = (fsm_output[4:3]!=2'b00);
  assign and_443_cse = (fsm_output[1]) & (fsm_output[3]);
  assign or_533_cse = (fsm_output[1]) | (fsm_output[3]);
  assign and_378_cse = (fsm_output[4:3]==2'b11);
  assign nor_268_cse = ~((fsm_output[6:5]!=2'b01));
  assign or_538_cse = (fsm_output[6:5]!=2'b00);
  assign mux_44_cse = MUX_s_1_2_2(nor_268_cse, mux_tmp_42, fsm_output[4]);
  assign mux_48_cse = MUX_s_1_2_2((~ (fsm_output[5])), (fsm_output[5]), fsm_output[4]);
  assign nor_128_cse = ~((fsm_output[2]) | (fsm_output[0]));
  assign or_584_cse = (src_rsci_idat_mxwt!=32'b00000000000000000000000000000000);
  assign while_and_rgt = (~ while_else_acc_itm_32) & for_11_slc_32_itm;
  assign while_for_land_3_lpi_2_dfm_mx0w2 = while_for_3_aif_acc_1_itm_32 & (~ for_11_slc_32_itm);
  assign nl_s_1_31_5_sva_2 = i_sva_26_0 + 27'b000000000000000000000000001;
  assign s_1_31_5_sva_2 = nl_s_1_31_5_sva_2[26:0];
  assign nl_while_else_acc_nl = conv_s2u_32_33({reg_while_L_lpi_2_dfm_reg , reg_while_L_lpi_2_dfm_1_reg})
      - conv_s2u_32_33(N_sva);
  assign while_else_acc_nl = nl_while_else_acc_nl[32:0];
  assign while_else_acc_itm_32 = readslicef_33_1_32(while_else_acc_nl);
  assign nl_while_for_1_while_acc_3 = ({i_sva_31_27 , i_sva_26_0}) + while_for_k_1_sva;
  assign while_for_1_while_acc_3 = nl_while_for_1_while_acc_3[31:0];
  assign while_L_lpi_2_dfm_8_mx0 = MUX_v_32_2_2(while_for_k_1_sva, ({reg_while_L_lpi_2_dfm_reg
      , reg_while_L_lpi_2_dfm_1_reg}), or_529_cse);
  assign nl_while_for_3_aif_acc_1_nl = conv_s2u_32_33({reg_while_L_lpi_2_dfm_reg
      , reg_while_L_lpi_2_dfm_1_reg}) - conv_s2u_32_33(while_for_k_1_sva);
  assign while_for_3_aif_acc_1_nl = nl_while_for_3_aif_acc_1_nl[32:0];
  assign while_for_3_aif_acc_1_itm_32 = readslicef_33_1_32(while_for_3_aif_acc_1_nl);
  assign while_for_mux_16_tmp = MUX_v_32_2_2(({reg_while_L_lpi_2_dfm_reg , reg_while_L_lpi_2_dfm_1_reg}),
      while_for_k_1_sva, while_for_land_3_lpi_2_dfm_mx0w2);
  assign while_for_3_while_aif_equal_tmp = (srcbuf_rsci_data_out_d) == while_for_while_aelse_asn_36_itm;
  assign nor_tmp_1 = or_602_cse & (fsm_output[5]);
  assign mux_tmp_2 = MUX_s_1_2_2((~ (fsm_output[5])), (fsm_output[5]), fsm_output[3]);
  assign nor_tmp_6 = (fsm_output[3]) & (fsm_output[5]);
  assign mux_tmp_13 = MUX_s_1_2_2((~ (fsm_output[5])), nor_tmp_6, fsm_output[4]);
  assign mux_24_cse = MUX_s_1_2_2((~ (fsm_output[5])), (fsm_output[5]), or_602_cse);
  assign mux_tmp_42 = MUX_s_1_2_2((~ (fsm_output[5])), (fsm_output[5]), fsm_output[6]);
  assign and_tmp = (fsm_output[4]) & mux_tmp_42;
  assign and_dcpl_12 = for_10_slc_32_itm & while_for_3_while_aif_equal_tmp;
  assign mux_tmp_74 = MUX_s_1_2_2((~ (fsm_output[5])), (fsm_output[5]), and_378_cse);
  assign or_dcpl_298 = ~(for_10_slc_32_itm & while_for_3_while_aif_equal_tmp);
  assign or_tmp_68 = (~ (fsm_output[6])) | (while_for_k_1_sva!=32'b00000000000000000000000000000000);
  assign not_tmp_193 = ~(for_10_slc_32_itm | (~ (fsm_output[6])));
  assign mux_tmp_119 = MUX_s_1_2_2(not_tmp_193, (fsm_output[6]), or_291_cse);
  assign or_tmp_73 = ~((~((fsm_output[1]) & for_10_slc_32_itm)) & (fsm_output[6]));
  assign mux_tmp_120 = MUX_s_1_2_2((~ or_tmp_73), mux_tmp_119, fsm_output[2]);
  assign mux_tmp_122 = MUX_s_1_2_2(not_tmp_193, (fsm_output[6]), and_696_cse);
  assign mux_124_nl = MUX_s_1_2_2(mux_tmp_119, mux_tmp_122, fsm_output[2]);
  assign mux_123_nl = MUX_s_1_2_2((~ mux_tmp_122), or_tmp_73, fsm_output[2]);
  assign mux_tmp_125 = MUX_s_1_2_2((~ mux_124_nl), mux_123_nl, fsm_output[4]);
  assign or_73_nl = (fsm_output[5:3]!=3'b000);
  assign or_379_nl = (N_sva!=32'b00000000000000000000000000000000) | (fsm_output[5:3]!=3'b000);
  assign mux_tmp_147 = MUX_s_1_2_2(or_73_nl, or_379_nl, for_slc_for_acc_2_29_itm);
  assign and_dcpl_116 = (fsm_output[0]) & (~ (fsm_output[2]));
  assign and_dcpl_117 = and_dcpl_116 & (fsm_output[6]);
  assign and_dcpl_118 = (~ (fsm_output[3])) & (fsm_output[1]);
  assign and_dcpl_120 = nor_359_cse & and_dcpl_118;
  assign and_dcpl_124 = nor_128_cse & (fsm_output[6]);
  assign and_dcpl_127 = and_702_cse & and_443_cse;
  assign and_dcpl_128 = and_dcpl_127 & and_dcpl_124;
  assign and_dcpl_129 = and_dcpl_127 & and_dcpl_117;
  assign and_dcpl_130 = (fsm_output[2]) & (fsm_output[6]);
  assign and_dcpl_168 = for_10_slc_32_itm & (fsm_output[6]);
  assign and_dcpl_169 = (fsm_output[0]) & (fsm_output[2]);
  assign and_dcpl_171 = (fsm_output[3]) & (~ (fsm_output[1]));
  assign and_dcpl_172 = and_702_cse & and_dcpl_171;
  assign nor_tmp_46 = (fsm_output[0]) & (fsm_output[1]) & (fsm_output[3]) & (fsm_output[4])
      & (fsm_output[5]);
  assign or_tmp_113 = (fsm_output[0]) | (fsm_output[1]) | (fsm_output[3]) | (fsm_output[4])
      | (fsm_output[5]);
  assign or_tmp_114 = (fsm_output[1]) | (fsm_output[3]) | (fsm_output[4]) | (fsm_output[5]);
  assign or_tmp_116 = (~ for_10_slc_32_itm) | (fsm_output[5]);
  assign nand_36_nl = ~(for_10_slc_32_itm & (fsm_output[5]));
  assign mux_tmp_262 = MUX_s_1_2_2(nand_36_nl, or_tmp_116, fsm_output[3]);
  assign nor_tmp_49 = ~(for_slc_for_acc_3_30_itm | (~ (fsm_output[0])));
  assign nor_tmp_53 = ~(for_11_slc_32_itm | (~ (fsm_output[0])));
  assign nor_tmp_54 = ~(for_14_slc_32_itm | (~ (fsm_output[0])));
  assign nor_tmp_56 = ~(for_10_slc_32_itm | (~ (fsm_output[0])));
  assign nor_tmp_57 = ~(for_13_slc_32_itm | (~ (fsm_output[0])));
  assign nor_tmp_59 = ~(for_19_slc_32_itm | (~ (fsm_output[0])));
  assign nor_tmp_61 = ~(for_slc_for_acc_2_29_itm | (~ (fsm_output[0])));
  assign and_dcpl_177 = nor_359_cse & (fsm_output[3:1]==3'b000);
  assign and_dcpl_178 = nor_128_cse & (~ (fsm_output[6]));
  assign and_dcpl_179 = and_dcpl_120 & and_dcpl_178;
  assign and_dcpl_180 = (~ (fsm_output[0])) & (fsm_output[2]);
  assign and_dcpl_181 = and_dcpl_180 & (~ (fsm_output[6]));
  assign and_dcpl_182 = (~ or_tmp_114) & and_dcpl_181;
  assign and_dcpl_183 = and_dcpl_120 & and_dcpl_181;
  assign and_dcpl_184 = nor_359_cse & and_dcpl_171;
  assign and_dcpl_185 = and_dcpl_184 & and_dcpl_178;
  assign and_dcpl_186 = nor_359_cse & and_443_cse;
  assign and_dcpl_187 = and_dcpl_186 & and_dcpl_178;
  assign and_dcpl_188 = and_dcpl_184 & and_dcpl_181;
  assign and_dcpl_190 = ~((fsm_output[3]) | (fsm_output[1]));
  assign and_dcpl_191 = (fsm_output[5:4]==2'b01);
  assign and_dcpl_192 = and_dcpl_191 & and_dcpl_190;
  assign and_dcpl_194 = and_dcpl_191 & and_dcpl_118;
  assign and_dcpl_195 = and_dcpl_194 & and_dcpl_178;
  assign and_dcpl_196 = and_dcpl_192 & and_dcpl_181;
  assign and_dcpl_198 = and_dcpl_191 & and_dcpl_171;
  assign and_dcpl_200 = and_dcpl_191 & and_443_cse;
  assign and_dcpl_201 = and_dcpl_200 & and_dcpl_178;
  assign and_dcpl_204 = (fsm_output[5:4]==2'b10);
  assign and_dcpl_205 = and_dcpl_204 & and_dcpl_190;
  assign and_dcpl_207 = and_dcpl_204 & and_dcpl_118;
  assign and_dcpl_211 = and_dcpl_204 & and_dcpl_171;
  assign and_dcpl_213 = and_dcpl_204 & and_443_cse;
  assign and_dcpl_217 = and_702_cse & and_dcpl_190;
  assign and_dcpl_219 = and_702_cse & and_dcpl_118;
  assign or_89_nl = (fsm_output[5]) | (fsm_output[3]);
  assign mux_tmp_300 = MUX_s_1_2_2(mux_tmp_2, or_89_nl, fsm_output[1]);
  assign nor_tmp_71 = (fsm_output[1]) & for_10_slc_32_itm & (fsm_output[6]);
  assign or_tmp_133 = (fsm_output[2]) | (~ nor_tmp_71);
  assign not_tmp_299 = ~(for_10_slc_32_itm & (fsm_output[6]));
  assign nor_160_nl = ~((fsm_output[2:1]!=2'b10) | not_tmp_299);
  assign nor_161_nl = ~((fsm_output[1]) | not_tmp_299);
  assign mux_308_nl = MUX_s_1_2_2(nor_161_nl, nor_tmp_71, fsm_output[2]);
  assign mux_tmp_309 = MUX_s_1_2_2(nor_160_nl, mux_308_nl, fsm_output[4]);
  assign and_dcpl_228 = and_dcpl_180 & and_dcpl_168;
  assign and_dcpl_231 = nor_128_cse & and_dcpl_168;
  assign and_dcpl_239 = (~ (fsm_output[2])) & (fsm_output[6]);
  assign and_dcpl_241 = (fsm_output[1:0]==2'b10) & and_dcpl_239;
  assign or_dcpl_365 = or_642_cse | (fsm_output[3:1]!=3'b000);
  assign or_tmp_138 = (fsm_output[0]) | (~ and_dcpl_127);
  assign and_dcpl_281 = and_dcpl_169 & (~ (fsm_output[6]));
  assign and_dcpl_283 = and_dcpl_120 & and_dcpl_124;
  assign and_dcpl_284 = and_dcpl_180 & (fsm_output[6]);
  assign and_dcpl_287 = and_dcpl_172 & and_dcpl_284;
  assign or_tmp_144 = (fsm_output[5:4]!=2'b10);
  assign mux_tmp_326 = MUX_s_1_2_2(or_tmp_144, (fsm_output[5]), fsm_output[3]);
  assign not_tmp_348 = ~(and_696_cse | (fsm_output[5:3]!=3'b000));
  assign mux_tmp_331 = MUX_s_1_2_2(not_tmp_348, nor_tmp_46, fsm_output[2]);
  assign and_dcpl_291 = and_dcpl_116 & (~ (fsm_output[6]));
  assign mux_tmp_335 = MUX_s_1_2_2((~ mux_tmp_42), (fsm_output[5]), fsm_output[3]);
  assign or_tmp_154 = (fsm_output[6:5]!=2'b01);
  assign or_tmp_158 = (fsm_output[5:4]!=2'b01);
  assign mux_tmp_349 = MUX_s_1_2_2(or_tmp_158, or_tmp_144, fsm_output[3]);
  assign mux_tmp_351 = MUX_s_1_2_2((~ mux_48_cse), or_tmp_158, fsm_output[3]);
  assign mux_tmp_353 = MUX_s_1_2_2(or_tmp_144, or_642_cse, fsm_output[3]);
  assign mux_tmp_354 = MUX_s_1_2_2(mux_tmp_349, mux_tmp_353, fsm_output[1]);
  assign and_dcpl_302 = (~ (fsm_output[0])) & (fsm_output[6]);
  assign mux_tmp_357 = MUX_s_1_2_2((~ and_702_cse), or_tmp_158, fsm_output[3]);
  assign mux_tmp_358 = MUX_s_1_2_2(mux_tmp_357, mux_tmp_349, fsm_output[1]);
  assign mux_tmp_368 = MUX_s_1_2_2(mux_48_cse, and_702_cse, fsm_output[3]);
  assign mux_tmp_374 = MUX_s_1_2_2(nor_359_cse, mux_48_cse, fsm_output[3]);
  assign or_tmp_168 = (fsm_output[6:5]!=2'b10);
  assign or_tmp_170 = (~((~ (fsm_output[3])) | (fsm_output[6]))) | (fsm_output[5]);
  assign and_328_nl = (fsm_output[3]) & or_tmp_168;
  assign mux_382_nl = MUX_s_1_2_2((~ or_tmp_170), and_328_nl, fsm_output[4]);
  assign mux_381_nl = MUX_s_1_2_2((~ or_tmp_170), nor_tmp_6, fsm_output[4]);
  assign mux_tmp_383 = MUX_s_1_2_2(mux_382_nl, mux_381_nl, fsm_output[2]);
  assign and_dcpl_315 = and_396_cse & or_dcpl_298 & nor_110_cse & and_dcpl_239;
  assign and_dcpl_316 = and_dcpl_172 & and_dcpl_117;
  assign and_dcpl_321 = and_dcpl_211 & and_dcpl_124;
  assign mux_tmp_403 = MUX_s_1_2_2((~ and_tmp), or_538_cse, fsm_output[3]);
  assign mux_tmp_406 = MUX_s_1_2_2((~ mux_44_cse), or_538_cse, fsm_output[3]);
  assign nand_13_nl = ~((~((fsm_output[4:3]==2'b11))) & (fsm_output[5]));
  assign mux_tmp_434 = MUX_s_1_2_2(nand_13_nl, mux_tmp_74, or_291_cse);
  assign mux_tmp_456 = MUX_s_1_2_2(or_tmp_144, mux_48_cse, fsm_output[3]);
  assign mux_tmp_457 = MUX_s_1_2_2(mux_tmp_74, mux_tmp_456, or_291_cse);
  assign nor_tmp_98 = (fsm_output[4]) & (fsm_output[2]);
  assign or_tmp_204 = (fsm_output[4]) | (fsm_output[2]);
  assign mux_tmp_468 = MUX_s_1_2_2(or_tmp_204, nor_tmp_98, and_dcpl_12);
  assign mux_tmp_471 = MUX_s_1_2_2((~ (fsm_output[2])), (fsm_output[2]), fsm_output[4]);
  assign mux_472_nl = MUX_s_1_2_2(nor_tmp_98, mux_tmp_471, and_dcpl_12);
  assign mux_473_nl = MUX_s_1_2_2((~ mux_472_nl), mux_tmp_468, fsm_output[1]);
  assign or_tmp_205 = (fsm_output[0]) | mux_473_nl;
  assign nor_179_nl = ~(nor_208_cse | (~ (fsm_output[1])) | (fsm_output[3]) | (fsm_output[4])
      | (fsm_output[5]));
  assign nor_180_nl = ~(while_else_acc_itm_32 | (~((while_for_k_1_sva!=32'b00000000000000000000000000000000)))
      | (fsm_output[1]) | (~((fsm_output[5:3]==3'b111))));
  assign mux_193_nl = MUX_s_1_2_2(nor_179_nl, nor_180_nl, fsm_output[2]);
  assign nand_7_nl = ~((fsm_output[6]) & mux_193_nl);
  assign mux_190_nl = MUX_s_1_2_2(mux_223_cse, mux_206_cse, fsm_output[1]);
  assign mux_166_nl = MUX_s_1_2_2(for_slc_for_acc_4_28_itm, for_slc_for_acc_8_27_itm,
      fsm_output[5]);
  assign mux_168_nl = MUX_s_1_2_2(mux_197_cse, mux_166_nl, fsm_output[4]);
  assign mux_170_nl = MUX_s_1_2_2(mux_199_cse, mux_168_nl, fsm_output[3]);
  assign mux_178_nl = MUX_s_1_2_2(mux_218_cse, mux_170_nl, fsm_output[1]);
  assign mux_191_nl = MUX_s_1_2_2(mux_190_nl, mux_178_nl, fsm_output[2]);
  assign or_386_nl = (~ for_10_slc_32_itm) | (fsm_output[5:1]!=5'b00000);
  assign mux_192_nl = MUX_s_1_2_2(mux_191_nl, or_386_nl, fsm_output[6]);
  assign mux_194_itm = MUX_s_1_2_2(nand_7_nl, mux_192_nl, fsm_output[0]);
  assign dest_rsci_idat_mx0c1 = ((N_sva!=32'b00000000000000000000000000000000)) &
      and_dcpl_120 & and_dcpl_117;
  assign dest_rsci_idat_mx0c4 = (while_for_k_1_sva==32'b00000000000000000000000000000000)
      & (fsm_output[5]) & and_378_cse & nor_110_cse & and_dcpl_130;
  assign dest_rsci_idat_mx0c5 = or_461_cse & and_dcpl_172 & and_dcpl_169 & and_dcpl_168;
  assign srcbuf_rsci_addr_wr_d_mx0c0 = (and_dcpl_177 ^ (fsm_output[6])) | (fsm_output[0]);
  assign srcbuf_rsci_addr_wr_d_mx0c32 = (~ or_tmp_114) & and_dcpl_124;
  assign while_L_lpi_2_dfm_mx0c1 = and_dcpl_186 & and_dcpl_124;
  assign nl_for_1_acc_2_nl =  -conv_s2s_32_33(src_rsci_idat_mxwt);
  assign for_1_acc_2_nl = nl_for_1_acc_2_nl[32:0];
  assign for_1_acc_2_itm_32_1 = readslicef_33_1_32(for_1_acc_2_nl);
  assign nor_252_nl = ~((~(or_dcpl_365 ^ (fsm_output[6]))) | (fsm_output[0]));
  assign srcbuf_rsci_data_in_d = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      src_rsci_idat_mxwt, nor_252_nl);
  assign nand_71_nl = ~((fsm_output==7'b1110110));
  assign nl_while_for_while_aelse_acc_13_nl = (while_for_k_1_sva[8:0]) + conv_s2u_5_9({1'b1
      , nand_71_nl , 3'b111});
  assign while_for_while_aelse_acc_13_nl = nl_while_for_while_aelse_acc_13_nl[8:0];
  assign while_for_while_aelse_or_8_nl = (nor_359_cse & and_dcpl_118 & and_dcpl_372)
      | ((fsm_output[5:4]==2'b11) & and_dcpl_118 & and_dcpl_372);
  assign and_712_nl = nor_359_cse & (fsm_output[3]) & (~ (fsm_output[1])) & and_dcpl_372;
  assign and_713_nl = (fsm_output[5:4]==2'b01) & and_dcpl_118 & and_dcpl_381;
  assign and_714_nl = (fsm_output[5]) & (~ (fsm_output[4])) & (fsm_output[3]) & (fsm_output[1])
      & and_dcpl_381;
  assign while_for_while_aelse_mux1h_10_nl = MUX1HOT_v_9_4_2(while_for_while_aelse_acc_13_nl,
      ({(z_out_12[7:0]) , (while_for_k_1_sva[0])}), z_out_12, z_out_13, {while_for_while_aelse_or_8_nl
      , and_712_nl , and_713_nl , and_714_nl});
  assign nl_while_for_while_aelse_acc_nl = while_for_while_aelse_mux1h_10_nl + (i_sva_26_0[8:0]);
  assign while_for_while_aelse_acc_nl = nl_while_for_while_aelse_acc_nl[8:0];
  assign while_for_while_aelse_mux_10_nl = MUX_v_7_2_2((z_out_12[6:0]), (while_for_while_aelse_acc_11_sdt[7:1]),
      and_519_ssc);
  assign while_for_while_aelse_mux_11_nl = MUX_s_1_2_2((while_for_k_1_sva[1]), (while_for_while_aelse_acc_11_sdt[0]),
      and_519_ssc);
  assign nl_while_for_while_aelse_acc_14_nl = ({while_for_while_aelse_mux_10_nl ,
      while_for_while_aelse_mux_11_nl , (while_for_k_1_sva[0])}) + (i_sva_26_0[8:0]);
  assign while_for_while_aelse_acc_14_nl = nl_while_for_while_aelse_acc_14_nl[8:0];
  assign nl_while_for_5_while_aelse_acc_nl = z_out_13 + (i_sva_26_0[8:0]);
  assign while_for_5_while_aelse_acc_nl = nl_while_for_5_while_aelse_acc_nl[8:0];
  assign nl_while_for_8_while_aelse_acc_nl = ({(z_out_12[5:0]) , (while_for_k_1_sva[2:0])})
      + (i_sva_26_0[8:0]);
  assign while_for_8_while_aelse_acc_nl = nl_while_for_8_while_aelse_acc_nl[8:0];
  assign nor_228_nl = ~((fsm_output[6:1]!=6'b000000));
  assign nand_48_nl = ~((fsm_output[1]) & (fsm_output[3]) & (fsm_output[5]));
  assign mux_302_nl = MUX_s_1_2_2(nand_48_nl, mux_tmp_300, fsm_output[4]);
  assign nand_10_nl = ~((fsm_output[1]) & (~ mux_tmp_2));
  assign mux_301_nl = MUX_s_1_2_2(mux_tmp_300, nand_10_nl, fsm_output[4]);
  assign mux_303_nl = MUX_s_1_2_2(mux_302_nl, mux_301_nl, fsm_output[2]);
  assign and_434_nl = (fsm_output[6]) & for_10_slc_32_itm & (~ mux_303_nl);
  assign mux_304_nl = MUX_s_1_2_2(nor_228_nl, and_434_nl, fsm_output[0]);
  assign while_for_while_aelse_or_nl = (and_dcpl_120 & and_dcpl_228) | (and_dcpl_184
      & and_dcpl_228) | (and_dcpl_194 & and_dcpl_231) | (and_dcpl_213 & and_dcpl_231)
      | (and_dcpl_219 & and_dcpl_228);
  assign while_for_while_aelse_or_1_nl = (and_dcpl_198 & and_dcpl_231) | (and_dcpl_205
      & and_dcpl_228);
  assign and_250_nl = and_dcpl_200 & and_dcpl_228;
  assign and_253_nl = and_dcpl_217 & and_dcpl_231;
  assign and_291_nl = (while_for_mux_16_tmp==32'b00000000000000000000000000000000)
      & (fsm_output[5]) & and_378_cse & and_dcpl_241;
  assign and_295_nl = or_461_cse & and_dcpl_172 & while_else_acc_itm_32 & (~ (fsm_output[0]))
      & and_dcpl_130;
  assign while_for_while_aelse_mux1h_nl = MUX1HOT_v_9_7_2(while_for_1_while_aif_acc_3_itm,
      while_for_while_aelse_acc_nl, while_for_while_aelse_acc_14_nl, while_for_5_while_aelse_acc_nl,
      while_for_8_while_aelse_acc_nl, (i_sva_26_0[8:0]), (z_out_1[8:0]), {mux_304_nl
      , while_for_while_aelse_or_nl , while_for_while_aelse_or_1_nl , and_250_nl
      , and_253_nl , and_291_nl , and_295_nl});
  assign nor_229_nl = ~((fsm_output[1]) | (fsm_output[0]) | (fsm_output[6]));
  assign mux_311_nl = MUX_s_1_2_2(nor_229_nl, nor_tmp_71, fsm_output[2]);
  assign mux_312_nl = MUX_s_1_2_2(mux_311_nl, (~ or_tmp_133), fsm_output[4]);
  assign mux_313_nl = MUX_s_1_2_2(mux_312_nl, mux_tmp_309, fsm_output[5]);
  assign nor_230_nl = ~((fsm_output[1:0]!=2'b10) | (while_for_mux_16_tmp!=32'b00000000000000000000000000000000)
      | (~ (fsm_output[6])));
  assign nor_232_nl = ~((fsm_output[0]) | (~(or_461_cse & while_else_acc_itm_32 &
      (fsm_output[6]))));
  assign mux_305_nl = MUX_s_1_2_2(nor_232_nl, and_436_cse, fsm_output[1]);
  assign mux_306_nl = MUX_s_1_2_2(nor_230_nl, mux_305_nl, fsm_output[2]);
  assign mux_307_nl = MUX_s_1_2_2((~ or_tmp_133), mux_306_nl, fsm_output[4]);
  assign mux_310_nl = MUX_s_1_2_2(mux_tmp_309, mux_307_nl, fsm_output[5]);
  assign mux_314_nl = MUX_s_1_2_2(mux_313_nl, mux_310_nl, fsm_output[3]);
  assign srcbuf_rsci_addr_rd_d = MUX_v_9_2_2(9'b000000000, while_for_while_aelse_mux1h_nl,
      mux_314_nl);
  assign for_for_mux_nl = MUX_v_4_2_2((i_sva_26_0[3:0]), for_slc_s_1_31_5_3_0_30_itm,
      srcbuf_rsci_addr_wr_d_mx0c32);
  assign for_not_nl = ~ srcbuf_rsci_addr_wr_d_mx0c0;
  assign for_and_nl = MUX_v_4_2_2(4'b0000, for_for_mux_nl, for_not_nl);
  assign and_205_nl = and_dcpl_186 & and_dcpl_181;
  assign and_209_nl = and_dcpl_192 & and_dcpl_178;
  assign and_213_nl = and_dcpl_194 & and_dcpl_181;
  assign and_215_nl = and_dcpl_198 & and_dcpl_178;
  assign and_218_nl = and_dcpl_198 & and_dcpl_181;
  assign and_219_nl = and_dcpl_200 & and_dcpl_181;
  assign and_222_nl = and_dcpl_205 & and_dcpl_178;
  assign and_224_nl = and_dcpl_207 & and_dcpl_178;
  assign and_225_nl = and_dcpl_205 & and_dcpl_181;
  assign and_226_nl = and_dcpl_207 & and_dcpl_181;
  assign and_228_nl = and_dcpl_211 & and_dcpl_178;
  assign and_230_nl = and_dcpl_213 & and_dcpl_178;
  assign and_231_nl = and_dcpl_211 & and_dcpl_181;
  assign and_232_nl = and_dcpl_213 & and_dcpl_181;
  assign and_234_nl = and_dcpl_217 & and_dcpl_178;
  assign and_236_nl = and_dcpl_219 & and_dcpl_178;
  assign and_237_nl = and_dcpl_217 & and_dcpl_181;
  assign and_238_nl = and_dcpl_219 & and_dcpl_181;
  assign and_239_nl = and_dcpl_172 & and_dcpl_178;
  assign and_240_nl = and_dcpl_127 & and_dcpl_178;
  assign and_241_nl = and_dcpl_172 & and_dcpl_181;
  assign and_242_nl = and_dcpl_127 & and_dcpl_181;
  assign for_mux1h_50_nl = MUX1HOT_v_5_30_2(5'b11110, 5'b11101, 5'b11100, 5'b11011,
      5'b11010, 5'b11001, 5'b11000, 5'b10111, 5'b10110, 5'b10101, 5'b10100, 5'b10011,
      5'b10010, 5'b10001, 5'b10000, 5'b01111, 5'b01110, 5'b01101, 5'b01100, 5'b01011,
      5'b01010, 5'b01001, 5'b01000, 5'b00111, 5'b00110, 5'b00101, 5'b00100, 5'b00011,
      5'b00010, 5'b00001, {and_dcpl_182 , and_dcpl_183 , and_dcpl_185 , and_dcpl_187
      , and_dcpl_188 , and_205_nl , and_209_nl , and_dcpl_195 , and_dcpl_196 , and_213_nl
      , and_215_nl , and_dcpl_201 , and_218_nl , and_219_nl , and_222_nl , and_224_nl
      , and_225_nl , and_226_nl , and_228_nl , and_230_nl , and_231_nl , and_232_nl
      , and_234_nl , and_236_nl , and_237_nl , and_238_nl , and_239_nl , and_240_nl
      , and_241_nl , and_242_nl});
  assign for_for_nor_1_nl = ~(MUX_v_5_2_2(for_mux1h_50_nl, 5'b11111, and_dcpl_179));
  assign for_nor_nl = ~(MUX_v_5_2_2(for_for_nor_1_nl, 5'b11111, srcbuf_rsci_addr_wr_d_mx0c32));
  assign for_for_nor_nl = ~(MUX_v_5_2_2(for_nor_nl, 5'b11111, srcbuf_rsci_addr_wr_d_mx0c0));
  assign srcbuf_rsci_addr_wr_d = {for_and_nl , for_for_nor_nl};
  assign nor_66_nl = ~(nor_201_cse | for_1_acc_2_itm_32_1 | (~ (fsm_output[0])));
  assign nor_65_nl = ~(for_17_slc_32_itm | (~ (fsm_output[0])));
  assign mux_293_nl = MUX_s_1_2_2(nor_66_nl, nor_65_nl, fsm_output[5]);
  assign mux_294_nl = MUX_s_1_2_2(mux_293_nl, nor_tmp_56, fsm_output[3]);
  assign nor_223_nl = ~((fsm_output[3]) | (~ for_10_slc_32_itm) | (fsm_output[5])
      | (~ (fsm_output[0])));
  assign mux_295_nl = MUX_s_1_2_2(mux_294_nl, nor_223_nl, fsm_output[6]);
  assign nor_64_nl = ~(for_18_slc_32_itm | (~ (fsm_output[0])));
  assign mux_290_nl = MUX_s_1_2_2(nor_tmp_56, nor_64_nl, fsm_output[5]);
  assign nor_63_nl = ~(while_for_while_for_while_for_nor_1_itm_2 | (~ (fsm_output[0])));
  assign mux_289_nl = MUX_s_1_2_2(nor_tmp_57, nor_63_nl, fsm_output[5]);
  assign mux_291_nl = MUX_s_1_2_2(mux_290_nl, mux_289_nl, fsm_output[3]);
  assign and_430_nl = (fsm_output[3]) & for_10_slc_32_itm & (fsm_output[5]);
  assign mux_292_nl = MUX_s_1_2_2(mux_291_nl, and_430_nl, fsm_output[6]);
  assign mux_296_nl = MUX_s_1_2_2(mux_295_nl, mux_292_nl, fsm_output[1]);
  assign mux_285_nl = MUX_s_1_2_2(nor_tmp_56, nor_tmp_59, fsm_output[5]);
  assign mux_284_nl = MUX_s_1_2_2(nor_tmp_54, nor_tmp_53, fsm_output[5]);
  assign mux_286_nl = MUX_s_1_2_2(mux_285_nl, mux_284_nl, fsm_output[3]);
  assign mux_287_nl = MUX_s_1_2_2(mux_286_nl, (~ mux_tmp_262), fsm_output[6]);
  assign mux_281_nl = MUX_s_1_2_2(nor_tmp_49, nor_tmp_61, fsm_output[5]);
  assign nor_60_nl = ~(for_slc_for_acc_6_29_itm | (~ (fsm_output[0])));
  assign mux_280_nl = MUX_s_1_2_2(nor_tmp_61, nor_60_nl, fsm_output[5]);
  assign mux_282_nl = MUX_s_1_2_2(mux_281_nl, mux_280_nl, fsm_output[3]);
  assign nor_227_nl = ~((fsm_output[3]) | (~ for_10_slc_32_itm) | (fsm_output[5]));
  assign mux_283_nl = MUX_s_1_2_2(mux_282_nl, nor_227_nl, fsm_output[6]);
  assign mux_288_nl = MUX_s_1_2_2(mux_287_nl, mux_283_nl, fsm_output[1]);
  assign mux_297_nl = MUX_s_1_2_2(mux_296_nl, mux_288_nl, fsm_output[2]);
  assign nor_58_nl = ~(for_25_slc_32_itm | (~ (fsm_output[0])));
  assign mux_275_nl = MUX_s_1_2_2(nor_tmp_59, nor_58_nl, fsm_output[5]);
  assign mux_276_nl = MUX_s_1_2_2(mux_275_nl, nor_tmp_57, fsm_output[3]);
  assign mux_277_nl = MUX_s_1_2_2((~ mux_276_nl), mux_tmp_262, fsm_output[6]);
  assign nor_55_nl = ~(for_26_slc_32_itm | (~ (fsm_output[0])));
  assign mux_272_nl = MUX_s_1_2_2(nor_tmp_56, nor_55_nl, fsm_output[5]);
  assign mux_273_nl = MUX_s_1_2_2(mux_272_nl, nor_tmp_54, fsm_output[3]);
  assign or_483_nl = (while_for_mux_16_tmp!=32'b00000000000000000000000000000000)
      | (~ (fsm_output[5])) | (fsm_output[0]);
  assign mux_271_nl = MUX_s_1_2_2(or_tmp_116, or_483_nl, fsm_output[3]);
  assign mux_274_nl = MUX_s_1_2_2((~ mux_273_nl), mux_271_nl, fsm_output[6]);
  assign mux_278_nl = MUX_s_1_2_2(mux_277_nl, mux_274_nl, fsm_output[1]);
  assign nor_52_nl = ~(for_27_slc_32_itm | (~ (fsm_output[0])));
  assign mux_267_nl = MUX_s_1_2_2(nor_tmp_53, nor_52_nl, fsm_output[5]);
  assign nor_51_nl = ~(for_15_slc_32_itm | (~ (fsm_output[0])));
  assign nor_50_nl = ~(for_31_slc_32_itm | (~ (fsm_output[0])));
  assign mux_266_nl = MUX_s_1_2_2(nor_51_nl, nor_50_nl, fsm_output[5]);
  assign mux_268_nl = MUX_s_1_2_2(mux_267_nl, mux_266_nl, fsm_output[3]);
  assign nand_47_nl = ~(or_461_cse & while_else_acc_itm_32 & (fsm_output[3]) & (fsm_output[5])
      & (~ (fsm_output[0])));
  assign mux_269_nl = MUX_s_1_2_2((~ mux_268_nl), nand_47_nl, fsm_output[6]);
  assign and_431_nl = ((~ for_slc_for_acc_4_28_itm) | (fsm_output[5])) & (fsm_output[0]);
  assign nor_225_nl = ~(for_slc_for_acc_4_28_itm | (fsm_output[5]) | (~ (fsm_output[0])));
  assign mux_263_nl = MUX_s_1_2_2(and_431_nl, nor_225_nl, for_slc_for_acc_8_27_itm);
  assign mux_264_nl = MUX_s_1_2_2(nor_tmp_49, mux_263_nl, fsm_output[3]);
  assign mux_265_nl = MUX_s_1_2_2((~ mux_264_nl), mux_tmp_262, fsm_output[6]);
  assign mux_270_nl = MUX_s_1_2_2(mux_269_nl, mux_265_nl, fsm_output[1]);
  assign mux_279_nl = MUX_s_1_2_2(mux_278_nl, mux_270_nl, fsm_output[2]);
  assign srcbuf_rsci_re_d = MUX_s_1_2_2((~ mux_297_nl), mux_279_nl, fsm_output[4]);
  assign or_476_nl = (fsm_output[0]) | (~ or_tmp_114);
  assign mux_260_nl = MUX_s_1_2_2(or_476_nl, (fsm_output[0]), fsm_output[2]);
  assign mux_259_nl = MUX_s_1_2_2(or_tmp_113, (~ nor_tmp_46), fsm_output[2]);
  assign srcbuf_rsci_we_d = MUX_s_1_2_2(mux_260_nl, mux_259_nl, fsm_output[6]);
  assign and_dcpl_356 = (fsm_output[2]) & (~ (fsm_output[6]));
  assign and_dcpl_357 = and_dcpl_356 & (~ (fsm_output[0]));
  assign and_dcpl_361 = nor_359_cse & and_dcpl_190 & and_dcpl_357;
  assign and_dcpl_365 = (fsm_output[5:4]==2'b01) & and_dcpl_190 & and_dcpl_356 &
      (fsm_output[0]);
  assign and_dcpl_368 = nor_359_cse & (fsm_output[3]) & (fsm_output[1]) & and_dcpl_357;
  assign mux_486_cse = MUX_s_1_2_2(nand_66_cse, or_tmp_158, fsm_output[3]);
  assign mux_487_nl = MUX_s_1_2_2(mux_486_cse, mux_tmp_349, fsm_output[1]);
  assign mux_483_nl = MUX_s_1_2_2(or_tmp_144, (~ mux_48_cse), fsm_output[3]);
  assign mux_484_nl = MUX_s_1_2_2(mux_483_nl, mux_tmp_351, fsm_output[1]);
  assign mux_488_nl = MUX_s_1_2_2(mux_487_nl, mux_484_nl, fsm_output[2]);
  assign and_dcpl_370 = (~ mux_488_nl) & (fsm_output[6]) & (~ (fsm_output[0]));
  assign and_dcpl_372 = (fsm_output[2]) & (fsm_output[6]) & (~ (fsm_output[0]));
  assign and_dcpl_381 = (~ (fsm_output[2])) & (fsm_output[6]) & (~ (fsm_output[0]));
  assign and_dcpl_404 = ~((fsm_output[2]) | (fsm_output[6]));
  assign and_dcpl_405 = and_dcpl_404 & (~ (fsm_output[0]));
  assign and_dcpl_409 = (fsm_output[5:4]==2'b01) & and_dcpl_118 & and_dcpl_405;
  assign and_dcpl_414 = and_dcpl_120 & (~ (fsm_output[2])) & (fsm_output[6]) & (~
      (fsm_output[0]));
  assign and_dcpl_415 = and_dcpl_120 & and_dcpl_405;
  assign and_dcpl_417 = and_dcpl_120 & and_dcpl_404 & (fsm_output[0]);
  assign mux_493_cse = MUX_s_1_2_2((fsm_output[5]), (~ (fsm_output[5])), fsm_output[4]);
  assign mux_494_nl = MUX_s_1_2_2(or_tmp_144, mux_493_cse, fsm_output[3]);
  assign mux_495_nl = MUX_s_1_2_2(mux_494_nl, mux_486_cse, fsm_output[1]);
  assign mux_496_nl = MUX_s_1_2_2(mux_495_nl, mux_tmp_354, fsm_output[2]);
  assign and_dcpl_419 = (~ mux_496_nl) & (fsm_output[6]) & (fsm_output[0]);
  assign and_dcpl_421 = ~((fsm_output[2]) | (fsm_output[6]) | (fsm_output[0]));
  assign and_dcpl_425 = nor_359_cse & (~ (fsm_output[3])) & (fsm_output[1]) & and_dcpl_421;
  assign and_dcpl_430 = and_dcpl_184 & (fsm_output[2]) & (~ (fsm_output[6])) & (~
      (fsm_output[0]));
  assign and_dcpl_434 = (fsm_output[5:4]==2'b01) & and_443_cse & and_dcpl_421;
  assign and_dcpl_436 = (~ (fsm_output[2])) & (fsm_output[6]) & (fsm_output[0]);
  assign and_dcpl_437 = and_dcpl_184 & and_dcpl_436;
  assign mux_499_nl = MUX_s_1_2_2(mux_493_cse, or_tmp_158, fsm_output[3]);
  assign mux_500_nl = MUX_s_1_2_2(mux_499_nl, mux_tmp_349, fsm_output[1]);
  assign mux_503_nl = MUX_s_1_2_2(mux_tmp_354, mux_500_nl, fsm_output[2]);
  assign and_dcpl_439 = (~ mux_503_nl) & (fsm_output[6]) & (fsm_output[0]);
  assign and_dcpl_442 = and_702_cse & and_443_cse & and_dcpl_436;
  assign and_dcpl_446 = and_702_cse & and_dcpl_171 & (fsm_output[2]) & (fsm_output[6])
      & (fsm_output[0]);
  assign and_dcpl_454 = (fsm_output[2]) & (~ (fsm_output[6])) & (fsm_output[0]);
  assign and_dcpl_457 = nor_359_cse & and_dcpl_190 & and_dcpl_454;
  assign and_dcpl_460 = and_dcpl_191 & and_dcpl_118 & and_dcpl_454;
  assign and_dcpl_463 = and_dcpl_191 & (fsm_output[3]) & (~ (fsm_output[1])) & and_dcpl_421;
  assign and_dcpl_469 = nor_359_cse & (fsm_output[3]) & (~ (fsm_output[1])) & and_dcpl_404
      & (fsm_output[0]);
  assign and_dcpl_471 = (fsm_output[2]) & (~ (fsm_output[6])) & (~ (fsm_output[0]));
  assign and_dcpl_475 = and_dcpl_191 & and_dcpl_190 & and_dcpl_471;
  assign and_dcpl_478 = and_dcpl_191 & (~ (fsm_output[3])) & (fsm_output[1]) & and_dcpl_471;
  assign and_dcpl_484 = and_dcpl_191 & (~ (fsm_output[3])) & (fsm_output[1]) & and_dcpl_404
      & (fsm_output[0]);
  assign and_dcpl_490 = nor_359_cse & (fsm_output[3]) & (fsm_output[1]) & (fsm_output[2])
      & (~ (fsm_output[6])) & (fsm_output[0]);
  assign and_dcpl_494 = and_dcpl_191 & and_dcpl_190 & and_dcpl_404 & (~ (fsm_output[0]));
  assign and_dcpl_496 = and_dcpl_404 & (fsm_output[0]);
  assign and_dcpl_499 = nor_359_cse & (fsm_output[3]) & (fsm_output[1]);
  assign and_dcpl_504 = (fsm_output[5:4]==2'b01) & and_dcpl_190 & and_dcpl_496;
  assign and_dcpl_506 = and_dcpl_499 & and_dcpl_404 & (~ (fsm_output[0]));
  assign and_dcpl_512 = and_dcpl_191 & and_dcpl_171 & and_dcpl_496;
  assign and_dcpl_515 = and_dcpl_191 & (fsm_output[3]) & (fsm_output[1]) & and_dcpl_496;
  assign and_dcpl_519 = nor_359_cse & and_dcpl_171 & and_dcpl_404 & (~ (fsm_output[0]));
  assign and_dcpl_524 = nor_359_cse & (~ (fsm_output[3])) & (fsm_output[1]);
  assign and_dcpl_526 = and_dcpl_356 & (fsm_output[0]);
  assign and_dcpl_527 = and_dcpl_524 & and_dcpl_526;
  assign and_dcpl_536 = nor_359_cse & and_dcpl_171 & (fsm_output[2]) & (fsm_output[6])
      & (~ (fsm_output[0]));
  assign and_dcpl_542 = and_dcpl_191 & (~ (fsm_output[3])) & (fsm_output[1]) & and_dcpl_381;
  assign and_dcpl_544 = and_dcpl_191 & and_dcpl_171 & and_dcpl_381;
  assign and_dcpl_548 = (fsm_output[5:4]==2'b11) & and_dcpl_190 & and_dcpl_381;
  assign and_dcpl_567 = and_dcpl_524 & and_dcpl_404 & (fsm_output[0]);
  assign nl_while_for_while_aelse_acc_11_sdt = (while_for_k_1_sva[8:1]) + 8'b11111101;
  assign while_for_while_aelse_acc_11_sdt = nl_while_for_while_aelse_acc_11_sdt[7:0];
  assign and_519_ssc = (fsm_output[5:4]==2'b10) & and_dcpl_190 & (fsm_output[2])
      & (fsm_output[6]) & (~ (fsm_output[0]));
  assign for_or_2_ssc = and_dcpl_442 | and_dcpl_446;
  assign or_tmp_219 = (fsm_output[5:2]!=4'b0000);
  assign not_tmp_535 = ~((fsm_output[2]) | (~ (fsm_output[6])));
  assign or_625_nl = for_11_slc_32_itm | (~ while_for_3_aif_acc_1_itm_32) | (fsm_output[0]);
  assign mux_tmp_513 = MUX_s_1_2_2(not_tmp_535, (fsm_output[6]), or_625_nl);
  assign and_708_nl = ((~ (fsm_output[5])) | for_11_slc_32_itm | (~ while_for_3_aif_acc_1_itm_32)
      | (fsm_output[0]) | (fsm_output[2])) & (fsm_output[6]);
  assign or_628_nl = (fsm_output[5]) | for_11_slc_32_itm | (~ while_for_3_aif_acc_1_itm_32)
      | (fsm_output[0]);
  assign mux_517_nl = MUX_s_1_2_2(not_tmp_535, (fsm_output[6]), or_628_nl);
  assign mux_tmp_517 = MUX_s_1_2_2(and_708_nl, mux_517_nl, fsm_output[4]);
  assign not_tmp_537 = ~(while_for_3_aif_acc_1_itm_32 & (fsm_output[6]));
  assign or_636_nl = (~ (fsm_output[5])) | (fsm_output[0]) | (~ (fsm_output[3]))
      | for_11_slc_32_itm | not_tmp_537;
  assign or_634_nl = (fsm_output[5]) | (fsm_output[0]) | (fsm_output[3]) | for_11_slc_32_itm
      | not_tmp_537;
  assign mux_tmp_523 = MUX_s_1_2_2(or_636_nl, or_634_nl, fsm_output[4]);
  assign or_tmp_236 = (fsm_output[0]) | (fsm_output[3]) | for_11_slc_32_itm | not_tmp_537;
  assign for_or_30_itm = and_dcpl_365 | and_dcpl_368;
  assign for_or_36_itm = and_dcpl_415 | and_dcpl_417;
  assign for_or_39_itm = and_dcpl_457 | and_dcpl_460 | and_dcpl_463;
  assign for_or_43_itm = and_dcpl_504 | and_dcpl_506;
  assign for_or_45_itm = and_dcpl_515 | and_dcpl_519;
  always @(posedge clk) begin
    if ( rst ) begin
      reg_srcbuf_rsci_cgo_ir_cse <= 1'b0;
      reg_src_rsci_iswt0_cse <= 1'b0;
      reg_dest_rsci_iswt0_cse <= 1'b0;
      while_for_while_aelse_asn_36_itm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen ) begin
      reg_srcbuf_rsci_cgo_ir_cse <= mux_132_rmff;
      reg_src_rsci_iswt0_cse <= MUX_s_1_2_2(mux_164_nl, mux_150_nl, fsm_output[2]);
      reg_dest_rsci_iswt0_cse <= MUX_s_1_2_2(mux_225_nl, mux_208_nl, fsm_output[1]);
      while_for_while_aelse_asn_36_itm <= srcbuf_rsci_data_out_d;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      dest_rsci_idat <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & ((~ mux_194_itm) | dest_rsci_idat_mx0c1 | and_dcpl_128 |
        and_dcpl_129 | dest_rsci_idat_mx0c4 | dest_rsci_idat_mx0c5) ) begin
      dest_rsci_idat <= MUX_v_32_2_2(32'b00000000000000000000000000000000, i_mux1h_nl,
          mux_194_itm);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      N_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & mux_315_nl ) begin
      N_sva <= src_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      i_sva_31_27 <= 5'b00000;
    end
    else if ( mux_507_nl & core_wen ) begin
      i_sva_31_27 <= i_mux1h_5_rgt[31:27];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      i_sva_26_0 <= 27'b000000000000000000000000000;
    end
    else if ( mux_512_nl & core_wen ) begin
      i_sva_26_0 <= i_mux1h_5_rgt[26:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_slc_for_acc_2_29_itm <= 1'b0;
    end
    else if ( core_wen & mux_329_nl ) begin
      for_slc_for_acc_2_29_itm <= MUX1HOT_s_1_3_2((z_out_14_29_28[1]), (z_out_4_32_30[0]),
          (z_out_4_32_30[1]), {and_dcpl_179 , and_dcpl_195 , and_dcpl_283});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_31_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & (mux_330_nl | (fsm_output[6])) ) begin
      for_31_slc_32_itm <= z_out_5[32];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_slc_for_acc_8_27_itm <= 1'b0;
    end
    else if ( core_wen & (mux_tmp_331 | (fsm_output[6])) ) begin
      for_slc_for_acc_8_27_itm <= z_out_6_32_27[0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_1_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_333_nl ) begin
      for_1_slc_32_itm <= MUX_s_1_2_2((readslicef_33_1_32(for_1_acc_nl)), while_for_land_3_lpi_2_dfm_mx0w2,
          and_306_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_10_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_348_nl ) begin
      for_10_slc_32_itm <= MUX1HOT_s_1_8_2((z_out_4_32_30[2]), (z_out_6_32_27[5]),
          z_out_7_32, z_out_8_32, (~ for_1_slc_32_itm), (readslicef_33_1_32(while_for_2_while_acc_2_nl)),
          while_else_acc_itm_32, (~ (z_out_5[32])), {for_or_6_nl , and_309_nl , and_310_nl
          , and_311_nl , and_298_nl , and_313_nl , and_dcpl_287 , and_315_nl});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_while_L_lpi_2_dfm_reg <= 5'b00000;
    end
    else if ( (~ mux_523_nl) & core_wen ) begin
      reg_while_L_lpi_2_dfm_reg <= mux1h_rgt[31:27];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_while_L_lpi_2_dfm_1_reg <= 27'b000000000000000000000000000;
    end
    else if ( (~ mux_531_nl) & core_wen ) begin
      reg_while_L_lpi_2_dfm_1_reg <= mux1h_rgt[26:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_slc_for_acc_4_28_itm <= 1'b0;
    end
    else if ( core_wen & (~(mux_365_nl & (fsm_output[6:5]==2'b00))) ) begin
      for_slc_for_acc_4_28_itm <= z_out_14_29_28[0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_slc_for_acc_6_29_itm <= 1'b0;
    end
    else if ( core_wen & (mux_369_nl | (fsm_output[6])) ) begin
      for_slc_for_acc_6_29_itm <= z_out_14_29_28[1];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_slc_for_acc_3_30_itm <= 1'b0;
    end
    else if ( core_wen & (mux_377_nl | (fsm_output[6])) ) begin
      for_slc_for_acc_3_30_itm <= MUX1HOT_s_1_3_2((z_out_1[30]), (z_out_9_32_30[0]),
          (z_out_10_32_30[0]), {and_dcpl_182 , and_326_nl , and_327_nl});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_13_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_389_nl ) begin
      for_13_slc_32_itm <= MUX1HOT_s_1_5_2(z_out_11_32, (z_out_5[32]), while_for_land_3_lpi_2_dfm_mx0w2,
          while_for_while_for_while_for_or_2_nl, while_for_while_for_while_for_nor_1_nl,
          {and_dcpl_183 , for_or_9_nl , and_329_nl , and_dcpl_315 , and_dcpl_316});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_14_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_399_nl ) begin
      for_14_slc_32_itm <= MUX1HOT_s_1_6_2(z_out_11_32, (z_out_10_32_30[2]), while_for_land_3_lpi_2_dfm_mx0w2,
          while_for_and_1_nl, while_for_while_for_while_for_or_1_nl, while_for_while_for_while_for_nor_3_nl,
          {for_or_11_nl , and_336_nl , and_337_nl , and_dcpl_321 , and_dcpl_315 ,
          and_dcpl_316});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_19_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_414_nl ) begin
      for_19_slc_32_itm <= MUX1HOT_s_1_3_2((z_out_10_32_30[2]), (z_out_9_32_30[2]),
          while_for_land_3_lpi_2_dfm_mx0w2, {and_dcpl_185 , and_340_nl , and_341_nl});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_11_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_421_nl ) begin
      for_11_slc_32_itm <= MUX1HOT_s_1_4_2((z_out_9_32_30[2]), (z_out_1[32]), (z_out_4_32_30[2]),
          while_while_while_or_nl, {and_dcpl_187 , and_342_nl , and_343_nl , and_dcpl_128});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_15_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_433_nl ) begin
      for_15_slc_32_itm <= MUX_s_1_2_2((z_out_1[32]), while_for_land_3_lpi_2_dfm_mx0w2,
          and_344_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_17_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_437_nl ) begin
      for_17_slc_32_itm <= MUX_s_1_2_2(z_out_8_32, while_for_land_3_lpi_2_dfm_mx0w2,
          and_346_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_18_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & mux_445_nl ) begin
      for_18_slc_32_itm <= MUX_s_1_2_2(z_out_8_32, while_for_land_3_lpi_2_dfm_mx0w2,
          and_dcpl_321);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      while_for_while_for_while_for_nor_1_itm_2 <= 1'b0;
    end
    else if ( core_wen & (~ mux_454_nl) ) begin
      while_for_while_for_while_for_nor_1_itm_2 <= MUX1HOT_s_1_4_2(z_out_7_32, while_for_if_while_for_if_and_nl,
          while_for_while_for_while_for_or_nl, while_for_while_for_while_for_nor_4_nl,
          {and_dcpl_196 , and_347_nl , and_dcpl_315 , and_dcpl_316});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_25_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & (mux_458_nl | (fsm_output[6])) ) begin
      for_25_slc_32_itm <= z_out_7_32;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_26_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & (mux_460_nl | (fsm_output[6])) ) begin
      for_26_slc_32_itm <= z_out_6_32_27[5];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_27_slc_32_itm <= 1'b0;
    end
    else if ( core_wen & (mux_461_nl | (fsm_output[6])) ) begin
      for_27_slc_32_itm <= z_out_6_32_27[5];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_slc_s_1_31_5_3_0_30_itm <= 4'b0000;
    end
    else if ( core_wen & (~((and_696_cse | (fsm_output[2])) & (fsm_output[5]) & and_378_cse
        & (~ (fsm_output[6])))) ) begin
      for_slc_s_1_31_5_3_0_30_itm <= i_sva_26_0[3:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      while_for_k_1_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(mux_478_nl & (fsm_output[6]))) ) begin
      while_for_k_1_sva <= MUX_v_32_2_2(32'b00000000000000000000000000000000, while_for_k_mux_1_nl,
          nand_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      while_for_1_while_acc_2_itm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_480_nl) & (fsm_output[6]))) ) begin
      while_for_1_while_acc_2_itm <= z_out_5[31:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      while_for_1_while_aif_acc_3_itm <= 9'b000000000;
    end
    else if ( core_wen & for_10_slc_32_itm ) begin
      while_for_1_while_aif_acc_3_itm <= z_out_1[8:0];
    end
  end
  assign nor_172_nl = ~((fsm_output[6]) | (fsm_output[1]) | (fsm_output[3]) | (fsm_output[4])
      | (fsm_output[5]));
  assign and_418_nl = or_584_cse & for_1_acc_2_itm_32_1;
  assign mux_159_nl = MUX_s_1_2_2(and_418_nl, for_17_slc_32_itm, fsm_output[5]);
  assign mux_160_nl = MUX_s_1_2_2(mux_159_nl, mux_220_cse, fsm_output[4]);
  assign mux_161_nl = MUX_s_1_2_2(mux_160_nl, mux_219_cse, fsm_output[3]);
  assign mux_162_nl = MUX_s_1_2_2(mux_161_nl, mux_206_cse, fsm_output[1]);
  assign nor_173_nl = ~(for_10_slc_32_itm | (fsm_output[1]) | (fsm_output[3]) | (fsm_output[4])
      | (fsm_output[5]));
  assign mux_163_nl = MUX_s_1_2_2(mux_162_nl, nor_173_nl, fsm_output[6]);
  assign mux_164_nl = MUX_s_1_2_2(nor_172_nl, mux_163_nl, fsm_output[0]);
  assign nor_174_nl = ~((fsm_output[1]) | mux_tmp_147);
  assign mux_148_nl = MUX_s_1_2_2((~ mux_tmp_147), and_396_cse, fsm_output[1]);
  assign mux_149_nl = MUX_s_1_2_2(nor_174_nl, mux_148_nl, for_10_slc_32_itm);
  assign and_123_nl = (fsm_output[6]) & mux_149_nl;
  assign mux_145_nl = MUX_s_1_2_2(mux_218_cse, mux_200_cse, fsm_output[1]);
  assign and_420_nl = (fsm_output[1]) & (fsm_output[3]) & (fsm_output[4]) & (fsm_output[5]);
  assign mux_146_nl = MUX_s_1_2_2(mux_145_nl, and_420_nl, fsm_output[6]);
  assign mux_150_nl = MUX_s_1_2_2(and_123_nl, mux_146_nl, fsm_output[0]);
  assign mux_224_nl = MUX_s_1_2_2(mux_223_cse, mux_218_cse, fsm_output[2]);
  assign nor_280_nl = ~((~ (fsm_output[0])) | mux_224_nl);
  assign nor_203_nl = ~((fsm_output[5:4]!=2'b11) | (while_for_k_1_sva!=32'b00000000000000000000000000000000));
  assign mux_210_nl = MUX_s_1_2_2(and_702_cse, nor_203_nl, while_else_acc_itm_32);
  assign and_456_nl = (fsm_output[3:2]==2'b11) & mux_210_nl;
  assign and_184_nl = (fsm_output[5:3]==3'b111) & or_461_cse;
  assign mux_209_nl = MUX_s_1_2_2(nor_204_cse, and_184_nl, fsm_output[2]);
  assign and_457_nl = for_10_slc_32_itm & mux_209_nl;
  assign mux_211_nl = MUX_s_1_2_2(and_456_nl, and_457_nl, fsm_output[0]);
  assign mux_225_nl = MUX_s_1_2_2(nor_280_nl, mux_211_nl, fsm_output[6]);
  assign mux_207_nl = MUX_s_1_2_2(mux_206_cse, mux_200_cse, fsm_output[2]);
  assign nor_281_nl = ~((~ (fsm_output[0])) | mux_207_nl);
  assign nor_209_nl = ~(nor_208_cse | (fsm_output[5:4]!=2'b00));
  assign mux_195_nl = MUX_s_1_2_2(nor_209_nl, and_702_cse, fsm_output[3]);
  assign nor_282_nl = ~((fsm_output[2]) | (~ mux_195_nl));
  assign mux_208_nl = MUX_s_1_2_2(nor_281_nl, nor_282_nl, fsm_output[6]);
  assign while_for_while_for_or_nl = for_1_slc_32_itm | while_for_land_3_lpi_2_dfm_mx0w2;
  assign while_for_while_for_and_4_nl = while_for_while_for_while_for_nor_1_itm_2
      & (~ while_for_land_3_lpi_2_dfm_mx0w2);
  assign while_for_while_for_and_5_nl = for_13_slc_32_itm & (~ while_for_land_3_lpi_2_dfm_mx0w2);
  assign while_for_while_for_or_2_nl = for_14_slc_32_itm | while_for_land_3_lpi_2_dfm_mx0w2;
  assign i_mux1h_nl = MUX1HOT_v_32_5_2(({i_sva_31_27 , i_sva_26_0}), ({28'b0000000000000000000000000000
      , while_for_while_for_or_nl , while_for_while_for_and_4_nl , while_for_while_for_and_5_nl
      , while_for_while_for_or_2_nl}), while_for_k_1_sva, while_for_while_aelse_asn_36_itm,
      srcbuf_rsci_data_out_d, {dest_rsci_idat_mx0c1 , and_dcpl_128 , and_dcpl_129
      , dest_rsci_idat_mx0c4 , dest_rsci_idat_mx0c5});
  assign and_437_nl = (fsm_output[5:0]==6'b111111);
  assign mux_315_nl = MUX_s_1_2_2(and_dcpl_177, and_437_nl, fsm_output[6]);
  assign or_620_nl = (fsm_output[0]) | (~((fsm_output[1]) & (fsm_output[3]) & (fsm_output[4])
      & (fsm_output[5])));
  assign mux_506_nl = MUX_s_1_2_2(or_tmp_113, or_620_nl, fsm_output[2]);
  assign or_619_nl = and_696_cse | (fsm_output[5:3]!=3'b000);
  assign mux_nl = MUX_s_1_2_2(or_642_cse, nand_66_cse, fsm_output[3]);
  assign or_618_nl = (fsm_output[1:0]!=2'b00) | mux_nl;
  assign mux_504_nl = MUX_s_1_2_2(or_618_nl, or_tmp_113, and_698_cse);
  assign mux_505_nl = MUX_s_1_2_2(or_619_nl, mux_504_nl, fsm_output[2]);
  assign mux_507_nl = MUX_s_1_2_2(mux_506_nl, (~ mux_505_nl), fsm_output[6]);
  assign and_699_nl = (fsm_output[5:2]==4'b1111);
  assign mux_511_nl = MUX_s_1_2_2((~ or_tmp_219), and_699_nl, fsm_output[1]);
  assign and_703_nl = (fsm_output[0]) & mux_511_nl;
  assign mux_509_nl = MUX_s_1_2_2(mux_508_cse, nor_204_cse, and_698_cse);
  assign nand_63_nl = ~((fsm_output[2]) & mux_509_nl);
  assign mux_510_nl = MUX_s_1_2_2(nand_63_nl, or_tmp_219, fsm_output[1]);
  assign nor_nl = ~((fsm_output[0]) | mux_510_nl);
  assign mux_512_nl = MUX_s_1_2_2(and_703_nl, nor_nl, fsm_output[6]);
  assign mux_327_nl = MUX_s_1_2_2(mux_tmp_326, nor_tmp_1, and_696_cse);
  assign or_508_nl = (~((fsm_output[4:3]!=2'b01))) | (fsm_output[5]);
  assign mux_325_nl = MUX_s_1_2_2(nor_tmp_1, or_508_nl, and_696_cse);
  assign mux_328_nl = MUX_s_1_2_2(mux_327_nl, mux_325_nl, fsm_output[2]);
  assign or_506_nl = (fsm_output[5:0]!=6'b000011);
  assign mux_329_nl = MUX_s_1_2_2(mux_328_nl, or_506_nl, fsm_output[6]);
  assign and_440_nl = or_291_cse & (fsm_output[5:3]==3'b111);
  assign mux_330_nl = MUX_s_1_2_2(not_tmp_348, and_440_nl, fsm_output[2]);
  assign nl_for_1_acc_nl = conv_s2u_32_33({s_1_31_5_sva_2 , 5'b00000}) - conv_s2u_32_33(N_sva);
  assign for_1_acc_nl = nl_for_1_acc_nl[32:0];
  assign and_306_nl = and_dcpl_217 & and_dcpl_284;
  assign or_99_nl = (fsm_output[1]) | (~ and_396_cse);
  assign or_515_nl = nor_110_cse | (fsm_output[3]) | (~ and_702_cse);
  assign mux_332_nl = MUX_s_1_2_2(or_99_nl, or_515_nl, fsm_output[2]);
  assign mux_333_nl = MUX_s_1_2_2(mux_tmp_331, mux_332_nl, fsm_output[6]);
  assign nl_while_for_2_while_acc_2_nl = conv_s2u_32_33(while_for_1_while_acc_3)
      - conv_s2u_32_33(N_sva);
  assign while_for_2_while_acc_2_nl = nl_while_for_2_while_acc_2_nl[32:0];
  assign for_or_6_nl = and_dcpl_179 | (and_dcpl_120 & and_dcpl_291);
  assign and_309_nl = (~ or_tmp_114) & and_dcpl_281;
  assign and_310_nl = and_dcpl_184 & and_dcpl_291;
  assign and_311_nl = and_dcpl_194 & and_dcpl_291;
  assign and_298_nl = and_dcpl_127 & and_dcpl_281;
  assign mux_352_nl = MUX_s_1_2_2(mux_tmp_351, mux_tmp_349, fsm_output[1]);
  assign mux_355_nl = MUX_s_1_2_2(mux_tmp_354, mux_352_nl, fsm_output[2]);
  assign and_313_nl = (~ mux_355_nl) & and_436_cse;
  assign and_315_nl = and_dcpl_172 & and_dcpl_169 & (fsm_output[6]);
  assign mux_344_nl = MUX_s_1_2_2(mux_tmp_42, or_tmp_154, fsm_output[0]);
  assign or_523_nl = (fsm_output[0]) | (fsm_output[6]);
  assign mux_345_nl = MUX_s_1_2_2(mux_344_nl, or_523_nl, fsm_output[3]);
  assign mux_346_nl = MUX_s_1_2_2(mux_345_nl, mux_tmp_335, fsm_output[4]);
  assign nor_259_nl = ~((~((fsm_output[0]) | (fsm_output[6]))) | (fsm_output[5]));
  assign mux_342_nl = MUX_s_1_2_2(nor_259_nl, (fsm_output[5]), fsm_output[3]);
  assign mux_343_nl = MUX_s_1_2_2(mux_342_nl, or_538_cse, fsm_output[4]);
  assign mux_347_nl = MUX_s_1_2_2(mux_346_nl, mux_343_nl, fsm_output[2]);
  assign mux_339_nl = MUX_s_1_2_2(or_tmp_154, (~ mux_tmp_42), fsm_output[3]);
  assign or_519_nl = (~((~ (fsm_output[0])) | (fsm_output[6]))) | (fsm_output[5]);
  assign mux_338_nl = MUX_s_1_2_2(or_519_nl, or_538_cse, fsm_output[3]);
  assign mux_340_nl = MUX_s_1_2_2(mux_339_nl, mux_338_nl, fsm_output[4]);
  assign mux_336_nl = MUX_s_1_2_2(and_441_cse, or_538_cse, fsm_output[3]);
  assign mux_337_nl = MUX_s_1_2_2(mux_336_nl, mux_tmp_335, fsm_output[4]);
  assign mux_341_nl = MUX_s_1_2_2(mux_340_nl, mux_337_nl, fsm_output[2]);
  assign mux_348_nl = MUX_s_1_2_2(mux_347_nl, mux_341_nl, fsm_output[1]);
  assign or_632_nl = (~((fsm_output[5]) | (fsm_output[2]))) | (fsm_output[6]);
  assign and_704_nl = (for_11_slc_32_itm | (~ while_for_3_aif_acc_1_itm_32) | (fsm_output[0])
      | (fsm_output[2])) & (fsm_output[6]);
  assign mux_520_nl = MUX_s_1_2_2(and_704_nl, mux_tmp_513, fsm_output[5]);
  assign mux_521_nl = MUX_s_1_2_2(or_632_nl, mux_520_nl, fsm_output[4]);
  assign mux_522_nl = MUX_s_1_2_2(mux_521_nl, mux_tmp_517, fsm_output[3]);
  assign and_705_nl = ((fsm_output[0]) | (fsm_output[2])) & (fsm_output[6]);
  assign mux_515_nl = MUX_s_1_2_2(and_705_nl, mux_tmp_513, fsm_output[5]);
  assign and_706_nl = (fsm_output[5]) & (fsm_output[0]);
  assign mux_513_nl = MUX_s_1_2_2((fsm_output[6]), (fsm_output[2]), and_706_nl);
  assign mux_516_nl = MUX_s_1_2_2(mux_515_nl, mux_513_nl, fsm_output[4]);
  assign mux_519_nl = MUX_s_1_2_2(mux_tmp_517, mux_516_nl, fsm_output[3]);
  assign mux_523_nl = MUX_s_1_2_2(mux_522_nl, mux_519_nl, fsm_output[1]);
  assign mux_527_nl = MUX_s_1_2_2((fsm_output[6]), (~ (fsm_output[6])), fsm_output[3]);
  assign or_641_nl = (fsm_output[0]) | mux_527_nl;
  assign mux_528_nl = MUX_s_1_2_2(or_641_nl, or_tmp_236, fsm_output[5]);
  assign nand_69_nl = ~((fsm_output[5]) & (fsm_output[0]) & (fsm_output[3]) & (fsm_output[6]));
  assign mux_529_nl = MUX_s_1_2_2(mux_528_nl, nand_69_nl, fsm_output[4]);
  assign mux_530_nl = MUX_s_1_2_2(mux_tmp_523, mux_529_nl, fsm_output[1]);
  assign or_640_nl = (fsm_output[0]) | (~ (fsm_output[3])) | for_11_slc_32_itm |
      not_tmp_537;
  assign mux_525_nl = MUX_s_1_2_2(or_640_nl, or_tmp_236, fsm_output[5]);
  assign nand_64_nl = ~((fsm_output[4]) & (~ mux_525_nl));
  assign mux_526_nl = MUX_s_1_2_2(nand_64_nl, mux_tmp_523, fsm_output[1]);
  assign mux_531_nl = MUX_s_1_2_2(mux_530_nl, mux_526_nl, fsm_output[2]);
  assign nand_50_nl = ~((fsm_output[0]) & (fsm_output[1]) & (fsm_output[3]) & (fsm_output[4]));
  assign mux_365_nl = MUX_s_1_2_2(or_602_cse, nand_50_nl, fsm_output[2]);
  assign mux_366_nl = MUX_s_1_2_2(mux_48_cse, and_702_cse, or_533_cse);
  assign and_444_nl = (and_443_cse | (fsm_output[4])) & (fsm_output[5]);
  assign mux_367_nl = MUX_s_1_2_2(mux_366_nl, and_444_nl, fsm_output[0]);
  assign mux_369_nl = MUX_s_1_2_2(mux_tmp_368, mux_367_nl, fsm_output[2]);
  assign and_326_nl = and_dcpl_186 & and_dcpl_291;
  assign and_327_nl = and_dcpl_198 & and_dcpl_291;
  assign mux_375_nl = MUX_s_1_2_2(nor_359_cse, or_tmp_144, fsm_output[3]);
  assign mux_376_nl = MUX_s_1_2_2(mux_375_nl, mux_tmp_374, fsm_output[1]);
  assign mux_372_nl = MUX_s_1_2_2(mux_508_cse, and_396_cse, fsm_output[1]);
  assign mux_370_nl = MUX_s_1_2_2(or_tmp_144, and_702_cse, fsm_output[3]);
  assign mux_371_nl = MUX_s_1_2_2(and_396_cse, mux_370_nl, fsm_output[1]);
  assign mux_373_nl = MUX_s_1_2_2(mux_372_nl, mux_371_nl, fsm_output[0]);
  assign mux_377_nl = MUX_s_1_2_2(mux_376_nl, mux_373_nl, fsm_output[2]);
  assign while_for_while_for_while_for_or_2_nl = (~((~((while_for_while_for_while_for_nor_1_itm_2
      & (~ for_13_slc_32_itm)) | for_15_slc_32_itm)) | for_17_slc_32_itm | for_18_slc_32_itm))
      | for_14_slc_32_itm;
  assign while_for_while_for_while_for_nor_1_nl = ~((~(for_14_slc_32_itm | for_19_slc_32_itm))
      | for_1_slc_32_itm);
  assign for_or_9_nl = and_dcpl_188 | and_dcpl_201;
  assign and_329_nl = and_dcpl_192 & and_dcpl_124;
  assign nand_12_nl = ~((fsm_output[6]) & (~(and_dcpl_12 | (~ (fsm_output[5])))));
  assign mux_385_nl = MUX_s_1_2_2(or_tmp_168, nand_12_nl, fsm_output[3]);
  assign mux_386_nl = MUX_s_1_2_2(or_tmp_170, mux_385_nl, fsm_output[4]);
  assign mux_387_nl = MUX_s_1_2_2((~ mux_386_nl), mux_tmp_13, fsm_output[2]);
  assign mux_388_nl = MUX_s_1_2_2(mux_387_nl, mux_tmp_383, fsm_output[1]);
  assign mux_378_nl = MUX_s_1_2_2((~ or_tmp_168), nor_tmp_6, fsm_output[4]);
  assign mux_380_nl = MUX_s_1_2_2(mux_tmp_13, mux_378_nl, fsm_output[2]);
  assign mux_384_nl = MUX_s_1_2_2(mux_tmp_383, mux_380_nl, fsm_output[1]);
  assign mux_389_nl = MUX_s_1_2_2(mux_388_nl, mux_384_nl, fsm_output[0]);
  assign while_for_and_1_nl = for_14_slc_32_itm & (~ while_for_land_3_lpi_2_dfm_mx0w2);
  assign while_for_while_for_while_for_or_1_nl = (~((~(for_13_slc_32_itm | for_15_slc_32_itm))
      | for_17_slc_32_itm | for_14_slc_32_itm)) | for_18_slc_32_itm;
  assign while_for_while_for_while_for_nor_3_nl = ~((~(for_13_slc_32_itm | for_19_slc_32_itm))
      | for_1_slc_32_itm);
  assign for_or_11_nl = (and_dcpl_120 & and_dcpl_281) | (and_dcpl_184 & and_dcpl_281);
  assign and_336_nl = and_dcpl_200 & and_dcpl_291;
  assign and_337_nl = and_dcpl_207 & and_dcpl_124;
  assign mux_396_nl = MUX_s_1_2_2(nor_268_cse, (fsm_output[5]), and_696_cse);
  assign mux_397_nl = MUX_s_1_2_2(mux_396_nl, (fsm_output[5]), fsm_output[2]);
  assign mux_398_nl = MUX_s_1_2_2(mux_397_nl, or_tmp_168, fsm_output[4]);
  assign mux_393_nl = MUX_s_1_2_2((fsm_output[6]), (~ or_tmp_168), or_291_cse);
  assign nor_271_nl = ~((~((~((fsm_output[1:0]!=2'b01))) | (fsm_output[6]))) | (fsm_output[5]));
  assign mux_394_nl = MUX_s_1_2_2(mux_393_nl, nor_271_nl, fsm_output[2]);
  assign or_540_nl = (~ while_for_3_while_aif_equal_tmp) | (~ for_10_slc_32_itm)
      | (fsm_output[1]);
  assign mux_390_nl = MUX_s_1_2_2((~ or_tmp_168), (fsm_output[6]), or_540_nl);
  assign or_539_nl = (fsm_output[1]) | (fsm_output[6]);
  assign mux_391_nl = MUX_s_1_2_2(mux_390_nl, or_539_nl, fsm_output[0]);
  assign mux_392_nl = MUX_s_1_2_2(mux_391_nl, or_538_cse, fsm_output[2]);
  assign mux_395_nl = MUX_s_1_2_2(mux_394_nl, mux_392_nl, fsm_output[4]);
  assign mux_399_nl = MUX_s_1_2_2((~ mux_398_nl), mux_395_nl, fsm_output[3]);
  assign and_340_nl = and_dcpl_192 & and_dcpl_291;
  assign and_341_nl = and_dcpl_213 & and_dcpl_284;
  assign mux_411_nl = MUX_s_1_2_2(mux_44_cse, and_tmp, fsm_output[3]);
  assign mux_409_nl = MUX_s_1_2_2(nor_268_cse, and_441_cse, fsm_output[4]);
  assign mux_410_nl = MUX_s_1_2_2((~ mux_409_nl), or_538_cse, fsm_output[3]);
  assign mux_412_nl = MUX_s_1_2_2((~ mux_411_nl), mux_410_nl, fsm_output[0]);
  assign mux_408_nl = MUX_s_1_2_2(mux_tmp_406, mux_tmp_403, fsm_output[0]);
  assign mux_413_nl = MUX_s_1_2_2(mux_412_nl, mux_408_nl, fsm_output[2]);
  assign mux_401_nl = MUX_s_1_2_2((~ mux_tmp_42), or_538_cse, fsm_output[4]);
  assign mux_402_nl = MUX_s_1_2_2((~ and_tmp), mux_401_nl, fsm_output[3]);
  assign mux_404_nl = MUX_s_1_2_2(mux_tmp_403, mux_402_nl, fsm_output[0]);
  assign mux_407_nl = MUX_s_1_2_2(mux_tmp_406, mux_404_nl, fsm_output[2]);
  assign mux_414_nl = MUX_s_1_2_2(mux_413_nl, mux_407_nl, fsm_output[1]);
  assign while_while_while_or_nl = (while_L_lpi_2_dfm_8_mx0!=32'b00000000000000000000000000000000);
  assign and_342_nl = and_dcpl_192 & and_dcpl_281;
  assign mux_422_nl = MUX_s_1_2_2(and_dcpl_204, and_702_cse, fsm_output[3]);
  assign mux_423_nl = MUX_s_1_2_2((~ mux_422_nl), mux_tmp_357, fsm_output[1]);
  assign mux_424_nl = MUX_s_1_2_2(mux_423_nl, mux_tmp_354, fsm_output[2]);
  assign and_343_nl = (~ mux_424_nl) & and_436_cse;
  assign and_447_nl = (fsm_output[0]) & (fsm_output[1]) & (fsm_output[3]);
  assign mux_419_nl = MUX_s_1_2_2(mux_48_cse, and_702_cse, and_447_nl);
  assign mux_417_nl = MUX_s_1_2_2(mux_tmp_368, mux_24_cse, fsm_output[1]);
  assign mux_416_nl = MUX_s_1_2_2(mux_tmp_326, mux_24_cse, fsm_output[1]);
  assign mux_418_nl = MUX_s_1_2_2(mux_417_nl, mux_416_nl, fsm_output[0]);
  assign mux_420_nl = MUX_s_1_2_2(mux_419_nl, mux_418_nl, fsm_output[2]);
  assign or_549_nl = (fsm_output[2]) | (~ nor_tmp_46);
  assign mux_421_nl = MUX_s_1_2_2(mux_420_nl, or_549_nl, fsm_output[6]);
  assign and_344_nl = and_dcpl_194 & and_dcpl_284;
  assign or_554_nl = and_443_cse | (fsm_output[5:4]!=2'b01);
  assign or_553_nl = (fsm_output[5:3]!=3'b010);
  assign mux_429_nl = MUX_s_1_2_2(or_tmp_158, or_642_cse, fsm_output[3]);
  assign mux_430_nl = MUX_s_1_2_2(or_553_nl, mux_429_nl, fsm_output[1]);
  assign mux_431_nl = MUX_s_1_2_2(or_554_nl, mux_430_nl, fsm_output[0]);
  assign mux_432_nl = MUX_s_1_2_2(or_tmp_158, mux_431_nl, fsm_output[2]);
  assign nor_113_nl = ~(and_378_cse | (fsm_output[5]));
  assign mux_427_nl = MUX_s_1_2_2(nor_113_nl, mux_tmp_74, or_291_cse);
  assign mux_426_nl = MUX_s_1_2_2(mux_tmp_74, mux_tmp_374, and_696_cse);
  assign mux_428_nl = MUX_s_1_2_2(mux_427_nl, mux_426_nl, fsm_output[2]);
  assign mux_433_nl = MUX_s_1_2_2(mux_432_nl, mux_428_nl, fsm_output[6]);
  assign and_346_nl = and_dcpl_198 & and_dcpl_284;
  assign or_559_nl = (fsm_output[3:0]!=4'b0000);
  assign mux_436_nl = MUX_s_1_2_2(mux_48_cse, or_tmp_158, or_559_nl);
  assign nand_51_nl = ~((~(or_291_cse & (fsm_output[4:3]==2'b11))) & (fsm_output[5]));
  assign mux_435_nl = MUX_s_1_2_2(nand_51_nl, mux_tmp_434, fsm_output[2]);
  assign mux_437_nl = MUX_s_1_2_2(mux_436_nl, mux_435_nl, fsm_output[6]);
  assign mux_441_nl = MUX_s_1_2_2(or_tmp_144, or_tmp_158, fsm_output[3]);
  assign mux_440_nl = MUX_s_1_2_2(mux_48_cse, or_tmp_158, fsm_output[3]);
  assign mux_442_nl = MUX_s_1_2_2(mux_441_nl, mux_440_nl, fsm_output[1]);
  assign mux_439_nl = MUX_s_1_2_2(mux_48_cse, or_tmp_158, or_533_cse);
  assign mux_443_nl = MUX_s_1_2_2(mux_442_nl, mux_439_nl, fsm_output[0]);
  assign mux_444_nl = MUX_s_1_2_2(mux_443_nl, or_tmp_158, fsm_output[2]);
  assign and_452_nl = ((fsm_output[2:0]!=3'b000)) & (fsm_output[3]);
  assign mux_438_nl = MUX_s_1_2_2((~ and_702_cse), or_tmp_144, and_452_nl);
  assign mux_445_nl = MUX_s_1_2_2(mux_444_nl, mux_438_nl, fsm_output[6]);
  assign while_for_if_while_for_if_and_nl = (z_out_5[32]) & (~ (z_out_4_32_30[2]));
  assign while_for_while_for_while_for_or_nl = for_17_slc_32_itm | for_14_slc_32_itm
      | for_18_slc_32_itm;
  assign while_for_while_for_while_for_nor_4_nl = ~((~(while_for_while_for_while_for_nor_1_itm_2
      | for_19_slc_32_itm)) | for_1_slc_32_itm);
  assign and_347_nl = and_dcpl_184 & and_dcpl_117;
  assign mux_450_nl = MUX_s_1_2_2(or_538_cse, (fsm_output[6]), fsm_output[0]);
  assign mux_451_nl = MUX_s_1_2_2((fsm_output[5]), mux_450_nl, fsm_output[1]);
  assign mux_452_nl = MUX_s_1_2_2(mux_451_nl, (fsm_output[6]), fsm_output[2]);
  assign mux_453_nl = MUX_s_1_2_2((fsm_output[5]), mux_452_nl, fsm_output[3]);
  assign mux_447_nl = MUX_s_1_2_2((fsm_output[6]), or_tmp_154, or_291_cse);
  assign mux_448_nl = MUX_s_1_2_2((fsm_output[6]), mux_447_nl, fsm_output[2]);
  assign or_562_nl = (~ while_for_3_while_aif_equal_tmp) | (~ for_10_slc_32_itm)
      | (fsm_output[2:0]!=3'b000);
  assign mux_446_nl = MUX_s_1_2_2(or_tmp_154, (~ (fsm_output[5])), or_562_nl);
  assign mux_449_nl = MUX_s_1_2_2(mux_448_nl, mux_446_nl, fsm_output[3]);
  assign mux_454_nl = MUX_s_1_2_2(mux_453_nl, mux_449_nl, fsm_output[4]);
  assign or_566_nl = and_696_cse | (fsm_output[3]);
  assign mux_455_nl = MUX_s_1_2_2(or_tmp_144, mux_48_cse, or_566_nl);
  assign mux_458_nl = MUX_s_1_2_2(mux_tmp_457, mux_455_nl, fsm_output[2]);
  assign mux_459_nl = MUX_s_1_2_2(mux_tmp_74, mux_tmp_456, and_696_cse);
  assign mux_460_nl = MUX_s_1_2_2(mux_459_nl, mux_tmp_456, fsm_output[2]);
  assign mux_461_nl = MUX_s_1_2_2(mux_tmp_434, mux_tmp_457, fsm_output[2]);
  assign and_362_nl = and_396_cse & or_529_cse & and_dcpl_241;
  assign while_for_k_mux_1_nl = MUX_v_32_2_2(while_for_1_while_acc_2_itm, ({reg_while_L_lpi_2_dfm_reg
      , reg_while_L_lpi_2_dfm_1_reg}), and_362_nl);
  assign mux_462_nl = MUX_s_1_2_2(and_dcpl_191, (fsm_output[5]), fsm_output[3]);
  assign mux_463_nl = MUX_s_1_2_2((~ mux_tmp_351), mux_462_nl, fsm_output[1]);
  assign mux_464_nl = MUX_s_1_2_2((~ mux_tmp_354), mux_463_nl, fsm_output[2]);
  assign nand_nl = ~(mux_464_nl & and_dcpl_302);
  assign or_573_nl = and_dcpl_12 | (~ nor_tmp_98);
  assign mux_475_nl = MUX_s_1_2_2(or_573_nl, mux_tmp_471, fsm_output[1]);
  assign mux_476_nl = MUX_s_1_2_2((~ mux_475_nl), or_tmp_204, fsm_output[0]);
  assign mux_477_nl = MUX_s_1_2_2(mux_476_nl, or_tmp_205, fsm_output[5]);
  assign nor_279_nl = ~((or_529_cse & (fsm_output[4])) | (fsm_output[2]));
  assign mux_469_nl = MUX_s_1_2_2(mux_tmp_468, nor_279_nl, fsm_output[1]);
  assign mux_470_nl = MUX_s_1_2_2(mux_469_nl, (~ nor_tmp_98), fsm_output[0]);
  assign mux_474_nl = MUX_s_1_2_2(or_tmp_205, mux_470_nl, fsm_output[5]);
  assign mux_478_nl = MUX_s_1_2_2(mux_477_nl, mux_474_nl, fsm_output[3]);
  assign mux_479_nl = MUX_s_1_2_2(mux_tmp_353, mux_tmp_351, fsm_output[1]);
  assign mux_480_nl = MUX_s_1_2_2(mux_tmp_358, mux_479_nl, fsm_output[2]);
  assign for_for_mux_22_nl = MUX_s_1_2_2((i_sva_26_0[26]), (i_sva_26_0[8]), and_dcpl_370);
  assign for_mux1h_120_nl = MUX1HOT_v_17_3_2((signext_17_16(i_sva_26_0[26:11])),
      (i_sva_26_0[25:9]), (signext_17_1(i_sva_26_0[8])), {and_dcpl_361 , for_or_30_itm
      , and_dcpl_370});
  assign for_or_48_nl = and_dcpl_365 | and_dcpl_368 | and_dcpl_370;
  assign for_for_mux_23_nl = MUX_s_1_2_2((i_sva_26_0[10]), (i_sva_26_0[8]), for_or_48_nl);
  assign for_mux1h_121_nl = MUX1HOT_s_1_3_2((i_sva_26_0[9]), (i_sva_26_0[7]), (i_sva_26_0[8]),
      {and_dcpl_361 , for_or_30_itm , and_dcpl_370});
  assign for_for_mux_24_nl = MUX_s_1_2_2((i_sva_26_0[8]), (i_sva_26_0[6]), for_or_30_itm);
  assign for_mux1h_122_nl = MUX1HOT_v_6_3_2((i_sva_26_0[7:2]), (i_sva_26_0[5:0]),
      (signext_6_4(i_sva_26_0[8:5])), {and_dcpl_361 , for_or_30_itm , and_dcpl_370});
  assign for_mux1h_123_nl = MUX1HOT_v_2_4_2((i_sva_26_0[1:0]), 2'b10, 2'b01, (i_sva_26_0[4:3]),
      {and_dcpl_361 , and_dcpl_365 , and_dcpl_368 , and_dcpl_370});
  assign for_mux_10_nl = MUX_v_3_2_2(3'b110, (i_sva_26_0[2:0]), and_dcpl_370);
  assign not_1093_nl = ~ and_dcpl_361;
  assign for_for_and_2_nl = MUX_v_3_2_2(3'b000, for_mux_10_nl, not_1093_nl);
  assign for_or_49_nl = (~ and_dcpl_370) | and_dcpl_361 | and_dcpl_365 | and_dcpl_368;
  assign for_mux1h_124_nl = MUX1HOT_v_32_3_2((signext_32_30(~ (N_sva[31:2]))), (~
      N_sva), (signext_32_9(while_for_k_1_sva[8:0])), {and_dcpl_361 , for_or_30_itm
      , and_dcpl_370});
  assign nl_acc_1_nl = conv_s2u_33_34({for_for_mux_22_nl , for_mux1h_120_nl , for_for_mux_23_nl
      , for_mux1h_121_nl , for_for_mux_24_nl , for_mux1h_122_nl , for_mux1h_123_nl
      , for_for_and_2_nl , for_or_49_nl}) + conv_s2u_33_34({for_mux1h_124_nl , 1'b1});
  assign acc_1_nl = nl_acc_1_nl[33:0];
  assign z_out_1 = readslicef_34_33_1(acc_1_nl);
  assign for_or_50_nl = and_dcpl_409 | and_dcpl_415 | and_dcpl_417;
  assign for_mux1h_125_nl = MUX1HOT_s_1_3_2((i_sva_26_0[26]), (~ (N_sva[31])), (while_for_k_1_sva[31]),
      {for_or_50_nl , and_dcpl_414 , and_dcpl_419});
  assign for_mux1h_126_nl = MUX1HOT_v_26_4_2((signext_26_25(i_sva_26_0[26:2])), (~
      (N_sva[31:6])), (i_sva_26_0[25:0]), (while_for_k_1_sva[30:5]), {and_dcpl_409
      , and_dcpl_414 , for_or_36_itm , and_dcpl_419});
  assign for_mux1h_127_nl = MUX1HOT_v_5_5_2(({(i_sva_26_0[1:0]) , 3'b100}), (~ (N_sva[5:1])),
      5'b00001, 5'b00010, (while_for_k_1_sva[4:0]), {and_dcpl_409 , and_dcpl_414
      , and_dcpl_415 , and_dcpl_417 , and_dcpl_419});
  assign for_or_51_nl = (~(and_dcpl_414 | and_dcpl_419)) | and_dcpl_409 | and_dcpl_415
      | and_dcpl_417;
  assign for_mux1h_128_nl = MUX1HOT_v_32_4_2((signext_32_30(~ (N_sva[31:2]))), 32'b00000000000000000000000000000001,
      (~ N_sva), 32'b11111111111111111111111111111101, {and_dcpl_409 , and_dcpl_414
      , for_or_36_itm , and_dcpl_419});
  assign nl_acc_4_nl = conv_s2u_33_34({for_mux1h_125_nl , for_mux1h_126_nl , for_mux1h_127_nl
      , for_or_51_nl}) + conv_s2u_33_34({for_mux1h_128_nl , 1'b1});
  assign acc_4_nl = nl_acc_4_nl[33:0];
  assign z_out_4_32_30 = readslicef_34_3_31(acc_4_nl);
  assign for_or_52_nl = and_dcpl_425 | and_dcpl_430 | and_dcpl_434;
  assign for_mux1h_129_nl = MUX1HOT_v_27_4_2(i_sva_26_0, (~ (while_for_k_1_sva[31:5])),
      (while_for_k_1_sva[31:5]), ({i_sva_31_27 , (i_sva_26_0[26:5])}), {for_or_52_nl
      , and_dcpl_437 , and_dcpl_439 , for_or_2_ssc});
  assign for_mux1h_130_nl = MUX1HOT_v_5_6_2(5'b11110, 5'b01100, 5'b11100, (~ (while_for_k_1_sva[4:0])),
      (while_for_k_1_sva[4:0]), (i_sva_26_0[4:0]), {and_dcpl_425 , and_dcpl_430 ,
      and_dcpl_434 , and_dcpl_437 , and_dcpl_439 , for_or_2_ssc});
  assign for_or_53_nl = (~(and_dcpl_437 | and_dcpl_439 | and_dcpl_442)) | and_dcpl_425
      | and_dcpl_430 | and_dcpl_434 | and_dcpl_446;
  assign for_or_54_nl = and_dcpl_437 | and_dcpl_439 | and_dcpl_442;
  assign for_for_mux_25_nl = MUX_v_32_2_2((~ N_sva), 32'b00000000000000000000000000000001,
      for_or_54_nl);
  assign nl_acc_5_nl = conv_s2u_33_34({for_mux1h_129_nl , for_mux1h_130_nl , for_or_53_nl})
      + conv_s2u_33_34({for_for_mux_25_nl , 1'b1});
  assign acc_5_nl = nl_acc_5_nl[33:0];
  assign z_out_5 = readslicef_34_33_1(acc_5_nl);
  assign for_for_mux_26_nl = MUX_v_26_2_2((signext_26_22(i_sva_26_0[26:5])), (i_sva_26_0[25:0]),
      for_or_39_itm);
  assign and_715_nl = nor_359_cse & and_dcpl_118 & and_dcpl_421;
  assign for_mux1h_131_nl = MUX1HOT_v_5_4_2((i_sva_26_0[4:0]), 5'b00100, 5'b11001,
      5'b11010, {and_715_nl , and_dcpl_457 , and_dcpl_460 , and_dcpl_463});
  assign for_for_mux_27_nl = MUX_v_32_2_2((signext_32_27(~ (N_sva[31:5]))), (~ N_sva),
      for_or_39_itm);
  assign nl_acc_6_nl = conv_s2u_33_34({(i_sva_26_0[26]) , for_for_mux_26_nl , for_mux1h_131_nl
      , 1'b1}) + conv_s2u_33_34({for_for_mux_27_nl , 1'b1});
  assign acc_6_nl = nl_acc_6_nl[33:0];
  assign z_out_6_32_27 = readslicef_34_6_28(acc_6_nl);
  assign for_mux1h_132_nl = MUX1HOT_v_3_3_2(3'b010, 3'b101, 3'b110, {and_dcpl_469
      , and_dcpl_475 , and_dcpl_478});
  assign for_for_or_9_nl = (~ and_dcpl_478) | and_dcpl_469 | and_dcpl_475;
  assign nl_acc_7_nl = conv_s2u_33_34({i_sva_26_0 , for_mux1h_132_nl , 1'b0 , for_for_or_9_nl
      , 1'b1}) + conv_s2u_33_34({(~ N_sva) , 1'b1});
  assign acc_7_nl = nl_acc_7_nl[33:0];
  assign z_out_7_32 = readslicef_34_1_33(acc_7_nl);
  assign for_for_or_10_nl = (~(and_dcpl_490 | and_dcpl_494)) | and_dcpl_484;
  assign for_for_or_11_nl = (~(and_dcpl_484 | and_dcpl_490)) | and_dcpl_494;
  assign nl_acc_8_nl = conv_s2u_33_34({i_sva_26_0 , 2'b10 , for_for_or_10_nl , 1'b0
      , for_for_or_11_nl , 1'b1}) + conv_s2u_33_34({(~ N_sva) , 1'b1});
  assign acc_8_nl = nl_acc_8_nl[33:0];
  assign z_out_8_32 = readslicef_34_1_33(acc_8_nl);
  assign for_for_mux_28_nl = MUX_v_26_2_2((signext_26_25(i_sva_26_0[26:2])), (i_sva_26_0[25:0]),
      for_or_43_itm);
  assign and_716_nl = and_dcpl_499 & and_dcpl_496;
  assign for_mux1h_133_nl = MUX1HOT_v_2_3_2((i_sva_26_0[1:0]), 2'b10, 2'b01, {and_716_nl
      , and_dcpl_504 , and_dcpl_506});
  assign for_for_mux_29_nl = MUX_v_32_2_2((signext_32_30(~ (N_sva[31:2]))), (~ N_sva),
      for_or_43_itm);
  assign nl_acc_9_nl = conv_s2u_33_34({(i_sva_26_0[26]) , for_for_mux_28_nl , for_mux1h_133_nl
      , 4'b0101}) + conv_s2u_33_34({for_for_mux_29_nl , 1'b1});
  assign acc_9_nl = nl_acc_9_nl[33:0];
  assign z_out_9_32_30 = readslicef_34_3_31(acc_9_nl);
  assign for_for_mux_30_nl = MUX_v_26_2_2((signext_26_25(i_sva_26_0[26:2])), (i_sva_26_0[25:0]),
      for_or_45_itm);
  assign for_mux_11_nl = MUX_v_2_2_2((i_sva_26_0[1:0]), 2'b01, and_dcpl_519);
  assign for_for_or_12_nl = MUX_v_2_2_2(for_mux_11_nl, 2'b11, and_dcpl_515);
  assign for_for_or_13_nl = (~ and_dcpl_519) | and_dcpl_512 | and_dcpl_515;
  assign for_for_or_14_nl = (~(and_dcpl_515 | and_dcpl_519)) | and_dcpl_512;
  assign for_for_or_15_nl = (~(and_dcpl_512 | and_dcpl_519)) | and_dcpl_515;
  assign for_for_mux_31_nl = MUX_v_32_2_2((signext_32_30(~ (N_sva[31:2]))), (~ N_sva),
      for_or_45_itm);
  assign nl_acc_10_nl = conv_s2u_33_34({(i_sva_26_0[26]) , for_for_mux_30_nl , for_for_or_12_nl
      , for_for_or_13_nl , for_for_or_14_nl , for_for_or_15_nl , 1'b1}) + conv_s2u_33_34({for_for_mux_31_nl
      , 1'b1});
  assign acc_10_nl = nl_acc_10_nl[33:0];
  assign z_out_10_32_30 = readslicef_34_3_31(acc_10_nl);
  assign for_for_or_16_nl = (~((and_dcpl_524 & and_dcpl_356 & (~ (fsm_output[0])))
      | and_dcpl_527)) | (nor_359_cse & (fsm_output[3]) & (~ (fsm_output[1])) & and_dcpl_526);
  assign for_for_mux_32_nl = MUX_v_2_2_2(2'b01, 2'b10, and_dcpl_527);
  assign nl_acc_11_nl = conv_s2u_33_34({i_sva_26_0 , 1'b0 , for_for_or_16_nl , 1'b1
      , for_for_mux_32_nl , 1'b1}) + conv_s2u_33_34({(~ N_sva) , 1'b1});
  assign acc_11_nl = nl_acc_11_nl[33:0];
  assign z_out_11_32 = readslicef_34_1_33(acc_11_nl);
  assign while_for_while_aelse_while_for_while_aelse_mux_1_nl = MUX_s_1_2_2((while_for_k_1_sva[8]),
      (while_for_k_1_sva[7]), and_dcpl_542);
  assign while_for_while_aelse_or_9_nl = and_dcpl_544 | and_dcpl_548;
  assign while_for_while_aelse_mux1h_11_nl = MUX1HOT_s_1_3_2((while_for_k_1_sva[7]),
      (while_for_k_1_sva[6]), (while_for_k_1_sva[8]), {and_dcpl_536 , and_dcpl_542
      , while_for_while_aelse_or_9_nl});
  assign while_for_while_aelse_mux1h_12_nl = MUX1HOT_v_6_4_2((while_for_k_1_sva[6:1]),
      (while_for_k_1_sva[5:0]), (while_for_k_1_sva[7:2]), (while_for_k_1_sva[8:3]),
      {and_dcpl_536 , and_dcpl_542 , and_dcpl_544 , and_dcpl_548});
  assign while_for_while_aelse_while_for_while_aelse_or_1_nl = and_dcpl_536 | and_dcpl_544
      | and_dcpl_548;
  assign nl_z_out_12 = ({(while_for_k_1_sva[8]) , while_for_while_aelse_while_for_while_aelse_mux_1_nl
      , while_for_while_aelse_mux1h_11_nl , while_for_while_aelse_mux1h_12_nl}) +
      conv_s2u_3_9({1'b1 , while_for_while_aelse_while_for_while_aelse_or_1_nl ,
      1'b1});
  assign z_out_12 = nl_z_out_12[8:0];
  assign nand_72_nl = ~((fsm_output==7'b1101010));
  assign nl_z_out_13 = (while_for_k_1_sva[8:0]) + conv_s2u_4_9({2'b10 , nand_72_nl
      , 1'b1});
  assign z_out_13 = nl_z_out_13[8:0];
  assign for_for_mux_33_nl = MUX_v_26_2_2((i_sva_26_0[25:0]), (i_sva_26_0[26:1]),
      and_dcpl_567);
  assign for_for_or_17_nl = ((i_sva_26_0[0]) & (~(and_dcpl_524 & and_dcpl_404 & (~
      (fsm_output[0]))))) | (nor_359_cse & and_dcpl_190 & (fsm_output[2]) & (~ (fsm_output[6]))
      & (~ (fsm_output[0])));
  assign for_for_mux_34_nl = MUX_v_29_2_2((~ (N_sva[31:3])), (signext_29_28(~ (N_sva[31:4]))),
      and_dcpl_567);
  assign nl_acc_14_nl = conv_s2u_30_31({(i_sva_26_0[26]) , for_for_mux_33_nl , for_for_or_17_nl
      , 2'b01}) + conv_s2u_30_31({for_for_mux_34_nl , 1'b1});
  assign acc_14_nl = nl_acc_14_nl[30:0];
  assign z_out_14_29_28 = readslicef_31_2_29(acc_14_nl);

  function automatic  MUX1HOT_s_1_3_2;
    input  input_2;
    input  input_1;
    input  input_0;
    input [2:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    MUX1HOT_s_1_3_2 = result;
  end
  endfunction


  function automatic  MUX1HOT_s_1_4_2;
    input  input_3;
    input  input_2;
    input  input_1;
    input  input_0;
    input [3:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    result = result | (input_3 & sel[3]);
    MUX1HOT_s_1_4_2 = result;
  end
  endfunction


  function automatic  MUX1HOT_s_1_5_2;
    input  input_4;
    input  input_3;
    input  input_2;
    input  input_1;
    input  input_0;
    input [4:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    result = result | (input_3 & sel[3]);
    result = result | (input_4 & sel[4]);
    MUX1HOT_s_1_5_2 = result;
  end
  endfunction


  function automatic  MUX1HOT_s_1_6_2;
    input  input_5;
    input  input_4;
    input  input_3;
    input  input_2;
    input  input_1;
    input  input_0;
    input [5:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    result = result | (input_3 & sel[3]);
    result = result | (input_4 & sel[4]);
    result = result | (input_5 & sel[5]);
    MUX1HOT_s_1_6_2 = result;
  end
  endfunction


  function automatic  MUX1HOT_s_1_8_2;
    input  input_7;
    input  input_6;
    input  input_5;
    input  input_4;
    input  input_3;
    input  input_2;
    input  input_1;
    input  input_0;
    input [7:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    result = result | (input_3 & sel[3]);
    result = result | (input_4 & sel[4]);
    result = result | (input_5 & sel[5]);
    result = result | (input_6 & sel[6]);
    result = result | (input_7 & sel[7]);
    MUX1HOT_s_1_8_2 = result;
  end
  endfunction


  function automatic [16:0] MUX1HOT_v_17_3_2;
    input [16:0] input_2;
    input [16:0] input_1;
    input [16:0] input_0;
    input [2:0] sel;
    reg [16:0] result;
  begin
    result = input_0 & {17{sel[0]}};
    result = result | (input_1 & {17{sel[1]}});
    result = result | (input_2 & {17{sel[2]}});
    MUX1HOT_v_17_3_2 = result;
  end
  endfunction


  function automatic [25:0] MUX1HOT_v_26_4_2;
    input [25:0] input_3;
    input [25:0] input_2;
    input [25:0] input_1;
    input [25:0] input_0;
    input [3:0] sel;
    reg [25:0] result;
  begin
    result = input_0 & {26{sel[0]}};
    result = result | (input_1 & {26{sel[1]}});
    result = result | (input_2 & {26{sel[2]}});
    result = result | (input_3 & {26{sel[3]}});
    MUX1HOT_v_26_4_2 = result;
  end
  endfunction


  function automatic [26:0] MUX1HOT_v_27_4_2;
    input [26:0] input_3;
    input [26:0] input_2;
    input [26:0] input_1;
    input [26:0] input_0;
    input [3:0] sel;
    reg [26:0] result;
  begin
    result = input_0 & {27{sel[0]}};
    result = result | (input_1 & {27{sel[1]}});
    result = result | (input_2 & {27{sel[2]}});
    result = result | (input_3 & {27{sel[3]}});
    MUX1HOT_v_27_4_2 = result;
  end
  endfunction


  function automatic [1:0] MUX1HOT_v_2_3_2;
    input [1:0] input_2;
    input [1:0] input_1;
    input [1:0] input_0;
    input [2:0] sel;
    reg [1:0] result;
  begin
    result = input_0 & {2{sel[0]}};
    result = result | (input_1 & {2{sel[1]}});
    result = result | (input_2 & {2{sel[2]}});
    MUX1HOT_v_2_3_2 = result;
  end
  endfunction


  function automatic [1:0] MUX1HOT_v_2_4_2;
    input [1:0] input_3;
    input [1:0] input_2;
    input [1:0] input_1;
    input [1:0] input_0;
    input [3:0] sel;
    reg [1:0] result;
  begin
    result = input_0 & {2{sel[0]}};
    result = result | (input_1 & {2{sel[1]}});
    result = result | (input_2 & {2{sel[2]}});
    result = result | (input_3 & {2{sel[3]}});
    MUX1HOT_v_2_4_2 = result;
  end
  endfunction


  function automatic [31:0] MUX1HOT_v_32_3_2;
    input [31:0] input_2;
    input [31:0] input_1;
    input [31:0] input_0;
    input [2:0] sel;
    reg [31:0] result;
  begin
    result = input_0 & {32{sel[0]}};
    result = result | (input_1 & {32{sel[1]}});
    result = result | (input_2 & {32{sel[2]}});
    MUX1HOT_v_32_3_2 = result;
  end
  endfunction


  function automatic [31:0] MUX1HOT_v_32_4_2;
    input [31:0] input_3;
    input [31:0] input_2;
    input [31:0] input_1;
    input [31:0] input_0;
    input [3:0] sel;
    reg [31:0] result;
  begin
    result = input_0 & {32{sel[0]}};
    result = result | (input_1 & {32{sel[1]}});
    result = result | (input_2 & {32{sel[2]}});
    result = result | (input_3 & {32{sel[3]}});
    MUX1HOT_v_32_4_2 = result;
  end
  endfunction


  function automatic [31:0] MUX1HOT_v_32_5_2;
    input [31:0] input_4;
    input [31:0] input_3;
    input [31:0] input_2;
    input [31:0] input_1;
    input [31:0] input_0;
    input [4:0] sel;
    reg [31:0] result;
  begin
    result = input_0 & {32{sel[0]}};
    result = result | (input_1 & {32{sel[1]}});
    result = result | (input_2 & {32{sel[2]}});
    result = result | (input_3 & {32{sel[3]}});
    result = result | (input_4 & {32{sel[4]}});
    MUX1HOT_v_32_5_2 = result;
  end
  endfunction


  function automatic [2:0] MUX1HOT_v_3_3_2;
    input [2:0] input_2;
    input [2:0] input_1;
    input [2:0] input_0;
    input [2:0] sel;
    reg [2:0] result;
  begin
    result = input_0 & {3{sel[0]}};
    result = result | (input_1 & {3{sel[1]}});
    result = result | (input_2 & {3{sel[2]}});
    MUX1HOT_v_3_3_2 = result;
  end
  endfunction


  function automatic [4:0] MUX1HOT_v_5_30_2;
    input [4:0] input_29;
    input [4:0] input_28;
    input [4:0] input_27;
    input [4:0] input_26;
    input [4:0] input_25;
    input [4:0] input_24;
    input [4:0] input_23;
    input [4:0] input_22;
    input [4:0] input_21;
    input [4:0] input_20;
    input [4:0] input_19;
    input [4:0] input_18;
    input [4:0] input_17;
    input [4:0] input_16;
    input [4:0] input_15;
    input [4:0] input_14;
    input [4:0] input_13;
    input [4:0] input_12;
    input [4:0] input_11;
    input [4:0] input_10;
    input [4:0] input_9;
    input [4:0] input_8;
    input [4:0] input_7;
    input [4:0] input_6;
    input [4:0] input_5;
    input [4:0] input_4;
    input [4:0] input_3;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [29:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | (input_1 & {5{sel[1]}});
    result = result | (input_2 & {5{sel[2]}});
    result = result | (input_3 & {5{sel[3]}});
    result = result | (input_4 & {5{sel[4]}});
    result = result | (input_5 & {5{sel[5]}});
    result = result | (input_6 & {5{sel[6]}});
    result = result | (input_7 & {5{sel[7]}});
    result = result | (input_8 & {5{sel[8]}});
    result = result | (input_9 & {5{sel[9]}});
    result = result | (input_10 & {5{sel[10]}});
    result = result | (input_11 & {5{sel[11]}});
    result = result | (input_12 & {5{sel[12]}});
    result = result | (input_13 & {5{sel[13]}});
    result = result | (input_14 & {5{sel[14]}});
    result = result | (input_15 & {5{sel[15]}});
    result = result | (input_16 & {5{sel[16]}});
    result = result | (input_17 & {5{sel[17]}});
    result = result | (input_18 & {5{sel[18]}});
    result = result | (input_19 & {5{sel[19]}});
    result = result | (input_20 & {5{sel[20]}});
    result = result | (input_21 & {5{sel[21]}});
    result = result | (input_22 & {5{sel[22]}});
    result = result | (input_23 & {5{sel[23]}});
    result = result | (input_24 & {5{sel[24]}});
    result = result | (input_25 & {5{sel[25]}});
    result = result | (input_26 & {5{sel[26]}});
    result = result | (input_27 & {5{sel[27]}});
    result = result | (input_28 & {5{sel[28]}});
    result = result | (input_29 & {5{sel[29]}});
    MUX1HOT_v_5_30_2 = result;
  end
  endfunction


  function automatic [4:0] MUX1HOT_v_5_4_2;
    input [4:0] input_3;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [3:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | (input_1 & {5{sel[1]}});
    result = result | (input_2 & {5{sel[2]}});
    result = result | (input_3 & {5{sel[3]}});
    MUX1HOT_v_5_4_2 = result;
  end
  endfunction


  function automatic [4:0] MUX1HOT_v_5_5_2;
    input [4:0] input_4;
    input [4:0] input_3;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [4:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | (input_1 & {5{sel[1]}});
    result = result | (input_2 & {5{sel[2]}});
    result = result | (input_3 & {5{sel[3]}});
    result = result | (input_4 & {5{sel[4]}});
    MUX1HOT_v_5_5_2 = result;
  end
  endfunction


  function automatic [4:0] MUX1HOT_v_5_6_2;
    input [4:0] input_5;
    input [4:0] input_4;
    input [4:0] input_3;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [5:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | (input_1 & {5{sel[1]}});
    result = result | (input_2 & {5{sel[2]}});
    result = result | (input_3 & {5{sel[3]}});
    result = result | (input_4 & {5{sel[4]}});
    result = result | (input_5 & {5{sel[5]}});
    MUX1HOT_v_5_6_2 = result;
  end
  endfunction


  function automatic [5:0] MUX1HOT_v_6_3_2;
    input [5:0] input_2;
    input [5:0] input_1;
    input [5:0] input_0;
    input [2:0] sel;
    reg [5:0] result;
  begin
    result = input_0 & {6{sel[0]}};
    result = result | (input_1 & {6{sel[1]}});
    result = result | (input_2 & {6{sel[2]}});
    MUX1HOT_v_6_3_2 = result;
  end
  endfunction


  function automatic [5:0] MUX1HOT_v_6_4_2;
    input [5:0] input_3;
    input [5:0] input_2;
    input [5:0] input_1;
    input [5:0] input_0;
    input [3:0] sel;
    reg [5:0] result;
  begin
    result = input_0 & {6{sel[0]}};
    result = result | (input_1 & {6{sel[1]}});
    result = result | (input_2 & {6{sel[2]}});
    result = result | (input_3 & {6{sel[3]}});
    MUX1HOT_v_6_4_2 = result;
  end
  endfunction


  function automatic [8:0] MUX1HOT_v_9_4_2;
    input [8:0] input_3;
    input [8:0] input_2;
    input [8:0] input_1;
    input [8:0] input_0;
    input [3:0] sel;
    reg [8:0] result;
  begin
    result = input_0 & {9{sel[0]}};
    result = result | (input_1 & {9{sel[1]}});
    result = result | (input_2 & {9{sel[2]}});
    result = result | (input_3 & {9{sel[3]}});
    MUX1HOT_v_9_4_2 = result;
  end
  endfunction


  function automatic [8:0] MUX1HOT_v_9_7_2;
    input [8:0] input_6;
    input [8:0] input_5;
    input [8:0] input_4;
    input [8:0] input_3;
    input [8:0] input_2;
    input [8:0] input_1;
    input [8:0] input_0;
    input [6:0] sel;
    reg [8:0] result;
  begin
    result = input_0 & {9{sel[0]}};
    result = result | (input_1 & {9{sel[1]}});
    result = result | (input_2 & {9{sel[2]}});
    result = result | (input_3 & {9{sel[3]}});
    result = result | (input_4 & {9{sel[4]}});
    result = result | (input_5 & {9{sel[5]}});
    result = result | (input_6 & {9{sel[6]}});
    MUX1HOT_v_9_7_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [25:0] MUX_v_26_2_2;
    input [25:0] input_0;
    input [25:0] input_1;
    input  sel;
    reg [25:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_26_2_2 = result;
  end
  endfunction


  function automatic [26:0] MUX_v_27_2_2;
    input [26:0] input_0;
    input [26:0] input_1;
    input  sel;
    reg [26:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_27_2_2 = result;
  end
  endfunction


  function automatic [28:0] MUX_v_29_2_2;
    input [28:0] input_0;
    input [28:0] input_1;
    input  sel;
    reg [28:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_29_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [2:0] MUX_v_3_2_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input  sel;
    reg [2:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_3_2_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input  sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [6:0] MUX_v_7_2_2;
    input [6:0] input_0;
    input [6:0] input_1;
    input  sel;
    reg [6:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_7_2_2 = result;
  end
  endfunction


  function automatic [8:0] MUX_v_9_2_2;
    input [8:0] input_0;
    input [8:0] input_1;
    input  sel;
    reg [8:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_9_2_2 = result;
  end
  endfunction


  function automatic [1:0] readslicef_31_2_29;
    input [30:0] vector;
    reg [30:0] tmp;
  begin
    tmp = vector >> 29;
    readslicef_31_2_29 = tmp[1:0];
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_34_1_33;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 33;
    readslicef_34_1_33 = tmp[0:0];
  end
  endfunction


  function automatic [32:0] readslicef_34_33_1;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 1;
    readslicef_34_33_1 = tmp[32:0];
  end
  endfunction


  function automatic [2:0] readslicef_34_3_31;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 31;
    readslicef_34_3_31 = tmp[2:0];
  end
  endfunction


  function automatic [5:0] readslicef_34_6_28;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 28;
    readslicef_34_6_28 = tmp[5:0];
  end
  endfunction


  function automatic [16:0] signext_17_1;
    input  vector;
  begin
    signext_17_1= {{16{vector}}, vector};
  end
  endfunction


  function automatic [16:0] signext_17_16;
    input [15:0] vector;
  begin
    signext_17_16= {{1{vector[15]}}, vector};
  end
  endfunction


  function automatic [25:0] signext_26_22;
    input [21:0] vector;
  begin
    signext_26_22= {{4{vector[21]}}, vector};
  end
  endfunction


  function automatic [25:0] signext_26_25;
    input [24:0] vector;
  begin
    signext_26_25= {{1{vector[24]}}, vector};
  end
  endfunction


  function automatic [28:0] signext_29_28;
    input [27:0] vector;
  begin
    signext_29_28= {{1{vector[27]}}, vector};
  end
  endfunction


  function automatic [31:0] signext_32_27;
    input [26:0] vector;
  begin
    signext_32_27= {{5{vector[26]}}, vector};
  end
  endfunction


  function automatic [31:0] signext_32_30;
    input [29:0] vector;
  begin
    signext_32_30= {{2{vector[29]}}, vector};
  end
  endfunction


  function automatic [31:0] signext_32_9;
    input [8:0] vector;
  begin
    signext_32_9= {{23{vector[8]}}, vector};
  end
  endfunction


  function automatic [5:0] signext_6_4;
    input [3:0] vector;
  begin
    signext_6_4= {{2{vector[3]}}, vector};
  end
  endfunction


  function automatic [32:0] conv_s2s_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2s_32_33 = {vector[31], vector};
  end
  endfunction


  function automatic [8:0] conv_s2u_3_9 ;
    input [2:0]  vector ;
  begin
    conv_s2u_3_9 = {{6{vector[2]}}, vector};
  end
  endfunction


  function automatic [8:0] conv_s2u_4_9 ;
    input [3:0]  vector ;
  begin
    conv_s2u_4_9 = {{5{vector[3]}}, vector};
  end
  endfunction


  function automatic [8:0] conv_s2u_5_9 ;
    input [4:0]  vector ;
  begin
    conv_s2u_5_9 = {{4{vector[4]}}, vector};
  end
  endfunction


  function automatic [30:0] conv_s2u_30_31 ;
    input [29:0]  vector ;
  begin
    conv_s2u_30_31 = {vector[29], vector};
  end
  endfunction


  function automatic [32:0] conv_s2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_s2u_32_33 = {vector[31], vector};
  end
  endfunction


  function automatic [33:0] conv_s2u_33_34 ;
    input [32:0]  vector ;
  begin
    conv_s2u_33_34 = {vector[32], vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    lz77simple
// ------------------------------------------------------------------


module lz77simple (
  clk, rst, dest_rsc_dat, dest_rsc_vld, dest_rsc_rdy, src_rsc_dat, src_rsc_vld, src_rsc_rdy
);
  input clk;
  input rst;
  output [31:0] dest_rsc_dat;
  output dest_rsc_vld;
  input dest_rsc_rdy;
  input [31:0] src_rsc_dat;
  input src_rsc_vld;
  output src_rsc_rdy;


  // Interconnect Declarations
  wire [31:0] srcbuf_rsci_data_in_d;
  wire [8:0] srcbuf_rsci_addr_rd_d;
  wire [8:0] srcbuf_rsci_addr_wr_d;
  wire srcbuf_rsci_re_d;
  wire srcbuf_rsci_we_d;
  wire [31:0] srcbuf_rsci_data_out_d;
  wire srcbuf_rsci_en_d;
  wire srcbuf_rsc_en;
  wire srcbuf_rsc_we;
  wire [8:0] srcbuf_rsc_addr_wr;
  wire [31:0] srcbuf_rsc_data_in;
  wire [31:0] srcbuf_rsc_data_out;
  wire srcbuf_rsc_re;
  wire [8:0] srcbuf_rsc_addr_rd;


  // Interconnect Declarations for Component Instantiations 
  register_file_be #(.ram_id(32'sd3),
  .words(32'sd512),
  .width(32'sd32),
  .addr_width(32'sd9),
  .a_reset_active(32'sd0),
  .s_reset_active(32'sd1),
  .enable_active(32'sd0),
  .re_active(32'sd0),
  .we_active(32'sd0),
  .num_byte_enables(32'sd1),
  .clock_edge(32'sd1),
  .no_of_REGISTER_FILE_read_port(32'sd1),
  .no_of_REGISTER_FILE_write_port(32'sd1)) srcbuf_rsc_comp (
      .data_in(srcbuf_rsc_data_in),
      .addr_rd(srcbuf_rsc_addr_rd),
      .addr_wr(srcbuf_rsc_addr_wr),
      .re(srcbuf_rsc_re),
      .we(srcbuf_rsc_we),
      .data_out(srcbuf_rsc_data_out),
      .clk(clk),
      .arst(1'b1),
      .srst(rst),
      .en(srcbuf_rsc_en)
    );
  lz77simple_ram_nangate_45nm_register_file_beh_REGISTER_FILE_rwport_en_3_512_32_9_0_1_0_0_0_1_1_1_1_gen
      srcbuf_rsci (
      .en(srcbuf_rsc_en),
      .we(srcbuf_rsc_we),
      .addr_wr(srcbuf_rsc_addr_wr),
      .data_in(srcbuf_rsc_data_in),
      .data_out(srcbuf_rsc_data_out),
      .re(srcbuf_rsc_re),
      .addr_rd(srcbuf_rsc_addr_rd),
      .data_in_d(srcbuf_rsci_data_in_d),
      .addr_rd_d(srcbuf_rsci_addr_rd_d),
      .addr_wr_d(srcbuf_rsci_addr_wr_d),
      .re_d(srcbuf_rsci_re_d),
      .we_d(srcbuf_rsci_we_d),
      .data_out_d(srcbuf_rsci_data_out_d),
      .en_d(srcbuf_rsci_en_d)
    );
  lz77simple_core lz77simple_core_inst (
      .clk(clk),
      .rst(rst),
      .dest_rsc_dat(dest_rsc_dat),
      .dest_rsc_vld(dest_rsc_vld),
      .dest_rsc_rdy(dest_rsc_rdy),
      .src_rsc_dat(src_rsc_dat),
      .src_rsc_vld(src_rsc_vld),
      .src_rsc_rdy(src_rsc_rdy),
      .srcbuf_rsci_data_in_d(srcbuf_rsci_data_in_d),
      .srcbuf_rsci_addr_rd_d(srcbuf_rsci_addr_rd_d),
      .srcbuf_rsci_addr_wr_d(srcbuf_rsci_addr_wr_d),
      .srcbuf_rsci_re_d(srcbuf_rsci_re_d),
      .srcbuf_rsci_we_d(srcbuf_rsci_we_d),
      .srcbuf_rsci_data_out_d(srcbuf_rsci_data_out_d),
      .srcbuf_rsci_en_d(srcbuf_rsci_en_d)
    );
endmodule



