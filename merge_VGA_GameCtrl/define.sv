`define FPOSX_BIT_CNT 13
`define FPOSY_BIT_CNT 12
`define PIXELX_BIT_CNT 10
`define PIXELY_BIT_CNT 9
`define PIXEL_640 10'b1010000000
`define PIXEL_480 9'b111100000
`define WALL_THICKNESS 10       //PIXEL

/////Gadget
`define GADGET_SIZE 15
`define GADGET_BIT_CNT 4     
// NULL
`define GADGET_NULL 0
// for platform
`define EXPAND 4'd1
`define SHRINK 4'd2
`define GRAB 4'd3
// for ball
`define FASTER_BALL 4'd4
`define SLOWER_BALL 4'd5
`define FIRE_BALL 4'd6
`define BIGGER_BALL 4'd7
`define SMALLER_BALL 4'd8

/////Platform
`define PLAT_SIZE_NUM_BIT_CNT 3     // 5 kinds of half width
`define PLAT_HF_WIDTH_BIT_CNT 8     // 8, 16, 32, 64, 128   // PIXEL
`define PLAT_HF_HIGHT         20    // pixel
`define PLAT_PIXELY           440    // upper center of platform

/////Ball
//SPEED 
`define DIR_BIT_CNT 6       // POS
`define STEP_BIT_CNT 3       // POS 1~5
`define FSPEED_BIT_CNT 4    // FPOS with sign bit (2's)
//DAMAGE
`define DAM_BIT_CNT 3 
//SIZE
`define BALL_SIZE_NUM_BIT_CNT 2
`define BALL_SIZE_BIT_CNT 6 // PIXEL

/////Score
`define SCORE_BIT_CNT

/////Brick
`define BRICK_LIFE_BIT_CNT