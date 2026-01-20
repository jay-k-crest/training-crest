
-- creating a table 
-- customer_id , first_name , last_name , email ,age 

CREATE TABLE customers(
customer_id SERIAL PRIMARY KEY,
first_name VARCHAR(150),
last_name VARCHAR(150),
email VARCHAR(150),
age INT
);

-- check table structure
SELECT * from customers


-- insert data into table 
INSERT INTO customers(first_name, last_name, email, age) VALUES('jay', 'kalsariya', 'jay.k@skillserve.com', 20);

--inset multiple records in a table

-- we seprate them with comma

INSERT INTO customers(first_name, last_name) VALUES
('abc','xyz'),
('def','jhg'),
('tyu','aby');

SELECT * from customers;


--insert data with quotes
--wrap with additional quotes 

INSERT INTO customers (first_name)
VALUES
('Bill O''Reilly')

SELECT * from customers

--use returning to get info on returns rows

INSERT INTO customers(first_name)
VALUES ('harsh')

INSERT INTO customers (first_name) VALUES
('MADHAV') RETURNING *;

--only single entity


INSERT INTO customers (first_name) VALUES
('MADHAV') RETURNING customer_id;

--update data in a table

-- UPDATE tablename
-- SET columnname = 'xyz'
-- WHERE columnname = 'abc'

SELECT * from customers

UPDATE customers 
SET email = 'madhav@enacton.com'
WHERE customer_id = 7

SELECT * from customers

UPDATE customers 
SET email = 'madhav@enacton.com',
age=70
WHERE customer_id = 8

SELECT * from customers

--updating row and returning it 

SELECT * from customers

UPDATE customers 
SET email = 'madhav@enacton.com'
WHERE customer_id = 2

SELECT * from customers

UPDATE customers 
SET email = 'madhav@enacton.com'
WHERE customer_id = 3
RETURNING *;

--updating all records in table at once 

SELECT * from customers

ALTER TABLE customers
ADD COLUMN is_enabled BOOLEAN;

UPDATE customers
SET is_enabled = TRUE;

SELECT * from customers

--delete data from table 

SELECT * from customers

DELETE FROM customers
WHERE customer_id = 6

SELECT * from customers

--delete from customers will delete all data and keep only strcuture 
DELETE from customers;

SELECT * from customers


--using upsert 

-- INSERT INTO tablename column_list
-- values()
-- on CONFLICT target ACTION

CREATE TABLE t_tags(
    id serial PRIMARY KEY,
    tag TEXT UNIQUE,
    update_date TIMESTAMP DEFAULT NOW()
);

INSERT INTO t_tags(tag) VALUES
('pen'),
('pen1'),
('pencil')


SELECT * from t_tags
-- 2026-01-16 17:31:04.936146


INSERT INTO t_tags(tag) VALUES
('pen') 
ON CONFLICT (tag) 
DO 
   NOTHING;


SELECT * from t_tags

INSERT INTO t_tags(tag) VALUES
('pen') 
ON CONFLICT (tag) 
DO 
   UPDATE SET   
   tag = excluded.tag,
   update_date = NOW();

SELECT * from t_tags




