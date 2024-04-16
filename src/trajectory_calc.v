`define default_netname none
`define IDLE 0
`define CALCULATING 1
`define DONE 2

module trajectory_calc (
    input wire [4:0] x_pos,
    input wire [4:0] rise_in,
    input wire [4:0] run_in,
    input wire direction_in, // Left(0) or right(1) initial trajectory? 
    input wire shoot,
    input wire [4:0] target_x,
    input wire [4:0] target_y,
    input wire clk,
    input wire rst,
    output wire result_valid,
    output wire hit,
    output wire [4:0] positionx
);

wire [4:0] cur_x, cur_y; 
reg [4:0] next_x, next_y; 
wire [1:0] state;
reg [1:0] next_state;
wire [4:0] rise, run;
reg [4:0] next_rise, next_run;
reg next_hit;
reg next_direction;
wire direction;

// Logic for next state
always @(*) begin
    case(state)
        `IDLE : begin
            next_state = shoot ? `CALCULATING : state;
        end
        `CALCULATING : begin
            // We can't check for y > target_y because of overflow
            next_state = cur_y > next_y ? `DONE : state;
        end
        `DONE : begin
            next_state = `IDLE;
        end
    endcase
end

// Logic for next x/y value
// TODO:
// take into account moving the rest forward before changing direction
// take into account intermediate values between larger rise/runs? 
always @(*) begin
    case(state)
        `IDLE : begin
            next_x = shoot ? x_pos : 5'b0;
            next_y = 5'b0;
        end
        `CALCULATING : begin
            next_x = direction ? cur_x + run : cur_x - run;
            next_y = cur_y + rise;
        end
        `DONE : begin
            next_x = 5'b0;
            next_y = 5'b0;
        end
    endcase
end

// Logic for rise/run
always @(*) begin
    case(state)
        `IDLE : begin
            next_rise = shoot ? rise_in : 5'b0;
            next_run = shoot ? run_in : 5'b0;
        end
        `CALCULATING : begin 
            next_rise = rise;
            next_run = run;
        end
        `DONE : begin
            next_rise = 5'b0;
            next_run = 5'b0;
        end
    endcase
end

// Lopic for direction
always @(*) begin
    case(state)
        `IDLE : begin
            next_direction = shoot ? direction_in : 1'b0;
        end
        `CALCULATING : begin 
            next_direction = direction ? 
                next_x > next_x + run ? ~direction : direction :
                next_x < next_x - run ? ~direction : direction;
        end
        `DONE : begin
            next_direction = 1'b0;
        end
        default : begin
            next_direction = direction;
        end
    endcase
end

// Logic for hit
always @(*) begin
    case(state)
        `IDLE : begin
            next_hit = 1'b0;
        end
        `CALCULATING : begin
            next_hit = cur_x == target_x && cur_y == target_y ? 1'b1 : hit;
        end
        `DONE : begin
            next_hit = 1'b0;
        end
    endcase
end

// Flip Flop for state
dffr #(2) state_ff(.clk(clk), .r(rst), .d(next_state), .q(state));
// Flip Flop for x_pos
dffr #(5) x_ff(.clk(clk), .r(rst), .d(next_x), .q(cur_x));
// Flip Flop for ypos
dffr #(5) y_ff(.clk(clk), .r(rst), .d(next_y), .q(cur_y));
// Flip Flop for rise
dffr #(5) rise_ff(.clk(clk), .r(rst), .d(next_rise), .q(rise));
// Flip Flop for run
dffr #(5) run_ff(.clk(clk), .r(rst), .d(next_run), .q(run));
// Flip Flop for hit ?
dffr #(1) hit_ff(.clk(clk), .r(rst), .d(next_hit), .q(hit));
// Flip Flop for direction
dffr #(1) direction_ff(.clk(clk), .r(rst), .d(next_direction), .q(direction));

assign result_valid = state == `DONE;
assign positionx = cur_x;
endmodule