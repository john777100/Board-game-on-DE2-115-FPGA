`include "define.sv"

module gadget(
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
    input        [`GADGET_BIT_CNT-1:0]    i_gadget_type_by_brick,
    output       [`GADGET_BIT_CNT-1:0]    o_gadget_type,

    input                              i_gadget_eaten,
    output                             o_gadget_ack,
    output                             o_gadget_frame_term,
    input                              i_gadget_req,
    input                              i_game_start
    //
);

// Internal Reg
    logic   [`FPOSX_BIT_CNT-1:0]    gadget_fposX, n_gadget_fposX;
    logic   [`FPOSY_BIT_CNT-1:0]    gadget_fposY, n_gadget_fposY;
    logic   [`FSPEED_BIT_CNT-1:0]   fspeedX,    n_fspeedX;
    logic   [`FSPEED_BIT_CNT-1:0]   fspeedY,    n_fspeedY;

    logic   [4:0]                   counter,    n_counter, static_counter, n_static_counter, cooldown_counter, n_cooldown_counter;          /// ✓
    logic   [2:0]                   state,      n_state;            /// ✓
    
// Collision IO Reg
    //logic   [`PIXELX_BIT_CNT-1:0]       ballX, n_ballX;   // == front 10 bits of ball_fposX
    //logic   [`PIXELY_BIT_CNT-1:0]       ballY, n_ballY;   // == front 9 bits of ball_fposY
    //logic   [`BALL_SIZE_BIT_CNT-1:0]    ball_size;        // == i_ball_size
    logic   [1:0]                       gadget_speedX, n_gadget_speedX;
    logic   [1:0]                       gadget_speedY, n_gadget_speedY;
    logic                               gadget_ack, n_gadget_ack;
    logic                               gadget_frame_term, n_gadget_frame_term;
    logic	[`GADGET_BIT_CNT-1:0]		gadget_type, n_gadget_type;
	logic								counter_wait, n_counter_wait, term_frame_flag, n_term_frame_flag, initialize_flag, n_initialize_flag;
    assign o_gadgetX          = (gadget_type > 4'b0) ? gadget_fposX[`FPOSX_BIT_CNT-1:3] : 0;
    assign o_gadgetY          = (gadget_type > 4'b0) ? gadget_fposY[`FPOSY_BIT_CNT-1:3] : 0;
    assign o_gadget_speedX    = (gadget_type > 4'b0) ? gadget_speedX : 0;
    assign o_gadget_speedY    = (gadget_type > 4'b0) ? gadget_speedY : 0;
    assign o_gadget_ack       = gadget_ack;
    assign o_gadget_frame_term= (gadget_type > 4'b0) ? gadget_frame_term : 1;
    assign o_gadget_type	  = gadget_type;

// flag
    //logic   handshake;
    //assign handshake = i_gadget_req && o_gadget_ack;

// Look up table

    logic   [`FSPEED_BIT_CNT-1:0]   lp_fspeedX;
    logic   [`FSPEED_BIT_CNT-1:0]   lp_fspeedY;
    direction_look_upp lp(.direction_var(static_counter),.fspeedX(lp_fspeedX),.fspeedY(lp_fspeedY));

always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            gadget_speedX     <= 0;
            gadget_speedY     <= 0;
            gadget_ack        <= 0;
            gadget_frame_term <= 0;
            gadget_fposX      <= 0;
            gadget_fposY      <= 0;
            fspeedX         <= 4'd0;
            fspeedY         <= 4'd0;
            counter         <= 4'd1;          /// ✓
            static_counter  <= 4'd1;
            gadget_type     <= 4'd0;
			counter_wait	 <= 1'b0;
            term_frame_flag <= 1'b0;
            cooldown_counter <= 4'b0;
            //initialize_flag <= 1'b1;
        end
        else begin
            gadget_speedX     <= n_gadget_speedX;
            gadget_speedY     <= n_gadget_speedY;
            gadget_ack        <= n_gadget_ack;
            gadget_frame_term <= n_gadget_frame_term;
            gadget_fposX      <= n_gadget_fposX;
            gadget_fposY      <= n_gadget_fposY;
            fspeedX         <= n_fspeedX;
            fspeedY         <= n_fspeedY;
            counter         <= n_counter;          /// ✓
            static_counter  <= n_static_counter;
            gadget_type 	<= n_gadget_type;
			counter_wait	<= n_counter_wait;
            term_frame_flag <= n_term_frame_flag;
            cooldown_counter <= n_cooldown_counter;
            //initialize_flag <= n_initialize_flag;
        end
    end


// handle gadget generation, eaten, type, and initialize counter.
	always_comb begin
		n_gadget_type = gadget_type;
		n_counter = counter;
		n_static_counter = static_counter;
		n_fspeedX = fspeedX;
        n_fspeedY = fspeedY;
		n_counter_wait = counter_wait;
        n_term_frame_flag = term_frame_flag;
        n_cooldown_counter = cooldown_counter;

		if(i_gadget_gen && gadget_type == 4'd0) begin
			n_gadget_type = i_gadget_type_by_brick;
			n_counter = 5'd1;
			n_static_counter = 5'd1;
		end
		else if (i_gadget_eaten) begin
			n_gadget_type = 4'b0;
			n_counter = 4'd0;
			n_static_counter = 4'd0;
		end
		else begin
	        if(counter > 0) begin
	                    n_fspeedX = lp_fspeedX;
	                    n_fspeedY = lp_fspeedY;
	        end

	        if((!gadget_ack) && i_gadget_req && counter > 5'd0) begin
					n_counter = counter - 5'd1;
	        end
	        else if(counter == 5'd0 && (counter_wait == 1'b0)) begin
					n_counter_wait = 1'b1;
                    n_term_frame_flag = 1'b1;
			end
			else if(counter_wait && i_cal_frame) begin
					n_counter = static_counter;
					n_counter_wait = 1'b0;
	        end
		end

        if(gadget_frame_term == 1'b1) begin
            n_term_frame_flag = 1'b0;
        end

		if(i_cal_frame && counter < static_counter) begin
            if(cooldown_counter == 5'd20) begin
    			case(static_counter)
                    5'd15: n_static_counter = 5'd9;
    				5'd9: n_static_counter = 5'd6;
    				5'd6: n_static_counter = 5'd3;
    				5'd3: n_static_counter = 5'd1;
    				5'd1: n_static_counter = 5'd2;
    				//5'd2: n_static_counter = 5'd4;
    				//5'd5: n_static_counter = 5'd7;
    				//5'd7: n_static_counter = 5'd8;
    				//5'd8: n_static_counter = 5'd10;
    				//5'd10: n_static_counter = 5'd11;
    				default: n_static_counter = 5'd2;
    			endcase
                n_cooldown_counter = 5'd0;
            end else begin
                n_cooldown_counter = cooldown_counter + 5'd1;
            end
		end

        if(i_game_start) begin
            n_gadget_type = 4'b0;
            n_counter = 4'd1;
            n_static_counter = 4'd1;
            n_fspeedX = 0;
            n_fspeedY = 0;
            n_counter_wait = 0;
            n_term_frame_flag = 0;
            n_cooldown_counter = 0;
        end
	end


	// next timing logic
    logic [`FPOSX_BIT_CNT-1:0]  n_n_gadget_fposX;
    logic [`FPOSY_BIT_CNT-1:0]  n_n_gadget_fposY;
    assign n_n_gadget_fposX = n_gadget_fposX + {{(`FPOSX_BIT_CNT-1){fspeedX[3]}},fspeedX};
    assign n_n_gadget_fposY = n_gadget_fposY + {{(`FPOSY_BIT_CNT-1){fspeedY[3]}},fspeedY};

// gadget_fposX/gadget_fposY/gadget_speedX/gadget_speedY/gadget_ack reg
    always_comb begin
        n_gadget_fposX = gadget_fposX;
        n_gadget_fposY = gadget_fposY;
        n_gadget_speedX = gadget_speedX;
        n_gadget_speedY = gadget_speedY;
        n_gadget_ack    = 0;
        //n_initialize_flag = initialize_flag;
        if(i_gadget_req) begin
                if(!gadget_ack) begin
                    n_gadget_fposX = gadget_fposX + {{(`FPOSX_BIT_CNT-1){fspeedX[3]}},fspeedX};
                    n_gadget_fposY = gadget_fposY + {{(`FPOSY_BIT_CNT-1){fspeedY[3]}},fspeedY};
                    n_gadget_speedX = n_n_gadget_fposX[3] != n_gadget_fposX[3] ? (fspeedX[3] ? 2'b11 : 2'b01 ) : 2'b00;
                    n_gadget_speedY = n_n_gadget_fposY[3] != n_gadget_fposY[3] ? (fspeedY[3] ? 2'b11 : 2'b01 ) : 2'b00;
                    if(gadget_type > 4'd0 && term_frame_flag == 1'b0) begin
                        n_gadget_ack = 1;
                    end else begin
                        n_gadget_ack = 0;
                    end
                end
                else begin
                    n_gadget_ack = 0;
                end
        end
        else if(i_gadget_gen && gadget_type == 4'b0) begin
        	n_gadget_fposX = {i_gadget_initX, 3'b000};
        	n_gadget_fposY = {i_gadget_initY, 3'b000};
        	n_gadget_speedX = 0;
        	n_gadget_speedY = 0;
            //n_initialize_flag = 1'b0;
        end

        //if(gadget_type == 4'b0) begin
        //    n_initialize_flag = 1'b1;
        //end
        if(i_game_start) begin
            n_gadget_fposX = 0;
            n_gadget_fposY = 0;
            n_gadget_speedX = 0;
            n_gadget_speedY = 0;
            n_gadget_ack = 0;
        end
    end

    // fspeedX fspeedY
// affect by i_grab i_shoot_ball state collision
    always_comb begin
    	n_gadget_frame_term = 0;
        if(i_gadget_req == 1 && gadget_frame_term == 0 && term_frame_flag == 1'b1) begin
        	n_gadget_frame_term = 1;
        end

        if(i_game_start) begin
            n_gadget_frame_term = 0;
        end
    end

endmodule




    module direction_look_upp(
    input   [4:0]      direction_var,
    output logic [`FSPEED_BIT_CNT-1:0]   fspeedX,   
    output logic [`FSPEED_BIT_CNT-1:0]   fspeedY
);
    always_comb begin
        case (direction_var)
            5'd9: begin fspeedY = -4'd2; fspeedX = 4'd0; end
            5'd6: begin  fspeedY = -4'd2; fspeedX = 4'd0; end
            5'd3: begin  fspeedY = -4'd2; fspeedX = 4'd0; end
            5'd1: begin  fspeedY = -4'd2; fspeedX = 4'd0; end
            5'd2: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            5'd5: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            5'd7: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            5'd8: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            5'd10: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            5'd11: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            5'd4: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
            default: begin  fspeedY = 4'd2; fspeedX = 4'd0; end
        endcase
    end
    
endmodule