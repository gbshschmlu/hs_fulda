const fs = require('fs').promises;
const path = require('path');

// Dateipfade für Snippets und deren Inhalte
const snippetsFilePath = path.join(__dirname, '..', 'data', 'snippets.json');
const contentDirPath = path.join(__dirname, '..', 'data', 'content');

/**
 * Lädt alle Snippet-Metadaten aus der JSON-Datei
 * Gibt ein leeres Array zurück, wenn die Datei nicht existiert
 */
async function getSnippets() {
    try {
        const data = await fs.readFile(snippetsFilePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        if (error.code === 'ENOENT') {
            return [];
        }
        throw error;
    }
}

/**
 * Lädt den Inhalt eines einzelnen Snippets
 * @param {string} id - Die ID des Snippets
 */
async function getSnippetContent(id) {
    try {
        const contentFilePath = path.join(contentDirPath, `${id}.txt`);
        return await fs.readFile(contentFilePath, 'utf8');
    } catch (error) {
        if (error.code === 'ENOENT') {
            return '';
        }
        throw error;
    }
}

/**
 * Speichert die Snippet-Metadaten in der JSON-Datei
 * @param {Array} snippets - Array mit allen Snippet-Objekten
 */
async function saveSnippets(snippets) {
    await fs.writeFile(snippetsFilePath, JSON.stringify(snippets, null, 2), 'utf8');
}

module.exports = {
    snippetsFilePath,
    contentDirPath,
    getSnippets,
    getSnippetContent,
    saveSnippets
};
