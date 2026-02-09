---------------------Topic 1: Type Conversion---------------------
/*
two types of conversion --> automatic
implicit & explicit --> manually
*/

--implicit conversion string to int 
select * from movies
where movie_id = '1';

--no need for conversion
select * from movies
where movie_id = 1;

--explicit conversion
select * from movies
where movie_id::int = 1;


---------------------Topic 2: CAST Function---------------------
/*
- Purpose: Converts a value from one data type to another.
- Standard Syntax: CAST(expression AS target_type).
- PostgreSQL Shortcut: expression::target_type (e.g., '10'::INTEGER).
- Common Use: Converting text to numbers or timestamps for calculations.
- Limitation: Conversion fails if the source value is incompatible with the target type.

  COMMON TYPES FOR CASTING
- TEXT / VARCHAR: Can be cast to almost any type if formatted correctly.
- INTEGER / BIGINT: Often cast to DECIMAL for precise division.
- DECIMAL / NUMERIC: Cast to INTEGER to truncate decimals.
- DATE / TIMESTAMP: Cast to TEXT for formatting or DATE for stripping time.
- BOOLEAN: Can be cast from specific strings ('1', 'true', 'y') or integers.
- JSONB: Often cast to TEXT or specific types when extracting values.
*/


--string to integer
select 
    cast('10' as integer);

--test error handling
/*
select 
    cast('10n' as integer)
    
Started executing query at Line 41
invalid input syntax for type integer: "10n"
LINE 2: cast('10n' as integer)
^
Total execution time: 00:00:00.007
*/

--string to date

select 
    cast('2020-01-01' as date),
    cast('01-may-2023' as date);


--string to boolean

select 
    cast('true' as boolean),
    cast('false' as boolean),
    cast('T' as boolean),
    cast('F' as boolean);


select 
    cast('0' as boolean),
    cast('1' as boolean);

--string to double 
 select 
    cast('10.4748' as double precision);

---------------------Topic 3: Casting Operator---------------------
-- In PostgreSQL, :: is the Casting Operator (not Scope Resolution)
select
    '10'::int,
    '2020-01-01'::date,
    'true'::boolean,
    '10.4748'::double precision;

---------------------Topic 4: Interval Casting---------------------
--string to timestamp

select 
    '2023-01-01 10:30:00'::timestamp,
    '2023-01-01 10:30:00+05:30'::timestamptz;

--string to interval
select 
    '10 minute'::interval,
    '4 hour'::interval,
    '1 day'::interval,
    '2 week'::interval,
    '1 month'::interval,
    '1 year'::interval;



---------------------Topic 5: Implicit vs. Explicit---------------------
/*
- Implicit: Automatic conversion by PostgreSQL.
- Explicit: Forced conversion by the user using CAST() or the :: operator.
- Safety: Explicit casting prevents "operator does not exist" errors in complex queries.
*/

--using integer and factorial

select factorial(20);

select factorial(20) as "result";

--explicit 
select cast(factorial(20) as bigint) as "result";

--round with numeric 

select round(10,4) as "result";

select cast(round(10,4) as numeric) as "result";

---------------------Topic 6: Functional Casting---------------------
--cast with text

select substr('123456',2) as "result";

select
    substr('123456',2) as "result",
    substr(cast('123456' as text),2) as "result";

---------------------Topic 7: Table Conversion---------------------
/*
- Syntax: ALTER TABLE table_name ALTER COLUMN col_name TYPE new_type.
- Explicit Using: Requires USING clause if data isn't automatically compatible.
- Example: ALTER COLUMN age TYPE INTEGER USING age::integer.
*/

create table rating(
    rating_id serial primary key,
    rating_value varchar(1) not null
);

select * from rating;

insert into rating
(rating_value)
values
('A'),
('B'),
('C'),
('D');

--mix of alpha and numeric strings
insert into rating
(rating_value)
values
('1'),
('2'),
('3'),
('4');

select * from rating;

--Convert strings to integers using cast inside a CASE statement
--Uses regex to ensure only numeric strings are casted
SELECT 
    rating_id,
    CASE
        WHEN rating_value ~ E'^\\d+$' THEN 
           CAST(rating_value AS integer)
        ELSE
           0
    END AS rating 
FROM 
    rating;