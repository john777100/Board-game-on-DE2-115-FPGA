/// 
`include "define.sv"
module collision(
// Fundamental IO
    input                               clk,
    input                               rst_n,

// CONTROL IO
    input                               i_game_start,
    input                               i_cal_frame,

// platform IO
    input       [`PIXELX_BIT_CNT-1:0]    i_platX,
    input       [`PIXELY_BIT_CNT-1:0]    i_platY,
    input       [`PLAT_HF_WIDTH_BIT_CNT-1:0]    i_plat_size, 

    output      [`GADGET_BIT_CNT-1:0]   o_plat_gadget_effect,  
    output                              o_plat_receive_gadget,

    input                               i_plat_ack,
    output                              o_plat_req,

// ball IO
    // ballX, ballY: PIXEL(Display)
    input       [`PIXELX_BIT_CNT-1:0]    i_ballX,
    input       [`PIXELY_BIT_CNT-1:0]    i_ballY,
    // ball_size: PIXEL(Display) size
    input       [`BALL_SIZE_BIT_CNT-1:0]i_ball_size,
    // speedX, speedY: PIXEL(Display) location variation for the ball at next frame with no collision
    input       [1:0]                   i_ball_speedX, // 2 bit 00 == 0, 11 == -1, 01 i_== 1
    input       [1:0]                   i_ball_speedY,
    // damage: damage for brick
    input       [`DAM_BIT_CNT-1:0]      i_ball_damage,
    // ball_collision: cue for speed variation on ball, only one cycle pulse
    output                              o_ball_collision,
    output      [`DIR_BIT_CNT-1:0]      o_direc_var,
    

    //ball_req: request for the next frame ballX, ballY, ball_size, speedX, speedY
    //          posedge by calculating next frame, negedge by ball_ack = 1
    //ball_ack: one cycle pulse occurs when 1.ball_req = 1, 2. valid of data and ready to send
    //ball_frame_term: cue for finish calculation on this frame
    input                               i_ball_ack,
    input                               i_ball_frame_term,
    output                              o_ball_req,



// gadget IO
    // gadgetX, gadgetY: Fine Position
    input       [`PIXELX_BIT_CNT-1:0]   i_gadgetX,
    input       [`PIXELY_BIT_CNT-1:0]   i_gadgetY,

    input       [1:0]                   i_gadget_speedX, // 2 bit 00 == 0, 11 == -1, 01 i_== 1
    input       [1:0]                   i_gadget_speedY,

    output      [1:0]                   o_gadget_direc_var,         // 00 -> no change on direction 01 -> X 10 -> y
    output      [`PIXELX_BIT_CNT-1:0]   o_gadget_initX, //pixelX
    output      [`PIXELX_BIT_CNT-1:0]   o_gadget_initY, //pixelY

    // gadget_gen, gadget_type: when collision happened between ball and brick drops the gadget.
    output                              o_gadget_gen,
    input                               i_gadget_type,

    output                              o_gadget_eaten,
    input                               i_gadget_ack,
    input                               i_gadget_frame_term,
    output                              o_gadget_req,

// score IO
    output                              o_score_ball_brick_collision,
// Life IO              
    output                              o_minus_life,
// Brick IO    
    output      [`PIXELX_BIT_CNT-1:0]    o_br_ballX,
    output      [`PIXELY_BIT_CNT-1:0]    o_br_ballY,
    output      [`BALL_SIZE_BIT_CNT-1:0]o_br_ball_size,
    output      [1:0]                   o_br_speedX, // 2 bit 00 == 0, 11 == -1, 01 == 1
    output      [1:0]                   o_br_speedY,
    output      [1:0]                   o_br_damage,
    input                               i_br_gadget_gen,
    input                               i_ball_brick_collision,
    input       [`DIR_BIT_CNT-1:0]      i_direc_var,


    input                               i_brick_ack,
    output                              o_brick_req,

//  DEBUG
    output      [3:0]                   o_state,
    output                              o_ball_load_flag
);
    
    localparam INIT             = 4'd0; //Ready to shoot the first_n ball
    localparam STANDBY          = 4'd1;
    localparam PLAT_LOAD        = 4'd2;
    localparam GADGET_LOAD      = 4'd3;
    localparam GADGET_MAP       = 4'd4;
    localparam GADGET_PLAT      = 4'd5;
    localparam BALL_LOAD        = 4'd6; 
    localparam BALL_BRICK       = 4'd7; 
    localparam BALL_MAP         = 4'd8; 
    localparam BALL_PLAT        = 4'd9; 
    //DEBUG
    localparam BAD_STATE        = 4'd10;


// Load flag
    logic ball_load_flag;       // == handshake of corresponding module
    logic plat_load_flag;       // == handshake of corresponding module
    logic gadget_load_flag;     // == handshake of corresponding module
    assign ball_load_flag   = o_ball_req && i_ball_ack;
    assign plat_load_flag   = o_plat_req && i_plat_ack;
    assign gadget_load_flag = o_gadget_req && i_gadget_ack;
    assign o_ball_load_flag = ball_load_flag;

// Ball and Gadget Collision or finish calculation flag
    logic gadget_exist;
    logic ball_collision_flag,      n_ball_collision_flag;
    logic ball_brick_finish_flag,   n_ball_brick_finish_flag;
    logic ball_map_finish_flag,     n_ball_map_finish_flag;
    logic ball_plat_finish_flag,    n_ball_plat_finish_flag;
    logic gadget_collision_flag,      n_gadget_collision_flag;
    logic gadget_map_finish_flag,   n_gadget_map_finish_flag;
    logic gadget_plat_finish_flag,   n_gadget_plat_finish_flag;
    //logic gadget_col_finish_flag;
    assign gadget_exist = ~(!i_gadget_type);

    logic [3:0] state, n_state;
    assign o_state = state;
// counter for ball_map & ball_platform collision

// Platform output reg
    //logic       [`GADGET_BIT_CNT-1:0]   plat_gadget_effect;     // == gadget_type
    logic                               plat_receive_gadget,    n_plat_receive_gadget;    
    logic                               plat_req,               n_plat_req;             /// ✓

    assign o_plat_gadget_effect     = i_gadget_type;
    assign o_plat_receive_gadget    = plat_receive_gadget;
    assign o_plat_req               = plat_req;


//Ball output reg
    //logic                               ball_collision; // == ball_collision_flag
    logic       [`DIR_BIT_CNT-1:0]      direc_var,          n_direc_var;
    logic                               ball_req,           n_ball_req;             /// ✓
    assign o_ball_collision = ball_collision_flag;
    assign o_direc_var = direc_var;
    assign o_ball_req = ball_req;


//Gadget output reg
    logic       [1:0]                   gadget_direc_var,   n_gadget_direc_var;     
    //logic       [`PIXELX_BIT_CNT-1:0]   gadget_initX; // == ballX   //pixelX
    //logic       [`PIXELX_BIT_CNT-1:0]   gadget_initY; // == ballY   //pixelY
    //logic                               gadget_gen;   // == i_br_gadget_gen
    logic                               gadget_eaten,       n_gadget_eaten;
    logic                               gadget_req,         n_gadget_req;           /// ✓

    assign o_gadget_direc_var   = gadget_direc_var;
    assign o_gadget_initX       = i_ballX;
    assign o_gadget_initY       = i_ballY;
    assign o_gadget_gen         = i_br_gadget_gen;
    assign o_gadget_eaten       = gadget_eaten;
    assign o_gadget_req         = gadget_req;



// Score output reg
    //logic                               score_ball_brick_collision;
    assign o_score_ball_brick_collision = i_ball_brick_collision;
// Life output reg
    logic                               minus_life,         n_minus_life;
    assign o_minus_life = minus_life;


//Brick output reg
    //logic       [`PIXELX_BIT_CNT-1:0]       br_ballX;       // == i_ballX
    //logic       [`PIXELY_BIT_CNT-1:0]       br_ballY;       // == i_ballY
    //logic       [`BALL_SIZE_BIT_CNT-1:0]    br_ball_size;   // == i_ball_size
    //logic       [1:0]                       br_speedX;      // == i_ball_speedX  // 2 bit 00 == 0, 11 == -1, 01 == 1
    //logic       [1:0]                       br_speedY;      // == i_ball_speedY
    //logic       [1:0]                       br_damage;      // == i_ball_damage
    ////logic                                   br_gadget_req,  n_br_gadget_req;
    logic                                   brick_req,      n_brick_req;            /// ✓

    assign  o_br_ballX      =   i_ballX;
    assign  o_br_ballY      =   i_ballY;
    assign  o_br_ball_size  =   i_ball_size;
    assign  o_br_speedX     =   i_ball_speedX;  
    assign  o_br_speedY     =   i_ball_speedY;
    assign  o_br_damage     =   i_ball_damage;
    assign  o_brick_req     =   brick_req;


    // Platform Ball collision event
    logic                                   right;
    logic   [`DIR_BIT_CNT-1:0]              plat_ball_direction_var;
    assign right =  i_ballX > i_platX ? 1 : 0;

    // border condition
    logic [`PIXELX_BIT_CNT-1:0]     left_bm_border_condition;
    logic [`PIXELX_BIT_CNT-1:0]     right_bm_border_condition;
    logic [`PIXELY_BIT_CNT-1:0]     upper_bm_border_condition;
    logic [`PIXELY_BIT_CNT-1:0]     lower_bm_border_condition;

    logic [`PIXELX_BIT_CNT-1:0]     left_gm_border_condition;
    logic [`PIXELX_BIT_CNT-1:0]     right_gm_border_condition;
    logic [`PIXELY_BIT_CNT-1:0]     upper_gm_border_condition;
    logic [`PIXELY_BIT_CNT-1:0]     lower_gm_border_condition;

    logic [`PIXELY_BIT_CNT-1:0]     bp_border_condition;
    logic [`PIXELY_BIT_CNT-1:0]     gp_border_condition;
    assign left_bm_border_condition     = (`WALL_THICKNESS) + i_ball_size - {{(`PIXELX_BIT_CNT-1){i_ball_speedX[1]}},i_ball_speedX[0]};
    assign right_bm_border_condition    = (`WALL_THICKNESS) + i_ball_size + {{(`PIXELX_BIT_CNT-1){i_ball_speedX[1]}},i_ball_speedX[0]};
    assign upper_bm_border_condition    = (`WALL_THICKNESS) + i_ball_size - {{(`PIXELY_BIT_CNT-1){i_ball_speedY[1]}},i_ball_speedY[0]};
    assign lower_bm_border_condition    = (`WALL_THICKNESS) + i_ball_size + {{(`PIXELY_BIT_CNT-1){i_ball_speedY[1]}},i_ball_speedY[0]};

    assign left_gm_border_condition     = (`WALL_THICKNESS) + (`GADGET_SIZE) - {{(`PIXELX_BIT_CNT-1){i_gadget_speedX[1]}},i_gadget_speedX[0]};
    assign right_gm_border_condition    = (`WALL_THICKNESS) + (`GADGET_SIZE) + {{(`PIXELX_BIT_CNT-1){i_gadget_speedX[1]}},i_gadget_speedX[0]};
    assign upper_gm_border_condition    = (`WALL_THICKNESS) + (`GADGET_SIZE) - {{(`PIXELY_BIT_CNT-1){i_gadget_speedY[1]}},i_gadget_speedY[0]};
    assign lower_gm_border_condition    = (`WALL_THICKNESS) + (`GADGET_SIZE) + {{(`PIXELY_BIT_CNT-1){i_gadget_speedY[1]}},i_gadget_speedY[0]};

    assign bp_border_condition          = i_ballY + i_ball_size + {{(`PIXELY_BIT_CNT-1){i_ball_speedY[1]}},i_ball_speedY[0]};
    assign gp_border_condition          = i_gadgetY + (`GADGET_SIZE) + {{(`PIXELY_BIT_CNT-1){i_gadget_speedY[1]}},i_gadget_speedY[0]};

    ball_plat_direction_variation_v2 m1(.right(right), .plat_size(i_plat_size), .ball_size(i_ball_size), .platX(i_platX), .ballX(i_ballX), .direction_var(plat_ball_direction_var));

    //DEBUG
    logic [3:0] ifelse;
    logic [9:0] speedX_sign_extend;
    //logic [9:0] left_bm_border_condition;
    //logic       left_bm_border_condition_meet;
    assign speedX_sign_extend = {{(`PIXELX_BIT_CNT-1){i_ball_speedX[1]}},i_ball_speedX[0]};
    //assign left_bm_border_condition = (`WALL_THICKNESS) + i_ball_size + {{(`PIXELX_BIT_CNT-1){i_ball_speedX[1]}},i_ball_speedX[0]};
    //assign left_bm_border_condition_meet = i_ballX < (`WALL_THICKNESS) + i_ball_size + {{(`PIXELX_BIT_CNT-1){i_ball_speedX[1]}},i_ball_speedX[0]};
    // FSM
    always_comb begin
        n_state = state;
        case (state)
            INIT:
                if(i_game_start) n_state = STANDBY;
            STANDBY:
                if(i_cal_frame) n_state = PLAT_LOAD;
            PLAT_LOAD:
                if(plat_load_flag) n_state = GADGET_LOAD;
            GADGET_LOAD: begin
                if(gadget_load_flag) n_state = gadget_exist ? GADGET_MAP : BALL_LOAD;
                if(i_gadget_frame_term) n_state = BALL_LOAD;
            end
            GADGET_MAP:
                if(gadget_map_finish_flag) n_state = !gadget_collision_flag ? GADGET_PLAT : BALL_LOAD;
            GADGET_PLAT:
                if(gadget_plat_finish_flag) n_state = GADGET_LOAD;
            BALL_LOAD: begin
                if(ball_load_flag) n_state = BALL_BRICK;
                if(i_ball_frame_term) n_state = STANDBY;
            end
            BALL_BRICK:
                if(ball_brick_finish_flag) n_state = !ball_collision_flag ? BALL_MAP : BALL_LOAD;
            BALL_MAP:
                if(ball_map_finish_flag) n_state = !ball_collision_flag ? BALL_PLAT : BALL_LOAD;
            BALL_PLAT:
                if(ball_plat_finish_flag) n_state = BALL_LOAD;
            default:
                n_state = BAD_STATE;
        endcase
    end
// Load stuffs
    always_comb begin
        n_plat_req      = 0;
        n_gadget_req    = 0;
        n_ball_req      = 0;
        case (state)
            PLAT_LOAD: begin
                n_plat_req = 1;
                if(plat_req && i_plat_ack) n_plat_req = 0;
            end
            GADGET_LOAD: begin
                n_gadget_req = 1;
                if(gadget_req && (i_gadget_ack || i_gadget_frame_term)) n_gadget_req = 0;
            end
            BALL_LOAD: begin
                n_ball_req = 1;
                if(ball_req &&(i_ball_ack || i_ball_frame_term)) n_ball_req = 0;
            end
        endcase
    end
// Ball Collision Control
    always_comb begin
        n_ball_brick_finish_flag    = 0;
        n_ball_map_finish_flag      = 0;
        n_ball_plat_finish_flag     = 0;
        
        n_ball_collision_flag       = 0;
        n_direc_var                 = 0;

        n_brick_req                 = 0;
        n_minus_life                = 0;

        ifelse = 0;
        case (state)
            BALL_BRICK: begin
                n_brick_req = 1;
                if(brick_req && i_brick_ack) begin
                    n_ball_brick_finish_flag = 1;
                    n_ball_collision_flag = i_ball_brick_collision;
                    n_direc_var = i_direc_var;
                    n_brick_req = 0;
                end
                if(ball_brick_finish_flag) begin
                    n_ball_brick_finish_flag = 0;
                    n_ball_collision_flag = 0;
                    n_direc_var = i_direc_var;
                    n_brick_req = 0;
                end
            end
            BALL_MAP: begin
                // Left bound(using pixel)
                if(i_ballX < left_bm_border_condition) begin
                    n_ball_map_finish_flag = 1;
                    n_ball_collision_flag = 1;
                    n_direc_var = 18;
                    ifelse = 1;
                end
                // Right bound(using pixel)
                else if (((`PIXEL_640)-1-i_ballX) < right_bm_border_condition) begin
                    n_ball_map_finish_flag = 1;
                    n_ball_collision_flag = 1;
                    n_direc_var = 18;
                    ifelse = 2;
                end 
                // Upper bound(using pixel)
                else if(i_ballY < upper_bm_border_condition) begin
                    n_ball_map_finish_flag = 1;
                    n_ball_collision_flag = 1;
                    n_direc_var = 19;
                    ifelse = 3;
               end
                // Lower bound(using pixel)
                else if (((`PIXEL_480)-1-i_ballY) < lower_bm_border_condition) begin
                    n_ball_map_finish_flag = 1;
                    n_ball_collision_flag = 1;
                    n_direc_var = 19;      
                    n_minus_life = 1;
                    ifelse = 4;
                end
                else begin
                    n_ball_map_finish_flag = 1;
                    n_ball_collision_flag = 0;
                    n_direc_var = 0;      
                end
                if(ball_map_finish_flag) begin
                    n_ball_map_finish_flag = 0;
                    n_ball_collision_flag = 0;
                    n_direc_var = 0;      
                end
            end
            BALL_PLAT:begin
                n_ball_plat_finish_flag = 1;
                n_ball_collision_flag = 0;
                n_direc_var = plat_ball_direction_var;

                if(bp_border_condition  == i_platY) begin
                    if(right) begin
                        if(i_ballX - i_platX <= i_plat_size + i_ball_size ) begin
                            n_ball_plat_finish_flag = 1;
                            n_ball_collision_flag = 1;            
                            n_direc_var = plat_ball_direction_var;      
                        end
                        // else
                    end
                    else begin
                        if(i_platX - i_ballX <= i_plat_size + i_ball_size) begin
                            n_ball_plat_finish_flag = 1;
                            n_ball_collision_flag = 1;            
                            n_direc_var = plat_ball_direction_var;
                        end
                        // else                    
                    end
                end
                // else 
                if(ball_map_finish_flag) begin    
                    n_ball_collision_flag = 0;
                    n_direc_var = 0;     
                    n_ball_plat_finish_flag = 0;
                end
            end
        endcase
    end
// Gadget Collision Control
    always_comb begin
        n_gadget_map_finish_flag = 0;
        n_gadget_plat_finish_flag = 0;

        n_gadget_collision_flag = 0;

        n_gadget_direc_var = 0;
        n_gadget_eaten = 0;

        n_plat_receive_gadget = 0;

        case (state)
            GADGET_MAP: begin
                // Left bound
                if(i_gadgetX < left_gm_border_condition) begin
                    n_gadget_map_finish_flag = 1;
                    n_gadget_collision_flag = 1;
                    n_gadget_direc_var = 1;
                    n_gadget_eaten = 0;

                end
                // Right bound(using pixel)
                else if (((`PIXEL_640)-1-i_gadgetX) < right_gm_border_condition) begin
                    n_gadget_map_finish_flag = 1;
                    n_gadget_collision_flag = 1;
                    n_gadget_direc_var = 1;
                    n_gadget_eaten = 0;
                end 
                // Upper bound(using pixel)
                else if(i_gadgetY  < upper_gm_border_condition) begin
                    n_gadget_map_finish_flag = 1;
                    n_gadget_collision_flag = 1;
                    n_gadget_direc_var = 2;
                    n_gadget_eaten = 0;
               end
                // Lower bound(using pixel)
                else if (((`PIXEL_480)-1-i_gadgetY) < lower_gm_border_condition) begin
                    n_gadget_map_finish_flag = 1;
                    n_gadget_collision_flag = 0;
                    n_gadget_direc_var = 0;
                    n_gadget_eaten = 1;
                end
                else begin
                    n_gadget_map_finish_flag = 1;
                    n_gadget_collision_flag = 0;
                    n_gadget_direc_var = 0;
                    n_gadget_eaten = 0;
                end
                if(ball_plat_finish_flag) begin
                    n_gadget_map_finish_flag = 0;
                    n_gadget_collision_flag = 0;
                    n_gadget_direc_var = 0;
                    n_gadget_eaten = 0;
                end
            end
            GADGET_PLAT: begin 
                if(gp_border_condition > i_platY) begin
                    if(i_gadgetX > i_platX) begin
                        if(i_gadgetX - i_platX  < i_plat_size + (`GADGET_SIZE) + 1) begin
                            n_gadget_plat_finish_flag = 1;
                            n_gadget_eaten = 1;
                            n_plat_receive_gadget = 1;
                        end
                        // else
                    end
                    else begin
                        if(i_platX - i_gadgetX < i_plat_size + (`GADGET_SIZE) + 1) begin
                            n_gadget_plat_finish_flag = 1;
                            n_gadget_eaten = 1;
                            n_plat_receive_gadget = 1;
                        end  
                        // else                  
                    end
                end
                // else begin
                //     n_gadget_plat_finish_flag = 1;
                //     n_gadget_eaten = 0;
                //     n_plat_receive_gadget = 0;
                // end
                if(gadget_plat_finish_flag) begin
                    n_gadget_plat_finish_flag = 0;
                    n_gadget_eaten = 0;
                    n_plat_receive_gadget = 0;
                end            
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ball_collision_flag         <= 0;
            ball_brick_finish_flag      <= 0;
            ball_map_finish_flag        <= 0;
            ball_plat_finish_flag       <= 0;
            gadget_collision_flag       <= 0;
            gadget_map_finish_flag      <= 0;
            gadget_plat_finish_flag     <= 0;
            state                       <= STANDBY;

            plat_receive_gadget         <= 0;    
            plat_req                    <= 0;             /// ✓

            direc_var                   <= 0;
            ball_req                    <= 0;             /// ✓

            gadget_direc_var            <= 0;
            gadget_eaten                <= 0;
            gadget_req                  <= 0;           /// ✓

            minus_life                  <= 0;
            brick_req                   <= 0;            /// ✓

        end
        else begin
            ball_collision_flag         <= n_ball_collision_flag;
            ball_brick_finish_flag      <= n_ball_brick_finish_flag;
            ball_map_finish_flag        <= n_ball_map_finish_flag;
            ball_plat_finish_flag       <= n_ball_plat_finish_flag;
            gadget_collision_flag       <= n_gadget_collision_flag;
            gadget_map_finish_flag      <= n_gadget_map_finish_flag;
            gadget_plat_finish_flag     <= n_gadget_plat_finish_flag;
            state                       <= n_state;

            plat_receive_gadget         <= n_plat_receive_gadget;    
            plat_req                    <= n_plat_req;             /// ✓

            direc_var                   <= n_direc_var;
            ball_req                    <= n_ball_req;             /// ✓

            gadget_direc_var            <= n_gadget_direc_var;
            gadget_eaten                <= n_gadget_eaten;
            gadget_req                  <= n_gadget_req;           /// ✓

            minus_life                  <= n_minus_life;
            brick_req                   <= n_brick_req;            /// ✓
        end

    end

endmodule


// module ball_plat_direction_variation(
//     input                                   right,
//     input   [`PLAT_HF_WIDTH_BIT_CNT-1:0]    plat_size,
//     input   [`PIXELX_BIT_CNT-1:0]           platX,
//     input   [`PIXELX_BIT_CNT-1:0]           ballX,
//     output reg [`DIR_BIT_CNT-1:0]              direction_var
// );
//     logic    [`PLAT_HF_WIDTH_BIT_CNT-1:0]    center_distance;

//     assign center_distance = right ? (ballX[`PLAT_HF_WIDTH_BIT_CNT-1:0]-platX[`PLAT_HF_WIDTH_BIT_CNT-1:0]) : (platX[`PLAT_HF_WIDTH_BIT_CNT-1:0]-ballX[`PLAT_HF_WIDTH_BIT_CNT-1:0]);
//     always_comb begin
//         case (plat_size)
//             8'b10000000: direction_var = right ? 9 + center_distance[7:5] : 8 - center_distance[7:5];
//             8'b01000000: direction_var = right ? 9 + center_distance[6:4] : 8 - center_distance[6:4];
//             8'b00100000: direction_var = right ? 9 + center_distance[5:3] : 8 - center_distance[5:3];
//             8'b00010000: direction_var = right ? 9 + center_distance[4:2] : 8 - center_distance[4:2];
//             8'b00001000: direction_var = right ? 9 + center_distance[3:1] : 8 - center_distance[3:1];
//         endcase
//     end

// endmodule

module ball_plat_direction_variation_v2(
    input                                   right,
    input   [`PLAT_HF_WIDTH_BIT_CNT-1:0]    plat_size,
    input   [`BALL_SIZE_BIT_CNT-1:0]        ball_size,
    input   [`PIXELX_BIT_CNT-1:0]           platX,
    input   [`PIXELX_BIT_CNT-1:0]           ballX,
    output logic [`DIR_BIT_CNT-1:0]           direction_var
);
    logic   [9:0]       range;
    logic    [`PLAT_HF_WIDTH_BIT_CNT-1:0]    center_distance;
    logic   [2:0]       quotient;
    assign range    = plat_size + ball_size;
    assign center_distance = right ? (ballX[`PLAT_HF_WIDTH_BIT_CNT-1:0]-platX[`PLAT_HF_WIDTH_BIT_CNT-1:0]) : (platX[`PLAT_HF_WIDTH_BIT_CNT-1:0]-ballX[`PLAT_HF_WIDTH_BIT_CNT-1:0]);
    assign quotient = {center_distance,3'd0}/range;
    assign direction_var = right ? 9 + quotient : 8 - quotient;

endmodule
