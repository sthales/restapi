select to_tsvector('english','ninja turtles') @@ plainto_tsquery('english','turtle')
select 'aplicativos educacionais' @@ 'aplicativos';
select to_tsvector('simple','ninja turtles') @@ to_tsquery('simple','ninja & turtles')
select to_tsvector('simple','ninja turtles') @@ to_tsquery('simple','ninja | turtles')
select to_tsvector('simple','ninja turtles') @@ to_tsquery('simple','ninja & !turtles')
select ts_rank(to_tsvector('ninja turtles'),to_tsquery('turtles'));


create table docs(
    id bigserial primary key,
    body jsonb not null,
    search tsvector,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);
create index idx_docs on docs using GIN(body jsonb_path_ops);
create index idx_docs_search on docs using GIN(search);

create function create_document_table(name varchar, out boolean)
as $$
  var sql = "create table " + name + "(" +
    "id serial primary key," +
    "body jsonb not null," +
    "search tsvector," +
    "created_at timestamptz default now() not null," +
    "updated_at timestamptz default now() not null);";

  plv8.execute(sql);
  plv8.execute("create index idx_" + name + " on docs using GIN(body jsonb_path_ops)");
  plv8.execute("create index idx_" + name + "_search on docs using GIN(search)");
  return true;
$$ language plv8;



select create_document_table('friends');

drop function if exists save_document(varchar,jsonb);
create function save_document(tbl varchar, doc_string jsonb)
returns jsonb
as $$
    var doc = JSON.parse(doc_string);
  	var result = null;
  	var id = doc.id;
  	var exists = plv8.execute("select table_name from information_schema.tables where table_name = $1", tbl)[0];
    if(!exists){
        plv8.execute("select create_document_table('"+ tbl +"');");
    }
    if(id){
        result = plv8.execute("update " + tbl + " set body=$1, updated_at = now() where id=$2 returning *;",doc_string,id);
    }else{
        result = plv8.execute("insert into" + tbl + "(body) values($1) returning *;",doc_string);
        id = result[0].id;
        doc.id = id;
        result = plv8.execute("update" + tbl +" set body=$1 where id=$2 returning *;",JSON.stringfy(doc),id);
    }
    return result[0] ? result[0].body : null;
$$ language plv8;

select save_document('buddies','{"name":"Niko"}');