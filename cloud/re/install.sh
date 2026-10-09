#!/usr/bin/env bash
set -euo pipefail

# Additive, unprivileged installation. Preserve the published REA directories.
tools_root="${REA_CLOUD_TOOLS_ROOT:-/workspace/.re-tools}"
rea_prefix="${REA_CLOUD_REA_PREFIX:-/workspace/.rea-cli}"
mkdir -p "$tools_root/downloads"
test "$(uname -m)" = x86_64 || { echo 'This configuration requires Linux x86-64.' >&2; exit 1; }
for utility in curl tar unzip sha256sum node npm; do command -v "$utility" >/dev/null; done

fetch_verified() {
  local url="$1" archive="$2" digest="$3"
  if [[ ! -f "$archive" ]]; then
    local partial
    partial="$(mktemp "$tools_root/downloads/.download.XXXXXX")"
    if ! curl --fail --location --silent --show-error --retry 2 --connect-timeout 30 --max-time 600 "$url" -o "$partial"; then
      rm -f "$partial"; return 1
    fi
    if ! printf '%s  %s\n' "$digest" "$partial" | sha256sum --check --status; then
      rm -f "$partial"; echo "Checksum mismatch: $url" >&2; return 1
    fi
    mv "$partial" "$archive"
  fi
  printf '%s  %s\n' "$digest" "$archive" | sha256sum --check --status
}

if [[ ! -x "$rea_prefix/bin/rea" ]]; then
  NPM_CONFIG_PREFIX="$rea_prefix" NPM_CONFIG_CACHE=/workspace/.cache/npm \
    npm install --global --no-audit --no-fund rea-agents@6.1.0
fi
test "$("$rea_prefix/bin/rea" --version)" = 6.1.0

jdk_dir="$tools_root/temurin-21.0.12.1"
ghidra_dir="$tools_root/ghidra_12.1.4_PUBLIC"
if [[ ! -x "$jdk_dir/bin/javac" || ! -x "$ghidra_dir/support/analyzeHeadless" ]]; then
  available_kb="$(df --output=avail "$tools_root" | tail -1 | tr -d ' ')"
  (( available_kb >= 2500000 )) || { echo 'At least 2.5 GB free space is required.' >&2; exit 1; }
fi

if [[ ! -d "$jdk_dir" ]]; then
  archive="$tools_root/downloads/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12.1_1.tar.gz"
  fetch_verified 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1%2B1/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12.1_1.tar.gz' \
    "$archive" ce79869e1307ed8ee1e2baa86a412b1eb5b75d10a01006d788a6f968bcfaee94
  staging="$(mktemp -d "$tools_root/.jdk-stage.XXXXXX")"
  tar -xzf "$archive" --strip-components=1 -C "$staging"
  test -x "$staging/bin/java" && test -x "$staging/bin/javac"
  mv "$staging" "$jdk_dir"
fi

if [[ ! -d "$ghidra_dir" ]]; then
  archive="$tools_root/downloads/ghidra_12.1.4_PUBLIC_20260921.zip"
  fetch_verified 'https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip' \
    "$archive" ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db
  staging="$(mktemp -d "$tools_root/.ghidra-stage.XXXXXX")"
  unzip -q "$archive" -d "$staging"
  test -x "$staging/ghidra_12.1.4_PUBLIC/support/analyzeHeadless"
  mv "$staging/ghidra_12.1.4_PUBLIC" "$ghidra_dir"
  rmdir "$staging"
fi

test -x "$jdk_dir/bin/java" && test -x "$jdk_dir/bin/javac"
test -x "$ghidra_dir/support/analyzeHeadless"
grep -qx 'application.version=12.1.4' "$ghidra_dir/Ghidra/application.properties"
"$jdk_dir/bin/javac" -version
echo "REA 6.1.0 and Ghidra 12.1.4 ready at $tools_root."
