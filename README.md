# 4-Stage Pipelined Processor

This project implements a four-stage SIMD multimedia pipeline processor in VHDL.

![project block diagram](https://github.com/user-attachments/assets/7debe292-3299-45e8-a838-4842e4b18b0a)


## Overview
- Designed and developed a pipelined processor featuring 4 stages: Instruction Fetch, Decode, Execute, and Write Back.
- Supports a MIPS-like ISA with a custom assembler written in C++.
- Includes cycle-accurate VHDL testbenches for each pipeline stage for functional correctness and reliability.

## Features
- ALU, register file, stage registers for pipelining, instruction buffer, and data forwarding.
- Custom assembler automates binary opcode generation from assembly instructions.
- Enhanced debugging and reliability using comprehensive testbenches.

## Technologies Used
- VHDL for hardware design
- C++ for custom assembler

## Usage
1. Simulate the VHDL design using an HDL simulator like ModelSim or Aldec Active-HDL.
2. Use the provided assembler to compile assembly code into machine code for the processor.
3. Run the included testbenches to verify functional accuracy.

---
