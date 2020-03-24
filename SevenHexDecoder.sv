`include "define.sv"

module SevenHexDecoder(
  input [12:0] i_addr, // SRAM address
  input is_light,
  input down_detected,
  input clk,
  input rst,
  //input [`GADGET_BIT_CNT-1:0] gadget_type,
  //input gadget_req,
  output logic [6:0] o_seven_ten,
  output logic [6:0] o_seven_one,
  output logic [6:0] o_seven_hun
  //output logic [6:0] o_seven_type,
  //output logic [6:0] o_seven_req
);

//=======================================================
//----------------Seven Segment Display------------------
//=======================================================

  /* The layout of seven segment display, 1: dark
   *    00
   *   5  1
   *    66
   *   4  2
   *    33
   */
  parameter D0 = 7'b1000000;
  parameter D1 = 7'b1111001;
  parameter D2 = 7'b0100100;
  parameter D3 = 7'b0110000;
  parameter D4 = 7'b0011001;
  parameter D5 = 7'b0010010;
  parameter D6 = 7'b0000010;
  parameter D7 = 7'b1011000;
  parameter D8 = 7'b0000000;
  parameter D9 = 7'b0010000;

//=======================================================
//----------------SRAM Address Invertal------------------
//=======================================================

  parameter S0  = 5'b00000;
  parameter S1  = 5'b00001;
  parameter S2  = 5'b00010;
  parameter S3  = 5'b00011;
  parameter S4  = 5'b00100;
  parameter S5  = 5'b00101;
  parameter S6  = 5'b00110;
  parameter S7  = 5'b00111;
  parameter S8  = 5'b01000;
  parameter S9  = 5'b01001;
  parameter S10 = 5'b01010;
  parameter S11 = 5'b01011;
  parameter S12 = 5'b01100;
  parameter S13 = 5'b01101;
  parameter S14 = 5'b01110;
  parameter S15 = 5'b01111;
  parameter S16 = 5'b10000;
  parameter S17 = 5'b10001;
  parameter S18 = 5'b10010;
  parameter S19 = 5'b10011;
  parameter S20 = 5'b10100;
  parameter S21 = 5'b10101;
  parameter S22 = 5'b10110;
  parameter S23 = 5'b10111;
  parameter S24 = 5'b11000;
  parameter S25 = 5'b11001;
  parameter S26 = 5'b11010;
  parameter S27 = 5'b11011;
  parameter S28 = 5'b11100;
  parameter S29 = 5'b11101;
  parameter S30 = 5'b11110;
  parameter S31 = 5'b11111;


  logic [9:0] addr_top5;
  logic [9:0] addr_top6;
  logic [9:0] addr_top7;
  logic [9:0] counter_r, counter_w;
  assign addr_top5 = i_addr/10'd100;
  assign addr_top6 = i_addr/10'd10 - addr_top5*10'd10;
  assign addr_top7 = counter_r - (counter_r/10'd10)*10'd10;
  
  always_ff @(posedge clk or negedge rst) begin
		if(!rst) begin
			counter_r <= 10'b0;
		end else begin
			counter_r <= counter_w;
		end
  end

  always_comb begin
  
		/*if(gadget_req == 1'b1) begin
			o_seven_req = D1;
			end else begin
			o_seven_req = D0;
			end
			
		if(gadget_type == 3'd1) begin
			o_seven_type = D1;
			end else begin
			o_seven_type = D0;
			end*/
  
  
		if(down_detected == 1'b1) begin
			//o_seven_one = D1;
			counter_w = counter_r + 1'b1;
		end
		else begin
			counter_w = counter_r;
		end
		
	 //o_seven_ten = D0;
	 if (i_addr < 20'd100) begin o_seven_hun = D0; end
	 else if (i_addr < 20'd200) begin o_seven_hun = D1; end
	 else if (i_addr < 20'd300) begin o_seven_hun = D2; end
	 else if (i_addr < 20'd400) begin o_seven_hun = D3; end
	 else if (i_addr < 20'd500) begin o_seven_hun = D4; end
	 else if (i_addr < 20'd600) begin o_seven_hun = D5; end
	 else begin o_seven_hun = D6; end
    /*if      ( S1 > addr_top5 && addr_top5 >= S0 ) begin o_seven_hun = D0; end
    else if ( S2 > addr_top5 && addr_top5 >= S1 ) begin o_seven_hun = D1; end
    else if ( S3 > addr_top5 && addr_top5 >= S2 ) begin o_seven_hun = D2; end
    else if ( S4 > addr_top5 && addr_top5 >= S3 ) begin o_seven_hun = D3; end
    else if ( S5 > addr_top5 && addr_top5 >= S4 ) begin o_seven_hun = D4; end
    else if ( S6 > addr_top5 && addr_top5 >= S5 ) begin o_seven_hun = D5; end
    else if ( S7 > addr_top5 && addr_top5 >= S6 ) begin o_seven_hun = D6; end
    else begin o_seven_hun = D7; end*/

    if      ( S1 > addr_top6 && addr_top6 >= S0 ) begin o_seven_ten = D0; end
    else if ( S2 > addr_top6 && addr_top6 >= S1 ) begin o_seven_ten = D1; end
    else if ( S3 > addr_top6 && addr_top6 >= S2 ) begin o_seven_ten = D2; end
    else if ( S4 > addr_top6 && addr_top6 >= S3 ) begin o_seven_ten = D3; end
    else if ( S5 > addr_top6 && addr_top6 >= S4 ) begin o_seven_ten = D4; end
    else if ( S6 > addr_top6 && addr_top6 >= S5 ) begin o_seven_ten = D5; end
    else if ( S7 > addr_top6 && addr_top6 >= S6 ) begin o_seven_ten = D6; end
    else if ( S8 > addr_top6 && addr_top6 >= S7 ) begin o_seven_ten = D7; end
    else if ( S9 > addr_top6 && addr_top6 >= S8 ) begin o_seven_ten = D8; end
    else if (S10 > addr_top6 && addr_top6 >= S9 ) begin o_seven_ten = D9; end
    else begin o_seven_ten = D0; end
	 
	 if      ( S1 > addr_top7 && addr_top7 >= S0 ) begin o_seven_one = D0; end
    else if ( S2 > addr_top7 && addr_top7 >= S1 ) begin o_seven_one = D1; end
    else if ( S3 > addr_top7 && addr_top7 >= S2 ) begin o_seven_one = D2; end
    else if ( S4 > addr_top7 && addr_top7 >= S3 ) begin o_seven_one = D3; end
    else if ( S5 > addr_top7 && addr_top7 >= S4 ) begin o_seven_one = D4; end
    else if ( S6 > addr_top7 && addr_top7 >= S5 ) begin o_seven_one = D5; end
    else if ( S7 > addr_top7 && addr_top7 >= S6 ) begin o_seven_one = D6; end
    else if ( S8 > addr_top7 && addr_top7 >= S7 ) begin o_seven_one = D7; end
    else if ( S9 > addr_top7 && addr_top7 >= S8 ) begin o_seven_one = D8; end
    else if (S10 > addr_top7 && addr_top7 >= S9 ) begin o_seven_one = D9; end
    else begin o_seven_one = D0; end


    /*else if (S12 > addr_top5 && addr_top5 >= S11) begin o_seven_ten = D1; o_seven_one = D1; end
    else if (S13 > addr_top5 && addr_top5 >= S12) begin o_seven_ten = D1; o_seven_one = D2; end
    else if (S14 > addr_top5 && addr_top5 >= S13) begin o_seven_ten = D1; o_seven_one = D3; end
    else if (S15 > addr_top5 && addr_top5 >= S14) begin o_seven_ten = D1; o_seven_one = D4; end
    else if (S16 > addr_top5 && addr_top5 >= S15) begin o_seven_ten = D1; o_seven_one = D5; end
    else if (S17 > addr_top5 && addr_top5 >= S16) begin o_seven_ten = D1; o_seven_one = D6; end
    else if (S18 > addr_top5 && addr_top5 >= S17) begin o_seven_ten = D1; o_seven_one = D7; end
    else if (S19 > addr_top5 && addr_top5 >= S18) begin o_seven_ten = D1; o_seven_one = D8; end
    else if (S20 > addr_top5 && addr_top5 >= S19) begin o_seven_ten = D1; o_seven_one = D9; end
    else if (S21 > addr_top5 && addr_top5 >= S20) begin o_seven_ten = D2; o_seven_one = D0; end
    else if (S22 > addr_top5 && addr_top5 >= S21) begin o_seven_ten = D2; o_seven_one = D1; end
    else if (S23 > addr_top5 && addr_top5 >= S22) begin o_seven_ten = D2; o_seven_one = D2; end
    else if (S24 > addr_top5 && addr_top5 >= S23) begin o_seven_ten = D2; o_seven_one = D3; end
    else if (S25 > addr_top5 && addr_top5 >= S24) begin o_seven_ten = D2; o_seven_one = D4; end
    else if (S26 > addr_top5 && addr_top5 >= S25) begin o_seven_ten = D2; o_seven_one = D5; end
    else if (S27 > addr_top5 && addr_top5 >= S26) begin o_seven_ten = D2; o_seven_one = D6; end
    else if (S28 > addr_top5 && addr_top5 >= S27) begin o_seven_ten = D2; o_seven_one = D7; end
    else if (S29 > addr_top5 && addr_top5 >= S28) begin o_seven_ten = D2; o_seven_one = D8; end
    else if (S30 > addr_top5 && addr_top5 >= S29) begin o_seven_ten = D2; o_seven_one = D9; end
    else if (S31 > addr_top5 && addr_top5 >= S30) begin o_seven_ten = D3; o_seven_one = D0; end
    else                                           begin o_seven_ten = D3; o_seven_one = D1; end*/
	 end
endmodule
