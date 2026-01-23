--upper ,lower and inicap

select upper('saul goodman')

SELECT
    upper(first_name) as first_name,
    upper(last_name) as last_name
FROM directors

SELECT lower('HELLO WORLD!')

SELECT initcap('humans nurse their past like festering wounds')

SELECT
   initcap(
    concat(first_name ,' ',last_name)
   ) as full_name
FROM actors
ORDER BY
first_name

--left and right

SELECT LEFT('abcd',1)

--return all except last n characters
SELECT LEFT('valar morghulis!',-1)



--get initial of all director name
SELECT 
    left(first_name,1) as initial
    from directors
    order by 1;


SELECT 
    left(first_name,1) as initial,
    count(*) as total_initials
    from directors
    group by 1
    order by 1;

--first 6 char from all movies

SELECT 
    movie_name,
    left(movie_name,6) as short_name
FROM movies

--right
SELECT right('you can say my name',11)
SELECT right('!valar dohaeris',-1)

select last_name,right(last_name,2)
from directors
where right(last_name,2) = 'on'


--reverse

select reverse('suidireM sumiceD sumixaM si eman yM')


select reverse('5544-305 )505(')

-- Challenge 1: The "Secret Agent" Clean-up
-- You have a column with data that looks like this: ***BOND, JAMES***. I want the output to look like this: James Bond (Title Case, no stars, First Name first).


select (left('JAMES****',5) || ' ' || RIGHT('****BOND',4))

-- Challenge 2: The "Tenet" Test
-- You are looking for movies in your movies table that are palindromes (they read the same forward and backward, like the movie Tenet).

select movie_name from movies
where reverse(movie_name) = movie_name

-- Challenge 3: The "Heisenberg" Mask
-- You have the string 'WALTER WHITE'. I want you to write a query that outputs: W*******E (The first letter, 7 stars, and the last letter).

select (left('WALTER WHITE',1) || '*******' || RIGHT('WALTER WHITE',1))

--#######################################################################
--splitpart function
--#######################################################################

select  split_part('1,2,3',',',2)

SELECT 
    split_part('it''s,hard,but,alas,all,goodman', ',', 1) AS first_part,
    split_part('it''s,hard,but,alas,all,goodman', ',', 5) AS middle_part,
    split_part('it''s,hard,but,alas,all,goodman', ',', 6) AS last_part
  

SELECT 
    movie_name,
    release_date,
    split_part(release_date::text, '-', 1) as year,
    split_part(release_date::text, '-', 2) as month,
    split_part(release_date::text, '-', 3) as day
FROM movies


--#######################################################################
--trim,btrim,ltrin,rtrim
--#######################################################################
-- TRIM([LEADING | TRAILING | BOTH] [characters] FROM string)

-- LTRIM(string [, characters])

-- RTRIM(string [, characters])

-- BTRIM(string [, characters])

select 
    trim(
        leading
        from 
        '   my name is skylerwhite yoo!'     
    ),
    trim (
        trailing
        from 
        'I am Ironman   '     
    ),
    trim (
        '    I am inevitable    ' 
    );
   

select 
    trim(
        leading '0'
        FROM
        '0000000What is dead may never die'::TEXT
    );

SELECT 
    ltrim('gmethempahtamene','g');

SELECT 
    rtrim('maximusm','m');

SELECT 
    btrim('kchaos is ladderk','k');



--#######################################################################
--lpad,rpad
--#######################################################################

-- LPAD(string, length [, fill_text])

-- RPAD(string, length [, fill_text])

select lpad('database',15,'*')

select rpad('database',15,'*')

SELECT 
    mv.movie_name,
    r.revenues_domestic,
    lpad('*',cast(trunc(r.revenues_domestic/10)as int),'*') chart
from movies mv
inner join movies_revenues r on r.movie_id=mv.movie_id
ORDER BY 3 DESC
nulls last


--#######################################################################
--length
--#######################################################################

SELECT length('power resides where men belive it resides!')

select char_length('')


select char_length(NULL)

SELECT 
    first_name || ' ' || last_name as full_name,
    length(first_name || ' ' || last_name) as full_name_length
FROM    
    directors
ORDER BY
    full_name_length desc


--#######################################################################
--position and strpos
--#######################################################################

select position('winter' in 'winter is coming')

SELECT position('t' in 'agrwetjnbstyhg')

strpos<str>,<substr>

select 
    first_name,
    last_name
from directors
where strpos(last_name,'on')>0;


--#######################################################################
--substring,repeat and replace
--#######################################################################

SELECT substring('what a wonderful world'from 1 for 4)


SELECT substring('what a wonderful world'from 6 for 10)

select repeat('a',4)

--REPLACE

select replace('valar morghulis','morghulis','dohaeris')

