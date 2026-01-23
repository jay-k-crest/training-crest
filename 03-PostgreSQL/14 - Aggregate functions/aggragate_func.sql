--count result using count

select count(*) from movies
--53

--records for a specific column
SELECT count(movies.movie_length) from movies
--53

--using count with distinct

--without distict
select count(movies.movie_lang) from movies

select count(DISTINCT(movies.movie_lang)) from movies

--distinct movie directors

select count(DISTINCT(movies.director_id)) from movies


--count english movies

SELECT COUNT(*) FROM movies
WHERE movie_lang='English'
--38


SELECT COUNT(*) FROM movies
WHERE movie_lang='Japanese'
--4

--##########################################################
--sum fucnction
--##########################################################

--get all movie revenue records
SELECT * from movies_revenues

--total of domestic revenues

select SUM(movies_revenues.revenues_domestic) from movies_revenues
--5719.50

--total where revenue>200
select sum(revenues_domestic) from movies_revenues
where revenues_domestic>200;
--3425.60

--total movie length of all english movies

select sum(movie_length) from movies
where movie_lang='English'
--4824


--movie names
select sum(length(movie_name)) from movies
where movie_lang='English'
--541

--sun with distinct

--total domestic revenues for all movies 
--WITHOUT distinct

select sum(revenues_domestic) from movies_revenues
--5719.50

--with distinct

select sum(distinct(revenues_domestic)) from movies_revenues
--5708.40

--####################################################################
--min max
--####################################################################

--longest length movie in movies table name

select max(length(movie_name)) from movies

--duration
SELECT MAX(movie_length) FROM movies;

--same for min

--shortest length movie in movies table name
select min(length(movie_name)) from movies
--4


--duration
SELECT min(movie_length) FROM movies;
--87

--longest english movie
SELECT MAX(movie_length) FROM movies
where movie_lang='English'
--168

--shortest english movie
SELECT min(movie_length) FROM movies
where movie_lang='English'
--87

--latest english movie
SELECT max(release_date) FROM movies
where movie_lang='English'
--2017-11-10

--first chinese movie
SELECT min(release_date) FROM movies
where movie_lang='Chinese'
--1972-06-01

--mix and max for text data type

--max func on movie_name

select max(movie_name) from movies
--Way of the Dragon 

select min(movie_name) from movies
--A Clockwork Orange

--#####################################################################
--greatest and least function
--#####################################################################

--greatest
select greatest(200,20,10)

--int and varchar

select least('a','b','c')
--cant use int and char together

--greatest and least revenue movie each

select
    movie_id,
    revenues_domestic,
    revenues_international,
    greatest(revenues_domestic,revenues_international) as highest_revenue,
    least(revenues_domestic,revenues_international) as lowest_revenue
from movies_revenues

--#####################################################################
--avg
--#####################################################################

--avg(columnname)
--avg movie length
select avg(movies.movie_length) from movies
--126.1320754716981132

--english avrage
select avg(movies.movie_length) from movies
where movie_lang = 'English'
--126.9473684210526316

--avg anf distinct
select avg(distinct movie_length) from movies
where movie_lang = 'English'
--127.7407407407407407

--avrage and sum together
select 
    avg(distinct movie_length) ,
     sum(distinct movie_length) 
from movies
where movie_lang = 'Chinese'
--121.8000000000000000	  609

--avrage will ignore all the null values

--operators 

/*
add +
sub -
mul *
division /
mod %
*/


select 2+10 as add

select 2-10 as sub

select 2*10 as mul

select 10/2 as div

select 10%2 as mod


--combine table columns
--total revenues
select 
    movie_id,
    revenues_domestic,
    revenues_international,
    revenues_domestic+revenues_international as total_revenues
from movies_revenues

--highest
SELECT 
    SUM(COALESCE(revenues_domestic, 0) + COALESCE(revenues_international, 0)) AS global_box_office
FROM movies_revenues;