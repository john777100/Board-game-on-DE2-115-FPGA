`include "collision.sv"
`include "ball.sv"
`include "platform.sv"
`include "brick.sv"
`include "define.sv"


`define CLK_PERIOD 10
//`define TERM_CYCLE 5000000
`define WAIT_CYCLE 300
`define FRAME_CNT 5000
`define SHOOT_CNT 3000


module tb_for_game_test;
    logic clk;
    logic rst_n;
    logic cal_frame;
    logic game_start;
    logic shoot;
    integer frame_counter;



    logic	[9:0]							gamepadX;
    logic									gamepad_shoot;
    logic									gamepad_use_gadget;

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
    logic	[`STEP_BIT_CNT-1:0]			    ball_speedstep;
    logic									ball_collision;
    logic   [`DIR_BIT_CNT-1:0]      		direc_var;
    logic                           		ball_ack;
    logic                           		ball_frame_term;
    logic                           		ball_req;



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



    //DEBUG
    logic	[2:0]							ball_counter;
    logic	[3:0]							debug_collision_state;
    logic	[2:0]							debug_ball_state;
    logic									debug_shoot;


    // Dump Wave file
    initial begin
        $dumpfile("game_test.fsdb");
        $dumpvars(0,tb_for_game_test);
    end


collision col0(
	// Fundamental IO
		.clk(clk),
		.rst_n(rst_n),

	// CONTROL IO
		.i_game_start(1'b0),
		.i_cal_frame(cal_frame),

	// platform IO
		.i_platX(platX),
		.i_platY(platY),
		.i_plat_size(plat_size), 

		.o_plat_gadget_effect(),  
		.o_plat_receive_gadget(),

		.i_plat_ack(plat_ack),
		.o_plat_req(plat_req),

	// ball IO
		.i_ballX(ballX),
		.i_ballY(ballY),
		.i_ball_size(ball_size_reg),
		.i_ball_speedX(ball_speedX), // 2 bit 00 == 0, 11 == -1, 01 i_== 1
		.i_ball_speedY(ball_speedY),
		.i_ball_damage(3'd0),
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
		.o_gadget_direc_var(),
		.o_gadget_initX(), //pixelX
		.o_gadget_initY(), //pixelY
		.o_gadget_gen(),
		.i_gadget_type(1'b0),
		.o_gadget_eaten(),
		.i_gadget_ack(1'b0),
		.i_gadget_frame_term(1'b1),
		.o_gadget_req(),

	// score IO
		.o_score_ball_brick_collision(),
	// Life IO              
		.o_minus_life(),
	// Brick IO    
		.o_br_ballX(br_ballX),
		.o_br_ballY(br_ballY),
		.o_br_ball_size(br_ball_size),
		.o_br_speedX(br_speedX), // 2 bit 00 == 0, 11 == -1, 01 == 1
		.o_br_speedY(br_speedY),
	    .o_br_damage(),
		.i_br_gadget_gen(1'b0),
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
		.clk(clk),
		.rst_n(rst_n),

	//Control IO
		.i_game_start(1'b0),   // when losing one life or start of the game 
		.i_cal_frame(cal_frame),    
		.i_shoot_ball(shoot), 


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
		.o_damage(),
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
		
		.i_grab(1'b1),
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
		.clk(clk),
		.rst_n(rst_n),

	//Control IO
		.i_game_start(1'b0),   // when losing one life or start of the game 
		.i_cal_frame(cal_frame), 
		.i_gamepad_X(`PIXELX_BIT_CNT'd320),

	// Collision IO
		.o_platX(platX),//debug use, drop platX temporary
		.o_platY(platY),
		.o_plat_size(plat_size), 
		.i_plat_gadget_effect(`GADGET_BIT_CNT'b0),  
		.i_plat_receive_gadget(1'b0),
		.o_plat_ack(plat_ack),
		.i_plat_req(plat_req),

	// Ball IO
		.o_grab(),
		.o_2ball_platX(),
		.o_2ball_platY(),
		.o_ball_speedstep(ball_speedstep),
		.o_ball_size(ball_size)
);

// brick brick(
// 	.clk(clk),
// 	.rst_n(rst_n),
// 	.DrawX(),
// 	.DrawY(),
// 	.i_br_ballX(br_ballX),
// 	.i_br_ballY(br_ballY),
// 	.i_br_ball_size(br_ball_size),
// 	.i_br_speedX(br_speedX), // 2 bit 00 == 0, 11 == -1, 01 == ()1
// 	.i_br_speedY(br_speedY),
// 	.i_br_damage(2'd1),
// 	.o_br_gadget_gen(),
// 	.o_ball_brick_collision(ball_brick_collision),
// 	.o_direc_var(ball_br_direc_var),

// 	.o_brick_ack(brick_ack),
// 	.is_brick(), //0 is no brick, else number = brick typ()e
// 	.i_brick_req(brick_req),
// 	.brick_game_start(1'b0),
// 	.brick_next_stage(),
//    	.brick_death(), //if player is dead
// 	.LEDG()
// );

    assign ball_brick_collision = 0;
    assign ball_br_direc_var = 0;
    assign brick_ack = 1;    

    // clk generation
    always begin
        #(`CLK_PERIOD/2) clk = ~clk;
    end


    // Signal assignment
    initial begin
        clk = 0;
        rst_n = 0;
        cal_frame = 0;
        game_start = 0;
        frame_counter = 0;
        #(3*`CLK_PERIOD) @(negedge clk) rst_n = 1;
        $display("Reset complete.\n");
        // #(`CLK_PERIOD) @(negedge clk) cal_frame = 1;
        // #(`CLK_PERIOD) @(negedge clk) cal_frame = 0;
        // $display("cal_frame has pulse.");
        repeat(`FRAME_CNT) begin
            #((`WAIT_CYCLE-1)*`CLK_PERIOD);
            @(negedge clk) cal_frame = 1;
            if(frame_counter == `SHOOT_CNT)
                shoot = 1;
            else
                shoot = 0;
            frame_counter = frame_counter + 1;
            #(`CLK_PERIOD);
            @(negedge clk) cal_frame = 0;

        end
         $finish;
        
    end
 


        
    
endmodule