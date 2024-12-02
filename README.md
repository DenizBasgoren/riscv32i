# Introduction

This repository contains 3 folders with distinct RiscV32i implementations in Verilog, that I wrote for my university Processor design class. Each folder contains:
- The requirements (all named Assignment.pdf)
- My report, which explains the implementation details and instructions on how to run the code
- The source code
- The testbenches
- Test programs in C. (refer to report.pdf for instructions)
- A javascript tool to extract and process segments in a given elf file and convert it to a format usable from my processors. (in util folder)

All code was tested on iverilog only, and it was simulated only - no synthesis was done.

# Single Cycle Riscv32i

A simple single-cycle variant of Riscv32i. Implements all the instructions in RV32I. Registers are read on rising edge, and written to on falling edge of clk. Instruction and data memories are kept seperate.

# Pipelined Riscv32i

Builds upon the single cycle variant, adds 5 stages (fetch, decode, execute, memory, writeback). All hazards (read after write etc) are handled properly.

# Superscalar Riscv32i

Builds upon the 5-stage pipelined variant. This variant has 2 ALU units. Instructions are fetched 2 at a time. All hazards are handled.
