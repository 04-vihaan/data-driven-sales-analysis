SELECT CASE WHEN days_late <= 0 THEN '0 on time'
            WHEN days_late <= 3 THEN '1-3d'
            WHEN days_late <= 7 THEN '4-7d'
            WHEN days_late <= 14 THEN '8-14d' ELSE '15d+' END AS bucket,
       COUNT(*) AS orders,
       ROUND(AVG(r.review_score), 2) AS avg_score,
       ROUND(100.0 * AVG((r.review_score = 1)::int), 1) AS pct_1star
FROM orders_clean o
JOIN reviews_clean r USING (order_id)
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1 ORDER BY 1;