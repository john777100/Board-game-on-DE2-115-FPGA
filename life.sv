`include "define.sv"

module life(
			input clk,
			input rst_n,
			input i_minus_life,
			output [2:0] o_life_count
	);

reg [2:0] life_count, n_life_count;
assign o_life_count = life_count;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		life_count <= 3'd3;
	end else begin
		life_count <= n_life_count;
	end
end

always_comb begin
	if(i_minus_life) begin n_life_count = life_count - 3'd1; end
	else begin n_life_count = life_count; end
end

endmodule