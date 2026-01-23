--Datetimes data types
--Date - date only yyyy-mm-dd
--Time - timeo only HH:MM:SS.p till  6 positions
--Time stamp date and time only yyyy-mm-dd hh-mm-ss does not store timezone

--system month date settings

SHOW Datestyle;
--ISO, DMY

SET Datestyle = 'ISO,DMY';

--time of day formates and values
--02:10 AM
--06:10:10 pm (6+12)
--6:10:10.736 

--timestamp format
--date time
--date time timezone
--datetime 2020-01-01 10:30:45 yyyy-mm-dd hh:mm:ss

--date/time input formates

--allballs time
--now date,time,timestamp
--today date,timestamp
--tomorrow
--yesterday
--epoch
--infinity
--'-infinity'

--converting string to dates

--D 1-7 days
--W week of month
--WW week of year

SELECT
    to_date('2020-01-01','YYYY-MM-DD');

SELECT
    to_date('20200101','yyyy-mm-dd')
    --will generate error

SELECT
    to_date('20200101','yyyymmdd')

--dd-mm-yyyy formate
SELECT
    to_date('01-01-2020','dd-mm-yyyy')

--yyyy-mm-dd from long date
SELECT
    to_date('december 1, 2020','month dd, yyyy')

--from short date
SELECT
    to_date('dec 1, 2020','mon dd, yyyy')

-- TO_TIMESTAMP function
SELECT
    to_timestamp('2020-01-01 10:30:45','YYYY-MM-DD HH:MI:SS')

SELECT
    to_timestamp('2020-01-01 20:30:45','YYYY-MM-DD HH24:MI:SS')

SELECT
    to_timestamp('01-01-2020 10:45','MM-DD-YYYY SS:MS')

--formatting dates

--to_char function

--it converts timestamp , interval, interger , doule precision to str
--9 for digit
--s for sign
--l for currency

SELECT
    CURRENT_TIMESTAMP,
    to_char('2020-01-01 10:30:45'::timestamp , 'yyyy month dd')

SELECT
    CURRENT_TIMESTAMP,
    to_char('2020-01-01 10:30:45'::timestamp , 'yyyy month dd'),
    to_char('2020-01-01 10:30:45'::timestamptz, 'yyyy month dd'),
    to_char('2020-01-01T10:30:45-6:00'::timestamptz, 'yyyy month dd hh::mm:ss tz')
    
--let view movies release date

SELECT release_date from movies;



SELECT
    movie_name,
    release_date,
    to_char(release_date,'FMMonth DDth, YYYY hh:mm:ss tz')
    from movies;

--date conversion functions

SELECT 
    make_date(2020,01,01)

--time without timezone

SELECT
    make_time(2,3,4.05)

--make_timestamp
--(yyyy-mm-dd-hh-mi-ss)

SELECT
    make_timestamp(2020,01,01,10,30,45)

--make interval

--(years.months,weeks,days,hours,minutes,seconds)

SELECT
    make_interval(2020,01,01,10,30,45)

--effect of week number
SELECT
    make_interval(2020,01,01,10,30,45),
    make_interval(2020,01,10,10,30,45),
    make_interval(2020,01,12,10,30,45)

--can also use named notation

SELECT
    make_interval(
        years  := 2020,
        months := 11,
        weeks  := 1,
        days   := 23,
        hours  := 3,
        mins   := 54,
        secs   :=5.123456
    )

--2020 years 11 mons 30 days 03:54:05.123456

--make_timestamptz
--year,month,day,hour,minute,sec

SELECT
    make_timestamptz(2026,01,01,10,30,45)

SELECT
    pg_typeof(make_timestamptz(2026,01,01,10,30,45))

--view available timezone names

SELECT * from pg_timezone_names;

--specify tiezone

SELECT pg_typeof(make_timestamptz(2026,01,01,10,30,45,'Europe/London'))

SELECT make_timestamptz(2026,01,01,10,30,45,'Europe/London')

--check same time for 10 different timezone

SELECT
    make_timestamptz(2026,01,01,10,30,45,'Europe/London'),
    make_timestamptz(2026,01,01,10,30,45,'Europe/Paris'),
    make_timestamptz(2026,01,01,10,30,45,'Europe/Moscow'),
    make_timestamptz(2026,01,01,10,30,45,'America/New_York'),
    make_timestamptz(2026,01,01,10,30,45,'Asia/Tokyo'),
    make_timestamptz(2026,01,01,10,30,45,'Australia/Sydney'),
    make_timestamptz(2026,01,01,10,30,45,'Pacific/Auckland'),
    make_timestamptz(2026,01,01,10,30,45,'Pacific/Fiji'),
    make_timestamptz(2026,01,01,10,30,45,'Pacific/Tongatapu'),
    make_timestamptz(2026,01,01,10,30,45,'Pacific/Guadalcanal')


--date value extractor
--extract(field , source)
/*
YEAR	The full year (4 digits)	2026
MONTH	The month number (1–12)	1
DAY	The day of the month (1–31)	22
HOUR	The hour (0–23)	14
MINUTE	The minute (0–59)	26
SECOND	The seconds, including decimals	6.938393
DOW	Day of Week (0=Sun, 6=Sat)	4 (Thursday)
QUARTER	The quarter of the year (1–4)	1
EPOCH	Total seconds since 1970-01-01	1737541566.9...
*/

SELECT
    extract ('day' from CURRENT_TIMESTAMP) as "DAY"

SELECT
    extract ('epoch' from CURRENT_TIMESTAMP)

SELECT
    extract ('century' from interval '500 years 2 months 11 days') 


--math with date 

--add 10 days
SELECT
 DATE'20200202'+10

SELECT 
    '20201010'::date + 10

--using interval with math

SELECT
    '20201010'::date + interval '10 days'

--with timestmp

SELECT
    CURRENT_TIMESTAMP + '01:01:01'

SELECT 
    '20201010'::date + '10:25:23'::time

--using interval

SELECT
    '30 minutes'::interval + '30 minutes'::interval

select 
    '2:00'::interval/2 as "1 hour"

--overlaps operator

select 
    (date '2020-01-01', date '2020-01-31') OVERLAPS (date '2020-01-15', date '2020-02-15')
--true

select
    (date '2020-01-01', date '2020-01-31') OVERLAPS (date '2020-02-15', date '2020-02-15')
--TRUE

--date/time native functions

SELECT
    current_date,
    current_time,
    current_timestamp,
    localtime,
    localtimestamp,
    now()


--we can use percision as well
SELECT
    current_date,
    current_time,
    current_time(2),
    current_timestamp,
    current_timestamp(2),
    localtime,
    localtime(3),
    localtimestamp,
    localtimestamp(6),



--postgresql date & time

select
    now(),
    transaction_timestamp(),
    statement_timestamp(), --time execution
    clock_timestamp(),
    timeofday(),
    pg_typeof( timeofday()) --string type

--age function

--age(date1,date2)

select
    age(date '2026-01-22', date '2015-07-21')

select age('21-07-2015'::timestamp)

--current_time in rable 
create table time(
    log_id serial primary key,
    add_date date default current_date,
    add_time time default current_time
)

insert into time (log_id) values ('1')


select * from time
insert into time (log_id) values ('2')
select * from time

-- 1	2026-01-22	15:46:40.12185
-- 2	2026-01-22	15:48:37.571298

--date accuracy with epoch

select
    AGE ('2020-12-20'::timestamp , '2020-01-01'::timestamp)

--only gives months and days no seconds

select 
    extract (epoch from '2020-12-20'::timestamptz - '2020-01-01'::timestamptz)

--how to do say difference in days (60/60/24) using epoch

select
    (extract (epoch from '2020-12-20'::timestamptz - '2020-01-01'::timestamptz))
    /60/60/24 as "difference in days"

--using date , time , timestamp in table

create table times(
    times_id serial primary key,
    start_date  date,
    start_time  time,
    start_timestamp timestamp
)

--insert data
insert into times(start_date,start_time,start_timestamp)
values
('epoch','allballs','infinity')

select * from times


insert into times(start_date,start_time,start_timestamp)
values
('epoch','allballs','-infinity')

select * from times

insert into times(start_date,start_time,start_timestamp)
values
(now(),'allballs','-infinity')

select * from times
-- 1	1970-01-01	00:00:00	infinity
-- 2	1970-01-01	00:00:00	-infinity
-- 3	2026-01-22	00:00:00	-infinity

--view and set timezone

select * from pg_timezone_names;

show time zone;

set time zone 'us/alaska'
show time zone;

set time zone 'asia/calcutta'

show time zone;

--how to handle timezones

alter table times
add column end_timestamp timestamp with time zone;

select * from times;

--data with daylight saving

insert into times(start_date,start_time,start_timestamp,end_timestamp)
values
('2020-03-08','01:30:00','2020-03-08 01:30:00','2020-03-08 01:30:00 EST');

select * from times;

insert into times(end_timestamp,start_timestamp)
values
('2020-03-08 01:30:00 US/PACIFIC','2020-03-08 01:30:00');

select * from times;

set time zone 'us/pacific'

select * from times;

set time zone 'asia/calcutta'

--date_part fucntion

--subfields access
--date_part(field,source)
/*
millennium	The millennium number.	2024 → 3
century	The century number.	2024 → 21
decade	The year divided by 10.	2024 → 202
year	The full year.	2024
quarter	The quarter of the year (1–4).	1 to 4
month	The month number (1–12).	1 to 12
week	ISO 8601 week number of year.	1 to 53
day	Day of the month.	1 to 31
doy	Day of the year.	1 to 366
dow	Day of week (0=Sunday, 6=Saturday).	0 to 6
isodow	ISO Day of week (1=Monday, 7=Sunday).	1 to 7
isoyear	ISO 8601 week-numbering year.	2024
*/

select date_part('year','2017-01-01'::date)

--try all field for same date
select 
date_part('year','2017-01-01'::date),
date_part('month','2017-01-01'::date),
date_part('day','2017-01-01'::date),
date_part('week','2017-01-01'::date),
date_part('doy','2017-01-01'::date),
date_part('dow','2017-01-01'::date),
date_part('isodow','2017-01-01'::date),
date_part('quarter','2017-01-01'::date),
date_part('century','2017-01-01'::date),
date_part('decade','2017-01-01'::date),
date_part('millennium','2017-01-01'::date)

--hour , minute , second , century


SELECT 
    date_part('hour', '2017-01-01 15:45:30'::timestamp) AS hour,
    date_part('minute', '2017-01-01 15:45:30'::timestamp) AS minute,
    date_part('second', '2017-01-01 15:45:30'::timestamp) AS second,
    date_part('century', '2017-01-01 15:45:30'::timestamp) AS century;


--movie release week and month 
select
    movie_name,
    release_date,
    date_part('week',release_date) as "week",
    date_part('month',release_date) as "month"
    from movies
    order by 4 desc

--date_truc function

--date_trunc('datepart',field)

/*
millennium	Start of the 1000-year period	2001-01-01 00:00:00
century	Start of the 100-year period	2001-01-01 00:00:00
decade	Start of the 10-year period	2010-01-01 00:00:00
year	January 1st of that year	2017-01-01 00:00:00
quarter	Start of the quarter (Jan, Apr, Jul, Oct)	2017-01-01 00:00:00
month	1st day of the month	2017-01-01 00:00:00
week	Monday of that week	2017-01-09 00:00:00
day	Midnight of that day	2017-01-15 00:00:00
*/

select
    date_trunc('hour','2020-10-01 12:34:12'::timestamp)

--trunc hour , minute and date 

select
    date_trunc('hour','2020-10-01 12:34:12'::timestamp) as "hour",
    date_trunc('minute','2020-10-01 12:34:12'::timestamp) as "minute",
    date_trunc('second','2020-10-01 12:34:12'::timestamp) as "second"


--count the number of movies by relase months
SELECT
    date_trunc('month', release_date) AS release,
    count(movie_id)
FROM
    movies
GROUP BY 
    release
order by
    2 desc



