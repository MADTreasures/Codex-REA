# Texte fuer die Cloud-Einstellungen

`install-cloud.sh` ist der vollstaendige Text fuer das Installations-/Setup-Feld.
Er funktioniert ohne Repository-Zugriff und verwendet vorhandene REA-, Ghidra-
und JDK-Installationen weiter. `START_SKILL.md` ist der vollstaendige Text fuer
das Start-Skill-Feld. Beide Texte werden manuell in „Umgebung bearbeiten“
uebernommen und ueber den unterstuetzten Workflow neu veroeffentlicht.

Die bisherigen Dateien unter `cloud/re/` und `.rea-setup` bleiben erhalten.
Das neue Setup legt ausschliesslich eigene Startdateien unter
`/workspace/.re-cloud-setup` an. Abweichende vorhandene Dateien werden nicht
ueberschrieben. Eine andere REA-/JDK-/Ghidra-Version oder eine unvollstaendige
Installation fuehrt zur Pruefung und zum Abbruch statt zu einer erzwungenen
Reparatur. Es gibt keine Systempaket- oder Shellprofil-Aenderungen.

## Gespeicherte Laufzeitdateien

- REA 6.1.0: `/workspace/.rea-cli`
- Ghidra 12.1.4: `/workspace/.re-tools/ghidra_12.1.4_PUBLIC`
- Vollstaendiges Temurin-JDK 21.0.12.1+1: `/workspace/.re-tools/temurin-21.0.12.1`
- Gepruefte Archive: `/workspace/.re-tools/downloads`
- Aktivierung: `/workspace/.re-cloud-setup/activate.sh`
- CLI/MCP-Wrapper: `/workspace/.re-cloud-setup/rea`
- Harmlose JavaScript-Testquelle: `/workspace/.re-cloud-setup/fixture/sample.js`
- MCP-Konfigurationsbeispiel: `/workspace/.re-cloud-setup/codex-mcp.example.toml`

Der Wrapper setzt JAVA_HOME, GHIDRA_INSTALL_DIR und PATH bei jedem Aufruf.
Die Exporte einer Setup-Shell allein gelten nicht automatisch fuer spaetere
Cloud-Aufgaben. Der Start-Skill verwendet deshalb den Wrapper bzw. die explizite
Aktivierung und prueft JavaScript sowie eine eigene harmlose ELF-Datei.

Die Installation verwendet festgeschriebene Werkzeugversionen und verifiziert
offizielle SHA-256-Werte fuer Ghidra/JDK sowie den SHA-512-Integrity-Wert des
offiziellen npm-Pakets REA. Bereits vorhandene Archive werden geprueft.
Vorhandene getestete Installationen loesen keine Ghidra-/JDK-Downloads aus.
Die von npm aufgeloesten abhaengigen Pakete unterliegen dessen Integrity-Pruefung;
dies ist kein bitidentisch eingefrorener Snapshot aller transitiven Abhaengigkeiten.

Ghidra und JDK belegen zusammen etwa 1,2 GiB; die beiden Archive etwa 742 MiB.
Ungefaehr 2 GiB sind somit der gesamte Speicherbedarf, nicht die reine
Downloadgroesse. Fuer einen Neuaufbau verlangt das Skript 3 GiB freien
Speicher und prueft ein vorhandenes cgroup-Limit auf mindestens 4 GiB RAM.
Der Standard-Heap bleibt auf 2 GiB pro Ghidra-Prozess begrenzt.

Ein Ausfuehren des Setup-Skripts und des Starttests in der bestehenden Sitzung
prueft die Texte, ersetzt aber keinen Wiederherstellungstest. Erst die
uebernommene, neu veroeffentlichte Cloud-Konfiguration und eine weitere frische
Aufgabe mit erfolgreichem Starttest bestaetigen die spaetere Verfuegbarkeit.
Diese Projektdateien aktualisieren die veroeffentlichte Umgebung nicht selbst.

Geprueft am 9. Oktober 2026: zwei Setup-Laeufe mit gesperrten Download-Aufrufen,
unveraenderte Ghidra-/JDK-Archive, Starttest in einer neuen Bash ohne Shellprofil
mit erfolgreicher JavaScript- und ELF-Analyse, MCP-Handshake ueber den neuen
Wrapper sowie separate REA-Neuinstallation aus dem SHA-512-geprueften Paket.
Eine abweichende vorhandene Startdatei wurde im Konflikttest erhalten und der
Installer brach ab. Die 13 bisherigen PR-Quelldateien blieben unveraendert.
Ein Starttest in einer weiteren tatsaechlichen Cloud-Aufgabe steht noch aus.

## Hopper bleibt offen

Der bisherige Zugriff auf `https://www.hopperapp.com/download.html` scheiterte
mit `curl: (56) CONNECT tunnel failed, response 403`. Die Herstellerdomain war
nicht freigegeben. Der REA-Versuch meldete `provider_unavailable` und
`executable_missing`; kein Hopper-Paket wurde installiert oder analysiert.

Zulaessige naechste Wege:

1. Die offizielle Herstellerdomain ueber den unterstuetzten Cloud-Konfigurations-
   workflow freigeben; danach den offiziellen Linux-Demo-Installer laden und auf
   dem vorbereiteten Ubuntu-24.04-Pruefweg ohne erzwungene Pakete testen.
2. Wenn ein erlaubter Dateitransfer verfuegbar ist, den unveraenderten offiziellen
   Installer aus einem herstellerseitigen Download des Nutzers bereitstellen.
   Herkunft und verfuegbare Hersteller-Pruefsummen zuvor verifizieren. Ein
   solcher Transfer muss von der Plattform erlaubt sein; er darf keine
   Netzwerkpolicy umgehen. Die Moeglichkeit ist hier nicht praktisch getestet.
3. Bei fehlender Freigabe die offizielle Demo auf einer unterstuetzten eigenen
   Ubuntu-24.04-Umgebung pruefen. Keine inoffiziellen Mirrors oder neuen
   kostenpflichtigen Dienste einsetzen.

Der vorhandene Ubuntu-Preflight wurde fuer Xvfb/Qt erfolgreich getestet; eine
Hopper-Installation oder REA-Verbindung dort ist damit noch nicht nachgewiesen.
Die Demo bleibt auf 30 Minuten begrenzt und sperrt Debugging sowie
Speichern/Exportieren von Disassembly oder modifizierten Binaerdateien.

Offizielle Quellen:

- [REA 6.1.0 und npm-Integrity](https://registry.npmjs.org/rea-agents/6.1.0)
- [REA-Projekt](https://github.com/morluto/rea)
- [Ghidra 12.1.4 und SHA-256](https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.4_build)
- [Temurin 21.0.12.1+1](https://github.com/adoptium/temurin21-binaries/releases/tag/jdk-21.0.12.1%2B1)
- [Hopper-Anforderungen und Demo](https://www.hopperapp.com/download.html)
- [Hopper-Lizenz](https://www.hopperapp.com/license_agreement.html)

In GitHub werden ausschliesslich diese Setup-Quellen und Dokumentation gesichert.
Lokale Testausgaben, Zugangsdaten, interne Cloud-Metadaten und Binärprogramme
gehoeren nicht in den Pull Request.
