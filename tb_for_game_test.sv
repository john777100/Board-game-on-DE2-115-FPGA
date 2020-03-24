`include "game_brick.sv"
`include "ball.sv"
`include "platform.sv"
`define CLK_PERIOD 10
//`define TERM_CYCLE 5000000
`define WAIT_CYCLE 300
`define FRAME_CNT 30000


module tb_for_game_test;
    logic clk;
    logic rst_n;
    logic cal_frame;
    logic game_start;
    integer cycle_counter;
    // Internal wire
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

    //DEBUG
    logic	[2:0]							debug_ball_counter;
    logic	[3:0]							debug_collision_state;
    logic	[2:0]							debug_ball_state;


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
            .i_game_start(game_start),
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
            .o_gadget_direc_var(),                // without connection
            .o_gadget_initX(), //pixelX               // without connection
            .o_gadget_initY(), //pixelY               // without connection
            .o_gadget_gen(),              // without connection
            .i_gadget_type(1'b0),
            .o_gadget_eaten(),                // without connection
            .i_gadget_ack(1'b0),
            .i_gadget_frame_term(1'b1),
            .o_gadget_req(),              // without connection

        // score IO
            .o_score_ball_brick_collision(),              // without connection
        // Life IO              
            .o_minus_life(),              // without connection
        // Brick IO    
            .o_br_ballX(),                // without connection
            .o_br_ballY(),                // without connection
            .o_br_ball_size(),                // without connection
            .o_br_speedX(), // 2 bit 00 == 0, 11 == -1, 01 == 1               // without connection
            .o_br_speedY(),               // without connection
            .o_br_damage(),               // without connection
            .i_br_gadget_gen(1'b0),
            .i_ball_brick_collision(1'b0),
            .i_direc_var(6'd0),


            .i_brick_ack(1'b1),
            .o_brick_req(),                // without connection

            //DEBUG
            .o_state(debug_collision_state)
    );
    ball ball0(
        //Fundemental IO
            .clk(clk),
            .rst_n(rst_n),

        //Control IO
            .i_game_start(1'b0),   // when losing one life or start of the game 
            .i_cal_frame(cal_frame),    
            .i_shoot_ball(1'b0), 


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
            .o_damage(),              // without connection
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
            
            .i_grab(1'b0),
            .i_platX(platX),
            .i_platY(platY),
            .i_ball_speedstep(ball_speedstep),
            .i_ball_size(ball_size),
        
        //DEBUG!!
            .o_state(debug_ball_state),
            .o_counter(debug_ball_counter)
    );

    platform plat0(
        //Fundemental IO
            .clk(clk),
            .rst_n(rst_n),

        //Control IO
            .i_game_start(1'b0),   // when losing one life or start of the game 
            .i_cal_frame(cal_frame), 
            .i_gamepad_X(10'd50),

        // Collision IO
            .o_platX(platX),
            .o_platY(platY),
            .o_plat_size(plat_size), 
            .i_plat_gadget_effect(4'd0),  
            .i_plat_receive_gadget(1'd0),
            .o_plat_ack(plat_ack),
            .i_plat_req(plat_req),

        // Ball IO
            .o_grab(),                // without connection
            .o_2ball_platX(),             // without connection
            .o_2ball_platY(),             // without connection
            .o_ball_speedstep(ball_speedstep),
            .o_ball_size(ball_size)
    );
    
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
        cycle_counter = 0;
        #(3*`CLK_PERIOD) @(negedge clk) rst_n = 1;
        $display("Reset complete.\n");
        // #(`CLK_PERIOD) @(negedge clk) cal_frame = 1;
        // #(`CLK_PERIOD) @(negedge clk) cal_frame = 0;
        // $display("cal_frame has pulse.");
        repeat(`FRAME_CNT) begin
            #((`WAIT_CYCLE-1)*`CLK_PERIOD);
            @(negedge clk) cal_frame = 1;
            #(`CLK_PERIOD);
            @(negedge clk) cal_frame = 0;

        end
         $finish;
        
    end

        
    
endmodule