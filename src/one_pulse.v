//  one_pulse
//  26-Jan-2007 David Black-Schaffer
//   Simple one_pulse module.
//   Asserts out for one cycle when the input goes high.
//   Does nothing when it goes low.

module one_pulse(
    input clk,
    input reset,
    input en,
    input in,        // Input, which may go high for more than one cycle
    output reg out  // Output goes high for one cycle
);

    wire last_value;
    dffr last_value_storage(.clk(clk), .r(reset), .d(in), .q(last_value));
    
    always @(*) begin
        if (en) begin
            out = ~last_value & in;
        end else begin
            out = 0;
        end
    end

endmodule
