\documentclass[11pt]{article}

\usepackage[margin=1in]{geometry}
\usepackage{fontspec}
\usepackage{listings}
\usepackage{xcolor}
\usepackage{longtable}
\usepackage{array}
\usepackage{hyperref}
\usepackage{amsmath}

\setmainfont{Noto Sans}

\title{FIR Hardware Accelerator}
\author{Vanessa Knight}
\date{}

\begin{document}

\maketitle

\section*{My First VLSI / ASIC Project! ⚙️}

I designed a small FIR (Finite Impulse Response) hardware accelerator in
SystemVerilog and took it from RTL code all the way through an ASIC backend
flow to a physical GDS layout using the SKY130 process.

I wanted to understand what actually happens between writing hardware code
and getting something that looks like a physical chip layout, so I documented
the process and the commands I used along the way.

\section*{🧠 What I Learned}

The basic idea of this project was:

\begin{center}
\textbf{SystemVerilog RTL}
$\rightarrow$
\textbf{Simulation}
$\rightarrow$
\textbf{Synthesis}
$\rightarrow$
\textbf{ASIC Backend}
$\rightarrow$
\textbf{Physical Layout}
\end{center}

More specifically:

\begin{verbatim}
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
\end{verbatim}

\section*{1. Write the FIR Hardware}

I started with a SystemVerilog implementation of a FIR filter and a
testbench to test it.

The FIR filter uses coefficients and input samples to calculate an output.

The main design file is:

\begin{verbatim}
fir_accelerator.sv
\end{verbatim}

and the testbench is:

\begin{verbatim}
fir_testbench.sv
\end{verbatim}

\section*{2. Test + Simulate the Design 🧪}

I used Icarus Verilog to compile my SystemVerilog module and testbench.

\begin{lstlisting}[language=bash]
cd C:\Users\vanes\OneDrive\Documents\VLSI_FIR_ACCELERATOR

iverilog -g2012 -o fir_test fir_accelerator.sv fir_testbench.sv

vvp fir_test

gtkwave fir_waveform.vcd
\end{lstlisting}

\texttt{fir\_test} is just the name I chose for the compiled simulation
output.

The testbench successfully passed the tests I created.

GTKWave was then used to look at the signals and waveform behavior.

\section*{3. Synthesis with Yosys ⚙️}

Next I moved into the Linux/OpenLane environment.

I used WSL and Docker because the OpenLane ASIC tool environment is
Linux-based.

Inside the OpenLane container, I used Yosys to read my SystemVerilog RTL
and examine its hardware representation.

\begin{lstlisting}[language=bash]
cd ~/OpenLane
make mount

ls /home/vanes/fir_synthesis

yosys
\end{lstlisting}

Inside the Yosys prompt:

\begin{lstlisting}
read_verilog -sv /home/vanes/fir_synthesis/fir_accelerator.sv
hierarchy -top fir_accelerator
proc
opt
stat
\end{lstlisting}

Yosys reported the initial synthesized design statistics, including:

\begin{itemize}
    \item 11 wires
    \item 148 wire bits
    \item 7 public wires
    \item 68 public wire bits
    \item 5 cells
    \item 2 \texttt{\$add} cells
    \item 3 \texttt{\$mul} cells
\end{itemize}

This helped me understand that RTL code can be converted into a logical
hardware representation before physical implementation.

\section*{4. Prepare the Design for OpenLane 🏗️}

I then created an OpenLane design directory and copied my SystemVerilog RTL
into it.

\begin{lstlisting}[language=bash]
mkdir -p designs/fir_accelerator/src

cp /home/vanes/fir_synthesis/fir_accelerator.sv \
designs/fir_accelerator/src/

ls designs/fir_accelerator/src
\end{lstlisting}

Then I created the OpenLane configuration:

\begin{lstlisting}
{
    "DESIGN_NAME": "fir_accelerator",
    "VERILOG_FILES": "dir::src/*.sv",
    "CLOCK_PORT": "__VIRTUAL_CLK__",
    "CLOCK_PERIOD": 12,
    "pdk::sky130*": {
        "FP_CORE_UTIL": 30
    }
}
\end{lstlisting}

The configuration tells OpenLane the design name, where the SystemVerilog
files are, the clock settings, and the target core utilization for the
SKY130 technology.

\section*{5. ASIC Backend / Physical Implementation 🔧}

I then ran the OpenLane flow:

\begin{lstlisting}[language=bash]
./flow.tcl -design fir_accelerator
\end{lstlisting}

This is where the project moves beyond just describing the logic.

The backend flow performs things such as:

\begin{itemize}
    \item synthesis
    \item floorplanning
    \item placement
    \item power planning
    \item routing
    \item timing analysis
    \item physical checks
    \item generation of the final layout files
\end{itemize}

The goal is to turn the logical design into a physical implementation using
the selected fabrication technology.

\section*{6. Final Design Results 📊}

OpenLane generated several different views of the completed design:

\begin{verbatim}
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
\end{verbatim}

The most important one for me was the GDS:

\begin{verbatim}
fir_accelerator.gds
\end{verbatim}

GDS contains the physical layout geometry of the implemented design,
including cells, metal layers, vias, and other physical structures.

The DEF contains physical placement and routing information.

LEF provides physical abstracts used by the physical-design tools.

LIB contains standard-cell timing/power information.

SDC contains timing constraints.

SDF contains timing delay information.

SPEF contains extracted parasitic information from the physical
implementation.

The final Verilog is the implemented logic netlist.

\section*{7. Final Metrics}

Some of the metrics reported by OpenLane were:

\begin{longtable}{|l|l|}
\hline
\textbf{Metric} & \textbf{Result} \\
\hline
Flow status & Flow completed \\
\hline
Total runtime & 2 min 22 sec \\
\hline
Routing runtime & 1 min 52 sec \\
\hline
Die area & 0.052245 mm$^2$ \\
\hline
Core area & 44,990.65 $\mu$m$^2$ \\
\hline
Synthesized cells & 1,339 \\
\hline
Total cells & 5,653 \\
\hline
Inputs & 54 \\
\hline
Outputs & 178 \\
\hline
Wire length & 41,972 \\
\hline
Vias & 9,712 \\
\hline
Critical path & 6.54 ns \\
\hline
Target clock period & 12 ns \\
\hline
Suggested frequency & 83.33 MHz \\
\hline
Core utilization & 30\% \\
\hline
Standard-cell library & sky130\_fd\_sc\_hd \\
\hline
\end{longtable}

The design completed the OpenLane flow successfully and had no setup
violations at the typical corner.

\section*{8. View the Physical Layout 🔬}

I used KLayout to open the final GDS file.

\begin{lstlisting}[language=bash]
ls designs/fir_accelerator/runs/RUN_2026.08.17_03.56.10/results/final/gds

klayout -v

klayout designs/fir_accelerator/runs/RUN_2026.08.17_03.56.10/results/final/gds/fir_accelerator.gds
\end{lstlisting}

This let me actually see the physical layout generated by the backend flow.

Seeing the GDS was probably my favorite part because it made the connection
between the SystemVerilog code and the physical implementation much more
obvious.

\section*{🧩 Tools I Used}

\begin{itemize}
    \item SystemVerilog
    \item VS Code
    \item Icarus Verilog
    \item GTKWave
    \item Yosys
    \item OpenLane
    \item OpenROAD
    \item Docker
    \item WSL / Linux
    \item SKY130 PDK
    \item KLayout
\end{itemize}

\section*{🌳 The Overall Idea}

The biggest thing I learned from this project is that writing hardware code
is only the beginning.

\begin{verbatim}
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
\end{verbatim}

The front-end describes what the hardware should do.

The backend figures out how that hardware can physically be implemented
using a particular fabrication technology.

For this project, that technology was SKY130.

\section*{📚 What I Want to Learn Next}

This project made me interested in going further into VLSI and
transistor-level design.

My next goal is to learn more about transistor-level circuits, schematic
design, SPICE simulation, and custom IC layout.

Also, my wonderful friend/mentor ChatGPT wrote this ReadME. I wrote and explained the rest of this project.
And yes, I learned how to manually add emojis + GIFs (Window + .). Now you know too, your welcome!

\end{document}
