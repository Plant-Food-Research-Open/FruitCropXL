#!/usr/bin/env bash
set -euo pipefail

GROIMP_DIR="${GROIMP_DIR:-/usr/share/GroIMP}"

base_dir="$(pwd)"
project_host="${base_dir}/Scripts/project.gs"
apptainer_image="${APPTAINER_IMAGE_PATH:-${base_dir}/images/groimp.sif}"

[[ -f "${project_host}" ]] || {
  echo "GroIMP project not found: ${project_host}" >&2
  exit 1
}
[[ -f "${apptainer_image}" ]] || {
  echo "GroIMP Apptainer image not found: ${apptainer_image}" >&2
  echo "Download it with: bash bash_scripts/apptainer_pull.sh" >&2
  exit 1
}
command -v apptainer >/dev/null 2>&1 || {
  echo "apptainer command not found" >&2
  exit 1
}

x11_args=()
xauthority_host="${XAUTHORITY:-${HOME}/.Xauthority}"
if [[ -n "${DISPLAY:-}" && -d /tmp/.X11-unix && -f "${xauthority_host}" ]]; then
  if command -v xhost >/dev/null 2>&1; then
    echo "Granting X11 access for local user: ${USER:-user}"
    xhost +SI:localuser:"${USER:-user}" >/dev/null
    cleanup_xhost() {
      xhost -SI:localuser:"${USER:-user}" >/dev/null || true
    }
    trap cleanup_xhost EXIT
  fi
  x11_args+=(
    --env "DISPLAY=${DISPLAY}"
    --env "XAUTHORITY=${xauthority_host}"
    --bind /tmp/.X11-unix:/tmp/.X11-unix
    --bind "${xauthority_host}:${xauthority_host}"
  )
else
  echo "DISPLAY, X11 socket, or Xauthority is unavailable; the GroIMP GUI may not open" >&2
fi

apptainer exec --nv \
  "${x11_args[@]}" \
  --bind "${base_dir}:/var/model" \
  "${apptainer_image}" \
  java -XX:+UseContainerSupport \
       -XX:ActiveProcessorCount=10 \
       -XX:+UseSerialGC \
       -Xms2g -Xmx14g -Xss2m \
       -XX:+AlwaysPreTouch \
       -noverify \
       -jar "${GROIMP_DIR}/core.jar" \
       -Xreset="true" -XmodelPath="/var/model/" \
       -XnCores="7" "/var/model/Scripts/$(basename "${project_host}")"
