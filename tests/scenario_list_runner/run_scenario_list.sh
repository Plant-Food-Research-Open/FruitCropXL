#!/bin/bash

set -e
set -o pipefail
###################################################################
# Constants
###################################################################

GROIMP_DIR=/usr/share/GroIMP
PARENT_DIR="tests" # Assumes the script is in tests/scenario_list_runner
TIMEOUT_LIST_FILE_NAME="timeout_list.txt"
RUN_SETTING_LOG_FILE_NAME="run_settings.txt"
SUMMARY_FILE_NAME="latest_summary.md"
WORKFLOW_ENV_FILE_NAME="workflow.env"

LOG_DIR="logs"
OUTPUT_LOG_DIR="output"
ERROR_LOG_DIR="error"

DEFAULT_TIMEOUT_SECONDS=360

ERROR_KEYWORD="error" # TODO: change to array to allow checking for multiple keywords

STYLE='\033[0;33m' # Yellow
NC='\033[0m' # No Color


###################################################################
# Functions
###################################################################


echo_alert() {
    echo -e "${STYLE}$1${NC}"
}

echo_alert_nl() {
    echo_alert "\n$1"
}


usage() {
    echo """
    ###############################################################
    Help:

    * Description:
        - Runs all the scenarios listed in a file (optionally, for a fixed number of steps).
        - Note: this script should be run while inside its root directory.
    * Usage:
        - $0 [scenario list path] [num steps] [timeout]
    * Parameters:
        - scenario list path: File path to the list of scenarios to run.
        - num steps: (Optional) Number of steps to run each scenario in the list.
        - timeout: (Optional) Number of seconds that may elapse between each output before the scenario run is terminated. Default timeout is 10 seconds.

    ###############################################################
    """    
}

help() {
    if [ "${1}" = "-h" ] || [ "${1}" = "-help" ]; then
        usage
        exit 0
    fi
}

run_scenario() {
  local scenario="$1"

  echo_alert_nl "###################################################################"
  echo_alert "Running new scenario: $scenario"
  echo_alert "###################################################################"

  echo_alert_nl "Starting GroIMP"

  # Define log file paths with timestamp and scenario
  output_dir="$current_log_path/$OUTPUT_LOG_DIR"
  error_dir="$current_log_path/$ERROR_LOG_DIR"  # kept for compatibility (not used with unified log)
  mkdir -p "$output_dir" "$error_dir"

  file_name_format="${scenario}.log"
  output_path="$output_dir/$file_name_format"
  error_path="$error_dir/$file_name_format"
  : >"$output_path"
  : >"$error_path"

  ########################
  # LAUNCH + WATCH (NEW) #
  ########################

  # pick a line-buffering helper if present
  if command -v stdbuf >/dev/null 2>&1; then
    BUF=(stdbuf -oL -eL)
  elif command -v unbuffer >/dev/null 2>&1; then
    BUF=(unbuffer)
  else
    BUF=()
  fi

  # launch; merge stderr into stdout; tee to single log
  "${BUF[@]}" apptainer exec --nv \
    --bind "${repo_path}:/var/model" \
    "${repo_path}/images/groimp.sif" \
    java -Djava.awt.headless=true -Djdk.xml.maxElementDepth=1000 \
    -Xms2G -Xss8m -noverify \
    -jar "${GROIMP_DIR}/core.jar" \
    --headless $([ -n "$arg_num_steps" ] && printf -- '-XrunEndSteps=%s' "$arg_num_steps") \
    -XmodelOptions="$scenario" -XnCores=1 -XmodelPath="/var/model/" \
    /var/model/Scripts/project.gs \
    2>&1 | tee "$output_path" &
  pid=$!

  # helper to read user+sys jiffies from /proc
  get_cputime() {
    awk '{print $14+$15}' "/proc/$1/stat" 2>/dev/null || echo 0
  }

  last_cpu=$(get_cputime "$pid")

  # Detect when the GroIMP headless app is no longer producing output
  while true; do
    # process finished?
    if ! ps -p "$pid" > /dev/null; then
      echo_alert "Finished"
      break
    fi

    # last write time (seconds) of the unified log
    last_output_time=$(stat -c %Y "$output_path" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    time_diff=$(( current_time - last_output_time ))

    # consider CPU progress as liveness even if no log lines
    cur_cpu=$(get_cputime "$pid")
    cpu_progress=$(( cur_cpu - last_cpu ))
    last_cpu=$cur_cpu

    # Look for real errors in the recent tail (avoid matching "error_count")
    if tail -n 200 "$output_path" 2>/dev/null \
         | grep -Eiq '(^|[^a-zA-Z])(Exception|FATAL)([^a-zA-Z]|$)'; then
      stop_scenario "$scenario"
      break
    fi

    # Timeout only if no output AND no CPU progress for the whole window
    if [ "$time_diff" -gt "$arg_timeout" ] && [ "$cpu_progress" -eq 0 ]; then
      stop_scenario "$scenario"
      break
    fi

    sleep 1
  done

  echo_alert_nl "GroIMP stopped"
}

stop_scenario() {
    local scenario="$1"

    echo_alert_nl "###################################################################"
    echo_alert "Timeout for scenario: $scenario"
    echo_alert "###################################################################"

    kill $pid
    has_timeout=true

    # Add this scenario to the timeout list for reference
    echo $scenario >> $current_log_path/$TIMEOUT_LIST_FILE_NAME
}

# Run a bash script of a given name inside the root of the repository
run_root_script() {
    local script=$1

    cd $repo_path
    source $script
    cd $base_dir # Return back to this script's directory, as source changes pwd
}

generate_summary_md() {
    echo_alert_nl "Generating test summary markdown"

    local listed_scenarios=$(cat $arg_scenario_list_path)
    local timed_out_scenarios=$(cat $current_log_path/$TIMEOUT_LIST_FILE_NAME)

    cat <<EOT > $LOG_DIR/$SUMMARY_FILE_NAME

# Run Scenario List - Test Summary
- Time: $start_time
- Scenario list: $arg_scenario_list_path
- Num steps: $arg_num_steps
- Timeout (seconds): $arg_timeout

## Scenario List
\`\`\`
$listed_scenarios
\`\`\`

## Timeout List
\`\`\`
$timed_out_scenarios
\`\`\`

EOT
}


###################################################################
# Main
###################################################################

help "${1}"

# Command line arguments
arg_scenario_list_path=$1 
arg_num_steps=$2
arg_timeout=$3

# Initialising variables
base_dir=$(pwd)
repo_path=${base_dir%%/$PARENT_DIR*} # Assumes the ancestor directory of this testing script is in the 'tests' directory

start_time=$(date +%Y-%m-%d_%H-%M-%S)

echo "" > $WORKFLOW_ENV_FILE_NAME # Clear env file
echo "LATEST_LOG_TIME=$start_time" >> $WORKFLOW_ENV_FILE_NAME # Save log time

current_log_path=$LOG_DIR/$start_time

has_timeout=false

# Env files
source $repo_path/.env

# Check if at least one arg is supplied
if [ "$#" -lt 1 ]; then
    echo_alert_nl "No arguments supplied. Use -h or -help for more information."
    exit 1
fi

# Check if scenario list file exists
if ! [ -e "$arg_scenario_list_path" ]; then
    echo_alert_nl "File not found: $arg_scenario_list_path - Please check you have created a file in this directory containing the scenarios to be tested."
    exit 1
fi

# Check if timeout is given, else check if is a positive, non-zero integer
if [ -z "$arg_timeout" ]; then
    arg_timeout=$DEFAULT_TIMEOUT_SECONDS
elif [[ ! "$arg_timeout" =~ ^[1-9][0-9]*$ ]]; then
    echo_alert_nl "Invalid timeout duration: $arg_timeout"
    exit 1
fi

# Create log directory for the current scenario list
mkdir -p $current_log_path
touch $current_log_path/$TIMEOUT_LIST_FILE_NAME
touch $current_log_path/$RUN_SETTING_LOG_FILE_NAME

cat <<EOT >> $current_log_path/$RUN_SETTING_LOG_FILE_NAME
Run settings:
- Scenario list: $arg_scenario_list_path
- Num steps: $arg_num_steps
- Timeout: $arg_timeout
EOT

# Read file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Remove any spaces from the line
    scenario=$(echo $line | tr -d '[:space:]')

    if [ -z "$scenario" ]; then
        # Skip empty lines
        continue
    fi

    run_scenario "$scenario"
done < "$arg_scenario_list_path"

generate_summary_md

# Produce the appropriate exit code
if [ "$has_timeout" = true ]; then
    echo_alert_nl "###################################################################"
    echo_alert "The following scenarios timed out after not producing any output for $arg_timeout seconds"
    echo_alert "###################################################################"
    
    echo "$(<$current_log_path/$TIMEOUT_LIST_FILE_NAME )"
    exit 1
else 
    echo_alert_nl "Finished with no scenarios timing out"
    exit 0
fi
