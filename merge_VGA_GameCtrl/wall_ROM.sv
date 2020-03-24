module  wallROM
(
		input logic [18:0] read_address,
		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses

logic mem_0 [0:99];
logic mem_1 [0:99];

initial
begin
	 $readmemh("sprite_bytes/wall_left.txt", mem_0);
	 $readmemh("sprite_bytes/wall_righ.txt", mem_1);
end


always_comb
 begin
	if(read_address < 18'd10)
	begin
		data_Out = mem_0[read_address];
	end
	else if (read_address > 18'd628)
	begin
		data_Out = mem_1[read_address - 18'd629];
	end
	else data_Out = 0;
	 
end

endmodule