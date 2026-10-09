#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
rea_prefix="${REA_CLOUD_REA_PREFIX:-/workspace/.rea-cli}"
target="${1:?Usage: preflight.sh ABSOLUTE_ELF}"
test -f "$target"
helper="$rea_prefix/lib/node_modules/rea-agents/scripts/hopper-demo-x11.py"
test -f "$helper"
export BUILDX_CONFIG="${BUILDX_CONFIG:-/workspace/work/re-cloud/buildx}"
mkdir -p "$BUILDX_CONFIG"
docker_local() {
  env -u DOCKER_HOST -u DOCKER_CONTEXT -u DOCKER_TLS -u DOCKER_TLS_VERIFY -u DOCKER_CERT_PATH \
    docker --host=unix:///var/run/docker.sock "$@"
}
docker_local info >/dev/null
docker_local build --secret id=system_ca,src=/etc/ssl/certs/ca-certificates.crt \
  -t rea-hopper-ubuntu-preflight:24.04 "$script_dir"
# This checks the prerequisites, not Hopper. No license or proprietary binary is included.
docker_local run --rm --network none --user 1000:1000 --cap-drop ALL \
  --security-opt no-new-privileges \
  --mount "type=bind,src=$target,dst=/analysis/fixture.elf,readonly" \
  --mount "type=bind,src=$helper,dst=/analysis/hopper-demo-x11.py,readonly" \
  rea-hopper-ubuntu-preflight:24.04 bash -c '
    set -e
    cat /etc/os-release
    file /analysis/fixture.elf
    sha256sum /analysis/fixture.elf
    dpkg-query -W xvfb xauth libqt6core6t64 libqt6widgets6t64 libpython3.12t64 libxcb-cursor0
    library_report="$(ldd /usr/lib/x86_64-linux-gnu/libQt6Widgets.so.6)"
    printf "%s\n" "$library_report"
    case "$library_report" in *"not found"*) exit 1;; esac
    /usr/bin/python3 /analysis/hopper-demo-x11.py --probe --strategy direct
  '
