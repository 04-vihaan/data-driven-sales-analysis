-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

CREATE EXTENSION IF NOT EXISTS unaccent

SELECT *
FROM olist_orders_dataset

CREATE TABLE olist_orders_cleaned (LIKE olist_orders_dataset INCLUDING ALL)

INSERT INTO olist_orders_cleaned
Select *
FROM olist_orders_dataset

SELECT *
FROM olist_orders_cleaned

-- CHECKING FOR DUPLICATES -- 
WITH duplicate as (
SELECT *, Row_number() over(Partition by order_id, customer_id) as row_num
from olist_orders_cleaned 
)

SELECT *
FROM duplicate
WHERE row_num > 1

-- NO DUPLICATES -- 

-- STANDARDISING DATA -- 

SELECT *
FROM olist_orders_cleaned
WHERE order_status in ('canceled','cancelled') and order_delivered_customer_date is not null

/* Here I am assuming that the orders that have delivered to the customer are inconsistency becuase I don't have the data for the refunds and 
the orders which have not be delivered are the orders which have be cancelled */

UPDATE olist_orders_cleaned 
SET order_status = 'delivered'
WHERE order_status in ('canceled','cancelled') and order_delivered_customer_date is not null

DELETE FROM olist_orders_cleaned
WHERE order_status in ('canceled','cancelled')

--Removed the cancelled orders -- 

SELECT DISTINCT order_status
FROM olist_orders_cleaned 

SELECT DISTINCT order_id
FROM olist_orders_cleaned
order by order_id


SELECT *
FROM olist_orders_cleaned
WHERE order_status = 'delivered' and order_delivered_customer_date is null

SELECT *
FROM olist_orders_cleaned
WHERE order_status = 'invoiced' and order_approved_at is null 

SELECT *
FROM olist_orders_cleaned
WHERE order_status = 'created' 

SELECT *
FROM olist_orders_cleaned
WHERE order_status = 'approved'

SELECT *
FROM olist_orders_cleaned
WHERE order_status = 'unavailable'

SELECT *
FROM olist_orders_cleaned
WHERE order_status = 'shipped' and order_delivered_carrier_date is null

/* The only thing is that some order are labeled as delivered but we don't have a delivery date for them. 
So, I am changing their order_status to that corresponding to other order_status
and some of the order_status are unavailable, I'll be keeping them as it is as it may be either at approved or invoiced state*/

UPDATE olist_orders_cleaned 
SET order_status = 'shipped'
WHERE order_status = 'delivered' and order_delivered_customer_date is null and order_delivered_carrier_date is not null

UPDATE olist_orders_cleaned 
SET order_status = 'unavailable'
WHERE order_status = 'delivered' and order_delivered_customer_date is null and order_delivered_carrier_date is null

SELECT *, DATE(order_purchase_timestamp) as purchase_date , DATE(order_delivered_customer_date) as delivery_date
FROM olist_orders_cleaned

ALTER TABLE olist_orders_cleaned
ADD purchase_date date 

ALTER TABLE olist_orders_cleaned
ADD delivery_date date 

UPDATE olist_orders_cleaned
SET purchase_date = DATE(order_purchase_timestamp)

UPDATE olist_orders_cleaned
SET delivery_date = DATE(order_delivered_customer_date)

-- CHECKING FOR NULL or BLANK Values -- 

SELECT *
FROM olist_orders_cleaned
WHERE order_status = '' and order_status is null

SELECT *
FROM olist_orders_cleaned
WHERE customer_id = '' and customer_id is null

SELECT *
FROM olist_orders_cleaned
WHERE order_id = '' and order_id is null

SELECT *
FROM olist_orders_cleaned
WHERE  order_purchase_timestamp is null

SELECT *
FROM olist_orders_cleaned
WHERE  order_approved_at is null and order_status not in ('created')

--  Some delivered orders may have missing approval timestamps. These do not affect total counts but may affect detailed delivery time breakdowns. -- 

CREATE TABLE olist_orders_cleaned_2 (LIKE olist_orders_cleaned INCLUDING ALL)

INSERT INTO olist_orders_cleaned_2
Select *
FROM olist_orders_cleaned 

ALTER TABLE olist_orders_cleaned_2
DROP COLUMN order_purchase_timestamp,
DROP COLUMN order_approved_at,
DROP COLUMN order_delivered_carrier_date,
DROP COLUMN order_delivered_customer_date,
DROP COLUMN order_estimated_delivery_date

Select *
FROM olist_orders_cleaned_2

-- END -- 
