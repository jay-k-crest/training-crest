/*
- TOPIC 1: INTRODUCTION TO CONSTRAINTS
- Purpose: Constraints are rules applied to columns to ensure Data Integrity.
- Prevention: They prevent invalid, null, or duplicate data from being entered.
- Timing: Constraints are checked during INSERT, UPDATE, and DELETE operations.
- Levels: 
    - Column Level: Applied directly to one column.
    - Table Level: Applied to the whole table (used for multi-column rules).
    - Categories:
    - NOT NULL: Prevents missing values.
    - UNIQUE: Prevents duplicate entries.
    - PRIMARY KEY: Uniquely identifies each record (NOT NULL +        UNIQUE).
    - FOREIGN KEY: Links tables together (Referential Integrity).
    - CHECK: Validates data based on a condition (e.g., price > 0).
    - DEFAULT: Automatically assigns a value if none is provided. 
*/

/******************************************
not null constairnt
*******************************************/
create table nn(
    id serial primary key,
    tag text not null

)

--insert values

insert into nn (tag) values 
('abc'),('xyz')

select * from nn

--try to insert null

insert into nn (tag) values 
(NULL)
--null value in column "tag" of relation "nn" violates not-null constraint

--adding not null constraint to an existing table
--create tablw without not null and add it 

create table no_nn(
    id serial primary key,
    tag text
)

alter table no_nn 
alter column tag set not null  
/******************************************
-unique constraints
*******************************************/

create table uni (
    id serial primary key,
    email text unique
);

SELECT * from uni

--insert data
INSERT INTO uni (email) values ('a@b.com')

SELECT * from uni

--insert again will give error
INSERT INTO uni (email) values ('a@b.com')
--duplicate key value violates unique constraint "uni_email_key"


--unique key on multiple columns
create table uni2 (
    id serial PRIMARY KEY,
    pc varchar(10),
    pn text
);

--unique constraints

alter table uni2
add constraint unique_products_code unique(pc,pn)

--add data

insert into uni2 (pc,pn) values
('a','test'),
('b','apple')

--will give error if run again
--duplicate key value violates unique constraint "unique_products_code"

select * from uni2
/*****************************************
default constraint 
*****************************************/
create table def (
    id serial primary key,
    fname varchar(50),
    is_enable varchar(2) default 'y'
);

select * from def;

insert into def (fname) values
('jay'),('madhav')

select * from def;

alter table def
alter column is_enable set default 'n'

insert into def (fname) values
('jay'),('madhav')

select * from def;

--drop defualt value

alter table def
alter column is_enable drop default

select * from def;

insert into def (fname) values
('jay')

select * from def;

/******************************************
--primary key constraints
*******************************************/
--primary key = unique + not null

--table can have only 1 primary but can have multiple unique not null
--multiple fields in  primary key is known as composite key

create table pk(
    id integer primary key,
    item_name varchar(100) not null
)

--insert some data
insert into pk (id,item_name) values
(1,'pen')
--rerun will result in error 
--duplicate key value violates unique constraint "pk_pkey"

select * from pk;

--Tablename_pkey is naming convention

--add primary key to existing table

--drop a constraint 

alter table pk
drop constraint pk_pkey;


--add back
alter table pk
add primary key (id,item_name)

select * from pk


--#######################################################
--primary key on multiple columns = composite primary key
--#######################################################

create table grades (
    c_id varchar(100) not null,
    s_id varchar(100) not null,
    grade int not null
)

insert into grades (c_id,s_id,grade) values
('math','s2',70),
('chemistry','s1',70),
('english','s2',70),
('physics','s1',89);

select * from grades

-- c_id+s_id = composite key 

drop table grades;

create table grades (
    c_id varchar(100) not null,
    s_id varchar(100) not null,
    grade int not null,
    primary key (c_id,s_id)
)

insert into grades (c_id,s_id,grade) values
('math','s1',50),
('math','s2',70),
('chemistry','s1',70),
('english','s2',70),
('physics','s1',89);

select * from grades

--drop the composite key

alter table grades
drop constraint grades_pkey;

alter table grades
    add constraint grades_pkey
        primary key(c_id,s_id);



--##############################################################
--foreign key constraints
--##############################################################

--first table that as a reference to the primary key of the second table


--without foreign key

create table t_products(
    product_id int primary key,
    product_name varchar(50) not null,
    supplier_id int not null
);

create table t_supplier(
    supplier_id int primary key,
    supplier_name varchar(100) not null
);


--insert data in both tables




insert into t_supplier (supplier_id, supplier_name) values
(1, 'Supplier A'), (2, 'Supplier B');

select * from t_supplier;

insert into t_products (product_id, product_name, supplier_id) values
    (101, 'Laptop', 1),
    (102, 'Mouse', 1),
    (103, 'Keyboard', 2);

select * from t_products;

insert into t_products (product_id, product_name, supplier_id) values
    (104, 'Laptop', 9)
--supplier 9 does not exist
--this will result in error in business logic thus foreign key is must to ensure database integrity

drop table t_products;


drop table t_supplier;



create table t_products(
    product_id int primary key,
    product_name varchar(50) not null,
    supplier_id int not null,
    foreign key (supplier_id) references t_supplier(supplier_id)
);

create table t_supplier(
    supplier_id int primary key,
    supplier_name varchar(100) not null
);


insert into t_supplier (supplier_id, supplier_name) values
(1, 'Supplier A'), (2, 'Supplier B');

select * from t_supplier;

INSERT INTO t_products (product_id, product_name, supplier_id) VALUES
    (101, 'Laptop', 1),
    (102, 'Mouse', 1),
    (103, 'Keyboard', 2);

select * from t_products;

--will generate error 
insert into t_products (product_id, product_name, supplier_id) values
    (104, 'Laptop', 9)
--insert or update on table "t_products" violates foreign key constraint "t_products_supplier_id_fkey"


insert into t_supplier (supplier_id, supplier_name) values
(9, 'Supplier C')

-- now run again
insert into t_products (product_id, product_name, supplier_id) values
    (104, 'Laptop', 9)


--have to use cascade when to use delete
delete from t_products where product_id = 104;
delete from t_supplier where supplier_id = 9;

SELECT * FROM t_products;
SELECT * FROM t_supplier;

--###################################################################
--drop constraint
--###################################################################

-- foreign key stored as tablename_columnname_fkey


alter table t_products drop constraint t_products_supplier_id_fkey;


--update existing table foreign key

alter table t_products
add constraint t_products_supplier_id_fkey
FOREIGN KEY (supplier_id) REFERENCES t_supplier(supplier_id);

--######################################################################
--check constraint
--######################################################################

--interting or updating data is where it is used most

create table products_check (
    product_id serial primary key,
    product_name varchar(100) not null,
    price decimal(10,2) check (price > 0),
    stock int check (stock >= 0)
);

insert into products_check (product_name,price,stock) values
('laptop',1200.00,50),
('mouse',25.50,100);

select * from products_check;

--will generate error 
insert into products_check (product_name,price,stock) values
('keyboard',-10.00,30);
-- new row for relation "products_check" violates check constraint "products_check_price_check"
-- DETAIL: Failing row contains (3, keyboard, -10.00, 30).

--define check constairnt for existing table

create table products_check_existing (
    product_id serial primary key,
    product_name varchar(100) not null,
    price decimal(10,2),
    stock int
);

--before adding check add data

insert into products_check_existing (product_name, price, stock) 
values ('webcam', -50.00, 5);

SELECT * FROM products_check_existing;

--add check constraint

alter table products_check_existing
add constraint price_check check (price > 0);
--check constraint "price_check" of relation "products_check_existing" is violated by some row
--so that row has to be removed


DELETE FROM products_check_existing WHERE price <= 0;


alter table products_check_existing
add constraint price_check check (price > 0);

insert into products_check_existing (product_name,price,stock) values
('monitor',200.00,10);


insert into products_check_existing (product_name,price,stock) values
('webcam',-50.00,5);
--will generate error
--new row for relation "products_check_existing" violates check constraint "price_check"
--DETAIL: Failing row contains (2, webcam, -50.00, 5).


--rename constraint on a table  

alter table products_check_existing
rename constraint price_check to product_price_check;

--check the constraint name

select conname from pg_constraint where conrelid = 'products_check_existing'::regclass;
-- conname
-- product_price_check
-- products_check_existing_pkey
-- products_check_existing_product_id_not_null
-- products_check_existing_product_name_not_null

--drop constraint

alter table products_check_existing
drop constraint product_price_check;


--
