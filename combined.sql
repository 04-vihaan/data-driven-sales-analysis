-- 1. CLEAN ORDERS: Keep timestamps and derive delivery flags instead of deleting
CREATE TABLE orders_clean AS
SELECT o.*,
       (order_status = 'canceled') AS is_canceled,
       (order_status = 'canceled' AND order_delivered_customer_date IS NOT NULL) AS canceled_but_delivered,
       CASE WHEN order_delivered_customer_date IS NULL THEN 'not_delivered'
            WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'late'
            ELSE 'on_time' END AS delivery_status
FROM olist_orders_dataset o;

-- 2. CLEAN GEOLOCATIONS: Collapse exact duplicates to prevent fan-out in Power BI
CREATE TABLE geo_zip AS
SELECT zip_code_prefix,
       AVG(geolocation_lat) AS lat, 
       AVG(geolocation_lng) AS lng,
       MODE() WITHIN GROUP (ORDER BY geolocation_state) AS state
FROM olist_geolocation_dataset
GROUP BY zip_code_prefix;

-- 3. CLEAN REVIEWS: Keep only the most recent review per order to avoid weighting duplicates
CREATE TABLE reviews_clean AS
SELECT DISTINCT ON (order_id) *
FROM olist_order_reviews_dataset
ORDER BY order_id, review_answer_timestamp DESC;