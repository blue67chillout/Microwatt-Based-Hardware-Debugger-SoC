# Microwatt-Based External Debugger for AI/NoC Workloads

---

## 1. Goal
Build an **external debugger platform** using the Microwatt POWER core to provide deeper observability and real-time analysis for **AI accelerators and Network-on-Chip (NoC) systems** in ASIC environments.

Instead of replacing the built-in debug fabric, Microwatt acts as an **orchestrator and flight recorder** — extending visibility, correlating data, and enabling active probes that existing infra cannot do alone.

---

## 2. What the External Debugger (Microwatt-Based) Adds

The Microwatt core doesn’t replace the accelerator’s debug blocks — it **sits outside**, leveraging and extending them:

🔎 **Observability beyond the built-in scope**
- Correlates AI cores, NoC, memory, DMA into a single timeline.
- Buffers and streams large traces (internal infra usually can’t).
- Collects performance metrics at system scale (bandwidth, congestion, hotspots).

🛠️ **Independent debug execution**
- Runs its own firmware, analyzing debug data in real time instead of just dumping raw logs.
- Can actively probe the AI chip (inject NoC packets, stress test memory ports).
- Acts like a **debug co-processor**, offloading analysis from the host PC.

🔗 **Cross-chip & system-level debug**
- Goes beyond chip boundaries: watches PCIe, DRAM, inter-chip NoCs.
- Correlates AI chip internals with host CPU/GPU activity.
- Provides a uniform debug view for **multi-accelerator setups**.

---

## 3. How This Looks in Practice

Imagine debugging a congested **NoC in a 256-core AI accelerator**:

- **Built-in debug infra**:  
  - Router counters + trace packets from a few links.

- **Microwatt-based debugger**:  
  - Subscribes to those counters, timestamps them, **correlates across routers**.  
  - Sniffs raw flits at selected links → reconstructs **traffic flows**.  
  - Runs a congestion-detection algorithm locally, flags hotspots in real time.  
  - Sends only **processed alerts** to the host PC (instead of drowning it in gigabytes of trace).  

---

## 4. Minimal Architecture (Hackathon Scope)

- **Microwatt Core**  
  - Runs debug firmware (event correlation, analysis, host protocol server).

- **JTAG/DMI Master Interface**  
  - Controls AI/NoC SoC at register/memory level.  
  - Acts as debug master for halt/resume, memory peek/poke.

- **NoC Event Monitor**  
  - Taps selected NoC links.  
  - Collects counters, samples flits, reconstructs flow-level stats.

- **Trace/Log Buffer**  
  - Small SRAM buffer for recent traces and events.  
  - Supports burst transfer to host when requested.

- **Host I/O (USB/Ethernet)**  
  - Bridges to host PC for integration with **GDB, OpenOCD, or custom debug CLI**.

---

## 5. Hackathon Deliverables
1. FPGA prototype with Microwatt + JTAG/DMI Master + USB/Ethernet bridge.  
2. Debug firmware running on Microwatt:  
   - Poll NoC counters, perform local analysis, flag congestion.  
   - Serve debug commands from host (halt/resume, trace dump).  
3. Demo scenario:  
   - Stress AI accelerator NoC → external debugger detects congestion pattern → sends alerts to host.  

---

## 6. Impact
- Provides **ASIC-oriented, external debug visibility** that complements built-in infra.  
- Reduces host overhead by performing **on-probe analysis**.  
- Portable design: works across AI accelerators, NoC-based SoCs, and multi-chip systems.  
- Ideal for **bring-up, performance tuning, and system-level debug** in complex AI hardware.

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

---

## Contact

Questions, issues, and collaboration: Open an issue in this repo or contact the maintainer.

---

**Empower your hardware debug workflow by leveraging the flexibility, openness, and modern POWER architecture of Microwatt!**

