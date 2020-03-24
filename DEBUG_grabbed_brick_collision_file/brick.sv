`include "define.sv"

module brick(
    input     clk,
    input     rst_n,
    input      [`PIXELX_BIT_CNT-1:0]    DrawX,
    input      [`PIXELY_BIT_CNT-1:0]    DrawY,
    input      [`PIXELX_BIT_CNT-1:0]    i_br_ballX,
    input      [`PIXELY_BIT_CNT-1:0]    i_br_ballY,
    input      [`BALL_SIZE_BIT_CNT-1:0]i_br_ball_size,
    input      [1:0]                   i_br_speedX, // 2 bit 00 == 0, 11 == -1, 01 == 1
    input      [1:0]                   i_br_speedY,
    input      [1:0]                   i_br_damage,
    output                               o_br_gadget_gen,
    output                               o_ball_brick_collision,
    output       [`DIR_BIT_CNT-1:0]      o_direc_var,

    output                               o_brick_ack,
    output   logic  [1:0]                     is_brick, //0 is no brick, else number = brick type
    input                              i_brick_req,
    input  brick_game_start,
    output  logic brick_next_stage,
    input  brick_death, //if player is dead
    output logic [8:0] LEDG //debug
);

assign LEDG[0] = brick_next_stage;
assign LEDG[1] = brick_next_stage;
assign LEDG[2] = brick_next_stage;
assign LEDG[3] = brick_next_stage;

logic [1:0] org_mem [0:399]; //the original map that should not be edit after initial
logic [1:0] mem [0:399];
logic [1:0] mem_next [0:399];
logic [1:0] pixel;
logic start; // game start, restart, load orginal map
logic collision,collision_next;
int x_num, y_num,mem_num;
int ball_left_up_x, ball_righ_up_x, ball_left_dw_x, ball_righ_dw_x;
int ball_left_up_y, ball_righ_up_y, ball_left_dw_y, ball_righ_dw_y;
int mem_left_up, mem_righ_up, mem_left_dw, mem_righ_dw;
logic [`DIR_BIT_CNT-1:0] direction,direction_next;
logic [3:0] four_point;
logic ack,ack_next;
logic request;

assign o_brick_ack = ack;

initial begin
	$readmemh("brick.dat", org_mem);
end

assign o_ball_brick_collision = collision;
assign o_direc_var = direction;

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

always_comb //collision detection
begin
  if(i_brick_req == 1'b1 && ack == 1'b0) ack_next = 1'b1;
  else ack_next = 1'b0;

  if(all_zero(mem))brick_next_stage = 1;
  else brick_next_stage = 0;

  mem_next = mem;
  collision_next = 0;
  four_point = 0; //0000
  if(ack == 1'b0 && i_brick_req == 1'b1)
  begin
    if(mem[mem_left_up] > 2'd0 && mem_left_up < 400)
    begin
      mem_next[mem_left_up] = mem[mem_left_up] - 2'd1;//collision, life - 1
      collision_next = 1;
      four_point[0] = 1;
    end
  else mem_next[mem_left_up] = mem[mem_left_up];
  if(mem[mem_righ_up] > 2'd0 && mem_righ_up < 400)
    begin
      mem_next[mem_righ_up] = mem[mem_righ_up] - 2'd1;
      collision_next = 1;
      four_point[1] = 1;
    end 
  else mem_next[mem_righ_up] = mem[mem_righ_up];
  if(mem[mem_left_dw] > 2'd0 && mem_left_dw < 400)
    begin
      mem_next[mem_left_dw] = mem[mem_left_dw] - 2'd1;
      collision_next = 1;
      four_point[2] = 1;
    end 
  else mem_next[mem_left_dw] = mem[mem_left_dw];
  if(mem[mem_righ_dw] > 2'd0 && mem_righ_dw < 400)
    begin
      mem_next[mem_righ_dw] = mem[mem_righ_dw] - 2'd1;
      collision_next = 1;
      four_point[3] = 1;
    end 
  else mem_next[mem_righ_dw] = mem[mem_righ_dw];
  
  //if(collision)o_ball_brick_collision = 1;
  //else o_ball_brick_collision = 0;

  case(four_point)
  /*
  0...1
  .....
  2...3
  */
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
  if(mem[mem_num] > 2'd0 && DrawY < 9'd320 && x_num != 0 && x_num != 19)is_brick = mem[mem_num];
  else is_brick = 0;
end

always_ff @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    begin
      mem <= org_mem; // game reset
      ack <= 1'b0;
      collision <= 0;
      direction <= 0;
    end
  else
    begin
      mem <= mem_next;
      ack <= ack_next;
      collision <= collision_next;
      direction <= direction_next;
    end
end

function all_zero (input [1:0] in [0:399]);
    for (int i=0; i<400; i++) 
      begin
          if (in[i] != 2'd0) return 0;
      end
    return 1; //all bricks are terminated
endfunction



endmodule