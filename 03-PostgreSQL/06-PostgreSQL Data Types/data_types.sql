/***********************************************************
* 1. POSTGRES DATA TYPES: BOOLEAN
* Stores logical values: TRUE, FALSE, or NULL (unknown).
* Valid Inputs for TRUE: 'true', 'yes', 'on', '1', 't', 'y'.
* Valid Inputs for FALSE: 'false', 'no', 'off', '0', 'f', 'n'.
* Usage: Best for "flags" like is_active, has_paid, or verified.
* Example: SELECT * FROM users WHERE is_active = 'true';
***********************************************************/

--sample table

CREATE TABLE bool_table(
    product_id SERIAL PRIMARY KEY,
    is_available BOOLEAN NOT NULL
);

--insert data

INSERT INTO bool_table (is_available) VALUES 
    ('true'), ('yes'), ('on'), ('1'), ('t'), ('y'), 
    ('false'), ('no'), ('off'), ('0'), ('f'), ('n'); 
SELECT * FROM bool_table;

-- all true values

SELECT * FROM bool_table
WHERE is_available = TRUE

--false values

SELECT * FROM bool_table
WHERE is_available = FALSE

--using not
SELECT * FROM bool_table
WHERE NOT is_available 

--default value for 

ALTER TABLE bool_table
ALTER COLUMN is_available
SET DEFAULT FALSE

--testin it

INSERT INTO bool_table (product_id) VALUES (15)

SELECT * FROM bool_table;

--by default false was inserted in case of no value provided

/***********************************************************
* 2. CHARACTER DATA TYPES: CHAR, VARCHAR, AND TEXT
* CHAR(n): Fixed length. Pads with spaces if the string is shorter.
* VARCHAR(n): Variable length with a limit. No padding.
* TEXT: Variable length with no limit. Best for long descriptions.
* Performance: In PostgreSQL, there is no performance difference
* between these three; TEXT or VARCHAR is usually preferred.
* Syntax: column_name VARCHAR(255);
***********************************************************/

--implementation of character
SELECT CAST('Jay' AS character(10)) as "Name";
--if more truncate if less add space 
--default length is one if not provided
SELECT 'Jay'::char(10) as "Name";

SELECT 
    CAST('Jay' AS character(10)) as "Name1",
    'Jay'::char(10) as "Name2";

--varchar , no default value

SELECT 'Jay'::VARCHAR(10);

SELECT 'This is a test for the system'::VARCHAR(10);


--text no fixed size its about 1GB
SELECT 'This is a massive paragraph. I can type as much as I want here without worrying about a character limit. PostgreSQL treats the TEXT type as a variable-length string with no specific upper bound other than the 1GB limit.'::TEXT;



--create a table of all type of char

CREATE TABLE table_char(
    col_char CHAR(10),
    col_varchar VARCHAR(10),
    col_text TEXT
);

SELECT * FROM table_char;

INSERT INTO table_char(col_char,col_varchar,col_text) VALUES
('ABC','ABC','ABC'),
('xyz','xyz','xyz')

SELECT * FROM table_char;

/***********************************************************
* 3. NUMERIC DATA TYPES
* INTEGER: Whole numbers (e.g., 1, 100, -5).
* NUMERIC/DECIMAL: Exact numbers (e.g., money). Best for precision.
* REAL/DOUBLE: Floating-point (approximate) for scientific data.
* SERIAL: Auto-incrementing integers (used for Primary Keys).
* Syntax: price NUMERIC(10, 2); -- 10 total digits, 2 after decimal.
***********************************************************/    

/*
-  INTEGER RANGES (SMALLINT vs INT vs BIGINT)
- SMALLINT: 2 bytes. Range: -32,768 to +32,767.
- INTEGER:  4 bytes. Range: -2.1B to +2.1B (Most common).
- BIGINT:   8 bytes. Range: -9 quintillion to +9 quintillion.
- Note: Use SMALLINT to save space for tiny lists, 
- and BIGINT for massive datasets (like Global IDs).
*/

--create a table for integer
CREATE TABLE table_serial(
    col_serial SERIAL PRIMARY KEY,
    product_name VARCHAR(20) NOT NULL
)

--insert data
INSERT INTO table_serial(product_name) VALUES
('pen');

SELECT * FROM table_serial;

INSERT INTO table_serial(product_name) VALUES
('book'),
('pencil'),
('eraser');

SELECT * FROM table_serial;

/*
- TOPIC 4: THE DECIMAL DATA TYPE
- Purpose: Stores exact numbers with fixed precision.
- Use Case: Always used for money and accounting.
- Syntax: DECIMAL(precision, scale).
- Precision: Total number of digits allowed.
- Scale: Number of digits after the decimal point.

floating point numbers
two types are:
real : allows precision to six decimal digits
double precision : allows precision to 15 decimal digits

*/


--number table creation
CREATE TABLE number_table(
    col_numeric NUMERIC(20,5),
    col_real REAL,
    col_double DOUBLE PRECISION
);
SELECT * FROM number_table;

--insert data in numric_data

INSERT INTO number_table(col_numeric,col_real,col_double) VALUES
(123456789.12345,123456789.12345,123456789.12345),
(1.1234567890123456789,1.1234567890123456789,1.1234567890123456789);


SELECT * FROM number_table;

/*
- TOPIC 5: STORAGE COST OF NUMERIC TYPES
- SMALLINT: 2 bytes - Smallest footprint for limited ranges.
- INTEGER: 4 bytes - Balanced performance and storage.
- BIGINT: 8 bytes - Higher cost, used only when necessary.
- DECIMAL: Variable - 5 to 8 bytes or more (Highest storage cost).
- REAL/DOUBLE: 4 or 8 bytes - Fixed cost for approximate values.
- Rule: Choose the smallest type that safely fits your data to optimize disk space and speed.
*/




/*
- TOPIC 6: DATE AND TIME DATA TYPES
- DATE: Stores calendar dates (year, month, day).
- TIME: Stores the time of day without a date.
- TIMESTAMP: Stores both date and time together.
- TIMESTAMPTZ: Timestamp that includes time zone offset (Best practice).
- INTERVAL: Stores a period of time (e.g., '3 days 4 hours').
*/

--create table
CREATE TABLE date_time_table(
    col_date DATE,
    col_time TIME,
    col_timestamp TIMESTAMP,
    col_timestamptz TIMESTAMPTZ,
    col_interval INTERVAL
);

SELECT * FROM date_time_table;

--insert data
INSERT INTO date_time_table(col_date, col_time, col_timestamp, col_timestamptz, col_interval) VALUES
    ('2023-01-15', '14:30:00', '2023-01-15 14:30:00', '2023-01-15 14:30:00+05:30', '1 year 2 months 3 days 4 hours 5 minutes 6 seconds');

SELECT * FROM date_time_table;

--delete table
DROP TABLE date_time_table;

--DATE 4bytes yyyy-mm-dd
--CURRENT_DATE 

CREATE TABLE table_date(
     id serial PRIMARY KEY,
     employee_name VARCHAR(100) not null,
     hire_date DATE NOT NULL,
     add_date DATE NOT NULL DEFAULT CURRENT_DATE
);

--insert data

INSERT INTO table_date(employee_name,hire_date) VALUES
('Jay', '2023-01-01'),
('Aayushi','2024-07-21')

SELECT * FROM table_date;

--current date

SELECT CURRENT_DATE;

--date & time

SELECT NOW();



-------time----------

--8 bytes c_name TIME(PRECISION) 
--seconds fields
--common formates
/*
HH:MM
HH:MM:SS
HHMMSS

MM:SS.pppppp
HH:MM:SS.pppppp
HHMMSS.pppppp
*/

--create a table
create table table_time(
    id SERIAL PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

--insert data
INSERT INTO table_time(class_name, start_time, end_time) VALUES
('Math', '09:00:00', '10:00:00'),
('Science', '10:30:00', '11:30:00');

--select data
SELECT * FROM table_time;

--current time
SELECT CURRENT_TIME;


--current time with precision
SELECT CURRENT_TIME(2);

--use local time
SELECT LOCALTIME;

--arithmatic operations

select time '10:00'-time'01:00' as result;

--interval

select current_time + interval'2 hours 30 minutes'as result;
select current_time - interval'2 hours 30 minutes'as result;


--timestamp and timestamptz
--timestamp without timezone
--timestamptz   with timezone


--create table
CREATE TABLE table_timestamp(
    event_timestamp TIMESTAMP,
    event_timestamptz TIMESTAMPTZ
);

--insert data
INSERT INTO table_timestamp(event_timestamp, event_timestamptz) VALUES
('2023-01-15 10:00:00', '2023-01-15 10:00:00+05:30'),
('2023-01-15 10:00:00', '2023-01-15 10:00:00-08:00');

SELECT * FROM table_timestamp;

--check timezone

SHOW TIMEZONE;

--set timezone

SET TIMEZONE = 'America/New_York';

SELECT * FROM table_timestamp;

--set timezone to UTC

SET TIMEZONE = 'UTC';

SELECT * FROM table_timestamp;

--set timezone to Asia/Kolkata

SET TIMEZONE = 'Asia/Kolkata';

SELECT * FROM table_timestamp;


--cuurent timestamp

SELECT CURRENT_TIMESTAMP;

--current time of the day
select timeofday();

--using timezone() function to convert time based on a time zone


SELECT timezone('America/New_York', CURRENT_TIMESTAMP);

/*
- TOPIC 7: UUID DATA TYPE
- Definition: Universally Unique Identifier (128-bit number).
- Format: Represented as 32 hexadecimal digits (e.g., a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11).
- Advantage: More secure than SERIAL as IDs cannot be easily guessed.
- Scaling: Better for distributed systems where different servers generate IDs simultaneously.
- Usage: Requires the "uuid-ossp" extension for generating values automatically.
*/

--enable the uuid-ossp extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


--sample uuid generation

SELECT uuid_generate_v4();
"f9792377-46dc-4f2d-aa49-41f7e5bc5e72"

SELECT uuid_generate_v1();
"99f9d200-f5cf-11f0-aa4a-57cab325d349"


--create a table with uuid as primary key
CREATE TABLE products_uuid (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

--insert data
INSERT INTO products_uuid (product_name, price) VALUES
('Laptop', 1200.00),
('Mouse', 25.00);

select * from products_uuid;


/*
- TOPIC 8: ARRAY DATA TYPE
- Definition: Allows columns to store a list of multiple values.
- Syntax: Use square brackets or the ARRAY keyword (e.g., INTEGER[] or TEXT[]).
- Access: Uses 1-based indexing (e.g., column[1] gets the first element).
- Functions: Supports operations like unnest (to expand) and array_agg (to combine).
- Usage: Good for storing small, fixed sets of related data like tags or phone numbers.
*/

--create a table with array

CREATE TABLE products_array (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    tags TEXT[]
);

--insert data
INSERT INTO products_array (product_name, tags) VALUES
('Laptop', ARRAY['electronics', 'computer', 'portable']),
('Mouse', '{electronics, peripheral, input}');

SELECT * FROM products_array;

select 
    product_name,
    tags[1] as first_tag
from products_array;
    
select 
    product_name
from 
    products_array
where
    tags[2] = 'peripheral';


/*
- TOPIC 9: HSTORE DATA TYPE
- Definition: A key-value store within a single PostgreSQL column.
- Structure: Stores data as sets of "key" => "value" pairs.
- Requirement: Must be enabled using the command 'CREATE EXTENSION hstore;'.
- Data Type: Both keys and values are stored as strings (text).
- Querying: Supports specialized operators to check for specific keys or values.
- Comparison: Precursor to JSONB; still useful for simple, flat key-value pairs.
*/

--enable the hstore extension
CREATE EXTENSION IF NOT EXISTS hstore;

--create a table with hstore
create table table_hstore(
    book_id serial primary key,
    title varchar(100) not null,
    book_info hstore not null 
);

--insert values

INSERT INTO table_hstore (title, book_info) VALUES 
(
    'The Great Gatsby', 
    '"author"=>"F. Scott Fitzgerald", "genre"=>"Classic", "year"=>"1925"'
),
(
    '1984', 
    '"author"=>"George Orwell", "genre"=>"Dystopian", "year"=>"1949"'
);

--query data

select * from table_hstore;

--accessing values
select book_info -> 'author' from table_hstore;
select book_info -> 'genre' from table_hstore;

/*
- TOPIC 10: JSON AND JSONB DATA TYPES
- JSON: Stores data as an exact copy of the input text (requires re-parsing).
- JSONB: Stores data in a decomposed binary format (faster to process).
- Indexing: JSONB supports GIN indexing, making queries significantly faster.
- Flexibility: Allows storing nested objects and arrays without a fixed schema.
- Selection: Use JSONB for almost all cases unless you need to preserve exact white space.
*/

--create a table with json and jsonb
create table table_json(
        product_id serial primary key,
        product_name varchar(100) not null,
        product_info json not null,
        product_info_jsonb jsonb not null
);


select * from table_json;

--insert data
insert into table_json(product_name,product_info,product_info_jsonb) values
('Laptop', '{"color": "silver", "weight": "1.5kg"}', '{"color": "silver", "weight": "1.5kg"}'),
('Mouse', '{"color": "black", "wireless": true}', '{"color": "black", "wireless": true}'),
('Keyboard', '{"type": "mechanical", "backlit": false}', '{"type": "mechanical", "backlit": false}');

--result
select * from table_json;

--query specific data from json and jsonb using -> operator
select product_info -> 'color' as color_json from table_json;
select product_info_jsonb -> 'color' as color_jsonb from table_json;

create index on table_json using gin(product_info_jsonb jsonb_path_ops);


select * from table_json 
where 
product_info_jsonb @> '{"color": "black"}'



/*
- TOPIC 11: NETWORK ADDRESS TYPES
- CIDR: Stores IPv4 and IPv6 networks (network bits must be zero). 7-19 bytes.
- INET: Stores IPv4 and IPv6 hosts and networks (most commonly used). 7-19 bytes
- MACADDR: Stores 6-byte MAC addresses (hardware identifiers). 6 bytes
- MACADDR8: Stores 8-byte MAC addresses (EUI-64 format). 8 bytes
- Benefits: Validates input and provides specialized sorting and operators.
*/


--sample ip table
create table table_ipaddr(
    col_cidr CIDR,
    col_inet INET,
    col_macaddr MACADDR,
    col_macaddr8 MACADDR8
);

select * from table_ipaddr;

--insert data



insert into table_ipaddr(col_cidr,col_inet,col_macaddr,col_macaddr8) values
('192.168.1.0/24','192.168.1.10','00:11:22:33:44:55','00:11:22:33:44:55:66:77'),
('10.0.0.0/8','10.0.0.1','AA:BB:CC:DD:EE:FF','AA:BB:CC:DD:EE:FF:00:11');


select * from table_ipaddr;

--lets analyze entries for /24 networks to ip addr.
--set_masklen func: set netmask length for inet value 

SELECT 
    col_inet AS original_ip,
    set_masklen(col_inet, 24)::cidr AS network_24_group
FROM table_ipaddr;


--inet to cidr
SELECT 
    col_inet AS original_ip,
    set_masklen(col_inet, 24)::cidr AS network_24_group
FROM table_ipaddr;

--we can also do it for /27 and /28

SELECT 
    col_inet AS original_ip,
    set_masklen(col_inet, 24)::cidr AS network_24_group,
    set_masklen(col_inet, 27)::cidr AS network_24_group,
    set_masklen(col_inet, 28)::cidr AS network_24_group
FROM table_ipaddr;