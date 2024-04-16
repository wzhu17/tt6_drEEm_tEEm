# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 10, units="ns")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.xpos.value = 0
  dut.rise_in.value = 0
  dut.run_in.value = 0
  dut.rst.value = 0
  dut.shoot.value = 0
  dut.target_x = 0
  dut.target_y = 0
  dut.direction_in = 0
  dut.rst.value = 1
  await ClockCycles(dut.clk, 10)
  dut.rst.value = 0
  dut.rise_in = 1
  dut.run_in = 2
  dut.xpos = 16
  dut.target_x = 13
  dut.target_y = 3
  dut.shoot = 1
  await ClockCycles(dut.clk, 1)
  dut.shoot = 0

  # Set the input values, wait one clock cycle, and check the output
  '''
  dut._log.info("Test")
  dut.ui_in.value = 20
  dut.uio_in.value = 30
  '''
  await ClockCycles(dut.clk, 50)

  #assert dut.uo_out.value == 50
