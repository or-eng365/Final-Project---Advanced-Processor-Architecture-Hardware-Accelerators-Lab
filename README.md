# Final-Project - Advanced-Processor-Architecture-Hardware-Accelerators-Lab
This project implements a MIPS-based microcontroller unit (MCU) in VHDL. The MCU integrates MIPS processor with various peripherals, making it suitable for a range of embedded applications.
Design, synthesis, and analysis of a simple (single cycle architecture) MIPS CPU core with Memory Mapped I/O and interrupt capability

This file provides a brief overview of the project structure and the purpose of the files in each directory.

## `DUT` Directory

This directory contains the VHDL source code for the Design Under Test (DUT), which is the MIPS-based MCU.

- **`CONTROL.VHD`**: Implements the MIPS control unit. It decodes the instruction opcode and funct fields to generate the necessary control signals for the datapath.
- **`DMEMORY.VHD`**: The data memory (DTCM) for the MIPS processor. It is implemented using an Altera `altsyncram` block.
- **`EXECUTE.VHD`**: The execute stage of the MIPS. It contains the main Arithmetic Logic Unit (ALU) which performs arithmetic and logical operations. It also includes logic for calculating branch target addresses.
- **`FIFO.vhd`**: A generic First-In, First-Out (FIFO) buffer used in filter operation.
- **`FIR.vhd`**: A Finite Impulse Response (FIR) filter hardware accelerator. It uses a FIFO to buffer input samples and a separate calculation block (`filter.vhd`) to perform the filtering operation.
- **`IDECODE.VHD`**: The instruction decode (ID) stage of the MIPS. It contains the register file, decodes instructions, and sign-extends immediate values.
- **`IFETCH.VHD`**: The instruction fetch (IF) stage of the MIPS. It holds the program counter (PC), fetches instructions from the instruction memory (`altsyncram`), and calculates the next PC value.
- **`MIPS.vhd`**: The top-level entity for the MIPS processor. It connects the IF, ID, EX, and MEM files.
- **`mcu.vhd`**: The top-level entity for the entire microcontroller unit (MCU). It instantiates the MIPS processor and connects it to various peripherals.
- **`PLL.vhd`**: An Altera Phase-Locked Loop (PLL) megafunction (`altpll`). It is used to generate stable clock signals for the system.
- **`Shifter.vhd`**: A generic barrel shifter used for shift operations in the execute stage.
- **`address_decoder.vhd`**: Decodes the address bus to generate chip select signals for the various peripherals in the MCU.
- **`aux_package.vhd`**: A VHDL package containing component declarations for all the modules used in the design.
- **`basic_timer.vhd`**: A basic timer module with PWM (Pulse Width Modulation) generation capabilities.
- **`cond_comilation_package.vhd`**: A VHDL package that defines constants for conditional compilation, allowing for different builds for simulation (Modelsim) and synthesis (Quartus).
- **`const_package.vhd`**: A VHDL package that defines constants for the MIPS instruction opcodes.
- **`filter.vhd`**: The core calculation block for the FIR filter. It performs the multiply-accumulate operations.
- **`fir_top.vhd`**: A top-level wrapper for the FIR filter that provides a memory-mapped interface for the MIPS processor.
- **`hex_decoder.vhd`**: A decoder that converts a 4-bit hexadecimal value to a 7-segment display pattern.
- **`hex_seg.vhd`**: A memory-mapped interface for a 7-segment display digit.
- **`int_ctrl.vhd`**: A prioritized interrupt controller that manages interrupt requests from the various peripherals.
- **`led_io.vhd`**: A memory-mapped interface for controlling a set of LEDs.
- **`pulse_synchronizer.vhd`**: A pulse synchronizer for safely passing signals between different clock domains (FIFO and filter calculation).
- **`sw_io.vhd`**: A memory-mapped interface for reading the state of a set of switches.
- **`timer_top.vhd`**: A top-level wrapper for the basic timer that provides a memory-mapped interface for the MIPS processor.

## Other Directories

- **`Library`**: Contains various test programs written in C and MIPS assembly language. Each subdirectory includes the source code and the compiled `.hex` files (`ITCM.hex` for instructions and `DTCM.hex` for data) that can be loaded into the processor's memories.

- **`TB`**: Holds the VHDL testbenches for simulating the design. This includes testbenches for the top-level MCU (`tb_sc_mips.vhd`), the FIR filter (`fir_tb.vhd`), and the timer (`timer_tb.vhd`).

- **`QUARTUS`**: Contains project files for the Altera Quartus II software. This includes the project file itself, as well as pin assignments and timing constraints (`.sdc` file) for targeting an FPGA device.

