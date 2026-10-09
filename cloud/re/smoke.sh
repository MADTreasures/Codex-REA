#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/activate.sh"
run_dir="${1:-$(mktemp -d /workspace/work/re-smoke.XXXXXX)}"
mkdir -p "$run_dir/home" "$run_dir/tmp" "$run_dir/project"
run_dir="$(cd "$run_dir" && pwd)"
gcc -O0 -g -fno-inline -fno-pie -no-pie "$script_dir/fixture.c" -o "$run_dir/fixture.elf"
"$run_dir/fixture.elf" | tee "$run_dir/fixture-output.txt"
sha256sum "$run_dir/fixture.elf" > "$run_dir/fixture.sha256"
JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Duser.home=$run_dir/home -Djava.io.tmpdir=$run_dir/tmp" \
  "$GHIDRA_INSTALL_DIR/support/analyzeHeadless" "$run_dir/project" Smoke \
    -import "$run_dir/fixture.elf" -overwrite -max-cpu 2 -analysisTimeoutPerFile 120 \
    -scriptPath "$script_dir" -postScript ExportSmoke.java "$run_dir/headless-decompilation.c" \
    -log "$run_dir/headless.log" > "$run_dir/headless.stdout" 2>&1
grep -q 'REA_HEADLESS_SMOKE_OK functions=3' "$run_dir/headless.stdout"
rea analyze "$run_dir/fixture.elf" --provider ghidra --format json > "$run_dir/rea-analysis.json"
rea search "$run_dir/fixture.elf" re_ --kind procedures --provider ghidra --format json > "$run_dir/rea-functions.json"
rea function "$run_dir/fixture.elf" re_add --provider ghidra --format json > "$run_dir/rea-function.json"
rea decompile "$run_dir/fixture.elf" re_add --provider ghidra --format json > "$run_dir/rea-decompilation.json"
python3 "$script_dir/verify-results.py" "$run_dir"
echo "Results saved to $run_dir"
