YES 😭 I see exactly what you mean now. You want **ONE single Markdown code block from the very first `#` to the very last sentence**, with **nothing breaking it into separate cells**.

Copy **this entire one block** and paste it directly into GitHub's `README.md` editor:

````markdown
# FIR Hardware Accelerator ⚙️

My first VLSI / ASIC project!

I designed a small FIR (Finite Impulse Response) hardware accelerator in SystemVerilog and took it from RTL code all the way through an ASIC backend flow to a physical GDS layout using the SKY130 process.

I wanted to understand what actually happens between writing hardware code and getting something that looks like a physical chip layout, so I documented the process and the commands I used along the way.

## 🧠 What I Learned

The basic idea of this project was:

**SystemVerilog RTL → Simulation → Synthesis → ASIC Backend → Physical Layout**

More specifically:

```text
SystemVerilog
      |
      v
Icarus Verilog + Testbench
      |
      v
GTKWave
      |
      v
Yosys
      |
      v
OpenLane / OpenROAD
      |
      v
SKY130 PDK
      |
      v
Placement + Routing + Timing + Physical Checks
      |
      v
GDS
      |
      v
KLayout
````

## 1. Write the FIR Hardware

I started with a SystemVerilog implementation of a FIR filter and a testbench to test it.

The FIR filter uses coefficients and input samples to calculate an output.

The main design file is:

`fir_accelerator.sv`

and the testbench is:

`fir_testbench.sv`

## 2. Test + Simulate the Design 🧪

I used Icarus Verilog to compile my SystemVerilog module and testbench.

**Note: do this in regular CMD on Windows**

### Commands

```text
cd C:\Users\vanes\OneDrive\Documents\VLSI_FIR_ACCELERATOR
```

```text
iverilog -g2012 -o fir_test fir_accelerator.sv fir_testbench.sv
```

```text
vvp fir_test
```

```text
gtkwave fir_waveform.vcd
```

`fir_test` is just the name I chose for the compiled simulation output.

The testbench successfully passed the tests I created.

GTKWave was then used to look at the signals and waveform behavior.

## 3. Synthesis with Yosys ⚙️

Next I moved into the Linux/OpenLane environment.

I used WSL and Docker because the OpenLane ASIC tool environment is Linux-based.

Inside the OpenLane container, I used Yosys to read my SystemVerilog RTL and examine its hardware representation.

### Enter the OpenLane environment

```text
cd ~/OpenLane
```

```text
make mount
```

```text
ls /home/vanes/fir_synthesis
```

Then start Yosys:

```text
yosys
```

### Inside the `yosys>` prompt

```text
read_verilog -sv /home/vanes/fir_synthesis/fir_accelerator.sv
hierarchy -top fir_accelerator
proc
opt
stat
```

Yosys reported the initial synthesized design statistics, including:

* 11 wires
* 148 wire bits
* 7 public wires
* 68 public wire bits
* 5 cells
* 2 `$add` cells
* 3 `$mul` cells

This helped me understand that RTL code can be converted into a logical hardware representation before physical implementation.

## 4. Prepare the Design for OpenLane 🏗️

I then created an OpenLane design directory and copied my SystemVerilog RTL into it.

```text
mkdir -p designs/fir_accelerator/src
```

```text
cp /home/vanes/fir_synthesis/fir_accelerator.sv designs/fir_accelerator/src/
```

```text
ls designs/fir_accelerator/src
```

Then I created the OpenLane configuration:

```json
{
    "DESIGN_NAME": "fir_accelerator",
    "VERILOG_FILES": "dir::src/*.sv",
    "CLOCK_PORT": "__VIRTUAL_CLK__",
    "CLOCK_PERIOD": 12,
    "pdk::sky130*": {
        "FP_CORE_UTIL": 30
    }
}
```

The configuration tells OpenLane the design name, where the SystemVerilog files are, the clock settings, and the target core utilization for the SKY130 technology.

## 5. ASIC Backend / Physical Implementation 🔧

I then ran the OpenLane flow:

```text
./flow.tcl -design fir_accelerator
```

This is where the project moves beyond just describing the logic.

The backend flow performs things such as:

* synthesis
* floorplanning
* placement
* power planning
* routing
* timing analysis
* physical checks
* generation of the final layout files

The goal is to turn the logical design into a physical implementation using the selected fabrication technology.

## 6. Final Design Results 📊

OpenLane generated several different views of the completed design:

```text
def
gds
lef
lib
mag
maglef
sdc
sdf
spef
spi
verilog
```

The most important one for me was the GDS:

`fir_accelerator.gds`

GDS contains the physical layout geometry of the implemented design, including cells, metal layers, vias, and other physical structures.

The DEF contains physical placement and routing information.

LEF provides physical abstracts used by the physical-design tools.

LIB contains standard-cell timing/power information.

SDC contains timing constraints.

SDF contains timing delay information.

SPEF contains extracted parasitic information from the physical implementation.

The final Verilog is the implemented logic netlist.

## 7. Final Metrics

Some of the metrics reported by OpenLane were:

| Metric                |          Result |
| --------------------- | --------------: |
| Flow status           |  Flow completed |
| Total runtime         |    2 min 22 sec |
| Routing runtime       |    1 min 52 sec |
| Die area              |    0.052245 mm² |
| Core area             |   44,990.65 µm² |
| Synthesized cells     |           1,339 |
| Total cells           |           5,653 |
| Inputs                |              54 |
| Outputs               |             178 |
| Wire length           |          41,972 |
| Vias                  |           9,712 |
| Critical path         |         6.54 ns |
| Target clock period   |           12 ns |
| Suggested frequency   |       83.33 MHz |
| Core utilization      |             30% |
| Standard-cell library | sky130_fd_sc_hd |

The design completed the OpenLane flow successfully and had no setup violations at the typical corner.

## 8. View the Physical Layout 🔬

I used KLayout to open the final GDS file.

First I displayed the GDS directory:

```text
ls designs/fir_accelerator/runs/RUN_2026.08.17_03.56.10/results/final/gds
```

Then I checked the KLayout version:

```text
klayout -v
```

Then I opened the final GDS:

```text
klayout designs/fir_accelerator/runs/RUN_2026.08.17_03.56.10/results/final/gds/fir_accelerator.gds
```

This let me actually see the physical layout generated by the backend flow.

Seeing the GDS was probably my favorite part because it made the connection between the SystemVerilog code and the physical implementation much more obvious.

## 🧩 Tools I Used

* SystemVerilog
* VS Code
* Icarus Verilog
* GTKWave
* Yosys
* OpenLane
* OpenROAD
* Docker
* WSL / Linux
* SKY130 PDK
* KLayout

## 🌳 The Overall Idea

The biggest thing I learned from this project is that writing hardware code is only the beginning.

```text
SystemVerilog
     |
     v
Functional simulation
     |
     v
Logical synthesis
     |
     v
Standard-cell implementation
     |
     v
Floorplanning
     |
     v
Placement
     |
     v
Routing
     |
     v
Timing + physical checks
     |
     v
GDS
     |
     v
Physical ASIC layout
```

The front-end describes what the hardware should do.

The backend figures out how that hardware can physically be implemented using a particular fabrication technology.

For this project, that technology was SKY130.

## 📚 What I Want to Learn Next

This project made me interested in going further into VLSI and transistor-level design.

My next goal is to learn more about transistor-level circuits, schematic design, SPICE simulation, and custom IC layout.

Also, my wonderful friend/mentor ChatGPT wrote this ReadME. I wrote and explained the rest of this project.

And yes, I learned how to manually add emojis + GIFs (Window + .). Now you know too, your welcome!

```

**Important:** when you paste it into GitHub, paste the **contents of the block**, not the outer three backticks that surround this whole response. That way GitHub will interpret the `#`, `##`, tables, and inner code blocks as Markdown instead of putting your entire README into one giant code box.
```
