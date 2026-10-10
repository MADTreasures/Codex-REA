# Codex-REA

Projekt zur Integration von OpenAI Codex
mit Reverse Engineer Anything (REA).

Ziel: Anwendungen analysieren und
Reverse-Engineering-Aufgaben durchführen.

## Eingaben und Ergebnisse

```text
Codex-REA/
├── Target/          # Vom Nutzer bereitgestellte EXE-/ELF-Dateien
└── Disassembled/    # Berichte und tatsächlich erzeugte Analyseergebnisse
```

Lege die gewünschte Datei in `Target/` ab und beauftrage Codex mit ihrer
statischen Analyse. Das Original bleibt unverändert. Pro Zieldatei und Lauf
werden Ergebnisse in einem eigenen Unterordner von `Disassembled/` abgelegt.
Ghidra ist der Standard; Hopper kann ausdrücklich gewählt oder für einen
Vergleich angefordert werden.

Beispielauftrag:

```text
Lies AGENTS.md aus dem aktuellen Projektstand. Analysiere
Target/meinprogramm.exe statisch mit REA und Ghidra.
Führe die Datei nicht aus und verändere sie nicht.
Speichere Bericht und tatsächlich erzeugte Analyseergebnisse unter
Disassembled/. Erstelle anschließend einen Pull Request mit den geprüften
Ergebnisdateien, ohne ihn automatisch zusammenzuführen.
```

Die Ordner sind angelegt; die Befehlsausführung übernimmt Codex nach einem
Analyseauftrag. Ein Datei-Upload startet noch keine Analyse. Ergebnisse im
lokalen Cloud-Checkout sind erst nach Commit/Push auch auf GitHub gesichert.
Es wurde kein automatischer Upload-Trigger eingerichtet.

Details: [Target](Target/README.md), [Disassembled](Disassembled/README.md) und
[Projektanweisungen](AGENTS.md). Die bestehende
[Hopper-Einrichtung](docs/hopper-cloud.md) bleibt unverändert.

## Vertraulichkeit

Die Repository war beim Einrichten dieses Ablaufs öffentlich. Hochgeladene
Zieldateien und veröffentlichte Berichte können damit von anderen gelesen
werden. Keine vertraulichen Binärdateien, persönlichen Daten oder Zugangsdaten
hochladen. Nur Dateien analysieren und veröffentlichen, für die du die
entsprechende Berechtigung hast.
