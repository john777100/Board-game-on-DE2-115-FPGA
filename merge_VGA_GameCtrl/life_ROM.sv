module  lifeROM
(
		input logic [18:0] read_address,
		input logic [2:0] life,
		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses

logic [3:0] mem1 [0:2999];
logic [3:0] mem2 [0:2999];
logic [3:0] mem3 [0:2999];

initial
begin
	 $readmemh("sprite_bytes/life1.txt", mem1);
	 $readmemh("sprite_bytes/life2.txt", mem2);
	 $readmemh("sprite_bytes/life3.txt", mem3);
end


always_comb
 begin
	case(life)
		3'd1: data_Out<= mem1[read_address];
		3'd2: data_Out<= mem2[read_address];
		3'd3: data_Out<= mem3[read_address];
		default: data_Out<= 3'd0;
	endcase
end

endmodule