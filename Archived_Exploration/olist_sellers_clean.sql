-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

CREATE EXTENSION IF NOT EXISTS unaccent

SELECT *
FROM olist_sellers

CREATE TABLE olist_sellers_cleaned (LIKE olist_sellers INCLUDING ALL)

INSERT INTO olist_sellers_cleaned
Select *
FROM olist_sellers

SELECT *
FROM olist_sellers_cleaned

-- CHECKING FOR DUPLICATES -- 
WITH duplicate as (
SELECT *, Row_number() over(Partition by seller_id) as row_num
from olist_sellers_cleaned 
)

SELECT *
FROM duplicate
WHERE row_num > 1

-- No Duplicates -- 

-- Standardising Data -- 

SELECT DISTINCT seller_city
FROM olist_sellers_cleaned
ORDER BY seller_city

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch

SELECT 
  DISTINCT a.seller_city AS city_1,
  b.seller_city AS city_2,
  levenshtein(a.seller_city, b.seller_city) AS distance
FROM olist_sellers_cleaned a
JOIN  olist_sellers_cleaned b ON a.seller_city < b.seller_city
WHERE levenshtein(a.seller_city, b.seller_city) <= 2
ORDER BY distance, city_1, city_2

-- Assigning city values based on frquency of the city and we assume that correct city has greater frquency than wrong -- 

CREATE TABLE city_standard_map (
  wrong_city TEXT PRIMARY KEY,
  correct_city TEXT
)

WITH city_counts AS (
  SELECT 
    LOWER(TRIM(seller_city)) AS city,
    COUNT(*) AS freq
  FROM olist_sellers_cleaned_2
  GROUP BY 1
),
levenshtein_matches AS (
  SELECT 
    a.city AS city_1,
    b.city AS city_2,
    a.freq AS freq_1,
    b.freq AS freq_2,
    levenshtein(a.city, b.city) AS distance
  FROM city_counts a
  JOIN city_counts b ON a.city < b.city
  WHERE levenshtein(a.city, b.city) <= 1
  AND (
      a.freq >= b.freq * 3 OR
      b.freq >= a.freq * 3
    )
    AND (a.freq < 150 AND b.freq < 150)
),
resolved_pairs AS (
  SELECT 
    CASE 
      WHEN freq_1 >= freq_2 THEN city_2
      ELSE city_1
    END AS wrong_city,

    CASE 
      WHEN freq_1 >= freq_2 THEN city_1
      ELSE city_2
    END AS correct_city

FROM levenshtein_matches
)


INSERT INTO city_standard_map (wrong_city, correct_city)
SELECT DISTINCT wrong_city, correct_city
FROM resolved_pairs
WHERE wrong_city != correct_city
ON CONFLICT (wrong_city) DO NOTHING

CREATE TABLE olist_sellers_cleaned_2 (LIKE olist_sellers_cleaned INCLUDING ALL)

INSERT INTO olist_sellers_cleaned_2
Select *
FROM olist_sellers_cleaned

UPDATE olist_sellers_cleaned s
SET seller_city = m.correct_city
FROM city_standard_map m
WHERE LOWER(TRIM(s.seller_city)) = m.wrong_city

/* This is one way of removing inconsistency but not the most accurate because of this 
there might be cities which have extremely similar names like mage and bage which are distinct but the function will count them as typos.
So, for that we have added a layer of safety but because of that our correction gets smaller */ 

SELECT *
FROM olist_sellers_cleaned
