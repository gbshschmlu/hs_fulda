var express = require('express');
var router = express.Router();
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const blogController = require('../controller/blog');

// Multer für Dateispeicherung konfigurieren
const uploadDir = path.join(__dirname, '../public/uploads/images');

// Sicherstellen, dass das Upload-Verzeichnis existiert
if (!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

/* GET /blog/ - Alle Blog-Einträge auflisten */
router.get('/', blogController.getAllPosts.bind(blogController));

/* GET /blog/newpost - Formular zum Erstellen eines neuen Blog-Eintrags anzeigen */
router.get('/newpost', blogController.showNewPostForm.bind(blogController));

/* POST /blog/ - Einen neuen Blog-Eintrag erstellen (mit Datei-Upload) */
router.post('/', upload.single('blogimage'), blogController.createPost.bind(blogController));

/* GET /blog/:id - Einen spezifischen Blog-Eintrag anhand der ID abrufen */
router.get('/:id', blogController.getPostById.bind(blogController));

/* PUT /blog/:id - Einen vorhandenen Blog-Eintrag aktualisieren (mit Datei-Upload) */
router.put('/:id', upload.single('blogimage'), blogController.updatePost.bind(blogController));

/* DELETE /blog/:id - Einen Blog-Eintrag löschen */
router.delete('/:id', blogController.deletePost.bind(blogController));

module.exports = router;
