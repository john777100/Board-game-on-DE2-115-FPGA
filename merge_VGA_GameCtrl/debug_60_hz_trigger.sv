module debug_60_hz_trigger (
    input   i_clk,
    input   i_rst_n,
    input   i_play_pause,
    input   i_frame_by_frame,
    output  o_cal_frame_signal
);
    localparam PLAY     = 1'b0;
    localparam PAUSE    = 1'b1;
    logic           state,      n_state;
    logic   [19:0]  counter,    n_counter; //need 833K cycles
    logic           cal_frame_signal, n_cal_frame_signal;
    assign o_cal_frame_signal = cal_frame_signal;
    always_comb begin
        n_state = state;
        if(i_play_pause) n_state = !state;
    end

    always_comb begin
        n_counter = counter;
            if(state == PLAY) begin
                n_counter = counter + 1;
                if(counter == 19'd833333) n_counter = 0;
            end
    end
    always_comb begin
        n_cal_frame_signal = 0;
        case (state)
            PLAY: begin
                if(counter == 19'd833333) n_cal_frame_signal = 1;
            end
            PAUSE: begin
                if(i_frame_by_frame) n_cal_frame_signal = 1;
            end
            
        endcase
        if(cal_frame_signal == 1) n_cal_frame_signal = 0;
    end

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(!i_rst_n) begin
            state               <=  PLAY;
            counter             <=  0; //need 833K cycles
            cal_frame_signal    <=  0;
        end
        else begin
            state               <=  n_state;
            counter             <=  n_counter; //need 833K cycles
            cal_frame_signal    <=  n_cal_frame_signal;
        end
        
    end
endmodule