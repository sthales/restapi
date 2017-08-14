/** Express import */
var express = require('express');
var app = express();
var port = process.env.port || 3500;
var apiRouter = express.Router();
/** postgres string connection */
const Postgres = require('./postgres');
var pg = new Postgres();



//pg.save('monkies',{name:"Mikey"},function(err,res){
//    console.log(err);
//    consol.log(res);
//});

apiRouter.route('/usuarios')
    .get(function(req,res){
        res.set({"Content-Type": "application/json; charset=utf-8"});
        
        var responseJson = pg.getUsers();
        res.json(responseJson);
    });
app.use('/api',apiRouter);

app.get('/',function(req,res){
    res.send('welcome to API in CHROME');
});
app.listen(port,function(){
    console.log('Running my app on PORT' + port);
});