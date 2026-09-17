-- EDA

select * from category;
select * from products;
select * from customers;
select * from inventory;
select * from order_items;
select * from orders;
select * from payments;
select * from sellers;
select * from shipping;


-- complete data and errors check
select * from category as c
full join products as p
on c.category_id = p.category_id
where c.category_id is null;


-- Duplicate products checks
SELECT
	*
FROM
	(
		SELECT
			*,
			COUNT(PRODUCT_NAME) OVER (
				PARTITION BY
					PRODUCT_NAME
				ORDER BY
					PRODUCT_ID
			) AS DUPLICATES
		FROM
			PRODUCTS
	)
WHERE
	DUPLICATES > 1;

-- Updating name of duplicate products

UPDATE products p
SET product_name = CONCAT(p.product_name, ' version ', d.rn)
FROM (
    SELECT 
        product_id,
        ROW_NUMBER() OVER (
            PARTITION BY product_name 
            ORDER BY product_id
        ) AS rn
    FROM products
) d
WHERE p.product_id = d.product_id
  AND d.rn > 1;

-- Product inventory check

select * from products p
full join inventory i
on p.product_id = i.product_id
where p.product_id is null;

-- Product order_items check

select * from products p
full join order_items o
on p.product_id = o.product_id
where o.order_item_id is null
;

-- Price per unit check

select * from products p
full join order_items o
on p.product_id = o.product_id
where price != price_per_unit;

-- Order order_items check

select distinct order_status from orders;

select * from orders o
full join order_items oi
on o.order_id = oi.order_id
where order_item_id is null;

SELECT o.*
FROM orders o
WHERE NOT EXISTS (
    SELECT *
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);

DELETE FROM orders o
WHERE NOT EXISTS (
    SELECT *
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);

-- seller and orders

select distinct origin from sellers;

select * from sellers s
full join orders o
on s.seller_id = o.seller_id
where order_id is null;

-- customers and orders

select * from orders o
full join customers c
on o.customer_id = c.customer_id
where c.customer_id is null;

-- payments and orders

select distinct payment_status from payments;

select * from payments p				-- DATA QUALITY ISSUE SERIOUS
full join orders o
on p.order_id = o.order_id
where p.order_id is null;


-- fixing payment exists but no order placed

delete from payments p
using(
select p2.order_id from payments p2
full join orders o
on p2.order_id = o.order_id
where o.order_id is null
) x
where p.order_id = x.order_id;
--check

select * from payments p2
full join orders o
on p2.order_id = o.order_id
where o.order_id is null;


-- shipping order check

select distinct delivery_status from shipping;

select distinct shipping_provider from shipping;

select * from shipping s
full join orders o
on s.order_id = o.order_id
where s.order_id is null


-- Order status set to inprogress for orders who are not in shipping
update orders o
set order_status = 'Inprogress'
where not exists
(select * from shipping s
where s.order_id = o.order_id);

-- Shipping done but not order

select * from shipping s
full join orders o
on s.order_id = o.order_id
where o.order_id is null;

delete from shipping s
using (
select s2.order_id from shipping s2
full join orders o
on s2.order_id = o.order_id
where o.order_id is null) x
where s.order_id = x.order_id;

-- Shipping Status , order status, patment status

select distinct order_status from orders;
select distinct payment_status from payments;
select distinct delivery_status from shipping;

-- 3 table date check


-- date check
select
	payment_date,
	payment_status,
	order_date,
	order_status,
	shipping_date,
	delivery_status
from payments p
full join orders o
on o.order_id = p.order_id
full join shipping s
on o.order_id = s.order_id
where order_date > shipping_date or order_date > payment_date;

-- shipping and order status check

select
	distinct
	order_status,
	delivery_status
from orders o
inner join shipping s
on o.order_id = s.order_id;


-- Order cancel = Delivery Status cancelled
update shipping s
set delivery_status = 'Cancelled'
from orders o
where s.order_id = o.order_id
 and o.order_status = 'Cancelled';

--Order Inprogress = Delivery status In Transit

update shipping s
set delivery_status = 'In Transit'
from orders o
where s.order_id = o.order_id
and o.order_status = 'Inprogress';

--Order Completed = Delivery status Shipped

update shipping s
set delivery_status = 'Shipped'
from orders o
where s.order_id = o.order_id
and o.order_status = 'Completed';

-- Order Returneed = Delivery Status Returned

update shipping s
set delivery_status = 'Returned'
from orders o
where s.order_id = o.order_id
and o.order_status = 'Returned';

-- payment and order status check

select
	distinct
	order_status,
	payment_status
from orders o
inner join payments p
on o.order_id = p.order_id;

-- Order Returned = Payment Status Returned

update payments p
set payment_status = 'Returned'
from orders o
where p.order_id = o.order_id
and order_status = 'Returned';



-- Order Completed = Payment Status Payment Successed

update payments p
set payment_status = 'Payment Successed'
from orders o
where p.order_id = o.order_id
and order_status = 'Completed';

update payments p
set payment_status = 'Failed'
from orders o
where p.order_id = o.order_id
and order_status = 'Cancelled';

update payments p
set payment_status = 'Unknown'
from orders o
where p.order_id = o.order_id
and order_status = 'Inprogress';
