# Target – Eingabedateien

Lege hier die EXE- oder ELF-Datei ab, die du mit REA untersuchen möchtest.
Die Groß-/Kleinschreibung des Ordnernamens `Target` gehört zum Projektablauf.
Unterordner für mehrere Anwendungen sind möglich.

## Ablauf

1. Die gewünschte Datei in diesen Ordner hochladen und im Repository speichern.
2. Codex mit der Analyse der konkreten Datei beauftragen.
3. Die Ergebnisse werden nach `Disassembled/<Dateiname>/<Lauf-ID>/` geschrieben.

Beispielauftrag:

```text
Lies AGENTS.md. Analysiere Target/meinprogramm.exe statisch mit REA und Ghidra.
Lass die Eingabedatei unverändert und führe sie nicht aus.
Speichere den Bericht und die tatsächlich erzeugten Analyseergebnisse
unter Disassembled/. Erstelle anschließend einen Pull Request mit den
geprüften Ergebnisdateien, ohne ihn automatisch zusammenzuführen.
```

Der Upload allein startet keine Analyse. Diese README ist keine Zieldatei.
Bei mehreren Dateien bitte die gewünschte Datei nennen oder ausdrücklich alle
beauftragen. Die genauen Arbeitsregeln stehen in der `AGENTS.md` im Projektstamm.

## Veröffentlichungen

Die Repository war bei Einrichtung dieses Ablaufs öffentlich. Dort hochgeladene
Zieldateien sind damit öffentlich zugänglich. Verwende nur Dateien, die du
analysieren und veröffentlichen darfst; keine vertraulichen Firmenprogramme,
Zugangsdaten oder persönlichen Daten. Die Sichtbarkeit wurde durch diese
Einrichtung nicht geändert.

Codex darf Zieldateien weder verändern noch automatisch ausführen. Benötigt ein
Analysewerkzeug eine Arbeitskopie, gehört diese außerhalb des Repositorys.
