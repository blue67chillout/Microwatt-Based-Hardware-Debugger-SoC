# Microwatt-Based Debugger ASIC for AI/NoC Systems

---

## 1. Goal
A **Microwatt-based debugger ASIC** that serves as an **external debug companion chip** for AI accelerators and Network-on-Chip (NoC) systems and leverages Microwatt’s native **Wishbone + JTAG/DMI debug fabric** to control, observe, and analyze external targets at ASIC-level performance.

---

## 2. What This Debugger Adds

**Extended Observability**
- Aggregates debug data across cores, NoCs, DMA, and memory into a unified timeline.  
- Adds scalable trace buffering (using openRAM) for long captures.  
- Enables live monitoring of congestion, stalls, and performance counters.  

**Independent Debug Execution**
- Microwatt firmware processes traces in real time (not just raw dump).  
- Can actively probe targets (inject NoC packets, force memory transactions).  
- Acts as a **debug co-processor ASIC**, offloading analysis from host PC.  

---

## 3. How This Looks in Practice
**Scenario: Debugging congestion in a 256-core AI accelerator NoC**  

- **Built-in debug infra**: router counters + limited packet trace.  
- **Microwatt Debugger ASIC**:  
  - Subscribes to counters via Wishbone/Debug Master.  
  - Timestamps and correlates events across routers.  
  - Sniffs selected flits, reconstructs traffic flows.  
  - Runs congestion-detection locally → flags hotspots.  
  - Sends only **processed alerts** to host instead of raw gigabytes.  

---

## 4. Prioritized attach points

- JTAG / DMI / debug transport 
- NoC telemetry registers / per-router counters
- AXI-Stream trace export or trace pins (ETM-lite)

## 5. Minimal ASIC Architecture

- **Microwatt Core**  
  - Runs debug firmware, OpenOCD/GDB server.  

- **dmi_dtm + wishbone_debug_master**  
  - JTAG/DMI → Wishbone bridge, controlling target SoC.  

- **NoC Event Monitor (Wishbone slave)**  
  - Lightweight sniffer for router metadata + counters.
 
- **Error Injection - controlled fault injection hooks
  -scripted fault injection runs, then capture effect using aggregator

- **Trace/Log Buffer (SRAM) (openRAM)**  
  - Stores pre/post-trigger trace.  

- **Host I/O**  
  - USB 3.0 or GigE PHY for host connection.  

```mermaid
HostPC["Host PC / Debugger"]
PHY["USB 3.0 / GigE PHY"]
MicrowattCore["Microwatt Core\n(GDB/OpenOCD Server)"]
DTM["dmi_dtm (JTAG/DMI/Debug Transport)"]
DebugMaster["wishbone_debug_master"]
NoCMon["NoC Event Monitor\n(NoC Telemetry/Router Counters)"]
ErrorInject["Error Injection Hooks"]
TraceBuffer["Trace/Log Buffer (SRAM)"]
AXITrace["AXI-Stream Trace Export\n(ETM-lite or Trace Pins)"]

HostPC <---> PHY
PHY --> MicrowattCore
MicrowattCore --> DTM
DTM --> DebugMaster
DebugMaster --> NoCMon
DebugMaster --> ErrorInject
DebugMaster --> TraceBuffer
DebugMaster --> AXITrace
AXITrace --> TraceBuffer



```
---

## 5. Hackathon Deliverables
- RTL prototype (Microwatt + DMI bridge + NoC Monitor).  
- Debug firmware (halt/resume, trace collection, congestion detection).  
- FPGA demo: detect & report NoC congestion in real time.  

---

## 6. Impact
- First **ASIC-debugger coprocessor** built on Microwatt.  
- Re-uses proven **Wishbone debug fabric** for target integration.  
- Provides real-time, cross-chip visibility .  
- Bridges gap between JTAG probes and system-scale debug observability.  


---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

---

## Contact

Questions, issues, and collaboration: Open an issue in this repo or contact the maintainer through mail ( fridayfallacy67@gmail.com ).

---


