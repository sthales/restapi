/** imports */
const express = require('express');
const app = express();
const cors = require('cors');
const path = require('path'); 
const fs = require('fs');

var port = process.env.port || 3500;
var apiRouter = express.Router();
/** model */
const db = require('./postgres');
db.connect();
//app.use('/static', express.static(__dirname + '/public'));
app.use(express.static('public'));
//app.use(express.static(path.join(__dirname, 'files')));
app.use(cors()); //Controle de Acesso HTTP (CORS) para todas as rotas
/** rotas */
app.use('/api',apiRouter);

apiRouter.route('/aplicativos').get(function(req,res,next){
    var limit = req.query.limit || 2;
    
    db.getAplicativos(limit,(err,apps) => {
        if(err){
            return next(err);
        }else{
            res.json(apps);
        }
    });
});
app.get('/streaming',(req,res)=>{
    console.log('requisição da url: ' + req.url);
    //res.writeHead(200,{'Content-Type':'application/json'});
    const arq = '/files/06.mp4'
    const stat = fs.statSync(file)
    const fileSize = stat.size
    const range = req.headers.range
    if (range) {
      const parts = range.replace(/bytes=/, "").split("-")
      const start = parseInt(parts[0], 10)
      const end = parts[1] 
        ? parseInt(parts[1], 10)
        : fileSize-1
      const chunksize = (end-start)+1
      const file = fs.createReadStream(arq, {start, end})
      const head = {
        'Content-Range': `bytes ${start}-${end}/${fileSize}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunksize,
        'Content-Type': 'video/mp4',
      }
      res.writeHead(206, head);
      file.pipe(res);
    } else {
      const head = {
        'Content-Length': fileSize,
        'Content-Type': 'video/mp4',
      }
      res.writeHead(200, head)
      fs.createReadStream(arq).pipe(res)
    }
});
//app.get('/video',(req,res)=>{
//    var head = {'Content-Type': 'text/html'}; 
//    res.writeHead(head);
//    res.sendFile('index.html');
//});    
app.use((error,req,res,next) => {
    res.status(500).send(error);    
});
/** inicio */
app.get('/',function(req,res){
    res.send('Bemvindo a nosso API');
});
/** no encontrado */
app.get('*', function(req, res){
  res.status(401).send('humm???');
});
app.listen(port,function(){
    console.log('Servidor iniciado na porta ' + port);
    console.log('\x1b[33m%s\x1b[0m',"http://localhost:" + port)
});



module.exports = app;