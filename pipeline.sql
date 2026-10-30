
CREATE TABLE orders_clean AS
SELECT o.*,
       (order_status = 'canceled') AS is_canceled,
       CASE
         WHEN order_status = 'canceled' THEN 'canceled'
         WHEN order_delivered_customer_date IS NULL THEN 'not_delivered_yet'
         WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'late'
         ELSE 'on_time'
       END AS delivery_status,
       order_delivered_customer_date::date - order_estimated_delivery_date::date AS days_late
FROM olist_orders_dataset o;
ALTER TABLE orders_clean ADD PRIMARY KEY (order_id);

CREATE TABLE reviews_clean AS
SELECT DISTINCT ON (order_id) *
FROM olist_order_reviews_dataset
ORDER BY order_id, review_answer_timestamp DESC, review_id;
ALTER TABLE reviews_clean ADD PRIMARY KEY (order_id);

-- median, not mean: a few bad geocodes drag an average off the map
CREATE TABLE geo_zip AS
SELECT geolocation_zip_code_prefix AS zip_prefix,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY geolocation_lat) AS lat,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY geolocation_lng) AS lng
FROM olist_geolocation_dataset
WHERE geolocation_lat BETWEEN -34 AND 6 AND geolocation_lng BETWEEN -74 AND -34
GROUP BY 1;
ALTER TABLE geo_zip ADD PRIMARY KEY (zip_prefix);
COMMIT;











