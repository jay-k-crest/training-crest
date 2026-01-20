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