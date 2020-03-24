module  platformROM
(		
		input clk,
		input rst_n,
		input logic [18:0] read_address,
		input [7:0] platform_size,
		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem256_0 [0:4095]; //size = 64
logic [3:0] mem256_1 [0:4095]; //size = 64
logic [3:0] mem256_2 [0:4095]; //size = 64
logic [3:0] mem256_3 [0:4095]; //size = 64

logic [3:0] mem128_0 [0:2047]; //size = 64
logic [3:0] mem128_1 [0:2047]; //size = 64
logic [3:0] mem128_2 [0:2047]; //size = 64
logic [3:0] mem128_3 [0:2047]; //size = 64

logic [3:0] mem64_0  [0:1023];
logic [3:0] mem64_1  [0:1023];
logic [3:0] mem64_2  [0:1023];
logic [3:0] mem64_3  [0:1023];

logic [3:0] mem32_0  [0:511];
logic [3:0] mem32_1  [0:511];
logic [3:0] mem32_2  [0:511];
logic [3:0] mem32_3  [0:511];

logic [23:0] counter, counter_next;

initial
begin
	 $readmemh("sprite_bytes/plat256_0.txt", mem256_0);
	 $readmemh("sprite_bytes/plat256_1.txt", mem256_1);
	 $readmemh("sprite_bytes/plat256_2.txt", mem256_2);
	 $readmemh("sprite_bytes/plat256_3.txt", mem256_3);

	 $readmemh("sprite_bytes/plat128_0.txt", mem128_0);
	 $readmemh("sprite_bytes/plat128_1.txt", mem128_1);
	 $readmemh("sprite_bytes/plat128_2.txt", mem128_2);
	 $readmemh("sprite_bytes/plat128_3.txt", mem128_3);

	 $readmemh("sprite_bytes/plat64_0.txt", mem64_0);
	 $readmemh("sprite_bytes/plat64_1.txt", mem64_1);
	 $readmemh("sprite_bytes/plat64_2.txt", mem64_2);
	 $readmemh("sprite_bytes/plat64_3.txt", mem64_3);

	 $readmemh("sprite_bytes/plat32_0.txt", mem32_0);
	 $readmemh("sprite_bytes/plat32_1.txt", mem32_1);
	 $readmemh("sprite_bytes/plat32_2.txt", mem32_2);
	 $readmemh("sprite_bytes/plat32_3.txt", mem32_3);
end


always_comb
 begin
	counter_next = counter + 1;
	case(platform_size)
		8'd128:
		begin
			if(counter < 24'd4194304) data_Out = mem256_0[read_address];
			else if(counter < 24'd8388608) data_Out = mem256_1[read_address];
			else if(counter < 24'd12582912) data_Out = mem256_2[read_address];
			else data_Out = mem256_3[read_address];
		end
		8'd64:
		begin
			if(counter < 24'd4194304) data_Out = mem128_0[read_address];
			else if(counter < 24'd8388608) data_Out = mem128_1[read_address];
			else if(counter < 24'd12582912) data_Out = mem128_2[read_address];
			else data_Out = mem128_3[read_address];
		end
		8'd32:
		begin
			if(counter < 24'd4194304) data_Out = mem64_0[read_address];
			else if(counter < 24'd8388608) data_Out = mem64_1[read_address];
			else if(counter < 24'd12582912) data_Out = mem64_2[read_address];
			else data_Out = mem64_3[read_address];
		end
		8'd16:
		begin
			if(counter < 24'd4194304) data_Out = mem32_0[read_address];
			else if(counter < 24'd8388608) data_Out = mem32_1[read_address];
			else if(counter < 24'd12582912) data_Out = mem32_2[read_address];
			else data_Out = mem32_3[read_address];
		end
		default:
		begin
			data_Out = mem128_0[read_address];
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