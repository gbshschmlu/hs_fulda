# Snippeteer PowerPoint-Folien (8-10 Min.)

## Folientypen-Kategorisierung

**CONTENT-FOLIEN** = Text, Bullet Points, Konzepte  
**DEMO-FOLIEN** = Screenshots, Live-Demo, Visuals

---

## Folienstruktur mit Inhalten
<!-->hier keine stichpunkte?
</!-->
### Folie 1: Titelfolie **CONTENT**
```
SNIPPETEER
Code-Snippet-Manager

• Zentrale Verwaltung von Code-Snippets
• Web-Interface + RESTful API
• Tag-basierte Organisation

Team: Luca M. Schmidt, Nicolai Sauer, Sam Stankiewicz, Jonas Zitzmann
Praxismodul Webentwicklung
```

---

### Folie 2: Problemstellung **CONTENT**
```
DAS PROBLEM

Entwickler-Alltag:
• Code-Snippets überall verstreut (IDE, Notizen, E-Mails)
• Keine zentrale Suchfunktion
• Schwierige Wiederverwendung
• Fehlende Team-Kollaboration
• Keine Kategorisierung

Konsequenz:
• Doppelte Arbeit
• Ineffiziente Workflows  
• Verlust bewährter Code-Patterns
```

---
<!--> würde ich weg machen,da es schon oben besprochen würde und ersetzten mit Zieldefinition
- Schnelle Speicherung und Abrufbarkeit
- kategorisierung und Tags
- sowohl im Darkmode und Brightmode anschprechendes Design
- Sytax-Highlighting
</!-->
### Folie 3: Zielgruppen **CONTENT**
```
UNSERE ZIELGRUPPEN

ENTWICKLER & TEAMS
• Individuelle Entwickler mit wiederkehrenden Code-Patterns
• Programmier-Teams für Code-Sharing
• Freelancer mit Client-spezifischen Bibliotheken

STUDENTEN & LERNENDE  
• Coding-Bootcamp-Teilnehmer
• Informatik-Studenten
• Autodidakten

USER STORIES:
"Als Entwickler möchte ich meine Snippets zentral verwalten"
"Als Team-Lead möchte ich bewährte Patterns teilen"  
"Als Student möchte ich Lernfortschritte dokumentieren"
```

---
<!-->Hier kurz auf Design und Farbkonzept eingehen?
- brightmode und Darkmode 
- Übersichtliches, einfaches Design 
- responsive
- barrierefrei
</!-->
### Folie 4: Lösungskonzept **CONTENT**
```
UNSER LÖSUNGSANSATZ

WEB-INTERFACE
• Benutzerfreundliche grafische Oberfläche
• Syntax-Highlighting für alle Sprachen
• Intuitive Navigation & Suche

RESTful API  
• Programmatischer Zugriff
• IDE-Integration möglich
• Vollständige CRUD-Operationen

ORGANISATION
• Tag-System für Kategorisierung
• Sprachfilterung  
• Erweiterte Suchfunktion
```

---
<!-->Hier am besten nur Live Demo?
</!-->
### Folie 5: Design-Prinzipien **DEMO**
```
DESIGN-PHILOSOPHIE

[Screenshots der Hauptseite nebeneinander: Desktop + Mobile]

DEVELOPER-FIRST DESIGN:
• Dunkles Theme (augenschonend)
• Monospace-Fonts (FiraCode) für Code
• Minimalistisches Interface
• Atom One Dark Design (bbekanntes IDE Them)

USABILITY:
• Klare Hierarchien
• Keyboard-Navigation  
• Responsive Design
• Konsistente URL-Struktur
```

---

### Folie 6: Tech Stack **CONTENT**
```
TECHNOLOGIE-STACK

BACKEND:
Node.js + Express.js
• Event-driven Architektur
• Große npm-Community
• Ideal für RESTful APIs

FRONTEND:
EJS Templates + HTML5/CSS3
• Server-side Rendering
• Semantisches Markup
• Modern CSS (Grid, Flexbox)

DATA:
Dateibasiertes System (JSON + UUID)
• Einfache Datenhaltung
• UUID für eindeutige IDs
• Backup-freundlich
```

---
<!--> Würde ich aus zeitgründen weglassen
</!-->
### Folie 7: API-Architektur **CONTENT**
```
RESTful API-DESIGN

ENDPOINTS:
GET    /api/snippets           → Alle Snippets
POST   /api/snippets           → Neues Snippet
GET    /api/snippets/:id       → Einzelnes Snippet  
PUT    /api/snippets/:id       → Snippet bearbeiten
DELETE /api/snippets/:id       → Snippet löschen

DATENSTRUKTUR:
{
  "id": "uuid-string",
  "name": "DOM Event Listener", 
  "language": "javascript",
  "content": "const btn = document.querySelector...",
  "tags": ["frontend", "dom", "events"],
  "createdAt": "2025-05-24T10:30:00Z"
}
```

---

### Folie 8: Live-Demo Übersicht **DEMO**
```
LIVE-DEMONSTRATION

WAS WIR ZEIGEN:

1. Startseite & Navigation
2. Snippet-Liste & Suche  
3. Neues Snippet erstellen (mit Syntax-Highlighting)
4. Tags & Filterung
5. API-Call live im Browser

DEMO-SZENARIO:
"JavaScript DOM-Manipulation Snippet erstellen und wiederfinden"

[Hier während Demo: Live-Bildschirm]
```

---

### Folie 9: Features im Detail **DEMO**
```
KEY FEATURES

[4 Screenshots in Grid-Layout:]

SNIPPET ERSTELLEN
[Screenshot: /snippets/new Formular]

SUCHE & FILTER  
[Screenshot: Snippet-Liste mit Tags]

SYNTAX-HIGHLIGHTING
[Screenshot: Code mit Farb-Highlighting]

API-ZUGRIFF
[Screenshot: JSON-Response im Browser]
```

---

### Folie 10: Responsive Design **DEMO**
```
RESPONSIVE DESIGN

[Drei Screenshots nebeneinander: Desktop, Tablet, Mobile]

MOBILE (< 768px):
• Kollabierbare Navigation
• Touch-optimierte Buttons
• Vertikale Code-Darstellung

DESKTOP (> 1200px):  
• Sidebar-Navigation
• Multi-Column-Layout
• Keyboard-Shortcuts

ÜBERALL:
• Gleiche Funktionalität
• Optimierte UX pro Gerät
```

---

### Folie 11: Code-Qualität **CONTENT**
```
TECHNISCHE HIGHLIGHTS

HTML5:
• Semantische Tags (article, section, nav)
• Accessibility-optimiert
• SEO-freundliche Struktur

CSS3:
• Modern CSS (Grid, Flexbox)
• CSS Custom Properties  
• Mobile-First Responsive Design

JAVASCRIPT:
• Vanilla JS (keine Framework-Dependencies)
• Progressive Enhancement
• Clean Code-Prinzipien

API:
• RESTful Standards
• JSON-basiert
• Error-Handling
```

---

### Folie 12: Fazit & Ausblick **CONTENT**
```
ZUSAMMENFASSUNG

ERREICHT:
• Vollständig funktionsfähiger Code-Snippet-Manager
• Moderne Web-Technologien (Node.js, Express, EJS)
• Web-Interface + RESTful API
• Developer-friendly Design
• Responsive & Accessible

MÖGLICHE ERWEITERUNGEN:
• User-Authentifizierung & private Snippets
• Kollaborations-Features für Teams
• GitHub/GitLab-Integration
• Syntax-Highlighting für mehr Sprachen
• Cloud-Deployment

VIELEN DANK FÜR EURE AUFMERKSAMKEIT!
Fragen?
```

---

## Folientyp-Übersicht

### CONTENT-FOLIEN (7 Folien)
- **Zweck:** Information vermitteln, Konzepte erklären
- **Design:** Viel Text, Bullet Points, klare Struktur
- **Inhalt:** Problemstellung, Zielgruppen, Tech Stack, API, etc.

**Folien:** 1, 2, 3, 4, 6, 7, 11, 12

### DEMO-FOLIEN (5 Folien)  
- **Zweck:** Visuelle Demonstration, Screenshots zeigen
- **Design:** Wenig Text, große Bilder/Screenshots
- **Inhalt:** Design-Beispiele, Live-Demo, Features, Responsive

**Folien:** 5, 8, 9, 10 + Live-Demo-Zeit

---

## Design-Empfehlungen nach Folientyp

### CONTENT-FOLIEN
```
LAYOUT:
• Große, lesbare Schrift (min. 24pt)
• Max. 6-7 Bullet Points pro Folie
• Konsistente Icons/Symbole
• Viel Whitespace

FARBEN:
• Dunkler Hintergrund (Developer-Theme)
• Helle Schrift (#FFFFFF, #F8F8F2)
• Akzentfarben für wichtige Punkte
• Monospace-Font für Code
```

### DEMO-FOLIEN  
```
LAYOUT:
• Große Screenshots (min. 50% der Folie)
• Wenig erklärenden Text
• Pfeile/Markierungen für wichtige Bereiche
• Grid-Layout für multiple Screenshots

SCREENSHOTS:
• Hohe Auflösung (min. 1920x1080)
• Konsistente Browser-Darstellung
• Realistische Daten (keine Lorem Ipsum)
• Verschiedene Geräteformate zeigen
```

---

## Rollen-Zuordnung zu Folien

### Luca (Folien 1-3) - 2 Min.
- Folie 1: Titelfolie **CONTENT**
- Folie 2: Problemstellung **CONTENT**  
- Folie 3: Zielgruppen **CONTENT**

### Nicolai (Folien 4-5) - 2 Min.
- Folie 4: Lösungskonzept **CONTENT**
- Folie 5: Design-Prinzipien **DEMO**

### Sam (Folien 6-7) - 1,5 Min.  
- Folie 6: Tech Stack **CONTENT**
- Folie 7: API-Architektur **CONTENT**

### Jonas (Folien 8-12) - 4,5 Min.
- Folie 8: Demo-Übersicht **DEMO**
- **LIVE-DEMO** (2,5 Min.)
- Folie 9: Features **DEMO**  
- Folie 10: Responsive **DEMO**
- Folie 11: Code-Qualität **CONTENT**
- Folie 12: Fazit **CONTENT**

---

## Screenshot-Checkliste für DEMO-FOLIEN

### Benötigte Screenshots:

**Folie 5 - Design:**
- [ ] Desktop: Hauptseite (http://localhost:3000)
- [ ] Mobile: Hauptseite (responsive)

**Folie 9 - Features (4 Screenshots):**
- [ ] `/snippets/new` - Formular zum Erstellen
- [ ] `/snippets` - Liste mit Tag-Filtern  
- [ ] Einzelner Snippet mit Syntax-Highlighting
- [ ] Browser mit `/api/snippets` JSON-Response

**Folie 10 - Responsive (3 Screenshots):**
- [ ] Desktop-View (1920px+)
- [ ] Tablet-View (768-1024px)
- [ ] Mobile-View (<768px)

### Screenshot-Tipps:
- **Konsistente Daten:** Gleiche Snippets in allen Screenshots
- **Realistische Inhalte:** Echte Code-Snippets, keine Platzhalter
- **Browser-UI:** Chrome/Firefox, saubere Adressleiste
- **Hohe Auflösung:** Min. 1920x1080 für Schärfe am Beamer
