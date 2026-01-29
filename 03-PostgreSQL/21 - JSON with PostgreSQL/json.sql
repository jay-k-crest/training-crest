
/*
JavaScript Object Notation (JSON)
{
    "key": "value"
}
Used in most modern CRUD APIs as request or response payloads because it is
self-describing and easily modifiable. It can contain main data and metadata.
Compared to XML, JSON is less verbose (no heavy <> tags), which makes parsing
lighter and read/write operations easier.

numeric values dont require quotes

{} used in json
[] json array 

"contacts": [
            {key1:value1},
            {key2:value2},
            {key3:value3}
            ]


{
  title: "Clean Code",
  author: "Robert Martin",
  details: {
    publisher: "Prentice Hall" 
  },
  prices: [
    { type: "Paperback", price: 44.99 },
    { type: "E-book", price: 29.99 }
  ]
};


JSON (Textual)
Storage: Stores an exact, verbatim copy of the input text.
Speed: Faster for writes (inserts) because it doesn't require pre-parsing.
Preservation: Maintains original whitespace, key order, and duplicate keys.
Retrieval: Slower for queries; the database must re-parse the text every time you extract a value. 


2. JSONB (Binary)
Storage: Stores data in a decomposed binary format, which is often slightly larger on disk due to overhead but significantly more efficient.
Speed: Faster for reads and processing since the binary tree is ready to be traversed.
Optimization: Automatically removes unnecessary whitespace, does not preserve key order, and keeps only the last value if duplicate keys exist.
Indexing: Supports powerful GIN (Generalized Inverted Index) indexing, allowing you to search deep inside large documents instantly



*/

select '{"title":"Clean Code","author":"Robert Martin"}'

--jaon will keep all white spaces
select '{
    "title":"Clean Code","author":"Robert Martin"
}'::json

--to remove have to use jsonb

select '{
    "title":"Clean Code","author":"Robert Martin"
}'::jsonb



--create a table book with jsonb

CREATE table books (
    book_id serial PRIMARY KEY,
    book_info jsonb NOT NULL
)

INSERT INTO books (book_info)
VALUES
('{
    "title":"Clean Code",
    "author":"Robert Martin"
}')

SELECT * FROM books

INSERT INTO books (book_info)
VALUES
('{
    "title":"A Song of Ice and Fire",
    "author":"George R.R. Martin"
}'),

('{
    "title":"The Hitchhiker''s Guide to the Galaxy",
    "author":"Douglas Adams"
}'),

('{
    "title":"The Lord of the Rings",
    "author":"J.R.R. Tolkien"
}')

SELECT * from books

--using selectors
/*
-> quotes
->> text
*/

select book_info from books

--returns title in doule quotes
select book_info->'title' from books

--returns text
select book_info->>'title' from books

select
 book_info->>'title' as "title",
 book_info->>'author' as "author"
from books

--filter

select
 book_info->>'title' as "title",
 book_info->>'author' as "author"
from books
where book_info->>'author' = 'George R.R. Martin'

--update and delete json data

select * from books

insert into books (book_info)
values 
('{
"title":"book10",
"author":"author10"
}')

--|| used to update

update books
set book_info = book_info || '{"author":"jay"}'
where book_info->>'author'='author10'

update books
set book_info = book_info || '{"title":"doom"}'
where book_info->>'title'='book10'

select * from books

--best seller with bool value

update books
set book_info = book_info || '{"is_bestseller":true}'
where book_info->>'title'='doom' 
returning *

--multiple key/value page , category etc...



update books
set book_info = book_info || '
{
"category":"marvel",
"pages":"200"
}'
where book_info->>'title'='doom' 
returning *

--delete best seller using - operator

update books
set book_info = book_info - 'is_bestseller'
where book_info->>'title'='doom' 
returning *

--nested array data

update books
set book_info = book_info || '{"reviews": [
    {"user": "jay", "rating": 5, "comment": "goated"},
    {"user": "madhav", "rating": 4, "comment": "skibidi dob"}
]}'
where book_info->>'title'='doom' 
returning *


--delete from array via #-
update books
set book_info = book_info #- '{reviews,1}'
where book_info->>'title'='doom' 
returning *


--create from json
--directors table to json

select 
row_to_json(directors)
from directors


select row_to_json(t) from
(
SELECT  
    director_id,
    first_name,
    last_name,
    nationality
from directors
) as t

--json_agg to agragate data

--list all movies for each director

select 
director_id,
first_name,
last_name,
(
    select 
    json_agg(x) from
    (
        select 
        movie_id,
        movie_name,
        release_date
        from movies
        where director_id = directors.director_id
    ) as x
)
from directors

--json array


select json_build_array(1,2,3,4,5)

--add text

select json_build_array(1,2,3,4,5,'hello')

--object
select json_build_object(1,2,3,4,5,'hello')

--supply key value

select json_build_object('name','jay','email','abc@zxyz.com')

--json_object((keys),(values))

select json_object('{name,email}','{jay,abc@zxyz.com}')

--create document from data
--#########################

create table directors_docs(
    id serial primary key,
    body jsonb
)

--insert data
--lets gett all movies by each director
select row_to_json(a)::jsonb from
(
select 
    director_id,
    first_name,
    last_name,
    date_of_birth,
    nationality,(
        select 
            json_agg(x) as all_movies from(
                select 
                    movie_name
                from movies
                where director_id = directors.director_id
            ) x
    )
from directors
) as a

--insert data
insert into directors_docs(body)
select row_to_json(a)::jsonb from
(
select 
    director_id,
    first_name,
    last_name,
    date_of_birth,
    nationality,(
        select 
            json_agg(x) as all_movies from(
                select 
                    movie_name
                from movies
                where director_id = directors.director_id
            ) x
    )
from directors
) as a

select * from directors_docs

--how to deal with null in json doc

select * from directors_docs

select jsonb_array_elements(body->'all_movies') from directors_docs
where (body->'all_movies') is not null

--will give error
--cannot extract elements from a scalar
delete from directors_docs


--empty values addition
insert into directors_docs(body)
select row_to_json(a)::jsonb from
(
select 
    director_id,
    first_name,
    last_name,
    date_of_birth,
    nationality,(
        select case
            count(x) when 0 then '[]' else json_agg(x) end as all_movies from(
                select 
                    movie_name
                from movies
                where director_id = directors.director_id
            ) x
    )
from directors
) as a

--try again
select jsonb_array_elements(body->'all_movies') from directors_docs

--getting info from json docs

--count total movies for each director


select
*,
jsonb_array_length(body->'all_movies') as total_movies
from directors_docs
order by total_movies desc

--list all keys within each json row
select 
*,
jsonb_object_keys(body) as keys
from directors_docs


--display key and values
select 
    j.key,
    j.value
from directors_docs , jsonb_each(directors_docs.body) j

--json to table
select 
    j.*
from directors_docs , jsonb_to_record(directors_docs.body) j
(
    director_id int,
    first_name text,
    last_name text,
    date_of_birth date,
    nationality text,
    all_movies jsonb
)


--the existance operator
--?

select * from directors_docs 
where body->'first_name'?'John'

--all records with director_id 1

select * from directors_docs 
where body->'director_id'? '1'::text

--? left and right must be a text 

--solution containment operator

--alll john

select * from directors_docs 
where body @> '{"first_name":"John"}'

--all records with director_id 1

select * from directors_docs 
where body @> '{"director_id":1}'

--toy story record

select * from directors_docs 
where body->'all_movies' @> '[{"movie_name":"Toy Story"}]'

--json search

--all record with first name starting with 'J'


select * from directors_docs 
where body ->>'first_name' like 'J%'

--director id >2

select * from directors_docs 
where (body ->>'director_id')::int>2

--director id is 1,2,3,4,5,10

select * from directors_docs 
where (body ->>'director_id')::int in (1,2,3,4,5,10)


explain select * from directors_docs 
where body ->>'first_name' like 'J%'

-- QUERY PLAN
-- Seq Scan on directors_docs  (cost=0.00..3.00 rows=1 width=36)
--   Filter: ((body ->> 'first_name'::text) ~~ 'J%'::text)

--seq search is not ideal for any db query 
--indexing in jsonb

select * from
contacts_docs

--all record first name is john

explain analyze select * from contacts_docs
where body @> '{"first_name":"John"}'

--Execution Time: 12.887 ms
--Seq Scan on contacts_docs  (cost=0.00..665.00 rows=2 width=135) (actual time=1.752..12.848 rows=9.00 loops=1)

--using GIN index

/**
 * GIN (Generalized Inverted Index)
 * 
 * Think of this like the "Index" at the back of a textbook.
 * Instead of scanning every row (reading the whole book), it maps 
 * every key and value inside your JSONB to its row location.
 * 
 * Perfect for: Using the @> (contains) operator.
 * Trade-off: Faster reads/searches, but slower inserts/updates.
 */

create index idx_gin_contacts_docs_body on contacts_docs using gin(body);

-- Total execution time: 00:00:00.508

--check again


explain analyze select * from contacts_docs
where body @> '{"first_name":"John"}'

--Execution Time: 4.117 ms
--vs
----Execution Time: 12.887 ms

--check size of index

select pg_size_pretty(pg_relation_size('idx_gin_contacts_docs_body'::regclass)) as index_name
--3664 kB


/**
 * GIN INDEX CHALLENGES:
 * 
 * 1. SLOW WRITES: Every Insert/Update takes a hit because Postgres 
 *    must re-index every single key/value inside the JSON.
 * 2. DISK HOG: These indexes are massive. They can easily become 
 *    larger than the actual table data.
 * 3. BLOAT: High-write tables cause GIN fragmentation, requiring 
 *    frequent VACUUMing to keep performance from tanking.
 * 4. SPECIFICITY: Only works with containment (@>) or existence (?) operators. 
 *    Standard equality (=) or ranges (>) usually won't use it.
 */

--better approach

create index idx_gin_contacts_docs_body_cool on contacts_docs using gin(body jsonb_path_ops);

-- Total execution time: 00:00:00.211

select pg_size_pretty(pg_relation_size('idx_gin_contacts_docs_body_cool'::regclass)) as index_name
--2512 kB

--create index on a specific json key
create index idx_gin_contacts_docs_body_fname on contacts_docs using gin((body->'first_name')jsonb_path_ops);
--Total execution time: 00:00:00.117

select pg_size_pretty(pg_relation_size('idx_gin_contacts_docs_body_fname'::regclass)) as index_name
--288 kB

