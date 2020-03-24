`define GAD_SPE_STEP 5
module gadget_v2(
    // Fundemental IO
    input                               clk,
    input                               rst_n,
    // Collision IO
    // gadget IO
    input      [`PIXELX_BIT_CNT-1:0]   i_gadget_initX, //pixelX
    input      [`PIXELY_BIT_CNT-1:0]   i_gadget_initY, //pixelY
    input                              i_cal_frame,    


    // gadgetX, gadgetY: Fine Position
    output       [`PIXELX_BIT_CNT-1:0]   o_gadgetX,
    output       [`PIXELY_BIT_CNT-1:0]   o_gadgetY,

    output       [1:0]                   o_gadget_speedX, // 2 bit 00 == 0, 11 == -1, 01 i_== 1
    output       [1:0]                   o_gadget_speedY,

    
    // gadget_gen, gadget_type: when collision happened between ball and brick drops the gadget.
    input                              	i_gadget_gen,
    input        [`GADGET_BIT_CNT-1:0]  i_gadget_type_by_brick,
    output       [`GADGET_BIT_CNT-1:0]  o_gadget_type,

    input                              i_gadget_eaten,
    output                             o_gadget_ack,
    output                             o_gadget_frame_term,
    input                              i_gadget_req
    //
);

    localparam STANDBY          = 3'd0;
    localparam WAIT_FOR_REQ     = 3'd1;
    localparam CAL_FOR_REQ      = 3'd2;
    localparam FRAME_TERM       = 3'd3;

    localparam INIT_STEP        = `GAD_SPE_STEP'd5;
    localparam TERM_STEP        = `GAD_SPE_STEP'd15;

    localparam SPEED_UP         = -4'd6;
    localparam SPEED_DOWN       = 4'd6;

// Internal logic
    logic       [`PIXELX_BIT_CNT-1:0]   gadget_fposX,            n_gadget_fposX;
    logic       [`PIXELY_BIT_CNT-1:0]   gadget_fposY,            n_gadget_fposY;
    logic       [`GAD_SPE_STEP-1:0]     speedstep,  n_speedstep;
    logic       [`GAD_SPE_STEP-1:0]     counter,    n_counter;
    logic                               direc_y,    n_direc_y; // direc_y: 0: -y, 1: +y
    logic       [1:0]                   state,      n_state;
    logic                               gadget_exist;
    logic                               handshake;

    assign gadget_exist     = !(gadget_type == 0);
    assign handshake        = i_gadget_req && gadget_ack;


// Output logic
    logic       [`PIXELX_BIT_CNT-1:0]   gadgetX,            n_gadgetX;
    logic       [`PIXELY_BIT_CNT-1:0]   gadgetY,            n_gadgetY;


    logic       [1:0]                   gadget_speedX,      n_gadget_speedX; // 2 bit 00 == 0; 11 == -1; 01 i_== 1
    logic       [1:0]                   gadget_speedY,      n_gadget_speedY;

    logic       [`GADGET_BIT_CNT-1:0]   gadget_type,        n_gadget_type;
    
    logic                               gadget_ack,         n_gadget_ack;
    logic                               gadget_frame_term,  n_gadget_frame_term;

    assign gadget_speedY = 2'd0;

    always_comb begin
        n_state = state;
        case (state)
            STANDBY:        n_state = i_gadget_req ? CAL_FOR_REQ : state;
            WAIT_FOR_REQ:   n_state = i_gadget_req ? CAL_FOR_REQ : state;
            CAL_FOR_REQ:    n_state = handshake ? (counter == 3'd1 ? FRAME_TERM : WAIT_FOR_REQ) : state;
            FRAME_TERM:     n_state = i_cal_frame ? STANDBY : state;
        endcase

    end



    // speedstep & direc
    always_comb begin
        n_speedstep = speedstep;
        n_direc_y = direc_y;

        case (state)
            CAL_FOR_REQ: begin
                if(handshake) begin
                    if(!direc_y && speedstep != `GAD_SPE_STEP'd1) n_speedstep = speedstep - 2;
                    if (direc_y && speedstep != `GAD_SPE_STEP'd15) n_speedstep = speedstep + 2;
                    if(!direc_y && speedstep == `GAD_SPE_STEP'd1) n_direc_y = 1'b1;
                end
            end
            default: begin
                n_speedstep = speedstep;
                n_direc_y = direc_y;
            end
        endcase

        if(i_gadget_gen && !gadget_exist) begin
            n_speedstep = INIT_STEP;
            n_direc_y   = 0;
        end 
    end

//
//n_gadget_fposX
//n_gadget_fposY;

//n_gadget_speedX; // 2 bit 00 == 0; 11 == -1; 01 i_== 1
//n_gadget_speedY;
    always_comb begin
        n_gadget_fposX = gadget_fposX;
        n_gadget_fposY = gadget_fposY;
        n_gadget_speedX = gadget_speedX;
        n_gadget_speedY = gadget_speedY;
        n_ball_ack      = 0;
        case (state)
            CAL_FOR_REQ: begin
                if(!ball_ack) begin
                    n_gadget_fposX = !direc_y;
                    n_gadget_fposY = gadget_fposY;
                    n_ball_ack = 1;
                end
                else n_ball_ack = 0;
            end
            
            default: begin
                pass
            end
        endcase

    end



// counter reg
    always_comb begin
        n_counter = counter;
        case(state)
            STANDBY:        n_counter = speedstep;
            WAIT_FOR_REQ:   n_counter = counter;
            CAL_FOR_REQ:    n_counter = handshake ? counter - 1 : counter;
            FRAME_TERM:     n_counter = i_cal_frame ? speedstep : counter;
        endcase
    end




endmodule