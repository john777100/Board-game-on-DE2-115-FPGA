module  brickROM
(
		input clk,
		input rst_n,
		input logic [18:0] read_address,
		input  [3:0] brick_type,
		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem1 [0:511];
logic [3:0] mem2 [0:511];
logic [3:0] mem3 [0:511];
logic [3:0] mem4_0 [0:511];
logic [3:0] mem4_1 [0:511];
logic [3:0] mem4_2 [0:511];
logic [3:0] mem4_3 [0:511];

logic [23:0] counter, counter_next;
initial
begin
	 $readmemh("sprite_bytes/brick.txt", mem1);//grey
	 $readmemh("sprite_bytes/brick_2.txt", mem2);//blue
	 $readmemh("sprite_bytes/brick_3.txt", mem3);
	 $readmemh("sprite_bytes/brick_3_0.txt", mem4_0);//shining
	 $readmemh("sprite_bytes/brick_3_1.txt", mem4_1);
	 $readmemh("sprite_bytes/brick_3_2.txt", mem4_2);
	 $readmemh("sprite_bytes/brick_3_3.txt", mem4_3);

end


always_comb
 begin
	counter_next = counter + 1;
	case(brick_type)
		4'd1:
		begin
			data_Out<= mem1[read_address];
		end
		4'd2:
		begin
			data_Out<= mem2[read_address];
		end
		4'd4:
		begin
			data_Out<= mem3[read_address];
		end
		4'd3:
			if(counter < 24'd4194304) data_Out = mem4_0[read_address];
			else if(counter < 24'd8388608) data_Out = mem4_1[read_address];
			else if(counter < 24'd12582912) data_Out = mem4_2[read_address];
			else data_Out = mem4_3[read_address];
		default:
		begin
			data_Out<= mem1[read_address];
		end
	endcase
end

always_ff @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		counter <= 0;
	end
	else
	begin
		counter <= counter_next;
	end
end

endmodule