SELECT data->>'titulo' as titulo 
FROM aplicativos 
WHERE (to_tsvector(data->>'titulo',data->>'descricao') 
@@ plainto_tsquery('aprender','matematica'))

-- concatena strings
SELECT 'Concatenation' || ' ' || 'Operator' AS result_string;
-- retorna vacio
SELECT 'Concat with ' || NULL AS result_string;
-- concate ignorando NULL
SELECT CONCAT('Concat with ', NULL) as result_string; 
-- concatena resultado
SELECT data->>'titulo' as titulo,
 concat ('Your first name has ', 
	LENGTH (data->>'titulo'),
	' characters')
FROM
 aplicativos;
-- concatena e separa e ordena por titulo
SELECT
 concat_ws (', ', data->>'titulo', data->>'categoria') AS full_name
FROM
 aplicativos
ORDER BY
 data->>'titulo'; 

SELECT concat(data->>'titulo', ' ---- ',
	data->>'descricao') as texto
FROM conteudos 
WHERE id = 4555
-- 
SELECT data->>'titulo' as titulo
FROM conteudos 
WHERE (to_tsvector(data->>'descricao') @@ to_tsquery('matematica')
OR to_tsvector(data->>'titulo') @@ to_tsquery('historia | edicao'))  
GROUP BY titulo

-- ?
SELECT data->>'titulo' as titulo 
FROM aplicativos 
WHERE (to_tsvector(data->>'descricao') @@ to_tsquery('editor')
OR to_tsvector(data->>'titulo') @@ to_tsquery('gimp | inkscape'))  
GROUP BY titulo
--
SELECT data->>'titulo' as titulo,
	data->>'descricao' as descricao 
FROM aplicativos 
WHERE (to_tsvector(concat(
	data->>'titulo',
	data->>'descricao')) 
	@@ to_tsquery('funcao | anima'))

--ORDER BY ts_rank(to_tsvector(data->>'titulo'))

SELECT concat(data->>'titulo',' -- ',data->>'descricao') FROM aplicativos;

-- concatena titulo e descricao e procura por programa OU aplicativo
SELECT count(*) 
FROM aplicativos
where (to_tsvector(concat(data->>'titulo',' ',data->>'descricao')) 
@@ to_tsquery('programas | aplicativo'))