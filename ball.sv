`include "define.sv"
module ball(
//Fundemental IO
    input                       clk,
    input                       rst_n,

//Control IO
    input                       i_game_start,   // when losing one life or start of the game 
    input                       i_cal_frame,    
    input                       i_shoot_ball, 


// Collision IO
    // ballX, ballY: PIXEL(Display)
    output     [`PIXELX_BIT_CNT-1:0]    o_ballX,
    output     [`PIXELY_BIT_CNT-1:0]    o_ballY,
    // ball_size: PIXEL(Display) size
    output     [`BALL_SIZE_BIT_CNT-1:0] o_ball_size,
    // speedX, speedY: PIXEL(Display) location variation for the ball at next frame with no collision
    output     [1:0]                    o_ball_speedX, // 2 bit 00 == 0, 11 == -1, 01 i_== 1
    output     [1:0]                    o_ball_speedY,
    // damage: damage for brick
    output     [`DAM_BIT_CNT-1:0]       o_damage,
    // ball_collision: cue for speed variation on ball, only one cycle pulse
    input                               i_ball_collision,   
    input      [`DIR_BIT_CNT-1:0]       i_direc_var,        //!!!!! Value 18,19 are used to judgement the collision between platform under grab situation

    //ball_req: request for the next frame ballX, ballY, ball_size, speedX, speedY
    //          posedge by calculating next frame, negedge by ball_ack = 1
    //ball_ack: one cycle pulse occurs when 1.ball_req = 1, 2. valid of data and ready to send
    //ball_frame_term: cue for finish calculation on this frame
    output                              o_ball_ack,
    output                              o_ball_frame_term,
    input                               i_ball_req,

// Platform IO
    
    input                               i_grab,
    input   [`PIXELX_BIT_CNT-1:0]       i_platX,
    input   [`PIXELY_BIT_CNT-1:0]       i_platY,
    input   [`STEP_BIT_CNT-1:0]         i_ball_speedstep,
    input   [`BALL_SIZE_BIT_CNT-1:0]    i_ball_size,

    //  DEBUG
    output      [2:0]                   o_state,
    output      [2:0]                   o_counter,
    output                              o_handshake
);

    localparam STANDBY          = 3'd0;
    localparam WAIT_FOR_REQ     = 3'd1;
    localparam CAL_FOR_REQ      = 3'd2;
    localparam FRAME_TERM       = 3'd3;

// Internal Reg
    logic   [`FPOSX_BIT_CNT-1:0]    ball_fposX, n_ball_fposX;
    logic   [`FPOSY_BIT_CNT-1:0]    ball_fposY, n_ball_fposY;
    logic   [`FSPEED_BIT_CNT-1:0]   fspeedX,    n_fspeedX;
    logic   [`FSPEED_BIT_CNT-1:0]   fspeedY,    n_fspeedY;
    logic   [`PIXELX_BIT_CNT-1:0]   plat_relativeX,  n_plat_relativeX;


    logic                           grabbed,    n_grabbed;
    //logic   [2:0]                   step_cnt;                       // determined by speed
    logic   [2:0]                   counter,    n_counter;          /// ✓
    logic   [2:0]                   state,      n_state;            /// ✓
    assign o_counter        = counter;
    assign o_state          = state;

// Collision IO Reg
    //logic   [`PIXELX_BIT_CNT-1:0]       ballX, n_ballX;   // == front 10 bits of ball_fposX
    //logic   [`PIXELY_BIT_CNT-1:0]       ballY, n_ballY;   // == front 9 bits of ball_fposY
    //logic   [`BALL_SIZE_BIT_CNT-1:0]    ball_size;        // == i_ball_size
    logic   [1:0]                       ball_speedX, n_ball_speedX;
    logic   [1:0]                       ball_speedY, n_ball_speedY;
    logic                               ball_ack, n_ball_ack;
    logic                               ball_frame_term, n_ball_frame_term;
    assign o_ballX          = ball_fposX[`FPOSX_BIT_CNT-1:3];
    assign o_ballY          = ball_fposY[`FPOSY_BIT_CNT-1:3];
    assign o_ball_size      = i_ball_size;
    assign o_ball_speedX    = ball_speedX;
    assign o_ball_speedY    = ball_speedY;
    assign o_ball_ack       = ball_ack;
    assign o_ball_frame_term= ball_frame_term;

// flag
    logic   handshake;
    assign handshake = i_ball_req && o_ball_ack;
    assign o_handshake = handshake;


// Look up table

    logic   [`FSPEED_BIT_CNT-1:0]   lp_fspeedX;
    logic   [`FSPEED_BIT_CNT-1:0]   lp_fspeedY;
    direction_look_up lp(.direction_var(i_direc_var),.fspeedX(lp_fspeedX),.fspeedY(lp_fspeedY));

// FSM
    always_comb begin
        n_state = state;
        case (state)
            STANDBY:        n_state = i_ball_req ? CAL_FOR_REQ : state;
            WAIT_FOR_REQ:   n_state = i_ball_req ? CAL_FOR_REQ : state;
            CAL_FOR_REQ:    n_state = handshake ? (counter == 3'd1 ? FRAME_TERM : WAIT_FOR_REQ) : state;
            FRAME_TERM:     n_state = i_cal_frame ? STANDBY : state;
        endcase
    end


// counter reg
    always_comb begin
        n_counter = counter;
        case(state)
            STANDBY:        n_counter = i_ball_speedstep;
            WAIT_FOR_REQ:   n_counter = counter;
            CAL_FOR_REQ:    n_counter = handshake ? counter - 1 : counter;
            FRAME_TERM:     n_counter = i_cal_frame ? i_ball_speedstep : counter;
        endcase
    end
// ball_frame_term reg
    always_comb begin
        n_ball_frame_term = 0;
        if(state == FRAME_TERM) begin
            if(i_ball_req == 1 && ball_frame_term == 0)
                n_ball_frame_term = 1;
        end
    end



// next timing logic
    logic [`FPOSX_BIT_CNT-1:0]  n_n_ball_fposX;
    logic [`FPOSY_BIT_CNT-1:0]  n_n_ball_fposY;
    assign n_n_ball_fposX = n_ball_fposX + {{(`FPOSX_BIT_CNT-1){fspeedX[3]}},fspeedX};
    assign n_n_ball_fposY = n_ball_fposY + {{(`FPOSY_BIT_CNT-1){fspeedY[3]}},fspeedY};

// ball_fposX/ball_fposY/ball_speedX/ball_speedY/ball_ack reg
    always_comb begin
        n_ball_fposX = ball_fposX;
        n_ball_fposY = ball_fposY;
        n_ball_speedX = ball_speedX;
        n_ball_speedY = ball_speedY;
        n_ball_ack    = 0;
        case (state)
            CAL_FOR_REQ: begin
                if(!ball_ack) begin
                    if(grabbed) begin
                        n_ball_fposX = {i_platX,3'd0} + {plat_relativeX,3'd0};
                        n_ball_fposY = {{i_platY - i_ball_size - 1}, 3'd0};
                        n_ball_speedX = 0;
                        n_ball_speedY = 0;
                        n_ball_ack = 1;
                    end
                    else begin
                        n_ball_fposX = ball_fposX + {{(`FPOSX_BIT_CNT-1){fspeedX[3]}},fspeedX};
                        n_ball_fposY = ball_fposY + {{(`FPOSY_BIT_CNT-1){fspeedY[3]}},fspeedY};
                        n_ball_speedX = n_n_ball_fposX[3] != n_ball_fposX[3] ? (fspeedX[3] ? 2'b11 : 2'b01 ) : 2'b00;
                        n_ball_speedY = n_n_ball_fposY[3] != n_ball_fposY[3] ? (fspeedY[3] ? 2'b11 : 2'b01 ) : 2'b00;
                        n_ball_ack = 1;
                    end
                end
                else begin
                    n_ball_ack = 0;
                end
            end
        endcase

    end

// fspeedX fspeedY
// affect by i_grab i_shoot_ball state collision
    always_comb begin
        n_fspeedX = fspeedX;
        n_fspeedY = fspeedY;
        n_grabbed = grabbed;
        n_plat_relativeX = plat_relativeX;
        if(i_ball_collision) begin
            if (i_direc_var == 6'd18) n_fspeedX = ~(fspeedX) + 1;
            else if (i_direc_var == 6'd19) n_fspeedY = ~(fspeedY) + 1;
            else begin
                if(i_grab) begin
                    n_fspeedX = 0;
                    n_fspeedY = 0;
                    n_grabbed = 1;
                end
                else begin
                    n_fspeedX = lp_fspeedX;
                    n_fspeedY = lp_fspeedY;
                end
                if(i_grab && !grabbed) 
                    n_plat_relativeX = ball_fposX[`FPOSX_BIT_CNT-1:3] - i_platX;
            end
        end
        if( state == CAL_FOR_REQ  &&  grabbed && i_shoot_ball) begin
            n_fspeedX = lp_fspeedX;
            n_fspeedY = lp_fspeedY;
            n_grabbed = 0;
        end

    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ball_speedX     <= 0;
            ball_speedY     <= 0;
            ball_ack        <= 0;
            ball_frame_term <= 0;
            ball_fposX      <= {10'd320,3'd0};
            ball_fposY      <= {9'd400,3'd0};
            fspeedX         <= 4'd1;
            fspeedY         <= 4'd5;
            grabbed         <= 0;
            counter         <= 3;          /// ✓
            state           <= STANDBY;            /// ✓
            plat_relativeX  <= 0;
        end
        else begin
            ball_speedX     <= n_ball_speedX;
            ball_speedY     <= n_ball_speedY;
            ball_ack        <= n_ball_ack;
            ball_frame_term <= n_ball_frame_term;
            ball_fposX      <= n_ball_fposX;
            ball_fposY      <= n_ball_fposY;
            fspeedX         <= n_fspeedX;
            fspeedY         <= n_fspeedY;
            grabbed         <= n_grabbed;
            counter         <= n_counter;          /// ✓
            state           <= n_state;            /// ✓
            plat_relativeX  <= n_plat_relativeX;
        end
    end



endmodule




module direction_look_up(
    input   [`DIR_BIT_CNT-1:0]      direction_var,
    output logic [`FSPEED_BIT_CNT-1:0]   fspeedX,   
    output logic [`FSPEED_BIT_CNT-1:0]   fspeedY
);
    always_comb begin
        case (direction_var)
            6'd1: begin
                fspeedX = -4'd6;
                fspeedY = -4'd1;
            end
            6'd2: begin
                fspeedX = -4'd6;
                fspeedY = -4'd2;
            end
            6'd3: begin
                fspeedX = -4'd6;
                fspeedY = -4'd3;
            end
            6'd4: begin
                fspeedX = -4'd5;
                fspeedY = -4'd4;
            end
            6'd5: begin
                fspeedX = -4'd4;
                fspeedY = -4'd5;
            end
            6'd6: begin
                fspeedX = -4'd3;
                fspeedY = -4'd6;
            end
            6'd7: begin
                fspeedX = -4'd2;
                fspeedY = -4'd6;
            end
            6'd8: begin
                fspeedX = -4'd1;
                fspeedY = -4'd7;
            end
            6'd9: begin
                fspeedX = 4'd1;
                fspeedY = -4'd7;
            end
            6'd10: begin
                fspeedX = 4'd2;
                fspeedY = -4'd7;
            end
            6'd11: begin
                fspeedX = 4'd3;
                fspeedY = -4'd6;
            end
            6'd12: begin
                fspeedX = 4'd4;
                fspeedY = -4'd5;
            end
            6'd13: begin
                fspeedX = 4'd5;
                fspeedY = -4'd4;
            end
            6'd14: begin
                fspeedX = 4'd6;
                fspeedY = -4'd3;
            end
            6'd15: begin
                fspeedX = 4'd6;
                fspeedY = -4'd2;
            end
            6'd16: begin
                fspeedX = 4'd6;
                fspeedY = -4'd1;
            end
            default: begin
                fspeedX = 4'd0;
                fspeedY = -4'd0;
            end        
        endcase
    end

endmodule