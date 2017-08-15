/** Postgres import  */
var pg = require('pg');
/** Undercore import */
var _ = require('underscore')._;
/** Assert */
var assert = require('assert');


const client = new pg.Client({
  user: 'niko',
  host: 'localhost',
  database: 'aew_db_final',
  password: 'romero',
  port: 5432
});

const connect = ()=> {
    client.connect((err)=>{
        if(!err){
            assert(err, 'Erro de conexão');
        }else{
            console.log("conectado");
        }
    });
}

client.connect();
    
    
const getAplicativos = (callback)=> {
    client.query("SELECT * from aplicativos",(err,results) =>{
        if(err){
            return callback(err);
        }
        callback(null,results.rows);
    });
}    

module.exports = {
    connect,
    getAplicativos
};