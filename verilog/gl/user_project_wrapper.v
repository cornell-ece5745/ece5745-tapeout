module user_project_wrapper (user_clock2,
    vccd1,
    vccd2,
    vdda1,
    vdda2,
    vssa1,
    vssa2,
    vssd1,
    vssd2,
    wb_clk_i,
    wb_rst_i,
    wbs_ack_o,
    wbs_cyc_i,
    wbs_stb_i,
    wbs_we_i,
    analog_io,
    io_in,
    io_oeb,
    io_out,
    la_data_in,
    la_data_out,
    la_oenb,
    user_irq,
    wbs_adr_i,
    wbs_dat_i,
    wbs_dat_o,
    wbs_sel_i);
 input user_clock2;
 input vccd1;
 input vccd2;
 input vdda1;
 input vdda2;
 input vssa1;
 input vssa2;
 input vssd1;
 input vssd2;
 input wb_clk_i;
 input wb_rst_i;
 output wbs_ack_o;
 input wbs_cyc_i;
 input wbs_stb_i;
 input wbs_we_i;
 inout [28:0] analog_io;
 input [37:0] io_in;
 output [37:0] io_oeb;
 output [37:0] io_out;
 input [127:0] la_data_in;
 output [127:0] la_data_out;
 input [127:0] la_oenb;
 output [2:0] user_irq;
 input [31:0] wbs_adr_i;
 input [31:0] wbs_dat_i;
 output [31:0] wbs_dat_o;
 input [3:0] wbs_sel_i;


 grp_15_SPI_TapeOutBlockRTL_32bits_5entries grp_15 (.adapter_parity(io_out[37]),
    .ap_en(io_oeb[37]),
    .clk(io_in[11]),
    .cs_en(io_oeb[8]),
    .loopthrough_sel(io_in[35]),
    .lt_sel_en(io_oeb[35]),
    .minion_parity(io_out[36]),
    .miso_en(io_oeb[33]),
    .mosi_en(io_oeb[34]),
    .mp_en(io_oeb[36]),
    .reset(io_in[10]),
    .sclk_en(io_oeb[9]),
    .spi_min_cs(io_in[8]),
    .spi_min_miso(io_out[33]),
    .spi_min_mosi(io_in[34]),
    .spi_min_sclk(io_in[9]),
    .vccd1(vccd1),
    .vssd1(vssd1));
 grp_16_SPI_TapeOutBlockRTL_32bits_5entries grp_16 (.adapter_parity(io_out[23]),
    .ap_en(io_oeb[23]),
    .clk(io_in[11]),
    .cs_en(io_oeb[22]),
    .loopthrough_sel(io_in[25]),
    .lt_sel_en(io_oeb[25]),
    .minion_parity(io_out[24]),
    .miso_en(io_oeb[20]),
    .mosi_en(io_oeb[19]),
    .mp_en(io_oeb[24]),
    .reset(io_in[10]),
    .sclk_en(io_oeb[21]),
    .spi_min_cs(io_in[22]),
    .spi_min_miso(io_out[20]),
    .spi_min_mosi(io_in[19]),
    .spi_min_sclk(io_in[21]),
    .vccd1(vccd1),
    .vssd1(vssd1));
 grp_17_SPI_TapeOutBlockRTL_32bits_5entries grp_17 (.adapter_parity(io_out[32]),
    .ap_en(io_oeb[32]),
    .clk(io_in[11]),
    .cs_en(io_oeb[31]),
    .loopthrough_sel(io_in[27]),
    .lt_sel_en(io_oeb[27]),
    .minion_parity(io_out[26]),
    .miso_en(io_oeb[29]),
    .mosi_en(io_oeb[28]),
    .mp_en(io_oeb[26]),
    .reset(io_in[10]),
    .sclk_en(io_oeb[30]),
    .spi_min_cs(io_in[31]),
    .spi_min_miso(io_out[29]),
    .spi_min_mosi(io_in[28]),
    .spi_min_sclk(io_in[30]),
    .vccd1(vccd1),
    .vssd1(vssd1));
 grp_99_SPI_TapeOutBlockRTL_32bits_5entries grp_99 (.adapter_parity(io_out[14]),
    .ap_en(io_oeb[14]),
    .clk(io_in[11]),
    .clk_en(io_oeb[11]),
    .cs_en(io_oeb[15]),
    .loopthrough_sel(io_in[12]),
    .lt_sel_en(io_oeb[12]),
    .minion_parity(io_out[13]),
    .miso_en(io_oeb[17]),
    .mosi_en(io_oeb[18]),
    .mp_en(io_oeb[13]),
    .reset(io_in[10]),
    .reset_en(io_oeb[10]),
    .sclk_en(io_oeb[16]),
    .spi_min_cs(io_in[15]),
    .spi_min_miso(io_out[17]),
    .spi_min_mosi(io_in[18]),
    .spi_min_sclk(io_in[16]),
    .vccd1(vccd1),
    .vssd1(vssd1));
endmodule
