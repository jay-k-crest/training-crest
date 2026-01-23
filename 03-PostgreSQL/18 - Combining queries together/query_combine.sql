/*
- TOPIC 1: UNION & UNION ALL (WITH FILTERS)
- Purpose: Stacks the results of multiple SELECT statements into one table.
- Conditions for Use:
    - Identical column counts and compatible data types across all SELECTs.
- Filtering Behavior:
    - Individual Filters: Each SELECT can have its own WHERE clause to filter data before merging.
    - Post-Union Filters: To filter the combined result, the UNION must be wrapped in a subquery or CTE.
- Duplicate Handling:
    - UNION: Performs a distinct sort to remove duplicate rows.
    - UNION ALL: Simply appends results, preserving duplicates and improving performance.
- Sorting: A single ORDER BY can be applied at the end of the final statement.
*/

--union of left_products and right_products

select p_id,p_name from left_products
union
select p_id,p_name from right_products

insert into right_products(p_id,p_name) values
(11,'Product G')

--wee need duplicate


select p_id,p_name from left_products
union all
select p_id,p_name from right_products

--combine directors and actors

select
    first_name,
    last_name
from directors
union
select
    first_name,
    last_name
from actors

--can we use oederby
select
    first_name,
    last_name,
    'directors' as "tablename"
from directors
union
select
    first_name,
    last_name,
     'actors' as "tablename"
from actors
order by first_name asc

--cant use union on data type that are not same

--union filters

--combine all directors where nationality are american , chinese and japanese with all female actors

select
    first_name,
    last_name
from directors
where 
    nationality in ('American','Chinese','Japanese')

union

select
    first_name,
    last_name
from actors
where 
     gender = 'F'
order by first_name asc


--all actors and directors born after 1990


select
    first_name,
    last_name,
    'directors' as "tablename"
from directors
    where 
    date_of_birth > '1990-01-01'::date

union

select
    first_name,
    last_name,
    'actors' as "tablename"
from actors
    where 
    date_of_birth > '1990-01-01'::date

order by first_name asc

--select first name and last name of all directors and actors where their first name  start with 'A'

select
    first_name,
    last_name,
    'directors' as "tablename"
from directors
    where 
    first_name like 'A%'

union

select
    first_name,
    last_name,
    'actors' as "tablename"
from actors
    where 
    first_name like 'A%'

order by first_name asc

--cobine diff. no of columns

select
    first_name,
    last_name,
    date_of_birth,
    'directors' as "tablename"
from directors
    

union

select
    first_name,
    last_name,
    'actors' as "tablename"
from actors
   

order by first_name asc

--each UNION query must have the same number of columns
-- LINE 12: first_name,

--table 1 - col1,col2
--table2 - col 3

create table table1(
    col1 int,
    col2 int
)

create table table2(
    col3 int
)


--union with null

select col1,col2 from table1
union
select col3,null from table2

drop table table2
drop table table1

/*
- TOPIC 2: INTERSECT
- Purpose: Returns only the rows that are common to both SELECT statements.
- Logic: It acts like the "AND" of set operations. If a row exists in Query A AND Query B, it appears in the result.
- Duplicates: By default, INTERSECT removes duplicate rows. Use INTERSECT ALL to keep them.
- Requirements: Like UNION, both queries must have the same number of columns and matching data types.
*/

--intersect left_products and right_products

select p_id,p_name from left_products
intersect
select p_id,p_name from right_products

--we can not get duplicate records

--intersect firstname and last name

select
    first_name,
    last_name
from directors
    

intersect

select
    first_name,
    last_name
from actors
   
/*
- TOPIC 3: EXCEPT
- Purpose: Returns rows from the first SELECT statement that are NOT present in the second SELECT statement.
- Logic: It acts as a "Subtraction" operation (Query A - Query B).
- Duplicates: By default, EXCEPT returns distinct rows. Use EXCEPT ALL to keep duplicates.
- Requirements: Both queries must have the same number of columns and compatible data types.
- Order Matters: Unlike UNION or INTERSECT, the order of tables changes the result (A - B is not the same as B - A).
*/


--except left_products and right_products

select p_id,p_name from left_products
except
select p_id,p_name from right_products

-- p_id	p_name
-- 5	Product E
-- 6	Product F
-- 3	Product C
-- 4	Product D

--except directors and actors

select
    first_name,
    last_name
from directors
    

except

select
    first_name,
    last_name
from actors

--list all the directors firstname , last name unless they have the same first_name in female actors

select
    first_name,
    last_name
from directors
    

except

select
    first_name,
    last_name
from actors
where gender = 'F'

