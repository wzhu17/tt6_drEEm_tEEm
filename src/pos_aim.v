module pos_aim (
    input wire clk,
    input wire reset,
    input wire left_x,
    input wire right_x,
    input wire left_aim,
    input wire right_aim,
    input wire ena,
    output wire [4:0] x_pos,
    output wire [2:0] aim_pos,
    output reg [4:0] run,
    output reg [4:0] rise,
    output reg dir
);

    wire [4:0] next_x_pos = left_x ? x_pos == 5'd0 ? x_pos : x_pos - 1 :
                            right_x ? x_pos == 5'd31 ? x_pos : x_pos + 1 : 
                            x_pos;

    // x_pos
    dffre #(.WIDTH(5)) x_pos_reg (
        .clk(clk),
        .r(reset),
        .d(next_x_pos),
        .q(x_pos), 
        .en(ena)
    );
    
    wire [2:0] next_aim_pos = left_aim ? aim_pos == 3'd0 ? aim_pos : aim_pos - 1 :
                              right_aim ? aim_pos == 3'd6 ? aim_pos : aim_pos + 1 : 
                              aim_pos;

    // aim_pos
    dffre #(.WIDTH(3)) aim_pos_reg (
        .clk(clk),
        .r(reset),
        .d(next_aim_pos),
        .q(aim_pos), 
        .en(ena)
    );

    always @(*) begin
        case(aim_pos)
            3'd0: begin
                dir = 1'd0;
                run = 5'd2;
                rise = 5'd1;
            end
            3'd1: begin
                dir = 1'd0;
                run = 5'd1;
                rise = 5'd1;
            end
            3'd2: begin
                dir = 1'd0;
                run = 5'd1;
                rise = 5'd2;
            end
            3'd3: begin
                dir = 1'd0;
                run = 5'd0;
                rise = 5'd1;
            end
            3'd4: begin
                dir = 1'd1;
                run = 5'd1;
                rise = 5'd2;
            end
            3'd5: begin
                dir = 1'd1;
                run = 5'd1;
                rise = 5'd1;
            end
            3'd6: begin
                dir = 1'd1;
                run = 5'd2;
                rise = 5'd1;
            end
            default: begin
                dir = 1'd0;
                run = 5'd0;
                rise = 5'd0;
            end
        endcase
    end

endmodule
