# Disassembled – Analyseergebnisse

Hier liegen geprüfte Berichte und kleine Ergebnisse ausdrücklich beauftragter
Analysen. Eingaben kommen über eine im Auftrag genannte externe Downloadquelle
und liegen nur im Cloud-Arbeitsverzeichnis außerhalb des Repositorys.
Der frühere Eingabeordner `Target/` ist nicht mehr Bestandteil dieses Ablaufs.

Pro Datei und Lauf wird ein eigener Unterordner angelegt. Beispiel, nicht das
Ergebnis einer bereits ausgeführten Analyse:

```text
Disassembled/
└── meinprogramm.exe/
    └── <UTC-Zeitstempel>-<SHA256-Kurzform>/
        ├── report.md
        ├── functions.csv       # nur bei tatsächlich gewonnenen Ergebnissen
        ├── analysis.json       # nur soweit klein genug und zur Veröffentlichung geeignet
        └── artifacts.json      # Verzeichnis großer externer/Release-Artefakte
```

`report.md` dokumentiert Dateiname, Größe, SHA-256, Format, Architektur,
Werkzeugversionen, Analyseumfang, Befunde und Grenzen. Keine Zugangstokens oder
privaten Downloadlinks speichern. Pseudocode als rekonstruierte Darstellung
kennzeichnen; fehlende Ausgaben erklären statt leere Erfolgsdateien anzulegen.
Bei zwei Providern kleine Ausgaben in `ghidra/` und `hopper/` trennen.

## Große Ausgaben

GitHub blockiert normale Git-Dateien über 100 MiB. Dieses Projekt verwendet als
vorsichtige Arbeitsgrenze unter 50 MiB pro versionierter Ergebnisdatei und
höchstens 250 MiB neue Ergebnisse pro Lauf. Diese niedrigeren Grenzen sind
Projektregeln. Bei Überschreitung kompakte Berichte hier speichern und vollständige
geprüfte Exporte außerhalb des Checkouts archivieren, statt sie zu verwerfen.

Mit ausdrücklicher Freigabe: große Archive als GitHub-Release-Anhänge hochladen.
Jeder Anhang muss unter 2 GiB liegen; größere Archive beispielsweise in 1-GiB-Teile
teilen und die Zusammenbauanleitung sichern. Alternativ nur einen vom Nutzer
freigegebenen externen Speicher verwenden. Keine großen Archivteile ins Git
committen und keine kostenpflichtigen Dienste oder LFS ungefragt aktivieren.

`artifacts.json` erfasst die wirklich vorhandenen Artefakte mit Dateiname,
Größe in Bytes, SHA-256, Status, gegebenenfalls bestätigter Downloadadresse
sowie Teilreihenfolge. Tokens und nicht öffentliche Freigabelinks weglassen.
Noch nicht hochgeladene Dateien als nur lokal kennzeichnen; einen Upload nicht
allein anhand einer vorgesehenen URL als erfolgreich melden.

## Veröffentlichung

Der Cloud-Checkout allein ist keine dauerhafte Sicherung. Codex bei Bedarf mit
einem Pull Request für geprüfte Ergebnisdateien beauftragen. Release-Erstellung
und externe Uploads benötigen die entsprechende Freigabe; keine bestehenden
Assets überschreiben. Das Repository war bei Einrichtung öffentlich: Auch
veröffentlichte Ergebnisarchive sind keine private Ablage.

Eingabebinärdateien, temporäre Projektdatenbanken, Rohlogs, Containerdaten und
Geheimnisse nicht übernehmen. Große Text-Exporte vor jedem Upload auf sensible
Inhalte prüfen. Vollständige Regeln: [AGENTS.md](../AGENTS.md).

GitHub-Dokumentation:
- https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github
- https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases
