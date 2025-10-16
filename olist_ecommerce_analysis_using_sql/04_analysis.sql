--Open the database
USE OlistDB;
GO

--Create a consolidated view to make the following analyses easier
CREATE VIEW olist AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_time_days,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    i.product_id,
    pr.product_category_name
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN order_payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS i
    ON o.order_id = i.order_id
LEFT JOIN products AS pr
    ON i.product_id = pr.product_id;

--Business questions

--What is the total revenue and order count per month?
SELECT
    FORMAT(ol.order_purchase_timestamp, 'yyyy-MM') AS month,
    COUNT(DISTINCT ol.order_id) AS total_orders,
    FORMAT(SUM(p.payment_value), 'C', 'pt-BR') AS total_revenue
FROM olist AS ol
JOIN order_payments AS p ON ol.order_id = p.order_id
GROUP BY FORMAT(ol.order_purchase_timestamp, 'yyyy-MM')
ORDER BY month;

--What are the most common payment types, and how do installment patterns affect revenue?
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS num_orders,
    FORMAT(SUM(payment_value), 'C', 'pt-BR') AS total_revenue,
    AVG(payment_installments) AS avg_installments
FROM olist
GROUP BY payment_type
ORDER BY SUM(payment_value) DESC;

--How long does delivery take from purchase to delivery date, and how has that changed over time?
SELECT
    order_status,
    AVG(delivery_time_days) AS avg_delivery_days,
    MAX(delivery_time_days) AS max_delivery_days,
    MIN(delivery_time_days) AS min_delivery_days
FROM olist
WHERE delivery_time_days IS NOT NULL
GROUP BY order_status
ORDER BY avg_delivery_days;

SELECT
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS month,
    AVG(delivery_time_days) AS avg_delivery_days,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist
WHERE delivery_time_days IS NOT NULL
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY month;

--Which states/cities have the highest number of orders and revenue?
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    FORMAT(SUM(payment_value), 'C', 'pt-BR') AS total_revenue
FROM olist
GROUP BY customer_state
ORDER BY SUM(payment_value) DESC;

SELECT
    customer_city,
    COUNT(DISTINCT order_id) AS total_orders,
    FORMAT(SUM(payment_value), 'C', 'pt-BR') AS total_revenue
FROM olist
GROUP BY customer_city
ORDER BY SUM(payment_value) DESC;

--Which product categories generate the most revenue and sales?
SELECT
    product_category_name,
    COUNT(DISTINCT order_id) AS total_orders,
    FORMAT(SUM(payment_value), 'C', 'pt-BR') AS total_revenue
FROM olist
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY SUM(payment_value) DESC;

--What is Olist’s total order volume, total revenue, and average delivery duration across all transactions in the dataset?
SELECT
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(payment_value) AS total_revenue,
  AVG(delivery_time_days) AS avg_delivery_days
FROM olist;