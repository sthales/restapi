/** Express import */
var express = require('express');
var app = express();

module.exports = app;

var port = process.env.port || 3500;
var apiRouter = express.Router();
/** postgres string connection */

//const connObject = new Pool({
//  user: 'niko',
//  host: 'localhost',
//  database: 'aew_db_final',
//  password: 'romero',
//  port: 5432
//});
/** model */
const db = require('./postgres');

db.connect();



//pg.save('monkies',{name:"Mikey"},function(err,res){
//    console.log(err);
//    consol.log(res);
//});

apiRouter.route('/aplicativos')
    .get(function(req,res,next){
        //res.set({"Content-Type": "application/json; charset=utf-8"});
        db.getAplicativos((err,apps) => {
            if(err){
                return next(err);
            }else{
                res.json(apps);
            }
        });
        
        
    });
app.use('/api',apiRouter);

app.get('/',function(req,res){
    res.send('welcome to API in CHROME');
});
app.listen(port,function(){
    console.log('Running my app on PORT' + port);
});