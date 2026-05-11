# ROSI – Fehlerszenarien: Inbetriebnahme & Betrieb (Grenzebach-intern)

> Ergänzungsdokument zur Wissensbasis (`Basis.md`)
> Ziel der Fallstudie: Problemstellen identifizieren – keine Lösungen erzwingen.
> Fokus: Grenzebach als Fehlerquelle – Vorbereitung in der Firma, Lieferung, Vor-Ort-Installation, laufender Betrieb.

---

## Kontext: Deployment-Ablauf

Der Rechner wird **vollständig bei Grenzebach vorbereitet** (ISO-Install + Ansible-Provisioning) und dann fertig konfiguriert zum Kunden geliefert. Vor Ort wird er nur in den Schaltschrank gestellt, angestöpselt und gestartet.

```
[Grenzebach BSH]                        [Kunde vor Ort]
ISO flashen → Ansible → Testen   →   Liefern → Einstecken → Start
     ↑
Fehler hier = Kunde bekommt
kaputtes / unsicheres System
```

---

## 1. Inbetriebnahme

### 1.1 Vorbereitung bei Grenzebach (ISO + Ansible)

| Bereich   | Fehlerszenario                                                                           | Auswirkung                                                                                              |
| --------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| ISO-Build | Falsches oder veraltetes eGrabber-Payload                                                | Framegrabber nicht funktionsfähig; Kamerazugriff schlägt fehl                                           |
| ISO-Build | Unternehmens-CA-Zertifikat fehlt oder abgelaufen                                         | Ansible-Provisioning schlägt fehl; interne HTTPS-Verbindungen nicht vertrauenswürdig                    |
| Ansible   | `group_vars/all.yml` nicht mit kundenspezifischen Produktions-Passwörtern befüllt        | System geht mit Default-Credentials (`rosi/ROSI`) in Produktion → trivial angreifbar                    |
| Ansible   | `hosts.yml` zeigt auf falsche IP (z.B. noch Vorjahr-Maschine)                            | Falsches System wird provisioniert; beide Systeme danach inkonsistent                                   |
| Ansible   | Playbook bricht mittendrin ab (Netzwerkfehler, Timeout) und wird nicht erneut ausgeführt | System bleibt in halbkonfiguriertem Zustand: z.B. Passwort geändert aber Clevis/TPM noch nicht gebunden |
| Ansible   | Clevis-TPM-Bindung schlägt beim Provisioning fehl (TPM nicht vorhanden oder deaktiviert) | LUKS-Unlock beim ersten Boot am Kundensystem funktioniert nicht → System nicht startbar                 |
| Ansible   | Dropbear-SSH nicht korrekt in initramfs installiert                                      | Kein Notfall-Fernzugang für Remote-LUKS-Unlock möglich                                                  |
| Ansible   | Firewall-Rolle fehlerhaft konfiguriert                                                   | SSH-Zugang für Fernwartung blockiert, oder ROSI-WebUI nicht erreichbar im Kundennetz                    |
| Podman    | Memcached/Redis/PostgreSQL-Container nicht gestartet oder falsch konfiguriert            | ROSI-Backend startet nicht; keine DB-Verbindung                                                         |
| Testen    | Kein vollständiger Abnahmetest vor Auslieferung                                          | Fehler werden erst beim Kunden entdeckt                                                                 |

### 1.2 Transport & Lieferung

| Bereich    | Fehlerszenario                                                                          | Auswirkung                                                                                   |
| ---------- | --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Mechanisch | Erschütterungen beim Transport → PCIe-Karten (GPU, Framegrabber) locker                 | Sporadische oder dauerhafte Hardware-Fehler beim ersten Boot                                 |
| Mechanisch | NVMe-SSD durch Vibration gelockert                                                      | System startet nicht; Datenverlust wenn SSD während Transport mit Schreibvorgängen aktiv war |
| Lieferung  | Falscher Rechner an falschen Kunden geliefert (falsche Hostname/Passwort-Konfiguration) | Kundendaten und Konfiguration passen nicht zusammen; Sicherheitsrisiko                       |
| Lieferung  | Langer Lagerweg → Akku der UPS tiefentladen bei Ankunft                                 | UPS nicht funktionsfähig beim ersten Betrieb                                                 |

### 1.3 Installation vor Ort

| Bereich         | Fehlerszenario                                                             | Auswirkung                                                              |
| --------------- | -------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Verkabelung     | Ethernet-Kabel für MTD Illumination und Kundennetz vertauscht angestöpselt | Beleuchtungssteuerung im falschen Netz; UI nicht erreichbar             |
| Verkabelung     | Framegrabber-Kabel (Kamera) falsch angeschlossen oder nicht eingesteckt    | Kein Kamerasignal; Health-Check schlägt fehl                            |
| Netzwerk        | Kundennetz blockiert SSH (Port 22) durch Firewall                          | Fernwartung durch Grenzebach nicht möglich                              |
| Netzwerk        | IP-Konflikt im Kundennetz (statische IP bereits vergeben)                  | ROSI-PC nicht erreichbar; UI nicht aufrufbar                            |
| Netzwerk        | Kundennetz nur DHCP → IP wechselt nach Reboot                              | UI-Adresse ändert sich; Nutzer können System nicht mehr finden          |
| Stromversorgung | 48V-Einspeisung im Schaltschrank nicht korrekt angeschlossen               | Kompletter Ausfall der 24V-Versorgung: IO-Module, Switches, Encoder tot |
| Erster Start    | TPM-Chip im BIOS deaktiviert (Kundenrechner) → Clevis kann nicht binden    | LUKS-Unlock schlägt fehl; System startet nicht ohne manuelle Passphrase |
| Erster Start    | Secure Boot im BIOS deaktiviert                                            | NVIDIA/Framegrabber-Module können nicht geladen werden                  |
| Erster Start    | BIOS-Einstellung "Restore on AC Power Loss" nicht auf `Power On`           | System startet nach Stromausfall nicht automatisch                      |

---

## 2. Laufender Betrieb (Grenzebach-seitig)

### 2.1 Fernwartung & Updates

| Bereich          | Fehlerszenario                                                                              | Auswirkung                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Kernel-Update    | Manuelles Kernel-Update beim Service-Termin → TPM-PCR-Werte ändern sich                     | LUKS-Unlock nach nächstem Reboot fehlgeschlagen; Dropbear als Fallback nötig |
| Kernel-Update    | Neuer Kernel inkompatibel mit NVIDIA- oder eGrabber-Treiber                                 | GPU/Framegrabber nicht erkannt nach Reboot; Produktionsausfall               |
| ROSI-Update      | Deployment eines fehlerhaften ROSI-Software-Stands auf Kundensystem                         | Produktionsausfall; kein automatischer Rollback vorgesehen                   |
| ROSI-Update      | Neues `.aiaddon` Modell deployed ohne vorherigen Test auf gleichem Material                 | Sofortige Fehlklassifikation im laufenden Betrieb                            |
| Dropbear         | LUKS-Notfall-Unlock via Dropbear: Falscher Key verwendet                                    | System bleibt gesperrt; physischer Vor-Ort-Einsatz nötig                     |
| Dropbear         | Dropbear-Key nur zentral bei Grenzebach → Techniker vor Ort hat keinen Zugriff ohne Rückruf | Verzögerung bei Notfall-Unlock; verlängerte Ausfallzeit                      |
| SSH              | Servicetechniker arbeitet versehentlich auf falschem System (falsche IP in Terminal)        | Falsches Produktivsystem wird verändert                                      |
| Podman-Container | PostgreSQL-Container stürzt ab und startet nicht automatisch neu                            | Keine DB-Verbindung; ROSI-Backend nicht funktionsfähig                       |
| Podman-Container | Redis/Memcached-Container verliert Cache bei ungeplanten Restarts                           | Mögliche Inkonsistenzen im laufenden Betrieb                                 |

### 2.2 Datensicherung & Speicher

| Bereich            | Fehlerszenario                                                                        | Auswirkung                                                   |
| ------------------ | ------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| DB-Backup          | Monatliches manuelles HDD-Backup wird bei einem Service-Termin vergessen              | Datenverlust-Risiko von bis zu >1 Monat Inspektionsdaten     |
| DB-Backup          | HDD-Backup schlägt fehl (HDD voll, defekt) ohne Rückmeldung                           | Kein gültiges Backup vorhanden; unbemerkt                    |
| SSD → HDD Transfer | Automatischer Bild-Transfer nicht implementiert → SSD läuft innerhalb von Wochen voll | Schreibfehler, möglicher Systemausfall                       |
| HDD                | HDD-Kapazität nicht auf Kundenbedarf (Retention-Dauer) abgestimmt                     | HDD läuft voll; Transfer schlägt fehl; Bilder gehen verloren |
