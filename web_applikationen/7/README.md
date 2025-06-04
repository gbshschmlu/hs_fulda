# Übung 6

## Blog Datenstruktur

Für die Blog-Funktionalität wird ein Array von JavaScript-Objekten verwendet, um Blog-Beiträge im Speicher zu halten. Jedes Objekt repräsentiert einen einzelnen Blog-Beitrag und enthält die folgenden Eigenschaften:

*   `id`: Ein eindeutiger Identifikator für den Beitrag (String).
*   `jahr`: Das Jahr, in dem der Beitrag veröffentlicht wurde (String).
*   `monat`: Der Monat, in dem der Beitrag veröffentlicht wurde (String, z.B. "04" für April).
*   `tag`: Der Tag, an dem der Beitrag veröffentlicht wurde (String, z.B. "29").
*   `autor`: Der Name des Autors des Beitrags (String).
*   `titel`: Der Titel des Blog-Beitrags (String).
*   `text`: Der Hauptinhalt des Blog-Beitrags (String).

**Begründung für diese Wahl:**

*   **Einfachheit:** Ein Array von Objekten ist unkompliziert zu implementieren und zu verwalten für eine kleine Anwendung oder eine Übungsaufgabe.
*   **Flexibilität:** JavaScript-Objekte ermöglichen eine strukturierte Speicherung verschiedener Datentypen für jeden Beitrag.
*   **Benutzerfreundlichkeit:** Native JavaScript-Array-Methoden (wie `find`, `push`, `map`) können einfach zur Bearbeitung und Abfrage der Daten verwendet werden.
*   **JSON-Kompatibilität:** Diese Struktur ist inhärent kompatibel mit JSON, was es einfach macht, sie als API-Antworten zu senden.

Für eine Produktivanwendung würde typischerweise eine Datenbank (SQL oder NoSQL) für Persistenz, Skalierbarkeit und erweiterte Abfragemöglichkeiten verwendet werden. Für diese Übung ist ein In-Memory-Array jedoch ausreichend.
