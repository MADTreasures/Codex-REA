#!/usr/bin/env bash
set -euo pipefail
# Optional Debian 13 user-local Xvfb. Never changes the system package database.
test "$(uname -m)" = x86_64
grep -qx 'VERSION_ID="13"' /etc/os-release
tools_root="${REA_CLOUD_TOOLS_ROOT:-/workspace/.re-tools}"
mkdir -p "$tools_root/downloads"
packages=(
  'xvfb_21.1.16-1.3+deb13u3_amd64.deb'
  'xserver-common_21.1.16-1.3+deb13u3_all.deb'
)
digests=(
  '365da2b6c93339f34337c434a9489bb6411a240fa47b9f49693d3091745f28c2'
  'dc1d37303c103b23c40cd1ea694c5c6561e0e8dc1734a73c7a0ae0ef080e7fcc'
)
for index in "${!packages[@]}"; do
  archive="$tools_root/downloads/${packages[$index]}"
  if [[ ! -f "$archive" ]]; then
    partial="$(mktemp "$tools_root/downloads/.xvfb-download.XXXXXX")"
    if ! curl --fail --location --silent --show-error --connect-timeout 30 --max-time 120 \
      "https://deb.debian.org/debian/pool/main/x/xorg-server/${packages[$index]}" -o "$partial"; then
      rm -f "$partial"; exit 1
    fi
    if ! printf '%s  %s\n' "${digests[$index]}" "$partial" | sha256sum --check --status; then
      rm -f "$partial"; echo 'Xvfb package checksum mismatch.' >&2; exit 1
    fi
    mv "$partial" "$archive"
  fi
  printf '%s  %s\n' "${digests[$index]}" "$archive" | sha256sum --check --status
done
if [[ ! -d "$tools_root/debian" ]]; then
  staging="$(mktemp -d "$tools_root/.xvfb-stage.XXXXXX")"
  for package in "${packages[@]}"; do dpkg-deb -x "$tools_root/downloads/$package" "$staging"; done
  mv "$staging" "$tools_root/debian"
fi
dependency_output="$(ldd "$tools_root/debian/usr/bin/Xvfb")"
if [[ "$dependency_output" == *'not found'* ]]; then
  printf '%s\n' "$dependency_output" >&2
  echo 'Missing host libraries. Do not force installation; use the Ubuntu preflight.' >&2
  exit 1
fi
echo "User-local Xvfb ready: $tools_root/debian/usr/bin/Xvfb"
# REA 6.1.0's default Hopper launcher specifically expects /usr/bin/Xvfb.
# This local helper is tested with --xvfb; it does not alter that system path.
