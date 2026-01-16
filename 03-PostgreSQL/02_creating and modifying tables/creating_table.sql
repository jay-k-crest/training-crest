CREATE TABLE actors(
   actor_id SERIAL PRIMARY KEY,
   first_name VARCHAR(150),
   last_name VARCHAR(150) NOT NULL,
   gender CHAR(1),
   date_of_birth DATE,
   add_date DATE,
   update_date DATE
);




CREATE TABLE directors(
director_id SERIAL PRIMARY KEY,
first_name VARCHAR(150),
last_name VARCHAR(150),
date_of_birth DATE,
nationality VARCHAR(20),
add_date DATE,
update_date DATE
);

SELECT * from directors



CREATE TABLE movies(
movie_id SERIAL PRIMARY KEY,
movie_name VARCHAR(100) NOT NULL,
movie_length INT,
movie_lang VARCHAR(20),
age_certificate VARCHAR(10),
release_date DATE,
director_id INT REFERENCES directors (director_id)
);
SELECT 	* from movies



CREATE TABLE movie_revenues(
revenue_id SERIAL PRIMARY KEY,
movie_id INT REFERENCES movies (movie_id),
revenues_domestic NUMERIC(10,2),
revenues_international  NUMERIC(10,2);
);

SELECT * from movie_revenues
