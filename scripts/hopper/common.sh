#!/usr/bin/env bash
# Shared local settings; never modifies REA, Ghidra or Docker configuration.
set -euo pipefail
task_repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
task_container=${HOPPER_CONTAINER_NAME:-hopper-rea-642-20261009}
task_state=${HOPPER_STATE_DIR:-/workspace/work/hopper-rea-642}
task_rea=${HOPPER_REA_ROOT:-/workspace/.rea-cli/lib/node_modules/rea-agents}
task_node=${HOPPER_NODE_PATH:-$(command -v node)}
task_image=codex-rea-hopper:6.4.2-ubuntu24.04
task_docker() {
    env -u DOCKER_HOST -u DOCKER_CONTEXT -u DOCKER_TLS \
        -u DOCKER_TLS_VERIFY -u DOCKER_CERT_PATH \
        docker --host=unix:///var/run/docker.sock "$@"
}
task_error() { printf '%s\n' "$*" >&2; exit 1; }
