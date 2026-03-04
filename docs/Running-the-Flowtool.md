# Running the Flowtool

This document contains the following guides:

- [Running the Flow](#running-the-flow)
- [Changing Flow Parameters](#changing-flow-parameters)

## Running the Flow

1. Clone this repository.

>	**Note:** You _must_ be on an ECE Linux server. Otherwise, you will not have access to the Cadence tools required to run the flow.

```bash
git clone https://github.gatech.edu/SiliconJackets/Physical-Design-Onboarding-S26.git
```

2. Change directory to the `design` directory by running `cd RTL2GDS/flowtool`.

3. Enter the C shell by running `tcsh`.

4. Run `source envsetup`.

	This command executes a script (`envsetup`) that sets up the environment variables necessary to run Cadence tools.

5. Start the flow with the command `flowtool -verbose`.

	This starts the flow, and will run it to completion. We recommend using the flag `-verbose` at a minimum, but here are some more flags you may find helpful:

| Flag | Description |
| --- | --- |
| -reset | runs the flow from the beginning | 
| -predict tcl | parses tcl scripts to try and catch any tcl script errors | 
| -to \<flowstep\> | will run to the ending flowstep ie. -to cts | 
| -from \<flowstep\> | will run from the specified flowstep from the specified flowstep ie. -from floorplan | 
| -from \<flowstep\> -to \<flowstep\> | will run from the specified flowstep to the specified flowstep ie. -from floorplan -to cts | 
| -flow \<flow\> | ex. -flow implementation will run the full implementation flow | 
| -db \<db_name\> | chose a design database to load in and run the flow on | 
| -verbose | flowtool will say what its doing/what scripts its running throughout the build process  | 
<!--- | -run_dir \<name\> | will create and put all files associated with a design build in a folder specified by \<name\> |
This is not true. -->


> **IMPORTANT:** The flow can take a while — potentially as long as an hour. Since its running on the Linux lab, it's okay to turn off your computer while it runs. It will continue running even if you close your terminal.

## Changing Flow Parameters

Most flow parameters you'd want to edit are in:

- `flowtool/resources/sdc/top_level.sdc` (this is where you specify the clock period)
- `flowtool/setup.yaml` 
- `flowtool/flow.yaml` 

For more granular control, you can edit the `.tcl` scripts in `flowtool/scripts/`.


