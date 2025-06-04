var express = require('express');
var router = express.Router();
const fs = require('fs');
const path = require('path');

// Hilfsfunktionen für JSON-Handling
const blogJsonPath = path.join(__dirname, '../model/blog.json');

function readBlogData() {
    try {
        if (!fs.existsSync(blogJsonPath)) return [];
        const data = fs.readFileSync(blogJsonPath, 'utf8');
        return data ? JSON.parse(data) : [];
    } catch (e) {
        return [];
    }
}

function writeBlogData(data) {
    fs.writeFileSync(blogJsonPath, JSON.stringify(data, null, 2), 'utf8');
}

function getNextId(blogEintraege) {
    if (blogEintraege.length === 0) return "1";
    return String(Math.max(...blogEintraege.map(e => Number(e.id) || 0)) + 1);
}

/* GET /blog/ - Alle Blog-Einträge auflisten */
router.get('/', function (req, res, next) {
    const blogEintraege = readBlogData();
    res.json(blogEintraege);
});

/* GET /blog/newpost - Formular anzeigen */
router.get('/newpost', function (req, res, next) {
    res.render('newPost', {title: 'Neuer Blogeintrag'});
});

/* POST /blog/ - Einen neuen Blog-Eintrag erstellen (ohne Fileupload) */
router.post('/', function (req, res, next) {
    const {jahr, monat, tag, autor, titel, text} = req.body;
    if (!jahr || !monat || !tag || !autor || !titel || !text) {
        return res.status(400).send("Fehlende Felder für den Blog-Eintrag");
    }
    const blogEintraege = readBlogData();
    const neuerEintrag = {
        id: getNextId(blogEintraege),
        jahr,
        monat,
        tag,
        autor,
        titel,
        text,
    };
    blogEintraege.push(neuerEintrag);
    writeBlogData(blogEintraege);
    if (req.headers['content-type'] && req.headers['content-type'].includes('application/json')) {
        res.status(201).json(neuerEintrag);
    } else {
        res.redirect('/blog/');
    }
});

/* GET /blog/:id - Einen spezifischen Blog-Eintrag anhand der ID abrufen */
router.get('/:id', function (req, res, next) {
    const blogEintraege = readBlogData();
    const eintragId = req.params.id;
    const eintrag = blogEintraege.find(p => p.id === eintragId);
    if (eintrag) {
        res.json(eintrag);
    } else {
        res.status(404).send('Blog-Eintrag nicht gefunden');
    }
});

module.exports = router;
