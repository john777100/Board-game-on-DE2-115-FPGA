module game_TOP(
// Fundamental IO
    input   clk,
    input   rst,

// VGA



// VGA part
    input   VGA_frame_req,
    output  VGA_frame_ack,
// VGA request for ball
    output  ball_X,
    output  ball_Y,

    output  plat_X,
    output  play_Y,

    output  gadget_X,
    output  gadget_Y,  
    output  gadget_type


// Not sure how to implement the god damn brick display
/*
    output  brick...

*/



);



endmodule