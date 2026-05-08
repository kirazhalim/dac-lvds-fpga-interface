# DAC/LVDS FPGA Interface

This repository contains a small FPGA interface prototype for DAC/LVDS signal generation. I worked on clocking, pulse generation, LVDS-style data output, and simulation checks in Verilog.

The project has 4 Verilog source files and several schematic/simulation figures. I used the design mainly to test timing behavior and compare different clocking ideas.

## What I Did

- Designed basic Verilog modules for pulse generation and top-level integration.
- Tested an externally supplied LVDS clock idea.
- Tested an internally generated high-speed clock approach.
- Added simulation and schematic figures to show the signal flow.

## Repository Structure

```text
src/        Verilog source files
figures/    Schematic and simulation images
```

## Notes

This is a prototype-level FPGA project. It is mainly useful for understanding the interface logic and simulation results, not as a complete production DAC driver.
