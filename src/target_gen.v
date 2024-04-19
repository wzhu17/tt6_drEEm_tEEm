module target_gen(
    input wire clk,
    input wire reset,
    input wire result_valid,
    input wire start_new_game, 
    input wire ena, 
    output wire [4:0] target_x,
    output wire [4:0] target_y
);

// RNG state and target generation logic
reg [7:0] rng_state = 0; 
wire [7:0] next_rng_state;
wire [4:0] next_target_x, next_target_y;

always @(*) begin 
    if (result_valid) begin
        rng_state = {next_rng_state[6:0], next_rng_state[7] ^ next_rng_state[5] ^ next_rng_state[4] ^ next_rng_state[3]};
    end 
    else if (reset) begin
        rng_state = 8'b01010101; 
    end
    else begin 
        rng_state = rng_state;
    end 
end

// Feedback taps are at bits 7, 5, 4, and 3

// Assign next target coordinates
assign next_target_y = {4'b0000, next_rng_state[0]} + 5'b11110;  // Randomly 0 or 1 for Y coordinate
assign next_target_x = next_rng_state[4:0]; // 5 bits for X coordinate, range 0 to 31

// RNG state register
dffre #(.WIDTH(8)) rng_register ( 
    .clk(clk),
    .r(reset),
    .en(start_new_game & ena),
    .d(rng_state),
    .q(next_rng_state)
);

// Target X coordinate register
dffre #(.WIDTH(5)) target_x_register (
    .clk(clk),
    .r(reset),
    .en(start_new_game & ena),
    .d(next_target_x),
    .q(target_x)
);

// Target Y coordinate register
dffre #(.WIDTH(5)) target_y_register (
    .clk(clk),
    .r(reset),
    .en(start_new_game & ena),
    .d(next_target_y),
    .q(target_y)
);

endmodule
