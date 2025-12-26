--Create and connect to OlistDB database

USE master;
GO

IF NOT EXISTS (
    SELECT * FROM sys.databases WHERE name = 'OlistDB'
)
BEGIN
    CREATE DATABASE OlistDB;
END;
GO

USE OlistDB;
GO

--Create tables to later import data from external files

CREATE TABLE dbo.orders_staging(
	order_id NCHAR(32),
	customer_id NCHAR(32),
	order_status NVARCHAR(12),
	order_purchase_timestamp DATETIME2(0),
	order_approved_at DATETIME2(0),
	order_delivered_carrier_date DATETIME2(0),
	order_delivered_customer_date DATETIME2(0),
	order_estimated_delivery_date DATETIME2(0));

CREATE TABLE dbo.order_items_staging(
	order_id NCHAR(32),
	order_item_id INT,
	product_id NCHAR(32),
	seller_id NCHAR(32),
	shipping_limit_date DATETIME2(0),
	price DECIMAL (10,2),
	freight_value DECIMAL (10,2));

CREATE TABLE dbo.products_staging(
	product_id NCHAR(32),
	product_category_name NVARCHAR(46),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT);

CREATE TABLE dbo.customers_staging(
	customer_id NCHAR(32),
	customer_unique_id NCHAR(32),
	customer_zip_code_prefix NVARCHAR(5),
	customer_city NVARCHAR(32),
	customer_state NCHAR(2));

CREATE TABLE dbo.order_payments_staging(
	order_id NCHAR(32),
	payment_sequential INT,
	payment_type NVARCHAR(11),
	payment_installments INT,
	payment_value DECIMAL (10,2));

--Import data from .csv files to each table

BULK INSERT dbo.orders_staging
FROM 'C:\SQL_data\olist_orders_dataset.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	ROWTERMINATOR = '0x0A');

BULK INSERT dbo.order_items_staging
FROM 'C:\SQL_data\olist_order_items_dataset.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	ROWTERMINATOR = '0x0A');

BULK INSERT dbo.products_staging
FROM 'C:\SQL_data\olist_products_dataset.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	ROWTERMINATOR = '0x0A');

BULK INSERT dbo.customers_staging
FROM 'C:\SQL_data\olist_customers_dataset.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	ROWTERMINATOR = '0x0A');

BULK INSERT dbo.order_payments_staging
FROM 'C:\SQL_data\olist_order_payments_dataset.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	ROWTERMINATOR = '0x0A');

--Count rows to assure correct import of data

SELECT
	'orders' AS table_name,
	COUNT(*) AS total_rows
FROM dbo.orders_staging
UNION ALL
SELECT
	'order_items' AS table_name,
	COUNT(*) AS total_rows
FROM dbo.order_items_staging
UNION ALL
SELECT
	'products' AS table_name,
	COUNT(*) AS total_rows
FROM dbo.products_staging
UNION ALL
SELECT
	'customers' AS table_name,
	COUNT(*) AS total_rows
FROM dbo.customers_staging
UNION ALL
SELECT
	'order_payments' AS table_name,
	COUNT(*) AS total_rows
FROM dbo.order_payments_staging;
--Expected values, respectively: 99441, 112650, 32951, 99441, and 103886.