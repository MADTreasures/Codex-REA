# REA und Ghidra in der Codex-Cloud

Additive Installations- und Startskripte für Linux x86-64, REA 6.1.0, Ghidra
12.1.4 und das vollständige Temurin-JDK 21.0.12.1+1. Ghidra und JDK werden aus
offiziellen Releases geladen und per festgeschriebenem SHA-256 geprüft. Die
Installation benötigt keine Administratorrechte und verändert keine bestehenden
Projektdateien, Systempakete oder REA-Konfigurationen.

```bash
bash /workspace/Codex-REA/cloud/re/install.sh
/workspace/Codex-REA/cloud/re/start-rea.sh doctor --format json
/workspace/Codex-REA/cloud/re/start-rea.sh mcp
```

Für eine interaktive Shell `cloud/re/activate.sh` sourcen. Für Codex-MCP steht
`codex-mcp.example.toml` bereit; die Datei wird nicht automatisch eingetragen.
Der Wrapper setzt JDK, Ghidra und REA-PATH bei jedem Start. Lokale Prozess- und
Socket-Kommunikation muss von der Ausführungssandbox erlaubt sein. Downloads
behalten den Cloud-Proxy und die TLS-Prüfung bei.

## Funktionale Prüfung

```bash
mkdir -p /workspace/work
bash /workspace/Codex-REA/cloud/re/smoke.sh /workspace/work/re-smoke
node /workspace/Codex-REA/cloud/re/mcp-smoke.mjs \
  /workspace/work/re-smoke/fixture.elf /workspace/work/re-smoke/mcp
```

Die eigene harmlose ELF-Datei gibt lediglich `REA harmless ELF fixture: 12` aus.
Der Headless-Test muss `re_add`, `re_score` und `main` dekompilieren. Der REA-Test
prüft Provider-Version, unveränderten Binärhash, Funktionen, Assemblerbefehle und
die tatsächliche Decompilation `return right + left;`. Der MCP-Test ruft
`open_binary`, `search_procedures`, `analyze_function`, `batch_decompile` und
`close_binary` auf. Beide Tests wurden am 9. Oktober 2026 auf Debian 13 erfolgreich
ausgeführt. Der bestehende REA-JavaScript-Workflow bestand ebenfalls CLI- und
MCP-Prüfungen.

Der Heap ist standardmäßig auf 2 GiB pro Ghidra-Prozess begrenzt. Werkzeugdateien
und Downloadarchive benötigen zusammen ungefähr 2 GiB. Analysesitzungen kosten
mehr Startzeit als ein bereits laufender MCP-Server; dessen Verbindung kann für
mehrere Abfragen wiederverwendet werden. In `install.sh` stehen Versionen und
Checksummen für eine wiederholbare Installation. Das Ubuntu-Basisimage ist per
Digest festgeschrieben; dessen Pakete kommen aus den jeweils aktuellen offiziellen
Repositories und bilden keinen bitidentischen Paket-Snapshot.

## Hopper und Ubuntu-Prüfung

Hopper wurde nicht installiert. Der offizielle Herstellerdownload wurde vom
Cloud-Proxy mit HTTP 403 abgewiesen. Ein Versuch mit derselben ELF-Datei und
`--provider hopper` meldete `provider_unavailable`/`executable_missing`. Die
Installation, REA-Verbindung und Binäranalyse von Hopper sind daher nicht
nachgewiesen. REA nennt als geprüften Demo-Kandidaten Hopper 6.4.2; die aktuell
verfügbare Linux-Paketversion konnte nicht unabhängig bestätigt werden.

Der Hersteller testet Ubuntu 24.04, Fedora 41 und Arch Linux auf 64-bit-Systemen;
Debian 13 wird weder dort noch im REA-Hopper-Installer als unterstützt geführt.
Es werden keine inkompatiblen Pakete erzwungen und keine Lizenzen umgangen. Die
offizielle Demo begrenzt Sitzungen auf 30 Minuten und sperrt Debugging sowie
Speichern/Exportieren von Disassembly oder modifizierten Binärdateien.

Xvfb wurde mit offiziellen Debian-Paketen lokal getestet:

```bash
bash /workspace/Codex-REA/cloud/re/install-xvfb.sh
/usr/bin/python3 /workspace/.rea-cli/lib/node_modules/rea-agents/scripts/hopper-demo-x11.py \
  --probe --strategy direct --xvfb /workspace/.re-tools/debian/usr/bin/Xvfb
```

Das ersetzt nicht `/usr/bin/Xvfb`, das REA beim üblichen Hopper-Start erwartet.
Für eine spätere Hopper-Prüfung ist der unterstützte Ubuntu-Container vorgesehen:

```bash
bash /workspace/Codex-REA/cloud/re/ubuntu/preflight.sh \
  /workspace/work/re-smoke/fixture.elf
```

Der Build und Lauf wurden erfolgreich geprüft. QtWidgets hat keine fehlenden
Bibliotheken; der REA-Xvfb-Test meldet `ready`. Der Testcontainer läuft als UID
1000, ohne Netzwerk und ohne Linux-Capabilities. Dies belegt funktionierende
Voraussetzungen, aber keine funktionierende Hopper-Installation. Der Container
enthält keinen proprietären Hopper-Download. Der Download und echte Demo-Test
müssen nach einer Freigabe der offiziellen Herstellerdomain über die unterstützte
Cloud-Konfiguration folgen.

## Verfügbarkeit in neuen Aufgaben

REA wurde zu Beginn dieser neuen Aufgabe wiederhergestellt. Die neuen Werkzeuge
wurden nicht in einer weiteren frischen Aufgabe geprüft und die veröffentlichte
Cloud-Konfiguration wurde nicht geändert. Ein Pull Request veröffentlicht kein
neues Cloud-Image.

Nach Übernahme dieses PR muss die gewünschte Repository-Revision in der
Cloud-Konfiguration vorhanden sein. Als zusätzlicher Setup-Schritt ist
`bash /workspace/Codex-REA/cloud/re/install.sh` vorgesehen. Die MCP-Registrierung
nutzt `start-rea.sh`. Anschließend muss die Konfiguration über den unterstützten
Workflow geprüft und neu veröffentlicht werden. Erst eine frische Aufgabe mit
denselben Tests bestätigt die Wiederherstellung der neuen Werkzeuge.

`rea doctor` bestätigt den verfügbaren Ghidra-Provider. Seine Gesamtprüfung bleibt
auf Debian negativ: Debian liegt außerhalb der allgemeinen REA-Hostliste; Hopper,
die installierte Skill-Identität und die automatische Codex-MCP-Registrierung
fehlen. Auch die optionale IDA-Registrierung ist nicht eingerichtet. Die
erfolgreichen CLI-/MCP-Tests sind keine Behauptung vollständiger Bereitschaft aller
REA-Funktionen.

## Offizielle Quellen

- [Ghidra 12.1.4](https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.4_build)
- [Ghidra-Anforderungen](https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_12.1.4_build/GhidraDocs/GettingStarted.md)
- [Temurin 21.0.12.1+1](https://github.com/adoptium/temurin21-binaries/releases/tag/jdk-21.0.12.1%2B1)
- [REA](https://github.com/morluto/rea)
- [Hopper-Anforderungen und Demo](https://www.hopperapp.com/download.html)
- [Hopper-Lizenz](https://www.hopperapp.com/license_agreement.html)

Rohdiagnosen und Metadaten der konkreten Cloud-Aufgabe gehören nicht zu diesem
Quellcode-PR. Sie bleiben im lokal bereitgestellten Berichtspaket.
