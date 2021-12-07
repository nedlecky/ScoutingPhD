Please note:

Each example of VHDL code in "Fundamentals of Digital Logic with VHDL Design"
is contained in a sub-folder of the VHDLcode folder (examples that involve
schematics are also included). In cases where subcircuits are involved, the
subcircuits (and/or package) code is also included. As an example,
Figure 7.75 in "Fundamentals of Digital Logic with VHDL Design" provides 
code for a simple processor. This code is found in the folder

<CD-ROM drive>\VHDLcode\Chap7\Figure7.75

which contains the VHDL source code files:

subccts.vhd -- contains a package with component declarations for subcircuits
dec2to4.vhd -- code for a 2-to-4 decoder subcircuit
regn.vhd    -- code for an n-bit register subcircuit
upcount.vhd -- code for a counter subcircuit
proc.vhd    -- top-level code for the processor

For each folder such as the Figure7.75 folder described above, we
recommend that the user create their own separate folder on a writable
disc and copy the *.vhd files into that folder. Any VHDL files that
contain packages should be compiled using MAX+plusII first, after which
the top-level file can be compiled. All VHDL code has been tested with
MAX+plusII version 9.23.

A listing of all files in the VHDLcode directory is given below:

Chap2/Figure2.29/example1.vhd
Chap2/Figure2.30/example2.vhd

Chap4/Figure4.42/func1.vhd
Chap4/Figure4.47/func2.vhd
Chap4/Figure4.48/func3.vhd
Chap4/Figure4.52/func4.vhd
Chap4/Figure4.53/func5.vhd

Chap5/Figure5.20/lpmadd.gdf
Chap5/Figure5.23/fulladd.vhd
Chap5/Figure5.24/adder4.vhd
Chap5/Figure5.24/fulladd.vhd
Chap5/Figure5.25/fulladd_package.vhd
Chap5/Figure5.26/adder4.vhd
Chap5/Figure5.26/fulladd.vhd
Chap5/Figure5.26/fulladd_package.vhd
Chap5/Figure5.27/adder4.vhd
Chap5/Figure5.27/fulladd.vhd
Chap5/Figure5.27/fulladd_package.vhd
Chap5/Figure5.28/adder16.vhd
Chap5/Figure5.29/adder16.vhd
Chap5/Figure5.30/adder16.vhd
Chap5/Figure5.31/adder16.vhd
Chap5/Figure5.38/BCD.vhd
Chap5/FigureP5.2/problem.vhd

Chap6/Figure6.27/mux2to1.vhd
Chap6/Figure6.28/mux4to1.vhd
Chap6/Figure6.29/mux16to1.vhd
Chap6/Figure6.29/mux4to1.vhd
Chap6/Figure6.30/dec2to4.vhd
Chap6/Figure6.31/mux2to1.vhd
Chap6/Figure6.32/priority.vhd
Chap6/Figure6.33/priority.vhd
Chap6/Figure6.34/compare.vhd
Chap6/Figure6.35/compare.vhd
Chap6/Figure6.36/mux16to1.vhd
Chap6/Figure6.36/mux4to1.vhd
Chap6/Figure6.37/dec2to4.vhd
Chap6/Figure6.37/dec4to16.vhd
Chap6/Figure6.38/mux2to1.vhd
Chap6/Figure6.39/mux2to1.vhd
Chap6/Figure6.40/priority.vhd
Chap6/Figure6.41/priority.vhd
Chap6/Figure6.42/compare1.vhd
Chap6/Figure6.43/implied.vhd
Chap6/Figure6.45/mux2to1.vhd
Chap6/Figure6.46/dec2to4.vhd
Chap6/Figure6.47/seg7.vhd
Chap6/Figure6.48/alu.vhd
Chap6/FigureP6.2/problem.vhd

Chap7/Figure7.31/storage.gdf
Chap7/Figure7.35/flipflop.vhd
Chap7/Figure7.36/implied.vhd
Chap7/Figure7.37/latch.vhd
Chap7/Figure7.38/flipflop.vhd
Chap7/Figure7.39/flipflop.vhd
Chap7/Figure7.40/flipflop.vhd
Chap7/Figure7.41/flipflop.vhd
Chap7/Figure7.42/Reg4.vhd
Chap7/Figure7.42/lpmreg.gdf
Chap7/Figure7.43/alureg.gdf
Chap7/Figure7.43/Add4.vhd
Chap7/Figure7.43/Reg4.vhd
Chap7/Figure7.45/shift.vhd
Chap7/Figure7.46/reg8.vhd
Chap7/Figure7.47/regn.vhd
Chap7/Figure7.48/muxdff.vhd
Chap7/Figure7.49/muxdff.vhd
Chap7/Figure7.49/shift4.vhd
Chap7/Figure7.50/shift4.vhd
Chap7/Figure7.51/shift4.vhd
Chap7/Figure7.52/shiftn.vhd
Chap7/Figure7.53/upcount.vhd
Chap7/Figure7.54/upcount.vhd
Chap7/Figure7.55/downcnt.vhd
Chap7/Figure7.62/regn.vhd
Chap7/Figure7.63/trin.vhd
Chap7/Figure7.64/shiftr.vhd
Chap7/Figure7.65/components.vhd
Chap7/Figure7.66/Readme.txt
Chap7/Figure7.66/components.vhd
Chap7/Figure7.66/shiftr.vhd
Chap7/Figure7.66/swap.vhd
Chap7/Figure7.66/trin.vhd
Chap7/Figure7.67/components.vhd
Chap7/Figure7.67/regn.vhd
Chap7/Figure7.67/shiftr.vhd
Chap7/Figure7.67/swapmux.vhd
Chap7/Figure7.68/components.vhd
Chap7/Figure7.68/regn.vhd
Chap7/Figure7.68/shiftr.vhd
Chap7/Figure7.68/swapmux.vhd
Chap7/Figure7.73/upcount.vhd
Chap7/Figure7.74/Readme.txt
Chap7/Figure7.74/dec2to4.vhd
Chap7/Figure7.74/proc.vhd
Chap7/Figure7.74/regn.vhd
Chap7/Figure7.74/subccts.vhd
Chap7/Figure7.74/trin.vhd
Chap7/Figure7.74/upcount.vhd
Chap7/Figure7.75/dec2to4.vhd
Chap7/Figure7.75/proc.vhd
Chap7/Figure7.75/regn.vhd
Chap7/Figure7.75/subccts.vhd
Chap7/Figure7.75/upcount.vhd
Chap7/Figure7.78/bcdcount.vhd
Chap7/Figure7.79/bcdcount.vhd
Chap7/Figure7.79/reaction.vhd
Chap7/Figure7.79/seg7.vhd

Chap8/Figure8.29/simple.vhd
Chap8/Figure8.33/simple.vhd
Chap8/Figure8.34/simple.vhd
Chap8/Figure8.35/simple.vhd
Chap8/Figure8.36/mealy.vhd
Chap8/Figure8.48/shiftrne.vhd
Chap8/Figure8.49/serial.vhd
Chap8/Figure8.49/shiftrne.vhd
Chap8/Figure8.74/arbiter.vhd
Chap8/Figure8.75/arbiter.vhd
Chap8/Figure8.76/arbiter.vhd

Chap10/Figure10.2/rege.vhd
Chap10/Figure10.3/regne.vhd
Chap10/Figure10.4/shiftlne.vhd
Chap10/Figure10.5/components.vhd
Chap10/Figure10.13/bitcount.vhd
Chap10/Figure10.13/components.vhd
Chap10/Figure10.13/shiftrne.vhd
Chap10/Figure10.19/components.vhd
Chap10/Figure10.19/multiply.vhd
Chap10/Figure10.19/mux2to1.vhd
Chap10/Figure10.19/regne.vhd
Chap10/Figure10.19/shiftlne.vhd
Chap10/Figure10.19/shiftrne.vhd
Chap10/Figure10.28/components.vhd
Chap10/Figure10.28/divider.vhd
Chap10/Figure10.28/downcnt.vhd
Chap10/Figure10.28/muxdff.vhd
Chap10/Figure10.28/regne.vhd
Chap10/Figure10.28/shiftlne.vhd
Chap10/Figure10.33/Readme.txt
Chap10/Figure10.33/mean.gdf
Chap10/Figure10.33/Adder.vhd
Chap10/Figure10.33/MReg.vhd
Chap10/Figure10.33/components.vhd
Chap10/Figure10.33/divider.vhd
Chap10/Figure10.33/downcnt.vhd
Chap10/Figure10.33/meancntl.vhd
Chap10/Figure10.33/muxdff.vhd
Chap10/Figure10.33/regne.vhd
Chap10/Figure10.33/shiftlne.vhd
Chap10/Figure10.40/components.vhd
Chap10/Figure10.40/regne.vhd
Chap10/Figure10.40/sort.vhd
Chap10/Figure10.40/upcount.vhd

AppA/FigureA.4/fulladd.vhd
AppA/FigureA.7/adder.vhd
AppA/FigureA.7/fulladd.vhd
AppA/FigureA.8/adderlpm.vhd
AppA/FigureA.9/fulladd_package.vhd
AppA/FigureA.10/adder.vhd
AppA/FigureA.10/fulladd.vhd
AppA/FigureA.10/fulladd_package.vhd
AppA/FigureA.11/adder.vhd
AppA/FigureA.12/priority.vhd
AppA/FigureA.14/adder.vhd
AppA/FigureA.14/fulladd.vhd
AppA/FigureA.14/fulladd_package.vhd
AppA/FigureA.15/addern.vhd
AppA/FigureA.15/fulladd.vhd
AppA/FigureA.15/fulladd_package.vhd
AppA/FigureA.23/numbits.vhd
AppA/FigureA.24/numbits.vhd
AppA/FigureA.26/NANDn.vhd
AppA/FigureA.27/NANDn.vhd
AppA/FigureA.28/NANDn.vhd
AppA/FigureA.29/latch.vhd
AppA/FigureA.30/flipflop.vhd
AppA/FigureA.31/flipflop.vhd
AppA/FigureA.32/flipflop.vhd
AppA/FigureA.33/flipflop.vhd
AppA/FigureA.34/flipflop.vhd
AppA/FigureA.35/reg4.vhd
AppA/FigureA.36/regn.vhd
AppA/FigureA.37/regne.vhd
AppA/FigureA.38/shift4.vhd
AppA/FigureA.39/shift4.vhd
AppA/FigureA.40/count4.vhd
AppA/FigureA.42/components.vhd
AppA/FigureA.43/accum.vhd
AppA/FigureA.43/addern.vhd
AppA/FigureA.43/components.vhd
AppA/FigureA.43/count4.vhd
AppA/FigureA.43/fulladd.vhd
AppA/FigureA.43/fulladd_package.vhd
AppA/FigureA.43/nandn.vhd
AppA/FigureA.43/regne.vhd
AppA/FigureA.45/moore.vhd
AppA/FigureA.46/moore.vhd
AppA/FigureA.48/mealy.vhd
AppA/FigureA.49/moore.vhd

AppC/FigureC.13/example2.vhd

AppD/FigureD.1/fulladd.vhd
AppD/FigureD.2/addern.vhd
AppD/FigureD.2/fulladd.vhd
AppD/FigureD.7/fulladd_package.vhd
AppD/FigureD.8/addern.vhd
AppD/FigureD.8/fulladd.vhd
AppD/FigureD.8/fulladd_package.vhd
AppD/FigureD.10/adderlpm.vhd
AppD/FigureD.23/graphic2.gdf
AppD/FigureD.23/Reg4.vhd
AppD/FigureD.28/Reg4.vhd
AppD/FigureD.28/example3.vhd
AppD/FigureD.30/simple.vhd
