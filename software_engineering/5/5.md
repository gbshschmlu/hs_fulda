# Übungsblatt 5

<div style="text-align: right">Luca M. Schmidt</div>

## 1. Nicht-funktionale Anforderungen (Fitness-App)

### Performanz-Anforderungen

* **Ladezeiten:** Videos < 3s Ladezeit; App-Reaktion < 500ms
* **Speicherplatz:** Max. 150MB lokaler Speicher für Offline-Inhalte
* **Batterielaufzeit:** Max. 15% zusätzlicher Akkuverbrauch bei aktiver Nutzung
* **Synchronisation:** Datenabgleich zwischen Geräten < 10s

### Benutzbarkeits-Anforderungen

* **Navigation:** Intuitiv; Kernfunktionen max. 3 Klicks erreichbar
* **Barrierefreiheit:** Screen-Reader-Unterstützung; Kontrast min. 4.5:1
* **Mehrsprachigkeit:** Deutsch, Englisch; weitere Sprachen erweiterbar
* **Responsivität:** Optimiert für Smartphones, Tablets und Smartwatches

### Zuverlässigkeits-Anforderungen

* **Verfügbarkeit:** 99.5% Uptime für Cloud-Services
* **Datensicherheit:** Kein Datenverlust bei App-Absturz oder Gerätwechsel
* **Offline-Fähigkeit:** Grundfunktionen ohne Internetverbindung nutzbar
* **Fehlerbehandlung:** Graceful Degradation bei Netzwerkproblemen

### Sicherheits- und Datenschutz-Anforderungen

* **DSGVO-Konformität:** Vollständige Einhaltung europäischer Datenschutzbestimmungen
* **Verschlüsselung:** End-to-End-Verschlüsselung für Datenübertragung und -speicherung
* **Authentifizierung:** Zwei-Faktor-Authentifizierung optional verfügbar
* **Datenminimierung:** Nur notwendige Gesundheitsdaten werden erfasst und gespeichert
*

---

## 2. Benutzer und Systemanforderungen (Fitness-App)

* **Benutzeranforderung (BA):**
  Als Nutzer möchte ich meine Laufstrecken aufzeichnen und auf einer Karte anzeigen.

* **Systemanforderungen (SA) abgeleitet aus BA:**
    1. **SA1:** System muss GPS-Koordinaten während Laufaufzeichnung erfassen.
    2. **SA2:** System muss Route speichern und auf Karte darstellen können.
    3. **SA3:** System muss Gesamtdistanz der Route berechnen und anzeigen.

---

## 3. Die Phasen des Requirements Engineering

**Beispiel:** Verwaltungssoftware Universitätsbibliothek

| Stufe                     | Runde 1                    | Runde 2                   | Runde 3                         |
|:--------------------------|:---------------------------|:--------------------------|:--------------------------------|
| **Ermittlung**            | **Start:** Kundenbedarf    | **Benutzeranforderungen** | **Systemanforderungen**         |
| *Thema*                   | Effizientere Verwaltung    | Ausleihprozess            | Technische Anforderungen        |
| *Ergebnis*                | Vision, Ziele              | Benutzeranforderungen     | Systemanforderungen             |
| *Rollen aktiv*            | Leitung, RE-Analyst        | Nutzer, RE-Analyst        | RE-Analyst, Technik-Team        |
| **Spezifikation/Analyse** | **Geschäftsanforderungen** | **Benutzeranforderungen** | **Systemanforderungen**         |
| *Thema*                   | Ziele, Kostensenkung       | Use Cases, Mock-ups       | Funktionen, Architektur         |
| *Ergebnis*                | Geschäftsziele, Scope      | Lastenheft, GUI-Entwürfe  | Pflichtenheft, Architektur      |
| *Rollen aktiv*            | Leitung, Management        | RE-Analyst, Designer      | RE-Analyst, Architekt           |
| **Validierung**           | **Machbarkeitsstudie**     | **Prototyp, Review**      | **Systemtest**                  |
| *Thema*                   | Machbarkeit, Risiken       | Klick-Prototyp            | Modellprüfung, Kernfunktionen   |
| *Ergebnis*                | Go/No-Go, Risikobewertung  | Validierter Prototyp      | Abnahme                         |
| *Rollen aktiv*            | Analyst, Management        | Entwickler, Nutzer        | Tester, Entwickler, Stakeholder |

---

## 4. Anforderungen Fitnessarmband (Lücken und Mehrdeutigkeiten)

* **"auf Aufforderung"**: Wie genau? Kontinuierlich oder nur auf Start?
* **"auf das Smartphone ausgegeben"**: Was bei keiner BT-Verbindung? Echtzeit?
* **"Tagesreport und Wochenreport"**: Wo/Wie ausgewählt/angezeigt? Inhalt?
* **"hohe Messgenauigkeit"**: Quantitativ? (z.B. ±5% Schritte?)

---

## 5. Strukturierte Anforderungen Fitnessarmband

* **Funktion:** Tagesreport für Schritte anzeigen
* **Beschreibung:** Anzeige des Reports über tägliche Schritte/Distanz in der App.
* **Eingaben:** Benutzerauswahl "Tagesreport", aktuelles Datum, gespeicherte Schritt-/Distanzdaten.
* **Quelle:** Nutzerinteraktion, Smartphone-System, interne Datenhaltung.
* **Ausgaben:** Visuelle Darstellung Tagesreport (Schritte, Distanz) auf Smartphone.
* **Ziel:** Schneller Überblick tägliche Aktivität.
* **Aktion:**
    1. Nutzer wählt "Tagesreport".
    2. Ggf. Synchronisation der Daten vom Armband.
    3. Daten aufbereiten und in App darstellen.
* **Benötigt:** Smartphone mit App, ggf. verbundenes Armband, erfasste Daten.
* **Vorbedingung:** Nutzer angemeldet, App hat nötige Rechte.
* **Nachbedingung:** Tagesreport sichtbar.
* **Seiteneffekte:** Ggf. erhöhter Akkuverbrauch (BT-Sync).
