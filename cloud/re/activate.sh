#!/usr/bin/env bash
# Source this file; it does not edit shell profiles or the original REA setup.
export REA_CLOUD_TOOLS_ROOT="${REA_CLOUD_TOOLS_ROOT:-/workspace/.re-tools}"
export REA_CLOUD_REA_PREFIX="${REA_CLOUD_REA_PREFIX:-/workspace/.rea-cli}"
export JAVA_HOME="$REA_CLOUD_TOOLS_ROOT/temurin-21.0.12.1"
export GHIDRA_INSTALL_DIR="$REA_CLOUD_TOOLS_ROOT/ghidra_12.1.4_PUBLIC"
export GHIDRA_HEADLESS_MAXMEM="${GHIDRA_HEADLESS_MAXMEM:-2G}"
export REA_ANALYSIS_PROVIDER="${REA_ANALYSIS_PROVIDER:-ghidra}"
export REA_GHIDRA_STARTUP_TIMEOUT_MS="${REA_GHIDRA_STARTUP_TIMEOUT_MS:-330000}"
export PATH="$JAVA_HOME/bin:$REA_CLOUD_REA_PREFIX/bin:$PATH"
