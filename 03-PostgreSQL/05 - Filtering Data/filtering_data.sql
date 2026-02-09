/* 1. Three Types of SQL Operators
1. Arithmetic: Performs math (+, -, *, /, %).
   Syntax: SELECT price * 1.1 FROM products;
2. Comparison: Compares values (=, <>, >, <, >=, <=).
   Syntax: SELECT * FROM staff WHERE age >= 21;
3. Logical: Combines conditions (AND, OR, NOT, BETWEEN).
   Syntax: SELECT * FROM sales WHERE qty > 5 AND city = 'Delhi';
*/

/***********************************************************
* 2. AND OPERATOR
* Used to filter records that satisfy ALL specified conditions.
* Returns TRUE only if every condition is met.
* Syntax: SELECT * FROM table WHERE cond1 AND cond2;
* Example: SELECT * FROM staff WHERE dept = 'Sales' AND id > 10;
***********************************************************/

SELECT * FROM movies;

SELECT * FROM movies
WHERE
    movie_lang = 'English';

-- single quotes will work only ' '

SELECT * FROM movies
WHERE
    movie_lang = 'Japanese';

--multiple condition

SELECT * FROM movies WHERE
movie_lang = 'English' AND age_certificate = '18';

/***********************************************************
* 3. OR OPERATOR
* Filters records that satisfy AT LEAST ONE of the conditions.
* Returns TRUE if any single condition is met.
* Syntax: SELECT * FROM table WHERE cond1 OR cond2;
* Example: SELECT * FROM users WHERE city = 'London' OR city = 'Paris';
***********************************************************/

--english or japanese

SELECT 
* FROM movies 
WHERE 
movie_lang = 'English' OR 
movie_lang = 'Japanese'
ORDER BY
movie_lang;

--all eng and director_id is equal to 15

SELECT * from movies
where 
movie_lang = 'English' AND director_id = '15';

/***********************************************************
* 4. COMBINING AND & OR OPERATORS
* Uses parentheses () to group conditions and control logic flow.
* Ensures the OR logic is evaluated before the AND logic.
* Essential for complex filtering in a single WHERE clause.
* Syntax: SELECT * FROM table WHERE cond1 AND (cond2 OR cond3);
* Example: SELECT * FROM items WHERE price < 50 AND (cat='Toy' OR cat='Game');
***********************************************************/

--get all english or chinese and age 12

--without parenthesis 

SELECT * FROM movies
WHERE
movie_lang = 'English' OR
movie_lang = 'Chinese'
AND age_certificate = '12';
--will not give perfect answer

--with parenthesis 
SELECT * FROM movies
WHERE
(movie_lang = 'English' OR
movie_lang = 'Chinese')
AND (age_certificate = '12')
ORDER BY movie_lang;

/***********************************************************
* 5. POSITIONING THE WHERE CLAUSE
* Placed after the FROM clause and before GROUP BY or ORDER BY.
* It must follow the table declaration to filter rows early.
* Standard Order: SELECT -> FROM -> WHERE -> GROUP BY -> ORDER BY.
* Syntax: SELECT cols FROM table WHERE cond ORDER BY col_name;
* Example: SELECT * FROM staff WHERE age > 25 ORDER BY hire_date;
***********************************************************/

/* SYNTAX ERROR */
-- SELECT * WHERE movie_lang = 'Japanese' FROM movies;


/* SYNTAX ERROR */
-- WHERE movie_lang = 'Japanese' SELECT * FROM movies;


/***********************************************************
* 6. EXECUTION ORDER (AND & OR PRECEDENCE)
* SQL always processes AND operators before OR operators.
* To change this order, use parentheses () to group OR logic.
* Think of parentheses like math: they force certain parts first.
* Syntax: WHERE (cond1 OR cond2) AND cond3;
* Example: SELECT * FROM products WHERE (cat='Pen' OR cat='Ink') AND price < 5;
***********************************************************/

SELECT * FROM movies 
WHERE (movie_lang = 'English' OR movie_lang = 'Hindi') 
AND movie_length < 120;


SELECT * FROM movies 
WHERE movie_lang = 'English' 
OR movie_lang = 'Hindi' AND movie_length < 120;

SELECT * FROM movies 
WHERE age_certificate = 'PG' 
OR (movie_lang = 'English' AND movie_length < 90);

/***********************************************************
* 7. COLUMN ALIASES WITH WHERE CLAUSE
* You cannot use a column alias inside a WHERE clause.
* This is because WHERE is processed before SELECT in SQL logic.
* To filter, you must use the original column name instead.
* Syntax: SELECT col AS alias FROM table WHERE col = 'value';
* Example: SELECT name AS n FROM users WHERE name = 'John';
***********************************************************/

-- column aliases with where
--cant use aliases in where
SELECT first_name,
    last_name as surname 
FROM
    actors 
WHERE
    last_name = 'Allen';

/***********************************************************
* 8. EXECUTION ORDER: WHERE, SELECT, ORDER BY
* SQL processes WHERE first to filter the raw table data.
* SELECT runs second to pick and alias the specific columns.
* ORDER BY runs last to sort the final filtered results.
* This is why you can't use an alias in WHERE, but can in ORDER BY.
* Syntax: SELECT col AS a FROM tbl WHERE col > 1 ORDER BY a;
***********************************************************/

SELECT * from movies 
WHERE 
    movie_lang = 'English'
ORDER BY
    movie_length DESC;

--logical operators

--movie length greater than 100

SELECT * FROM movies
WHERE
    movie_length > 100
ORDER BY
    movie_length;

--movie length greater than or equal to 100

SELECT * FROM movies
WHERE
    movie_length >= 100
ORDER BY
    movie_length;

--movie length less than 100

SELECT * FROM movies
WHERE
    movie_length < 100
ORDER BY
    movie_length;

--movie length less than or equal to 100

SELECT * FROM movies
WHERE
    movie_length <= 100
ORDER BY
    movie_length;

--date format in postgres yyyy-mm-dd

--movies with release date after 2000

SELECT * FROM movies
WHERE
    release_date > '1999-12-31';
-- ' ' are compulsory for date 

--greater than english

SELECT * FROM movies
WHERE
    movie_lang > 'English'
ORDER BY movie_lang;

--less than english

SELECT * FROM movies
WHERE
    movie_lang < 'English'
ORDER BY movie_lang;

--non english movies

SELECT * FROM movies
WHERE 
    movie_lang <> 'English'
ORDER BY movie_lang;

--or--
SELECT * FROM movies
WHERE 
    movie_lang != 'English'
ORDER BY movie_lang;

--omit quotes using numerical data

SELECT * FROM movies
WHERE movie_length > 100;

--for numerical data we can get away without quotes but for non-numeric it is must

/***********************************************************
* 9. USING LIMIT AND OFFSET
* LIMIT: Restricts the total number of rows returned by a query.
* OFFSET: Skips a specific number of rows before starting to return.
* These are essential for creating "pagination" in applications.
* Syntax: SELECT * FROM table LIMIT [count] OFFSET [skip];
* Example: SELECT * FROM books LIMIT 10 OFFSET 20; 
* Result: Skips the first 20 books and shows the next 10.
***********************************************************/

--top 5 biggest movies length wise

SELECT * FROM movies
ORDER BY movie_length DESC
LIMIT 5;

--top 5 oldest american directors

SELECT * FROM directors
WHERE nationality = 'American'
ORDER BY date_of_birth ASC
LIMIT 5;

--top 10 youngest female actors

SELECT * FROM actors
WHERE gender = 'F'
ORDER BY date_of_birth ASC
LIMIT 10;

--top 10 most domestic profitable movies

SELECT * FROM movies_revenues
ORDER BY revenues_domestic DESC NULLS LAST
LIMIT 10;

--top 10 least domestic profitable movies
SELECT * FROM movies_revenues
ORDER BY revenues_domestic ASC NULLS LAST
LIMIT 10;

--offset will skip specific number of rows before starting to return.

--list 5 films starting from the 4th one orderby movie_id

SELECT * FROM movies
ORDER BY movie_id
LIMIT 5
OFFSET 4;

--top 5 movies after the top 5 highest domestic profit movie

SELECT * FROM movies_revenues
ORDER BY revenues_domestic DESC NULLS LAST
LIMIT 5 OFFSET 5;

/***********************************************************
* 10. USING FETCH CLAUSE
* A standard SQL alternative to LIMIT for restricting rows.
* Often used with OFFSET to skip rows and "fetch" the next set.
* It follows the ORDER BY clause for consistent results.
* Syntax: OFFSET [n] ROWS FETCH NEXT [m] ROWS ONLY;
* Example: SELECT name FROM employees ORDER BY id 
* OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;
***********************************************************/

-- get the first row of movies table

SELECT * FROM movies
FETCH FIRST 1 ROW ONLY;

--top 5 biggest movie by movie length

SELECT * FROM movies
ORDER BY movie_length DESC
FETCH FIRST 5 ROWS ONLY;

--top 5 oldest american directors

SELECT * FROM directors
WHERE nationality = 'American'
ORDER BY date_of_birth ASC
FETCH FIRST 5 ROWS ONLY;

--top 10 youngest female actor

SELECT * FROM actors
WHERE gender = 'F'
ORDER BY date_of_birth ASC
FETCH FIRST 10 ROWS ONLY;

--get first 5 movies from the 5th record onwards by long movie length

SELECT * FROM movies
ORDER BY movie_length DESC
OFFSET 4
FETCH FIRST 5 ROWS ONLY;

/***********************************************************
* 11. IN AND NOT IN OPERATORS
* IN: Checks if a value matches any value in a list or subquery.
* NOT IN: Filters out rows that match values in the list.
* It is a cleaner shorthand for multiple OR conditions.
* Syntax: SELECT * FROM table WHERE col IN (val1, val2, val3);
* Example: SELECT * FROM users WHERE country IN ('UK', 'USA', 'IN');
* Syntax: SELECT * FROM table WHERE col NOT IN (val1, val2);
***********************************************************/

--all movies in eng , chi. , and japanese

SELECT * FROM movies
WHERE movie_lang = 'English' OR
movie_lang = 'Chinese' OR
movie_lang = 'Japanese'
ORDER BY movie_lang;

--alternative

SELECT * FROM movies
WHERE movie_lang IN('English','Chinese','Japanese')
ORDER BY movie_lang;

--age is 13 and pg

SELECT * FROM movies
WHERE
    age_certificate IN('12','PG')
ORDER BY age_certificate ASC;

--movies where director_id is not 13 or 10
SELECT * FROM movies
WHERE 
    director_id NOT IN('13','10')
ORDER BY director_id;

--get all actors where actor id is not 1,2,3,4

SELECT * FROM actors
WHERE
    actor_id NOT IN(1,2,3,4)
ORDER BY actor_id;

/***********************************************************
* 12. BETWEEN AND NOT BETWEEN
* BETWEEN: Filters values within a specific range (inclusive).
* NOT BETWEEN: Filters values outside of a specific range.
* Works with numbers, text, and date data types.
* Syntax: WHERE column BETWEEN value1 AND value2;
* Example: SELECT * FROM items WHERE price BETWEEN 10 AND 50;
* Note: 'BETWEEN 10 AND 50' includes both 10 and 50.
***********************************************************/

--get all actors where birth_date between 1991 and 1995

SELECT * FROM actors 
WHERE date_of_birth BETWEEN '1991-01-01' AND '1995-12-31';

--get all the movies released between 1998 and 2002

SELECT * FROM movies
WHERE release_date BETWEEN '1998-01-01' AND '2002-12-31'
ORDER BY release_date;

--DOMESTIC REVENUE BETWEEN 100 AND 200
SELECT * FROM movies_revenues
WHERE revenues_domestic BETWEEN 100 AND 200
ORDER BY revenues_domestic ASC NULLS LAST;

--all eng. movie where length between 100 and 200

SELECT * FROM movies
WHERE 
    movie_length BETWEEN 100 AND 200
ORDER BY movie_length;

--all eng. movie where length not between 100 and 200

SELECT * FROM movies
WHERE 
    movie_length NOT BETWEEN 100 AND 200
ORDER BY movie_length;

/***********************************************************
* 13. LIKE AND ILIKE OPERATORS
* LIKE: Performs case-sensitive pattern matching using wildcards.
* ILIKE: Performs case-insensitive matching (PostgreSQL specific).
* Wildcards: % (any number of chars), _ (exactly one char).
* Syntax: WHERE column LIKE 'A%'; -- Starts with capital A
* Example: SELECT * FROM staff WHERE name ILIKE 'john%';
* Result: Returns 'John', 'JOHN', or 'john'.
***********************************************************/

--full character search

SELECT 'hello' LIKE 'hello';

--partial character search

SELECT 'hello' LIKE 'h%';

SELECT 'hello' LIKE '%e%';

SELECT 'hello' LIKE 'hell%';

SELECT 'hello' LIKE '%ll';

--single character search using '_'

SELECT 'hello' LIKE '_ello';

--checking occurrence of search using '_'

SELECT 'hello' LIKE '__ll_';

--using % and _ together

SELECT 'hello' LIKE '%ll_';

--get all actor name where first name starts with A

SELECT first_name from actors
WHERE first_name LIKE 'A%'
ORDER BY first_name;

--get all actors names where last name ending with 'a'

SELECT last_name from actors
WHERE last_name LIKE '%a'
ORDER BY last_name;

--get all first name with 5 characters only

SELECT first_name from actors
WHERE first_name LIKE '_____'
ORDER BY first_name;

--first name has l on 2nd place

SELECT first_name from actors
WHERE first_name LIKE '_l%'
ORDER BY first_name;

--like is case sensitive
--Ilike is not case sensitive

--actor name Tim

SELECT * FROM actors
WHERE 
    first_name ILIKE '%Tim%';

/***********************************************************
* 14. IS NULL AND IS NOT NULL
* Used to check for empty or missing data (NULL values).
* NULL is not zero or a space; it is the absence of a value.
* You must use IS NULL instead of = NULL to find these rows.
* Syntax: WHERE column IS NULL; -- Finds missing values
* Syntax: WHERE column IS NOT NULL; -- Finds filled values
* Example: SELECT * FROM users WHERE email IS NOT NULL;
***********************************************************/

--find list of actors with missing dob

SELECT * FROM actors
WHERE
    date_of_birth IS NULL
ORDER BY date_of_birth;

----find list of actors with missing dob or first name

SELECT * FROM actors
WHERE
    date_of_birth IS NULL OR first_name IS NULL
ORDER BY date_of_birth;

--list of movie where domestic revenues is null

SELECT * FROM movies_revenues
WHERE revenues_domestic IS NULL
ORDER BY revenues_domestic;

--either domestic or international revenues is null

SELECT * FROM movies_revenues
WHERE revenues_domestic IS NULL OR revenues_international IS NULL
ORDER BY revenues_domestic;

--both domestic and international revenues are null

SELECT * FROM movies_revenues
WHERE revenues_domestic IS NULL AND revenues_international IS NULL
ORDER BY revenues_domestic;

--domestic revenues are not null

SELECT * FROM movies_revenues
WHERE revenues_domestic IS NOT NULL
ORDER BY revenues_domestic;

--instead of null using followings


-- = NULL
SELECT * FROM actors 
WHERE date_of_birth = NULL;
--empty table 

-- = 'NULL'
-- SELECT * FROM actors WHERE date_of_birth = 'NULL';
--generate error 

-- = ''
-- SELECT * FROM actors WHERE date_of_birth = '';
--will also give error

-- = ' '
-- SELECT * FROM actors WHERE date_of_birth = ' ';
--also give error 

-- IS NULL
SELECT * FROM actors 
WHERE date_of_birth IS NULL;

/***********************************************************
* 15. CONCATENATION TECHNIQUES
* Used to join two or more strings into a single string.
* Pipe Operator (||): Standard SQL and PostgreSQL/Oracle.
* CONCAT() Function: Standard function available in most DBs.
* CONCAT_WS(): "With Separator" - adds a delimiter between strings.
* Syntax: SELECT 'Hello' || ' ' || 'World';
* Example: SELECT CONCAT(first_name, ' ', last_name) FROM staff;
***********************************************************/

--concat hello and world

SELECT 'hello' || 'world!' AS new_string;

SELECT 'hello' || ' ' || 'world!' AS new_string;

--actors first and last name

SELECT 
   CONCAT(first_name, ' ' , last_name) AS "Actor Name"
FROM actors
ORDER BY first_name;

--fname , lname and dob separated by comma

SELECT 
    CONCAT_WS(',', first_name, last_name, date_of_birth)
FROM actors
ORDER BY first_name;

/***********************************************************
* 16. NULL HANDLING IN CONCATENATION
* || Operator: Returns NULL if any part of the string is NULL.
* CONCAT(): Ignores NULLs and treats them as empty strings ('').
* CONCAT_WS(): Skips NULL values and only joins existing data.
* Logic: Use CONCAT() if you want to avoid a "hidden" NULL result.
* Example: 'Hello' || NULL  ->  Result: NULL
* Example: CONCAT('Hello', NULL) -> Result: 'Hello'
***********************************************************/

--using ||
--entire string becomes null

SELECT 'HELLO' || NULL || 'WORLD!';

-- using CONCAT -
--ignores null
SELECT
revenues_domestic,
revenues_international,
    concat(revenues_domestic, revenues_international) as profits
FROM movies_revenues;


--using CONCAT_WS()

SELECT
revenues_domestic,
revenues_international,
    concat_ws('|', revenues_domestic, revenues_international) as profits
FROM movies_revenues;