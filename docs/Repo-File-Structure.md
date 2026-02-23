# Repo File Structure

This repository has the following file structure:

```
├── assignment.docx
├── docs
├── README.md
└── RTL2GDS
    ├── design
    │   ├── envsetup
    │   ├── Makefile
    │   └── scripts
    ├── pipeline_src
    │   ├── adder32.sv
    │   ├── calculator_pkg.sv
    │   ├── controller.sv
    │   ├── full_adder.sv
    │   ├── result_buffer.sv
    │   ├── tb_calculator.sv
    │   └── top_lvl.sv
    ├── PythonSTA
    │   ├── multi_corner_sta.max.rpt
    │   └── template.py
    ├── README.md
    └── SiliconJackets
```

Here's an overview of the important files and directores:

| File/Directory | Overview |
| --- | --- |
| assignment.docx | The assignment associated with this onboarding project. This is the file you will submit to a PD team lead |
| RTL2GDS/ | Contains the resources required to run the flow and complete the project. | 
| RTL2GDS/design | Contains scripts and tools to set up your environment to recognize Cadence commands and configure the flowtool |
| RTL2GDS/pipeline_src | Contains golden RTL files for the 32 bit adder module. You can run the flow on these, or import your own RTL from the DD onboarding.|
| RTL2GDS/PythonSTA | Contains the files necessary to complete the Python Static Timing Analysis section of the onboarding project |
| RTL2GDS/SiliconJackets | Contains the library specifications of the process node we use to tape out our chips. You will not have to interact with this directory. |
| docs/ | Contains some helpful resources to guide you through the onboarding project. |
