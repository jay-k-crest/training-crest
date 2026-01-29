--create a schema

create schema sales

create schema hr

--rename schema

alter schema hr rename to programming

--drop schema

drop schema programming

--schema hierarchy

/*
physical host>cluster>databse>schema>onjname

object access database.schema.object_name
*/

--create a database "test"

create database test

select * from hr.public.employees

--move a table to new schema

create schema humanresources

create table humanresources.orders(
    order_id serial primary key
)

alter table humanresources.orders  set schema public

--schema search path
--public is default search path
--SET search_path TO analytics;

select current_schema()
--public

show search_path
--"$user", public

set search_path to humanresources , public;

show search_path
--humanresources, public

create table humanresources.test(
    id serial primary key
)
insert into test (id) values (1)

select * from test;

create table public.test(
    id serial primary key
)
insert into public.test (id) values (2)

select * from test;
--1 came coz order of search path matters
----humanresources, public

--lets change order

set search_path to  public,humanresources;

show search_path
--public, humanresources

select * from test;
--2
--this time it will print 2

--alter schema ownership


alter schema humanresources owner to jay;

--check owner

SELECT r.rolname FROM pg_namespace n JOIN pg_roles r ON r.oid=n.nspowner WHERE n.nspname='humanresources';
--jay


--duplicate a schema along with data

create database test_schema


--table called song

create table test_schema.public.songs(
    song_id serial primary key,
    song_name varchar(50) not null
)

--add some sample data
 
insert into test_schema.public.songs (song_name) values 
('sexy back'),
('tous les memes')

--duplicate schema public with all data'

pg_dump -d test_schema -h localhost -U postgres -n public >dump.sql 

---rename original schema to public to old schema

alter schema public rename to old_public

--import back the dump'ed file

psql -h localhost -U postfres -d test_schema -f dump.sql

--pg_catalog

select * from information_schema.schemata

--compare tables and columns in two schemas

SELECT coalesce(c1.table_name,c2.table_name) as table_name,
coalesce(c1.column_name,c2.column_name) as column_name,
c1.column_name as schema1,
c2.column_name as schema2

from(
    select table_name,column_name
    from information_schema.columns c
    where c.table_schema = 'public'
) c1
full join
(
     select table_name,column_name
    from information_schema.columns c
    where c.table_schema = 'humanresources'
) c2
on c1.table_name = c2.table_name and c1.column_name = c2.column_name
where c1.table_name is null or c2.table_name is null
order by 1,2

--schemas and privileges

--- Schema Acessess level rights 
---   - USAGE   only can see data
---   - CREATE  even modify data

CREATE SCHEMA programming;

CREATE TABLE programming.employee (
    emp_id UUID PRIMARY KEY,
    name   VARCHAR(100)
);



GRANT USAGE ON SCHEMA programming TO "jay";

--- grant select 

GRANT SELECT ON ALL TABLES IN SCHEMA programming TO "jay";

INSERT INTO programming.employee (emp_id,name) VALUES ('7fa7c25e-dfad-4b94-b257-7c8bb81c9f9e','ABC')

SELECT * FROM programming.employee

GRANT SELECT ON ALL TABLES IN SCHEMA public TO "jay";

GRANT CREATE ON SCHEMA programming TO "jay";