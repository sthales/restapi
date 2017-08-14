/** Postgres import  */
var pg = require('pg');
/** Undercore import */
var _ = require('underscore')._;
/** Assert */
var assert = require('assert');

const connObject = new pg.Pool({
  user: 'niko',
  host: 'localhost',
  database: 'teste',
  password: 'romero',
  port: 5432
});

var items = new Object();

class Postgres{
    constructor(items){
        this.items = items;
    }
    getUsers() {
        //var items = new Object();
        
        var sql = 'SELECT * FROM usuarios;';
        connObject.query(sql,(err,result)=>{
            assert.ok(err == null ,err);
            this.items = Object.assign({}, result.rows);
        });
        
        
        return this.items;
    }
}


// var Postgres= ()=>{
  
//     assert(connObject, 'Need a connectionString');
//     var run = (sql,params,next)=>{
//         pg.connect(connObject,(err,db,done)=>{
//             assert.ok(err == null ,err);
//             db.query(sql,params,(err,result)=>{
//                 done();
//                 pg.end();
//                 if(err){
//                     next(err,null);
//                 }else{
//                     next(null,result.rows);
//                 }
//             });
//         });
//     };
//     this.getUsers = ()=>{
//         var sql = "select * from usuarios;";
//         run(sql,params,next);
//     }
// }

/**
 * var postgres = function(args){
    assert(args.connectionString,'Need a connectionString');
    var run = function(sql,params,next){
        pg.connect(args.connectionString,function(err,db,done){
            //throw if there's connection error
            assert.ok(error == null ,err);
            db.query(sql,params,function(err,result){
                // we have the results, release the connection
                done();
                pg.end();
                if(err){
                    next(err,null);
                }else{
                    next(null,result.rows);
                }
            });
        });
    };
    this.save = function(tbl,doc,next){
        var sql = "select * from save_document($1, $2);";
        var params = [tbl,doc];
        run(sql,params,next);
    };
    this.findById = function(tbl,id,next){

    };
    this.find = function(tbl,criteria,next){

    };
    this.filter = function(tbl,criteria,next){

    };
    this.search = function(tbl,term,next){

    };
};
*/
module.exports = Postgres;