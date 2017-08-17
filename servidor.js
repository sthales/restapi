/** imports */
var express = require('express');
var app = express();
var cors = require('cors');


var port = process.env.port || 3500;
var apiRouter = express.Router();
/** model */
const db = require('./postgres');
db.connect();

// app.use(cors()); Controle de Acesso HTTP (CORS) para todas as rotas
/** rotas */
app.use('/api',apiRouter);

apiRouter.route('/aplicativos')
    .get(cors(),function(req,res,next){
        //res.set({"Content-Type": "application/json; charset=utf-8"});
        db.getAplicativos((err,apps) => {
            if(err){
                return next(err);
            }else{
                res.json(apps);
            }
        });
    });

app.use((error,req,res,next) => {
    res.send(error);
});
/** inicio */
app.get('/',function(req,res){
    res.send('Bemvindo a nosso API');
});
/** no encontrado */
app.get('*', function(req, res){
  res.send('humm???', 404);
});
app.listen(port,function(){
    console.log('Servidor iniciado na porta ' + port);
    console.log('\x1b[33m%s\x1b[0m',"http://localhost:" + port)
});



module.exports = app;