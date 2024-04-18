module controls(
    input clk,
    input reset,
    input move_left,
    input move_right,
    input aim_left,
    input aim_right,
    input shoot,
    input start_new_game,
    output reg left_x,
    output reg right_x,
    output reg left_aim,
    output reg right_aim,
    output reg shoot_out,
    output reg [4:0] select
);

    reg [3:0] sum;

    always @(posedge clk) begin
        if (reset | start_new_game) begin
            // Reset all outputs
            left_x = 1'b0;
            right_x = 1'b0;
            left_aim = 1'b0;
            right_aim = 1'b0;
            shoot_out = 1'b0;
            select = 5'b00000;
        end else begin
            sum = move_left + move_right + aim_left + aim_right + shoot;
            // if more than one button are pressed. Don't respond.
            if (sum > 1) begin
                left_x = 1'b0;
                right_x = 1'b0;
                left_aim = 1'b0;
                right_aim = 1'b0;
                shoot_out = 1'b0;
                select = 5'b00000;
            // only one button was pressed. Assign accordingly. 
            end else begin
                shoot_out = shoot;
                left_x = move_left;
                right_x = move_right;
                left_aim = aim_left;
                right_aim = aim_right;
                // Assign select signal
                if (move_left | move_right) begin
                    select = 5'b10000;
                end else if (aim_left | aim_right) begin
                    select = 5'b01000;
                end else begin
                    select = 5'b00000;
                end
            end
        end
    end
endmodule
