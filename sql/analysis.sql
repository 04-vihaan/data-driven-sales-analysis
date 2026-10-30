-- 1. SEVERITY DROP-OFF: How do review scores degrade as days late increase?
WITH delivered AS (
  SELECT order_id, customer_id,
         (order_delivered_customer_date::date - order_estimated_delivery_date::date) AS days_late
  FROM olist_orders_dataset
  WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
),
latest_review AS (
  SELECT DISTINCT ON (order_id) order_id, review_score
  FROM olist_order_reviews_dataset
  ORDER BY order_id, review_answer_timestamp DESC
)
SELECT CASE WHEN days_late <= 0  THEN '0 on time'
            WHEN days_late <= 3  THEN '1-3d'
            WHEN days_late <= 7  THEN '4-7d'
            WHEN days_late <= 14 THEN '8-14d'
            ELSE '15d+' END                          AS late_bucket,
       COUNT(*)                                      AS orders,
       ROUND(AVG(review_score), 2)                   AS avg_score,
       ROUND(100.0 * AVG((review_score = 1)::int), 1) AS pct_1_star
FROM delivered
JOIN latest_review USING (order_id)
GROUP BY 1
ORDER BY MIN(days_late);

-- 2. STATE BOTTLENECKS: Which customer states experience the highest late rates?
WITH delivered AS (
  SELECT order_id, customer_id,
         (order_delivered_customer_date::date - order_estimated_delivery_date::date > 0) AS is_late
  FROM olist_orders_dataset
  WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
)
SELECT c.customer_state,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(d.is_late::int), 1) AS late_rate
FROM delivered d
JOIN olist_customers_dataset c USING (customer_id)
GROUP BY 1
ORDER BY late_rate DESC
LIMIT 5;

-- 3. REVENUE AT RISK: How much sales value is tied up in late orders? (Excludes freight)
WITH delivered AS (
  SELECT order_id,
         (order_delivered_customer_date::date - order_estimated_delivery_date::date > 0) AS is_late
  FROM olist_orders_dataset
  WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
)
SELECT ROUND(SUM(i.price)) AS total_delivered_sales,
       ROUND(SUM(CASE WHEN d.is_late THEN i.price ELSE 0 END)) AS late_orders_value,
       ROUND(100.0 * SUM(CASE WHEN d.is_late THEN i.price ELSE 0 END) / SUM(i.price), 1) AS pct_late_value
FROM delivered d
JOIN olist_order_items_dataset i USING (order_id);