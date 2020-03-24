module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
	logic keydown;
	logic [9:0] X,Y;
	logic [9:0] ballX;
	logic [8:0] ballY;
	logic [7:0] de_key;

	//logic CLK_25;
	Debounce deb0(
		.i_in(KEY[0]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(keydown)
	);
	/*PLL pll0(.inclk0(CLOCK_50),
		.c0(CLK_25)
	);*/


	VGA v0(
		.CLK_50(CLOCK_50),
		.RST_N(KEY[1]),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_CLK(VGA_CLK),
		.X(X),
		.Y(Y)
	);
	
	color_mapper map( 
				.DrawX(X),
				.DrawY(Y),
				.ballX(ballX),
				.ballY(ballY),
				.VGA_R(VGA_R),
				.VGA_G(VGA_G),
				.VGA_B(VGA_B),
				.LEDG(LEDG)
                );

	ball_pos pos(
		.clk(VGA_CLK),
		.rst_n(KEY[1]),
		.key(de_key),
		.ballX(ballX),
		.ballY(ballY)
	);

Debounce key0(
		.i_in(key[0]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[0])
	);
Debounce key1(
		.i_in(key[1]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[1])
	);
Debounce key2(
		.i_in(key[2]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[2])
	);
Debounce key3(
		.i_in(key[3]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[3])
	);
Debounce key4(
		.i_in(key[4]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[4])
	);
Debounce key5(
		.i_in(key[5]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[5])
	);
Debounce key6(
		.i_in(key[6]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[6])
	);
Debounce key7(
		.i_in(key[7]),
		.i_rst(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[7])
	);

wire [7:0] key;

assign PS2_CLK = 1'bz;
assign PS2_DAT = 1'bz;

keyboardRecv keyboard(
	.i_clk(PS2_CLK),			// PS2 clock (slower than 50MHz)
	.i_rst(KEY[0]),
	.i_quick_clk(CLOCK_50),
	.i_data(PS2_DAT),			// PS2 data
	.o_key(key)
);
/*
SevenHexDecoder_Hex3 hex3_dec(
	.i_hex(key),
	.o_seven_hun(HEX2),
	.o_seven_ten(HEX1),
	.o_seven_one(HEX0)
);*/


`ifdef DUT_LAB1
	initial begin
		$fsdbDumpfile("LAB1.fsdb");
		$fsdbDumpvars(0, DE2_115, "+mda");
	end
`endif
endmodule
