module Disp_Ctrl(
    input clk, //50Mhz
    input rst_n,
    input endgame, startgame,
    input acknowledge,
    output logic [1:0] state,
    output logic request
);
    logic [19:0] counter,counter_next; //need 833K cycles
    logic request_next;
    logic [1:0] state_next;

    parameter START = 2'b00;
    parameter GAME  = 2'b01;
    parameter END   = 2'b10; 

    always_comb
    begin
        state_next = state;
        case(state)
            START:if(startgame) state_next = GAME;   
            GAME: if(endgame) state_next = END;
        endcase
    end

    always_comb
    begin
        counter_next = counter + 1;
        request_next = request;

        if(counter == 20'd833333)
        begin
            counter_next = 0;
            request_next = 1;
        end

        if(acknowledge) request_next = 0;
    end

    always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
        request <= 0;
        state <= 0;
        counter <= 0;
    end
    else begin
        request <= request_next;
        state   <= state_next;
        counter <= counter_next;
    end
end

endmodule