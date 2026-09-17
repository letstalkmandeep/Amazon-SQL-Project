-- Creating Tabling

-- Create Table - Category
drop table if exists category;
create table category (
	category_id int primary key,
	category_name varchar(50)	
);

truncate table category;
COPY category
FROM 'C:\Temp\dataset\category.csv'
DELIMITER ','
CSV HEADER
;

-- Create table - Customers

drop table if exists customers;
create table customers (
	customer_id int primary key,
	first_name varchar(50),
	last_name varchar(50),
	state varchar(50)
);

truncate table customers;
COPY customers
FROM 'C:\Temp\dataset\customers.csv'
DELIMITER ','
CSV HEADER
;

-- Create table - products

drop table if exists products;
create table products (
	product_id int primary key,
	product_name varchar(100),
	price float,
	cogs float,
	category_id int not null
);

truncate table products;
copy products
from 'C:\Temp\dataset\products.csv'
delimiter ','
csv header;

-- Create table - Inventory

drop table if exists inventory;
create table inventory (
	inventory_id int primary key,
	product_id int, -- FK
	stock int,
	warehouse_id int,
	last_stock_date date
);

truncate table inventory;
COPY inventory
FROM 'C:\Temp\dataset\inventory.csv'
DELIMITER ','
CSV HEADER;

-- Create table - sellers

drop table if exists sellers;
create table sellers (
	seller_id int not null,
	seller_name varchar(50),
	origin varchar(50)
);

truncate table sellers;
copy sellers
from 'C:\Temp\dataset\sellers.csv'
delimiter ','
csv header;

-- Create table - orders

drop table if exists orders;
create table orders (
	order_id int primary key,
	order_date date,
	customer_id int not null, -- FK
	seller_id int not null, -- FK
	order_status varchar(50)
);

truncate table orders;
copy orders
from 'C:\Temp\dataset\orders.csv'
delimiter ','
csv header;

-- Create table - order_items

drop table if exists order_items;
create table order_items(
	order_item_id int primary key,
	order_id int not null, --FK
	product_id int not null, -- FK
	quantity int,
	price_per_unit float
);

truncate table order_items;
COPY order_items
from 'C:\Temp\dataset\order_items.csv'
delimiter ','
csv header;

-- Create table - payments

drop table if exists payments;
create table payments (
	payment_id int primary key,
	order_id int not null, --FK
	payment_date date,
	payment_status varchar(50)
);

truncate table payments;
copy payments
from 'C:\Temp\dataset\payments.csv'
delimiter ','
csv header;

-- Create table - Shipping

drop table if exists shipping;
create table shipping (
	shipping_id int primary key,
	order_id int not null, -- FK
	shipping_date date,
	return_date date,
	shipping_provider varchar(50),
	delivery_status varchar(50)
);

truncate table shipping;
copy shipping
from 'C:\Temp\dataset\shipping.csv'
delimiter ','
csv header;
