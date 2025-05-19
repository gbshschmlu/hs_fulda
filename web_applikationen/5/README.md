# Übung 5

## Fragen:

### Aufgaben der Dateien:

- **bin/**: Server-Start (`www`), Port-Konfiguration, HTTP-Server-Initialisierung
- **routes/**: Router-Definitionen, API-Endpunkte, Controller-Logik
- **views/**: EJS-Templates, View-Komponente im MVC, HTML-Generierung
- **public/**: Statische Dateien (CSS, Browser-JS, Bilder)

### app.js:

- Express-App-Initialisierung
- View-Engine-Konfiguration
- Middleware-Einrichtung (Logger, Parser, etc.)
- Routen-Registrierung
- Fehlerbehandlung

### Route-Definition

```javascript
router.get('/', function (req, res, next) {
    res.render('index', {title: 'Express'});
});
```

- HTTP-Methode + Pfad
- Handler-Funktion mit req/res-Parametern
- Anfrageverarbeitung (meist View-Rendering)
