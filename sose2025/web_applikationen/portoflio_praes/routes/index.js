const express = require('express');
const router = express.Router();
const fs = require('fs').promises;
const path = require('path');

/* GET Startseite */
router.get('/', function(req, res) {
  res.render('index', { title: 'Snippeteer' });
});

// Get Über uns
router.get('/about', async (req, res) => {
  try {
    // Load references data
    const referencesPath = path.join(__dirname, '../data/references.json');
    const data = await fs.readFile(referencesPath, 'utf8');
    const references = JSON.parse(data);
    
    res.render('about', { 
      title: 'About Snippeteer',
      references 
    });
  } catch (err) {
    console.error('Fehler beim Laden der Referenzen:', err);
    res.status(500).render('error', {
      message: 'Error loading page data',
      error: { status: 500 }
    });
  }
});

// GET Erfahrungen
router.get('/experience', async (req, res) => {
  try {
    // Load references data
    const experiencesPath = path.join(__dirname, '../data/experiences.json');
    const data = await fs.readFile(experiencesPath, 'utf8');
    const experiences = JSON.parse(data);
    
    res.render('experience', { 
      title: 'Erfahrungen mit Snippeteer',
      experiences,
    });
  } catch (err) {
    console.error('Fehler beim Laden der Referenzen:', err);
    res.status(500).render('error', {
      message: 'Error loading page data',
      error: { status: 500 }
    });
  }
});


module.exports = router;
