var express = require('express');
var router = express.Router();

var db = require('monk')('localhost/pirates-demo');
var piratesCollection = db.get('pirates');

/* GET home page. */
router.get('/pirates', function(req, res, next) {
  piratesCollection.find({}, function (err, records) {
    res.render('pirates/index', { pirates: records });
  });
});

router.get('/pirates/new', function(req, res, next){
  res.render('pirates/new');
});

router.get('/pirates/:id/edit', function(req, res, next){
  piratesCollection.findOne({_id: req.params.id}, function(err, record) {
    res.render('pirates/edit',{pirate: record});
    });
});

router.get('pirates/:id', function (req,res,next) {
  piratesCollection.findOne({_id: req.params.id}, function (err, record) {
    res.render('pirates/show', {pirate: record});
  });
});

router.post('/pirates/new', function(req, res,next){
var name = req.body.name;
var poison = req.body.poison;
var accessory = req.body.accessory;
piratesCollection.insert ({ name: name, poison: poison, accessory: accessory
});
  res.redirect('/pirates');
});

router.post('/pirates/:id/update', function(req,res,next) {
  var name = req.body.name;
  var poison = req.body.poison;
  var accessory = req.body.accessory;
  piratesCollection.update ({_id: req.params.id},{ name: name, poison: poison, accessory: accessory
  });
  res.redirect('/pirates/' + req.params.id);
});

router.post('/pirates/:id/delete', function(req,res,next) {
  piratesCollection.remove({_id: req.params.id});
  res.redirect('/pirates/');
});

module.exports = router;
