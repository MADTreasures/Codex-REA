# Codex-REA

Projekt zur Integration von OpenAI Codex mit Reverse Engineer Anything (REA).
GitHub enthält ausschließlich Projektcode, Einrichtungsdateien und Anleitungen.
**Eingabedateien und sämtliche Analyseergebnisse werden in Dropbox abgelegt.**

## Ablage

Die Ordner `Target/` und `Disassembled/` gehören nicht mehr ins Git-Repository.
Vorgesehene Struktur im vom Nutzer autorisierten Dropbox-Bereich:

```text
Codex-REA/
├── Target/          # EXE-/ELF-Dateien des Nutzers
└── Disassembled/
    └── <Dateiname>/<Lauf-ID>/
        ├── report.md
        ├── artifacts.json
        └── <tatsächlich erzeugte Analyseausgaben oder Ergebnisarchive>
```

Das ist eine Ablagekonvention, keine Bestätigung, dass die Dropbox-Ordner bereits
angelegt oder eine Verbindung eingerichtet wurde. Bei einem eingeschränkten
App-Ordner müssen die API-Pfade zum tatsächlich freigegebenen Bereich passen.
Die konkrete Quelle und der erlaubte Zielordner werden im Analyseauftrag benannt.

## Ablauf

1. Der Nutzer lädt die Eingabe in Dropbox hoch und nennt den Dateipfad oder
   einen geeigneten HTTPS-Downloadlink sowie das gewünschte Analyseziel.
2. Codex prüft zuerst den Downloadzugriff und einen tatsächlich verfügbaren,
   autorisierten Uploadweg zum Dropbox-Ziel. Ein Leselink erlaubt keinen Upload.
3. Die Datei wird außerhalb des Git-Checkouts heruntergeladen und statisch mit
   REA und Ghidra analysiert. Hopper kann ausdrücklich ausgewählt werden.
4. Berichte, Prüfsummen, Text-/JSON-Ausgaben und gegebenenfalls große Archive
   werden in einem neuen Dropbox-Ergebnisordner gespeichert und dort überprüft.

Quellprogramme nicht ausführen oder verändern. Alte Ergebnisse nicht überschreiben.
GitHub ist weder Zwischenablage noch Ausweichziel für Analyseergebnisse: keine
Ergebnis-Commits, Pull Requests, Releases oder LFS-Uploads. Auch kleine Berichte
und Artefaktverzeichnisse gehören nach Dropbox, nicht ins Repository.

## Zugriff und große Dateien

Ein Dropbox-Downloadlink und Dropbox-Schreibzugriff sind getrennte Voraussetzungen.
Verwende nur eine verfügbare autorisierte App-Aktion oder eine ausdrücklich
freigegebene Dropbox-API-Verbindung. Eine verbundene ChatGPT-App beweist nicht,
dass dieselbe Codex-Cloud-Aufgabe große lokale Dateien an diese App übergeben kann.
Die konkrete Dateiübergabe, Uploadfunktion und deren Größenlimits müssen geprüft werden.

Große API-Uploads benötigen gegebenenfalls Upload-Sessions mit begrenzten Chunks.
Die Gesamtdatei nicht in RAM, Chat-Nachrichten oder Tool-Argumente kopieren.
Connector-Dateireferenzen nur gemäß der jeweiligen Schnittstelle verwenden.
Für Eingaben, Arbeitskopien und Exporte genügend Cloud- und Dropbox-Speicher einplanen.
Ein großer Download garantiert keine vollständige Analyse innerhalb der RAM-/Zeitgrenzen.

Passwörter, OAuth-Tokens und private Freigabelinks gehören nicht ins Repository,
in veröffentlichte Konfigurationen oder in Protokolle. Kontoautorisierung über den
vorgesehenen Anbieterprozess durchführen, keine Tokens in Chat-Nachrichten anfordern.
Keine öffentlichen Ergebnislinks erstellen, sofern der Nutzer dies nicht verlangt.
Ein lokal erzeugtes Ergebnis ist erst nach bestätigtem Dropbox-Upload remote gesichert.

## Beispielauftrag

```text
Verwende den aktuellen main-Stand von MADTreasures/Codex-REA und lies AGENTS.md.

Dropbox-Quelle: <DATEIPFAD ODER HTTPS-DOWNLOADLINK>
Dateiname: <NAME.exe oder NAME.elf>
Erwartete SHA-256: <FALLS VORHANDEN>
Dropbox-Ziel: <AUTORISIERTER ORDNER, z. B. /Codex-REA/Disassembled>
Analyseziel: <WAS SOLL UNTERSUCHT WERDEN?>
Provider: Ghidra

Prüfe vor der umfangreichen Analyse, ob Download, Dateiübergabe und Upload
in dieser Cloud-Aufgabe tatsächlich möglich sind. Fehlt der Schreibzugriff,
melde die konkrete fehlende Freigabe und starte noch keine große Analyse.

Analysiere statisch; führe die Eingabe nicht aus und ändere sie nicht.
Speichere Bericht und alle tatsächlich erzeugten, geprüften Exporte ausschließlich
in einem neuen Unterordner des genannten Dropbox-Ziels. Ich beauftrage damit
auch deren Upload in diesen Ordner, ohne bestehende Dateien zu ersetzen.

Nichts zu GitHub hochladen, keine öffentlichen Links erzeugen und keine
Neuinstallation oder Änderung an der Cloud-Konfiguration durchführen.
Berichte getrennt über Analyseergebnis und bestätigten Dropbox-Speicherstatus.
```

## Umstellungsstatus

Die Repository-Anweisungen sind auf Dropbox umgestellt. Die Installation von
REA/Ghidra/Hopper und ihre Tests bleiben davon getrennt. Durch diese Änderung
wurden weder ein Dropbox-Konto verbunden noch Dateien dorthin übertragen.
Ein vollständiger Cloud-Download-/Analyse-/Dropbox-Uploadlauf ist noch zu prüfen.
Es gibt keinen automatischen Analysejob allein durch einen Datei-Upload.

Details: [Projektanweisungen](AGENTS.md) und die bestehende
[Hopper-Einrichtung](docs/hopper-cloud.md).

Quellen für die Zugriffseinrichtung und große Uploads:
- https://help.dropbox.com/share/set-file-folder-permissions
- https://help.dropbox.com/integrations/chatGPT-app
- https://docs.dropboxapi.com/dropbox-api/api-reference/user-endpoints/files/upload-session-start
