--Open the database
USE OlistDB;
GO

--Verify the tables available in the database.
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

--Choose which tables to use and take a look at the 10 first rows of each one to understand the data.
SELECT TOP 10 *
FROM orders;

SELECT TOP 10 *
FROM order_items;

SELECT TOP 10 *
FROM products;

SELECT TOP 10 *
FROM customers;

SELECT TOP 10 *
FROM order_payments;

--Check if data conversion is needed in any table.
SELECT
	TABLE_NAME,
	COLUMN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH,
	IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN('orders', 'order_items', 'products', 'customers', 'order_payments');
--Data conversion is not needed.

--Check for missing or invalid data.
SELECT
	'orders' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
	SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS purchase_timestamp_nulls,
	SUM(CASE WHEN order_purchase_timestamp > GETDATE() THEN 1 ELSE 0 END) AS purchase_timestamp_future_date,
	SUM(CASE WHEN order_purchase_timestamp > order_delivered_customer_date THEN 1 ELSE 0 END) AS delivery_before_purchase
FROM orders;

SELECT
	'order_items' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
	SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
	SUM(CASE WHEN price <=0 THEN 1 ELSE 0 END) AS price_zero_or_negative,
	SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS freight_value_negative
FROM order_items
GROUP BY order_id, order_item_id HAVING COUNT(*) > 1;

SELECT
	'products' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
	SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS product_category_name_nulls
FROM products;

SELECT
	'customers' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
	SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS customer_unique_id_nulls,
	SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS customer_city_nulls,
	SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS customer_state_nulls
FROM customers;

SELECT
	'order_payments' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN payment_value <=0 THEN 1 ELSE 0 END) AS payment_value_zero_or_negative,
	SUM(CASE WHEN payment_installments <=0 THEN 1 ELSE 0 END) AS payment_installments_zero_or_negative
FROM order_payments;

SELECT
	order_status,
	COUNT(*)
FROM orders
GROUP BY order_status;

SELECT
	payment_type,
	COUNT(*)
FROM order_payments
GROUP BY payment_type;
--Problems found.
--products table: column product_category_name has null values.
--order_payments table: payment_value and payment_installments columns have zero or negative values.

--Check for duplicate IDs where applicable
SELECT
	order_id,
	COUNT(*) AS count_duplicate
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
	order_id, order_item_id
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
	product_id,
	COUNT(*) AS count_duplicate
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
	customer_id,
	COUNT(*) AS count_duplicate
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
	order_id, payment_sequential
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
--No problems found.

--Check integrity (ID consistency between tables)
SELECT
	orders.customer_id
FROM orders
LEFT JOIN customers
	ON orders.customer_id = customers.customer_id
WHERE customers.customer_id IS NULL;

SELECT
	order_items.order_id
FROM order_items
LEFT JOIN orders
	ON order_items.order_id = orders.order_id
WHERE orders.order_id IS NULL;

SELECT
	order_items.product_id
FROM order_items
LEFT JOIN products
	ON order_items.product_id = products.product_id
WHERE products.product_id IS NULL;

SELECT
	orders.order_id
FROM orders
LEFT JOIN order_payments
	ON orders.order_id = order_payments.order_id
WHERE order_payments.order_id IS NULL;
--Problems found.
--the order_id bfbd0f9bdef84302105ad712db648a6c is on the orders table, but does not appear on the order_payments table.

--Check for unique pairing where applicable
SELECT
	order_id,
	order_item_id,
	COUNT(*) AS duplicates
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
	order_id,
	payment_sequential,
	COUNT(*) AS duplicates
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
--No problems found.