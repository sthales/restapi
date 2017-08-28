CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Javascript 
CREATE EXTENSION IF NOT EXISTS plv8; 

SHOW default_text_search_config;  

-- command line show catalogos \dF

ALTER DATABASE dbname SET default_text_search_config = 'pg_catalog.portuguese'

SET default_text_search_config = 'pg_catalog.portuguese'

select to_tsvector('portuguese','Olá meu irmão');

select titulo from conteudodigital where idconteudodigital = 4005



UPDATE conteudodigital SET documento = (SELECT)
WHERE idconteudodigital = idconteudodigital

SELECT to_tsvector('portuguese', titulo || descricao)  
FROM conteudodigital  
WHERE titulo = 'Princípio de Inércia - Primeira Lei de Newton'; 

SELECT setweight(to_tsvector('simple', COALESCE(titulo,'')), 'A') ||  
     setweight(to_tsvector('portuguese', COALESCE(descricao,'')), 'C')
FROM conteudodigital  
WHERE titulo = 'Princípio de Inércia - Primeira Lei de Newton';

-- lembre desabilitar o trigger UPDATE DO campo DOCUMENTO
UPDATE conteudodigital SET  
    documento = x.documento
FROM (  
    SELECT idconteudodigital,
           setweight(to_tsvector('simple', COALESCE(UNACCENT(TRIM(titulo)),'')), 'B') ||
           setweight(to_tsvector('portuguese', COALESCE(UNACCENT(descricao),'')), 'D')
           AS documento
     FROM conteudodigital
) AS x
WHERE x.idconteudodigital = conteudodigital.idconteudodigital
RETURNING *;

select nometag from tag where idtag = 5555

 
---------------------- UPDATE CON TAGS

WITH d AS
(SELECT cd.idconteudodigital as id, 
        setweight(to_tsvector('simple', COALESCE(UNACCENT(TRIM(string_agg(t.nometag,' '))),'')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(UNACCENT(TRIM(cd.titulo)),'')), 'B') ||
        setweight(to_tsvector('portuguese', COALESCE(UNACCENT(TRIM(cd.descricao)),'')), 'D')
        as doc
FROM conteudodigital cd
JOIN conteudodigitaltag ct 
ON ct.idconteudodigital = cd.idconteudodigital
JOIN tag t ON t.idtag = ct.idtag 
GROUP BY cd.idconteudodigital
) UPDATE conteudodigital cd SET documento = doc 
  FROM d 
  WHERE id = cd.idconteudodigital
  RETURNING cd.documento;

----- Cria index dentro da tabela

CREATE INDEX index_tsv_documento 
ON conteudodigital
USING GIST (documento);  



--- como funciona la consulta con la clausula with
WITH documentos AS
(SELECT cd.idconteudodigital as id, 
        setweight(to_tsvector('simple', COALESCE(UNACCENT(TRIM(string_agg(t.nometag,' '))),'')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(UNACCENT(TRIM(cd.titulo)),'')), 'B') ||
        setweight(to_tsvector('portuguese', COALESCE(UNACCENT(TRIM(cd.descricao)),'')), 'D')
        as doc
FROM conteudodigital cd
JOIN conteudodigitaltag ct 
ON ct.idconteudodigital = cd.idconteudodigital
JOIN tag t ON t.idtag = ct.idtag 
GROUP BY cd.idconteudodigital
) SELECT *
  FROM documentos 
  WHERE id = 4880

-- exemplo ts_headline formatação da busca

SELECT ts_headline(titulo,to_tsquery('marx'),
	'StartSel = <b>,StopSel = </b>,
	MaxFragments=10,
	MinWords=10,
	MaxWords=20,
	FragmentDelimiter=" ...<br>..."') as resultado
FROM conteudodigital
WHERE documento @@ to_tsquery(unaccent('marx'))
LIMIT 20; 

SELECT 'Titulo do Conteúdo: <i>' || titulo || '</i><br><br>' ||
	ts_headline(descricao,q,
	'StartSel = <b>,StopSel = </b>,
	MaxFragments=10,
	MinWords=10,
	MaxWords=20,
	FragmentDelimiter=" ...<br>..."') as resultado,
	ts_rank(documento,q) as ranking
FROM conteudodigital,
     plainto_tsquery(unaccent('deus')) as q
WHERE documento @@ q
ORDER BY ranking DESC;     	
-- utilização ranking

SELECT titulo, ts_rank(documento,q) AS ranking
FROM conteudodigital,
	plainto_tsquery('marx') AS q
ORDER BY ranking DESC
LIMIT 20;	

SELECT titulo,descricao, ts_rank_cd(documento, query) AS rank
FROM conteudodigital, to_tsquery('historia|(gregos & romanos)') query
WHERE query @@ documento
ORDER BY rank DESC
LIMIT 10;

SELECT titulo,descricao, ts_rank_cd(documento, query) AS rank
FROM conteudodigital, to_tsquery('função|(matematica & funcao)') query
WHERE query @@ documento
ORDER BY rank DESC
LIMIT 20;

SELECT ts_rank(documento,
       to_tsquery('matematica | funcao')) as relevancia,
       idconteudodigital
FROM conteudodigital
WHERE idconteudodigital = idconteudodigital
ORDER BY relevancia DESC;

--- LISTA tags por similitude


SELECT titulo
FROM   conteudodigital
WHERE  documento @@ to_tsquery('sertao')





------------- trigram-indexes extension 

select idusuario from usuario 
where username ILIKE '%nikoz.1984@gmail.com%'

CREATE INDEX CONCURRENTLY idx_on_usuario_trigram
ON usuario
USING gin (username gin_trgm_ops);

CREATE INDEX CONCURRENTLY idx_usuario_on_nomeusuario_trigram
ON usuario
USING gin (nomeusuario gin_trgm_ops);


------------------
SELECT username,COUNT(*) as count
FROM usuario
WHERE username ILIKE '%mail%'
GROUP BY username;

SELECT idusuario,nomeusuario
FROM usuario
WHERE similarity(lower(nomeusuario),'nicolas') > 0.4

select * from usuario

select show_trgm('nicolas');

select idusuario,
	nomeusuario,
	SIMILARITY(unaccent(lower(nomeusuario)), 'nico') AS sml 
FROM usuario 
ORDER BY sml DESC

SELECT nomeusuario, sml 
FROM usuario,
     SIMILARITY(unaccent(nomeusuario), 'matema') AS sml 	
WHERE sml > 0.333
ORDER BY sml DESC, nomeusuario;


SELECT nometag, sml 
FROM tag,
     SIMILARITY(unaccent(nometag), 'historia') AS sml 	
WHERE sml > 0.333
ORDER BY sml DESC, nometag;


SELECT titulo, sml 
FROM conteudodigital,
     SIMILARITY(unaccent(titulo), 'matematica') AS sml 	
WHERE sml > 0.333
ORDER BY sml DESC, titulo;



-- stop words ou palavras irrelevantes
SELECT to_tsvector('english','in the list of stop words');
SELECT ts_rank_cd (to_tsvector('english','in the list of stop words'), to_tsquery('list & stop'));
SELECT ts_rank_cd (to_tsvector('english','list stop words'), to_tsquery('list & stop'));

-- https://www.postgresql.org/docs/9.5/static/unaccent.html

-- As in basic tsquery input, weight(s) can be attached to each lexeme to restrict it to match only tsvector lexemes of those weight(s)
SELECT to_tsquery('portuguese', 'Melão | Fotografia:AB');
-- pesquisar por ts_rank e ts_rank_cd
-- diccionarios 
-- Ispell tentam reduzir palavras de entrada para uma forma normalizada
-- Stemmer removem o fim da palavra

-- por exemplo nome de cores podem ser substituidas por valores hexadecimais: red, green -> FF0000, 00FF00 
-- si indexar numeros remover digitos fracionais para reduzir a faixa de possiveis numeros
-- 3.14159265359, 3.1415926, 3.14
-- modelo thesaurus sinonimos
-- \dFd

select * from pg_ts_dict;

select ts_lexize('simple','SiM');
select ts_lexize('simple','foi');
select * from ts_debug('portuguese','Paris');
-- Veremos que corta a palabra para par
-- echo 'Paris paris' > sinonimos.syn

 -- arquivos de configuração do tsearch /usr/share/postgresql/9.6/tsearch_data/
 -- serve para criar dicionarios personalizados : sinonimos e mais restritivos tipo spell thesaurus
 -- https://www.postgresql.org/docs/9.1/static/textsearch-dictionaries.html 

--  egrep 'foi|sim' portuguese.stop command line /usr/share/postgresql/9.6/tsearch_data
-- respota foi

CREATE TEXT SEARCH DICTIONARY dic_sinonimos (
	TEMPLATE = synonym,
	SYNONYMS = sinonimos
);

ALTER TEXT SEARCH CONFIGURATION portuguese
ALTER MAPPING FOR asciiword
WITH dic_sinonimos, portuguese_stem;

-- agora no corta a palavra e considera um sinonimo
select * from ts_debug('portuguese','Paris');

-- Diccionario thesaurus sirve para abreviar frases ou palavras requer reindexaçao

-- cp thesaurus_sample.ths pt_br_tz.ths  /usr/share/postgresql/9.6/tsearch_data

CREATE TEXT SEARCH DICTIONARY dic_pt_br_tz (
	TEMPLATE = thesaurus,
	DictFile = pt_br_tz,
	Dictionary = pg_catalog.portuguese_stem
);

ALTER TEXT SEARCH CONFIGURATION portuguese
	ALTER MAPPING FOR
	  Asciiword,
	  Asciihword,
	  hword_asciipart
	WITH
	  dic_pt_br_tz,
	  portuguese_stem;	

-- echo 'tv : *televisão' >> pt_br_tz.ths add parametros

ALTER TEXT SEARCH DICTIONARY dic_pt_br_tz (
	DictFile = pt_br_tz
);

SELECT to_tsvector('portuguese','tv')

-- dicionario Ispell verbos irregulares

--  sudo apt install myspell-pt-br instalar dependencia

??

	  
--CREATE TEXT SEARCH CONFIGURATION pt ( COPY = portuguese );
--ALTER TEXT SEARCH CONFIGURATION pt ALTER MAPPING
--FOR hword, hword_part, word WITH unaccent, portuguese_stem;



 
------------------------

SELECT documento from conteudodigital 
 
SELECT idconteudodigital,titulo FROM conteudodigital
WHERE documento @@ to_tsquery(unaccent('marx')) 

select documento from conteudodigital where idconteudodigital = 3848

SELECT idconteudodigital,titulo FROM conteudodigital
WHERE documento @@ to_tsquery(unaccent('DEUS')) 

SELECT idconteudodigital,titulo,descricao,documento FROM conteudodigital
WHERE documento @@ plainto_tsquery('portuguese',unaccent('física e matemática')) 

select documento from conteudodigital where idconteudodigital = 2620

SELECT idconteudodigital,titulo FROM conteudodigital
WHERE documento @@ plainto_tsquery('portuguese',unaccent('biologia molecular'))



EXPLAIN ANALYZE SELECT idconteudodigital 
FROM conteudodigital WHERE 
(to_tsvector('simple', conteudodigital.titulo::text) 
@@ plainto_tsquery('portuguese', 'matemática'::text));



select documento from conteudodigital where idusuarioultimaatualizacao = 1131

select idusuario from usuario 
where username ILIKE '%nikoz.1984@gmail.com%'


SELECT ts_parse('default', descricao)  
FROM conteudodigital  
WHERE titulo = 'Princípio de Inércia - Primeira Lei de Newton' 

SELECT * FROM ts_debug('portuguese', (SELECT titulo FROM conteudodigital WHERE idconteudodigital = 3078));
 
SELECT *  
FROM ts_parse('default',  
(SELECT titulo FROM conteudodigital WHERE idconteudodigital = 1556));


----- ENCRIPTAR EN POSTGRES

select crypt('R0mero',gen_salt('md5'))
select md5('test')
select crypt('mypass', 'cryptpwd');
select gen_salt('bf')::text -- blowfish algoritmo
select crypt('mypass',gen_salt('bf'))
select crypt('new password', gen_salt('md5'));
select pswhash = crypt('entered password', pswhash)


--- inserta novo usuario
WITH x AS (
SELECT 'foo'::text AS user,
	'123'::text AS pw,
	gen_salt('bf')::text AS salt
	)
INSERT INTO tb_user (username,pass)
   SELECT x.user,
	  crypt(x.pw,x.salt)
	  FROM x;

-- login true
SELECT crypt('123',pass) = pass
	as acessed
	FROM tb_user
	WHERE username = 'foo'
-- login false
SELECT crypt('1234',pass) = pass
	as acessed
	FROM tb_user
	WHERE username = 'foo'	



select encrypt('Nicolas encriptado', 'fooz', 'bf')
select decrypt('\215oD\315\031l\206\213\344\317GBq\005\316J\250\355\011\265\005\320\002\212', 'fooz', 'bf')
select gen_random_uuid()
select gen_random_bytes(30)


SELECT encode(digest('ss', 'sha1'), 'hex')
SELECT decode(digest('c1c93f88d273660be5358cd4ee2df2c2f3f0e8e7', 'sha1'), 'hex')

SELECT CONVERT_FROM(DECODE(field, 'BASE64'), 'UTF-8') FROM table;

-- codifica em base 64
SELECT ENCODE(CONVERT_TO(nomeusuario, 'UTF-8'), 'base64') 
FROM usuario where idusuario = 1131;
-- decodifica em base 64
SELECT CONVERT_FROM(DECODE('Tmljb2zDoXMgRGFuaWVsIFJvbWVybyBIZXJuw6FuZGV6', 'BASE64'), 'UTF-8') 
FROM usuario where idusuario = 1131;

SELECT gen_random_uuid()


	  
