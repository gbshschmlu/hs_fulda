const fs = require('fs');
const path = require('path');

class BlogController {
    constructor() {
        this.blogJsonPath = path.join(__dirname, '../model/blog.json');
    }

    // Hilfsfunktionen für JSON-Handhabung
    readBlogData() {
        try {
            if (!fs.existsSync(this.blogJsonPath)) return [];
            const data = fs.readFileSync(this.blogJsonPath, 'utf8');
            return data ? JSON.parse(data) : [];
        } catch (e) {
            return [];
        }
    }

    writeBlogData(data) {
        fs.writeFileSync(this.blogJsonPath, JSON.stringify(data, null, 2), 'utf8');
    }

    getNextId(blogEintraege) {
        if (blogEintraege.length === 0) return "1";
        return String(Math.max(...blogEintraege.map(e => Number(e.id) || 0)) + 1);
    }

    // GET /blog/ - Alle Blog-Einträge auflisten
    getAllPosts(req, res, _next) {
        const blogEintraege = this.readBlogData();

        // Konsolen-Ausgabe: ID und Titel aller Posts
        console.log('=== Alle gespeicherten Posts ===');
        blogEintraege.forEach(post => {
            console.log(`ID: ${post.id}, Titel: ${post.titel}`);
        });
        console.log('================================');

        res.json(blogEintraege);
    }

    // GET /blog/newpost - Formular zum Erstellen eines neuen Blog-Eintrags anzeigen
    showNewPostForm(req, res, _next) {
        res.render('newPost', {title: 'Neuer Blogeintrag'});
    }

    // POST /blog/ - Einen neuen Blog-Eintrag erstellen
    createPost(req, res, _next) {
        const {autor, titel, text} = req.body;
        if (!autor || !titel || !text) {
            return res.status(400).send("Fehlende Felder für den Blog-Eintrag");
        }

        const currentDate = new Date();
        const jahr = currentDate.getFullYear().toString();
        const monat = (currentDate.getMonth() + 1).toString();
        const tag = currentDate.getDate().toString();

        const blogEintraege = this.readBlogData();
        const neuerEintrag = {
            id: this.getNextId(blogEintraege),
            jahr,
            monat,
            tag,
            autor,
            titel,
            text,
            imagePath: req.file ? `/uploads/images/${req.file.filename}` : null
        };

        blogEintraege.push(neuerEintrag);
        this.writeBlogData(blogEintraege);

        console.log(`Neuer Post erstellt - ID: ${neuerEintrag.id}, Titel: ${neuerEintrag.titel}`);

        res.status(201).json(neuerEintrag);
    }

    // GET /blog/:id - Einen spezifischen Blog-Eintrag anhand der ID abrufen
    getPostById(req, res, _next) {
        const blogEintraege = this.readBlogData();
        const eintragId = req.params.id;
        const eintrag = blogEintraege.find(p => p.id === eintragId);

        if (eintrag) {
            console.log(`Post gefunden - ID: ${eintrag.id}, Titel: ${eintrag.titel}`);
            res.json(eintrag);
        } else {
            console.log('Kein Eintrag');
            res.status(404).send('Blog-Eintrag nicht gefunden');
        }
    }

    // PUT /blog/:id - Einen vorhandenen Blog-Eintrag aktualisieren
    updatePost(req, res, _next) {
        const blogEintraege = this.readBlogData();
        const eintragId = req.params.id;
        const eintragIndex = blogEintraege.findIndex(p => p.id === eintragId);

        if (eintragIndex === -1) {
            console.log(`Update fehlgeschlagen - Post mit ID ${eintragId} nicht gefunden`);
            return res.status(404).send('Blog-Eintrag nicht gefunden');
        }

        const {autor, titel, text} = req.body;
        if (!autor || !titel || !text) {
            return res.status(400).send("Fehlende Felder für den Blog-Eintrag");
        }

        // Vorhandenen Eintrag aktualisieren, aber ID, Datum und Bild beibehalten
        const aktualisiertEintrag = {
            ...blogEintraege[eintragIndex],
            autor,
            titel,
            text,
            // Neues Bild nur hinzufügen, wenn eines hochgeladen wurde
            imagePath: req.file ? `/uploads/images/${req.file.filename}` : blogEintraege[eintragIndex].imagePath
        };

        blogEintraege[eintragIndex] = aktualisiertEintrag;
        this.writeBlogData(blogEintraege);

        console.log(`Post aktualisiert - ID: ${aktualisiertEintrag.id}, Titel: ${aktualisiertEintrag.titel}`);

        res.json(aktualisiertEintrag);
    }

    // DELETE /blog/:id - Einen Blog-Eintrag löschen
    deletePost(req, res, _next) {
        const blogEintraege = this.readBlogData();
        const eintragId = req.params.id;
        const eintragIndex = blogEintraege.findIndex(p => p.id === eintragId);

        if (eintragIndex === -1) {
            console.log(`Löschung fehlgeschlagen - Post mit ID ${eintragId} nicht gefunden`);
            return res.status(404).send('Blog-Eintrag nicht gefunden');
        }

        const geloeschterEintrag = blogEintraege[eintragIndex];

        // Bild löschen, falls vorhanden
        if (geloeschterEintrag.imagePath) {
            const imagePath = path.join(__dirname, '../public', geloeschterEintrag.imagePath);
            if (fs.existsSync(imagePath)) {
                fs.unlinkSync(imagePath);
            }
        }

        // Eintrag aus Array entfernen
        blogEintraege.splice(eintragIndex, 1);
        this.writeBlogData(blogEintraege);

        console.log(`Post gelöscht - ID: ${geloeschterEintrag.id}, Titel: ${geloeschterEintrag.titel}`);

        res.json({message: 'Blog-Eintrag erfolgreich gelöscht', geloeschterEintrag});
    }
}

module.exports = new BlogController();
