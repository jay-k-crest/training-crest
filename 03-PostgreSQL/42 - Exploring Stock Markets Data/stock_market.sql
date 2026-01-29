
--first or last 10 records

select
*
from stocks_prices
where
    symbol_id =10
order by
    price_date desc
offset 10
limit 10

--Get first or last record per each group

select
 symbol_id,
 min(price_date) as price_date
from
   stocks_prices
group by
    symbol_id

--or 

select
 symbol_id,
 max(price_date) as price_date
from
   stocks_prices
group by
    symbol_id

-- How to calculate cube root in PostgreSQL?

select cbrt(27) as cuberroot

select
    close_price,
    cbrt(close_price)
from
    stocks_prices
where 
    symbol_id = 1
order by price_date desc