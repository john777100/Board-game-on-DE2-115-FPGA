module direction(
					clk,
					rst,
					//light,
					ready,
					//X_center,
					Y_center,
					//X_MOVE_right_r,
					//X_MOVE_left_r,
					Y_MOVE_down_r,
					Y_MOVE_up_r,
					//X_center_before_r,
					Y_center_before_r,
					down_detected
					);

//`include "VGA_Param.h"
`define VGA_640x480p60
input clk;
input rst;
//input [7:0] light;
input ready;
//input [9:0] X_center;
input [9:0] Y_center;
//output reg [9:0] X_MOVE_left_r;
//output reg [9:0] X_MOVE_right_r;
reg [9:0] Y_MOVE_up_r;
reg [9:0] Y_MOVE_down_r;
//output reg [9:0] X_center_before_r;
reg [9:0] Y_center_before_r;
output reg		 down_detected;
reg [9:0] Y_MOVE_up_w, Y_MOVE_down_w, Y_center_before_w;
//X_MOVE_left_w, X_MOVE_right_w, X_center_before_w

always@(posedge clk or negedge rst) begin
	if(!rst) begin
		//X_MOVE_right_r <= 10'b0;
		//X_MOVE_left_r <= 10'b0;
		Y_MOVE_down_r <= 10'b0;
		Y_MOVE_up_r <= 10'b0;
		//X_center_before_r <= 10'b0;
		Y_center_before_r <= 10'b0;
	end else begin
		//X_MOVE_right_r <= X_MOVE_right_w;
		//X_MOVE_left_r <= X_MOVE_left_w;
		Y_MOVE_down_r <= Y_MOVE_down_w;
		Y_MOVE_up_r <= Y_MOVE_up_w;
		//X_center_before_r <= X_center_before_w;
		Y_center_before_r <= Y_center_before_w;
		if(Y_MOVE_down_w > 2) begin
			down_detected = 1'b1;
		end else begin
			down_detected = 1'b0;
		end
	end
end

always @(*) begin
	//X_MOVE_right_w = X_MOVE_right_r;
	//X_MOVE_left_w = X_MOVE_left_r;
	Y_MOVE_up_w = Y_MOVE_up_r;
	Y_MOVE_down_w = Y_MOVE_down_r;
	//X_center_before_w = X_center_before_r;
	Y_center_before_w = Y_center_before_r;

	if(ready) begin
		/*if(X_center > X_center_before_r) begin
			X_MOVE_right_w = (X_center - X_center_before_r) << 1;
			X_MOVE_left_w = 10'b0;
		end else begin
			X_MOVE_left_w = (X_center_before_r - X_center) << 1;
			X_MOVE_right_w = 10'b0;
		end*/
		if(Y_center < Y_center_before_r) begin
			Y_MOVE_down_w = Y_MOVE_down_r + 1'b1;
			Y_MOVE_up_w = 10'b0;
		end else begin
			Y_MOVE_up_w = Y_MOVE_up_r + 1'b1;
			Y_MOVE_down_w = 10'b0;
		end
		//X_center_before_w = X_center;
		Y_center_before_w = Y_center;
	end

end