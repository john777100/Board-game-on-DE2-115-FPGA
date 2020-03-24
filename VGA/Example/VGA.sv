module VGA(
	input CLK_50,
	input RST_N,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_HS,
	output VGA_VS,
	output VGA_CLK,
  output [10:0] X,
	output [10:0] Y
);
// Horizontal Parameter
parameter H_FRONT = 16;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_ACT   = 640;
parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

// Vertical Parameter
parameter V_FRONT = 11;
parameter V_SYNC  = 2;
parameter V_BACK  = 32;
parameter V_ACT   = 480;
parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

//wire CLK_25;
//wire CLK_to_DAC;
//wire RST_N;

//PLL pll0 (
//  .inclk0(CLOCK_50),
//  .c0(CLK_25)
//);

// Select DAC clock
//assign CLK_to_DAC = CLK_25;
assign VGA_SYNC  = 1'b0;        // This pin is unused.
assign VGA_BLANK_N = ~(H_Cont<H_BLANK)||(V_Cont<V_BLANK);
//assign VGA_CLK   = ~CLK_50; // Invert internal clock to output clock
//assign RST_N     = KEY[0];      // Set reset signal is KEY[0]

reg [10:0] H_Cont;
reg [10:0] V_Cont;
reg [7:0]  vga_r;
reg [7:0]  vga_g;
reg [7:0]  vga_b;
reg        vga_hs;
reg        vga_vs;
//reg [10:0] X;
//reg [10:0] Y;

reg        vga_clk;

assign VGA_R = vga_r;
assign VGA_G = vga_g;
assign VGA_B = vga_b;
assign VGA_HS = vga_hs;
assign VGA_VS = vga_vs;

assign VGA_CLK = vga_clk;

// Horizontal Generator: Refer to the pixel clock
always@(posedge VGA_CLK, negedge RST_N) begin
  if(!RST_N) begin
    H_Cont <= 0;
    vga_hs <= 1;
    X      <= 0;
  end 
  else begin
    if (H_Cont < H_TOTAL)
      H_Cont	<=	H_Cont+1'b1;
    else
      H_Cont	<=	0;
      
    // Horizontal Sync
    if(H_Cont == H_FRONT-1) // Front porch end
      vga_hs <= 1'b0;
      
    if(H_Cont == H_FRONT + H_SYNC -1) // Sync pulse end
      vga_hs <= 1'b1;

    // Current X
    if(H_Cont >= H_BLANK)
      X <= H_Cont-H_BLANK;
    else
      X <= 0;
  end
end

// Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS, negedge RST_N) begin
  if(!RST_N) begin
    V_Cont <= 0;
    vga_vs <= 1;
    Y      <= 0;
  end
  else begin
    if (V_Cont<V_TOTAL)
      V_Cont <= V_Cont + 1'b1;
    else
      V_Cont	<= 0;
      
    // Vertical Sync
    if (V_Cont == V_FRONT-1) // Front porch end
      vga_vs <= 1'b0;
      
    if (V_Cont == V_FRONT + V_SYNC-1) // Sync pulse end
      vga_vs <= 1'b1;
      
    // Current Y
    if (V_Cont >= V_BLANK)
      Y <= V_Cont-V_BLANK;
    else
      Y <= 0;
  end
end

// Pattern Generator
always@(posedge VGA_CLK, negedge RST_N) begin
  if(!RST_N) begin
    vga_r <= 0;
    vga_g <= 0;
    vga_b <= 0;
  end
  else begin
    vga_r <= (Y < 120) ? 64 :
             (Y >= 120 && Y < 240) ? 128 :
             (Y >= 240 && Y < 360) ? 192 :
             255;
             
    vga_g <= (X < 80) ? 32 :
             (X >= 80  && X < 160) ? 64 :
             (X >= 160 && X < 240) ? 96 :
             (X >= 240 && X < 320) ? 128 :
             (X >= 320 && X < 400) ? 160 :
             (X >= 400 && X < 480) ? 192 :
             (X >= 480 && X < 560) ? 224 :
             255;
             
    vga_b <= (Y < 60) ? 255:
             (Y >= 60  && Y < 120) ? 224 :
             (Y >= 120 && Y < 180) ? 192 :
             (Y >= 180 && Y < 240) ? 160 :
             (Y >= 240 && Y < 300) ? 128 :
             (Y >= 300 && Y < 360) ? 96 :
             (Y >= 360 && Y < 420) ? 64 :
             32;
  end
end

always@(posedge CLK_50, negedge RST_N) begin
	if(!RST_N)
		vga_clk <= 0;
	else
		vga_clk <= vga_clk + 1;
end
endmodule