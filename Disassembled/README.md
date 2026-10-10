# Disassembled – Analyseergebnisse

Hier speichert Codex die Ergebnisse von ausdrücklich beauftragten Analysen der
Dateien aus `Target/`. Pro Eingabedatei und Lauf wird ein eigener Unterordner
angelegt; vorhandene Ergebnisse werden nicht überschrieben.

Beispielstruktur (noch keine Analyse durchgeführt):

```text
Disassembled/
└── meinprogramm.exe/
    └── <UTC-Zeitstempel>-<SHA256-Kurzform>/
        ├── report.md
        ├── analysis.json
        ├── functions.csv
        ├── strings.txt
        ├── disassembly.txt
        └── pseudocode.c
```

`report.md` dokumentiert mindestens Eingabepfad, SHA-256, Dateiformat,
Architektur, verwendete Werkzeuge/Versionen, ausgeführte Prüfungen, Ergebnisse
und offene Einschränkungen. Die weiteren Dateien werden nur angelegt, wenn die
jeweilige Ausgabe tatsächlich gewonnen wurde. Kein erfundener Pseudocode,
keine leeren Platzhalter als vermeintlicher Analyseerfolg.

Bei einem Vergleich von Ghidra und Hopper liegen deren Ausgaben in getrennten
Unterordnern desselben Laufs. Pseudocode ist als rekonstruierte Darstellung
zu kennzeichnen, nicht als ursprünglicher Quellcode.

Die vollständigen Regeln stehen in `AGENTS.md`. Rohlogs, temporäre native
Projektdateien, Container-Daten, Zugangsdaten und Kopien der Ziel-Binärdateien
gehören nicht in die versionierten Ergebnisse.

Dateien im Cloud-Checkout sind noch nicht automatisch auf GitHub gespeichert.
Für die dauerhafte Ablage auf GitHub Codex ausdrücklich mit einem Ergebnis-
Commit beziehungsweise Pull Request beauftragen. Nur geprüfte, zur
Veröffentlichung geeignete Ergebnisse hochladen: Die Repository war bei
Einrichtung dieses Ablaufs öffentlich.

Es gibt keinen automatisch beim Datei-Upload gestarteten Analysejob.
