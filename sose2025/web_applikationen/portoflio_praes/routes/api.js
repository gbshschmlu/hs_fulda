const express = require('express');
const router = express.Router();
const fs = require('fs').promises;
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { 
    contentDirPath, 
    getSnippets, 
    getSnippetContent,
    saveSnippets 
} = require('../utils/snippetUtils');
const { PROGRAMMING_LANGUAGES } = require('../utils/constants');

// Hilfsfunktion zur Sprach validierung
const validateLanguage = (language) => {
    if (language === 'Other') return true;
    return PROGRAMMING_LANGUAGES.map(l => l.toLowerCase()).includes(language.toLowerCase());
};

// GET alle Snippets abrufen
router.get('/snippets', async (req, res, next) => {
    try {
        res.json(await getSnippets());
    } catch (error) {
        next(error);
    }
});

// POST ein neues Snippet erstellen
router.post('/snippets', async (req, res, next) => {
    try {
        const { name, tags, language, content } = req.body;
        
        // Pflichtfelder prüfen
        if (!name || !language || !content) {
            return res.status(400).json({ message: 'Missing required fields: name, language, content' });
        }

        // Sprache validieren
        if (!validateLanguage(language)) {
            return res.status(400).json({ 
                message: `Invalid language. Valid languages are: ${PROGRAMMING_LANGUAGES.join(', ')}`
            });
        }

        const snippets = await getSnippets();
        const newSnippet = {
            id: uuidv4(),
            name,
            tags: tags || [],
            language,
            lastModified: new Date().toISOString(),
        };

        snippets.push(newSnippet);
        await saveSnippets(snippets);

        // Inhalt in separater Datei speichern
        const contentFilePath = path.join(contentDirPath, `${newSnippet.id}.txt`);
        await fs.writeFile(contentFilePath, content, 'utf8');

        res.status(201).json(newSnippet);
    } catch (error) {
        next(error);
    }
});

// GET ein einzelnes Snippet mit Inhalt
router.get('/snippets/:id', async (req, res, next) => {
    try {
        const snippets = await getSnippets();
        const snippet = snippets.find(s => s.id === req.params.id);

        if (!snippet) {
            return res.status(404).json({ message: 'Snippet not found' });
        }

        try {
            const content = await getSnippetContent(snippet.id);
            res.json({ ...snippet, content });
        } catch (error) {
            res.status(404).json({ message: 'Snippet content not found, metadata exists.' });
        }
    } catch (error) {
        next(error);
    }
});

// PUT ein Snippet aktualisieren
router.put('/snippets/:id', async (req, res, next) => {
    try {
        const { name, tags, language, content } = req.body;
        const snippets = await getSnippets();
        const snippetIndex = snippets.findIndex(s => s.id === req.params.id);

        if (snippetIndex === -1) {
            return res.status(404).json({ message: 'Snippet not found' });
        }

        // Sprache validieren, falls angegeben
        if (language && !validateLanguage(language)) {
            return res.status(400).json({ 
                message: `Invalid language. Valid languages are: ${PROGRAMMING_LANGUAGES.join(', ')}`
            });
        }

        // Snippet aktualisieren
        const updatedSnippet = { ...snippets[snippetIndex] };
        if (name) updatedSnippet.name = name;
        if (tags) updatedSnippet.tags = tags;
        if (language) updatedSnippet.language = language;
        updatedSnippet.lastModified = new Date().toISOString();

        snippets[snippetIndex] = updatedSnippet;
        await saveSnippets(snippets);

        // Inhalt aktualisieren falls vorhanden
        if (content !== undefined) {
            const contentFilePath = path.join(contentDirPath, `${updatedSnippet.id}.txt`);
            await fs.writeFile(contentFilePath, content, 'utf8');
        }

        res.json(updatedSnippet);
    } catch (error) {
        next(error);
    }
});

// DELETE ein Snippet löschen
router.delete('/snippets/:id', async (req, res, next) => {
    try {
        let snippets = await getSnippets();
        const snippetIndex = snippets.findIndex(s => s.id === req.params.id);

        if (snippetIndex === -1) {
            return res.status(404).json({ message: 'Snippet not found' });
        }

        const deletedSnippetId = snippets[snippetIndex].id;
        snippets.splice(snippetIndex, 1);
        await saveSnippets(snippets);

        // Inhalts-Datei löschen
        try {
            await fs.unlink(path.join(contentDirPath, `${deletedSnippetId}.txt`));
        } catch (fileError) {
            console.error(`Failed to delete content file for ${deletedSnippetId}:`, fileError);
        }

        res.status(204).send();
    } catch (error) {
        next(error);
    }
});

module.exports = router;
