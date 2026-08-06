# Scenario List Runner

The Scenario List Runner script allows you to run multiple scenarios in one go. It records the console output, any errors, and list any scenarios that timed out (e.g.: stopped execution partway due to an error). The script also produces an output table of the simulated scenario's results in the `Model_output` directory.

## Contents

- [Usage](#usage)
- [Example](#example)
  - [Setup](#setup)
  - [Checking the output after execution](#checking-the-output-after-execution)
  - [Checking scenario timeouts](#checking-scenario-timeouts)
- [Troubleshooting](#troubleshooting)
- [Developer Notes](#developer-notes)

## Usage

Navigate to the directory containing the `run_scenario_list.sh` script (assuming the current directory is the repository root).

```
cd tests/scenario_list_runner
```

Run the following to view usage information about the script.

```
bash run_scenario_list.sh -h
```

### Example

#### Setup

Suppose we want to run the following scenarios:

```
model.options.default.grapevine.json
model.options.default.json
model.options.dynamicApple.json
```

Create a new .txt file (either by duplicating the existing .txt files or running `touch scenario_lists/my_list.txt` in CLI). Then copy and paste the scenarios listed above into the file.

The scenario list runner supports the following options (given in order):

```
[scenario list path] [num steps] [timeout]
```

- **scenario list path**: File path to the list of scenarios to run.
- **num steps**: (Optional) Number of steps to run each scenario in the list.
- **timeout**: (Optional) Number of seconds that may elapse between each output before the scenario run is terminated. Default timeout is 10 seconds.

For this example, we wish to run the scenarios listed in our newly created `my_list.txt` file for **5 steps**, and set a timeout after **15 seconds**. The timeout is beneficial for helping catch when a scenario stops midway during execution (potentially due to an error).

The resulting command to enter is the following:

```
bash run_scenario_list.sh scenario_lists/my_list.txt 5 15
```

Run the above command and observe the execution of each scenario in the console output.

#### Checking the output after execution

Navigate to the `logs` folder that has been created in the same directory as the `run_scenario_list.sh` script.

You should see a new folder with the time of when the run command was executed (such as `2024-02-07_14-33-20`), which will contain two other folders:

- `output`: Records all of the output from each scenario execution.
- `error`: Records only error outputs from each scenario execution.

For example, you should see a file named `model.options.default.grapevine.json.log` in both the `output` and `error` folders.

You can also check the model output for each scenario in the `Model_output` directory within the root of the repository.

#### Checking scenario timeouts

You can find a `timeout_list.txt` file in the same directory as the `output` and `error` folders. This file lists any scenario that timed out (no output was detected within the allowed timeout duration).

The purpose of the timeout list is to keep track of problematic scenarios. If there are any scenarios present in the list, it is recommended to:

1. Check the output and error logs to gain insight into the cause.
   - Note: scroll to the bottom of the file to see the last output before the scenario was terminated.
   - If no error is visible, this may indicate other issues such as compute time causing timeouts (see [Troubleshooting](#troubleshooting)).
2. Resolve the cause of the error for the scenario(s) in question.
3. Run again to check if the issue has been fixed. You may choose to either:
   - Run the scenario list (`my_list.txt`) again, or
   - Pass the timeout list directly to the script (replacing \<TIMESTAMP\> with the folder name, such as `2024-02-07_14-33-20`):

```
bash run_scenario_list.sh logs/<TIMESTAMP>/timeout_list.txt 5 15
```

## Troubleshooting

**All of my scenarios timed out and there were no errors or exceptions listed in the error logs.**
You may need to increase the number of seconds for the timeout value depending on your computer's performance, as compute and execution times will vary.

**GroIMP headless does not start.**
Navigate to the top of the `run_scenario_list.sh` script for the following line: `GROIMP_DIR=/usr/share/GroIMP` and check if the path correctly points to the location of your GroIMP installation.

## Developer Notes

### Log files

The following defines which files the GroIMP headless stdout and stderr are sent to. Note that GroIMP headless produces stderr outputs regardless of if there were actual errors during execution.

```
$GROIMP_RUN_CMD 2> $error_path | tee $output_path &
```

You may opt to change this if you wish to see both stdout and stderr in a single file by replacing the line with the following:

```
$GROIMP_RUN_CMD 2>&1 | tee $output_path &
```
