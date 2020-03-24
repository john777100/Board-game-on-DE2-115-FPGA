//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------
`include "../define.sv"
`include "../game_brick.sv"
`include "../ball.sv"
`include "../platform.sv"
// color_mapper: Decide which color to be output to VGA for each pixel.

module  color_mapper ( 
                       input        [9:0] DrawX, DrawY,
					   input 		[9:0] ballX,
					   input 		[8:0] ballY,
					   input	[`PIXELX_BIT_CNT-1:0] 			platX;
					   input	[`PIXELY_BIT_CNT-1:0] 			platY;
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
					   output logic [8:0] LEDG //debug
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

	 logic[3:0] sponge_Out;
	 logic[3:0] ball_Out;
	 logic[3:0] brick_Out;
	 logic[3:0] platform_Out;
	 logic is_brick;

	 //X 640  Y 480
	 int DistLivesX, DistLivesY , DistScoreX_1, DistScoreX_10, DistScoreY ,DistHomeX, DistHomeY;
	 int DistBallX, DistBallY;
	 int BrickX, BrickY;
	 int DistPlatX, DistPlatY;
    assign DistLivesX = DrawX - 20; // boundary
    assign DistLivesY = DrawY - 430; //
	assign DistScoreX_1 = DrawX - 590;
	assign DistScoreX_10 = DrawX - 565;
	assign DistScoreY = DrawY - 430;
	assign DistHomeX = DrawX - 400;
	assign DistHomeY = DrawY - 430;


ballROM ball(
	.read_address( DistBallX + (DistBallY * 20)),
	.ball_size(2'd1),
	.data_Out(ball_Out)
);

platformROM platform(
	.read_address(DistPlatX + DistPlatY*256),
	.platform_size(),
	.data_Out(platform_Out)
);

brickROM brickROM(
	.read_address( BrickX + BrickY*32 ),
	.data_Out(brick_Out)
);

brick brick(
	.DrawX(DrawX),
	.DrawY(DrawY),
	.is_brick(is_brick)
);

    always_comb //judge if VGA is reading ball scope 
	begin
		BrickX = DrawX[4:0];
		BrickY = DrawY[3:0];
	
		if((DrawX + 10'd10) > ballX && (DrawX - 10'd10) < ballX && (DrawY + 9'd10) > ballY && (DrawY - 9'd10) < ballY)begin
			DistBallX = DrawX - ballX + 10;
			DistBallY = DrawY - ballY + 10;
		end
		else begin
			DistBallX = 0;
			DistBallY = 0;
		end
	end

	always_comb //judge if VGA is reading platform scope
	begin // TODO: the constant 128 should further be adjusted to platform size
		if((DrawX + 10'd128) > platX && (DrawX - 10'd128) < platX && (DrawY + 9'd8) > platY && (DrawY - 9'd8) < platY)begin
			DistPlatX = DrawX - platX + 128;
			DistPlatY = DrawY - platY + 8;
		end
		else begin
			DistPlatX = 0;
			DistPlatY = 0;
		end
	end

	assign LEDG[2] = brick_Out[0];//debug
	assign LEDG[3] = brick_Out[1];

    // Assign color based on is_scope signal
    always_comb
    begin	
	 	LEDG[0] = 0;
		LEDG[1] = 0;
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
			case(platform_Out)
				4'd1:
				begin
					Red = 8'hE5;
					Green = 8'h41;
					Blue = 8'h41;
				end
				4'd2:
				begin
					Red = 8'hFD;
					Green = 8'hFE;
					Blue = 8'h5B;
				end
			endcase
			if(is_brick)
			begin
				case(brick_Out)
					4'd1:
					begin
						Red = 8'hBB;
						Green = 8'hBB;
						Blue = 8'hBB;
					end
					4'd2:
					begin
						Red = 8'h76;
						Green = 8'h76;
						Blue = 8'h76;
					end
					4'd3:
					begin
						Red = 8'h57;
						Green = 8'h57;
						Blue = 8'h57;
					end
					4'd4:
					begin
						Red = 8'h3B;
						Green = 8'h3B;
						Blue = 8'h3B;
					end
				endcase
			end
					
			case(ball_Out)
			
				4'd1:begin
							Red = 8'hE2;
							Green = 8'hE2;
							Blue = 8'hDA;
							end
					4'd2:begin
							Red = 8'h00;
							Green = 8'h00;
							Blue = 8'h00;
							end
				4'd3:begin
						Red = 8'hBD;
							Green = 8'hB6;
							Blue = 8'hA4;
				end
				4'd4:begin
						Red = 8'hED;
							Green = 8'hEE;
							Blue = 8'hE6;
				end
				4'd5:begin
						Red = 8'h99;
							Green = 8'h97;
							Blue = 8'h84;
				end
				
			
			endcase

    end 
    
endmodule
