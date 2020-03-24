/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  ballROM
(
		input logic [18:0] read_address,
		input logic [1:0] ball_size,
		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem0 [0:99]; // radius = 5
logic [3:0] mem1 [0:399]; // radius = 10
logic [3:0] mem2 [0:899]; // radius = 15

initial
begin
	 $readmemh("sprite_bytes/ball_5.txt", mem0);
	 $readmemh("sprite_bytes/ball_10.txt", mem1);
	 $readmemh("sprite_bytes/ball_15.txt", mem2);
end

always_comb
 begin
	if(ball_size == 2'd0) data_Out <= mem0[read_address];
	else if (ball_size == 2'd1) data_Out <= mem1[read_address];
	else data_Out <= mem2[read_address];
end

endmodule
