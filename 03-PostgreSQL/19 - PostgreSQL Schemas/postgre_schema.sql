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
