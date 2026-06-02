# Übersicht: Evaluierungsmetriken nach dem 3-Ebenen-Modell

## 🔵 Säule 1: Modell-Genauigkeit (Algorithmische Basisleistung)

_Hier geht es rein um die Frage: Rechnet die KI richtig und erkennt sie die Befunde?_

- **KI-Bildanalyse in Industrie & Medizin (ROSI):** F1-Score (Trefferquote vs. Übersehen-Rate)
- **KI-Auswertung (Röntgen/CT/MRT):** Sensitivität, Spezifität, AUC-ROC
- **KI-Endoskopie:** Live-Bild Analyse der KI, Adenomdetektionsrate (Krebsvorstufen)
- **Sprachmodelle (LLM):** MedGPTEval-Benchmark, Fehlerraten-Messung
- **Chatbots:** MedGPTEval-Benchmark

---

## 🟠 Säule 2: Klinische Ebene (Workflow & Prozessqualität)

_Hier geht es um die Auswirkungen auf den Klinikalltag, das Personal und den Patienten._

- **KI-Bildanalyse in Industrie & Medizin (ROSI):** Sensitivitätssteigerung (+12%), Befundungszeit-Reduktion (-44%) als "Zweiter Leser"
- **Pflege-Roboter:** Arbeitszeitentlastung, körperliche Entlastung (Hebevorgänge), Patientenzufriedenheit
- **Wearables & Apps:** PPG/SpO2 & EKG, Akzelerometer & Temperatur, EQ-5D (Lebensqualität)
- **Erinnerungssysteme:** Adhärenzrate, Pünktlichkeit, erfasste vergessene Dosen
- **KI-Endoskopie:** Zäkumintubationsrate (CIR), Rückzugszeit, Vorbereitungsqualität
- **Sprachmodelle (LLM):** Klinische Validierungsstudien (verblindet durch Fachpersonal)

---

## 🟣 Säule 3: IT & Infrastruktur (Technische Umsetzung)

_Hier geht es um die System-Performance, Latenzen und Sicherheit im Netzwerk._

- **KI-Bildanalyse in Industrie & Medizin (ROSI):** Inferenz-Latenz (Echtzeittauglichkeit), lokaler Datenverbleib (DSGVO Art. 9)
- **Chatbots:** RAGAS (Retrieval Augmented Generation Assessment)
- **Sprachmodelle (LLM):** Technology Acceptance Model (TAM - Akzeptanz der Infrastruktur)
