var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('index', {title: 'Index Seite', name: 'Luca M. Schmidt'});
});

/* GET alt page. */
router.get('/alt', function (req, res, next) {
    res.render('alt', {title: 'Alt Seite', name: 'Luca M. Schmidt'});
});

// 1. Route mit URL-Parametern für Datum
router.get('/:year/:month/:day', function (req, res, next) {
    const year = req.params.year;
    const month = req.params.month;
    const day = req.params.day;
    res.send(`Datum empfangen: Jahr ${year}, Monat ${month}, Tag ${day}`);
});

// 2. Route mit Query-Parametern für Name
router.get('/names', function (req, res, next) {
    const name = req.query.name;
    res.send(`Name empfangen: ${name}`);
});

// 3. Route, die URL- und Query-Parameter kombiniert
router.get('/:year/:month/:day/details', function (req, res, next) {
    const year = req.params.year;
    const month = req.params.month;
    const day = req.params.day;
    const filter = req.query.filter;
    res.send(`Datum: ${year}-${month}-${day}, Filter: ${filter}`);
});

// 4. POST-Route
router.post('/submit-data', function (req, res, next) {
    const data = req.body;
    // Beispiel: Wenn { "message": "Hallo" } gesendet wird
    // const message = req.body.message;
    res.send(`Daten via POST empfangen: ${JSON.stringify(data)}`);
});

module.exports = router;
