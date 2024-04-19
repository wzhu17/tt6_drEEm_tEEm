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
    input wire ena, 
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
        default : begin
            next_state = `IDLE;
        end
    endcase
end

// Logic for next x/y value
// TODO:
// take into account moving the rest forward before changing direction
// take into account intermediate values between larger rise/runs? 
wire [4:0] add_run; 
wire [4:0] sub_run;
assign add_run = cur_x + run;
assign sub_run = cur_x - run;

always @(*) begin
    case(state)
        `IDLE : begin
            next_x = shoot ? x_pos : 5'b0;
            next_y = 5'b0;
        end
        `CALCULATING : begin
            if (direction != next_direction && direction) next_x = 5'd31 - (add_run) - 1;
            else if (direction == next_direction && direction) next_x = add_run;
            else if (direction != next_direction && ~direction) next_x = run - cur_x; 
            else if (direction == next_direction && ~direction) next_x = sub_run; 
            else next_x = 5'd0;
            //next_x = direction ? cur_x + run : cur_x - run;
            next_y = cur_y + rise;
        end
        `DONE : begin
            next_x = 5'b0;
            next_y = 5'b0;
        end
        default: begin
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
        default : begin
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
                /*
                next_x > next_x + run ? ~direction : direction :
                next_x < next_x - run ? ~direction : direction;
                */
                cur_x > add_run ? ~direction : direction :
                cur_x < sub_run ? ~direction : direction;
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
        default : begin
            next_hit = 1'b0;
        end
    endcase
end

// Flip Flop for state
dffre #(2) state_ff(.clk(clk), .r(rst), .d(next_state), .q(state), .en(ena));
// Flip Flop for x_pos
dffre #(5) x_ff(.clk(clk), .r(rst), .d(next_x), .q(cur_x), .en(ena));
// Flip Flop for ypos
dffre #(5) y_ff(.clk(clk), .r(rst), .d(next_y), .q(cur_y), .en(ena));
// Flip Flop for rise
dffre #(5) rise_ff(.clk(clk), .r(rst), .d(next_rise), .q(rise), .en(ena));
// Flip Flop for run
dffre #(5) run_ff(.clk(clk), .r(rst), .d(next_run), .q(run), .en(ena));
// Flip Flop for hit ?
dffre #(1) hit_ff(.clk(clk), .r(rst), .d(next_hit), .q(hit), .en(ena));
// Flip Flop for direction
dffre #(1) direction_ff(.clk(clk), .r(rst), .d(next_direction), .q(direction), .en(ena));


assign result_valid = state == `DONE;
assign positionx = cur_x;
endmodule
