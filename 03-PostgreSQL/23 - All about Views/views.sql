/*
PostgreSQL Views 
STANDARD VIEW: Virtual table; runs query in real-time.
Syntax: CREATE VIEW name AS SELECT ...;

MATERIALIZED VIEW: Physically stores results on disk for speed.
Syntax: CREATE MATERIALIZED VIEW name AS SELECT ...;

Update: REFRESH MATERIALIZED VIEW name;
TEMP VIEW: Automatically dropped at session end.
Syntax: CREATE TEMP VIEW name AS SELECT ...;

RECURSIVE VIEW: Handles hierarchical/tree data.
Syntax: CREATE RECURSIVE VIEW name(cols) AS (base_query UNION recursive_query);

MANAGEMENT:

Modify: CREATE OR REPLACE VIEW name AS ...;

Delete: DROP VIEW name; OR DROP MATERIALIZED VIEW name;
*/

--creating view

create or replace view name as query

query can be anything subquery , join

--view to include all movies with directors first and last name

create or replace view v_movie_quick as 
select
    movie_name,
    movie_length,
    release_date
from movies mv

create or replace view v_movies_directors_all as
select
mv.movie_id,
mv.movie_name,
mv.movie_length,
mv.movie_lang,
mv.release_date,
mv.age_certificate,
mv.director_id,

d.first_name,
d.last_name,
d.date_of_birth,
d.nationality
 from movies mv
inner join directors d on  d.director_id = mv.director_id


select * from v_movies_directors_all

select * from v_movie_quick

--rename a view

--alter view view name rename to newname

alter view v_movie_quick rename to v_movie_quick2

--delete view

--drop view name
drop view v_movie_quick2

-- use filter with view

create or replace view v_movies_after_1997 as
select
* 
from movies
where release_date >='1997-12-31'
order by release_date desc


--english only from view

select * from v_movies_after_1997
where movie_lang = 'English'

--movies with american and japanese directoes

select
*
from movies mv
inner join directors d on d.director_id = mv.director_id
where d.nationality in ('American','Japanese')

--or

select * from v_movies_directors_all
where nationality in ('American','Japanese')


--view with union

--all people in a movie like actors and directors firstname and lastname

create view v_all_actors_directors as
select
    first_name,
    last_name,
    'actors' as people_type
from actors
union all
select
    first_name,
    last_name,
    'directors' as people_type
from directors



select * from v_all_actors_directors
order by people_type,first_name


--connecting multiple table with single view

--movies , directors , movies_revenues

create view v_movies_directors_revenues as 
select
*
from
movies mv
inner join directors d on d.director_id = mv.director_id
inner join movies_revenues mr  on mr.movie_id = mv.movie_id

--a column cannot appear multple time while view
--column "movie_id" specified more than once

create view v_movies_directors_revenues as 
select
mv.movie_id,
mv.movie_name,
mv.movie_length,
mv.movie_lang,
mv.release_date,
mv.age_certificate,

d.director_id,
d.first_name,
d.last_name,
d.date_of_birth,
d.nationality,

mr.revenue_id,
mr.revenues_domestic,
mr.revenues_international
from
movies mv
inner join directors d on d.director_id = mv.director_id
inner join movies_revenues mr  on mr.movie_id = mv.movie_id

select * from v_movies_directors_revenues
where age_certificate = '12'

--rearrange columns in a view

create view v_directors as
select
    first_name,
    last_name
from directors

--the only way is to delete the view and rearrage them

drop view v_directors

--delete a column in a view

create view v_directors as
select
    first_name,
    last_name
from directors

select * from v_directors

--this also requires deleting view and rebuilding again

--same goes for adding a column
--here 
create or replace view v_directors as
select
    first_name,
    last_name,
    director_id
from directors
--new column must be at last


--regular view are dynamic and not store data thus giving all data updated

select * from v_directors
--38 data

insert into directors (first_name,last_name,date_of_birth,nationality) values
('madhav','bhalodiya','2004-07-04'::date,'indian')

select * from v_directors
--39 data

--what is an updatable view
--can use only
--insert , delete , update with where thats it

--updatable view with crud
create or replace view vu_directors as
select
    first_name,
    last_name
from directors

--insert via view

insert into vu_directors (first_name) values ('dir1'),('dir2')

select * from vu_directors

select * from directors

--delete

delete from vu_directors where first_name = 'dir1'

select * from vu_directors

delete from vu_directors where first_name = 'dir2'

--updatable view with check option

CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_code VARCHAR(4),
    city_name VARCHAR(100)
);

INSERT INTO countries (country_code, city_name)
VALUES
('IND','Delhi'),
('USA','Mumbai'),
('CAD','Bengal');

CREATE OR REPLACE VIEW v_cities_us AS
SELECT *
FROM countries
WHERE country_code = 'USA'
WITH CHECK OPTION;

INSERT INTO v_cities_us (country_code, city_name)
VALUES ('USA','chicago');

select * from v_cities_us

--WITH CHECK OPTION ensures that all INSERTs and UPDATEs through a view satisfy the view’s defining condition, preventing hidden or inconsistent data modifications, and is commonly used with privileges to enforce row-level data security.

--Updatable views using WITH LOCAL and CASCADED CHECK OPTION

create or replace view v_cities_c as 
select
    country_id,
    country_code,
    city_name
from countries
where city_name like 'c%' or city_name like 'C%'


select * from v_cities_c


create or replace view v_cities_c_us as 
select
    country_id,
    country_code,
    city_name
from v_cities_c
where country_code = 'USA'
with local check option

insert into v_cities_c_us (country_code, city_name) values ('USA','connecticut')

insert into v_cities_c_us (country_code, city_name) values ('USA','Los Angeles')

select * from v_cities_c


select * from 
--in only checks the local condition

create or replace view v_cities_c_us as 
select
    country_id,
    country_code,
    city_name
from v_cities_c
where country_code = 'USA'
with cascaded check option

--cascaded
insert into v_cities_c_us (country_code, city_name) values ('USA','boston')

-- new row violates check option for view "v_cities_c"
-- DETAIL: Failing row contains (9, USA, boston).

/*
MATERIALIZED VIEWS 
PHYSICAL STORAGE: Unlike standard views, these save the query result
to disk. They occupy actual storage space.
PERFORMANCE: High-speed reads because the database doesn't re-run
complex joins or aggregates on every access.
DATA FRESHNESS: Not real-time. Data remains "frozen" as a snapshot
until a manual or scheduled refresh is triggered.
REFRESHING:
Standard: Locks the table (no reads allowed during update).
Concurrent: Allows reads while updating (requires a Unique Index).
INDEXING: Supports custom indexes directly on the view to further
optimise performance, exactly like a regular table.
*/

--creating a materialized view

create materialized view if not exist as query
with [no] data

create materialized view if not exists mv_directors as
select
first_name,
last_name
from directors
with data

select * from mv_directors

--nodata

create materialized view if not exists mv_directors_nodata as
select
first_name,
last_name
from directors
with no data

select * from mv_directors_nodata

-- materialized view "mv_directors_nodata" has not been populated
-- HINT: Use the REFRESH MATERIALIZED VIEW command.


refresh materialized view mv_directors_nodata

select * from mv_directors_nodata

--drop materialized view

drop materialized view mv_directors_nodata

--Changing materialized view data

select * from mv_directors

insert into mv_directors (first_name)  values ('dir1'),('dir2')
--cannot change materialized view "mv_directors"

insert into directors (first_name)  values ('dir1'),('dir2')

--the change will be not visible until refresh

refresh materialized view mv_directors

select * from mv_directors

--insert , delete or update will not work on materialized view 

delete from directors where first_name in ('dir1','dir2')

--How to check if a materialized view is populated or not?

select relispopulated from pg_class where relname = 'mv_directors'
--true

create materialized view if not exists mv_directors2 as
select
first_name,
last_name,
director_id
from directors
with no data



select relispopulated from pg_class where relname = 'mv_directors2'
--false

-- Refreshing data in materialize views

--using previous mv_directors2 table

--view it

select * from mv_directors2
--materialized view "mv_directors2" has not been populated
-- HINT: Use the REFRESH MATERIALIZED VIEW command.

--refresh the view

refresh materialized view mv_directors2

select * from mv_directors2

--While refreshing an index normally blocks queries on the table, using CONCURRENTLY allows the table to remain readable and writable while the index is being rebuilt.

refresh materialized view concurrently mv_directors2

-- cannot refresh materialized view "public.mv_directors2" concurrently
-- HINT: Create a unique index with no WHERE clause on one or more columns of the materialized view.

create unique index idx_u_mv_directors2_first_name on mv_directors2(director_id)

refresh materialized view concurrently mv_directors2

/* 
A table stores static data and must be manually kept in sync, 
while a materialized view stores query results that can be 
automatically refreshed to stay consistent with the base tables.

Example: 
Sales table changes every minute.
A normal table copied from it becomes outdated.
A materialized view can be REFRESHed to recompute totals from sales 
without rewriting insert/update logic.
*/

/* 
Downsides of materialized views (with example):
1. Stale data: 
   -- Base table changes aren’t reflected automatically
   SELECT * FROM sales;        -- new sales exist
   SELECT * FROM mv_sales_totals; -- still old totals until REFRESH

2. Refresh can be slow:
   REFRESH MATERIALIZED VIEW mv_sales_totals; -- takes time if millions of rows

3. Extra storage:
   -- Stores all aggregated totals physically, unlike a normal view

4. Limited write capability:
   -- You cannot directly insert into mv_sales_totals like a table
*/


--Using materialized view for websites page analysis

create table page_clicks(
    rec_id serial primary key,
    page varchar(200),
    click_time timestamp,
    user_id bigint
)

--10000 fake data
INSERT INTO page_clicks (page, click_time, user_id)
SELECT 
 
    (ARRAY['home', 'product_page', 'cart', 'checkout', 'blog'])[floor(random() * 5 + 1)],
    
    
    NOW() - (random() * (interval '30 days')),
    
   
    floor(random() * (9999 - 1000 + 1) + 1000)::bigint
FROM generate_series(1, 10000);


select * from page_clicks limit 100

--analyze a daily trend 

create materialized view mv_page_clicks_daily as
select
    date_trunc('day',click_time) as day,
    page,
    count(*) as total_clicks
from page_clicks
group by day,page;

select * from mv_page_clicks_daily

refresh materialized view mv_page_clicks_daily

--and we can refresh as we use 


CREATE MATERIALIZED VIEW mv_page_clicks_daily2 AS
SELECT
    date_trunc('day', click_time) AS day,
    page,
    count(*) AS cnt
FROM page_clicks
WHERE click_time >= date_trunc('day', now())
  AND click_time < date_trunc('day', now()) + interval '1 day'
GROUP BY day, page;


select * from mv_page_clicks_daily2

--create a unique index for concurrent

create unique index idx_my_page_clicks_daily_page on mv_page_clicks_daily2(page)

refresh materialized view concurrently mv_page_clicks_daily2

--list all materialized view by select

select oid::regclass::text
from pg_class
where relkind = 'm'

-- mv_directors_nodata
-- mv_directors
-- mv_page_clicks_daily
-- mv_directors2
-- mv_page_clicks_daily2

-- List materialized views with no unique index

SELECT
    c.relname AS materialized_view
FROM pg_class c
WHERE c.relkind = 'm'
AND NOT EXISTS (
    SELECT 1
    FROM pg_index i
    WHERE i.indrelid = c.oid
      AND i.indisunique = true
);

-- mv_directors_nodata
-- mv_directors
-- mv_page_clicks_daily
