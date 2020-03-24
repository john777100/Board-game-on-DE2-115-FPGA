/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  ballROM
(
		input logic [18:0] read_address,
		input logic [1:0] ball_size,
		input				is_fire,
		output logic [3:0] data_Out
);

logic [3:0] mem0 [0:63]; // radius = 4
logic [3:0] mem1 [0:143]; // radius = 6
logic [3:0] mem2 [0:255]; // radius = 8
logic [3:0] mem3 [0:255];

initial
begin
	 $readmemh("sprite_bytes/ball_4.txt", mem0);
	 $readmemh("sprite_bytes/ball_6.txt", mem1);
	 $readmemh("sprite_bytes/ball_8.txt", mem2);
	 $readmemh("sprite_bytes/fire_ball.txt", mem3);
end

always_comb
 begin
	if(is_fire) data_Out <= mem3[read_address];
	else
	begin
		if(ball_size == 2'd0) data_Out <= mem0[read_address];
		else if (ball_size == 2'd1) data_Out <= mem1[read_address];
		else data_Out <= mem2[read_address];
	end
end

endmodule
