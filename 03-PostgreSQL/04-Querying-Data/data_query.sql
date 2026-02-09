---------------------Topic1----------------------------------
--select all data

SELECT *
FROM movies
SELECT *
FROM actors -- sql is case-insensitive
 ---------------------Topic2----------------------------------
 --selecting a specific column from the table
 -- select c1,c2 from tablename
 --first name

select first_name
from actors;

--first name , last name

SELECT first_name,
       last_name
FROM actors;

--movie_name , movie_lang

SELECT movie_name,
       movie_lang
FROM movies;

---------------------Topic3----------------------------------
 --Adding ALIAS TO A COLUMN NAME

SELECT *
FROM actors;

/*
select column as alias_name from tablename
*/
SELECT first_name AS FirstName
from actors;


SELECT first_name AS "First Name"
from actors;


SELECT movie_name AS "Movie Name",
       movie_lang AS "Language"
FROM movies;

--AS is optional

SELECT movie_name  "Movie Name",
       movie_lang  "Language"
FROM movies;
-- output alias.png

-- can not use '' in alias

---------------------Topic4----------------------------------
/*
Assigning column alias to an expression
*/

SELECT 
first_name,
last_name
FROM actors; 

-- || concatinating operator


SELECT 
first_name || last_name AS "Full Name"
FROM actors; 

--final vesion

SELECT 
first_name || ' ' || last_name AS "Full Name"
FROM actors; 

--output image concatinating.png
--expression without table

SELECT 2*10;

---------------------Topic5----------------------------------
/*
Using ORDERBY to sort records

Syntax:

SELECT column1, column2, ...
FROM table_name
WHERE condition
ORDER BY column_name1 [ASC | DESC], column_name2 [ASC | DESC];

*/

--sort all movies records by their release_date in ascending order

SELECT 
    *
FROM movies
ORDER BY
    release_date ASC;

--without ASC keyword
SELECT 
    *
FROM movies
ORDER BY
    release_date;

-- by default it will use ascending order

SELECT 
    *
FROM movies
ORDER BY
    release_date DESC;

-- sort based multiple columns 

SELECT 
*
FROM movies
ORDER BY
    release_date DESC,
    movie_name ASC;        

--output in orderby.png

---------------------Topic6----------------------------------
--alias with orderby 

--get fname , lname from actors table
SELECT 
    first_name,
    last_name 
FROM actors
--make an alias for lname as surname 
SELECT 
    first_name,
    last_name AS surname
FROM actors

--sort rows by lname
SELECT 
    first_name,
    last_name AS surname
FROM actors
ORDER BY last_name;

--sort by desc

SELECT 
    first_name,
    last_name AS surname
FROM actors
ORDER BY last_name DESC;
 
-- use alias in orderby 

SELECT 
    first_name,
    last_name AS surname
FROM actors
ORDER BY surname DESC;
--output in order_alias.png

---------------------Topic7----------------------------------
--orderby to sort rows by expression

--get all records of actors table


SELECT * from actors;

--calculate length of actor name with lenght function

SELECT 
    first_name,
    length(first_name) as len
FROM actors


--sort rows by  length of the actor name in descending order

SELECT 
    first_name,
    length(first_name) as len
FROM actors
ORDER BY
    len DESC 
 
-- output at exp_orderby.png

---------------------Topic8----------------------------------
--column name or column number in orderby clause

--get all records of actors

SELECT * FROM actors

--sort all records by first_name asc , date_of_birth descending

SELECT * FROM actors
ORDER BY 
    first_name ASC,
    date_of_birth DESC;

--using column number instade of column name for sorting 

SELECT 
    first_name,
    last_name,
    date_of_birth
FROM  actors
ORDER BY
    1 ASC,
    3 DESC

--output at num_with_orderby.png

---------------------Topic9----------------------------------
--using orderby with null values

/*
null indicates missing or null values 
can be seen on exp_orderby.png

using nullfirst or nulllast

Syntax:

SELECT column1, column2, ...
FROM table_name
WHERE condition
ORDER BY column_name1 [ASC | DESC][NULLS FIRST | NULLS LAST];
*/


CREATE TABLE demo_sorting(
num INT
);

--inserting values

INSERT INTO demo_sorting(num)
VALUES
(1),
(2),
(3),
(NULL);

SELECT * FROM demo_sorting;

--sort by asc

SELECT * FROM demo_sorting 
ORDER BY num ASC;

SELECT * FROM  demo_sorting ORDER BY num NULLS LAST;


--null first

SELECT * FROM  demo_sorting ORDER BY num DESC NULLS LAST;
--output at null_orderby.png
--descending will put null at first unless you state NULLS LAST


---------------------Topic10----------------------------------
--selecting distinct values

--get all values of movies table

SELECT * FROM movies;

--get movie_lang

SELECT movie_lang from movies;

--get unique movie_lang

SELECT 
    DISTINCT movie_lang 
from movies
ORDER BY 1;
--output at distinct.png

--get movie lang and dirctor id
SELECT 
    DISTINCT director_id , movie_lang
from movies
ORDER BY 2;

--get all unique records in movies

SELECT DISTINCT * from  movies ORDER BY movie_id ASC;