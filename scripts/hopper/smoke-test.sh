#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
command -v gcc >/dev/null || task_error 'Existing host gcc required; no compiler is installed automatically.'
mkdir -p "$task_state"
gcc -O0 -g -fno-inline -fno-pie -no-pie "$task_repo/scripts/hopper/harmless.c" -o "$task_state/harmless.elf"
cp "$task_repo/scripts/hopper/smoke.mjs" "$task_state/smoke.mjs"
task_docker exec -e REA_ANALYSIS_PROVIDER=hopper -e HOPPER_LAUNCHER_PATH=/opt/hopper/bin/Hopper \
    "$task_container" timeout -k 1s 59s node /work/smoke.mjs
task_docker exec -e REA_ANALYSIS_PROVIDER=hopper -e HOPPER_LAUNCHER_PATH=/opt/hopper/bin/Hopper \
    "$task_container" sh -c 'timeout -k 1s 59s node /opt/rea/scripts/rea.mjs function /work/harmless.elf demo_add --provider hopper --json > /work/function-results.json'
task_docker exec "$task_container" node -e 'const d=JSON.parse(require("fs").readFileSync("/work/function-results.json")); if(d.provider?.id!=="hopper" || d.operation!=="analyze_function" || d.normalized_result?.procedure?.name!=="demo_add" || !d.normalized_result.assembly?.length || !d.normalized_result.pseudocode) throw Error("Invalid Hopper function evidence"); console.log("PASS: production REA analyze_function returned Hopper evidence");'
