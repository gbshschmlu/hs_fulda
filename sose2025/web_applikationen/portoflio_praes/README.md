# Snippeteer - Code-Snippet-Manager

Eine Webanwendung zum effizienten Verwalten, Suchen und Teilen von Code-Snippets.

## Teilnehmer

* Luca M. Schmidt
* Nicolai Sauer
* Sam Stankiewicz
* Jonas Zitzmann

## Projektbeschreibung

Snippeteer ist ein umfassendes Code-Snippet-Verwaltungssystem, das es Entwicklern ermöglicht, wiederverwendbare
Code-Snippets zu erstellen, zu speichern, zu durchsuchen und zu teilen. Die Anwendung bietet sowohl eine
benutzerfreundliche Weboberfläche als auch eine RESTful-API für programmatischen Zugriff.

## Funktionen

- Erstellen und Speichern von Code-Snippets mit Syntaxhervorhebung
- Organisation von Snippets mit Tags und Sprachkategorisierung
- Suchen und Filtern von Snippets nach Namen, Tags und Sprache
- Anzeige detaillierter Informationen zu einzelnen Snippets
- Bearbeiten und Löschen bestehender Snippets
- RESTful-API für programmatischen Zugriff auf Snippets

## Referenzen

Die Referenzen zu diesem Projekt sind in der JSON-Datei [`references.json`](./data/references.json) im
Projektverzeichnis zu finden. 
Diese Datei enthält Informationen zu den verwendeten Technologien, Bibliotheken und
Ressourcen, die während der Entwicklung verwendet wurden.

## Verwendete Technologien

- Node.js und Express.js für den Server
- EJS für Templates
- RESTful-API-Architektur
- UUID für eindeutige Kennung
- Dateibasiertes Speichersystem

## Setup und Installation

1. Repository klonen
2. Abhängigkeiten installieren:
   ```
   npm install
   ```
3. Anwendung starten:
   ```
   npm run dev
   ```
4. Zugriff auf die Anwendung im Browser unter http://localhost:3000

## API-Dokumentation

Die Anwendung bietet eine RESTful-API zur Verwaltung von Snippets:

### Alle Snippets abrufen

```
GET /api/snippets
```

### Neues Snippet erstellen

```
POST /api/snippets
Body: { "name": "string", "language": "string", "content": "string", "tags": ["string"] }
```

### Bestimmtes Snippet abrufen

```
GET /api/snippets/:id
```

### Snippet aktualisieren

```
PUT /api/snippets/:id
Body: { "name": "string", "language": "string", "content": "string", "tags": ["string"] }
```

### Snippet löschen

```
DELETE /api/snippets/:id
```

## Web-Routen

- Startseite: `/`
- Snippets-Liste: `/snippets`
- Neues Snippet erstellen: `/snippets/new`
- Snippet anzeigen/bearbeiten: `/snippets/:id`
- Über uns: `/about`
- Referenzen: `/references`
