# Pancake Motor Design

This repository contains the complete open-source hardware files for a DIY **Axial-Flux Pancake Motor**, featuring a **PCB-based stator** and a dual-rotor mechanical assembly.

The motor is designed to conform to the **NEMA 34** standard for easy mounting and integration, and it includes provisions for a rear-mounted rotary encoder.

## Features

- **PCB Stator**: The stator is designed as a custom 2-layer Printed Circuit Board (PCB), eliminating the need for complex wire winding by hand.
  - **Topology**: 12 coils, 3-phase star connection, 8-pole rotor.
  - **Dimensions**: 72mm outer diameter.
  - Generatable via a provided Python script directly into KiCad.
- **Parametric Mechanics & Assembly**: The entire mechanical housing, shaft, and rotor discs are modeled parametrically in OpenSCAD.
  - **NEMA 34 Standard**: The front face is designed to match the NEMA 34 square profile and bolt pattern.
  - **Dual Shaft Options**: Features a stepped 10mm primary shaft output and an 8mm rear stub tailored for a standard 58mm hollow-shaft rotary encoder.
  - **Easy Machining/3D Printing**: Designed to be fabricated from standard materials (turned low-carbon steel for rotors, FDM 3D printing or machined Aluminum 6061 for housing).
- **Automated STL Export**: Contains handy shell and batch scripts to selectively export individual mechanical components from the master OpenSCAD file.

## Repository Contents

* `generate_stator_pcb.py` - Python script to programmatically generate the `stator.kicad_pcb` file (KiCad 6/7 compatible). Just run the script to generate the design!
* `pancake_motor_assembly.scad` - The master OpenSCAD file containing the full parametric 3D model of the motor housing, bearing pockets, rotors, and shaft. Overrides can isolate specific parts for rendering.
* `export_stls.sh` / `export_stls.bat` - Utility scripts to automatically render and export all individual STL files required for printing or machining directly from the `.scad` model.
* `*.gbr` / `*.kicad_pcb` (etc) - Prepared KiCad PCB design and Gerber files ready for PCB fabrication. 

## How to Work With It

### Generating the Stator PCB
To customize or generate the stator PCB:
```bash
python3 generate_stator_pcb.py my_motor.kicad_pcb
```
Then simply open `my_motor.kicad_pcb` natively in KiCad 6 or 7.

### Exporting Mechanical Parts
To export the individual mechanical models to STL, simply run the appropriate script for your OS:

**Linux / macOS:**
```bash
./export_stls.sh
```

**Windows:**
```bat
export_stls.bat
```
Each individual component (e.g., front_end_cap, rotor_disc, shaft) will be dumped directly into standard STL format ready for your slicer or CAM software.

## Assembly Requirements
- **Bearings**: 2x 7200B angular contact bearings (ID: 10mm, OD: 30mm, W: 9mm).
- **Fasteners**: M4 assembly bolts mapping the housing halves together, plus M5 mounting bolts for NEMA 34 installation.
- **Magnets**: Requires 8 poles per disc, embedded within the defined OpenSCAD rotor pockets.
