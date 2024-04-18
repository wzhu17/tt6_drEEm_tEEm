module controls(
    input clk,
    input reset,
    input move_left,
    input move_right,
    input aim_left,
    input aim_right,
    input shoot,
    input start_new_game,
    output wire left_x,
    output wire right_x,
    output wire left_aim,
    output wire right_aim,
    output wire shoot_out,
    output reg [4:0] select
);
    wire [3:0] sum;
    wire start_new_game_intermediate;
    wire start_new_game_final;
    assign sum = {3'b0, move_left} + {3'b0, move_right} + {3'b0, aim_left} + {3'b0, aim_right + shoot};
    wire en = sum < 2;

    one_pulse move_left_reg(.clk(clk), .reset(reset), .en(en), .in(move_left), .out(left_x));
    one_pulse move_right_reg(.clk(clk), .reset(reset), .en(en), .in(move_right), .out(right_x));
    one_pulse left_aim_reg(.clk(clk), .reset(reset), .en(en), .in(aim_left), .out(left_aim));
    one_pulse right_aim_reg(.clk(clk), .reset(reset), .en(en), .in(aim_right), .out(right_aim));
    one_pulse shoot_reg(.clk(clk), .reset(reset), .en(en), .in(shoot), .out(shoot_out));

    dff new_game(.clk(clk), .d(start_new_game), .q(start_new_game_intermediate));
    dff duummy(.clk(clk), .d(start_new_game_intermediate), .q(start_new_game_final));

    always @(*) begin
        if (sum < 2) begin
            if (move_left | move_right) begin
                select = 5'b10000;
            end else if (aim_left | aim_right) begin
                select = 5'b01000;
            end else if (start_new_game == 1) begin
                select = 5'b00100;
            end else if (start_new_game_final == 1) begin
                select = 5'b00010;
            end else begin
                select = 5'b00000;
            end
        end else begin
            select = 5'b00000;
        end
    end


endmodule
