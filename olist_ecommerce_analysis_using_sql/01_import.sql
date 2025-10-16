--Create and connect to OlistDB database
CREATE DATABASE OlistDB;
GO
USE OlistDB;
GO

--Verify data import success
SELECT
	'orders' AS table_name,
	COUNT(*) AS total_rows
FROM olist_orders_dataset
UNION ALL
SELECT
	'order_items',
	COUNT(*)
FROM olist_order_items_dataset
UNION ALL
SELECT
	'products',
	COUNT(*)
FROM olist_products_dataset
UNION ALL
SELECT
	'customers',
	COUNT(*)
FROM olist_customers_dataset
UNION ALL
SELECT
	'order_payments',
	COUNT(*)
FROM olist_order_payments_dataset;

--Manually rename each dataset with shorter names