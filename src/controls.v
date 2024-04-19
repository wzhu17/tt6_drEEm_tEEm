module controls(
    input clk,
    input reset,
    input move_left,
    input move_right,
    input aim_left,
    input aim_right,
    input shoot,
    input start_new_game,
    input ena,
    output wire left_x,
    output wire right_x,
    output wire left_aim,
    output wire right_aim,
    output wire shoot_out,
    output wire [4:0] select
);
    wire [3:0] sum;
    wire start_new_game_delayed;
    assign sum = {3'b0, move_left} + {3'b0, move_right} + {3'b0, aim_left} + {3'b0, aim_right + shoot};
    wire en = sum < 2;

    one_pulse move_left_reg(.clk(clk), .reset(reset), .en(en & ena), .in(move_left), .out(left_x));
    one_pulse move_right_reg(.clk(clk), .reset(reset), .en(en & ena), .in(move_right), .out(right_x));
    one_pulse left_aim_reg(.clk(clk), .reset(reset), .en(en & ena), .in(aim_left), .out(left_aim));
    one_pulse right_aim_reg(.clk(clk), .reset(reset), .en(en & ena), .in(aim_right), .out(right_aim));
    one_pulse shoot_reg(.clk(clk), .reset(reset), .en(en & ena), .in(shoot), .out(shoot_out));

    dffre new_game(.clk(clk), .d(start_new_game), .q(start_new_game_delayed), .r(reset), .en(ena));

    reg [4:0] next_select; 
    dffre #(5) select_ff (.clk(clk), .d(next_select), .q(select), .r(reset), .en(ena));

    always @(*) begin
        if (sum < 2) begin
            if (start_new_game_delayed == 1) begin
                next_select = 5'b00100;
            end else if (start_new_game == 1) begin
                next_select = 5'b00010;
            end else if (move_left | move_right) begin
                next_select = 5'b10000;
            end else if (aim_left | aim_right) begin
                next_select = 5'b01000;
            end else begin
                next_select = 5'b00000;
            end
        end else begin
            next_select = 5'b00000;
        end
    end


endmodule
