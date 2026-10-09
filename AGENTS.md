# Anweisungen für Codex

## REA und Ghidra vor Analyseaufgaben

Verwende vor Aufgaben mit REA, Ghidra oder nativen Binärdateien den
Repository-Skill
`.agents/skills/rea-ghidra-cloud-start/SKILL.md`. Er beschreibt die vorhandene
Installation von REA 6.1.0, Ghidra 12.1.4 und Temurin JDK 21.

Aktiviere die Programme in jeder eigenständigen Bash-Shell vor ihrer Nutzung:

```bash
source /workspace/.re-cloud-setup/activate.sh
rea --version
```

Ein `source` wirkt nur in dieser Shell und ihren Kindprozessen. Jede neue Shell
oder jeder unabhängige Tool-Aufruf kann eine erneute Aktivierung benötigen.
Alternativ verwende den vorhandenen Wrapper mit ausdrücklichen Argumenten,
etwa `/workspace/.re-cloud-setup/rea --version`. Der Wrapper aktiviert seine
eigene Prozessumgebung; ohne Argumente startet er einen MCP-Server.

Für native Binäranalysen verwende `--provider ghidra`. Ein kurzer CLI-Test
genügt für die Aktivierung; wiederhole keine bereits erfolgreiche ELF-Analyse,
sofern eine Änderung oder die Aufgabe dies nicht erfordert.

Ersetze keine Installationsskripte, lade REA/Ghidra/Java nicht neu herunter und
ändere keine Einstellungen der veröffentlichten Cloud-Umgebung. Committe keine
Zugangsdaten, Binärprogramme, Installationen oder Analyse-Artefakte. Melde
fehlende Komponenten und genaue Befehlsfehler, statt sie ungefragt zu beheben.

## Prüfung in einer frischen Cloud-Aufgabe

Die automatische Erkennung von `rea-ghidra-cloud-start` ist noch offen. Sie muss
in einer neuen Cloud-Aufgabe mit diesem Repository auf dem Commit oder Branch
geprüft werden, der den Skill enthält. Prüfe dann zuerst, ob der Skill als
Repository-Skill erkannt wird, und führe nur seinen kurzen CLI-Starttest aus.
Ein manuelles Öffnen der Datei ersetzt diesen Erkennungsnachweis nicht. Melde
Erkennung und CLI-Ergebnis getrennt; behaupte vorher keine automatische
Erkennung. Die dauerhaft gespeicherten Anweisungen aktivieren keine bereits
laufende Shell und ersetzen kein Cloud-Setup.
