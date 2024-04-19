# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 10, units="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 10)
  dut.rst_n.value = 0
  # Set the input values, wait one clock cycle, and check the output
  await ClockCycles(dut.clk, 1)
  dut._log.info("Test")
  dut.ui_in.value = 1
  await ClockCycles(dut.clk, 10)
  dut.ui_in.value = 2
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 32
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, 10)
  dut.ui_in.value = 16
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, 50)
  dut.ui_in.value = 2
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 32
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, 1)
  
  for i in range(6): 
    dut.ui_in.value = 8
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)
  
  for i in range(19):
    dut.ui_in.value = 2
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)

  dut.ui_in.value = 16
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, 50)
