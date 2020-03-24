`include "../define.sv"

module brick(
    input     clk,
    input     rst_n,
    input      [17:0] SW,
    input      [`PIXELX_BIT_CNT-1:0]    DrawX,
    input      [`PIXELY_BIT_CNT-1:0]    DrawY,
    input      [`PIXELX_BIT_CNT-1:0]    i_br_ballX,
    input      [`PIXELY_BIT_CNT-1:0]    i_br_ballY,
    input      [`BALL_SIZE_BIT_CNT-1:0]i_br_ball_size,
    input      [1:0]                   i_br_speedX, // 2 bit 00 == 0, 11 == -1, 01 == 1
    input      [1:0]                   i_br_speedY,
    input                              i_br_damage,
    input                              i_down,
    output                               o_br_gadget_gen,
    output                               o_ball_brick_collision,
    output       [`DIR_BIT_CNT-1:0]      o_direc_var,

    output                               o_brick_ack,
    output   logic  [3:0]                     is_brick, //0 is no brick, else number = brick type
    input     logic                         i_brick_req,
    input  brick_game_start,
    output  logic brick_next_stage,
    input  [2:0] life_count,
    input  brick_death, //if player is dead
    output logic [3:0] o_gadget_type,
    output logic o_win,
    output logic [2:0] o_stage_num,
    output logic [2:0] LEDR //debug
);


logic [3:0] org_mem [0:399]; //the original map that should not be edit after initial
logic [3:0] mem [0:399];
logic [3:0] mem_next [0:399];

logic [3:0] org_mem_1 [0:399];
logic [3:0] org_mem_2 [0:399]; 


logic [3:0] gadget_org_mem [0:399]; //the original map that should not be edit after initial
logic [3:0] gadget_org_mem1 [0:399]; 
logic [3:0] gadget_org_mem2 [0:399]; 
logic [3:0] gadget_mem [0:399];
logic [3:0] gadget_mem_next [0:399];

logic [3:0] logo [0:399];

logic [3:0] win [0:399];
logic [3:0] lose [0:399];

logic [3:0] gadget_type, gadget_type_next;
logic start; // game start, restart, load orginal map
logic collision,collision_next;
logic gadget_gen, gadget_gen_next;
int x_num, y_num,mem_num;
int ball_left_up_x, ball_righ_up_x, ball_left_dw_x, ball_righ_dw_x;
int ball_left_up_y, ball_righ_up_y, ball_left_dw_y, ball_righ_dw_y;
int mem_left_up, mem_righ_up, mem_left_dw, mem_righ_dw;
logic [`DIR_BIT_CNT-1:0] direction,direction_next;
logic [3:0] four_point;
logic ack,ack_next;
logic request;
logic [2:0] stage_num, stage_num_next;

assign o_brick_ack = ack;
assign LEDR[0] = !brick_next_stage;
assign o_stage_num = stage_num;

initial begin
	$readmemh("./sprite_bytes/map0.txt", org_mem);
  $readmemh("./sprite_bytes/map1.txt", org_mem_1);
  $readmemh("./sprite_bytes/map2.txt", org_mem_2);
  $readmemh("./sprite_bytes/LOGO.txt", logo);
  $readmemh("./sprite_bytes/gadget_0.dat", gadget_org_mem);
  $readmemh("./sprite_bytes/gadget_1.dat", gadget_org_mem1);
  $readmemh("./sprite_bytes/gadget_2.dat", gadget_org_mem2);
  $readmemh("./sprite_bytes/win.txt", win);
  $readmemh("./sprite_bytes/lose.txt", lose);
end

assign o_ball_brick_collision = collision;
assign o_direc_var = direction;
assign o_gadget_type = gadget_type;
assign o_br_gadget_gen = gadget_gen;

//Turn ball position into brick-coordinate
assign ball_left_up_x = (i_br_ballX - i_br_ball_size) >> 5;
assign ball_left_up_y = (i_br_ballY - i_br_ball_size) >> 4;
assign ball_righ_up_x = (i_br_ballX + i_br_ball_size) >> 5;
assign ball_righ_up_y = (i_br_ballY - i_br_ball_size) >> 4;
assign ball_left_dw_x = (i_br_ballX - i_br_ball_size) >> 5;
assign ball_left_dw_y = (i_br_ballY + i_br_ball_size) >> 4;
assign ball_righ_dw_x = (i_br_ballX + i_br_ball_size) >> 5;
assign ball_righ_dw_y = (i_br_ballY + i_br_ball_size) >> 4;

assign mem_left_up = ball_left_up_x + ball_left_up_y * 20;
assign mem_righ_up = ball_righ_up_x + ball_righ_up_y * 20;
assign mem_left_dw = ball_left_dw_x + ball_left_dw_y * 20;
assign mem_righ_dw = ball_righ_dw_x + ball_righ_dw_y * 20;


always_comb //brick collision detection
begin
  mem_next = mem;
  if(i_brick_req == 1'b1 && ack == 1'b0 ) ack_next = 1'b1;
  else ack_next = 1'b0;

  stage_num_next = stage_num;

  if(all_zero(mem))brick_next_stage = 1;
  else brick_next_stage = 0;

  o_win = 0;
	LEDR[2:1] = 2'b00;
  case(stage_num)
    3'd0:
    begin
      if(i_down)begin
        stage_num_next = stage_num + 3'd1;
        mem_next = org_mem;

      end
    end
    3'd1:
    begin
      if(brick_next_stage == 1)begin
        stage_num_next = stage_num + 3'd1;
        mem_next = org_mem_1;
      
      end
    end
    3'd2:
    begin
      if(brick_next_stage == 1)begin
        stage_num_next = stage_num + 3'd1; //end game, WIN!
        mem_next = win;
        o_win = 1;
      end
	end
    3'd3:
    begin
      if(brick_next_stage == 1)begin
        stage_num_next = 0;
        mem_next = org_mem;
      end
    end
  endcase

  collision_next = 0;
  four_point = 4'd0; //0000
  direction_next = `DIR_BIT_CNT'd0;
  if(i_brick_req == 1'b1 && ack == 1'b0)
  begin
    if(mem[mem_left_up] > 4'd0 && mem_left_up < 400)
    begin
      if(i_br_damage)mem_next[mem_left_up] = 0;
      else
      begin
        mem_next[mem_left_up] = mem[mem_left_up] - 4'd1;//collision, life - 1
        collision_next = 1;
        four_point[0] = 1;
      end
    end
    else mem_next[mem_left_up] = mem[mem_left_up];
    if(mem[mem_righ_up] > 4'd0 && mem_righ_up < 400)
      begin
        if(i_br_damage)mem_next[mem_righ_up] = 0;
        else
        begin
          mem_next[mem_righ_up] = mem[mem_righ_up] - 4'd1;
          collision_next = 1;
          four_point[1] = 1;
        end 
      end 
    else mem_next[mem_righ_up] = mem[mem_righ_up];
    if(mem[mem_left_dw] > 4'd0 && mem_left_dw < 400)
      begin
        if(i_br_damage)mem_next[mem_left_dw] = 0;
        else
        begin
          mem_next[mem_left_dw] = mem[mem_left_dw] - 4'd1;
          collision_next = 1;
          four_point[2] = 1;
        end
      end 
    else mem_next[mem_left_dw] = mem[mem_left_dw];
    if(mem[mem_righ_dw] > 4'd0 && mem_righ_dw < 400)
      begin
        if(i_br_damage)mem_next[mem_righ_dw] = 0;
        else
        begin
          mem_next[mem_righ_dw] = mem[mem_righ_dw] - 4'd1;
          collision_next = 1;
          four_point[3] = 1;
        end
      end 
    else mem_next[mem_righ_dw] = mem[mem_righ_dw];
    if(SW[17]) mem_next = org_mem_2;

    if(life_count == 3'd0)begin
      mem_next = lose;
    end 
      /*
    0...1
    .....
    2...3
    */
    case(four_point)
      4'b0111: direction_next = `DIR_BIT_CNT'd19;
      4'b1011: direction_next = `DIR_BIT_CNT'd19;
      4'b1101: direction_next = `DIR_BIT_CNT'd19;
      4'b1110: direction_next = `DIR_BIT_CNT'd19;

      4'b0101: direction_next = `DIR_BIT_CNT'd18;
      4'b1010: direction_next = `DIR_BIT_CNT'd18;
      4'b0011: direction_next = `DIR_BIT_CNT'd19;
      4'b1100: direction_next = `DIR_BIT_CNT'd19;

      4'b0001: direction_next = `DIR_BIT_CNT'd19;
      4'b0010: direction_next = `DIR_BIT_CNT'd19;
      4'b0100: direction_next = `DIR_BIT_CNT'd19;
      4'b1000: direction_next = `DIR_BIT_CNT'd19;
      default: direction_next = `DIR_BIT_CNT'd0;
    endcase  
  end 
end

always_comb //check brick, is the VGA reading a brick?
begin
    x_num = DrawX >> 5; //transform real coordinate into brick coordinate
    y_num = DrawY >> 4;
    mem_num = y_num * 20 + x_num;
  if(mem[mem_num] > 4'd0 && DrawY < 9'd320 && x_num != 0 && x_num != 19)is_brick = mem[mem_num];
  else is_brick = 0;
end

always_comb //gadget collision detection
begin

 
  gadget_mem_next = gadget_mem;
  gadget_gen_next = 0;
  gadget_type_next = gadget_type;
  case(stage_num)
    3'd0:
    begin
      if(i_down)begin

        gadget_mem_next = gadget_org_mem;

      end
    end
    3'd1:
    begin
      if(brick_next_stage == 1)begin
      
        gadget_mem_next = gadget_org_mem1;
      end
    end
  endcase
  if(i_brick_req == 1'b1 && ack == 1'b0)
  begin
    if(gadget_mem[mem_left_up] > 4'd0 && mem_left_up < 400)
    begin
      gadget_mem_next[mem_left_up] = 0;
      gadget_gen_next = 1;
      gadget_type_next= gadget_mem[mem_left_up];
    end
    else gadget_mem_next[mem_left_up] = gadget_mem[mem_left_up];
    if(gadget_mem[mem_righ_up] > 4'd0 && mem_righ_up < 400)
      begin
        gadget_mem_next[mem_righ_up] = 0;
        gadget_gen_next = 1;
        gadget_type_next = gadget_mem[mem_righ_up];
      end 
    else gadget_mem_next[mem_righ_up] = gadget_mem[mem_righ_up];
    if(gadget_mem[mem_left_dw] > 4'd0 && mem_left_dw < 400)
      begin
        gadget_mem_next[mem_left_dw] = 0;
        gadget_gen_next = 1;
        gadget_type_next = gadget_mem[mem_left_dw];
      end 
    else gadget_mem_next[mem_left_dw] = gadget_mem[mem_left_dw];
    if(gadget_mem[mem_righ_dw] > 4'd0 && mem_righ_dw < 400)
      begin
        gadget_mem_next[mem_righ_dw] = 0;
        gadget_gen_next = 1;
        gadget_type_next = gadget_mem[mem_righ_dw];
      end 
    else gadget_mem_next[mem_righ_dw] = gadget_mem[mem_righ_dw];
  end 
	case(stage_num)
    3'd0:
    begin
      if(i_down)begin
        gadget_mem_next = gadget_org_mem;
      end
    end
    3'd1:
    begin
      if(brick_next_stage == 1)begin
        gadget_mem_next = gadget_org_mem1;
      end
    end
  endcase

  if(SW[17]) gadget_mem_next = gadget_org_mem2;
  
  end

always_ff @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    begin
      mem <= logo; // game reset
      gadget_mem <= gadget_org_mem;
      ack <= 1'b0;
      collision <= 0;
      direction <= 0;
      gadget_gen <= 0;
      gadget_type <= 0;
      stage_num <= 0;
    end
  else
    begin
      mem <= mem_next;
      gadget_mem <= gadget_mem_next;
      ack <= ack_next;
      collision <= collision_next;
      direction <= direction_next;
      gadget_gen <= gadget_gen_next;
      gadget_type <= gadget_type_next;
      stage_num <= stage_num_next;
    end
end

function all_zero (input [1:0] in [0:399]);
    for (int i=0; i<400; i++) 
      begin
          if (in[i] != 4'd0) return 0;
      end
    return 1; //all bricks are terminated
endfunction



endmodule