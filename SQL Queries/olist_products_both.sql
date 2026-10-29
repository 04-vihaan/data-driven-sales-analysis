-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

CREATE EXTENSION IF NOT EXISTS unaccent

SELECT *
FROM olist_products

CREATE TABLE olist_products_cleaned (LIKE olist_products INCLUDING ALL)

INSERT INTO olist_products_cleaned
Select *
FROM olist_products

SELECT *
FROM olist_products_cleaned

-- CHECKING FOR DUPLICATES -- 
WITH duplicate as (
SELECT *, Row_number() over(Partition by product_id, product_category_name) as row_num
from olist_products_cleaned 
)

SELECT *
FROM duplicate
WHERE row_num > 1

-- NO DUPLICATES --

-- STANDARDISING DATA -- 

SELECT DISTINCT product_category_name
FROM olist_products_cleaned 
order by product_category_name

SELECT DISTINCT p.product_category_name
FROM olist_products_cleaned  p left join product_category_name_translation pc on p.product_category_name = pc.product_category_name
where pc.product_category_name is null and p.product_category_name is not null

INSERT INTO product_category_name_translation (product_category_name,product_category_name_english )
VALUES 
('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portables_and_food_processors'),
('pc_gamer', 'pc_gamer')


SELECT *
FROM olist_products_cleaned 
WHERE product_category_name is null

SELECT *
FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id 
WHERE product_category_name  is null

/*
Missing product categories were filled based on seller behavior. 
If a seller sold only one known category, that category was assigned to their uncategorized products. Others remain labeled as 'unknown'.
*/

SELECT oo.seller_id 
FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id 
WHERE product_category_name is null

-- Using above as SubQuery -- 

SELECT oo.seller_id
FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id
WHERE oo.seller_id in 
(
SELECT oo.seller_id 
FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id 
WHERE product_category_name is null
) 
and op.product_category_name is not null 
GROUP BY oo.seller_id
HAVING count(DISTINCT op.product_category_name) = 1
order by oo.seller_id

-- Using above as SubQuery -- 
WITH seller_category_map AS (
SELECT DISTINCT op.product_category_name, oo.seller_id

FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id
WHERE seller_id in 
(
SELECT oo.seller_id
FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id
WHERE oo.seller_id in 

(SELECT oo.seller_id 
FROM olist_products_cleaned op inner join olist_order_items_cleaned oo on op.product_id = oo.product_id 
WHERE product_category_name is null) 

and op.product_category_name is not null 
GROUP BY oo.seller_id
HAVING count(DISTINCT op.product_category_name) = 1
)
and op.product_category_name is not null
)

-- UPDATE THE TABLE USING THE ABOVE CTE -- 

UPDATE olist_products_cleaned p
SET product_category_name = scm.product_category_name
FROM olist_order_items_cleaned oi
JOIN seller_category_map scm ON oi.seller_id = scm.seller_id
WHERE p.product_id = oi.product_id
  AND p.product_category_name IS NULL;

UPDATE olist_products_cleaned
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL


SELECT * 
FROM olist_products_cleaned
WHERE product_category_name is null

/* ALL THE NULL are either unknown or Missing product categories were filled based on seller behavior. 
If a seller sold only one known category, that category was assigned to their uncategorized products. Others remain labeled as 'unknown' */

CREATE TABLE olist_products_cleaned_2 (LIKE olist_products_cleaned INCLUDING ALL)

INSERT INTO olist_products_cleaned_2
Select *
FROM olist_products_cleaned

SELECT *
FROM olist_products_cleaned_2

ALTER TABLE olist_products_cleaned_2
DROP COLUMN product_name_length,
DROP COLUMN product_description_length,
DROP COLUMN product_photos_qty,
DROP COLUMN product_weight_g,
DROP COLUMN product_length_cm,
DROP COLUMN product_height_cm,
DROP COLUMN product_width_cm;



