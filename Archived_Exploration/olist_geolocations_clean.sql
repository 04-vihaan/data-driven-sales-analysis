-- Data Cleaning

-- 1. Removing Duplicates
-- 2. Standardize Data
-- 3. Null or Blank Values
-- 4. Remove any unnecessary columns

CREATE EXTENSION IF NOT EXISTS unaccent

SELECT *
FROM olist_geolocations

-- Creating another table in which we'll be doing all the changes --
CREATE TABLE olist_geolocations_cleaned (LIKE olist_geolocations INCLUDING ALL)

INSERT INTO olist_geolocations_cleaned
Select *
FROM olist_geolocations

SELECT *
FROM olist_geolocations_cleaned

-- Checking for duplicates --

WITH duplicate AS (
    SELECT ctid,
           ROW_NUMBER() OVER (
               PARTITION BY zip_code_prefix, lat, lng, city, state
               ORDER BY zip_code_prefix
           ) AS row_num
    FROM olist_geolocations_cleaned
)
DELETE FROM olist_geolocations_cleaned
WHERE ctid IN (
    SELECT ctid
    FROM duplicate
    WHERE row_num > 1
)

Select *
from duplicate
where row_num > 1

-- Around 263000 duplicates deleted --

-- Standardizing Data -- 

SELECT DISTINCT zip_code_prefix 
FROM olist_geolocations_cleaned 
ORDER BY zip_code_prefix

SELECT DISTINCT TRIM(zip_code_prefix) 
FROM olist_geolocations_cleaned 
ORDER BY TRIM(zip_code_prefix)

-- No inconsistency with the zip_code_prefix

CREATE TABLE ordinal_map (
  num   INTEGER PRIMARY KEY,
  word  TEXT NOT NULL      -- UNACCENTed, lower-case
)

INSERT INTO ordinal_map (num, word) VALUES
  (1,  'primeiro'),
  (2,  'segundo'),
  (3,  'terceiro'),
  (4,  'quarto'),
  (5,  'quinto'),
  (6,  'sexto'),
  (7,  'setimo'),
  (8,  'oitavo'),
  (9,  'nono'),
  (10, 'decimo'),
  (11, 'decimo primeiro'),
  (12, 'decimo segundo'),
  (13, 'decimo terceiro'),
  (14, 'decimo quarto'),
  (15, 'decimo quinto'),
  (16, 'decimo sexto'),
  (17, 'decimo setimo'),
  (18, 'decimo oitavo'),
  (19, 'decimo nono'),
  (20, 'vigesimo'),
  (30, 'trigesimo'),
  (40, 'quadragesimo'),
  (50, 'quinquagesimo'),
  (60, 'sexagesimo'),
  (70, 'septuagesimo'),
  (80, 'octogesimo'),
  (90, 'nonagesimo'),
  (100,'centesimo')


ALTER TABLE olist_geolocations_cleaned 
ADD city_base varchar(100)

UPDATE olist_geolocations_cleaned
SET city_base = unaccent(LOWER(TRIM(REGEXP_REPLACE(city, '[^a-zA-Z0-9À-ÿ\s]+', '', 'g'))))

select * 
from olist_geolocations_cleaned
order by city_base 

CREATE TABLE olist_geolocations_cleaned_backup (LIKE olist_geolocations_cleaned INCLUDING ALL)

INSERT INTO olist_geolocations_cleaned_backup
Select *
FROM olist_geolocations_cleaned

SELECT 
  city_base,
  substring(city_base FROM 1 FOR 2) AS first_two_chars
FROM olist_geolocations_cleaned
WHERE city_base ILIKE '4o%'

UPDATE olist_geolocations_cleaned geo
SET city_base = REGEXP_REPLACE(
    city_base,
    '^(\d+)(?:º|°|o\.?)?\s',
    om.word || ' '
)
FROM ordinal_map om
WHERE
  city_base ~ '^\d+(?:º|°|o\.?)?\s' AND
  om.num = substring(city_base FROM '^(\d+)')::int

SELECT * 
FROM olist_geolocations_cleaned 
where city_base like ('quarto centenario')

-- by this we removed all the accents and replaced 4o and 4 to quarto using the ordinal map --

ALTER TABLE olist_geolocations_cleaned 
DROP COLUMN city

-- NULL and BLANK VALUES -- 
SELECT *
FROM olist_geolocations_cleaned
WHERE zip_code_prefix is NULL or zip_code_prefix = ''

SELECT *
FROM olist_geolocations_cleaned
WHERE lat is NULL or lng is NULL

SELECT *
FROM olist_geolocations_cleaned
WHERE state is NULL or state = ''

SELECT *
FROM olist_geolocations_cleaned
WHERE city_base is NULL or city_base = ''

-- NO NULL or BLANK values --
-- We've checked the inconsistencies and corrected in the table --
-- END -- 