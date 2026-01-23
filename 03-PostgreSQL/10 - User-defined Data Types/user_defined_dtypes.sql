/*
- TOPIC 1: CREATE DOMAIN
- Purpose: A domain is a user-defined data type that is based on an underlying type (like TEXT or INTEGER).
- Constraints: You can add constraints (CHECK, NOT NULL, DEFAULT) to ensure the data is always valid.
- Reusability: Once defined, you can use the domain across multiple tables to maintain consistency.
- Benefits: Centralizes validation logic. If the rule for an "address" changes, you update it in one place.
*/


-- Create a DOMAIN 'addr' with varchar(100)
CREATE DOMAIN addr AS VARCHAR(100) not null

create table locations(
    adderes addr
);

insert into locations (adderes) values ('123 surat')

select * from locations

--positive numeric domain with values >0

create domain positive_numeric int not null check (value>0)

create table sample(
    sample_id serial primary key,
    value_num positive_numeric
);

select * from sample

insert into sample (value_num) values
(10), (20), (30);

select * from sample

insert into sample (value_num) values
(-10);
--will throw error 

--us_postal_code to check formate

create domain us_postal_code as text check(
    value ~ '^\d{5}$' OR value ~ '^\d{5}-\d{4}$'
)

create table postal(
    postal_code us_postal_code
);

insert into postal (postal_code) values 
('12345-6789'),
('12345');

select * from postal;

--email domain

create domain email as text 
check 
(value ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

create table email_check(
    email_address email 
);


select * from email_check;

INSERT INTO email_check (email_address) values 
(
    'abc@gmail.com'
)

select * from email_check;

--will generate error if not given email 
INSERT INTO email_check (email_address) values 
(
    'abc@'
    --value for domain email violates check constraint "email_check"
)


--create an enum type(enum or set of values) domain

create domain valid_color varchar(10)
CHECK
    (value in('red','green','blue'))

CREATE TABLE colors (
    color valid_color
);

SELECT * from colors;

INSERT INTO colors (color) 
VALUES
    ('red'),
    ('green'),
    ('blue')

select * from colors;


--will generate error 
INSERT INTO colors (color) 
VALUES
    ('yellow')
--value for domain valid_color violates check constraint "valid_color_check"

--get list all domins in schema 

--gui under schema public domains

select typname
from pg_catalog.pg_type
join pg_catalog.pg_namespace
on pg_namespace.oid = pg_type.typnamespace
where 
typtype = 'd' and nspname = 'public'

--drop domain datatype
--before delete domain have to deal with depending objects

drop domain positive_numeric cascade 

select * from sample

select * from colors

--change type before dropping
alter table colors alter column color type varchar(10);

--now drop
drop domain valid_color 


/*
- TOPIC 2: COMPOSITE DATA TYPES (CREATE TYPE)
- Purpose: Defines a list of field names and their data types, essentially acting like a "row" type.
- Structure: Can contain multiple different data types (e.g., TEXT, INTEGER, and DATE) within one type.
- Usage: Use it as a column type in a table or as a return type in stored functions.
- Comparison: Unlike a DOMAIN (which is one type with a rule), a COMPOSITE is multiple types grouped together.
*/

--address composite datatype
create type address as (
    city varchar(50),
    country varchar(50)
);

--create table
create table companies(
    company_id serial primary key,
    company_address address
);

--insert data
INSERT INTO companies(company_address) 
values (row('up','india'))

SELECT * from companies;
--selection

--(compositecolumn).field
--when multiple tables use (tablename.compositecolumn).field
select (company_address).city from companies;
select (company_address).country from companies;

--create a composite inventory_item data type

create type inventory_item as (
    product_name varchar(100),
    supplier_id INT,
    price NUMERIC
);

--create table

create table inventory(
    inventory_id serial primary key,
    item inventory_item
);

select * from inventory;

--insertdata


INSERT INTO inventory (item) VALUES 
(ROW('pc', 102, 20000.00));

SELECT * FROM inventory;

--item where price is less than 1500

SELECT (item).product_name FROM inventory 
WHERE (item).price < 1500;


--currency enum data type with currency data

CREATE TYPE currency AS ENUM (
    'USD',
    'EUR',
    'GBP',
    'INR'
);

select 'INR'::currency

alter type currency add value 'CHF' after 'GBP'

--create table

create table stock (
    stock_id serial primary key,
    price currency
);

select * from stock;

--insert data

insert into stock (price) values ('INR')

--will give error
insert into stock (price) values ('INR1')
--invalid input value for enum currency: "INR1"

--drop type
create type sample_type as enum ('abc','123')

drop type sample_type


/*
- TOPIC 3: ALTER DATA TYPE (TABLE COLUMNS)
- Purpose: Changes the data type of an existing column in a table.
- Syntax: ALTER TABLE table_name ALTER COLUMN column_name TYPE new_data_type.
- Automatic Conversion: Works if PostgreSQL knows how to convert the types (e.g., INTEGER to BIGINT).
- Explicit Conversion: Use the 'USING' clause for complex changes (e.g., TEXT to BOOLEAN).
- Impact: PostgreSQL validates all existing rows; if any row fails the conversion, the command fails.
*/

create type my_addr as (
    city varchar(50),
    country varchar(50)
);


--rename data type

alter type my_addr rename to address_type;

--change owner
alter type address_type owner to postgres;

--change schema create a test schema and change it 
create schema test_schema;
alter type address_type set schema test_schema;


--add new attriute

alter type test_schema.address_type 
add attribute 
    postal_code varchar(10);

--drop attribute

alter type test_schema.address_type
drop attribute postal_code;


--alter enum data type

create type mycolors as enum('red','green','blue');

--update value

alter type mycolors rename value 'red' to 'orange';

--list all enum values

select enum_range(null::mycolors);

--to add a new value(by default at the end)
alter type mycolors add value 'yellow';

select enum_range(null::mycolors);

--to add a new value before another value

alter type mycolors add value 'purple' before 'green';

select enum_range(null::mycolors);

--to add a new value after another value

alter type mycolors add value 'pink' after 'blue';

select enum_range(null::mycolors);

--update enum data type in production server

create type status as enum(
    'queued','waiting','running','done'
)
select enum_range(null::status);

create table job(
    job_id serial primary key,
    status status
);

--insert data
insert into job (status) values ('queued'),('waiting'),('running'),('done');

select * from job;


update job set status = 'running' where status = 'waiting'

select * from job;

alter type status  rename to status_old

--create fresh enum

create type status_new as enum(
    'queued','running','done'
)

alter table job alter column status type status_new using 
status::text::status_new

select * from job;

drop type status_old;

--enum with default value

create type order_status as enum (
    'pending',
    'processing',
    'completed',
    'cancelled'
);

create table orders (
    order_id serial primary key,
    status order_status default 'pending'
);

insert into orders (order_id) values (1);

select * from orders;

insert into orders (order_id,status) values (2,'completed');
select * from orders;

insert into orders (order_id,status) values (3,'processing');
select * from orders;


--create a type if not exist using pl/pgsql func


do
$$
begin
    if not exists(select *
                        from pg_type typ
                            inner join pg_namespace nsp
                                on nsp.oid = typ.typnamespace
                    where nsp.nspname = current_schema()
                     and typ.typname = 'ai') then
        create type ai
                    as (a text,
                        i integer);
    end if;
end;
$$
language plpgsql;

