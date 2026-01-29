
--northwind db practice queries

--orders shipping from usa or france

select * from orders where ship_country in ('USA','France')

--total  number of orders shipping from usa or france

select 
ship_country,
count(*) 
from orders 
where 
ship_country in ('USA','France')
GROUP BY orders.ship_country

-- Orders shipped to latin america


select 
* 
from orders
 where 
 ship_country in ('Brazil','Mexico','Argentina','Venezuela')

--Show total order amount for each order

select 
order_id,
product_id,
unit_price,
quantity,
discount,
((unit_price * quantity) * (1-discount)) as total_amount
from order_details

-- First and the oldest and latest order date

select 
min(order_date) as "min order date",
max(order_date) as "max order date"
from orders

--Total products in each categories

select 
    c.category_name,
    count(*) as total_products
from products p
inner join categories c on c.category_id = p.category_id
group by c.category_name

--  List products that needs re-ordering

--unit in stock <= reorder level

select * from products

select 
product_name,
units_in_stock,
reorder_level
from products
where units_in_stock <= reorder_level

-- Freight analysis

--top 5 highest freight charges

select * from orders
order by freight desc
limit 5

--using avrage
select 
ship_country,
avg(freight) as avg_freight
from orders
group by ship_country
order by 2 desc
limit 5

--top 5 freight charges in 1997
select * from orders
where order_date between '1997-01-01' and '1997-12-31'
order by freight desc
limit 5

--or
select 
ship_country,
avg(freight) as avg_freight
from orders
where order_date between '1997-01-01' and '1997-12-31'
group by ship_country
order by 2 desc
limit 5

--top 5 highest freight last year


select * from orders
where extract ('Y' from order_date) = extract ('Y' from current_date) -1
order by freight desc
limit 5

--or
select
ship_country,
avg(freight) as avg_freight
from orders
where extract ('Y' from order_date) = extract ('Y' from current_date) -1
group by ship_country
order by 2 desc
limit 5

-- Customers with no orders

select * from customers

select * from orders

--customers and orderid link

select 
c.customer_id, 
c.contact_name
from customers c
left join orders o on o.customer_id = c.customer_id
where o.order_id is null

--Top customers with total orders amount
--((unit_price * quantity) * (1-discount)) as total_amount

select
c.customer_id,
c.company_name,
sum(((unit_price * quantity) * (1-discount))) as total_amount
from customers c
inner join orders o on o.customer_id = c.customer_id
inner join order_details od on od.order_id = o.order_id
group by c.customer_id,c.company_name
order by 3 desc
limit 5



--Orders with many lines of ordered items

select 
order_id,
count(*) as total_items
from order_details
group by order_id
order by 2 desc


--Orders with double entry line items qt>60

select 
order_id,
quantity
 from order_details
where quantity > 60
group by order_id,quantity
having count(*) > 1
order by order_id


--lets get the details of the items to

with duplicate_order as 
(
    select 
order_id,
quantity
 from order_details
where quantity > 60
group by order_id,quantity
having count(*) > 1
order by order_id
)
select 
*
from order_details 
where order_id in (select order_id from duplicate_order)


-- Late shipped orders by employees

select * from orders
where shipped_date > required_date


--employees with late shipped order

with late_orders as
(
    select * from orders
where shipped_date > required_date
)
select 
e.employee_id,
e.first_name,
e.last_name,
count(*) as total_late_orders
from employees e
inner join late_orders lo on lo.employee_id = e.employee_id
group by e.employee_id,e.first_name,e.last_name
order by 4 desc

-- Countries with customers or suppliers
--customer and supplier info both have country column we will use union

select
distinct country,
'customer' as "user"
from customers

union all

select
distinct country,
'supplier' as "user"
from suppliers
order by country

--using cte

WITH CombinedLocations AS (
    SELECT DISTINCT 
        country, 
        'customer' AS user_type
    FROM customers

    UNION ALL

    SELECT DISTINCT 
        country, 
        'supplier' AS user_type
    FROM suppliers
)
SELECT * 
FROM CombinedLocations
ORDER BY country;

--Customers with multiple orders
--within 4 days

with next_order_date as
(
    select
    customer_id,
    order_date,
    lead(order_date) over (partition by customer_id order by order_date) as next_order_date
    from orders
)
select 
*
from next_order_date
where next_order_date - order_date <=  4 
and next_order_date is not null


--first order from each country
--orders table has ship_country and order_date


WITH RankedOrders AS (
    SELECT 
        ship_country, 
        order_date, 
        order_id,
        customer_id,
        ROW_NUMBER() OVER(PARTITION BY ship_country ORDER BY order_date ASC) as order_rank
    FROM orders
)
SELECT 
    ship_country, 
    order_date, 
    order_id, 
    customer_id
FROM RankedOrders
WHERE order_rank = 1
ORDER BY ship_country;
