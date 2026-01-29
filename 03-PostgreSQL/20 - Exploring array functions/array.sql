--arrays 
--[] closed range
--() open range

SELECT
int4range(1,6) as "DEFAULT [( =closed -opened",
NUMRANGE (1.4213,6.2986,'[]') AS "[] closed-closed",
DATERANGE ('20200101','20201220','()') as "dates () = opened-opened",
tsrange(LOCALTIMESTAMP,LOCALTIMESTAMP+INTERVAL '8 days','(]') as "opened-closed"

--array defination

SELECT
    array[1,2,3] as "INT arrays",
    ARRAY[2.12225::float] as "float with explicit type cast",
    ARRAY[current_date,current_date+5]

--usinf operators
--####################

--comparison operators
-- = , < , > , <= , >=

SELECT
    array[1,2,3,4] = array[1,2,3,4] as "equality",
    array[1,2,3,4] = array[2,3,4] as "equality",
    array[1,2,3,4] <> array[2,3,4,5] as "not equal to ",
    array[1,2,3,4] < array[2,3,4,5] as "less than",
    array[1,2,3,4] <= array[2,3,4,5] as "less than or equal to",
    array[1,2,3,4] > array[2,3,4,5] as "greater than",
    array[1,2,3,4] >= array[2,3,4,5] as "greater than or equal to"

--a shorter array considered to be less than a longer array!!

--for ranges
select
INT4RANGE(1,4) @> int4range(2,3) as "contains",
DATERANGE(CURRENT_DATE,CURRENT_DATE+30) @> CURRENT_DATE+15 as "contains value",
numrange(1.6,5.2) && NUMRANGE(0,4)


--inclusion operators
--@> , <@ , &&
SELECT
    array[1,2,3,4] @> array[2,3,4]  as "contains",
    array['a','b'] <@ array['a','b'] as "contained by",
    array[1,2,3,4] && array[2,3,4] as "is overlapped by"

--array construction

--using ||

SELECT  
    array[1,2,3] || ARRAY[4,5,6] as "combine array"

SELECT
    array_cat(array[1,2,3],array[4,5,6]) as "combine array via array_cat"

--add item to array
SELECT
    4 || array[1,2,3] as "adding with pipe operator"

SELECT
    array_prepend(4,array[1,2,3]) as "using prepend"

SELECT
    array_append(array[1,2,3],4) as "using append"

--array metadata functions

SELECT
    array_ndims(array[[1,2,3],[4,5,6]]) as "dimensions"

--array_dim

SELECT
    array_dims(array[[1,2,3],[4,5,6]]) as "dimensions"
--[1:2][1:3]

--array length

SELECT  
    array_length(ARRAY[1,2,3,4],1) as "lenght"

--lower bound using array_lower

SELECT
    array_lower(ARRAY[1,2,3,4],1) as "lower bound"

--upper bound using array_upper

SELECT
    array_upper(ARRAY[1,2,3,4],1) as "upper bound"

--cardinality
select
cardinality(ARRAY[[1, NULL, NULL], [2, 3, NULL], [4, 5, 6]]),
cardinality(ARRAY[1,2,3,4,5,6])

--array search functions

--array_position

--first ocuurance only
SELECT
    array_position(array['jan','feb','march','april'],'march')

SELECT
    array_position(array[1,2,3,4],3)

--array index start with 1 in postgre

--for multiple values

--array_positions

select
    array_positions(array['jan','feb','march','april','march'],'march')
--{3,5}

select
    array_positions(array[1,2,3,4,3],3)
--{3,5}


--array modification functions
--using array_cat
SELECT
    array_cat(array[1,2,3],array[4,5,6]) as "modify array via array_cat"

SELECT
    array_append(array[1,2,3],4) as "modify array using append"

SELECT
    array_prepend(4,array[1,2,3]) as "modify array using prepend"

--remove
select
    array_remove(array['jan','feb','march','april'],'march')

--replace
select
    array_replace(array['jan','feb','march','april','march'],'march','may')

--array comparison with in , all , any & some

select
 20 in (1,2,9,20) as "result"

--not in

select
 20 not in (1,2,9,20) as "result"
--false

--all operator

select
    25 = all(array[20,25,30,35,40]) as "result"
--true

--any/some operator

select
    25 = any(array[20,25,30,35,40]) as "result"

select
    25 <> any(array[20,25,30,35,null]) as "!= any with nulls" 

select
    25 = some(array[20,25,30,35,null]) as "= some with nulls" 

--formatting and coverting array

--str to array

select
    string_to_array('1,2,3,4',',') as "string to array"

select
    string_to_array('1,2,3,4,ABC',',','ABC')
--null value

--empty value to null value

select
    string_to_array('1,2,3,4,,6',',','')

--array tp string

select
    array_to_string(array[1,2,3,4,5],'|')   as "array to str"

--null to other values

select
     array_to_string(array[1,2,3,4,null,5],'|','empty data')

--using arrays in table

create table teachers (
    t_id serial primary key,
    t_name varchar(100) not null,
    phones text []
    
)

--or
create table teachers1 (
    t_id serial primary key,
    t_name varchar(100) not null,
    phones text array
    
)

--insert data into arrays
--method 1
insert into teachers (t_name , phones) values
(
    'jay', array['(455)-111-2222','(454)-244-5456']
)

-- method 2
insert into teachers (t_name , phones) values
(
    'ABC','{"(111)-222-3333"}'
),
(
    'BCD','{"(222)-333-4444","(333)-444-5555"}'

)

--find all phone records

select t_name,phones from teachers

--all data

select * from teachers

--specific element

select
    t_name,
    phones[1]
from 
    teachers

select
    t_name,
    phones[2]
from 
    teachers

--filter condition

select
    t_name,
    phones
from 
    teachers
where
    phones[1]='(111)-222-3333'

--any array for all rows

select
   *
from 
    teachers
where
    '(111)-222-3333' = any(phones)

--modify array content

update teachers
set phones[2] = '(555)-666-7777'
where
    t_id = 2;

select * from teachers where t_id = 2;

--array dimensions are ignored
--so if we define any array with fixed size postgree will ignore it 
-- phones text array is same as phones text array[n]
-- the n is ignored


--display all array elements
--using the unset function

select
t_id,
t_name,
unnest(phones)
from
teachers

--use orderby 

select
t_id,
t_name,
unnest(phones)
from
teachers
order by
phones

--using multidimensional array

create table students (
    student_id serial primary key,
    student_name varchar(100),
    student_grade integer[][]
)

insert into students (student_name,student_grade) values
('s1','{90,2020}')

select * from students

--insert multiple input data

insert into students (student_name,student_grade) values
('s2','{{80,2021},{70,2022}}')

-- add more data

insert into students (student_name,student_grade) values
('s3','{80,2020}'),
('s4','{80,2021}'),
('s5','{80,2023}')

select student_grade[1] from students
select student_grade[2] from students

--all student with grade year @>2020

select * from students where student_grade @> array[2020]
select * from students where 2020 = any(student_grade)

--all student with grade >80

select * from students where student_grade[1] > 80

--array vs jsonb

/*******************************************************************************
 * COMPARISON: SQL NATIVE ARRAY VS. JSON/JSONB
 * ---------------------------------------------------------------------------
 * FEATURE          | NATIVE ARRAY              | JSON / JSONB
 * ---------------- | ------------------------- | ----------------------------
 * Schema           | Strict (single type)      | Flexible (mixed types)
 * Nested Data      | Multidimensional only     | Deeply nested objects/lists
 * Indexing         | GIN (full array search)   | GIN (key/path specific)
 * Performance      | Fast for simple lists     | Slightly slower (parsing req)
 * Portability      | Low (DB specific)         | High (standard format)
 ******************************************************************************/

-- Example Usage:
-- SELECT array_column[1] FROM table; -- Native Array (1-indexed)
-- SELECT json_column->>'key' FROM table; -- JSONB (Key-based)


