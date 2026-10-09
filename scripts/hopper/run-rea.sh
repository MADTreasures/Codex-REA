#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
if [[ $(task_docker inspect --format '{{.State.Running}}' "$task_container") != true ]]; then
    task_docker start "$task_container" >/dev/null
fi
# Pass CLI arguments unchanged. --mcp serves REA stdio without registration changes.
exec env -u DOCKER_HOST -u DOCKER_CONTEXT -u DOCKER_TLS \
    -u DOCKER_TLS_VERIFY -u DOCKER_CERT_PATH \
    docker --host=unix:///var/run/docker.sock exec -i --workdir /work \
    -e REA_ANALYSIS_PROVIDER=hopper -e HOPPER_LAUNCHER_PATH=/opt/hopper/bin/Hopper \
    "$task_container" node /opt/rea/scripts/rea.mjs "$@"
