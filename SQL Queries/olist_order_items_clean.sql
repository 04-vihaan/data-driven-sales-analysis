-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

CREATE EXTENSION IF NOT EXISTS unaccent

SELECT *
FROM olist_order_items

-- Creating another table in which we'll be doing all the changes --
CREATE TABLE olist_order_items_cleaned (LIKE olist_order_items INCLUDING ALL)

INSERT INTO olist_order_items_cleaned
Select *
FROM olist_order_items

SELECT *
FROM olist_order_items_cleaned

-- Checking for Duplicates -- 

/* 
order_item_id tells us the number of products in an order. Now the products maybe same or different or from same or different seller.
So, we don't have to remove anything as that can be found out from other datasets 
like the order_payments or the orders_dataset that whether the full payment was done or whether the order was cancelled or not.
*/

-- NULL and Blank Values --

SELECT * 
FROM olist_order_items_cleaned
WHERE price is null or price = 0

SELECT * 
FROM olist_order_items_cleaned
WHERE freight_value is null or freight_value = 0

SELECT * 
FROM olist_order_items_cleaned 
WHERE order_id in (select order_id from olist_order_items_cleaned where order_item_id > 1 and freight_value = 0)

SELECT * 
FROM olist_order_items_cleaned
WHERE  shipping_limit_date is null 

-- No NULL or BLANK values here -- 

UPDATE olist_order_items_cleaned 
SET order_id = trim(order_id), product_id = trim(product_id), seller_id = trim(seller_id)

SELECT count(DISTINCT order_id)
FROM olist_order_items_cleaned

SELECT count(DISTINCT order_id)
from olist_order_items_cleaned 
where order_item_id > 1

-- No inconsistencies should be left in the dataset -- 
-- Now what we can do is we can extract the date separately without time -- 

SELECT shipping_limit_date, DATE(shipping_limit_date) as shipping_date 
FROM olist_order_items_cleaned

ALTER TABLE olist_order_items_cleaned 
ADD shipping_date date;

UPDATE olist_order_items_cleaned 
SET shipping_date = DATE(shipping_limit_date)

SELECT * 
FROM olist_order_items_cleaned 

-- 	We've added another separate column for the date -- 