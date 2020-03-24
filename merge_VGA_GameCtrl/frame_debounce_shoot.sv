module frame_debounce_shoot (
    // Fundemental IO
    input   i_clk,
    input   i_rst_n,

    // make the shoot signal last for one frame in the upcoming frame
    input   i_shoot_signal,
    input   i_cal_frame,
    output  o_shoot_signal_frame_debounce,
    output  o_shoot_next_frame_high

);
    //Output reg
    logic   shoot_signal_frame_debounce, n_shoot_signal_frame_debounce;

    // Internal reg
    logic   shoot_next_frame_high, n_shoot_next_frame_high;   
    assign o_shoot_signal_frame_debounce = shoot_signal_frame_debounce;
    assign o_shoot_next_frame_high = shoot_next_frame_high;


    always_comb begin
        n_shoot_signal_frame_debounce   = shoot_signal_frame_debounce;
        n_shoot_next_frame_high         = shoot_next_frame_high;
        if(i_shoot_signal)
            n_shoot_next_frame_high = 1;

        if(i_cal_frame) begin
            if(shoot_next_frame_high) n_shoot_signal_frame_debounce = 1;
            else n_shoot_signal_frame_debounce = 0;
            n_shoot_next_frame_high = 0;
        end
    end
    
    
    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(!i_rst_n) begin
            shoot_signal_frame_debounce <= 0;
            shoot_next_frame_high       <= 0;
        end
        else begin
            shoot_signal_frame_debounce <= n_shoot_signal_frame_debounce;
            shoot_next_frame_high       <= n_shoot_next_frame_high;
        end
    end

    
endmodule