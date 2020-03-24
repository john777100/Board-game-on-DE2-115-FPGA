`include "define.sv"

module score (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input i_score_ball_brick_collision,
	output [9:0] o_score
);

logic [9:0] score, n_score;
assign o_score = score;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		score <= 10'd0;
	end else begin
		score <= n_score;
	end
end

always_comb begin
	if(i_score_ball_brick_collision) begin 
		n_score = score + 10'd10;
	end else begin 
		n_score = score; 
	end
end

endmodule