-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

CREATE EXTENSION IF NOT EXISTS unaccent

SELECT *
FROM olist_order_payments

CREATE TABLE olist_order_payments_cleaned (LIKE olist_order_payments INCLUDING ALL)

INSERT INTO olist_order_payments_cleaned
Select *
FROM olist_order_payments

WITH duplicate as (
SELECT *, Row_number() over(Partition by order_id, payment_type, payment_installments, payment_value) as row_num
from olist_order_payments_cleaned 
)

SELECT *
FROM duplicate
WHERE row_num > 1

-- No duplicates -- 

SELECT DISTINCT payment_type
FROM olist_order_payments_cleaned  
ORDER BY payment_type

SELECT *
FROM olist_order_payments_cleaned 
WHERE payment_type = 'not_defined'

DELETE from olist_order_payments_cleaned
WHERE payment_type = 'not_defined'

SELECT DISTINCT order_id 
FROM olist_order_payments_cleaned 
ORDER BY order_id

SELECT DISTINCT TRIM(order_id) 
FROM olist_order_payments_cleaned 
ORDER BY TRIM(order_id)

-- No inconsitencies with data as such the minor problems we'll deal in the orders_dataset -- 

-- NULL and Blank Values -- 
SELECT *
FROM olist_order_payments_cleaned
WHERE order_id is NULL or order_id = ''

SELECT *
FROM olist_order_payments_cleaned
WHERE payment_sequential is NULL or payment_sequential = 0

SELECT *
FROM olist_order_payments_cleaned
WHERE payment_type is NULL or payment_type = ''

SELECT *
FROM olist_order_payments_cleaned
WHERE payment_value is NULL or payment_value = 0

DELETE FROM olist_order_payments_cleaned 
WHERE payment_value is NULL or payment_value = 0

-- Removed all the BLANK data -- 



