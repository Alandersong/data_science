/*Purpose:
Answer key business questions using cleaned Olist data.
Notes:
- Monetary values are formatted for pt-BR locale
- Aggregations are performed on numeric values before formatting
- Revenue is normalized at order level to avoid duplication*/

--Open the database
USE OlistDB;
GO

--Business questions

--What is the total revenue and order count per month?
WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_revenue
    FROM dbo.order_payments
    GROUP BY order_id
)
SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS [month],
    FORMAT(COUNT(DISTINCT p.order_id), 'N0', 'pt-BR') AS total_orders,
    FORMAT(SUM(p.order_revenue), 'C', 'pt-BR') AS total_revenue
FROM dbo.orders o
JOIN payments_per_order p
    ON o.order_id = p.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY [month];

--What are the most common payment types, and how do installment patterns affect revenue?
SELECT
    payment_type,
    FORMAT(COUNT(DISTINCT order_id), 'N0', 'pt-BR') AS total_orders,
    FORMAT(SUM(payment_value), 'C', 'pt-BR') AS total_revenue,
    ROUND(AVG(payment_installments),2) AS avg_installments
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY SUM(payment_value) DESC;

--How long does delivery take from purchase to delivery date, and how has that changed over time?
SELECT
    order_status,
    ROUND(AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)),2) AS avg_delivery_days,
    MAX(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS max_delivery_days,
    MIN(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS min_delivery_days
FROM dbo.orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY order_status
ORDER BY avg_delivery_days;

SELECT
    FORMAT (order_purchase_timestamp, 'yyyy-MM') AS [month],
    ROUND(AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)),2) AS avg_delivery_days,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY FORMAT (order_purchase_timestamp, 'yyyy-MM')
ORDER BY [month];

--Which states/cities have the highest number of orders and revenue?
WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_revenue
    FROM dbo.order_payments
    GROUP BY order_id
)
SELECT
    c.customer_state,
    FORMAT(COUNT(DISTINCT o.order_id), 'N0', 'pt-BR') AS total_orders,
    FORMAT(SUM(p.order_revenue), 'C', 'pt-BR') AS total_revenue
FROM dbo.orders o
JOIN dbo.customers c
    ON o.customer_id = c.customer_id
JOIN payments_per_order p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY SUM(p.order_revenue) DESC;

WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_revenue
    FROM dbo.order_payments
    GROUP BY order_id
)
SELECT
    c.customer_city,
    FORMAT(COUNT(DISTINCT o.order_id), 'N0', 'pt-BR') AS total_orders,
    FORMAT(SUM(p.order_revenue), 'C', 'pt-BR') AS total_revenue
FROM dbo.orders o
JOIN dbo.customers c
    ON o.customer_id = c.customer_id
JOIN payments_per_order p
    ON o.order_id = p.order_id
GROUP BY c.customer_city
ORDER BY SUM(p.order_revenue) DESC;

--Which product categories generate the most revenue and sales?
WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_revenue
    FROM dbo.order_payments
    GROUP BY order_id
),
items_with_revenue AS (
    SELECT
        oi.order_id,
        oi.product_id,
        p.order_revenue / COUNT(*) OVER (PARTITION BY oi.order_id) AS item_revenue
    FROM dbo.order_items oi
    JOIN payments_per_order p
        ON oi.order_id = p.order_id
)
SELECT
    pr.product_category_name,
    FORMAT(COUNT(DISTINCT iwr.order_id), 'N0', 'pt-BR') AS total_orders,
    FORMAT(SUM(iwr.item_revenue), 'C', 'pt-BR') AS total_revenue
FROM items_with_revenue iwr
LEFT JOIN dbo.products pr
    ON iwr.product_id = pr.product_id
WHERE pr.product_category_name IS NOT NULL
GROUP BY pr.product_category_name
ORDER BY SUM(iwr.item_revenue) DESC;

--What is Olist’s total order volume, total revenue, and average delivery duration across all transactions in the dataset?
WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_revenue
    FROM dbo.order_payments
    GROUP BY order_id
)
SELECT
    FORMAT(COUNT(DISTINCT p.order_id), 'N0', 'pt-BR') AS total_orders,
    FORMAT(SUM(p.order_revenue), 'C', 'pt-BR') AS total_revenue,
    ROUND(AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)),2) AS avg_delivery_days
FROM dbo.orders o
JOIN payments_per_order p
    ON o.order_id = p.order_id
WHERE o.order_delivered_customer_date IS NOT NULL;