--grouping records by groupby

/*
select
    aggragate
from table
group by column name

*/

select 
    movie_lang,
    count(movie_lang)
from movies
    group by movie_lang
    order by 2 desc;

--abg movie length by lenguage
select 
    movie_lang,
    avg(movie_length)
from movies
    group by movie_lang
    order by 2

--total movie length for each age_certificate

select 
    age_certificate,
    sum(movie_length)
from movies
    group by age_certificate
    order by 2 desc
--minimum abd maximun movie length by language

select 
    movie_lang,
    min(movie_length),
    max(movie_length)
from movies
    group by movie_lang
    order by 2

--groupby without aggragete 
select 
    movie_lang
from movies
    group by movie_lang
    order by 1
--it removes duplicate values from result

--groupby with multiple column

--can we use column1, aggragate func without groupby

select 
    movie_lang,
    min(movie_length),
    max(movie_length)
from movies
    -- group by movie_lang
    order by 2

--column "movies.movie_lang" must appear in the GROUP BY clause or be used in an aggregate function

--avg movie length by lang and age_certificate

select 
    movie_lang,
    age_certificate,
    avg(movie_length)
from movies
    group by movie_lang,age_certificate
    order by 1,2


--avg movie length by lang and age_certificate where length >100

select 
    movie_lang,
    age_certificate,
    avg(movie_length)
from movies
    where movie_length>100 
    group by movie_lang,age_certificate
    order by 1,2


--avg movie length by lang and age_certificate where length =10

SELECT 
    movie_lang,
    age_certificate,
    AVG(movie_length)
FROM movies
WHERE age_certificate = '18'
GROUP BY movie_lang, age_certificate
ORDER BY 1, 2;


--cant put where clause after groupby

--how many director from each country

select
    nationality,
    count(nationality)
from directors
    group by nationality
    order by 2 desc

--total sum movie length for each age cerificate and movuie language combination

select 
    age_certificate,
    movie_lang,
    sum(movie_length)
from movies
    group by age_certificate,movie_lang
    order by 1,2

--order of execution 
from
WHERE
group by
having
select
distinct
orderby

--using having

--list movies labguage where titak length of movies is greater than 200
--works on aggragate function


select 
    movie_lang,
    sum(movie_length)
from movies
    group by movie_lang
    having sum(movie_length)>200
    order by 2 desc

--directors where sum total movie >200
SELECT
    director_id,
    sum(movie_length)
from movies
    GROUP BY director_id
    having sum(movie_length)>200
    order by 2 desc

--column alias with having
select 
    movie_lang,
    sum(movie_length) as "totallength"
from movies
    group by movie_lang
    -- having totallength>200
    order by 2 desc
-- will generate error

--order execution of having

FROM
where
GROUP BY
having
select
distinct
orderby
limit

--having vs where
--having filters result data on aggragate
--where filters input data on select 

--movie lang where sum of total movie length is>200

SELECT 
    movie_lang,
    SUM(movie_length)
FROM movies
GROUP BY movie_lang
having SUM(movie_length)>200
ORDER BY 2 desc



SELECT 
    movie_lang,
    SUM(movie_length)
FROM movies
GROUP BY movie_lang
-- where SUM(movie_length)>200
ORDER BY 2 desc
--will generate error

--Handling NULL values with GROUP BY

create table employee_test(
    emp_id serial primary key,
    emp_name varchar(100),
    dept varchar(100),
    salary int
);

select * from employee_test

--insert some test data that include null
insert into employee_test(emp_name,dept,salary)
values
    ('John Doe','HR',45000),
    ('Jane Smith','Finance',55000),
    ('Bob Johnson','HR',50000),
    ('Alice Brown','IT',52000),
    ('Mike Wilson','Finance',58000),
    ('Sara Davis',NULL,60000),
    ('Tom White','HR',NULL),
    ('Emily Clark',NULL,NULL);

select * from employee_test

--display all dpet
select dept from employee_test

--how many employee in each group
select 
    dept,
    count(emp_id)
from employee_test
    group by dept
    order by 2 desc

---handle null values

--coalesce(source,0)

select 
     coalesce(dept,'No Department') as department,
    count(emp_id)
from employee_test
    group by dept
    order by 2 desc