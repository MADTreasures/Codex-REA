#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/activate.sh"
test -x "$JAVA_HOME/bin/javac"
test -x "$GHIDRA_INSTALL_DIR/support/analyzeHeadless"
if (( $# == 0 )); then set -- mcp; fi
exec "$REA_CLOUD_REA_PREFIX/bin/rea" "$@"
