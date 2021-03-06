module keyboard_gamepadX(
    input           i_clk,
    input           i_rst_n,
    input   [7:0]   i_key,
    output  [9:0]   o_platX,
    output          o_shoot,
    output          o_use_gadget,
    output          o_debug_shoot
);
    logic   [9:0]   platX,  n_platX;
    logic           shoot,  n_shoot;
    logic           use_gadget, n_use_gadget;  
    logic           debug_shoot, n_debug_shoot;   

    assign  o_platX =   platX;
    assign  o_shoot =   shoot;
    assign  o_use_gadget = use_gadget;
    assign  o_debug_shoot = debug_shoot;

    always_comb begin
        n_platX =       platX;
        n_shoot =       shoot;
        n_use_gadget =  use_gadget;  
        n_debug_shoot = debug_shoot;
        case(i_key)
            8'h1D:begin //up
                n_shoot = 1;
                n_debug_shoot = !debug_shoot;
            end
            8'h1B:begin //down
                n_use_gadget = 1;
            end
            8'h1C:begin //left
                if(platX < 10'd10) n_platX = 10'd0;
                else n_platX = platX - 10'd10;
            end
            8'h23:begin //right
                if(platX > 10'd630) n_platX = 10'd639;
                else n_platX = platX + 10'd10;
            end
        endcase
        if(shoot == 1'b1) n_shoot = 0;
        if(use_gadget == 1'b1) n_use_gadget = 0;
    end

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if(!i_rst_n) begin
            platX       <= 10'd320;
            shoot       <= 1'b0;
            use_gadget  <= 1'b0;
            debug_shoot <= 1'b0;
        end
        else begin
            platX       <=  n_platX;
            shoot       <=  n_shoot;
            use_gadget  <=  n_use_gadget;  
            debug_shoot <=  n_debug_shoot;
        end
    end

endmodule