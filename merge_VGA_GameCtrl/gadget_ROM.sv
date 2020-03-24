module  gadgetROM
(
		input logic [18:0] read_address,
		input logic [3:0] gadget_type,
		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses

logic [3:0] mem1 [0:1023];
logic [3:0] mem2 [0:1023];
logic [3:0] mem3 [0:1023];
logic [3:0] mem4 [0:1023];
logic [3:0] mem5 [0:1023];
logic [3:0] mem6 [0:1023];
logic [3:0] mem7 [0:1023];
logic [3:0] mem8 [0:1023];

initial
begin
	 $readmemh("sprite_bytes/g_big_ball.txt", mem7);
	 $readmemh("sprite_bytes/g_small_ball.txt", mem8);
	 $readmemh("sprite_bytes/g_faster.txt", mem4);
	 $readmemh("sprite_bytes/g_slower.txt", mem5);
	 $readmemh("sprite_bytes/g_fire.txt", mem6);//0~4: ball
	 $readmemh("sprite_bytes/g_big.txt", mem1);
	 $readmemh("sprite_bytes/g_grab.txt", mem3);
	 $readmemh("sprite_bytes/g_shrink.txt", mem2);//5~7: platform
end


always_comb
 begin
	case(gadget_type)
		4'd1: data_Out<= mem1[read_address];
		4'd2: data_Out<= mem2[read_address];
		4'd3: data_Out<= mem3[read_address];
		4'd4: data_Out<= mem4[read_address];
		4'd5: data_Out<= mem5[read_address];
		4'd6: data_Out<= mem6[read_address];
		4'd7: data_Out<= mem7[read_address];
		4'd8: data_Out<= mem8[read_address];
		default: data_Out<= 4'd0;
	endcase
end

endmodule