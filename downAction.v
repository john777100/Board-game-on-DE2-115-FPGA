module downAction(
					clk,
					rst,
					ready,
					X_center,
					Y_center,
					down_detected_r
					);

//`include "VGA_Param.h"
`define VGA_640x480p60
input clk;
input rst;
input ready;
input [9:0] X_center;
input [9:0] Y_center;
output reg	down_detected_r;

reg down_detected_w;
reg [9:0] buffer1_r, buffer1_w, buffer2_r, buffer2_w, buffer3_r, buffer3_w, buffer4_r, buffer4_w;
reg [9:0] xuffer1_r, xuffer1_w, xuffer2_r, xuffer2_w, xuffer3_r, xuffer3_w, xuffer4_r, xuffer4_w;
reg [3:0] cooldown_r, cooldown_w;

always@(posedge clk or negedge rst) begin
	if(!rst) begin
		down_detected_r <= 1'b0;
		cooldown_r <= 4'd0;
		buffer1_r <= 10'd0;
		buffer2_r <= 10'd0;
		buffer3_r <= 10'd0;
		buffer4_r <= 10'd0;
		xuffer1_r <= 10'd0;
		xuffer2_r <= 10'd0;
		xuffer3_r <= 10'd0;
		xuffer4_r <= 10'd0;
	end else begin
		down_detected_r <= down_detected_w;
		cooldown_r <= cooldown_w;
		buffer1_r <= buffer1_w;
		buffer2_r <= buffer2_w;
		buffer3_r <= buffer3_w;
		buffer4_r <= buffer4_w;
		xuffer1_r <= xuffer1_w;
		xuffer2_r <= xuffer2_w;
		xuffer3_r <= xuffer3_w;
		xuffer4_r <= xuffer4_w;
	end
end

always @(*) begin
	buffer1_w = Y_center;
	buffer2_w = buffer1_r;
	buffer3_w = buffer2_r;
	buffer4_w = buffer3_r;
	xuffer1_w = X_center;
	xuffer2_w = xuffer1_r;
	xuffer3_w = xuffer2_r;
	xuffer4_w = xuffer3_r;
	cooldown_w = cooldown_r;
	down_detected_w = 1'b0;

	if(ready) begin
		if(cooldown_r == 4'd6) begin
			cooldown_w = cooldown_r - 4'd1;
			down_detected_w = 1'b1;
		end else if(cooldown_r > 4'd0 && cooldown_r < 4'd6) begin
			cooldown_w = cooldown_r - 4'd1;
			down_detected_w = 1'b0;
		end else begin	
			if(X_center > xuffer4_r && buffer4_r < Y_center && Y_center - buffer4_r > 10'd24 && X_center - xuffer4_r < 10'd15) begin down_detected_w = 1'b1; cooldown_w = 4'd6; end
			else if(xuffer4_r > X_center && buffer4_r < Y_center && Y_center - buffer4_r > 10'd24 && xuffer4_r - X_center < 10'd15) begin down_detected_w = 1'b1; cooldown_w = 4'd6; end
		end
	end

end
endmodule