module game_controller (
    // fimcdemental IO
    input   i_clk,
    input   i_rst_n,

    output  o_shoot_signal,


    output  o_col_ball_gad_game_start,
    // collision IO
    input   i_collision_life_loss,

    // Gamepad IO
    input   i_gamepad_shootball,  // downword motion


    // platform IO
    output  o_platform_initial_grab,


    // ball IO
    // output  o_ball_shoot,

    // gadget IO
    //output  o_gadget_reset,
    //output  o_gadget_cal_frame,


    // brick IO
    input   i_brick_next_stage,//???????????




    // life IO
    input   [2:0] i_life_count,



    // Disp Ctrl IO
    output  o_disp_ctrl_endgame,
    output  o_disp_ctrl_startgame

    
);
localparam  START   = 3'd0;
localparam  GAME    = 3'd1;
localparam  END     = 3'd2;

// output Reg
    logic   col_ball_gad_game_start ,n_col_ball_gad_game_start;
    //logic   platform_initial_grab   ,n_platform_initial_grab;
    // logic   brick_player_dead   ,n_brick_player_dead;
    //logic   disp_ctrl_endgame   ,n_disp_ctrl_endgame;
    //logic   disp_ctrl_startgame ,n_disp_ctrl_startgame;
    assign o_shoot_signal = START ? 1'b0 : i_gamepad_shootball;
    assign o_platform_initial_grab = 1'b0;
    assign o_disp_ctrl_startgame = (n_state == GAME && state == START) ? 1'b1 : 1'b0;
    assign o_disp_ctrl_endgame = (n_state == END && state == GAME) ? 1'b1 : 1'b0;
// Internal Reg
    logic   [2:0]   state, n_state;

// FSM IO
    always_comb begin
        case (state)
            START:  n_state = i_gamepad_shootball ? GAME : state;
            GAME:   n_state = i_life_count == 3'd0 ? END : state;
            END:    n_state = state;
        endcase
    end

    always_comb begin
        n_col_ball_gad_game_start = col_ball_gad_game_start;
        case(state)
            START: if(i_gamepad_shootball) n_col_ball_gad_game_start = 1'b1;
            GAME: 
                if(i_collision_life_loss || i_brick_next_stage) n_col_ball_gad_game_start = 1'b1;
            END: n_col_ball_gad_game_start = 0;
        endcase
        if(col_ball_gad_game_start) n_col_ball_gad_game_start = 0;
    end

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= START;
            col_ball_gad_game_start <= 0;
        end
        else begin
            state <= n_state;
            col_ball_gad_game_start <= n_col_ball_gad_game_start;
        end
    end 
        



    
endmodule