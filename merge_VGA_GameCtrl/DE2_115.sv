`include "../define.sv"
`define VGA_640x480p60


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
	//output [6:0] HEX7,
	//output LCD_BLON,
	//inout [7:0] LCD_DATA,
	//output LCD_EN,
	//output LCD_ON,
	//output LCD_RS,
	//output LCD_RW,
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
	//inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO,
	input		    [11:0]		D5M_D,
input		          		D5M_FVAL,
input		          		D5M_LVAL,
input		          		D5M_PIXLCLK,
output		          		D5M_RESET_N,
output		          		D5M_SCLK,
inout		          		D5M_SDATA,
input		          		D5M_STROBE,
output		          		D5M_TRIGGER,
output		          		D5M_XCLKIN
);

logic	[3:0]							debounce_key;
logic									cal_frame;

logic	[9:0]							gamepadX;
logic									gamepad_shoot;
logic									gamepad_shoot_frame_debounce;
logic									gamepad_use_gadget;

logic	[`PIXELX_BIT_CNT-1:0] 			platX;
logic	[`PIXELY_BIT_CNT-1:0] 			platY;
logic	[`PLAT_HF_WIDTH_BIT_CNT-1:0] 	plat_size;
logic									plat_ack;
logic									plat_req;
logic	[`GADGET_BIT_CNT-1:0]			plat_gadget_effect;
logic									plat_receive_gadget;

logic	[`PIXELX_BIT_CNT-1:0] 			ballX;
logic	[`PIXELY_BIT_CNT-1:0] 			ballY;
logic	[`BALL_SIZE_BIT_CNT-1:0]		ball_size;
logic	[`BALL_SIZE_BIT_CNT-1:0]		ball_size_reg;
logic	[1:0]							ball_speedX;
logic	[1:0]							ball_speedY;
logic	[`STEP_BIT_CNT-1:0]				ball_speedstep;
logic									ball_collision;
logic   [`DIR_BIT_CNT-1:0]      		direc_var;
logic                           		ball_ack;
logic                           		ball_frame_term;
logic                           		ball_req;

logic									grab;


logic	[`PIXELX_BIT_CNT-1:0]   		br_ballX;
logic	[`PIXELY_BIT_CNT-1:0]   		br_ballY;
logic	[`BALL_SIZE_BIT_CNT-1:0]		br_ball_size;
logic	[1:0]                   		br_speedX; // 2 bit 00 == 0, 11 == -1, 01 == 1
logic	[1:0]                   		br_speedY;
//logic	[1:0]                   		br_damage;
//logic                               	br_gadget_gen;
logic                               	ball_brick_collision;
logic       [`DIR_BIT_CNT-1:0]      	ball_br_direc_var;
logic                               	brick_ack;
logic									brick_req;

logic									restart_the_ball_gad_col;

assign	restart_the_ball_gad_col = minus_life || next_stage;


//DEBUG
logic	[2:0]							ball_counter;
logic	[3:0]							debug_collision_state;
logic	[2:0]							debug_ball_state;
logic									debug_shoot;
logic									debug_shoot_debounce_next_frame;
// temp control signal
logic 	[7:0]	key;
logic 	[7:0] 	de_key;
// end of temp control signal

//Hsin's camera variables
//logic [9:0] X_center_r, Y_center_r;
//logic 		ready_r, is_light, down_detected;
//=======================================================
//  REG/WIRE declarations
//=======================================================
wire	[15:0]	Read_DATA1;
wire	[15:0]	Read_DATA2;

wire	[11:0]	mCCD_DATA;
wire			mCCD_DVAL;
wire			mCCD_DVAL_d;
wire	[15:0]	X_Cont;
wire	[15:0]	Y_Cont;
wire	[9:0]	X_ADDR;
wire	[31:0]	Frame_Cont;
wire			DLY_RST_0;
wire			DLY_RST_1;
wire			DLY_RST_2;
wire			DLY_RST_3;
wire			DLY_RST_4;
wire			Read;
reg		[11:0]	rCCD_DATA;
reg				rCCD_LVAL;
reg				rCCD_FVAL;
wire	[12:0] X_center_r, Y_center_r;
wire 			ready_r, is_light, down_detected;
wire	[11:0]	sCCD_R;
wire	[11:0]	sCCD_G;
wire	[11:0]	sCCD_B;
wire			sCCD_DVAL;

wire			sdram_ctrl_clk;
logic	[9:0]	oVGA_R;   				//	VGA Red[9:0]
logic	[9:0]	oVGA_G;	 				//	VGA Green[9:0]
logic	[9:0]	oVGA_B;   				//	VGA Blue[9:0]
logic 	[`PIXELX_BIT_CNT-1:0]	gadgetX;
logic 	[`PIXELY_BIT_CNT-1:0]	gadgetY;
logic	[1:0]	gadget_speedX, gadget_speedY;
logic	gadget_gen, gadget_eaten, gadget_req, gadget_ack, gadget_frame_term;
logic 	[`GADGET_BIT_CNT-1:0]	gadget_type, gadget_type_by_brick;
logic 	minus_life;
logic	[2:0] life_count;
logic	[9:0] score;
logic 	score_ball_brick_collision;

//wire  [9:0] X_center_r, Y_center_r;
//wire 			is_light, ready_r;

//power on start
wire             auto_start;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;
assign  VGA_CTRL_CLK = ~VGA_CLK;

//assign	LEDR		=	SW;
//assign	LEDG		=	Y_Cont;
assign	UART_TXD = UART_RXD;
logic VGA_CLK_HSIN;









//Yi-Chien's VGA variables
logic keydown;
logic [9:0] X,Y;
logic [3:0] is_brick;
logic [3:0] is_gadget;
logic [`BALL_SIZE_BIT_CNT-1:0] ball_size_temp; //debug use
logic [7:0] plat_size_temp;//debug
logic [2:0] stage_num;

//Yi-Chien's Modules//
always_comb
begin
	if(SW[3]) ball_size_temp = `BALL_SIZE_BIT_CNT'd3;
	else if(SW[5]) ball_size_temp = `BALL_SIZE_BIT_CNT'd5;
	else ball_size_temp = `BALL_SIZE_BIT_CNT'd7;

	if(SW[4]) plat_size_temp = 8'd128;
	else if(SW[6]) plat_size_temp = 8'd64;
	else plat_size_temp = 8'd32;
end



VGA v0( //VGA controller
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
				.clk(CLOCK_50),
				.rst_n(KEY[1]),
				.DrawX(X),
				.DrawY(Y),
				.ballX(ballX),
				.ballY(ballY),
				.is_fire(ball_damage),
				.GadgetX(gadgetX),
				.GadgetY(gadgetY),
				//.ballSize(ball_size_reg),
				.i_ball_size(ball_size),
				.platX(platX),
				.platY(platY),
				.platform_size(plat_size),
				.is_brick(is_brick),
				.is_gadget(gadget_type),
				.i_stage_numb(stage_num),
				.life_count(life_count),
				.VGA_R(VGA_R),
				.VGA_G(VGA_G),
				.VGA_B(VGA_B)
                );

logic	[2:0]	sw_15_17;
assign sw_15_17 = SW[17:15];
					 
brick brick(
	.clk(CLOCK_50),
	.rst_n(KEY[1]),
	.SW(SW),
	.DrawX(X),
	.DrawY(Y),
	.i_br_ballX(br_ballX),
	.i_br_ballY(br_ballY),
	.i_br_ball_size(ball_size),
	.i_br_speedX(br_speedX), // 2 bit 00 == 0, 11 == -1, 01 == ()1
	.i_br_speedY(br_speedY),
	.i_br_damage(ball_damage),
	.i_down(down_detected),
	.o_br_gadget_gen(gadget_gen),
	.o_ball_brick_collision(ball_brick_collision),
	.o_direc_var(ball_br_direc_var),

	.o_brick_ack(brick_ack),
	.is_brick(is_brick), //0 is no brick, else number = brick typ()e
	.i_brick_req(brick_req),
	.brick_game_start(0),
	.brick_next_stage(next_stage),
	.life_count(life_count),
   	.brick_death(0), //if player is dead
	.o_gadget_type(gadget_type_by_brick),
	.o_stage_num(stage_num),
	.LEDR(LEDR[17:15])
);
/*
gadget gadget(
	.clk(CLOCK_50),
	.rst_n(KEY[1]),
	.DrawX(X),
	.DrawY(Y),
	.i_br_ballX(br_ballX),
	.i_br_ballY(br_ballY),
	.i_br_ball_size(br_ball_size),
	.o_br_gadget_gen(1'b0),

	.o_gadget_ack(),
	.is_gadget(is_gadget), //0 is no brick, else number = brick typ()e
	.i_gadget_req()
);*/
/* used for debug, controlled by keyboard
ball_pos pos(
		.clk(VGA_CLK),
		.rst_n(KEY[1]),
		.key(de_key),
		.ballX(ballX),
		.ballY(ballY)
	);
*/

//Yi-Chien's module end



// TEMP control
keyboardRecv keyboard(
	.i_clk(PS2_CLK),			// PS2 clock (slower than 50MHz)
	.i_rst(KEY[1]),
	.i_quick_clk(CLOCK_50),
	.i_data(PS2_DAT),			// PS2 data
	.o_key(key)
);

Debounce key0(
		.i_in(key[0]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[0])
	);
Debounce key1(
		.i_in(key[1]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[1])
	);
Debounce key2(
		.i_in(key[2]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[2])
	);
Debounce key3(
		.i_in(key[3]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[3])
	);
Debounce key4(
		.i_in(key[4]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[4])
	);
Debounce key5(
		.i_in(key[5]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[5])
	);
Debounce key6(
		.i_in(key[6]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[6])
	);
Debounce key7(
		.i_in(key[7]),
		.i_rst_n(KEY[1]),
		.i_clk(CLOCK_50),
		.o_neg(de_key[7])
	);
keyboard_gamepadX keyboard_pad(
	.i_clk(CLOCK_50),
    .i_rst_n(KEY[1]),
    .i_key(de_key),
    .o_platX(gamepadX),
    .o_shoot(gamepad_shoot),
    .o_use_gadget(gamepad_use_gadget),
	.o_debug_shoot(debug_shoot)
);


// End of temp control


Debounce deb0(
	.i_in(KEY[0]),
	.i_rst_n(KEY[1]),
	.i_clk(CLOCK_50),
	.o_neg(debounce_key[0])
);


Debounce deb2(
	.i_in(KEY[2]),
	.i_rst_n(KEY[1]),
	.i_clk(CLOCK_50),
	.o_neg(debounce_key[2])
);
Debounce deb3(
	.i_in(KEY[3]),
	.i_rst_n(KEY[1]),
	.i_clk(CLOCK_50),
	.o_neg(debounce_key[3])
);

debug_60_hz_trigger debug_60hz(
	.i_clk(CLOCK_50),
    .i_rst_n(KEY[1]),
    .i_play_pause(debounce_key[2]),
    .i_frame_by_frame(debounce_key[3]),
    .o_cal_frame_signal(cal_frame)
);

frame_debounce_shoot shoot_debounce(
	.i_clk(CLOCK_50),
    .i_rst_n(KEY[1]),

    // make the shoot signal last for one frame in the upcoming frame
    .i_shoot_signal(down_detected),
    .i_cal_frame(cal_frame),
    .o_shoot_signal_frame_debounce(gamepad_shoot_frame_debounce),

	//DEBUG
	.o_shoot_next_frame_high(debug_shoot_debounce_next_frame)
);
assign LEDR[0] = !KEY[0];
assign LEDR[1] = debug_shoot_debounce_next_frame;
assign LEDR[2] = gamepad_shoot_frame_debounce;

collision col0(
	// Fundamental IO
		.clk(CLOCK_50),
		.rst_n(KEY[1]),

	// CONTROL IO
		.i_game_start(restart_the_ball_gad_col),
		.i_cal_frame(cal_frame),

	// platform IO
		.i_platX(platX),
		.i_platY(platY),
		.i_plat_size(plat_size), 

		.o_plat_gadget_effect(plat_gadget_effect),  
		.o_plat_receive_gadget(plat_receive_gadget),

		.i_plat_ack(plat_ack),
		.o_plat_req(plat_req),

	// ball IO
		.i_ballX(ballX),
		.i_ballY(ballY),
		.i_ball_size(ball_size_reg),
		.i_ball_speedX(ball_speedX), // 2 bit 00 == 0, 11 == -1, 01 i_== 1
		.i_ball_speedY(ball_speedY),
		//.i_ball_damage(ball_damage),
		.o_ball_collision(ball_collision),
		.o_direc_var(direc_var),
		.i_ball_ack(ball_ack),
		.i_ball_frame_term(ball_frame_term),
		.o_ball_req(ball_req),


	// gadget IO
		// gadgetX, gadgetY: Fine Position
		.i_gadgetX(gadgetX),
		.i_gadgetY(gadgetY),
		.i_gadget_speedX(gadget_speedX), // 2 bit 00 == 0, 11 == -1, 01 i_== 1
		.i_gadget_speedY(gadget_speedY),
		//.o_gadget_direc_var(),
		//.o_gadget_initX(), //pixelX
		//.o_gadget_initY(), //pixelY
		.o_gadget_gen(),
		.i_gadget_type(gadget_type),
		.o_gadget_eaten(gadget_eaten),
		.i_gadget_ack(gadget_ack),
		.i_gadget_frame_term(gadget_frame_term),
		.o_gadget_req(gadget_req),

	// score IO
		//.o_score_ball_brick_collision(),
	// Life IO              
		.o_minus_life(minus_life),
	// Brick IO    
		.o_br_ballX(br_ballX),
		.o_br_ballY(br_ballY),
		.o_br_ball_size(br_ball_size),
		.o_br_speedX(br_speedX), // 2 bit 00 == 0, 11 == -1, 01 == 1
		.o_br_speedY(br_speedY),
		//.o_br_damage(),
		.i_br_gadget_gen(0),
		.i_ball_brick_collision(ball_brick_collision),
		.i_direc_var(ball_br_direc_var),


		.i_brick_ack(brick_ack),
		.o_brick_req(brick_req),

		//DEBUG
		.o_state(debug_collision_state),
		.o_ball_load_flag()
);



ball ball0(
	//Fundemental IO
		.clk(CLOCK_50),
		.rst_n(KEY[1]),

	//Control IO
		.i_game_start(restart_the_ball_gad_col),   // when losing one life or start of the game 
		.i_cal_frame(cal_frame),    
		.i_shoot_ball(gamepad_shoot_frame_debounce), 
		.i_start_grab(1'b0),


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
		
		.i_grab(grab),
		.i_platX(platX),
		.i_platY(platY),
		.i_ball_speedstep(ball_speedstep),
		.i_ball_size(ball_size),
	
	//DEBUG!!
		.o_state(debug_ball_state),
		.o_counter(ball_counter),
		.o_handshake()
);

platform plat0(
	//Fundemental IO
		.clk(CLOCK_50),
		.rst_n(KEY[1]),

	//Control IO
		.i_game_start(restart_the_ball_gad_col),   // when losing one life or start of the game 
		.i_cal_frame(cal_frame), 
		.i_gamepad_X(X_center_r),

	// Collision IO
		.o_platX(platX),//debug use, drop platX temporary
		.o_platY(platY),
		.o_plat_size(plat_size), 
		.i_plat_gadget_effect(plat_gadget_effect),  
		.i_plat_receive_gadget(plat_receive_gadget),
		.o_plat_ack(plat_ack),
		.i_plat_req(plat_req),

	// Ball IO
		.o_grab(grab),
		//.o_2ball_platX(),
		//.o_2ball_platY(),
		.o_ball_speedstep(ball_speedstep),
		.o_ball_size(ball_size),

	// Brick IO
		.o_ball_damage(ball_damage),
		.SW(SW)
);
assign LEDG[0] = plat_size == 8'd32;
assign LEDG[1] = ball_size == 6'd5;
assign LEDG[2] = ball_speedstep == 3'd3;
assign LEDG[3] = ball_damage;


//Hsin's module
//assign  VGA_R = oVGA_R[9:2];
//assign  VGA_G = oVGA_G[9:2];
//assign  VGA_B = oVGA_B[9:2];

VGA_Position		u1	(	//	Host Side
							.oRequest(Read),
							.iRed(Read_DATA2[9:0]),
							.iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
							.iBlue(Read_DATA1[9:0]),
							//	VGA Side
							//.oVGA_R(oVGA_R),
							//.oVGA_G(oVGA_G),
							//.oVGA_B(oVGA_B),
							//.oVGA_H_SYNC(VGA_HS),
							//.oVGA_V_SYNC(VGA_VS),
							//.oVGA_SYNC(VGA_SYNC_N),
							//.oVGA_BLANK(VGA_BLANK_N),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST_2),
							.iZOOM_MODE_SW(SW[16]),
							.X_center_r(X_center_r),
							.Y_center_r(Y_center_r),
							.ready_r(ready_r),
							.is_light(is_light)
							//.tempOutput(tempOutput)
						);

downAction			downAction1(
							.clk(VGA_CTRL_CLK),
							.rst(DLY_RST_2),
							.ready(ready_r),
							.X_center(X_center_r),
							.Y_center(Y_center_r),
							.down_detected_r(down_detected)
							);

							
gadget gadget1(
			.clk(CLOCK_50),
			.rst_n(DLY_RST_2),
			.i_gadget_initX(ballX),
			.i_gadget_initY(ballY),
			.o_gadgetX(gadgetX),
			.o_gadgetY(gadgetY),
			.o_gadget_speedX(gadget_speedX),
			.o_gadget_speedY(gadget_speedY),
			.i_gadget_gen(gadget_gen),
			.i_gadget_type_by_brick(gadget_type_by_brick),
			.o_gadget_type(gadget_type),
			.i_gadget_eaten(gadget_eaten),
			.o_gadget_ack(gadget_ack),
			.o_gadget_frame_term(gadget_frame_term),
			.i_gadget_req(gadget_req),
			.i_cal_frame(cal_frame),
			.i_game_start(restart_the_ball_gad_col)
	); 

life life1(
			.clk(CLOCK_50),
			.rst_n(KEY[1]),
			.i_minus_life(minus_life),
			.o_life_count(life_count)
	);

score score1(
			.clk(CLOCK_50),
			.rst_n(KEY[1]),
			.i_score_ball_brick_collision(score_ball_brick_collision),
			.o_score(score)
	);
							
always@(posedge D5M_PIXLCLK)
begin
	rCCD_DATA	<=	D5M_D;
	rCCD_LVAL	<=	D5M_LVAL;
	rCCD_FVAL	<=	D5M_FVAL;
end

//auto start when power on
assign auto_start = ((KEY[1])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
//Reset module
Reset_Delay			u2	(	.iCLK(CLOCK2_50),
							.iRST(KEY[1]),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						);
//D5M image capture
CCD_Capture			u3	(	.oDATA(mCCD_DATA),
							.oDVAL(mCCD_DVAL),
							.oX_Cont(X_Cont),
							.oY_Cont(Y_Cont),
							.oFrame_Cont(Frame_Cont),
							.iDATA(rCCD_DATA),
							.iFVAL(rCCD_FVAL),
							.iLVAL(rCCD_LVAL),
							.iSTART((1'b0)|auto_start),
							.iEND(1'b0),
							.iCLK(~D5M_PIXLCLK),
							.iRST(DLY_RST_2)
						);
//D5M raw date convert to RGB data
`ifdef VGA_640x480p60
RAW2RGB				u4	(	.iCLK(D5M_PIXLCLK),
							.iRST(DLY_RST_1),
							.iDATA(mCCD_DATA),
							.iDVAL(mCCD_DVAL),
							.oRed(sCCD_R),
							.oGreen(sCCD_G),
							.oBlue(sCCD_B),
							.oDVAL(sCCD_DVAL),
							.iX_Cont(X_Cont),
							.iY_Cont(Y_Cont)
						);
`else
RAW2RGB				u4	(	.iCLK(D5M_PIXLCLK),
							.iRST_n(DLY_RST_1),
							.iData(mCCD_DATA),
							.iDval(mCCD_DVAL),
							.oRed(sCCD_R),
							.oGreen(sCCD_G),
							.oBlue(sCCD_B),
							.oDval(sCCD_DVAL),
							.iZoom(SW[16]),
							.iX_Cont(X_Cont),
							.iY_Cont(Y_Cont)
						);
`endif
//Frame count display
/*
SEG7_LUT_8 			u5	(	.oSEG0(HEX0),.oSEG1(HEX1),
							.oSEG2(HEX2),.oSEG3(HEX3),
							.oSEG4(HEX4),.iDIG(Frame_Cont[31:0])
						);*/

sdram_pll 			u6	(
							.inclk0(CLOCK2_50),
							.c0(sdram_ctrl_clk),
							.c1(DRAM_CLK),
							.c2(D5M_XCLKIN), //25M
/*`ifdef VGA_640x480p60
							.c3(VGA_CLK_HSIN)     //25M 
`else
						    .c4(VGA_CLK_HSIN)     //40M 	
`endif*/
						);

//SDRam Read and Write as Frame Buffer
Sdram_Control	u7	(	//	HOST Side						
						    .RESET_N(KEY[1]),
							.CLK(sdram_ctrl_clk),

							//	FIFO Write Side 1
							.WR1_DATA({1'b0,sCCD_G[11:7],sCCD_B[11:2]}),
							.WR1(sCCD_DVAL),
							.WR1_ADDR(0),
`ifdef VGA_640x480p60
						    .WR1_MAX_ADDR(640*480/2),
						    .WR1_LENGTH(8'h50),
`else
							.WR1_MAX_ADDR(800*600/2),
							.WR1_LENGTH(8'h80),
`endif							
							.WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(D5M_PIXLCLK),

							//	FIFO Write Side 2
							.WR2_DATA({1'b0,sCCD_G[6:2],sCCD_R[11:2]}),
							.WR2(sCCD_DVAL),
							.WR2_ADDR(23'h100000),
`ifdef VGA_640x480p60
						    .WR2_MAX_ADDR(23'h100000+640*480/2),
							.WR2_LENGTH(8'h50),
`else							
							.WR2_MAX_ADDR(23'h100000+800*600/2),
							.WR2_LENGTH(8'h80),
`endif	
							.WR2_LOAD(!DLY_RST_0),
							.WR2_CLK(D5M_PIXLCLK),

							//	FIFO Read Side 1
						    .RD1_DATA(Read_DATA1),
				        	.RD1(Read),
				        	.RD1_ADDR(0),
`ifdef VGA_640x480p60
						    .RD1_MAX_ADDR(640*480/2),
							.RD1_LENGTH(8'h50),
`else
							.RD1_MAX_ADDR(800*600/2),
							.RD1_LENGTH(8'h80),
`endif
							.RD1_LOAD(!DLY_RST_0),
							.RD1_CLK(~VGA_CTRL_CLK),
							
							//	FIFO Read Side 2
						    .RD2_DATA(Read_DATA2),
							.RD2(Read),
							.RD2_ADDR(23'h100000),
`ifdef VGA_640x480p60
						    .RD2_MAX_ADDR(23'h100000+640*480/2),
							.RD2_LENGTH(8'h50),
`else
							.RD2_MAX_ADDR(23'h100000+800*600/2),
							.RD2_LENGTH(8'h80),
`endif
				        	.RD2_LOAD(!DLY_RST_0),
							.RD2_CLK(~VGA_CTRL_CLK),
							
							//	SDRAM Side
						    .SA(DRAM_ADDR),
							.BA(DRAM_BA),
							.CS_N(DRAM_CS_N),
							.CKE(DRAM_CKE),
							.RAS_N(DRAM_RAS_N),
							.CAS_N(DRAM_CAS_N),
							.WE_N(DRAM_WE_N),
							.DQ(DRAM_DQ),
							.DQM(DRAM_DQM)
						);
//D5M I2C control
I2C_CCD_Config 		u8	(	//	Host Side
							.iCLK(CLOCK2_50),
							.iRST_N(DLY_RST_2),
							.iEXPOSURE_ADJ(1'b1),
							.iEXPOSURE_DEC_p(SW[0]),
							.iZOOM_MODE_SW(SW[16]),
							//	I2C Side
							.I2C_SCLK(D5M_SCLK),
							.I2C_SDAT(D5M_SDATA)
						);
/*SevenHexDecoder seven_dec0(
	.i_hex(platX[3:0]),
	.o_seven_ten(HEX1),
	.o_seven_one(HEX0)
);

SevenHexDecoder seven_dec1(
	.i_hex(platX[7:4]),
	.o_seven_ten(HEX3),
	.o_seven_one(HEX2)
);

SevenHexDecoder seven_dec2(
	.i_hex({2'd0,platX[9:8]}),
	.o_seven_ten(HEX5),
	.o_seven_one(HEX4)
);

SevenHexDecoder seven_dec3(
	.i_hex({3'd0,debug_shoot}),
	.o_seven_ten(HEX7),
	.o_seven_one(HEX6)
);*/

SevenHexDecoder Hexxx(
	   .i_addr(X_center_r), // SRAM address
		.is_light(is_light),
		.down_detected(down_detected),
		.clk(VGA_CTRL_CLK),
		.rst(DLY_RST_2),
		.o_seven_hun(HEX6),
		.o_seven_ten(HEX5),
		.o_seven_one(HEX4),
		//.gadget_type(gadget_type),
		//.gadget_req(gadget_req),
		//.o_seven_type(HEX3),
		//.o_seven_req(HEX2)
	);

endmodule