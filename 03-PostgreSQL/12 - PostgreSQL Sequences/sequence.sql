/*
- TOPIC: SEQUENCES
- Purpose: A sequence is a special kind of database object that generates a sequence of unique integers.
- Common Use: Powering Primary Keys (often implicitly used by the SERIAL or IDENTITY types).
- Persistence: Sequences are independent of tables and transactions; incrementing a sequence cannot be rolled back.
- Main Functions:
    - NEXTVAL('seq_name'): Increments the sequence and returns the new value.
    - CURRVAL('seq_name'): Returns the value most recently obtained by NEXTVAL in the current session.
    - SETVAL('seq_name', value): Resets the sequence to a specific number.
- Scalability: Highly efficient for generating unique IDs in high-concurrency environments.
*/

--create sequence
CREATE SEQUENCE IF NOT EXISTS test_seq

SELECT nextval('test_seq')


SELECT currval('test_seq')

--set a seq.

SELECT setval('test_seq',100)

SELECT currval('test_seq')

--set a seq. and do not skip over

SELECT setval('test_seq',100,false)

SELECT currval('test_seq')

--control the sequence start value

CREATE SEQUENCE IF NOT EXISTS test_seq2 START WITH 100
SELECT nextval('test_seq2');
SELECT currval('test_seq2')

--alter sequence
select nextval('test_seq')

alter SEQUENCE test_seq RESTART WITH 100

ALTER SEQUENCE test_seq RENAME TO my_sequence4

/*
start with value
increment value
min value
max value
*/

create SEQUENCE IF NOT EXISTS test_seq3
INCREMENT 50
MINVALUE 400
MAXVALUE 6000
start with 400

select nextval('test_seq3')

--sequece with specific data type

create SEQUENCE IF NOT EXISTS test_seq_smallint as SMALLINT

create SEQUENCE IF NOT EXISTS test_seq_smallint as INT

create SEQUENCE IF NOT EXISTS test_seq4

SELECT nextval('test_seq_smallint')

--descending sequence and cycle sequence

CREATE SEQUENCE seq_des
INCREMENT -1
MINVALUE 1
MAXVALUE 3
START 3
CYCLE

select nextval('seq_des')

--delete a sequence

DROP SEQUENCE seq_des

--attaching sequence to an existing table

CREATE TABLE users(
    user_id serial PRIMARY KEY,
    user_name varchar(50) NOT NULL
)
INSERT INTO users (user_name) VALUES
('jay'),
('madhav')

SELECT * from users;

ALTER SEQUENCE users_user_id_seq RESTART WITH 100
INSERT INTO users (user_name) VALUES
('jay'),
('madhav')
--will start from 100

CREATE TABLE users2(
    user2_id INT PRIMARY KEY,
    user2_name varchar(50) NOT NULL
)

--create seq

CREATE SEQUENCE IF NOT EXISTS users2_user2_id_seq
START WITH 100
INCREMENT BY 5
OWNED BY users2.user2_id;

--it will not work now we have to all nextval(seq) as default
ALTER TABLE users2
ALTER COLUMN user2_id SET DEFAULT nextval('users2_user2_id_seq');

INSERT INTO users2 (user2_name) VALUES
('jay'),
('madhav')

SELECT * from users2;

-- user2_id	user2_name
-- 100	      jay
-- 105	      madhav

--listing all sequences

SELECT relname sequence_name
from pg_class
WHERE
relkind = 'S';

--share seq between multiple tables

CREATE SEQUENCE common_seq START WITH 100;

CREATE TABLE apples(
    fruit_id INT DEFAULT nextval('common_seq') not null,
    fruit_name varchar(50) not null
)

--table2
CREATE TABLE manogs(
    fruit_id INT DEFAULT nextval('common_seq') not null,
    fruit_name varchar(50) not null
)

INSERT INTO apples (fruit_name) VALUES
('apple1'),
('apple2')

INSERT INTO manogs (fruit_name) VALUES
('mango1'),
('mango2')

SELECT * from apples;
-- fruit_id	fruit_name
-- 100	        apple1
-- 101	        apple2

SELECT * from manogs;
-- fruit_id	fruit_name
--   102          mango1
--   103	       mango2

--alphanumeric sequence

--create a table with serial datatype for seq
CREATE table contacts(
    contact_id serial PRIMARY KEY,
    c_name varchar(50) NOT NULL
);

INSERT INTO contacts (c_name) VALUES
('jay'),
('madhav')

SELECT * from contacts;

-- what if id be 
-- id1
-- id1
DROP TABLE contacts

--create seq

CREATE SEQUENCE table_seq;

CREATE table contacts(
    contact_id text DEFAULT('id'||nextval('table_seq')) PRIMARY KEY,
    c_name varchar(50) NOT NULL
);

INSERT INTO contacts (c_name) VALUES
('jay'),
('madhav')

SELECT * from contacts;

--contact_id c_name
--  id1	      jay
--  id2	     madhav

--alter seq and attach to table

ALTER SEQUENCE table_seq OWNED BY contacts.contact_id;


INSERT INTO contacts (c_name) VALUES
('ahdf'),
('aifhe')

SELECT * FROM contacts;

-- contact_id	c_name
--     id1	    jay
--     id2	    madhav
--     id3	    ahdf
--     id4	    aifhe

