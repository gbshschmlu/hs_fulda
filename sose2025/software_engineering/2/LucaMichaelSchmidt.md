# Übungsblatt 2 – Vorgehensmodelle

<div style="text-align: right">Luca M. Schmidt</div>

## 1. V-Modell für Papierfliegerproduktion

* **Firma:** Grenzebach BSH GmbH
* **Logo:** Grenzebach BSH GmbH (Corporate Design Logo Nr. 3)
* **Farben:** Rot und Schwarz

### Projektplan

| **Schritt**                               | **Zeit (min.)** | **Aufgabe**                                                                                                        |
|-------------------------------------------|-----------------|--------------------------------------------------------------------------------------------------------------------|
| **1. Vorbereitung & Materialzuschnitt**   | 5               | - Faltanleitung (referenziert in F-1, SP-4) prüfen & verstehen                                                     |
|                                           |                 | - 1 Blatt DIN A4 Papier, Schere bereitstellen (gem. F-2)                                                           |
|                                           |                 | - Quadrat für Hauptkörper aus DIN A4 schneiden, Reststreifen für Heckleitwerk sichern (gem. F-3)                   |
|                                           |                 | - Stifte/Drucker für Logo/Farben bereitlegen (gem. F-4)                                                            |
| **2. Hauptkörper falten (Komponente 1)**  | 10              | - Hauptkörper aus dem Quadrat gemäß Anleitung (Schritte 1-15 der Anleitung, gem. F-1, F-3, SysArch) falten         |
|                                           |                 | - Nach Faltung implizite Prüfung gem. MF-1, MF-2, MF-3                                                             |
| **3. Heckleitwerk falten (Komponente 2)** | 5               | - Heckleitwerk aus dem Reststreifen gemäß Anleitung (Schritte 16-21 der Anleitung, gem. F-1, F-3, SysArch) falten  |
|                                           |                 | - Nach Faltung implizite Prüfung gem. MS-1, MS-2, MS-3                                                             |
| **4. Designapplikation & Integration**    | 5               | - Logo der Grenzebach BSH GmbH und Farben (rot/schwarz) auf eine oder beide Komponenten auftragen (gem. F-4, SP-2) |
|                                           |                 | - Hauptkörper und Heckleitwerk zum Gesamtsystem zusammenfügen und festen Sitz prüfen (gem. SP-1, AK-3)             |
| **5. Systemtests, Anpassung & Abnahme**   | 5               | - Visuelle Prüfung des Designs (SP-2) und der Vollständigkeit der Faltung (SP-4)                                   |
|                                           |                 | - Flugtest durchführen (SP-3): Grundlegende Gleitflugeigenschaften (F-5, AK-4) prüfen                              |
|                                           |                 | - Ggf. kleinere Anpassungen an Flügeln/Heck zur Verbesserung der Flugfähigkeit                                     |
|                                           |                 | - Finale Abnahmeprüfung (AK-1 bis AK-4)                                                                            |

### Liste der Anforderungen (Systemspezifikation)

* **F-1:** Der Flieger muss exakt nach der gegebenen schriftlichen Anleitung gefaltet werden
* **F-2:** Benötigtes Material ist 1 Blatt DIN A4 Papier und eine Schere
* **F-3:** Der Flieger besteht aus zwei Teilen: Hauptkörper (aus Quadrat gefaltet) und Heckleitwerk (aus
  abgeschnittenem Streifen gefaltet)
* **F-4:** Der Flieger muss das Logo der Grenzebach BSH GmbH (in schwarz/rot) tragen
* **F-5:** Der Flieger soll nach Fertigstellung grundlegende Gleitflugeigenschaften besitzen

### Systemarchitektur

* **Komponente 1:** Hauptkörper/Flügel
* *Funktion:* Erzeugt Auftrieb, bildet die Grundstruktur
* *Basis:* Quadratisches Papierstück, gefaltet nach Schritten 1-15 der Anleitung
* *Schnittstelle:* Aufnahmeöffnung für Heckleitwerk
* **Komponente 2:** Heckleitwerk/Schwanz
* *Funktion:* Stabilisiert den Flug
* *Basis:* Papierstreifen (Rest vom DIN A4 Blatt), gefaltet nach Schritten 16-21 der Anleitung.
* *Schnittstelle:* Spitze zum Einführen in Komponente 1
* **Design:** Logo/Farben werden auf dem Papier angebracht (z.B. vor dem Falten auf das spätere Quadrat drucken oder
  nach dem Falten aufmalen)

### Testspezifikation der Module

* **Modul: Hauptkörper/Flügel**
* **MF-1:** Prüfung der Faltung zum Quadrat (exakte Kanten)
* **MF-2:** Prüfung der korrekten Faltung der "Ziehharmonika"-Struktur (Falten 3 auf 1, 4 auf 2, 5 auf 1)
* **MF-3:** Prüfung der korrekten Faltung der Spitzen zur Mitte
* **Modul: Heckleitwerk/Schwanz**
* **MS-1:** Prüfung der korrekten Dimensionen des abgeschnittenen Streifens
* **MS-2:** Prüfung der korrekten Faltung des Streifens (Halbierung, Spitzen zur Mittellinie)
* **MS-3:** Prüfung der Form der Spitze für das Einführen

### Testspezifikation des Systems

* **SP-1 (Integrationstest):** Das Heckleitwerk lässt sich korrekt und bis zur vorderen Spitze in den Hauptkörper
  einschieben und sitzt fest
* **SP-2 (Validierung Design):** Visuelle Prüfung: Logo und Farben sind korrekt platziert und sichtbar
* **SP-3 (Funktionstest):** Flugtest: Flieger wird gerade gehalten und geworfen. Beobachtung: Gleitet der Flieger
  über eine kurze Distanz (z.B. > 2 Meter)?
* **SP-4 (Vollständigkeitstest):** Alle Faltschritte der Anleitung wurden sichtbar umgesetzt

### Abnahme-Report

* **Abnahmekriterium AK-1:** Flieger entspricht der Anleitung und besteht aus 2 Teilen (F-1, F-3). **Ergebnis:**
* Bestanden
* **Abnahmekriterium AK-2:** Logo und Farben der Grenzebach BSH GmbH sind korrekt angebracht (F-4). **Ergebnis:**
  Bestanden
* **Abnahmekriterium AK-3:** Integration der Teile erfolgreich (SP-1). **Ergebnis:** Bestanden
* **Abnahmekriterium AK-4:** Grundlegende Flugfähigkeit nachgewiesen (SP-3). **Ergebnis:** Bestanden
* **Gesamturteil:** Produkt abgenommen

---

## 2. Inkrementelle Softwareentwicklung

### a. Warum ist sie so gut für Geschäftssysteme?

* **Schneller Nutzen:** Wichtige Funktionen kommen rasch zum Einsatz, was einen schnelleren Return on Investment
  ermöglicht
* **Anpassungsfähigkeit:** In der Geschäftswelt ändern sich Anforderungen ständig - inkrementelle Entwicklung passt sich
  diesen Änderungen viel leichter an
* **Frühes Feedback:** Nutzer können schon früh mit dem System arbeiten und wertvolles Feedback geben, bevor man zu weit
  in die falsche Richtung läuft
* **Risiken verteilen:** Statt alles auf eine Karte zu setzen, verteilt man Risiken clever auf kleinere Etappen
* **Smarte Priorisierung:** Man kann sich zuerst auf das konzentrieren, was wirklich wichtig ist

### b. Warum passt sie nicht so gut zu Echtzeitsystemen?

* **Verzahnte Komponenten:** Bei Echtzeitsystemen hängt alles eng zusammen - wie bei einem Uhrwerk. Da kann man nicht
  einfach ein Zahnrad nach dem anderen austauschen, ohne dass der Takt durcheinander gerät
* **Systemweite Anforderungen:** Dinge wie garantierte Reaktionszeiten oder Sicherheit betreffen das ganze System. Das
  ist, als müsste ein Haus schon bewohnbar sein, wenn erst das Fundament und ein Teil der Wände stehen
* **Aufwändige Integration:** Jede neue Komponente erfordert eine komplette Überprüfung des Zeitverhaltens - als würde
  man nach jedem neuen Möbelstück prüfen müssen, ob die Tür noch aufgeht
* **Tragfähige Basis nötig:** Echtzeitsysteme brauchen eine solide, durchdachte Architektur von Anfang an. Man kann
  nicht einfach mit einem Gerüst beginnen und hoffen, dass sich der Rest später von selbst ergibt

---

## 3. SE mit Wiederverwendung

* Anforderungsspezifikation
* Analyse der Komponenten

* **Notwendigkeit der Zweiteilung**
    * Identifikation von Komponenten beinflusst Anforderungsdefinition
    * Iteratives Anpassen der Komponenten je nach Anforderung
