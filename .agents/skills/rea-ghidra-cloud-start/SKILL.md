---
name: rea-ghidra-cloud-start
description: >-
  Bereitet die vorhandene Codex-REA-Cloud-Installation vor Analyseaufgaben vor.
  Verwenden, wenn REA, Ghidra oder eine native Binäranalyse in diesem Repository
  benötigt wird oder der Nutzer den Start-Skill ausdrücklich aufruft.
---

# REA und Ghidra in der Cloud starten

Nutze die vorhandene Installation. Dieser Skill richtet die Umgebung des
jeweiligen Prozesses ein; er installiert nichts und ändert keine Shellprofile,
MCP-Konfigurationen oder Einstellungen der veröffentlichten Cloud-Umgebung.

## Vorhandene Komponenten

| Komponente | Version | Pfad |
| --- | --- | --- |
| REA | 6.1.0 | `/workspace/.rea-cli/bin/rea` |
| Ghidra | 12.1.4 | `/workspace/.re-tools/ghidra_12.1.4_PUBLIC` |
| Temurin JDK | 21, derzeit 21.0.12.1 | `/workspace/.re-tools/temurin-21.0.12.1` |
| Aktivierung | vorhanden | `/workspace/.re-cloud-setup/activate.sh` |
| REA-Wrapper | vorhanden | `/workspace/.re-cloud-setup/rea` |

## Aktivierung und kurzer Starttest

1. Prüfe, ob Aktivierungsskript, Wrapper und die oben genannten Programme
   vorhanden und lesbar beziehungsweise ausführbar sind.
2. Nutze Bash und aktiviere vor REA-/Ghidra-Befehlen in derselben Shell:

   ```bash
   source /workspace/.re-cloud-setup/activate.sh
   rea --version
   ```

   Der kurze CLI-Test muss `6.1.0` liefern. Wiederhole keine bereits erfolgreiche
   ELF-Analyse nur zur Aktivierung. Bei einem bloßen Startauftrag endet der Skill
   nach dem kurzen Test und der Meldung des Ergebnisses.
3. Jede neue Shell beziehungsweise jeder unabhängige Befehlsaufruf kann die
   Variablen wieder verlieren. Lade das Aktivierungsskript dort erneut. Gehe
   nicht davon aus, dass ein früheres `source` andere Tool-Aufrufe beeinflusst.

Das Skript setzt `JAVA_HOME` und `GHIDRA_INSTALL_DIR` auf die obigen Pfade und
 ergänzt den `PATH` um REA und das Temurin-JDK. Es setzt, sofern nicht bereits
vorgegeben, `REA_ANALYSIS_PROVIDER=ghidra`, `GHIDRA_HEADLESS_MAXMEM=2G` und
`REA_GHIDRA_STARTUP_TIMEOUT_MS=330000`. Kopiere diese Logik nicht in neue
Installationsskripte; das vorhandene Aktivierungsskript bleibt maßgeblich.

Alternativ lädt der Wrapper die Aktivierung bei jedem Aufruf selbst:

```bash
/workspace/.re-cloud-setup/rea --version
/workspace/.re-cloud-setup/rea analyze --help
```

Übergib dem Wrapper immer einen ausdrücklichen Befehl. Ohne Argumente startet
er den MCP-Server. `rea mcp` stellt einen stdio-Server bereit, registriert ihn
aber nicht automatisch als Codex-Tool. Für diese Einrichtung genügt die CLI;
ändere keine globale MCP-Konfiguration.

## Analyseaufgaben

Führe nur die vom Nutzer angeforderte Analyse durch. Verwende für native
Binäranalysen ausdrücklich den Ghidra-Provider, zum Beispiel:

```bash
source /workspace/.re-cloud-setup/activate.sh
rea analyze /pfad/zur/binaerdatei --provider ghidra
```

Für Eingaben und Ergebnisse gelten die aktuellen Regeln aus `AGENTS.md`:
Lade die im Auftrag benannte externe Datei außerhalb des Repositorys herunter.
Prüfe Format, Größe und SHA-256; führe die Eingabe nicht aus und ändere sie nicht.
Der frühere Ordner `Target/` wurde entfernt und darf nicht neu angelegt werden.
Speichere geprüfte kleine Berichte in einem neuen Unterordner von `Disassembled/`.
Große Exporte bleiben außerhalb des Checkouts und werden bei entsprechender
Freigabe als Release-Anhänge oder beim vereinbarten externen Speicher abgelegt.
Ein kleines Artefaktverzeichnis dokumentiert Größe, Prüfsummen und bestätigte
Uploadorte ohne private Tokens. Eingaben, große Archive und Rohlogs nicht committen.
Veröffentlichung nur nach entsprechendem Auftrag und Prüfung der Ergebnisdateien.

Ghidra benötigt temporäre Projekt-, Bridge- und Logdateien. Behandle das
Analyseziel als unveränderlich und beachte zusätzliche Vorgaben des Nutzers zu
temporären Dateien. Scheitert ein Unterprozess mit `EPERM`, melde den exakten
Fehler und unterscheide eine Einschränkung der Ausführungs-Sandbox von einer
fehlenden Installation. Leite daraus keine Neuinstallation ab.

## Grenzen und Erkennungsprüfung

- Ersetze keine vorhandenen Installations- oder Aktivierungsskripte.
- Lade REA, Ghidra und Java nicht erneut herunter.
- Übernimm keine Zugangsdaten, Eingabebinärdateien, heruntergeladenen
  Analyseprogramme, Installationen oder privaten Rohlogs ins Repository.
  Geprüfte kleine Ergebnisse in `Disassembled/` sind nach `AGENTS.md` vorgesehen;
  die Anweisung ersetzt das frühere pauschale Artefaktverbot und die Target-Regeln.
- Melde fehlende Pfade, unerwartete Versionen und fehlgeschlagene Befehle genau.
  Behaupte bei einem fehlgeschlagenen oder ausgelassenen geforderten Test keinen
  vollständigen Starterfolg.
- Die automatische Skill-Erkennung ist weiterhin nicht nachgewiesen und keine
  Voraussetzung für den Ablauf. Lies die vorhandenen Anweisungen bei
  Bedarf direkt. Untersuche die Erkennung nur auf ausdrücklichen Auftrag;
  manuelles Lesen ist kein Beleg für einen Eintrag im Skill-Katalog.
