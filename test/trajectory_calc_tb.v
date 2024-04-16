`default_nettype none `timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module trajectory_calc_tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("trajectory_calc_tb.vcd");
    $dumpvars(0, trajectory_calc_tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg [4:0] xpos;
  reg [4:0] rise_in;
  reg [4:0] run_in;
  reg shoot;
  reg [4:0] target_x;
  reg [4:0] target_y;
  reg direction_in;
  reg clk;
  reg rst;
  wire result_valid;
  wire hit;
  wire [4:0] positionx;


  // Replace tt_um_example with your module name:
  trajectory_calc tc (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
      .xpos    (xpos),      // Dedicated inputs
      .rise_in (rise_in),   // Dedicated outputs
      .run_in  (run_in),    // IOs: Input path
      .shoot   (shoot),     // IOs: Output path
      .target_x(target_x),  // IOs: Enable path (active high: 0=input, 1=output)
      .target_y(target_y),  // enable - goes high when design is selected
      .clk     (clk),       // clock
      .rst     (rst),       // not reset
      .result_valid(result_valid),
      .hit      (hit),
      .positionx(positionx),
      .direction_in(direction_in)
  );

endmodule
