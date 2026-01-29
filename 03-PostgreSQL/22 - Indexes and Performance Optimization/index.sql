/* ==============================================================================

1. WHAT IS AN INDEX?
------------------------------------------------------------------------------
An Index is a physical structure (usually a B-Tree) that points to data 
locations so the DB doesn't have to scan every row (Sequential Scan).

PROS: 
- Massive speed boost for SELECT queries using WHERE, JOIN, or ORDER BY.
- Can enforce data integrity (UNIQUE INDEX).

CONS: 
- Slows down INSERT, UPDATE, and DELETE (the index must be updated).
- Consumes additional disk space.

ANALOGY: 
Like an index at the back of a textbook. Find the 'Keyword', get the 
'Page Number', and jump straight to the data.

2. COMMON USE CASES (PKs & UUIDs)
------------------------------------------------------------------------------
- Primary Keys/UUIDs: Automatically indexed to ensure fast lookups and 
  uniqueness.
- Foreign Keys: Should usually be indexed manually to speed up JOINs.

3. NAMING CONVENTIONS (snake_case)
------------------------------------------------------------------------------
Format: {table_name}_{column_name}_{suffix}
- Standard Index: _idx
- Unique Index:   _uq or _key
- Foreign Key:    _fk
- GIN Index:      _gin

4. SYNTAX EXAMPLES
------------------------------------------------------------------------------
-- Standard B-Tree Index: Allows duplicates, speeds up general queries.
CREATE INDEX idx_users_email ON users (email);

-- Unique Index: Speeds up queries AND prevents duplicate entries.
CREATE UNIQUE INDEX uq_users_username ON users (username);

-- GIN Index: Specifically for JSONB or Array data (Module 20/21 stuff).
CREATE INDEX gin_products_metadata ON products USING GIN (metadata);



==============================================================================
*/

--create index on order_date on orders table

create index idx_orders_order_date on orders (order_date);
--Total execution time: 00:00:00.021

--index on ship_city

create index idx_orders_ship_city on orders (ship_city);
--Total execution time: 00:00:00.014


--multiple column customer_id and order_id_id

create index idx_orders_customer_id_order_id on orders (customer_id, order_id);
--Total execution time: 00:00:00.012

--put most selective column first

--using pgadmin to create index



--primary key and indexes

--unique key on product_id
create UNIQUE INDEX idx_u_products_product_id on products(product_id);
--Total execution time: 00:00:00.019

--similar on employees id

CREATE UNIQUE INDEX idx_u_employees_employee_id on employees(employee_id)
--Total execution time: 00:00:00.009

--UNIQUE ON MULTIPLE COLUMN

--customers - order_id , customer_id

create UNIQUE INDEX idx_u_orders_order_id_customer_id on orders(order_id, customer_id);
--Total execution time: 00:00:00.015

--employees -  employee_id , hiredate

create UNIQUE INDEX idx_u_employees_employee_id_hiredate on employees(employee_id, hire_date);
-- Total execution time: 00:00:00.010

SELECT * from employees


INSERT INTO employees(employee_id, first_name, last_name)
VALUES (1,'a','b')


CREATE TABLE t1(
  id serial PRIMARY KEY,
  tag text
)

--insert some data
INSERT INTO t1 (tag) values 
('tag1'),
('tag2'),
('tag3'),
('tag4'),
('tag5')

SELECT * from t1

CREATE UNIQUE INDEX idx_u_t1_tag on t1(tag)

INSERT INTO t1 (tag) values 
('tag1')
--duplicate key value violates unique constraint "idx_u_t1_tag"
-- DETAIL: Key (tag)=(tag1) already exists.

--list all indexes

--all indices

SELECT 
*
FROM pg_indexes
where 
  schemaname = 'public'
ORDER BY
  tablename,
  indexname;


--indices of a table


SELECT 
*
FROM pg_indexes
where 
  tablename = 'orders'
ORDER BY
  tablename,
  indexname;

--size of table index

SELECT 
  pg_size_pretty(pg_indexes_size('orders'))
--168 kB


--supplier - > region 

CREATE INDEX idx_suppliers_region on suppliers(region)

SELECT 
  pg_size_pretty(pg_indexes_size('suppliers'))
  --32 kb

--count for all indexes

SELECT
 *
from pg_stat_all_indexes  

--for a schema

SELECT
 *
from pg_stat_all_indexes  
WHERE schemaname = 'public'

--for a table

SELECT
 *
from pg_stat_all_indexes  
WHERE relname = 'orders'
order by relname,indexrelname;

--drop index
--cascade | restrict

drop index idx_suppliers_region

--sql statement execution process

--fastest path vs time spent in reasoning about this path
--sql is declarative 
--its about what and not how 

--sql stmt execution stages

/*
Parser (The Architect): Performs a Syntax Check (proper grammar) and a Semantic Check (do the tables/columns exist?). It outputs a Parse Tree.

Rewriter (The Editor): Simplifies the query. It expands Views, flattens subqueries, and converts the tree into Relational Algebra.

Optimizer (The Brain): Evaluates multiple paths to find the "cheapest" route. It uses Database Statistics to choose between Index Scans or Table Scans and decides the join order.

execution engine(The Worker): The Execution Engine physically pulls data from storage, applies filters, and returns the Result Set to your screen.
*/

-- The Query Optimizer
-- Goal: Identify the Lowest Estimated Cost plan.
-- Factors: Primarily balances I/O (Disk access) + CPU (Processing); planning time is kept minimal to avoid "optimization overhead."
-- Selection: The plan with the lowest total work (least logical operations) is chosen, regardless of real-time server load.


/* 
=================================================================================
  POSTGRESQL PLANNER/OPTIMIZER REFERENCE
=================================================================================
  STAGE: Parser -> Rewriter -> Optimizer (Planner) -> Executor

  1. SCAN NODES (Data Retrieval)
     - Seq Scan: Full table read. Chosen if table is small or returning > 20% rows.
     - Index Scan: B-Tree lookup + Heap fetch. Best for selective data.
     - Index Only Scan: Data is retrieved 100% from Index (No Heap fetch).
     - Bitmap Index Scan: Efficiently handles multiple 'OR/AND' index conditions.

  2. JOIN NODES (Data Merging)
     - Nested Loop: O(N*M). Best for small outer tables with indexed inner tables.
     - Hash Join: Creates a 'Hash Table' in work_mem. Best for large, unsorted sets.
     - Merge Join: Zips two sorted lists. Best for large sets if already indexed/sorted.

  3. RESOURCE & COMPLEXITY NODES
     - Gather / Parallel: Indicates the query is split across multiple CPU workers.
     - Materialize: Caches a sub-result to avoid re-computing in a loop.
     - Sort / Incremental Sort: Preps data for Merge Joins or ORDER BY clauses.

  4. THE "BIG QUERY" LOGIC (50+ Joins)
     - GEQO: Genetic Query Optimizer. Used for complex joins to prevent 
             planning time from exceeding execution time.
     - JIT (Just-In-Time): Compiles SQL expressions into machine code to 
             speed up compute-heavy 'Big Data' queries.
=================================================================================
*/

EXPLAIN select * from orders
--Seq Scan on orders  (cost=0.00..22.30 rows=830 width=90)

/*
+--------+--------------------------+-----------------------+--------------------+
| Index  | Best For                 | Supported Operators   | Disk Size          |
+--------+--------------------------+-----------------------+--------------------+
| B-Tree | General usage, Sorts     | =, <, >, <=, >=       | Medium             |
| Hash   | Unique, Exact match only | =                     | Small              |
| BRIN   | PBs of Time-series data  | =, <, >, (ranges)     | Tiny               |
| GIN    | Full-Text, JSON, Arrays  | @>, @@, && (contains) | Large              |
+--------+--------------------------+-----------------------+--------------------+
*/


--create index name on table using hash (column_name);

create index idx_orders_order_date_on on orders using hash (order_date)

explain select * from orders where order_date = '2020-01-01'

-- Index Scan using idx_orders_order_date_on on orders  (cost=0.00..8.02 rows=1 width=90)
--   Index Cond: (order_date = '2020-01-01'::date)

--explain statement 

explain select * from suppliers
where supplier_id = 1

-- Seq Scan on suppliers  (cost=0.00..1.36 rows=1 width=740)
--   Filter: (supplier_id = 1)

explain select company_name from suppliers
order by company_name

-- Sort  (cost=1.99..2.07 rows=29 width=98)
--   Sort Key: company_name
--   ->  Seq Scan on suppliers  (cost=0.00..1.29 rows=29 width=98)

--explain output options

--can have text , xml , json , yaml

explain (format yaml) select * from suppliers
where supplier_id = 1
/*
[
  {
    "Plan": {
      "Node Type": "Seq Scan",
      "Parallel Aware": false,
      "Async Capable": false,
      "Relation Name": "suppliers",
      "Alias": "suppliers",
      "Startup Cost": 0.00,
      "Total Cost": 1.36,
      "Plan Rows": 1,
      "Plan Width": 740,
      "Disabled": false,
      "Filter": "(supplier_id = 1)"
    }
  }
]
*/

--using explain analyze

-- explain output

explain select * from orders where order_id = 1 order by order_id

-- Index Scan using idx_u_orders_order_id_customer_id on orders  (cost=0.28..8.29 rows=1 width=90)
--   Index Cond: (order_id = 1)

select count(*) from orders
--830


--explain analyze '


explain analyze select * from orders where order_id = 1 order by order_id

/*
Index Scan using idx_u_orders_order_id_customer_id on orders  (cost=0.28..8.29 rows=1 width=90) (actual time=0.458..0.458 rows=0.00 loops=1)
  Index Cond: (order_id = 1)
  Index Searches: 1
  Buffers: shared hit=3 read=2
Planning Time: 0.258 ms
Execution Time: 0.498 ms
*/

--understanding query cost model

--generate large table

create table t_big (id serial , name text);

insert into t_big (name)
select 'jay' from generate_series(1,2000000)

-- Total execution time: 00:00:12.625


insert into t_big (name)
select 'madhav' from generate_series(1,2000000)

-- Total execution time: 00:00:13.771

explain select * from t_big where id=12345
-- Gather  (cost=1000.00..41494.43 rows=1 width=9)
--   Workers Planned: 2
--   ->  Parallel Seq Scan on t_big  (cost=0.00..40494.33 rows=1 width=9)
--         Filter: (id = 12345)

show max_parallel_workers_per_gather

--2

set max_parallel_workers_per_gather = 0

--with 0 worker

explain select * from t_big where id=12345

-- Seq Scan on t_big  (cost=0.00..69661.00 rows=1 width=9)
--   Filter: (id = 12345)

set max_parallel_workers_per_gather = 2

--block cost

select pg_relation_size('t_big')/8192.0
--19661.000000000000

--seq page cost

show seq_page_cost

--1

show cpu_tuple_cost

--0.01

show cpu_operator_cost

--0.0025

--cost fromula

Cost = (relpages * seq_page_cost) + (reltuples * cpu_tuple_cost) + (reltuples * cpu_operator_cost)

SELECT (19661 * 1.0) + (4000000 * 0.01) + (4000000 * 0.0025) AS cost;
--69661.0000


--index are not free

select
  pg_size_pretty(pg_indexes_size('t_big'))
-- 0 bytes

select
   pg_size_pretty(
    pg_total_relation_size('t_big')
   )
--154 MB

explain analyze select * from t_big where id=123456

--41494.43 cost without index

create index idx_t_big_id on t_big(id)


select
   pg_size_pretty(
    pg_total_relation_size('t_big')
   )
--239 MB increase table size

select
  pg_size_pretty(pg_indexes_size('t_big'))
-- 86 MB added 

--insert will be slow coz every insert will rebuild all indexes

explain analyze select * from t_big where id=123456

--8.45 after index

--indexes for sorted output

explain select * from t_big order by id limit 20

-- Limit  (cost=0.43..1.05 rows=20 width=9)
--   ->  Index Scan using idx_t_big_id on t_big  (cost=0.43..123544.43 rows=4000000 width=9)

explain select * from t_big 
order by name
limit 20

--cost 81679.43

explain select min(id),
max(id) from
t_big
--0.92 cost

--using multiple index on same query


explain analyze select * from t_big
where
  id = 20
  or id = 40

-- Bitmap Heap Scan on t_big  (cost=8.88..16.84 rows=2 width=9) (actual time=0.700..0.702 rows=2.00 loops=1)
--   Recheck Cond: ((id = 20) OR (id = 40))
--   Heap Blocks: exact=1
--   Buffers: shared hit=4
--   ->  Bitmap Index Scan on idx_t_big_id  (cost=0.00..8.88 rows=2 width=0) (actual time=0.635..0.636 rows=2.00 loops=1)
--         Index Cond: (id = ANY ('{20,40}'::integer[]))
--         Index Searches: 1
--         Buffers: shared hit=3
-- Planning Time: 0.239 ms
-- Execution Time: 3.596 ms

--execution plan depends on input values

create index idx_t_big_name on t_big(name)

explain select * from t_big where name = 'jay'
limit 10

  -- ->  Seq Scan on t_big  (cost=0.00..69661.00 rows=2006667 width=9)

explain select * from t_big where name = 'jay' or name = 'madhav'
limit 10

--  ->  Seq Scan on t_big  (cost=0.00..79661.00 rows=3000011 width=9)

--system ignoring the index
explain select * from t_big where name = 'jay2' or name = 'madhav2'
limit 10

-- Limit  (cost=0.43..8.88 rows=1 width=9)
--   ->  Index Scan using idx_t_big_name on t_big  (cost=0.43..8.88 rows=1 width=9)
--         Index Cond: (name = ANY ('{jay2,madhav2}'::text[]))

--this time it uses it 

--Postgres ignored  index because half (or all) of the table matches, making a sequential scan cheaper than any index or bitmap strategy.

--using organized vs random data

select * from t_big order by id limit 10

explain (analyze true , buffers true , timing true)
select * from t_big where id<10000

-- Index Scan using idx_t_big_id on t_big  (cost=0.43..368.84 rows=10938 width=9) (actual time=0.025..5.118 rows=9999.00 loops=1)
--   Index Cond: (id < 10000)
--   Index Searches: 1
--   Buffers: shared hit=4 read=71
-- Planning:
--   Buffers: shared hit=4
-- Planning Time: 0.392 ms
-- Execution Time: 5.821 ms

--table with unorganized data 


create table t_big2 as
select * from t_big
order by random()


create index idx_t_big2_id on t_big2(id)
--Total execution time: 00:00:30.177

--run the same query
explain (analyze true , buffers true , timing true)
select * from t_big2 where id<10000

-- Bitmap Heap Scan on t_big2  (cost=24961.76..61276.42 rows=1333333 width=36) (actual time=6.248..70.240 rows=9999.00 loops=1)
--   Recheck Cond: (id < 10000)
--   Heap Blocks: exact=7904
--   Buffers: shared hit=5355 read=2579
--   ->  Bitmap Index Scan on idx_t_big2_id  (cost=0.00..24628.43 rows=1333333 width=0) (actual time=3.916..3.916 rows=9999.00 loops=1)
--         Index Cond: (id < 10000)
--         Index Searches: 1
--         Buffers: shared read=30
-- Planning:
--   Buffers: shared hit=15 read=1
-- Planning Time: 0.772 ms
-- Execution Time: 71.423 ms

vacuum analyze t_big2

--same query 2nd time
explain (analyze true , buffers true , timing true)
select * from t_big2 where id<10000

-- Bitmap Heap Scan on t_big2  (cost=197.12..17261.72 rows=10412 width=9) (actual time=6.664..19.305 rows=9999.00 loops=1)
--   Recheck Cond: (id < 10000)
--   Heap Blocks: exact=7904
--   Buffers: shared hit=7907 read=27
--   ->  Bitmap Index Scan on idx_t_big2_id  (cost=0.00..194.52 rows=10412 width=0) (actual time=4.588..4.589 rows=9999.00 loops=1)
--         Index Cond: (id < 10000)
--         Index Searches: 1
--         Buffers: shared hit=3 read=27
-- Planning:
--   Buffers: shared hit=9 read=3
-- Planning Time: 0.564 ms
-- Execution Time: 21.355 ms

-- Execution Time: 21.355 ms vs Execution Time: 71.423 ms 


pg_stats

select
 tablename,
 attname,
correlation
from
 pg_stats
where
 tablename in  ('t_big2','t_big')
order by 1,2

-- tablename	attname	correlation
-- t_big	      id	            1
-- t_big	      name	        1
-- t_big2      	id	      0.010555946
-- t_big2	     name	        0.50806254


--try to use index only scan 

explain analyze select * from t_big where id = 123456

-- Index Scan using idx_t_big_id on t_big  (cost=0.43..8.45 rows=1 width=9) (actual time=0.199..0.201 rows=1.00 loops=1)
--   Index Cond: (id = 123456)
--   Index Searches: 1
--   Buffers: shared read=4
-- Planning Time: 0.194 ms
-- Execution Time: 0.240 ms

explain analyze select id from t_big where id = 123456

-- Index Only Scan using idx_t_big_id on t_big  (cost=0.43..4.45 rows=1 width=4) (actual time=0.176..0.177 rows=1.00 loops=1)
--   Index Cond: (id = 123456)
--   Heap Fetches: 0
--   Index Searches: 1
--   Buffers: shared hit=3 read=1
-- Planning Time: 0.249 ms
-- Execution Time: 0.229 ms

--partial index

select
  pg_size_pretty(pg_indexes_size('t_big'))
-- 112mb

--drop name index coz only 2 names are there

drop index idx_t_big_name

select
  pg_size_pretty(pg_indexes_size('t_big'))
--86 mb

create index idx_p_t_big_name on t_big(name)
 where name not in ('jay','madhav')

select
  pg_size_pretty(pg_indexes_size('t_big'))
--86 mb

select * from customers
--add column add is_actor

alter table customers
add column is_active boolean


update customers
set is_active = true
where customer_id in ('ALFKI','ANATR')

explain analyze select * from customers 
where is_active = true

-- Seq Scan on customers  (cost=0.00..2.91 rows=46 width=127) (actual time=0.095..0.096 rows=2.00 loops=1)
--   Filter: is_active
--   Rows Removed by Filter: 89
--   Buffers: shared hit=2
-- Planning Time: 0.116 ms
-- Execution Time: 0.114 ms

--partial index

create index idx_p_customers_is_active on customers(is_active)
where is_active = true

select
  pg_size_pretty(pg_indexes_size('customers'))
--32 kB

explain analyze select * from customers 
where is_active = true

-- Planning Time: 0.571 ms
-- Execution Time: 0.113 ms

--expression index

/*
Expression Index Explanation:
- This query uses an index built on a computed expression, not a base column.
- The indexed expression must exactly match the expression in the WHERE clause.
- PostgreSQL can use the index directly without recalculating the expression per row.
- This avoids a Sequential Scan and improves performance for function-based filters.
*/


create table t_dates as
select d, repeat(md5(d::text),10) as padding
from generate_series(timestamp '1800-01-01',
                      timestamp '2100-01-01',
                      interval '1 day') as s(d);


vacuum analyze t_dates

select count(*) from t_dates

explain analyze select * from t_dates where d between '2001-01-01' and '2001-01-31'
--Execution Time: 85.622 ms

create index idx_t_dates_d on t_dates(d)


explain analyze select * from t_dates where d between '2001-01-01' and '2001-01-31'
--Execution Time: 0.123 ms

--select for first day of each month
explain analyze select * from t_dates where extract(day from d) =1

/*
Seq Scan on t_dates  (cost=0.00..6624.61 rows=548 width=332) (actual time=0.348..159.101 rows=3601.00 loops=1)
  Filter: (EXTRACT(day FROM d) = '1'::numeric)
  Rows Removed by Filter: 105973
  Buffers: shared hit=2925 read=2056
Planning Time: 0.101 ms
Execution Time: 159.973 ms
*/

--create index

create index idx_expr_t_dates on t_dates (extract(day from d))


analyze t_dates

explain analyze select * from t_dates where extract(day from d) =1

-- Bitmap Heap Scan on t_dates  (cost=72.87..4952.57 rows=3671 width=332) (actual time=2.242..17.684 rows=3601.00 loops=1)
--   Recheck Cond: (EXTRACT(day FROM d) = '1'::numeric)
--   Heap Blocks: exact=3601
--   Buffers: shared hit=2756 read=857
--   ->  Bitmap Index Scan on idx_expr_t_dates  (cost=0.00..71.95 rows=3671 width=0) (actual time=1.441..1.442 rows=3601.00 loops=1)
--         Index Cond: (EXTRACT(day FROM d) = '1'::numeric)
--         Index Searches: 1
--         Buffers: shared read=12
-- Planning:
--   Buffers: shared hit=14 read=1
-- Planning Time: 0.405 ms
-- Execution Time: 18.125 ms
--vs Execution Time: 159.973 ms


--adding data while indexing

--create index concurrently

create index concurrently idx_t_big_name2 on t_big(name)

select oid,relname,relpages,reltuples,
        i.indisunique,i.indisclustered,i.indisvalid,
        pg_catalog.pg_get_indexdef(i.indexrelid,0,true)
        from pg_class c join pg_index i on c.oid = i.indrelid
        where c.relname = 't_big'

--invalidating an index

select *  from orders

--without dropping the index telling postgre to not to use a perticular index

explain select * from orders where ship_country = 'USA'
--Seq Scan on orders  (cost=0.00..24.38 rows=122 width=90)

--create index
create index idx_orders_ship_country on orders(ship_country)

explain select * from orders where ship_country = 'USA'
--Bitmap Heap Scan on orders  (cost=5.10..20.62 rows=122 width=90)

--disbale the query optimizer from using this column

update pg_index
set indisvalid = false
where indexrelid = 'idx_orders_ship_country'::regclass

explain select * from orders where ship_country = 'USA'
--Seq Scan on orders  (cost=0.00..24.38 rows=122 width=90)

--rebuildind index in postgre

reindex [(verbose)](index|table|schema|database|system)[consurrently] name

reindex (verbose) index idx_orders_customer_id_order_id;

--entire table
reindex (verbose) table orders;

--database , schema system also work

