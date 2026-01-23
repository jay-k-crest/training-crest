/*
- TOPIC 1: INNER JOIN
- Purpose: Combines rows from two or more tables based on a related column between them.
- Logic: Only returns records where there is a match in BOTH tables.
- Filtration: If a row in Table A has no matching ID in Table B, that row is excluded from the results.
- Syntax: SELECT columns FROM tableA INNER JOIN tableB ON tableA.key = tableB.key.
- Use Case: Retrieving related data, such as "Orders" alongside "Customer Names."
*/


--combine movies and directors table
select * from movies --director_id foreign key
select * from directors --id primary key

select 
movies.movie_id,
movies.movie_name,
movies.director_id,

directors.first_name
from movies
inner join directors
on movies.director_id = directors.director_id

--join using alias

select 
m.movie_id,
m.movie_name,
m.director_id,

d.first_name
from movies m 
inner join directors d
on m.director_id = d.director_id

--filter some records

select 
m.movie_name,
m.director_id,
m.movie_lang,

d.first_name
from movies m 
inner join directors d
on m.director_id = d.director_id
where m.movie_lang != 'Japanese'
and d.director_id = '3'

-- m.* will take all colums

--inner join with "using"

--used when same column name

--movie and director table using keyword

--director_id is common keyword

select 
*
from movies
inner join directors using(director_id)

--movies and movies_revenues
--movie_id is common

select 
*
from movies
inner join movies_revenues using(movie_id)


--can we connect more than 2 table
--movies , revenues, directors
--movie movie_id direcotr_id
--movie_revenues movie_id , director director_id

select
*
from movies
inner join movies_revenues using(movie_id)
inner join directors using(director_id)

--inner joins with filter

--moviename , domestic revenue ,  for japanese movie
select
m.movie_name,

d.first_name,
d.last_name,

r.revenues_domestic
from movies m
inner join directors d on m.director_id = d.director_id
inner join movies_revenues r on m.movie_id = r.movie_id
where m.movie_lang = 'Japanese'

--movie name , director name for all english , chinese and japanese movies where domestic revenues is greater than 100

select 
 m.movie_name,
 m.movie_lang,

 d.first_name,
 d.last_name,

r.revenues_domestic

from movies m
inner join directors d on m.director_id = d.director_id
inner join movies_revenues r on m.movie_id = r.movie_id
where m.movie_lang in('Japanese','Chinese','English')
and r.revenues_domestic > 100 

--moviename , directorname , movielanf , total revenues for all top 5 movies

select 
 m.movie_name as "movie name",
 m.movie_lang,

d.first_name || ' ' || d.last_name AS director_name,

(r.revenues_domestic + r.revenues_international) AS total_revenues
from movies m
inner join directors d on m.director_id = d.director_id
inner join movies_revenues r on m.movie_id = r.movie_id
ORDER BY total_revenues DESC NULLS LAST
LIMIT 5;

--top 5 most profitable movies between 2005 and 2008, name , direcor name and total income

select 
 m.movie_name as "movie name",
 m.release_date,

d.first_name || ' ' || d.last_name AS director_name,

(r.revenues_domestic + r.revenues_international) AS total_revenues

from movies m
inner join directors d on m.director_id = d.director_id
inner join movies_revenues r on m.movie_id = r.movie_id
where release_date between'2005-01-01'::date and '2008-12-31'::date
order by total_revenues desc
limit 5;

--inner join with different column data types

create table t1 (test int)

create table t2 (test varchar(10))

--can we join them?

select* from t1
inner join t2 on t1.test = t2.test
--will throw error

--use case

select* from t1
inner join t2 on t1.test = t2.test::int
--or

select* from t1
inner join t2 on t1.test::varchar = t2.test

insert into t1(test) values (1),(2)

insert into t2(test) values (1),(2)

select* from t1
inner join t2 on t1.test = t2.test::int

--or

select* from t1
inner join t2 on t1.test::varchar = t2.test

/*
- TOPIC 2: LEFT JOIN (LEFT OUTER JOIN)
- Purpose: Returns ALL records from the left table, and the matched records from the right table.
- Logic: If there is no match, the result is NULL on the right side.
- Primary Table: The table listed first (the "Left" table) is the dominant table; no rows from this table will be dropped.
- Use Case: Finding "orphaned" records or items without associations (e.g., Movies without a Director assigned).
*/

create table left_products (
    p_id serial primary key,
    p_name varchar(200)
)

create table right_products (
    p_id serial primary key,
    p_name varchar(200)
)

--add some data

insert into left_products (p_id,p_name) values
(1,'Product A'),
(2,'Product B'),
(3,'Product C'),
(4,'Product D'),
(5,'Product E'),
(6,'Product F');

insert into right_products (p_id,p_name) values
(1,'Product A'),
(2,'Product B'),
(3,'Product G'),
(4,'Product H'),
(5,'Product I');

select 
*
from left_products
left join right_products using(p_id)

--all movies with director fname, lname and movie name

--director_id is same

select
 d.first_name,
 d.last_name,
 m.movie_name
from directors d
left join movies m on m.director_id = d.director_id


--reverse

select
 d.first_name,
 d.last_name,
 m.movie_name
from movies m
left join directors d on m.director_id = d.director_id

--insert a data in director table

insert into directors (first_name,last_name,date_of_birth,nationality) values
('jay','kalsariya','22-05-2002','Indian')

--run again
select
 d.first_name,
 d.last_name,
 m.movie_name
from movies m
left join directors d on m.director_id = d.director_id

--get english and chinese movies

select
 d.first_name,
 d.last_name,
 m.movie_name,
 m.movie_lang
from directors d
left join movies m on m.director_id = d.director_id
-- where movie_lang in('English','Chinese','NULL')

--count all movies for each director

select
d.first_name,
d.last_name,
count(*) as "total_movies"
from directors d
left join movies m on m.director_id = d.director_id
group by d.first_name,d.last_name
order by total_movies desc

--get all movies with age certification for all directors where nationality are american chinese adn japanese

select
m.movie_name,
m.age_certificate,
d.first_name || ' ' || d.last_name as "full name"
from movies  m
left join directors d on m.director_id = d.director_id
GROUP BY
    m.movie_name,
    d.nationality,
    m.age_certificate,
    d.first_name || ' ' || d.last_name
having d.nationality in('American','Chinese','Japanese')
order by age_certificate desc


--get all total revenue done by each film by each director

SELECT
    d.first_name || ' ' || d.last_name as "full name",
    m.movie_name,
    sum(COALESCE(r.revenues_domestic, 0)+COALESCE(r.revenues_international, 0)) as "total revenue"
from directors d
left join movies m on m.director_id = d.director_id
left join movies_revenues r on m.movie_id = r.movie_id
group by d.first_name,d.last_name,m.movie_name
order by "total revenue" desc

/*
- TOPIC 3: RIGHT JOIN (RIGHT OUTER JOIN)
- Purpose: The mirror image of the LEFT JOIN. It returns ALL records from the right table, and the matched records from the left table.
- Logic: If there is no match in the left table for a row in the right table, the result contains NULLs for the left table's columns.
- Significance: The table listed second (after the 'RIGHT JOIN' keyword) is the "Primary" table.
- Relationship: 'Table A LEFT JOIN Table B' is functionally identical to 'Table B RIGHT JOIN Table A'.
*/

select * from left_products

select * from right_products

select
*
from left_products
right join right_products using(p_id)

--list all the movies with directors first and last name and movie name

select
    d.first_name,
    d.last_name,

    m.movie_name
from directors d
right join movies m on m.director_id = d.director_id

--reverse the table

select
    d.first_name,
    d.last_name,

    m.movie_name
from movies m
right join directors d on m.director_id = d.director_id


--list of english and chinese movies only

select
    d.first_name,
    d.last_name,

    m.movie_name,
    m.movie_lang
from directors d
right join movies m on m.director_id = d.director_id
where
    m.movie_lang in('English','Chinese')


--count all movies for each director

select
d.first_name,
d.last_name,
count(*) as "total_movies"
from directors d
right join movies m on m.director_id = d.director_id
group by d.first_name,d.last_name
order by total_movies desc

--total revenues done by each film by each director



select
    d.first_name,
    d.last_name,

    sum(COALESCE(r.revenues_domestic, 0)+COALESCE(r.revenues_international, 0)) as "total revenue"
from directors d
right join movies m on m.director_id = d.director_id
right join movies_revenues r on m.movie_id = r.movie_id
group by d.first_name,d.last_name
order by "total revenue" desc
/*
- TOPIC 4: FULL OUTER JOIN
- Purpose: Combines the results of both LEFT and RIGHT joins.
- Logic: Returns all records when there is a match in either left or right table records.
- Results: 
    - If there is a match, rows are joined.
    - If there is no match on the left, right columns are filled with NULL.
    - If there is no match on the right, left columns are filled with NULL.
- Use Case: Data auditing or synchronizing two tables where you need to see every record from both sides, regardless of associations.
*/

--left_product and right_product via full join

select
*
from left_products
full join right_products using(p_id)

--right+left union

--list of english and chinese movies only

select
    d.first_name,
    d.last_name,

    m.movie_name,
    m.movie_lang
from directors d
full join movies m on m.director_id = d.director_id
where
    m.movie_lang in('English','Chinese')

--joining multiple tables

--get all total revenue done by each film by each director

SELECT
    d.first_name || ' ' || d.last_name as "full name",
    m.movie_name,
    sum(COALESCE(r.revenues_domestic, 0)+COALESCE(r.revenues_international, 0)) as "total revenue"
from directors d
left join movies m on m.director_id = d.director_id
left join movies_revenues r on m.movie_id = r.movie_id
group by d.first_name,d.last_name,m.movie_name
order by "total revenue" desc

--join movies , actors , directors , movies_revenues together

select 
*
from actors ac
join movies_actors ma on ac.actor_id = ma.actor_id
join movies m on ma.movie_id = m.movie_id
join directors d on m.director_id = d.director_id
join movies_revenues r on m.movie_id = r.movie_id


--is join and inner join same?
--yes both produce same result
select 
*
from actors ac
inner join movies_actors ma on ac.actor_id = ma.actor_id
inner join movies m on ma.movie_id = m.movie_id
inner join directors d on m.director_id = d.director_id
inner join movies_revenues r on m.movie_id = r.movie_id

/*
- TOPIC 5: SELF JOIN
- Purpose: A self join is a regular join, but the table is joined with itself.
- Logic: Since you are using the same table twice, you MUST use table aliases to distinguish the "left" version from the "right" version.
- Common Use Case: Used for hierarchical data (e.g., an 'employees' table where one column is 'manager_id' pointing back to another employee's 'emp_id').
- Comparison: It treats the single table as if it were two identical tables sitting side-by-side.
*/


--inner join left_product table

select 
*
from left_products t1
inner join left_products t2 on t1.p_id = t2.p_id


--self join directors table

select 
*
from directors t1
inner join directors t2 on t1.director_id = t2.director_id


--lets self join finds all pair of movies that have the same movie length 


SELECT
    t1.movie_name,
    t1.movie_length,
    t2.movie_name,
    t2.movie_length
FROM movies t1
JOIN movies t2
    ON t1.movie_length = t2.movie_length
WHERE t1.movie_id < t2.movie_id;

--query hierarchical data like all directors and movies

select
t1.movie_name,
t2.director_id
from movies t1
inner join movies t2 on t1.movie_id = t2.movie_id


/*
- TOPIC 6: CROSS JOIN
- Purpose: Produces a Cartesian Product of two tables. 
- Logic: Every single row from the first table is combined with every single row from the second table.
- Result Set Size: If Table A has 10 rows and Table B has 5 rows, the result will have 50 rows (10 * 5).
- Constraint: Unlike other joins, it does NOT use an 'ON' clause because there is no matching condition.
- Use Case: Generating all possible combinations (e.g., matching every shirt color with every pants size).
*/

--cross join left_products and right_products

select 
*
from left_products
cross join right_products
--mXn results

--does order matter?

select 
*
from right_products
cross join left_products
--order does matter

--equivalant
select
*
from left_products , right_products

--method 2
select *
from left_products
inner join right_products on true

--cross join with directos and directors

--147x38 records

select
* 
from actors
cross join directors

/*
- TOPIC 7: NATURAL JOIN
- Purpose: A shorthand join that automatically joins tables based on columns with the SAME name.
- Logic: It looks for any columns that exist in both tables and uses them as the join condition.
- Constraint: It does not use an 'ON' or 'USING' clause.
- Risk: It can be dangerous if two tables share a column name that isn't actually a relationship (e.g., both have a 'created_at' or 'name' column).
- Result: It returns only one copy of each common column, unlike an INNER JOIN which might show both 'tableA.id' and 'tableB.id'.
*/

select 
*
from left_products
natural left join right_products

--natural join movies nad directors table

select 
*
from movies
natural join directors

--by default inner
--specify natural left or right for perticular use case

--append table with different columns

--table1 , add_date , col1-3
--table2 - add_date , col 1-5

--use data of table 1 

create table t1(
    add_date date,
    col1 int,
    col2 int,
    col3 int
)

create table t2(
    add_date date,
    col1 int,
    col2 int,
    col3 int,
    col4 int,
    col5 int
)


insert into t1 (add_date,col1,col2,col3) values
('2020-01-01',1,2,3),
('2020-01-02',4,5,6)

insert into t2 (add_date,col1,col2,col3,col4,col5) values
('2020-01-01',NULL,7,8,9,10),
('2020-01-02',11,12,13,14,15),
('2020-01-03',16,17,18,19,20);

--use (coalesce(c1,c2))

select
    coalesce(t1.add_date,t2.add_date) as add_date,
    coalesce(t1.col1,t2.col1) as col1,
    coalesce(t1.col2,t2.col2) as col2,
    coalesce(t1.col3,t2.col3) as col3,
    t2.col4,
    t2.col5
from t1
full outer join t2 on t1.add_date=t2.add_date

