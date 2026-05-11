# ROSI – Fehlerszenarien während des Betriebs

> Ergänzungsdokument zur Wissensbasis (`ROSI_Wissensbasis.md`)
> Ziel der Fallstudie: Problemstellen identifizieren – keine Lösungen erzwingen.

---

## Kontext: Rollen im Betrieb

| Rolle                | Zugriff (UI)                                                                                                                                      | Physisch                                 |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| **Operator**         | Produktion ansehen, Aufträge erstellen/bearbeiten, eigene Logs, Dashboards                                                                        | Reinigung Portal/Schaltschrank von außen |
| **QS**               | Produktion, Statistiken, Aufträge ansehen, Rezepte ansehen, Dashboards                                                                            | Reinigung Portal/Schaltschrank von außen |
| **Plant Manager**    | Produktion, Statistiken, Aufträge, alle Logs, Rezepte ansehen, Dashboards                                                                         | Reinigung Portal/Schaltschrank von außen |
| **Service**          | Produktion, Statistiken, Aufträge, alle Logs, Systemeinstellungen ansehen, Dashboards                                                             | Reinigung Portal/Schaltschrank von außen |
| **Grenzebach Admin** | Vollzugriff: Rezepte erstellen/bearbeiten/archivieren, Systemeinstellungen bearbeiten, Benutzer verwalten, Modelle deployen, Dashboards verwalten | Reinigung Portal/Schaltschrank von außen |

> Kein Kunde hat SSH-Zugang oder physischen Zugang zum Rechner-Inneren.
> Modell-Deployment (`.aiaddon`) ist dem **Grenzebach Admin** erlaubt – das kann auch ein Kundenvertreter mit dieser Rolle sein.

---

## Bereits aufgetretene Vorfälle (andere Produkte / Anlagen)

> Diese realen Ereignisse zeigen, dass die Szenarien unten keine theoretischen Konstrukte sind.

| Vorfall                              | Beschreibung                                                                                                                                                                                                          |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bitcoin-Miner auf Anlagenrechner** | Auf einer Produktionsmaschine wurde unbemerkt Mining-Software installiert – vermutlich über einen externen Zugang. Dauerhafte GPU/CPU-Last, mögliche Scan-Beeinträchtigung, Entdeckung erst durch Performance-Abfall. |
| **USV abgeraucht**                   | Eine Unterbrechungsfreie Stromversorgung ist im Betrieb in Brand geraten. Totalausfall der angeschlossenen Komponenten, potenzielle Folgeschäden durch Hitze/Rauch im Schaltschrank.                                  |
 ** Beleuchtung verstellt** | Besteigen / Betreten einer Beleuchtung
 ** Beleuchtungshalter verbogen ** | Während IBN betritt (vor Beleuchtungsmontage) ein Monteur die Halterung und verbiegt diese
 ** Extreme Verstaubung Schaltschrank / Rechner | Verstopfter Filter des Kühlgeräts (Schaltschrank) -> Kunde öffnent Schaltschrank um Überhitzung zu verhindern -> Staub dringt über langen Zeitraum in den Schaltschrank ein
 ** Ausfall Wasserkühlung Beleuchtung (aktuell wird keins Verwendet) | Ausfall wird nicht bemerkt -> Überhitzung Beleuchtung -> Schnellere Alterung -> Intensitätsabfall (dauerhaft) / Reduzierung Lebenszeit
 ** Intensitätsabfall LED Beleuchtung durch Alterung -> Verschlechterung Bildaufnahme -> Detektionsprobleme (Thresholding)
 ** Undichtigkeit Wasserkühlung Anschluss Beleuchtung | Wassereintritt in die Beleuchtung
 ** Kundeseitige Beleuchtungsreparatur | Verstellung der Optik -> Verminderte Systemleistung / Schatteneffekte
 ** Spannungsabfall Netzteil | Netzteilspannung zu gering, sodass PC bei Lastspitzen ausfällt
 ** Spannungsschwankung Netzanschluss | Große Verbraucher / Motoren können zu stärkeren Spannungsschwankungen führen -> Flackern Monitor evtl. auch Zusammenhängend mit weiteren Systeminstabilitäten
 ** Lose Stecker | Lösen von Steckern beim Transport
 ** Lose Pins | Lösen von lockeren Pins von spannungsführenden Teilen nach mehreren Jahren. Wahrscheinlich durch Vibrationen -> Beleuchtungsausfall
 ** Beleuchtungsausfall | Ein Bild bleibt dunkel, Gesamtbild dunkler / Schatten bei welligen Platten 
 ** Schwingungsanregung des Portals  | Schwingungsanregung des Portals / Kamera durch externe Systeme -> Kamera gerät aus dem Fokus
 ** Sonneneinstrahlung | Durch eine Dachluke scheint Sonne auf die Scanlinie und stört die Defekterkennung / -klassifizierung
 ** Staubansammlung  | Staub setzt sich ab (Gehäuse, Objektiv, Beleuchtung) und reduziert die Belichtungsintensität
 ** Teilausfall Beleuchtung | Ausfall LED / LED-Treiber
 ** Ausfall Encoder -> Keine Inspektion
 ** Kunde tauscht programmierbaren Encoder selbst -> Ohne Wissen, dass er programmiert werden muss -> Falsche Breitenmessung 
 ** Ausfall Lichttaster -> Keine Inspektion
| Lichtschranke        | Verschmutzung der Optik durch Produktionsstaub    
** Furnierreste unter der Scannline | Reste "beeinflussen" die korrekte Bildaufnahme -> Streifen auf dem Bild
** Furnierreste in der Lichtschranke / unter dem Lichttaster | Dauerhafte Auslösung Plattenerkennung
** Abdeckglas Kamera / Beleuchtung (war mal aus Plastik) vergilbt | Reduzierung der aufgenommenen Intensität durch Alterungsprozesse
** Plastikabdeckung beim Reinigen beschädigt / eingedrückt | Eindringen von Staub in das Kameragehäuse
** Objektiv hat sich gelockert | Durch Vibrationen hat sich das Objektiv gelöst und die Bildaufnahme war nicht mehr korrekt / scharf
** Ausfall der Kamera
** Systemabsturz durch verwenden der großen Enter Taste :D
** Ausfall von nicht mehr verfügbaren elektrischen Komponenten (Altanlagen >= 18 Jahre)
** Knowhowverlust durch nicht mehr verfügbare Mitarbeiter -> Kunden können bei Problemen nicht mehr geholfen werden -> System wird quasi dadurch Abgekündigt
** Unbemerkter Memory Leak lässt das System alle paar Wochen Abstürzen -> Einführung Watchdog ist erfolgt
** TCP IP verbinung zur Datenübertragung bricht ab | Unbemerkt -> Einführung Heartbeat überprüfung
** Ein Teil der Software stürzt ab ( der andere übermittelt Heartbeat) | Watchdog auf beide Softwarebestandteile angewendet
** Systeminstabilität durch PC Abstürze | System stürzr mit der Zeit immer häufiger ab. Ursache nach wie vor Unbekannt
** RAM Dist nicht geladen | Bei System wird RAM Disk nicht geladen und verhindert Inspektion
** Autostart Verknüpfung fehlerhaft | Systemneustart läd veralteten Softwarestand, da Verknüfpung nicht aktualisiert
** Speicher voll | Logs schreiben den Speicher voll da sie nicht automatisch wieder gelöscht werden, System hängt sich auf
** Windows 7 | System kann nicht aufgrund von Hard- und Software Upgedatet werden. Sicherheitsprobleme denkbar. Prinzipiell ist das GSG vorgeschaltet und sollte "alles blocken".
** Kunde zieht Remoteverbindung -> System nicht erreichbar
** GSG nicht erreichbar -> System nicht erreichbar
** Sprachbug in der Software -> Änderung der Sprache auf Spanisch führt zum Absturz der Software, Direkter Neustart war durch Änderung nicht möglich
** Korrupte Einstellungsdatei -> Die Einstellungsdatei war korrupt, wodurch die Qualittätsevaluation nicht mehr möglich war
** Kunde im Adminbereich -> Kunde hat Zugang zum Adminbereich bzw. in der Software sind kritische Einstellungen zugänglich (setzen Thresholds) und Kunde verstellt das System unwissentlich

---

## 1. Hardware-Fehler

### 1.0 Natürlicher Verschleiß / Umgebungseinflüsse

> Kein menschliches Fehlverhalten – passiert im Normalbetrieb über Zeit oder durch externe Faktoren.

| Komponente           | Fehlerszenario                                                                        | Auswirkung                                                                                                   |
| -------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| NVMe SSD             | TBW-Erschöpfung durch ~50 GB Schreiblast/Tag (Bilder: hochauflösend, Thumbnail, SD)   | Schreibfehler, Datenverlust, Systemausfall; Zeitpunkt schwer vorhersagbar                                    |
| SSD → HDD Transfer   | Automatischer Bild-Transfer nach ~4h schlägt fehl (HDD voll, Verbindung unterbrochen) | Bilder gehen verloren bevor sie gesichert sind; SSD läuft voll                                               |
| LED-Beleuchtung      | Alterung der LEDs → schleichender Helligkeitsverlust über Monate                      | KI-Modell auf ursprüngliche Lichtintensität trainiert → schleichende Fehlklassifikation ohne Fehlerindikator | -> Problematisch bei Thresholding mit klassischer Bildverarbeitung, -> Überhitzung Beleuchtung, da zu wenig Wärme abgeführt wird (-> Kühlrippen zugestaubt, Kühlsystem ausgefallen(sofern vorhanden/nötig))
| Kameraobjektiv / Abdeckscheibe        | Schleichende Verschmutzung durch Produktionsstaub (Gips/Holz)                         | Bildqualitätsverlust über Zeit; unklar ab wann KI-Inferenz unzuverlässig wird                                | -> Erstmal wird es neben einer minimalen Unschärfe zu Intensitätsverlust kommen
| USV                 | Akku-Kapazitätsverlust durch Alterung                                                 | Puffer reicht bei Stromausfall nicht mehr für geordnetes Herunterfahren                                      |
| USV                  | Thermisches Ereignis / Brand (analog zu realem Vorfall)                               | Totalausfall + potenzielle Folgeschäden durch Hitze/Rauch im Schaltschrank                                   |
| Schaltschrank-Filter | Filter setzt sich über Zeit mit Produktionsstaub zu                                   | Eingeschränkte Luftzirkulation → Überhitzung von PC, Switches, IO-Modulen                                    | -> Ausfall Netzteil Lüfter -> Überhitzung
| Encoder              | Mechanischer Verschleiß → fehlerhafte Geschwindigkeitssignale      | Frames kommen zu früh/spät → geometrisch falsche Inspektion ohne Fehlerindikator                             |
| Lichtschranke        | Verschmutzung der Optik durch Produktionsstaub                                        | Trigger löst nicht mehr zuverlässig aus → Material wird nicht gescannt, kein Alarm                           | -> Eine Anlage hat eine Abblaseinheit
| Framegrabber-Treiber | Treiber-Cache läuft bei langer Uptime voll                                            | Instabiler Kamerazugriff, Bildübertragungsfehler; gelöst durch geplanten Reboot                              |
| Netzwerkkabel        | Kabelermüdung durch dauerhaften Betrieb, Knicke, Vibrationen                          | Intermittierende Verbindungsabbrüche schwer zu debuggen                                                      |
Schaden bei Versand?

### 1.1 Bedienerfehler (ungewollt)

> Verursacher: Kundenmitarbeiter bei Reinigung des Portals oder Schaltschranks.
> Kein Zugang zu Rechner-Innereien oder Verkabelung.

| Komponente        | Fehlerszenario                                                              | Auswirkung                                                                    |
| ----------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Portal allgemein  | Flüssigkeit gelangt ins Portal (Kamera, Beleuchtung)              | Kurzschluss oder optische Verschmutzung → Scan-Ausfall                        |
| Kamera            | Kameraobjektiv beim Reinigen verschmutzt oder zerkratzt                     | Bildqualität dauerhaft beeinträchtigt, KI-Inferenz liefert falsche Ergebnisse |
| LED-Beleuchtung   | LED-Leiste beim Reinigen mechanisch beschädigt oder Stecker gelöst          | Teilweise oder vollständige Dunkelheit → Scan nicht verwertbar                |
| Schaltschrank     | Schaltschranktür beim Reinigen offen gelassen → Staub/Schmutz umgeht Filter | Langfristig: Überhitzung, Kontaktprobleme                                     |
| Netzwerkkabel     | Kabel beim Reinigen versehentlich gezogen (Außenbereich Schaltschrank)      | UI nicht erreichbar oder Beleuchtungssteuerung ausgefallen                    |
| USV               | Beim Reinigen versehentlich Netzstecker der USV gezogen                     | Kein Puffer bei Stromausfall bis Fehler bemerkt wird                          | -> IDR wird im Schaltschrank nicht gereinigt. Abgeschottet durch Filter

### 1.2 Beabsichtigter Schaden (Sabotage / mutwillige Beschädigung)

> Verursacher: Kundenmitarbeiter oder Dritte mit physischem Zugang zum Portal/Schaltschrank.

| Ziel                              | Fehlerszenario                                                             | Auswirkung                                                                       |
| --------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Einzelkomponente: Kamera          | Absichtliches Abdecken oder Beschädigen der Objektiv /                          | Bilderfassung fällt aus – kein Softwarealarm                                     |
| Einzelkomponente: Kamera          | Starke externe Lichtquelle direkt in die Kamera ( oder auf die Scanlinie) gerichtet                  | Sensor überlichtet → fehlerhafte Bilder oder dauerhafter Sensorschaden          | -> Sensorschaden glaube ich nicht
| Einzelkomponente: LED-Beleuchtung | Beleuchtung absichtlich falsch eingestellt oder Kabel getrennt             | Stille Fehlklassifikation oder Totalausfall des Scans                            |
| Einzelkomponente: UPS             | Netzkabel der UPS absichtlich gezogen oder Akku beschädigt                 | System bei Stromausfall schutzlos → ungeplanter Shutdown, mögliche DB-Korruption |
| Einzelkomponente: Netzwerk        | Ethernet-Kabel (Beleuchtungssteuerung oder Kundennetz) absichtlich gezogen | MTD Illumination nicht steuerbar/veränderbar; UI nicht erreichbar                            | -> Sollte auch ohne laufen(bei nur einem genutzten Profil), da nur Einstellungen gesetzt werden können / Infos ausgelesen werden
| Gruppe: Schaltschrank             | Mutwillige Beschädigung des Schaltschranks (Schlag, Wasser, Feuer)         | Ausfall: IO-Module, Switches, Stromversorgung, UPS gleichzeitig → Totalausfall   |
| Gruppe: Portal                    | Mutwillige Beschädigung des Scan-Portals (Kamera, Beleuchtung, Mechanik)   | Vollständiger Produktionsstopp; Hardware-Austausch nötig                         |
| Gruppe: Stromversorgung           | 48V-Einspeisung unterbrochen oder Sicherung mutwillig ausgelöst            | Kompletter Ausfall aller 24V-versorgten Komponenten                              |
| Gruppe: Rechner                   | Mutwillige physische Beschädigung des PCs (Sturz, Schlag, Flüssigkeit)     | Totalausfall aller Komponenten gleichzeitig                                      |
-> Systemspionage? 


---

## 2. Software-Fehler

### 2.0 Natürlicher Verschleiß / Systemverhalten über Zeit

> Kein menschliches Fehlverhalten – ergibt sich aus Dauerbetrieb und Systemwachstum.

| Bereich                  | Fehlerszenario                                             | Auswirkung                                                                                                         |
| ------------------------ | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Shared Memory (Pipeline) | Memory Leak über Wochen → RAM-Fragmentierung               | Pipeline instabil; gelöst durch geplanten Reboot – schlägt der Cronjob einmalig fehl, akkumuliert sich das Problem |
| Zombie-Prozesse          | Anhäufung über Zeit bei ausbleibenden Reboots              | Systemressourcen erschöpft; Reboot-Cronjob als einzige Gegenmassnahme                                              |
| PostgreSQL               | DB wächst kontinuierlich (Geometriedaten, Logs, Metadaten) | Langfristig: längere Queryzeiten; kein automatisches Archivierungskonzept vorhanden                                |
| Systemd-Journal          | Log-Rotation greift nicht wenn ein Prozess exzessiv loggt  | `root`-Partition läuft voll → OS-Instabilität                                                                      |
| LUKS/TPM                 | TPM-Bindung bricht nach automatischem Kernel-Update        | System nach Reboot nicht entsperrbar → ungeplanter Ausfall bis manuelles Eingreifen                                |
| SSD → HDD Archivierung   | Kein implementiertes Archivierungskonzept → SSD läuft voll | Schreibfehler in DB und Bildablage; im schlimmsten Fall OS-Partition betroffen                                     |

### 2.1 Bedienerfehler (ungewollt)

> Verursacher: Kundenmitarbeiter über die UI (je nach Rolle).
> Rezepte und Uploads werden front- und backendseitig validiert (Syntax, Typen, Geometrie).
> Semantische Fehler (inhaltlich falsch aber formal gültig) werden nicht erkannt.

| Rolle            | Bereich             | Fehlerszenario                                                                      | Auswirkung                                                                                   |
| ---------------- | ------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | -> Falsche Einstellungen (Größenüberprüfung)
| Operator         | Aufträge            | Falschen Auftrag aktiviert (falsches Material/Rezept-Kombination)                   | Scan läuft mit falschem Rezept → Fehlklassifikation für gesamten Auftrag                     |
| Grenzebach Admin | Rezeptsystem        | Gültiges aber semantisch falsches Rezept gespeichert (z.B. Schwellwerte vertauscht) | Stille Fehlklassifikation – System zeigt keinen Fehler, Qualitätseinstufung dauerhaft falsch |
| Grenzebach Admin | KI-Modell           | Falsches `.aiaddon` hochgeladen (z.B. Holzmodell auf Gipsanlage)                    | Systematische Fehlklassifikation bis manuell bemerkt                                         |
| Grenzebach Admin | Systemeinstellungen | Kritische Systemeinstellung versehentlich geändert                                  | Je nach Einstellung: Pipeline-Fehler, Verbindungsabbruch, Fehlverhalten beim nächsten Start  |
| Grenzebach Admin | Benutzerverwaltung  | Versehentlich falsche Rolle vergeben                                                | Unbeabsichtigter Zugriff auf Funktionen die der User nicht bedienen soll/kann                |

### 2.2 Beabsichtigter Schaden (Sabotage)

> Verursacher: Kundenmitarbeiter mit entsprechender Rolle, oder Dritte die Zugangsdaten erlangt haben.
> Kein direkter Systemzugriff möglich – nur über die UI.

| Rolle            | Bereich                | Fehlerszenario                                                   | Auswirkung                                                                  |
| ---------------- | ---------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Grenzebach Admin | KI-Modell (`.aiaddon`) | Manipuliertes `.aiaddon` mit schadhaftem `plugin.py` hochgeladen | Schadcode wird beim Laden auf dem Produktivsystem ausgeführt                |
| Grenzebach Admin | Rezeptsystem           | Absichtlich falsches Rezept als aktiv gesetzt                    | Dauerhafte stille Fehlklassifikation → wirtschaftlicher Schaden beim Kunden |
| Grenzebach Admin | Systemeinstellungen    | Kritische Einstellungen mutwillig geändert                       | Betriebsstörung oder Ausfall beim nächsten Start                            |
| Grenzebach Admin | Benutzerverwaltung     | Accounts anderer Nutzer gesperrt oder Rollen entzogen            | Betriebsunterbrechung durch fehlende Zugriffsrechte                         |
| Jede Rolle       | Authentifizierung      | Credentials weitergegeben oder gestohlen → fremder Login         | Aktionen unter falscher Identität, keine Nachvollziehbarkeit                |
| Jede Rolle       | Netzwerk               | Fremdes Gerät ins Kundennetz eingeschleust                       | Zugriff auf ROSI-UI ohne eigene Credentials, falls Netzwerktrennung fehlt   |
