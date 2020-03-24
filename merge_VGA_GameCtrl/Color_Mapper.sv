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

// color_mapper: Decide which color to be output to VGA for each pixel.

module  color_mapper ( 
					   input 		clk,
					   input		rst_n,
                       input        [9:0] DrawX, DrawY,
					   input 		[9:0] ballX,
					   input 		[8:0] ballY,
					   input		is_fire,
					   input	[`PIXELX_BIT_CNT-1:0] 			GadgetX,
					   input	[`PIXELY_BIT_CNT-1:0] 			GadgetY,
					   input 	[`BALL_SIZE_BIT_CNT-1:0]		i_ball_size,
					   input	[`PIXELX_BIT_CNT-1:0] 			platX,
					   input	[`PIXELY_BIT_CNT-1:0] 			platY,
					   input	[7:0] 							platform_size,
					   input	[3:0] is_brick,
					   input 	[3:0] is_gadget,
					   input 	[2:0] i_stage_numb,
					   input 	[2:0] life_count,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
					   //output logic [8:0] LEDG //debug
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
	 logic[3:0] gadget_Out;
	 logic[3:0] life_Out;
	 logic[3:0] wall_Out;

	 logic [`BALL_SIZE_BIT_CNT-1:0] ball_size_rom;
	 logic [8:0] platY_VGA;
	 assign platY_VGA = platY + 9'd8;
	 //X 640  Y 480
	
	 int DistBallX, DistBallY;
	 int BrickX, BrickY;
	 int DistPlatX, DistPlatY;
	 int lifeX, lifeY;
	 //int GadgetX, GadgetY;
	 int DistGadgetX, DistGadgetY;
	 int ball_size;
	 int WallX;
	 assign ball_size_rom = (ball_size == `BALL_SIZE_BIT_CNT'd3)? 2'd0 : (ball_size == `BALL_SIZE_BIT_CNT'd5)? 2'd1 : 2'd2;
	 assign ball_size = (is_fire)?  7 : i_ball_size;

ballROM ball(
	.read_address( DistBallX + (DistBallY * (ball_size+1)*2)),
	.ball_size(ball_size_rom),
	.is_fire(is_fire),
	.data_Out(ball_Out)
);

platformROM platform(
	.clk(clk),
	.rst_n(rst_n),
	.read_address(DistPlatX + DistPlatY*platform_size*2),
	.platform_size(platform_size), //8-bit
	.data_Out(platform_Out)
);

brickROM brickROM(
	.clk(clk),
	.rst_n(rst_n),
	.read_address( BrickX + BrickY*32 ),
	.brick_type (is_brick),
	.data_Out(brick_Out)
);

gadgetROM gadget(
	.read_address( DistGadgetX + DistGadgetY * 32 ),
	.gadget_type(is_gadget), //3-bit
	.data_Out(gadget_Out)
);

lifeROM life(
		.read_address(lifeX + lifeY * 100),
		.life(life_count),
		.data_Out(life_Out)
);

wallROM wall(
	.read_address(DrawX),
	.data_Out(wall_Out)
);


/*
brick brick(
	.DrawX(DrawX),
	.DrawY(DrawY),
	.is_brick(is_brick)
);
*/
	always_comb
	begin
		if(DrawX > 10'd539 && DrawY > 10'd449)
		begin
			lifeX = DrawX - 10'd540;
			lifeY = DrawY - 10'd450;
		end
		else
		begin
			lifeX = 0;
			lifeY = 0;
		end
	end

    always_comb //judge if VGA is reading ball scope 
	begin
		BrickX = DrawX[4:0];
		BrickY = DrawY[3:0];
	
		if((DrawX + (ball_size+1)) > ballX && (DrawX - (ball_size+1)) < ballX && (DrawY + (ball_size+1)) > ballY && (DrawY - (ball_size+1)) < ballY)begin
			DistBallX = DrawX - ballX + (ball_size+1);
			DistBallY = DrawY - ballY + (ball_size+1);
		end
		else begin
			DistBallX = 0;
			DistBallY = 0;
		end
	end

	always_comb //judge if VGA is reading platform scope
	begin // TODO: the constant 128 should further be adjusted to platform size
		if((DrawX + platform_size) > platX && (DrawX) < platX + platform_size && (DrawY + 9'd8) > platY_VGA && (DrawY - 9'd8) < platY_VGA)begin
			DistPlatX = {2'b00,platform_size} + DrawX - platX;
			DistPlatY = 8 + DrawY - platY_VGA;
		end
		else begin
			DistPlatX = 0;
			DistPlatY = 0;
		end
	end

	always_comb //judge if VGA is reading gadget
	begin // TODO: the constant 128 should further be adjusted to platform size
		if((DrawX + 10'd16) > GadgetX && (DrawX) < GadgetX + 10'd16 && (DrawY + 10'd16) > GadgetY && (DrawY - 10'd16) < GadgetY)begin
			DistGadgetX = 16 + DrawX - GadgetX;
			DistGadgetY = 16 + DrawY - GadgetY;
		end
		else begin
			DistGadgetX = 0;
			DistGadgetY = 0;
		end
	end

	//assign LEDG[2] = brick_Out[0];//debug
	//assign LEDG[3] = brick_Out[1];

    // Assign color based on is_scope signal
    always_comb
    begin	
	 
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
			
			if(is_brick != 4'd0)
			begin
				case(is_brick)
					4'd1:
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
					4'd2:
					begin
						//Red = 8'h00;
						//Green = 8'h00;
						//Blue = 8'h00;
						case(brick_Out)
							
							4'd1:
							begin
								Red = 8'h97;
								Green = 8'h9F;
								Blue = 8'hEA;
							end
							4'd2:
							begin
								Red = 8'h2F;
								Green = 8'h3E;
								Blue = 8'hD5;
							end
							4'd3:
							begin
								Red = 8'h17;
								Green = 8'h1F;
								Blue = 8'h6A;
							end
							4'd4:
							begin
								Red = 8'h23;
								Green = 8'h2E;
								Blue = 8'h9E;
							end
						endcase
						
					end
					4'd4:
						begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
						end
						/*
						case(brick_Out)
							4'd1:
							begin
								Red = 8'hFF;
								Green = 8'hEF;
								Blue = 8'h3C;
							end
							4'd2:
							begin
								Red = 8'hFE;
								Green = 8'hF5;
								Blue = 8'h8C;
							end
							4'd3:
							begin
								Red = 8'hC5;
								Green = 8'hB9;
								Blue = 8'h2B;
							end
							4'd4:
							begin
								Red = 8'hAF;
								Green = 8'h77;
								Blue = 8'h26;
							end
							4'd5:
							begin
								Red = 8'h7F;
								Green = 8'h56;
								Blue = 8'h1C;
							end
						endcase */
					4'd3:
						case(brick_Out)
							4'd0:
							begin
								Red = 8'hFF;
								Green = 8'h00;
								Blue = 8'h00;
							end
							4'd1:
							begin
								Red = 8'hFF;
								Green = 8'h67;
								Blue = 8'h67;
							end
							4'd2:
							begin
								Red = 8'h7F;
								Green = 8'h00;
								Blue = 8'h00;
							end
							4'd3:
							begin
								Red = 8'hC5;
								Green = 8'h00;
								Blue = 8'h00;
							end
							4'd4:
							begin
								Red = 8'hED;
								Green = 8'hE4;
								Blue = 8'h4C;
							end
							4'd5:
							begin
								Red = 8'hED;
								Green = 8'hE3;
								Blue = 8'h48;
							end
							4'd6:
							begin
								Red = 8'h76;
								Green = 8'h71;
								Blue = 8'h24;
							end
							4'd7:
							begin
								Red = 8'hb7;
								Green = 8'haf;
								Blue = 8'h38;
							end
						endcase
				endcase
			end


			case(platform_size)
			8'd128:
			begin
				case(platform_Out)
				4'd1:
				begin
					Red = 8'h98;
					Green = 8'h93;
					Blue = 8'h93;
				end
				4'd2:
				begin
					Red = 8'h4A;
					Green = 8'h4A;
					Blue = 8'h4A;
				end
				4'd3:
				begin
					Red = 8'h3D;
					Green = 8'h92;
					Blue = 8'hAA;
				end
				4'd4:
				begin
					Red = 8'hC9;
					Green = 8'h16;
					Blue = 8'h16;
				end
				4'd5:
				begin
					Red = 8'hFF;
					Green = 8'hFF;
					Blue = 8'h00;
				end
			endcase
			end
			8'd64:
			begin
				case(platform_Out)
				4'd1:
				begin
					Red = 8'h38;
					Green = 8'h68;
					Blue = 8'h6D;
				end
				4'd2:
				begin
					Red = 8'h3B;
					Green = 8'h8D;
					Blue = 8'hAC;
				end
				4'd3:
				begin
					Red = 8'h2F;
					Green = 8'h5B;
					Blue = 8'h85;
				end
				4'd4:
				begin
					Red = 8'h35;
					Green = 8'hAC;
					Blue = 8'hE0;
				end
				4'd5:
				begin
					Red = 8'h3D;
					Green = 8'h92;
					Blue = 8'hAA;
				end
				4'd6:
				begin
					Red = 8'hFF;
					Green = 8'hFF;
					Blue = 8'hFF;
				end
			endcase
			end
			8'd32:
			begin
				case(platform_Out)
				4'd1:
				begin
					Red = 8'hFF;
					Green = 8'h32;
					Blue = 8'h00;
				end
				4'd2:
				begin
					Red = 8'h00;
					Green = 8'h5B;
					Blue = 8'hF3;
				end
				4'd3:
				begin
					Red = 8'hFF;
					Green = 8'hFF;
					Blue = 8'hFF;
				end
				4'd4:
				begin
					Red = 8'hD0;
					Green = 8'hD0;
					Blue = 8'hD0;
				end
				4'd5:
				begin
					Red = 8'h2B;
					Green = 8'h2A;
					Blue = 8'h2A;
				end
			endcase
			end
			8'd16:
			begin
				case(platform_Out)
				4'd1:
				begin
					Red = 8'h55;
					Green = 8'h25;
					Blue = 8'h04;
				end
				4'd2:
				begin
					Red = 8'hBF;
					Green = 8'hBF;
					Blue = 8'hC1;
				end
				4'd3:
				begin
					Red = 8'h47;
					Green = 8'h14;
					Blue = 8'h00;
				end
				4'd4:
				begin
					Red = 8'h85;
					Green = 8'h65;
					Blue = 8'h52;
				end
			endcase
			end
		endcase
			case(gadget_Out)
				4'd1:
				begin
					Red = 8'h80;
					Green = 8'hC5;
					Blue = 8'hA4;
				end
				4'd2:
				begin
					Red = 8'h00;
					Green = 8'h8B;
					Blue = 8'h49;
				end
				4'd3:
				begin
					Red = 8'h00;
					Green = 8'h65;
					Blue = 8'h35;
				end
				4'd4:
				begin
					Red = 8'h00;
					Green = 8'h45;
					Blue = 8'h24;
				end
				4'd5:
				begin
					Red = 8'hFF;
					Green = 8'hFF;
					Blue = 8'hFF;
				end
			endcase
					
		if(is_fire)
		begin
			case(ball_Out)
				4'd1:begin
					Red = 8'hF1;
					Green = 8'hF1;
					Blue = 8'hEA;
					end
				4'd2:begin
					Red = 8'h13;
					Green = 8'h14;
					Blue = 8'h0E;
					end
			endcase
		end
		else
		begin
			case(ball_Out)
				4'd1:begin
							Red = 8'hF1;
							Green = 8'hF1;
							Blue = 8'hEA;
							end
					4'd2:begin
							Red = 8'h13;
							Green = 8'h14;
							Blue = 8'h0E;
							end
				4'd3:begin
						Red = 8'hBC;
							Green = 8'hB6;
							Blue = 8'hA6;
				end
				4'd4:begin
						Red = 8'h1D;
							Green = 8'h1F;
							Blue = 8'h19;
				end
				
			endcase
		end

		case(wall_Out)
				4'd1:
				begin
					Red = 8'hFF;
					Green = 8'hFF;
					Blue = 8'hFF;
				end
				4'd2:
				begin
					Red = 8'hE5;
					Green = 8'hFF;
					Blue = 8'hFB;
				end
				4'd3:
				begin
					Red = 8'h8F;
					Green = 8'hFF;
					Blue = 8'hEE;
				end
				4'd4:
				begin
					Red = 8'h4B;
					Green = 8'hFF;
					Blue = 8'hE5;
				end
			endcase
			case(life_Out)
				4'd1:
				begin
					Red = 8'hFF;
					Green = 8'h00;
					Blue = 8'h00;
				end
			endcase

    end 
    
endmodule
