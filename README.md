# Microwatt-Based Hardware Debugger SoC

## Overview

This repository contains the design, firmware, and integration resources for a **hardware debugger platform built on the open-source Microwatt POWER CPU core**. The project transforms Microwatt into a versatile debug master, offering real-time control, inspection, and patching of external hardware modules—targeting both FPGA and ASIC environments.

The solution supports seamless integration with industry-standard debug tools (GDB, OpenOCD) through UART, SPI, GPIO, and JTAG protocols, making it ideal for hardware bring-up, rapid prototyping, advanced verification, and cross-disciplinary hardware/software education.

---

## Key Features

- **Wishbone Master Debugging:** Microwatt acts as a bus master, inspecting and manipulating memory/registers of any attached Wishbone-compliant peripheral, IP block, or soft CPU.
- **Multi-Protocol Debug Bridges:** Supports UART, SPI, GPIO, and optional JTAG master for connection to external targets ranging from SoCs to custom digital designs.
- **GDB/OpenOCD Server Block:** Built-in protocol handler accepts remote debug commands over UART, Ethernet, or USB, bridging industry-standard tools directly into the SoC’s internals.
- **Breakpoints & Watchpoints:** Hardware logic enables setting breakpoints, watchpoints, and triggers for advanced test, debug, and automation scenarios.
- **Performance & Trace Modules:** Optional additions for execution tracing, cycle/instruction counting, and system performance profiling.
- **Firmware Tools:** Configurable firmware and command interpreter for streamlined debug workflows and easy integration with host scripts.

---

## Architecture


- **Microwatt Core:** Central processor running debug firmware.
- **Wishbone Master:** Direct access to IP blocks and peripherals.
- **External Interfaces:** UART, SPI, GPIO, optional JTAG master and GDB/OpenOCD server.
- **Peripheral Agents:** Target modules with debug-agent logic for breakpoint, patch, and monitor functions.

---

## Supported Debug Workflows

- **Halt, single-step, resume, and status reporting on target modules**
- **Memory/register inspection and patching**
- **Setting, removing, and monitoring hardware breakpoints/watchpoints**
- **Real-time trace and performance analysis**
- **Automated test and remote debug via scriptable GDB/OpenOCD integration**

---

## Applications

- Rapid ASIC/FPGA hardware bring-up and troubleshooting
- Embedded firmware debugging without special host hardware
- System-level verification and cross-trigger workflows
- Teaching computer architecture and digital hardware
- Prototyping co-processor, accelerator, and multicore experiments
- Open hardware development with professional tool support

---

## Getting Started

1. **Clone the repo** and review the top-level block diagrams and RTL modules.
2. **Select target platform** (FPGA or prepare scripts for ASIC tapeout).
3. **Connect external modules** through Wishbone, SPI, GPIO, or JTAG pins.
4. **Run the debug firmware** on Microwatt; interface with GDB/OpenOCD or use terminal for manual command entry.
5. **Start debugging!** Inspect, patch, and control attached hardware, view logs, handle breakpoints, and automate verification flows.

---

## Contributing

Open for contributions in:
- Hardware module design (trace, JTAG master, performance counters)
- Firmware improvements and debug protocol extensions
- Documentation, educational use cases, and integration examples

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

---

## Contact

Questions, issues, and collaboration: Open an issue in this repo or contact the maintainer.

---

**Empower your hardware debug workflow by leveraging the flexibility, openness, and modern POWER architecture of Microwatt!**

