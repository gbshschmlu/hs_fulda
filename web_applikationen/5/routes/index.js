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

module.exports = router;
