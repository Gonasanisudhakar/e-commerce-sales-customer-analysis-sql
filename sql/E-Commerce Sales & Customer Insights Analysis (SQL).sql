create database ecommerce_project;
use ecommerce_project;

-- Tables creation
create table customers(
	customer_id varchar(50),
    customer_unique_id varchar(50),
    customer_zip_code_prefix int,
    customer_city varchar(50),
    customer_state varchar(5)
    );
    
create table orders(
    order_id varchar(50),
    customer_id varchar(50),
    order_status varchar(20),
    order_purchase_timestamp datetime,
    order_approved_at datetime,
    order_delivered_carrier_date datetime,
    order_delivered_customer_date datetime,
    order_estimated_delivery_date datetime
    );
    
 create table order_items(
     order_id varchar(50),
     order_item_id int,
     product_id varchar(50),
     seller_id varchar(50),
     shipping_limit_date datetime,
     price decimal(10,2),
    freight_value decimal(10,2)
    );
    
create table payments(
     order_id varchar(50),
     payment_sequential int,
     payment_type varchar(20),
     payment_installments int,
     payment_value decimal(10,2)
     );
     
CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


-- count rows
select count(*) from customers;  
select count(*) from orders;  
select count(*) from order_items ;  
select count(*) from payments;  
select count(*) from products;  
      
 
  
-- Data cleaning
-- check null values
select 
count(*) as total_rows,
count(*) - count(customer_id) as customer_id_count,
count(*) - count(customer_city) as customer_city_count,
count(*) - count(customer_state) as customer_state_count
from customers;

select 
COUNT(*) AS total_rows,
count(*) - COUNT(order_id) AS order_id_count,
count(*) - COUNT(customer_id) AS customer_id_count,
count(*) - COUNT(order_purchase_timestamp) AS date_count
FROM orders;

select
count(*) as total_rows,
count(*) - count(order_id) as order_id_count,
count(*) - count(product_id) as product_id_count,
count(*) - count(price) as price_count
from order_items;

select 
count(*) as total_counts,
count(*) - count(order_id) as order_id_count,
count(*) - count(payment_value) as payment_value_count
from payments;

select 
count(*) as total_counts,
count(*) - count(product_id) as product_id,
count(*) - count(product_category_name) as product_category_name
from products;


-- check duplicate values

SELECT customer_id, COUNT(*) 
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) 
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id, product_id, COUNT(*) 
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

SELECT order_id, payment_sequential, COUNT(*)
FROM payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) 
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- KPI Analysis
-- 1.Total Revenue
select round(sum(payment_value),2) as total_revenue
from payments;

-- 2.Total orders
select count(distinct order_id) as total_orders
from orders;

-- 3.Total Customers
select count(distinct customer_id) as total_customers
from customers;

-- 4.Average Order Value
select round(sum(payment_value) /count(distinct order_id),2) as avg_order_value
from payments;
 

-- Bussiness quries
-- 1. Revenue by Category
select
p.product_category_name,
ROUND(SUM(pay.total_payment),2) AS revenue
from order_items oi
join  products p ON p.product_id = oi.product_id
join (
    select order_id, SUM(payment_value) AS total_payment
    from payments
    group by  order_id
) pay ON oi.order_id = pay.order_id
group by p.product_category_name
order by revenue desc;

-- 2. Monthly Revenue Trend
select 
date_format(o.order_purchase_timestamp, '%Y-%m') as month,
round(sum(py.payment_value),2) as revenue
 from orders o 
 join payments py on o.order_id = py.order_id
 group by month 
 order by month;
 
 -- 3.Top Customers by Revenue
select 
o.customer_id,
round(sum(py.payment_value),2) as revenue
from orders o
join payments py on  o.order_id = py.order_id
group by o.customer_id
order by revenue desc
limit 10;

-- 4. Orders per Customer
select
customer_id,
count(order_id) as total_orders
from orders 
group by customer_id
order by total_orders desc;

-- 5.Average Items per Orde
select
round(avg(item_count),2)  as avg_items_per_order
from (
SELECT order_id, COUNT(product_id) AS item_count
from order_items
group by order_id
) t;

-- 6.Top Selling Products
select 
product_id,
count(*) as total_orders
from order_items 
group by product_id
order by total_orders desc
limit 10;

-- 7.Category Performance
select
p.product_category_name,
count(*) as total_orders
from order_items oi
join products p on oi.product_id = p.product_id
group by p.product_category_name
order by total_orders desc;

--  CUSTOMER BEHAVIOR ANALYSIS
-- 1.Repeat vs One-time Customers

SELECT 
customer_id,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id;
 
 -- 2. Customers Who Never Ordered
 SELECT c.customer_id
FROM customers c
LEFT JOIN orders o 
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 3. Customer Lifetime Value
-- Total spending per customer
SELECT 
o.customer_id,
ROUND(SUM(p.payment_value),2) AS lifetime_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id;

-- 4. Customer Segmentation
select 
customer_id,
lifetime_value,
case
    when lifetime_value > 500 then "High value"
    when lifetime_value Between 200 and 500 then "Medium value"
    else "Low value"
    end as customer_segment
    from (
          select 
          o.customer_id,
          round(sum(py.payment_value),2) as lifetime_value
          from orders o
          join payments py on o.order_id = py.order_id
          group by o.customer_id
) t;












    
    
    
    