# ROSI – Fehlerszenarien während des Betriebs

> Ergänzungsdokument zur Wissensbasis (`Basis.md`)
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

| Vorfall                                          | Beschreibung                                                                                                                                                                                                          |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bitcoin-Miner auf Anlagenrechner**             | Auf einer Produktionsmaschine wurde unbemerkt Mining-Software installiert – vermutlich über einen externen Zugang. Dauerhafte GPU/CPU-Last, mögliche Scan-Beeinträchtigung, Entdeckung erst durch Performance-Abfall. |
| **USV abgeraucht**                               | Eine Unterbrechungsfreie Stromversorgung ist im Betrieb in Brand geraten. Totalausfall der angeschlossenen Komponenten, potenzielle Folgeschäden durch Hitze/Rauch im Schaltschrank.                                  |
| **Beleuchtung verstellt / Halterung verbogen**   | Monteur betritt während IBN (vor Beleuchtungsmontage) die Halterung und verbiegt diese; alternativ Beleuchtung durch Besteigen nachträglich verstellt. Verminderte Systemleistung, Schatteneffekte.                   |
| **Extreme Verstaubung Schaltschrank**            | Verstopfter Filter des Kühlgeräts → Kunde öffnet Schaltschrank eigenmächtig um Überhitzung zu verhindern → Staub dringt über langen Zeitraum unkontrolliert ein.                                                      |
| **Spannungsabfall Netzteil**                     | Netzteilspannung zu gering, sodass PC bei Lastspitzen (GPU-Inferenz) unerwartet ausfällt.                                                                                                                             |
| **Spannungsschwankung Netzanschluss**            | Große Verbraucher / Motoren in der Produktionshalle verursachen Spannungsschwankungen → Systeminstabilitäten, ggf. Monitorflackern.                                                                                   |
| **Lose Stecker / Pins beim Transport**           | Steckverbindungen lösen sich durch Vibrationen beim Transport; bei spannungsführenden Teilen auch nach Jahren im Betrieb durch Dauervibration → Beleuchtungsausfall.                                                  |
| **Schwingungsanregung Portal / Kamera**          | Externe Systeme regen das Portal oder die Kamerahalterung in Resonanz an → Kamera gerät aus dem Fokus → unscharfe Bilder ohne direkten Fehlerhinweis.                                                                 |
| **Sonneneinstrahlung auf Scanlinie**             | Durch eine Dachluke fällt Sonnenlicht direkt auf die Scanlinie → Störung der Defekterkennung und -klassifizierung.                                                                                                    |
| **Objektiv gelockert durch Vibration**           | Kameraobjektiv löst sich im Betrieb durch Dauervibration → Bildaufnahme nicht mehr korrekt / scharf; ggf. schleichend.                                                                                                |
| **Teilausfall Beleuchtung**                      | Ausfall einzelner LEDs oder eines LED-Treibers → ein Bildstreifen bleibt dunkel; bei welligen Platten zusätzlich Schatteneffekte.                                                                                     |
| **Vergilbung Abdeckglas**                        | Plastikabdeckglas von Kamera oder Beleuchtung vergilbt durch Alterung → schleichende Reduzierung der Lichtintensität.                                                                                                 |
| **Memory Leak → Watchdog eingeführt**            | Unbemerkter Memory Leak ließ das System alle paar Wochen abstürzen. Erst nach Einführung eines Watchdogs stabilisiert.                                                                                                |
| **TCP/IP-Verbindung bricht unbemerkt ab**        | Verbindung zur Datenübertragung brach ohne Rückmeldung ab. Erst nach Einführung einer Heartbeat-Prüfung erkennbar.                                                                                                    |
| **Software-Teilabsturz unbemerkt**               | Ein Softwarebestandteil stürzt ab, der andere übermittelt weiterhin Heartbeat → Watchdog muss auf alle Einzelkomponenten angewendet werden, nicht nur auf den Gesamtprozess.                                          |
| **RAM Disk nicht geladen**                       | Beim Systemstart wird die RAM Disk nicht gemountet → Pipeline kann nicht starten, keine Inspektion möglich.                                                                                                           |
| **Autostart-Verknüpfung veraltet**               | Nach einem Update wurde die Autostart-Verknüpfung nicht aktualisiert → System lädt beim Neustart einen veralteten Softwarestand, läuft scheinbar normal.                                                              |
| **Korrupte Einstellungsdatei**                   | Einstellungsdatei war korrupt → Qualitätsevaluation nicht mehr möglich; Fehler erst durch ausbleibende Ergebnisse bemerkt.                                                                                            |
| **Speicher voll durch Logs**                     | Logs wurden nicht automatisch rotiert → Speicher läuft voll, System hängt sich auf.                                                                                                                                   |
| **Kunde im Adminbereich**                        | Kunde hatte Zugang zu kritischen Einstellungen (z.B. Schwellwerte) und verstellt das System unwissentlich.                                                                                                            |
| **Knowhow-Verlust durch Mitarbeiterabgang**      | Nicht mehr verfügbare Mitarbeiter → Kunde kann bei Problemen nicht mehr geholfen werden → System wird de facto abgekündigt.                                                                                           |
| **Veraltete, nicht mehr verfügbare Komponenten** | Altanlagen (≥ 18 Jahre): elektrische Komponenten nicht mehr lieferbar → Reparatur nicht möglich.                                                                                                                      |

---

## 1. Hardware-Fehler

### 1.0 Natürlicher Verschleiß / Umgebungseinflüsse

> Kein menschliches Fehlverhalten – passiert im Normalbetrieb über Zeit oder durch externe Faktoren.

| Komponente                         | Fehlerszenario                                                                                                    | Auswirkung                                                                                                                                                                       |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| NVMe SSD                           | TBW-Erschöpfung durch Datenbank- und OS-Schreiblast im Dauerbetrieb                                               | Schreibfehler, Datenverlust, Systemausfall; Zeitpunkt schwer vorhersagbar. _(Bildlast entfällt – Bilder werden direkt auf HDD geschrieben.)_                                     |
| HDD (Bildspeicher)                 | HDD-Ausfall während laufender Produktion                                                                          | Direkte Bildverluste ohne Zwischenpuffer auf SSD; kein automatischer Fallback                                                                                                    |
| HDD (Bildspeicher)                 | HDD läuft voll (Retention-Dauer nicht auf Kundenbedarf abgestimmt)                                                | Schreibfehler bei neuen Bildern; Produktion läuft weiter, Bilder gehen verloren                                                                                                  |
| HDD (Bildspeicher)                 | Schreibdurchsatz der HDD reicht bei Spitzenlast nicht aus                                                         | Frames werden zu langsam weggeschrieben → Pipeline-Stau; im schlimmsten Fall Frame-Drops                                                                                         |
| LED-Beleuchtung                    | Schleichender Helligkeitsverlust durch LED-Alterung                                                               | KI-Modell auf ursprüngliche Lichtintensität trainiert → schleichende Fehlklassifikation ohne Fehlerindikator; bei klassischer Bildverarbeitung (Thresholding) besonders kritisch |
| LED-Beleuchtung                    | Überhitzung durch zugestaubte Kühlrippen oder ausgefallenes Kühlsystem                                            | Beschleunigte LED-Alterung, Intensitätsabfall, verkürzte Lebensdauer                                                                                                             |
| LED-Beleuchtung                    | Teilausfall: einzelne LEDs oder LED-Treiber ausgefallen                                                           | Ein Bildstreifen bleibt dunkel; bei welligen Platten Schatteneffekte; kein direkter Softwarealarm                                                                                |
| Kameraobjektiv / Abdeckscheibe     | Schleichende Verschmutzung durch Produktionsstaub (Gips/Holz)                                                     | Zunächst Intensitätsverlust, dann Unschärfe; unklar ab wann KI-Inferenz unzuverlässig wird                                                                                       |
| Abdeckscheibe Kamera / Beleuchtung | Vergilbung durch Alterungsprozesse (v.a. Kunststoffabdeckungen)                                                   | Schleichende Reduzierung der Lichtintensität → analog zu LED-Alterung, kein Fehlerindikator                                                                                      |
| Kameraobjektiv                     | Lockert sich durch Dauervibration im Betrieb                                                                      | Bildaufnahme nicht mehr korrekt / scharf; ggf. schleichend ohne klaren Fehlerzeitpunkt                                                                                           |
| Kamera                             | Vollständiger Kameraausfall (Sensor, Elektronik)                                                                  | Bilderfassung fällt komplett aus; kein Softwarealarm wenn Framegrabber keinen Fehler meldet                                                                                      |
| UPS                                | Akku-Kapazitätsverlust durch Alterung                                                                             | Puffer reicht bei Stromausfall nicht mehr für geordnetes Herunterfahren                                                                                                          |
| UPS                                | Thermisches Ereignis / Brand (analog zu realem Vorfall)                                                           | Totalausfall + potenzielle Folgeschäden durch Hitze/Rauch im Schaltschrank                                                                                                       |
| Schaltschrank-Filter               | Filter setzt sich über Zeit mit Produktionsstaub zu                                                               | Eingeschränkte Luftzirkulation → Überhitzung von PC, Switches, IO-Modulen                                                                                                        |
| Netzteil-Lüfter                    | Ausfall des Netzteil-Lüfters                                                                                      | Überhitzung des Netzteils → Systemabsturz oder dauerhafter Hardwareschaden                                                                                                       |
| Encoder                            | Mechanischer Verschleiß → fehlerhafte Geschwindigkeitssignale                                                     | Frames kommen zu früh/spät → geometrisch falsche Inspektion ohne Fehlerindikator                                                                                                 |
| Lichtschranke                      | Verschmutzung der Optik durch Produktionsstaub                                                                    | Trigger löst nicht mehr zuverlässig aus → Material wird nicht gescannt, kein Alarm                                                                                               |
| FAST I/O Interface Modul           | Einzelner digitaler Eingangs- oder Ausgangskanal defekt (z.B. Encoder-Signal, Lichtschranke, Stapelplatz-Ausgang) | Kein Totalausfall des Moduls – andere Kanäle laufen normal weiter; Fehler schwer zu lokalisieren, da kein direkter Softwarealarm auf Kanalebene                                  |
| Framegrabber-Treiber               | Treiber-Cache läuft bei langer Uptime voll                                                                        | Instabiler Kamerazugriff, Bildübertragungsfehler; gelöst durch geplanten Reboot                                                                                                  |
| Netzwerkkabel                      | Kabelermüdung durch dauerhaften Betrieb, Knicke, Vibrationen                                                      | Intermittierende Verbindungsabbrüche schwer zu debuggen                                                                                                                          |
| Portal / Kamerahalterung           | Schwingungsanregung durch externe Systeme (Maschinen, Förderbänder)                                               | Kamera gerät aus dem Fokus → unscharfe Bilder ohne direkten Fehlerhinweis                                                                                                        |
| Umgebung (Licht)                   | Sonneneinstrahlung durch Dachluke direkt auf Scanlinie                                                            | Störung der Defekterkennung und -klassifizierung; zeitabhängig (Tageszeit, Jahreszeit)                                                                                           |

### 1.1 Bedienerfehler (ungewollt)

> Verursacher: Kundenmitarbeiter bei Reinigung des Portals oder Schaltschranks.
> Kein Zugang zu Rechner-Innereien oder Verkabelung.

| Komponente       | Fehlerszenario                                                                                                                                          | Auswirkung                                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Portal allgemein | Flüssigkeit gelangt ins Portal (Kamera, Beleuchtung)                                                                                                    | Kurzschluss oder optische Verschmutzung → Scan-Ausfall                          |
| Kamera           | Kameraobjektiv beim Reinigen verschmutzt oder zerkratzt                                                                                                 | Bildqualität dauerhaft beeinträchtigt, KI-Inferenz liefert falsche Ergebnisse   |
| Kamera           | Plastikabdeckung beim Reinigen eingedrückt / beschädigt                                                                                                 | Staub dringt ins Kameragehäuse ein → schleichende Bildqualitätsverschlechterung |
| LED-Beleuchtung  | LED-Leiste beim Reinigen mechanisch beschädigt oder Stecker gelöst                                                                                      | Teilweise oder vollständige Dunkelheit → Scan nicht verwertbar                  |
| Schaltschrank    | Schaltschranktür beim Reinigen offen gelassen → Staub/Schmutz umgeht Filter                                                                             | Langfristig: Überhitzung, Kontaktprobleme                                       |
| Netzwerkkabel    | Kabel beim Reinigen versehentlich gezogen (Außenbereich Schaltschrank)                                                                                  | UI nicht erreichbar oder Beleuchtungssteuerung ausgefallen                      |
| UPS              | Beim Reinigen versehentlich Netzstecker der UPS gezogen _(Schaltschrank-USV ist durch Filter abgeschottet – nur relevant bei geöffnetem Schaltschrank)_ | Kein Puffer bei Stromausfall bis Fehler bemerkt wird                            |

### 1.2 Beabsichtigter Schaden (Sabotage / mutwillige Beschädigung)

> Verursacher: Kundenmitarbeiter oder Dritte mit physischem Zugang zum Portal/Schaltschrank.

| Ziel                              | Fehlerszenario                                                                                  | Auswirkung                                                                                                           |
| --------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Einzelkomponente: Kamera          | Absichtliches Abdecken oder Beschädigen des Objektivs                                           | Bilderfassung fällt aus – kein Softwarealarm                                                                         |
| Einzelkomponente: Kamera          | Starke externe Lichtquelle direkt auf die Scanlinie oder in die Kamera gerichtet                | Sensor überlichtet → fehlerhafte Bilder                                                                              |
| Einzelkomponente: LED-Beleuchtung | Beleuchtung absichtlich falsch eingestellt oder Kabel getrennt                                  | Stille Fehlklassifikation oder Totalausfall des Scans                                                                |
| Einzelkomponente: UPS             | Netzkabel der UPS absichtlich gezogen oder Akku beschädigt                                      | System bei Stromausfall schutzlos → ungeplanter Shutdown, mögliche DB-Korruption                                     |
| Einzelkomponente: Netzwerk        | Ethernet-Kabel (Beleuchtungssteuerung oder Kundennetz) absichtlich gezogen                      | MTD Illumination nicht mehr konfigurierbar _(System läuft mit letztem gesetztem Profil weiter)_; UI nicht erreichbar |
| Gruppe: Schaltschrank             | Mutwillige Beschädigung des Schaltschranks (Schlag, Wasser, Feuer)                              | Ausfall: IO-Module, Switches, Stromversorgung, UPS gleichzeitig → Totalausfall                                       |
| Gruppe: Portal                    | Mutwillige Beschädigung des Scan-Portals (Kamera, Beleuchtung, Mechanik)                        | Vollständiger Produktionsstopp; Hardware-Austausch nötig                                                             |
| Gruppe: Stromversorgung           | 48V-Einspeisung unterbrochen oder Sicherung mutwillig ausgelöst                                 | Kompletter Ausfall aller 24V-versorgten Komponenten                                                                  |
| Gruppe: Rechner                   | Mutwillige physische Beschädigung des PCs (Sturz, Schlag, Flüssigkeit)                          | Totalausfall aller Komponenten gleichzeitig                                                                          |
| Systemspionage                    | Fremdes Gerät physisch ans Kundennetz angeschlossen (z.B. hinter einem Switch im Schaltschrank) | Passiver Datenabgriff von Inspektionsdaten, Netzwerkverkehr, ggf. Modell-IP                                          |

---

## 2. Software-Fehler

### 2.0 Natürlicher Verschleiß / Systemverhalten über Zeit

> Kein menschliches Fehlverhalten – ergibt sich aus Dauerbetrieb und Systemwachstum.

| Bereich                    | Fehlerszenario                                                               | Auswirkung                                                                                                         |
| -------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| RAM Disk (Pipeline-Cache)  | RAM Disk wird beim Systemstart nicht gemountet                               | Pipeline kann nicht starten → keine Inspektion möglich; Fehler ggf. erst mit Verzögerung bemerkt                   |
| RAM Disk (Pipeline-Cache)  | RAM Disk läuft im Betrieb voll (akkumulierende Zwischendaten)                | Schreibfehler in der Pipeline; Frame-Drops oder Absturz möglich                                                    |
| RAM Disk (Pipeline-Cache)  | Ungeplanter Reboot / Absturz → RAM Disk-Inhalt verloren                      | In-flight-Daten (aktuell verarbeitete Frames) unwiederbringlich verloren                                           |
| Shared Memory (Pipeline)   | Memory Leak über Wochen → RAM-Fragmentierung                                 | Pipeline instabil; gelöst durch geplanten Reboot – schlägt der Cronjob einmalig fehl, akkumuliert sich das Problem |
| Zombie-Prozesse            | Anhäufung über Zeit bei ausbleibenden Reboots                                | Systemressourcen erschöpft; Reboot-Cronjob als einzige Gegenmassnahme                                              |
| PostgreSQL                 | DB wächst kontinuierlich (Geometriedaten, Logs, Metadaten)                   | Langfristig: längere Queryzeiten; kein automatisches Archivierungskonzept vorhanden                                |
| Systemd-Journal            | Log-Rotation greift nicht wenn ein Prozess exzessiv loggt                    | `root`-Partition läuft voll → OS-Instabilität                                                                      |
| LUKS/TPM                   | TPM-Bindung bricht nach automatischem Kernel-Update                          | System nach Reboot nicht entsperrbar → ungeplanter Ausfall bis manuelles Eingreifen                                |
| HDD (Bildspeicher)         | HDD läuft voll ohne automatische Bereinigung                                 | Neue Bilder können nicht geschrieben werden; Pipeline-Fehler oder Absturz                                          |
| Autostart-Verknüpfung      | Verknüpfung nach Update nicht aktualisiert → veralteter Softwarestand lädt   | System läuft scheinbar normal, verwendet aber alten Code; Fehler schwer zu reproduzieren                           |
| TCP/IP-Verbindung          | Interne Verbindung zur Datenübertragung bricht unbemerkt ab (kein Heartbeat) | Teilsystem arbeitet weiter, Daten kommen nicht an; erst durch fehlende Ergebnisse bemerkt                          |
| Korrupte Einstellungsdatei | Einstellungsdatei durch Absturz oder Schreibfehler korrupt                   | Qualitätsevaluation oder Pipeline-Start nicht mehr möglich; Fehler ggf. schwer zu diagnostizieren                  |

### 2.1 Bedienerfehler (ungewollt)

> Verursacher: Kundenmitarbeiter über die UI (je nach Rolle).
> Rezepte und Uploads werden front- und backendseitig validiert (Syntax, Typen, Geometrie).
> Semantische Fehler (inhaltlich falsch aber formal gültig) werden nicht erkannt.

| Rolle            | Bereich             | Fehlerszenario                                                                      | Auswirkung                                                                                   |
| ---------------- | ------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Operator         | Aufträge            | Falschen Auftrag aktiviert (falsches Material/Rezept-Kombination)                   | Scan läuft mit falschem Rezept → Fehlklassifikation für gesamten Auftrag                     |
| Grenzebach Admin | Rezeptsystem        | Gültiges aber semantisch falsches Rezept gespeichert (z.B. Schwellwerte vertauscht) | Stille Fehlklassifikation – System zeigt keinen Fehler, Qualitätseinstufung dauerhaft falsch |
| Grenzebach Admin | Rezeptsystem        | Falsche Größeneinstellungen konfiguriert (z.B. Plattenmaße, Inspektionsbereich)     | Defekte außerhalb des konfigurierten Bereichs werden ignoriert; falsche Qualitätseinstufung  |
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
