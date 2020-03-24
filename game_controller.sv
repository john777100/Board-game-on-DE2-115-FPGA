module game_controller (
    // fimcdemental IO
    input   clk,    
    input   rst_n,

    // general IO

    output  o_cal_frame,
    input i_down_detected,    //ok
    input [2:0] i_life_count,   //ok


    // collision IO
    output  o_collision_game_start, //ok
    //output  o_collision_cal_frame,
    input   i_collision_life_loss,

    // Gamepad IO
    //input   i_gamepad_positionX,
    //input   i_gamepad_shootball,  // downword motion
    //input   i_gamepad_usegadget,  // upward motion


    // platform IO
    output  o_platform_initial_grab,
    //output  o_platform_positionX,


    // ball IO
    output  o_ball_grab,
    output  o_ball_shoot,
    //output  o_ball_cal_frame,

    // gadget IO
    output  o_gadget_reset,
    //output  o_gadget_cal_frame,


    // brick IO
    output  o_brick_game_start, //ok
    input   i_brick_next_stage,//???????????




    // life IO
    output  o_life_game_start,  //ok
    input   i_life_player_dead,


    // score IO
    output  o_score_life_loss,

    // Disp Ctrl IO
    output  o_disp_ctrl_endgame,
    output  o_disp_ctrl_startgame,  //ok
    output  o_disp_ctrl_ack,
    input   i_disp_ctrl_req
    
);
localparam  START   = 3'd0;
localparam  GAME    = 3'd1;
localparam  END     = 3'd2;


// Internal Reg
    logic           shootball_reg, n_shootball_reg;
    logic           usegadget_reg, n_usegadget_reg;
    logic   [2:0]   state, n_state;

// collision IO
    logic   collision_game_start,   n_collision_game_start;



    always_comb begin
        n_shootball_reg =   shootball_reg;
        n_usegadget_reg =   usegadget_reg;
        o_life_game_start = 1'b0;
        o_brick_game_start = 1'b0;
        o_collision_game_start = 1'b0;
        o_disp_ctrl_startgame = 1'b0;

        case(state)
            START: begin
                if(down_detected) begin
                    n_state = GAME;
                    o_life_game_start = 1'b1;
                    o_brick_game_start = 1'b1;
                    o_collision_game_start = 1'b1;
                    o_disp_ctrl_startgame = 1'b1;
                end else begin
                    n_state = state;
                end
            end
            GAME: begin
                if(i_life_count == 3'd0) begin
                    n_state = END;
                end else begin
                    n_state = state;
                end

                if(down_detected) begin
                    o_ball_shoot = 1'b1;
                end else begin
                    o_ball_shoot = 1'b0;
                end

                if(i_life_player_dead) begin
                    o_platform_initial_grab = 1'b1;
                end else begin
                    o_platform_initial_grab = 1'b0;
                end
            end
            END: begin
            end
        endcase // state
        
    end
    
endmodule