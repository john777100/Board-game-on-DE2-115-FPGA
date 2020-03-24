module  ball_pos
(
        input logic clk, //25MHz
        input logic rst_n,
        input logic [7:0] key,
		output logic [9:0] ballX,
        output logic [8:0] ballY
);

logic [9:0] ballX_next;
logic [8:0] ballY_next;
logic [17:0] counter,counter_next;
logic revX,revX_next;

always@(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
        ballX <= 10'd320;
        ballY <= 9'd240;
        counter <= 0;
        revX  <= 0;
    end
    else begin
        ballX <= ballX_next;
        ballY <= ballY_next;
        counter <= counter_next;
        revX <= revX_next;
    end
end

always_comb begin
    counter_next = counter + 1;
    ballY_next = ballY;
    ballX_next = ballX;
    revX_next = revX;
    
   /* if(counter == 18'd0)begin
        if(!revX) begin
            ballX_next = ballX + 10'd1;
            if(ballX == 10'd630) revX_next = 1;
            else revX_next = 0;
        end
        else begin
            ballX_next = ballX - 10'd1;
            if(ballX == 10'd20) revX_next = 0;
            else revX_next = 1;
        end  
    end
    else begin
        ballX_next = ballX;
        revX_next = revX;
    end*/
    case(key)
        8'h1D:begin //up
            if(ballY <= 9'd20) ballY_next = ballY;
            else ballY_next = ballY - 9'd5;
        end
        8'h1B:begin //down
            if(ballY >= 9'd460) ballY_next = ballY;
            else ballY_next = ballY + 9'd5;
        end
        8'h1C:begin //left
            if(ballX <= 10'd20) ballX_next = ballX;
            else ballX_next = ballX - 10'd5;
        end
        8'h23:begin //right
            if(ballX >= 10'd630) ballX_next = ballX;
            else ballX_next = ballX + 10'd5;
        end
    endcase
end

endmodule
