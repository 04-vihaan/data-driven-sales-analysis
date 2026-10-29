-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

SELECT *
FROM olist_customers

-- Creating another table in which we'll be doing all the changes --
CREATE TABLE olist_customer_cleaned (LIKE olist_customers INCLUDING ALL)

INSERT INTO olist_customer_cleaned
Select *
FROM olist_customers

-- Checking for Duplicates -- 

WITH duplicate as (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) as row_num
FROM olist_customer_cleaned
)

Select *
from duplicate
where row_num > 1


/* This database assigns customer_id for a particular order_id
There are duplicates in the customer_unique_id because if one unique user orders
multiple things at different dates/address then he will be given a new customer_id
but the customer_unique_id will be the same.
So, here we'll not do anything and we will remove the cancelled orders etc. on the
other datasets
*/

-- Standardizing data -- 

SELECT DISTINCT customer_city 
FROM olist_customer_cleaned 
ORDER BY customer_city

SELECT DISTINCT TRIM(customer_city) 
FROM olist_customer_cleaned 
ORDER BY TRIM(customer_city)

-- No inconsistency with the customer city 

SELECT DISTINCT customer_state
FROM olist_customer_cleaned 
order by customer_state 

SELECT DISTINCT TRIM(customer_state) 
FROM olist_customer_cleaned 
order by TRIM(customer_state) 

-- No inconsistency with the customer state

SELECT DISTINCT customer_unique_id
FROM olist_customer_cleaned 
order by customer_unique_id

SELECT DISTINCT TRIM(customer_unique_id) 
FROM olist_customer_cleaned 
order by TRIM(customer_unique_id)

-- No inconsistency with the customer unique id

SELECT DISTINCT customer_id
FROM olist_customer_cleaned 
order by customer_id

SELECT DISTINCT TRIM(customer_id) 
FROM olist_customer_cleaned 
order by TRIM(customer_id)

-- No inconsistency with the customer id

-- NULL and Blank Values --
SELECT *
FROM olist_customer_cleaned
WHERE customer_id is NULL or customer_id = ''

SELECT *
FROM olist_customer_cleaned
WHERE customer_unique_id is NULL or customer_unique_id = ''

SELECT *
FROM olist_customer_cleaned
WHERE customer_zip_code_prefix is NULL 

SELECT *
FROM olist_customer_cleaned
WHERE customer_city is NULL or customer_city = ''

SELECT *
FROM olist_customer_cleaned
WHERE customer_state is NULL or customer_state = ''

-- No NULL or BLANK values in this table
-- Also we have checked the Quarto Centenario inconsistency which was present in geolocations' dataset -- 
-- We've checked the inconsistencies in the table --
-- END -- 



