#!/usr/bin/env bash
set -euo pipefail
umask 022

# Vollstaendig eigenstaendig; bestehende Projekte/Konfigurationen bleiben erhalten.
tools=/workspace/.re-tools
prefix=/workspace/.rea-cli
state=/workspace/.re-cloud-setup
jdk="$tools/temurin-21.0.12.1"
ghidra="$tools/ghidra_12.1.4_PUBLIC"
partial=''
stage=''
die() { printf '%s\n' "$*" >&2; exit 1; }
cleanup() {
  [[ -z "$partial" ]] || rm -f -- "$partial"
  [[ -z "$stage" ]] || rm -rf -- "$stage"
}
trap cleanup EXIT

[[ "$(uname -s)" = Linux && "$(uname -m)" = x86_64 ]] || die 'Linux x86-64 erforderlich.'
for cmd in node npm curl tar unzip sha256sum sha512sum cmp flock; do
  command -v "$cmd" >/dev/null || die "Fehlendes Basiswerkzeug: $cmd"
done
node -e 'const [m,n]=process.versions.node.split(".").map(Number); if(!((m===22&&n>=19)||(m===24&&n>=11)||m>=26))process.exit(1)' \
  || die 'REA erfordert Node 22.19+, 24.11+ oder 26+ in der jeweiligen Hauptversion.'
mkdir -p "$tools/downloads" "$state/fixture" /workspace/work /workspace/.cache/npm
exec 9>"$tools/.cloud-install.lock"
flock -n 9 || die 'Ein weiterer Cloud-Installer laeuft bereits.'

# Rund 742 MiB Archive + 1,2 GiB entpackte Werkzeuge; Reserve fuer Staging.
if [[ ! -d "$jdk" || ! -d "$ghidra" ]]; then
  free_kib="$(df --output=avail "$tools" | tail -1 | tr -d ' ')"
  (( free_kib >= 3 * 1024 * 1024 )) || die 'Mindestens 3 GiB freier Speicher erforderlich.'
fi
if [[ -r /sys/fs/cgroup/memory.max ]]; then
  memory_limit="$(cat /sys/fs/cgroup/memory.max)"
  if [[ "$memory_limit" =~ ^[0-9]+$ ]]; then
    (( memory_limit >= 4 * 1024 * 1024 * 1024 )) || die 'Fuer Ghidra mindestens 4 GiB RAM vorsehen.'
  fi
fi

verify() { printf '%s  %s\n' "$3" "$1" | "$2" --check --status; }
fetch() {
  local url="$1" file="$2" algorithm="$3" digest="$4"
  if [[ ! -f "$file" ]]; then
    [[ ! -e "$file" && ! -L "$file" ]] || die "Ungeeigneter Archivpfad: $file"
    partial="$(mktemp "$tools/downloads/.download.XXXXXX")"
    # Cloud-Proxy und TLS-Pruefung bleiben aktiviert; keine Netzwerksperren umgehen.
    curl --fail --location --silent --show-error --retry 2 \
      --connect-timeout 30 --max-time 600 "$url" -o "$partial"
    verify "$partial" "$algorithm" "$digest" || die "Pruefsumme falsch: $url"
    mv "$partial" "$file"
    partial=''
  fi
  verify "$file" "$algorithm" "$digest" || die "Vorhandenes Archiv hat falsche Pruefsumme: $file"
}

rea_archive="$tools/downloads/rea-agents-6.1.0.tgz"
jdk_archive="$tools/downloads/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12.1_1.tar.gz"
ghidra_archive="$tools/downloads/ghidra_12.1.4_PUBLIC_20260921.zip"
rea_sha512=c6c5c589712dda1739b6cfb35f70fccddc991cae4695ba7c185612207319cad0e2502180429d9cac39a4a3289734d6d75dcbde9b6dbc87e939e3150e6029c8ed
jdk_sha256=ce79869e1307ed8ee1e2baa86a412b1eb5b75d10a01006d788a6f968bcfaee94
ghidra_sha256=ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db

# Auch behaltene Archive pruefen; bereits installierte Werkzeuge nicht herunterladen.
for record in "$rea_archive|sha512sum|$rea_sha512" "$jdk_archive|sha256sum|$jdk_sha256" "$ghidra_archive|sha256sum|$ghidra_sha256"; do
  IFS='|' read -r file algorithm digest <<< "$record"
  if [[ -f "$file" ]]; then
    verify "$file" "$algorithm" "$digest" || die "Archivpruefung fehlgeschlagen: $file"
  fi
done

if [[ -x "$prefix/bin/rea" ]]; then
  [[ "$("$prefix/bin/rea" --version)" = 6.1.0 ]] || die 'Vorhandene andere REA-Version wird nicht ueberschrieben.'
else
  [[ ! -e "$prefix/lib/node_modules/rea-agents" && ! -L "$prefix/bin/rea" ]] \
    || die 'Unvollstaendige REA-Installation; zuerst pruefen, nicht ueberschreiben.'
  fetch 'https://registry.npmjs.org/rea-agents/-/rea-agents-6.1.0.tgz' "$rea_archive" sha512sum "$rea_sha512"
  NPM_CONFIG_CACHE=/workspace/.cache/npm NPM_CONFIG_UPDATE_NOTIFIER=false \
    npm install --global --prefix "$prefix" --registry=https://registry.npmjs.org \
      --no-audit --no-fund "$rea_archive"
fi
[[ "$("$prefix/bin/rea" --version)" = 6.1.0 ]] || die 'REA-Versionspruefung fehlgeschlagen.'

if [[ ! -e "$jdk" ]]; then
  fetch 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1%2B1/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12.1_1.tar.gz' \
    "$jdk_archive" sha256sum "$jdk_sha256"
  stage="$(mktemp -d "$tools/.jdk-stage.XXXXXX")"
  tar -xzf "$jdk_archive" --strip-components=1 -C "$stage"
  [[ -x "$stage/bin/java" && -x "$stage/bin/javac" ]] || die 'JDK unvollstaendig.'
  mv "$stage" "$jdk"
  stage=''
fi
[[ -x "$jdk/bin/java" && -x "$jdk/bin/javac" ]] || die 'Vorhandenes JDK unvollstaendig; keine Ueberschreibung.'
grep -qx 'IMPLEMENTOR_VERSION="Temurin-21.0.12.1+1"' "$jdk/release" || die 'Unerwartete JDK-Version.'
[[ "$("$jdk/bin/javac" -version 2>&1)" = 'javac 21.0.12.1' ]] || die 'JDK nicht ausfuehrbar.'

if [[ ! -e "$ghidra" ]]; then
  fetch 'https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip' \
    "$ghidra_archive" sha256sum "$ghidra_sha256"
  stage="$(mktemp -d "$tools/.ghidra-stage.XXXXXX")"
  unzip -q "$ghidra_archive" -d "$stage"
  [[ -x "$stage/ghidra_12.1.4_PUBLIC/support/analyzeHeadless" ]] || die 'Ghidra unvollstaendig.'
  mv "$stage/ghidra_12.1.4_PUBLIC" "$ghidra"
  rmdir "$stage"
  stage=''
fi
[[ -x "$ghidra/support/analyzeHeadless" ]] || die 'Vorhandenes Ghidra unvollstaendig; keine Ueberschreibung.'
grep -qx 'application.version=12.1.4' "$ghidra/Ghidra/application.properties" || die 'Unerwartete Ghidra-Version.'

# Neue Startdateien nur anlegen oder identische eigene Dateien wiederverwenden.
save_file() {
  local target="$1" mode="$2" temporary
  temporary="$(mktemp "$state/.text.XXXXXX")"
  cat > "$temporary"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" || ! -f "$target" ]] || ! cmp -s "$temporary" "$target"; then
      rm -f "$temporary"
      die "Vorhandene geaenderte Datei bleibt erhalten: $target"
    fi
    rm -f "$temporary"
    [[ "$mode" != 755 || -x "$target" ]] || die "Ausfuehrungsrecht fehlt: $target"
  else
    chmod "$mode" "$temporary"
    mv "$temporary" "$target"
  fi
}
save_file "$state/activate.sh" 644 <<'EOF'
export JAVA_HOME=/workspace/.re-tools/temurin-21.0.12.1
export GHIDRA_INSTALL_DIR=/workspace/.re-tools/ghidra_12.1.4_PUBLIC
export GHIDRA_HEADLESS_MAXMEM="${GHIDRA_HEADLESS_MAXMEM:-2G}"
export REA_ANALYSIS_PROVIDER="${REA_ANALYSIS_PROVIDER:-ghidra}"
export REA_GHIDRA_STARTUP_TIMEOUT_MS="${REA_GHIDRA_STARTUP_TIMEOUT_MS:-330000}"
case ":$PATH:" in
  *:/workspace/.rea-cli/bin:*) ;;
  *) export PATH="/workspace/.rea-cli/bin:$PATH" ;;
esac
case ":$PATH:" in
  *:"$JAVA_HOME/bin":*) ;;
  *) export PATH="$JAVA_HOME/bin:$PATH" ;;
esac
EOF
save_file "$state/rea" 755 <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source /workspace/.re-cloud-setup/activate.sh
if (( $# == 0 )); then set -- mcp; fi
exec /workspace/.rea-cli/bin/rea "$@"
EOF
save_file "$state/fixture/sample.js" 644 <<'EOF'
import { basename } from "node:path";
export function describeFile(filePath) {
  return `REA smoke test: ${basename(filePath)}`;
}
export const testVersion = "1.0.0";
EOF
save_file "$state/codex-mcp.example.toml" 644 <<'EOF'
[mcp_servers.rea]
command = "/workspace/.re-cloud-setup/rea"
args = ["mcp"]
EOF
source "$state/activate.sh"
rea capabilities --format json >/dev/null
printf 'Bereit: REA 6.1.0, Ghidra 12.1.4, Temurin 21.0.12.1+1.\n'
printf 'CLI/MCP: /workspace/.re-cloud-setup/rea\n'
printf 'Neue Shells: source /workspace/.re-cloud-setup/activate.sh\n'
