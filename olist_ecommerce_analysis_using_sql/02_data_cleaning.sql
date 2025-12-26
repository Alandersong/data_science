--Open the database
USE OlistDB;
GO

--Verify the tables available in the database.
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

--Choose which tables to use and take a look at the 10 first rows of each one to understand the data.
SELECT TOP 10 *
FROM dbo.orders_staging;

SELECT TOP 10 *
FROM dbo.order_items_staging;

SELECT TOP 10 *
FROM dbo.products_staging;

SELECT TOP 10 *
FROM dbo.customers_staging;

SELECT TOP 10 *
FROM dbo.order_payments_staging;

--Check if data conversion is needed in any table.
SELECT
	TABLE_NAME,
	COLUMN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH,
	IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN('dbo.orders_staging', 'dbo.order_items_staging', 'dbo.products_staging', 'dbo.customers_staging', 'dbo.order_payments_staging');
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
FROM dbo.orders_staging;

SELECT
	'order_items' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
	SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
	SUM(CASE WHEN price <=0 THEN 1 ELSE 0 END) AS price_zero_or_negative,
	SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS freight_value_negative
FROM dbo.order_items_staging;

SELECT
	'products' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
	SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS product_category_name_nulls
FROM dbo.products_staging;

SELECT
	'customers' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
	SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS customer_unique_id_nulls,
	SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS customer_city_nulls,
	SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS customer_state_nulls
FROM dbo.customers_staging;

SELECT
	'order_payments' AS table_name,
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN payment_value <=0 THEN 1 ELSE 0 END) AS payment_value_zero_or_negative,
	SUM(CASE WHEN payment_installments <=0 THEN 1 ELSE 0 END) AS payment_installments_zero_or_negative
FROM dbo.order_payments_staging;

SELECT
	order_status,
	COUNT(*)
FROM dbo.orders_staging
GROUP BY order_status;

SELECT
	payment_type,
	COUNT(*)
FROM dbo.order_payments_staging
GROUP BY payment_type;
--Problems found.
--products table: column product_category_name has null values.
--order_payments table: payment_value and payment_installments columns have zero or negative values.
--note: timestamps are stored in Brazil local time (UTC-3).

--Check for duplicate IDs where applicable
SELECT
	order_id,
	COUNT(*) AS count_duplicate
FROM dbo.orders_staging
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
	order_id, order_item_id
FROM dbo.order_items_staging
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
	product_id,
	COUNT(*) AS count_duplicate
FROM dbo.products_staging
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
	customer_id,
	COUNT(*) AS count_duplicate
FROM dbo.customers_staging
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
	order_id, payment_sequential
FROM dbo.order_payments_staging
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
--No problems found.

--Check integrity (ID consistency between tables)
SELECT
	dbo.orders_staging.customer_id
FROM dbo.orders_staging
LEFT JOIN dbo.customers_staging
	ON dbo.orders_staging.customer_id = dbo.customers_staging.customer_id
WHERE dbo.customers_staging.customer_id IS NULL;

SELECT
	dbo.order_items_staging.order_id
FROM dbo.order_items_staging
LEFT JOIN dbo.orders_staging
	ON dbo.order_items_staging.order_id = dbo.orders_staging.order_id
WHERE dbo.orders_staging.order_id IS NULL;

SELECT
	dbo.order_items_staging.product_id
FROM dbo.order_items_staging
LEFT JOIN dbo.products_staging
	ON dbo.order_items_staging.product_id = dbo.products_staging.product_id
WHERE dbo.products_staging.product_id IS NULL;

SELECT
	dbo.orders_staging.order_id
FROM dbo.orders_staging
LEFT JOIN dbo.order_payments_staging
	ON dbo.orders_staging.order_id = dbo.order_payments_staging.order_id
WHERE dbo.order_payments_staging.order_id IS NULL;
--Problems found.
--the order_id bfbd0f9bdef84302105ad712db648a6c is on the orders table, but does not appear on the order_payments table.

--Check for unique pairing where applicable
SELECT
	order_id,
	order_item_id,
	COUNT(*) AS duplicates
FROM dbo.order_items_staging
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
	order_id,
	payment_sequential,
	COUNT(*) AS duplicates
FROM dbo.order_payments_staging
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
--No problems found.