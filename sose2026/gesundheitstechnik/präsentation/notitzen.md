# Sprechernotizen: Von der Produktion zur Diagnose

## Folie 1: Titelfolie

- **Begrüßung:** Herzlich willkommen! Name: Luca Michael Schmidt.
- **Hintergrund:** Dualer Student bei der Grenzebach BSH GmbH.
- **Thema:** Brücke schlagen zwischen zwei Welten – Industrielle Qualitätskontrolle und medizinische Radiologie.

## Folie 2: Agenda

- **Fahrplan:** 4 Hauptblöcke.
- Erst das Problem, dann die technische Basis (Wie macht die KI das?).
- Dann der direkte Transfer aus der Industrie-Praxis.
- Abschließend: Harte Evidenz und Messbarkeit auf drei Ebenen.

## Folie 3: Problemstellung (Catcher)

- **Bildvergleich:** Links Holzplatte (Industrie), rechts MRT (Medizin).
- **Kernaufgabe ist identisch:** Anomalie finden (Riss vs. Tumor).
- **Das Problem der Medizin:** Datenflut steigt jährlich. Radiologen völlig überlastet (Burnout-Raten bis 65%).
- **Fehlerquote:** Passieren oft bei massiver Überlastung (Schnitt 121%).
- **Lösung:** Industrie hat Skalierung/Automatisierung bereits gelöst – Medizin muss diesen Transfer jetzt nutzen.

## Folie 4: Technische Grundlagen (Neuronale Netze)

- **Technisches Herzstück:** Künstliche neuronale Netze.
- **Funktionsweise:** Input-Layer nimmt Daten auf (Pixel).
- Hidden Layers verarbeiten und verknüpfen Informationen.
- Output-Layer spuckt Wahrscheinlichkeit aus (Krank vs. Gesund).

## Folie 5: Convolutional Neural Network (CNN)

- **Spezialisierung:** CNNs sind speziell für Bilder gemacht.
- **Schichten-Prinzip (Feature Extraktion):**
    - Vorne (frühe Layer): Erkennen nur dumme Kontraste und Kanten.
    - Mitte: Setzen Kanten zu geometrischen Texturen zusammen.
    - Hinten (tiefe Layer): Verstehen komplexe, krankhafte Muster.
- **Vorteil:** KI lernt Merkmale selbst, wir müssen sie nicht manuell programmieren.

## Folie 6: Transfer Learning & Fine-Tuning

- **Problem in Medizin:** Akuter Datenmangel (DSGVO). CNN braucht eigentlich Millionen Bilder.
- **Lösung (Transfer Learning):**
    - _Pre-Training:_ KI lernt Basis-Schichten (Kanten/Formen) an harmlosen Standardbildern.
    - _Fine-Tuning:_ Nur letzte Schicht wird mit echten Röntgenbildern überschrieben/spezialisiert.
- Spart enorm Daten und Rechenzeit.

## Folie 7: Methodischer Transfer (Trenner)

- _Kurze Überleitung:_ Wie sieht das nun in der Praxis aus?

## Folie 8: Transfer zwischen ROSI & Medizin

- **1:1 Gegenüberstellung:**
- _Input:_ Industriekamera vs. MRT-Scan.
- _Klassen:_ Holzeinschlüsse/Risse vs. Tumore/Frakturen.
- _Output:_ Defekttyp vs. klinischer Befund.
- **Erkenntnis:** System und Architektur bleiben gleich, nur der Anwendungsbereich ändert sich. KI ist ermüdungsfrei!

## Folie 9: Messbarkeit & Evidenz (Trenner)

- _Kurze Überleitung:_ Behaupten kann man viel – wir müssen den Erfolg nun in Zahlen messen. (Aufgeteilt in 3 Ebenen).

## Folie 10: Ebene 1 - Modell Genauigkeit

- **Fokus:** Wie gut ist der Algorithmus isoliert betrachtet?
- **Metrik:** F1-Score (Perfekte Balance aus Treffern und Fehlalarmen).
- **Benchmark:** Stanford-Studie "CheXNet" (Lungenentzündungen).
- **Ergebnis:** KI ($F_1$ = 0,435) schlägt den Schnitt der Fachärzte ($F_1$ = 0,387) signifikant. Algorithmus ist bereit!

## Folie 11: Ebene 2 - Klinische Effizienz

- **Fokus:** Was bringt es im Klinik-Alltag?
- **Konzept:** KI ersetzt Arzt nicht! Sie agiert als "Zweiter Leser" (markiert Auffälligkeiten).
- **Evidenz (Brustkrebsscreening):**
    - Sensitivität steigt (+12% mehr Tumore gefunden).
    - Zeitaufwand für den Arzt sinkt enorm (-44%).
- **Fazit hier:** Direkte Burnout-Prävention durch Arbeitserleichterung.

## Folie 12: Ebene 3 - IT-Souveränität

- **Fokus:** Die Infrastruktur. (Der Elefant im Raum).
- **Risiko:** Röntgenbilder = Hochsensibel (Art. 9 DSGVO). US-Clouds (AWS/Azure) sind wegen US CLOUD Act rechtlich oft unvereinbar.
- **Lösung 1:** On-Premise (Eigener Server im Krankenhauskeller). Wichtig hier: Geringe Inferenz-Latenz für Echtzeit-Ergebnisse.
- **Lösung 2:** Federated Learning. KI wandert zum Krankenhaus, lernt dort. Nur anonyme Updates verlassen die Klinik, niemals Patientendaten.

## Folie 13: Fazit & Ausblick (Trenner)

- _Kurze Überleitung zum Abschluss der Präsentation._

## Folie 14: Fazit / Take-Aways

- **3 Kernaussagen:**
-   1. Methodik (CNNs) lässt sich absolut valide aus der Industrie transferieren.
-   2. Nutzen (Sensitivität hoch, Zeitaufwand runter) ist hart messbar.
-   3. Die Hürde ist nicht die KI an sich, sondern der datenschutzkonforme Serverbetrieb.

## Folie 15: Ausblick

- **Rechtlich:** EU AI Act bringt dieses Jahr (August) endlich feste Zertifizierungs-Standards für Hochrisiko-KIs.
- **Technisch:** Multimodale Modelle kommen. KI schaut nicht nur das Bild an, sondern liest gleichzeitig Patientenakte und Laborwerte.

## Folie 16: Literaturverzeichnis & Kontakt

- Hier der QR-Code zum neuen Git-Repository.
- Beinhaltet Fachartikel (PDF) und alle Quellenangaben zur Prüfung.
- Vielen Dank für die Aufmerksamkeit!

## Folie 17: Danke

- Stehe nun gerne für Fragen und Diskussionen zur Verfügung.
