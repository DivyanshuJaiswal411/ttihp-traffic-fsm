import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_traffic_light(dut):
    dut._log.info("Starting Traffic Light FSM test")

    # Set initial states
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Start a simulated clock (10 us period)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset the FSM
    dut._log.info("Applying reset...")
    dut.rst_n.value = 0
    await Timer(20, units="us")
    dut.rst_n.value = 1
    dut._log.info("Reset complete.")

    # Run the clock for 50 cycles just to ensure it doesn't crash
    # (Note: State won't change in simulation unless we simulate millions of cycles)
    for _ in range(50):
        await RisingEdge(dut.clk)

    dut._log.info("Simulation ran successfully!")
