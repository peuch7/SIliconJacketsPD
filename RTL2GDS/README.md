# Running the Flow

To run:

1. Clone the onboarding repository into the Linux server

```
git clone https://github.gatech.edu/SiliconJackets/Physical-Design-Onboarding-S26.git
```

2. Copy your verilog files into `RTL2GDS/flowtool/src/`

> IMPORTANT: The way the SRAM modules were instantiated in the Digital Design Onboarding isn't compatible with synthesis. Please follow the following steps:

- Change both instantiations of the SRAM macro in your toplevel file from `CF_SRAM_1024x32_macro` to `CF_SRAM_1024x32`
- Add the following declarations in your toplevel file:
```
supply1 VDD;
supply0 VSS;
```
- Finally, replace your power ports:
```
 .TM         (VSS),
        .SM         (VSS),
        .WLBI       (VSS),
        .WLOFF      (VSS),
        .ScanInCC   (VSS),
        .ScanInDL   (VSS),
        .ScanInDR   (VSS),
        .ScanOutCC  (),
        .vpwrac     (VDD),
        .vpwrpc     (VDD)
```

3. Navigate into the flowtool directory

4. Specify the name of your toplevel verilog file on line 228 of `flowtool/scripts/setup.yaml`. This should be the name of your verilog file **without the .sv extension**.

5. Enter tcsh by running `tcsh` on your command line

6. Source the envsetup file to add Cadence tools to your $PATH

```
source envsetup
```

7. Then invoke the flowtool by running the following command or an equivalent

> IMPORTANT: After cloning a fresh version of the repo, the flow will fail. Please complete part 4 of `assignment.docx` to debug the flow.

```
flowtool -verbose
```


## Common flags that may be useful for flowtool 

```
-reset, runs the flow from the beginning
-predict tcl, parses tcl scripts to try and catch any tcl script errors
-to <flowstep>, will run to the ending flowstep ie. -to cts
-from <flowstep>, will run from the specified flowstep from the specified flowstep ie. -from floorplan
-from <flowstep> -to <flowstep>, will run from the specified flowstep to the specified flowstep ie. -from floorplan -to cts
-flow <flow>, ex. -flow implementation will run the full implementation flow
-db <db_name>, chose a design database to load in and run the flow on
-run_dir <name>, will create and put all files associated with a design build in a folder specified by <name>
-verbose, flowtool will say what its doing/what scripts its running throughout the build process 
```

## Tips

The Makefile has several useful targets:
- **clean**. Permanently deletes flow output files
- **archive NAME=\<name\>**. Archives flow output files into a folder with the provided name.
- **purge**. Purge any existing archives in `archives/`
- **flow NAME=\<name\>**. Runs a flow on the current design configuration and automatically archives files after completion.
  
If you have any questions, send a message in the physical design discussion channel on the [Discord server](https://discord.com/invite/swK5QnTt4j) or reach out to a Physical Design team lead:

| Name | Discord | Email |
| --- | --- | --- |
| Cooper Shaw | cooper.shaw | shaw@gatech.edu |
| Julian Grinberg | juleslop | jgrinberg7@gatech.edu |
| Patricio Cortez | lovebaron | pcortez3@gatech.edu |
| Josh Perez | jp_1234. | jperez321@gatech.edu | 
| Jiho Jun | Dj0812 | jjun49\@gatech.edu | 

