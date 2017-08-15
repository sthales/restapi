var express = require('express');
var app = express();
var appsEducacionais = express.Router();
appsEducacionais.get('/', function(req, res) { });
appsEducacionais.post('/', function(req, res) { });
appsEducacionais.get('/:id', function(req, res) { });
appsEducacionais.patch('/:id', function(req, res) { });
appsEducacionais.delete('/:id', function(req, res) { });

app.use('/aplicativos-educacionais', appsEducacionais);

var recursosEducacionais = express.Router();
recursosEducacionais.get('/', function(req, res) { });
recursosEducacionais.post('/', function(req, res) { });
recursosEducacionais.get('/:id', function(req, res) { });
recursosEducacionais.patch('/:id', function(req, res) { });
recursosEducacionais.delete('/:id', function(req, res) { });

app.use('/recursos-educacionais', recursosEducacionais);

module.exports = app;