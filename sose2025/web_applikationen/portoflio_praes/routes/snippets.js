const express = require('express');
const router = express.Router();
const { getSnippets, getSnippetContent } = require('../utils/snippetUtils');
const { PROGRAMMING_LANGUAGES } = require('../utils/constants');

// Neue Snippets erstellen - Formularanzeige
router.get('/new', (req, res) => {
    res.render('snippets/new', {
        title: 'Create New Snippet',
        languages: PROGRAMMING_LANGUAGES
    });
});

// Alle Snippets anzeigen mit Suchfilter
router.get('/', async (req, res, next) => {
    try {
        const snippets = await getSnippets();
        
        // Einzigartige Tags für Filter extrahieren
        const tags = [...new Set(snippets.flatMap(s => s.tags))];
        
        res.render('snippets/index', { 
            title: 'Code Snippets',
            snippets,
            languages: PROGRAMMING_LANGUAGES,
            tags
        });
    } catch (error) {
        next(error);
    }
});

// Detailansicht eines Snippets
router.get('/:id', async (req, res, next) => {
    try {
        const snippets = await getSnippets();
        const snippet = snippets.find(s => s.id === req.params.id);
        
        if (!snippet) {
            return res.status(404).render('error', { 
                message: 'Snippet not found', 
                error: { status: 404 } 
            });
        }
        
        // Snippet-Inhalt laden und mit Metadaten kombinieren
        const content = await getSnippetContent(snippet.id);
        const tags = [...new Set(snippets.flatMap(s => s.tags))];
        
        res.render('snippets/detail', {
            title: snippet.name,
            snippet: { ...snippet, content },
            languages: PROGRAMMING_LANGUAGES,
            tags
        });
    } catch (error) {
        next(error);
    }
});

module.exports = router;
