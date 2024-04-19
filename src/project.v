/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_ppca (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_oe  = 8'b11111111;
  assign uio_out[7] = target_y == 5'd31;
  assign uio_out[6:2] = target_x; 
  assign uio_out[1:0] = 2'd0;

  wire left_x, right_x, left_aim, right_aim, shoot;
  wire [4:0] select;

  controls control_inst (.ena(ena), .clk(clk), .reset(rst_n), .move_left(ui_in[0]),
    .move_right(ui_in[1]), .aim_left(ui_in[2]), .aim_right(ui_in[3]), .shoot(ui_in[4]),
      .start_new_game(ui_in[5]), .left_x(left_x), .right_x(right_x), .left_aim(left_aim),
       .right_aim(right_aim), .shoot_out(shoot), .select(select));

  wire [4:0] x_pos;
  wire dir; 
  wire [4:0] rise;
  wire [4:0] run;
  wire [2:0] aim_pos; 

  pos_aim pos_aim_inst (.ena(ena), .clk(clk), .reset(rst_n), .left_x(left_x), 
    .right_x(right_x), .left_aim(left_aim), .right_aim(right_aim), 
      .x_pos(x_pos), .dir(dir), .rise(rise), .run(run), .aim_pos(aim_pos));

  wire [4:0] target_x, target_y;
  wire [4:0] tc_pos; 
  wire result_valid, hit;

  trajectory_calc tc (.ena(ena), .x_pos(x_pos), .rise_in(rise), .run_in(run),    // IOs: Input path
    .shoot(shoot), .target_x(target_x), .target_y(target_y), .clk(clk), 
      .rst(rst_n), .result_valid(result_valid), .hit(hit), .positionx(tc_pos),
        .direction_in(dir));

  target_gen target_gen_inst (.ena(ena), .clk(clk), .reset(rst_n), .result_valid(result_valid),
   .target_x(target_x), .target_y(target_y), .start_new_game(ui_in[5]));      

  reg [4:0] temp_out; 
  assign uo_out[0] = result_valid;
  assign uo_out[1] = hit;
  assign uo_out[6:2] = temp_out;
  assign uo_out[7] = 0;
  always @(*) begin
    case(select)
      5'b10000 : begin
        temp_out = x_pos; // Cannon Position
      end
      5'b01000 : begin
        temp_out = {2'd0, aim_pos}; // Aim Position
      end
      5'b00100 : begin
        temp_out = target_y;
      end
      5'b00010 : begin
        temp_out = target_x; 
      end
      5'b00001 : begin
        temp_out = tc_pos; 
      end
      default : begin
        temp_out = x_pos;
      end
    endcase
  end
endmodule
