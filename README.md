# Codex-REA

Projekt zur Integration von OpenAI Codex mit Reverse Engineer Anything (REA).
Ziel: Anwendungen analysieren und Reverse-Engineering-Aufgaben durchführen.

## Eingaben und Ergebnisse

```text
Externer HTTPS-Dateilink aus dem Analyseauftrag
    ↓ Download außerhalb des Git-Repositorys
Statische Analyse mit REA und Ghidra bzw. Hopper
    ↓
Disassembled/<Dateiname>/<Lauf-ID>/
    report.md, kleine Ausgaben und gegebenenfalls artifacts.json
    ↓ bei großen Exporten und ausdrücklicher Freigabe
GitHub-Release-Anhänge oder vereinbarter externer Speicher
```

Der Ordner `Target/` wurde entfernt. Lade die EXE- oder ELF-Datei bei einem
geeigneten Speicherdienst hoch und gib Codex den Downloadlink im Analyseauftrag.
Die Eingabe bleibt außerhalb des Git-Checkouts und wird nicht auf GitHub kopiert.
Ghidra ist der Standard; Hopper kann ausdrücklich gewählt werden.

Ein direkt erreichbarer HTTPS-Link ist einfacher als eine Login-, CAPTCHA-
oder Vorschauseite. Die Cloud muss die Quelle und eventuelle Weiterleitungsdomains
über ihre regulären Netzwerkfreigaben erreichen dürfen. Ein Freigabelink ist
keine Uploadberechtigung für den externen Dienst. Zugangsdaten, signierte Links
und private Freigabetokens nicht ins Repository übernehmen.

## Beispielauftrag

Den Platzhalter vor dem Absenden durch die tatsächliche Quelle ersetzen:

```text
Verwende den aktuellen main-Stand von MADTreasures/Codex-REA und lies AGENTS.md.

Quelle: <HTTPS-DOWNLOADLINK>
Dateiname: <NAME.exe oder NAME.elf>
Erwartete SHA-256: <WERT, falls vorhanden; sonst nicht vorgegeben>
Analyseziel: <WAS SOLL UNTERSUCHT WERDEN?>
Provider: Ghidra

Prüfe Downloadzugang und Ressourcen. Lade die Datei außerhalb des Git-Repositorys
herunter, prüfe Format und SHA-256 und analysiere sie statisch. Führe sie nicht
aus und lade die Eingabe nicht zu GitHub hoch.

Speichere den Bericht und kleine geprüfte Ergebnisse in einem neuen Unterordner
von Disassembled/. Erstelle dafür einen Ergebnis-Branch und einen Pull Request,
ohne automatisch zu mergen. Keine Zugangsdaten oder privaten Quelllinks hochladen.

Für große Ergebnisarchive bereite GitHub-Release-Anhänge vor und nenne Größe und
benötigte Veröffentlichung. Noch keinen Release ohne meine Bestätigung erstellen.
Verwerfe oder kürze große Ausgaben nicht stillschweigend. Melde getrennt, was nur
lokal und was tatsächlich auf GitHub gesichert ist.

Keine Neuinstallation und keine Änderung der Cloud-Konfiguration.
```

## Große Ergebnisdateien

Normales Git blockiert auf GitHub Dateien über 100 MiB. Wir halten versionierte
Ergebnisse vorsichtshalber unter 50 MiB pro Datei und unter 250 MiB pro Lauf;
diese niedrigeren Werte sind eigene Projektregeln. Große vollständige Exporte
gehören nicht in hunderte Git-Teile, sondern in Archive außerhalb des Checkouts.

Mit Veröffentlichungsfreigabe können Archive als GitHub-Release-Anhänge gespeichert
werden: jeder Anhang muss unter 2 GiB liegen. Größere Archive lassen sich z. B. in
1-GiB-Teile aufteilen. Der kleine Bericht bleibt in `Disassembled/`; eine
`artifacts.json` beschreibt Größe, SHA-256, Teilreihenfolge und bestätigte
Downloadadressen. Alternativ ist ein ausdrücklich vereinbarter externer Speicher
möglich. Git LFS und kostenpflichtige Dienste sind dafür nicht automatisch eingerichtet.

Quellen (geprüft am 2026-10-10):
- https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github
- https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases

## Grenzen und Vertraulichkeit

Dieser Ablauf wird über Projektanweisungen gesteuert; es gibt keinen automatischen
Download- oder Analyse-Trigger. Er wurde mit den neuen externen Eingaben noch nicht
praktisch getestet. Ein großer Download bedeutet nicht, dass eine vollständige
Analyse in den verfügbaren RAM-, Speicher- und Zeitgrenzen möglich ist.

Das Repository war beim Einrichten öffentlich. Veröffentlichte Berichte und
Release-Anhänge sind dann öffentlich zugänglich, selbst wenn die ursprüngliche
Datei privat gelagert wird. Nur dafür geeignete, autorisierte Ergebnisse freigeben.
Ein lokaler Cloud-Pfad ist noch keine dauerhafte Sicherung auf GitHub.

Details: [Ergebnisablage](Disassembled/README.md), [Projektanweisungen](AGENTS.md)
und die unveränderte [Hopper-Einrichtung](docs/hopper-cloud.md).
