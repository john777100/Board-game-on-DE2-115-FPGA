`include "define.sv"
module platform(
//Fundemental IO
    input                       clk,
    input                       rst_n,

//Control IO
    input                               i_game_start,   // when losing one life or start of the game 
    input                               i_cal_frame, 
    input       [`PIXELX_BIT_CNT-1:0]   i_gamepad_X,

// Collision IO
    output      [`PIXELX_BIT_CNT-1:0]    o_platX,
    output      [`PIXELY_BIT_CNT-1:0]    o_platY,
    output      [`PLAT_HF_WIDTH_BIT_CNT-1:0]    o_plat_size, 

    input       [`GADGET_BIT_CNT-1:0]   i_plat_gadget_effect,  
    input                               i_plat_receive_gadget,

    output                              o_plat_ack,
    input                               i_plat_req,

// Ball IO
    output                               o_grab,
    output   [`PIXELX_BIT_CNT-1:0]       o_2ball_platX,
    output   [`PIXELY_BIT_CNT-1:0]       o_2ball_platY,
    output   [`STEP_BIT_CNT-1:0]         o_ball_speedstep,
    output   [`BALL_SIZE_BIT_CNT-1:0]    o_ball_size,
    output                               o_ball_damage
);

// Internal Reg
    logic   [`PIXELX_BIT_CNT-1:0]       plat_pixelX,        n_plat_pixelX;
    //logic   [`PIXELY_BIT_CNT-1:0]       plat_pixelY,        n_plat_pixelY;
    logic   [`BALL_SIZE_NUM_BIT_CNT-1:0]ball_sizenum,       n_ball_sizenum;
    logic   [`STEP_BIT_CNT-1:0]         ball_speedstep,     n_ball_speedstep;
    logic   [`PLAT_SIZE_NUM_BIT_CNT-1:0]plat_sizenum,       n_plat_sizenum;
    logic                               gadget_grab,        n_gadget_grab;
    logic                               gadget_fireball,    n_gadget_fireball;

// Look up table
    logic  [`BALL_SIZE_BIT_CNT-1:0]         lp_ball_size_pixel;
    logic  [`PLAT_HF_WIDTH_BIT_CNT-1:0]     lp_plat_size_pixel;
    ball_size_look_up ball_lp(.size_num(ball_sizenum), .size_pixel(lp_ball_size_pixel));
    platform_size_look_up plat_lp(.size_num(plat_sizenum), .size_pixel(lp_plat_size_pixel));

// Collision Reg
    //logic   [`PIXELX_BIT_CNT-1:0]       platX;    // == plat_pixelX
    //logic   [`PIXELY_BIT_CNT-1:0]       platY;    // == `PLAT_PIXELY
    logic   [`PLAT_HF_WIDTH_BIT_CNT-1:0]plat_size,  n_plat_size;
    logic                               plat_ack,   n_plat_ack;
    assign o_platX      = plat_pixelX;
    assign o_platY      = `PLAT_PIXELY;
    assign o_plat_size  = plat_size;
    assign o_plat_ack   = plat_ack;

// Ball Reg
    //logic                               grab;             // == gadget_grab
    //logic   [`PIXELX_BIT_CNT-1:0]       2ball_platX;      // == plat_pixelX
    //logic   [`PIXELY_BIT_CNT-1:0]       2ball_platY;      // == `PLAT_PIXELY
    //logic   [`STEP_BIT_CNT-1:0]        ball_speedstep;    // in Internal Reg
    //logic   [`BALL_SIZE_BIT_CNT-1:0]    ball_size;        // == lp_ball_size_pixel
    //logic                               ball_damage;
    assign  o_grab = gadget_grab;
    assign  o_2ball_platX = plat_pixelX;
    assign  o_2ball_platY = `PLAT_PIXELY;
    assign  o_ball_speedstep = ball_speedstep;
    assign  o_ball_size = lp_ball_size_pixel;
    assign  o_ball_damage = gadget_fireball;





// Internal wire
    logic   [`PIXELX_BIT_CNT-1:0]       platX_limit_left;
    logic   [`PIXELX_BIT_CNT-1:0]       platX_limit_right;
    assign  platX_limit_left    = `WALL_THICKNESS + lp_plat_size_pixel;
    assign  platX_limit_right   = `PIXEL_640 - `WALL_THICKNESS - lp_plat_size_pixel;


// Platform related Reg & ack
    always_comb begin
        n_plat_pixelX = plat_pixelX;
        n_plat_size = plat_size;
        n_plat_ack = 0;
        //n_plat_ack = 1;
        if(i_plat_req) begin
            if(!plat_ack) begin
                n_plat_ack = 1;
                n_plat_size = lp_plat_size_pixel;
                if(i_gamepad_X < platX_limit_left)
                    n_plat_pixelX = platX_limit_left;
                else if (i_gamepad_X > platX_limit_right)
                    n_plat_pixelX = platX_limit_right;
                else
                    n_plat_pixelX = i_gamepad_X;
            end
            else 
                n_plat_ack = 0;
        end
        

    end

// Gadget related Reg
    always_comb begin
        n_ball_sizenum      = ball_sizenum;
        n_ball_speedstep    = ball_speedstep;
        n_plat_sizenum      = plat_sizenum;
        n_gadget_grab       = gadget_grab;
        n_gadget_fireball   = gadget_fireball;

        if(i_plat_receive_gadget) begin
            case(i_plat_gadget_effect)
                `EXPAND: n_plat_sizenum = plat_sizenum != 3'd5 ? plat_sizenum + 1 : plat_sizenum;
                `SHRINK: n_plat_sizenum = plat_sizenum != 3'd1 ? plat_sizenum - 1 : plat_sizenum;
                `GRAB:   n_gadget_grab = 1;
                `FASTER_BALL: n_ball_speedstep = ball_speedstep != 3'd5 ? ball_speedstep + 1 : ball_speedstep;   
                `SLOWER_BALL:    n_ball_speedstep = ball_speedstep != 3'd1 ? ball_speedstep - 1 : ball_speedstep; 
                `FIRE_BALL:      n_gadget_fireball = 1;
                `BIGGER_BALL:    n_ball_sizenum = ball_sizenum != 3'd3 ? ball_sizenum + 1 : ball_sizenum;
                `SMALLER_BALL:   n_ball_sizenum = ball_sizenum != 3'd1 ? ball_sizenum - 1 : ball_sizenum;
            endcase
        end
        if(i_game_start) begin
            n_ball_sizenum      = 3'd2;
            n_ball_speedstep    = 3'd3;
            n_plat_sizenum      = 3'd5;
            n_gadget_grab       = 1'd0;
            n_gadget_fireball   = 1'd0;
        end
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            plat_pixelX        <= 320;
            ball_sizenum       <= 2;
            ball_speedstep     <= 2;
            plat_sizenum       <= 5;
            gadget_grab        <= 0;
            gadget_fireball    <= 0;
            plat_size          <= 32;
            plat_ack           <= 0;
        end
        else begin
            plat_pixelX        <= n_plat_pixelX;
            ball_sizenum       <= n_ball_sizenum;
            ball_speedstep     <= n_ball_speedstep;
            plat_sizenum       <= n_plat_sizenum;
            gadget_grab        <= n_gadget_grab;
            gadget_fireball    <= n_gadget_fireball;
            plat_size          <= n_plat_size;
            plat_ack           <= n_plat_ack;
        end
    end


endmodule

module ball_size_look_up(
    input   [`BALL_SIZE_NUM_BIT_CNT-1:0]    size_num,
    output reg [`BALL_SIZE_BIT_CNT-1:0]        size_pixel
);
    always_comb begin
        case(size_num)
            2'd1: size_pixel = 6'd3;
            2'd2: size_pixel = 6'd5;
            2'd3: size_pixel = 6'd7;
            default: size_pixel = 6'd1;
        endcase
    end
endmodule

module platform_size_look_up(
    input   [`PLAT_SIZE_NUM_BIT_CNT-1:0]    size_num,
    output logic [`PLAT_HF_WIDTH_BIT_CNT-1:0]    size_pixel
);
    always_comb begin
        case(size_num)
            3'd1: size_pixel = 8'd8;
            3'd2: size_pixel = 8'd16;
            3'd3: size_pixel = 8'd32;
            3'd4: size_pixel = 8'd64;
            3'd5: size_pixel = 8'd128;
            default: size_pixel = 8'd1;
        endcase
    end

endmodule