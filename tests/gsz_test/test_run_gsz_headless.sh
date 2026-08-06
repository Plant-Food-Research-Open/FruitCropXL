#!/bin/bash
GROIMP_DIR=/usr/share/GroIMP

###################################################################
# Main
###################################################################

if [ -z "$1" ]; then
 . .env
fi  

usage() {
    echo """
    ###############################################################
    Help:

    * Description:
        - Runs the project archive (.gsz) headlessly with a timeout guard.
    * Example usage:
        - $0 [project gsz path] [timeout seconds] [model arguments]
    * Parameters:
        - project gsz path: The path to the project archive.
        - timeout: The maximum number of seconds allowed before the guard terminates the run.

    ###############################################################
    """    
}

help() {
    if [ "${1}" = "-h" ] || [ "${1}" = "-help" ]; then
        usage
        exit 0
    fi
}




###################################################################
# Main
###################################################################

help "${1}"

# Command line arguments
project_gsz_path=$1
cli_timeout_sec=$2


# Check if at least one arg is supplied
if [ "$#" -lt 1 ]; then
    echo "No arguments supplied. Use -h or -help for more information."
    exit 1
fi

if [ -z "$project_gsz_path" ]; then
    echo "Path to project archive was not supplied."
    exit 1
fi

timeout_sec="${GROIMP_TIMEOUT_SEC:-$cli_timeout_sec}"

if [ -z "$timeout_sec" ]; then
    echo "Number of seconds before timeout was not supplied."
    exit 1
fi


base_dir=$(pwd)
log_root="${base_dir}/logs"
log_dir="${log_root}/gsz-test"
stdout_log="${log_dir}/stdout.log"
stderr_log="${log_dir}/stderr.log"
prefs_user_host="${log_dir}/java_prefs_user"
prefs_sys_host="${log_dir}/java_prefs_system"
tmp_host="${log_dir}/tmp"
run_marker="${log_dir}/run.marker"
kill_after_sec="${GROIMP_TIMEOUT_KILL_AFTER_SEC:-30}"

groimp_java_xms="${GROIMP_JAVA_XMS:-512m}"
groimp_java_xmx="${GROIMP_JAVA_XMX:-2G}"
groimp_java_xss="${GROIMP_JAVA_XSS:-2m}"
groimp_java_active_processors="${GROIMP_JAVA_ACTIVE_PROCESSORS:-2}"
groimp_model_ncores="${GROIMP_MODEL_NCORES:-2}"

mkdir -p "$log_dir" "$prefs_user_host" "$prefs_sys_host" "$tmp_host"
: > "$stdout_log"
: > "$stderr_log"
touch "$run_marker"

ulimit -c 0 || true

prefs_user="/var/model/logs/gsz-test/java_prefs_user"
prefs_sys="/var/model/logs/gsz-test/java_prefs_system"
tmp_dir="/var/model/logs/gsz-test/tmp"

timeout_cmd=(timeout --signal=TERM)
if timeout --help 2>&1 | grep -q -- '--kill-after'; then
    timeout_cmd+=(--kill-after="${kill_after_sec}s")
fi
timeout_cmd+=("${timeout_sec}s")

run_cmd=(
    "${timeout_cmd[@]}"
    apptainer exec
    --bind "${base_dir}:/var/model"
    "${base_dir}/images/groimp.sif"
    java
    -Djava.awt.headless=true
    -Djava.util.prefs.userRoot="${prefs_user}"
    -Djava.util.prefs.systemRoot="${prefs_sys}"
    -Djava.io.tmpdir="${tmp_dir}"
    -XX:+UseContainerSupport
    -XX:+UseSerialGC
    -XX:-TieredCompilation
    -XX:CICompilerCount=1
    -XX:ActiveProcessorCount="${groimp_java_active_processors}"
    -XX:ErrorFile=/var/model/logs/hs_err_pid%p.log
    -Xms"${groimp_java_xms}"
    -Xmx"${groimp_java_xmx}"
    -Xss"${groimp_java_xss}"
    -noverify
    -jar "${GROIMP_DIR}/core.jar"
    --headless
    -XmodelPath="/var/model/"
    -XmodelOptions="model.options.gszTest.dynamicApple.json"
    -XnCores="${groimp_model_ncores}"
    "${@:3}"
    "${project_gsz_path}"
)

echo "Scripts.gsz launcher settings:"
echo "  project archive : ${project_gsz_path}"
echo "  timeout guard   : ${timeout_sec} sec"
echo "  timeout grace   : ${kill_after_sec}"
echo "  java xms/xmx    : ${groimp_java_xms}/${groimp_java_xmx}"
echo "  java xss        : ${groimp_java_xss}"
echo "  active procs    : ${groimp_java_active_processors}"
echo "  model nCores    : ${groimp_model_ncores}"
echo "  stdout log      : ${stdout_log}"
echo "  stderr log      : ${stderr_log}"

set +e
APPTAINERENV_TMPDIR="${tmp_dir}" \
APPTAINERENV_TMP="${tmp_dir}" \
APPTAINERENV_TEMP="${tmp_dir}" \
"${run_cmd[@]}" \
    > >(tee "$stdout_log") \
    2> >(tee "$stderr_log" >&2)
exit_status=$?
set -e

mapfile -t hs_err_logs < <(find "$log_root" -maxdepth 1 -name 'hs_err_pid*.log' -type f -newer "$run_marker" | sort)

report_hs_err_logs() {
    local hs_err_log
    for hs_err_log in "${hs_err_logs[@]}"; do
        echo "Detected JVM crash log: ${hs_err_log}"
        echo "--- hs_err head (${hs_err_log}) ---"
        head -n 20 "$hs_err_log" || true
        echo "--- hs_err tail (${hs_err_log}) ---"
        tail -n 20 "$hs_err_log" || true
    done
}

if [[ $exit_status -eq 124 ]]; then
    if [[ ${#hs_err_logs[@]} -gt 0 ]]; then
        echo "ERROR: ${project_gsz_path} exceeded the ${timeout_sec}-second guard, and the JVM produced a fatal crash log while handling timeout shutdown."
        report_hs_err_logs
    else
        echo "ERROR: ${project_gsz_path} exceeded the ${timeout_sec}-second guard (TERM then KILL after ${kill_after_sec} seconds if needed)."
    fi
    echo "Launcher stdout log: ${stdout_log}"
    echo "Launcher stderr log: ${stderr_log}"
    exit 1
fi

if [[ $exit_status -ne 0 ]]; then
    if [[ ${#hs_err_logs[@]} -gt 0 ]] || [[ $exit_status -ge 128 ]]; then
        echo "ERROR: ${project_gsz_path} crashed or was terminated by signal (exit code ${exit_status})."
        report_hs_err_logs
    else
        echo "ERROR: ${project_gsz_path} failed with non-zero exit code ${exit_status}."
    fi
    echo "Launcher stdout log: ${stdout_log}"
    echo "Launcher stderr log: ${stderr_log}"
    exit 1
fi

echo "Scripts.gsz headless run completed successfully."
