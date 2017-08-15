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
            var banco = client.connectionParameters.database;
            console.log('\x1b[36m%s\x1b[0m',"Conetado ao banco de dados " + banco + " com sucesso!!");
        }
    });
}
/** Permite a coneção ao banco */
client.connect();
    
    
const getAplicativos = (callback)=> {
    params = [5];
    client.query("SELECT * from aplicativos LIMIT $1;",params,(err,results) =>{
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