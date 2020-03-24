`include "../define.sv"
`include "../game_brick.sv"
`include "../ball.sv"
`include "../platform.sv"
module DE2_115 (
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

logic	[3:0]							debounce_key;
logic	[`PIXELX_BIT_CNT-1:0] 			platX;
logic	[`PIXELY_BIT_CNT-1:0] 			platY;
logic	[`PLAT_HF_WIDTH_BIT_CNT-1:0] 	plat_size;
logic									plat_ack;
logic									plat_req;
logic	[`PIXELX_BIT_CNT-1:0] 			ballX;
logic	[`PIXELY_BIT_CNT-1:0] 			ballY;
logic	[`BALL_SIZE_BIT_CNT-1:0]		ball_size;
logic	[`BALL_SIZE_BIT_CNT-1:0]		ball_size_reg;
logic	[1:0]							ball_speedX;
logic	[1:0]							ball_speedY;
logic	[`FSPEED_BIT_CNT-1:0]			ball_speedstep;
logic									ball_collision;
logic   [`DIR_BIT_CNT-1:0]      		direc_var;
logic                           		ball_ack;
logic                           		ball_frame_term;
logic                           		ball_req;

//DEBUG
logic	[2:0]							ball_counter;
logic	[3:0]							debug_collision_state;
logic	[2:0]							debug_ball_state;
always_comb begin
	LEDG[0] = debug_ball_state == 0 ? 1 : 0;
	LEDG[1] = debug_ball_state == 1 ? 1 : 0;
	LEDG[2] = debug_ball_state == 2 ? 1 : 0;
end


always_comb begin
	LEDR[1] = debug_collision_state == 1 ?  1 : 0;
	LEDR[2] = debug_collision_state == 2 ?  1 : 0;
	LEDR[3] = debug_collision_state == 3 ?  1 : 0;
	LEDR[4] = debug_collision_state == 4 ?  1 : 0;
	LEDR[5] = debug_collision_state == 5 ?  1 : 0;
	LEDR[6] = debug_collision_state == 6 ?  1 : 0;
	LEDR[7] = debug_collision_state == 7 ?  1 : 0;
	LEDR[8] = debug_collision_state == 8 ?  1 : 0;
	LEDR[9] = debug_collision_state == 9 ?  1 : 0;
end



Debounce deb0(
	.i_in(KEY[0]),
	.i_rst_n(KEY[1]),
	.i_clk(CLOCK_50),
	.o_neg(debounce_key[0])
);




collision col0(
	// Fundamental IO
		.clk(CLOCK_50),
		.rst_n(KEY[1]),

	// CONTROL IO
		.i_game_start(1'b0),
		.i_cal_frame(debounce_key[0]),

	// platform IO
		.i_platX(platX),
		.i_platY(platY),
		.i_plat_size(plat_size), 

		//.o_plat_gadget_effect(0),  
		//.o_plat_receive_gadget(0),

		.i_plat_ack(plat_ack),
		.o_plat_req(plat_req),

	// ball IO
		.i_ballX(ballX),
		.i_ballY(ballY),
		.i_ball_size(ball_size_reg),
		.i_ball_speedX(ball_speedX), // 2 bit 00 == 0, 11 == -1, 01 i_== 1
		.i_ball_speedY(ball_speedY),
		.i_ball_damage(ball_damage),
		.o_ball_collision(ball_collision),
		.o_direc_var(direc_var),
		.i_ball_ack(ball_ack),
		.i_ball_frame_term(ball_frame_term),
		.o_ball_req(ball_req),


	// gadget IO
		// gadgetX, gadgetY: Fine Position
		.i_gadgetX(10'd320),
		.i_gadgetY(9'd240),
		.i_gadget_speedX(2'd0), // 2 bit 00 == 0, 11 == -1, 01 i_== 1
		.i_gadget_speedY(2'd0),
		//.o_gadget_direc_var(),
		//.o_gadget_initX(), //pixelX
		//.o_gadget_initY(), //pixelY
		//.o_gadget_gen(),
		.i_gadget_type(0),
		//.o_gadget_eaten(),
		.i_gadget_ack(0),
		.i_gadget_frame_term(1),
		//.o_gadget_req(),

	// score IO
		//.o_score_ball_brick_collision(),
	// Life IO              
		//.o_minus_life(),
	// Brick IO    
		//.o_br_ballX(),
		//.o_br_ballY(),
		//.o_br_ball_size(),
		//.o_br_speedX(), // 2 bit 00 == 0, 11 == -1, 01 == 1
		//.o_br_speedY(),
		//.o_br_damage(),
		.i_br_gadget_gen(0),
		.i_ball_brick_collision(0),
		.i_direc_var(0),


		.i_brick_ack(1),
		//.o_brick_req()

		//DEBUG
		.o_state(debug_collision_state),
		.o_ball_load_flag(LEDG[5])
);



ball ball0(
	//Fundemental IO
		.clk(CLOCK_50),
		.rst_n(KEY[1]),

	//Control IO
		.i_game_start(0),   // when losing one life or start of the game 
		.i_cal_frame(debounce_key[0]),    
		.i_shoot_ball(0), 


	// Collision IO
		// ballX, ballY: PIXEL(Display)
		.o_ballX(ballX),
		.o_ballY(ballY),
		// ball_size: PIXEL(Display) size
		.o_ball_size(ball_size_reg),
		// speedX, speedY: PIXEL(Display) location variation for the ball at next frame with no collision
		.o_ball_speedX(ball_speedX), // 2 bit 00 == 0, 11 == -1, 01 i_== 1
		.o_ball_speedY(ball_speedY),
		// damage: damage for brick
		//.o_damage(),
		// ball_collision: cue for speed variation on ball, only one cycle pulse
		.i_ball_collision(ball_collision),   
		.i_direc_var(direc_var),        //!!!!! Value 18,19 are used to judgement the collision between platform under grab situation

		//ball_req: request for the next frame ballX, ballY, ball_size, speedX, speedY
		//          posedge by calculating next frame, negedge by ball_ack = 1
		//ball_ack: one cycle pulse occurs when 1.ball_req = 1, 2. valid of data and ready to send
		//ball_frame_term: cue for finish calculation on this frame
		.o_ball_ack(ball_ack),
		.o_ball_frame_term(ball_frame_term),
		.i_ball_req(ball_req),

	// Platform IO
		
		.i_grab(0),
		.i_platX(platX),
		.i_platY(platY),
		.i_ball_speedstep(ball_speedstep),
		.i_ball_size(ball_size),
	
	//DEBUG!!
		.o_state(debug_ball_state),
		.o_counter(ball_counter),
		.o_handshake(LEDG[4])
);

platform plat0(
	//Fundemental IO
		.clk(CLOCK_50),
		.rst_n(KEY[1]),

	//Control IO
		.i_game_start(0),   // when losing one life or start of the game 
		.i_cal_frame(debounce_key[0]), 
		.i_gamepad_X(10'd50),

	// Collision IO
		.o_platX(platX),
		.o_platY(platY),
		.o_plat_size(plat_size), 
		.i_plat_gadget_effect(0),  
		.i_plat_receive_gadget(0),
		.o_plat_ack(plat_ack),
		.i_plat_req(plat_req),

	// Ball IO
		//.o_grab(),
		//.o_2ball_platX(),
		//.o_2ball_platY(),
		.o_ball_speedstep(ball_speedstep),
		.o_ball_size(ball_size)
);

SevenHexDecoder seven_dec0(
	.i_hex(ballX[3:0]),
	.o_seven_ten(HEX1),
	.o_seven_one(HEX0)
);

SevenHexDecoder seven_dec1(
	.i_hex(ballX[7:4]),
	.o_seven_ten(HEX3),
	.o_seven_one(HEX2)
);

SevenHexDecoder seven_dec2(
	.i_hex({2'd0,ballX[9:8]}),
	.o_seven_ten(HEX5),
	.o_seven_one(HEX4)
);

SevenHexDecoder seven_dec3(
	.i_hex(ball_counter),
	.o_seven_ten(HEX7),
	.o_seven_one(HEX6)
);

endmodule