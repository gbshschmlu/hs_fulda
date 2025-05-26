var express = require('express');
var router = express.Router();

// Datenstruktur: (Memory) Array von Objekten.
// Warum: Einfach zu implementieren für diese Übung, ermöglicht das Speichern mehrerer Einträge mit strukturierten Daten.
// Jedes Objekt repräsentiert einen Blog-Eintrag mit definierten Eigenschaften.
// Nachteil: Nicht persistent, d.h. Daten gehen bei Neustart des Servers verloren.
let blogEintraege = [
    { id: "1", jahr: "2024", monat: "01", tag: "15", autor: "Max Mustermann", titel: "Mein erster Beitrag", text: "Das ist der Inhalt meines ersten Blog-Beitrags." },
    { id: "2", jahr: "2024", monat: "02", tag: "10", autor: "Erika Mustermann", titel: "Express Grundlagen", text: "Lernen über Express.js Routing." }
];
let naechsteEintragId = 3; // Um eine automatisch inkrementierende ID für neue Beiträge zu simulieren

/* GET /blog/ - Alle Blog-Einträge auflisten */
router.get('/', function(req, res, next) {
  res.json(blogEintraege);
});

/* POST /blog/ - Einen neuen Blog-Eintrag erstellen */
router.post('/', function(req, res, next) {
  const { jahr, monat, tag, autor, titel, text } = req.body;
  if (!jahr || !monat || !tag || !autor || !titel || !text) {
    return res.status(400).send("Fehlende Felder für den Blog-Eintrag");
  }
  const neuerEintrag = {
    id: String(naechsteEintragId++),
    jahr,
    monat,
    tag,
    autor,
    titel,
    text
  };
  blogEintraege.push(neuerEintrag);
  res.status(201).json(neuerEintrag);
});

/* GET /blog/:id - Einen spezifischen Blog-Eintrag anhand der ID abrufen */
router.get('/:id', function(req, res, next) {
  const eintragId = req.params.id;
  const eintrag = blogEintraege.find(p => p.id === eintragId);
  if (eintrag) {
    res.json(eintrag);
  } else {
    res.status(404).send('Blog-Eintrag nicht gefunden');
  }
});

module.exports = router;
