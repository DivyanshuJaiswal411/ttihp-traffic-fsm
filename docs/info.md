## How it works

This project implements a Finite State Machine (FSM) traffic light controller. It uses a 26-bit counter to divide the clock signal, creating human-visible multi-second delays between the light transitions (Green -> Yellow -> Red) for a standard 4-state North/South and East/West intersection.

## How to test

Provide a clock signal (e.g., 50MHz) to the `clk` input and set `rst_n` high (1). Monitor the lower 6 bits of the `uo_out` pins. You will see the binary values corresponding to the traffic light states shifting automatically based on the internal counter.
