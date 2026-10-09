---
name: rea-ghidra-cloud-start
description: REA 6.1.0 und Ghidra 12.1.4 in dieser Codex-Cloud-Aufgabe starten und die wiederhergestellte Installation pruefen.
---

Diese Umgebung verwendet REA 6.1.0, Ghidra 12.1.4 und das vollstaendige
Temurin-JDK 21.0.12.1+1. Native Analyse verwendet Ghidra. Die statische
JavaScript-Analyse bleibt verfuegbar und benoetigt kein Hopper.

Nutze fuer CLI-Aufrufe `/workspace/.re-cloud-setup/rea`. Dieser Wrapper setzt
JAVA_HOME, GHIDRA_INSTALL_DIR und PATH bei jedem Aufruf. Fuer eine Bash-Shell:
`source /workspace/.re-cloud-setup/activate.sh`. Exporte aus dem Installationslauf
sind keine dauerhaft gesetzten Variablen jeder spaeteren Shell.

Fuehre den folgenden Test einmal zu Beginn einer frischen Cloud-Aufgabe aus.
Pruefe vorhandene Dateien zuerst; lade Ghidra/JDK bei vorhandener Installation
nicht erneut herunter. Falls Setup-Dateien fehlen, melde den fehlenden
Setup-Schritt. Ein erneuter Installationslauf ist nur ueber das gepruefte
Installationsskript und die geltende Cloud-Netzwerkfreigabe zulaessig.

```bash
set -euo pipefail
source /workspace/.re-cloud-setup/activate.sh
test "$(/workspace/.re-cloud-setup/rea --version)" = 6.1.0
test "$(javac -version 2>&1)" = 'javac 21.0.12.1'
test -x "$GHIDRA_INSTALL_DIR/support/analyzeHeadless"
grep -qx 'application.version=12.1.4' "$GHIDRA_INSTALL_DIR/Ghidra/application.properties"
mkdir -p /workspace/work
check_dir="$(mktemp -d /workspace/work/rea-start.XXXXXX)"
/workspace/.re-cloud-setup/rea analyze-javascript-application \
  /workspace/.re-cloud-setup/fixture --format json > "$check_dir/javascript.json"
cat > "$check_dir/smoke.c" <<'C'
#include <stdio.h>
__attribute__((noinline)) int re_add(int left, int right) { return left + right; }
int main(void) { printf("REA harmless ELF fixture: %d\n", re_add(9, 3)); return 0; }
C
gcc -O0 -g -fno-inline -fno-pie -no-pie "$check_dir/smoke.c" -o "$check_dir/smoke.elf"
test "$("$check_dir/smoke.elf")" = 'REA harmless ELF fixture: 12'
/workspace/.re-cloud-setup/rea function "$check_dir/smoke.elf" re_add \
  --provider ghidra --format json > "$check_dir/function.json"
node - "$check_dir" <<'JS'
const fs = require('node:fs');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const dir = process.argv[2];
const js = fs.readFileSync(`${dir}/javascript.json`, 'utf8');
JSON.parse(js);
for (const value of ['sample.js', 'node:path', 'describeFile']) assert(js.includes(value));
const fn = JSON.parse(fs.readFileSync(`${dir}/function.json`, 'utf8'));
const digest = crypto.createHash('sha256').update(fs.readFileSync(`${dir}/smoke.elf`)).digest('hex');
assert.equal(fn.provider.id, 'ghidra');
assert.equal(fn.provider.version, '12.1.4');
assert.equal(fn.subject.digest.sha256, digest);
assert.equal(fn.normalized_result.procedure.name, 're_add');
assert(fn.normalized_result.assembly.length > 0);
assert(fn.normalized_result.pseudocode.includes('return right + left;'));
console.log('REA_START_OK: JavaScript und echte Ghidra-ELF-Analyse bestaetigt.');
JS
```

Nutze fuer einen MCP-Server `/workspace/.re-cloud-setup/rea mcp`. Eine passende
Registrierung steht in `/workspace/.re-cloud-setup/codex-mcp.example.toml`.
Das Installationsskript registriert MCP nicht automatisch und ueberschreibt
keine bestehende Codex-Konfiguration. Lokale Prozess-/Socket-Kommunikation
muss von der Ausfuehrungssandbox erlaubt sein; Internetdownloads bleiben
an die Cloud-Netzwerkpolicy gebunden.

Halte Analyseergebnisse unter `/workspace/work/`. Bewahre vorhandene Projekte,
Konfigurationen und Aenderungen. Veröffentliche keine Zugangsdaten,
Cloud-Metadaten, privaten Logs oder heruntergeladenen Binaerprogramme.
Der Standard-Heap betraegt 2 GiB je Ghidra-Prozess. Vermeide mehrere parallele
Ghidra-Starts bei knappen Ressourcen; verwende laufende MCP-Sitzungen weiter.
Die Installation braucht etwa 2 GiB inklusive Archive und verlangt beim
Neuaufbau mindestens 3 GiB freien Speicher und 4 GiB RAM als cgroup-Limit.

`rea doctor` darf auf Debian insgesamt negativ bleiben. Ghidra-Verfuegbarkeit
und tatsaechliche Analyse werden durch den obigen Test getrennt geprueft.
Ein erfolgreicher Test in dieser Sitzung beweist keine Wiederherstellung in
einer spaeteren Cloud-Aufgabe. Erst nach Neuveroeffentlichung und erfolgreichem
Test in einer frischen Aufgabe ist diese Wiederherstellung nachgewiesen.

Hopper bleibt das naechste Installationsziel. Der bisherige offizielle
Downloadversuch scheiterte mit HTTP 403 am Cloud-Proxy. Debian 13 ist keine
offiziell unterstuetzte Hopper-Plattform; Ubuntu 24.04 ist der vorbereitete
Pruefweg. Nutze ausschliesslich offizielle Installer und den erlaubten
Demo-Modus. Eine Herstellerdomain-Freigabe muss ueber die Cloud-Konfiguration
erfolgen. Keine Proxy-Umgehung, fremden Mirrors, erzwungenen Pakete,
Lizenzumgehungen oder kostenpflichtigen Dienste verwenden.
