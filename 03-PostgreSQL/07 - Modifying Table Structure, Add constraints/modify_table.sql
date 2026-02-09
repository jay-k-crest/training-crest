--create a sample table for modify exercise
create table persons(
    person_id serial primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null
);

--add new column 

alter table persons 
add column age INT not null;

select * from persons;

-- add nationality

alter table persons 
add column nationality varchar(50) not null;

--email

alter table persons 
add column email varchar(100) unique not null;


--TOPIC 2
--MODIFY TABLE STRUCTURE

--rename table

alter table persons
rename to users;

alter table users
rename to persons;

--column name 

alter table persons
rename column age to person_age;

--drop column 

alter table persons
drop column person_age;

alter table persons 
add column age varchar(10);


--data type 

ALTER TABLE persons 
ALTER COLUMN age TYPE int USING age::integer;

--reverse it

ALTER TABLE persons 
ALTER COLUMN age TYPE varchar(10);

--set a default value to a column

alter table persons
add column is_enabled varchar(1);

alter table persons 
alter column is_enabled set default 'Y';

select * from persons;

--insert to test

insert into persons
(first_name, last_name, age, nationality, email)
 values
 ('Jay', 'kalsariya', 20, 'Indian', 'jay.k@example.com');


--add constraints to columns 
--create new table weblinks
create table weblinks(
    link_id serial primary key,
    link_url varchar(255) not null,
    link_name varchar(255) not null
);

select * from weblinks;

--insert data

insert into weblinks
(link_url, link_name)
values
('https://www.google.com', 'google'),
('https://www.yahoo.com', 'yahoo'),
('https://www.bing.com', 'bing');

select * from weblinks;

--unique links

alter table weblinks
add constraint unique_links unique(link_url);

--check it

/*
insert into weblinks
(link_url, link_name)
values
('https://www.google.com', 'google');
Started executing query at Line 107
duplicate key value violates unique constraint "unique_links"
DETAIL: Key (link_url)=(https://www.google.com) already exists.
Total execution time: 00:00:00.008
*/

--allow certain values only 

alter table weblinks 
add column is_enable varchar(2);

insert into weblinks
(link_url, link_name, is_enable)
values
('https://www.netflix.com', 'netflix', 'Y');

select * from weblinks;

alter table weblinks
add check (is_enable in ('Y', 'N'));

--check
/*
insert into weblinks
(link_url, link_name, is_enable)
values
('https://www.warnerbros.com', 'wb', 'fd');
Started executing query at Line 134
new row for relation "weblinks" violates check constraint "weblinks_is_enable_check"
DETAIL: Failing row contains (6, https://www.warnerbros.com, wb, fd).
Total execution time: 00:00:00.001
*/

insert into weblinks
(link_url, link_name, is_enable)
values
('https://www.warnerbros.com', 'wb', 'N');


select * from weblinks;

--update 
update weblinks
set is_enable = 'Y'
where link_id = 1;

select * from weblinks;