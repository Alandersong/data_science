/*Problems found during the data cleaning phase:
1) Products table: column product_category_name has 610 null values.
2) Order_payments table: column payment_value has 9 zero or negative values.
3) Order_payments table: column payment_installments has 2 zero or negative values.
4) Orders table: the order_id bfbd0f9bdef84302105ad712db648a6c is on the orders table, but is not on the order_payments table.
- During the correction of the problems, new tables will be created for further analyses, leaving the tables with raw data (_staging) intact.*/

--Open the database
USE OlistDB;
GO

--Solutions:

--1) Products table: column product_category_name has 610 null values.
SELECT *
FROM dbo.products_staging
WHERE product_category_name IS NULL;
--No change. The rows will be kept as they are.
--The fact that the columns product_name_length, product_description_length, and product_photos_qty are also NULL indicates incomplete product registration.
--Therefore, the option for keeping the values as NULL preserve the semantic meaning of the missing data.

CREATE TABLE dbo.products(
	product_id NCHAR(32),
	product_category_name NVARCHAR(46),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
	CONSTRAINT PK_products PRIMARY KEY (product_id));

INSERT INTO dbo.products
SELECT
	product_id,
	product_category_name,
	product_name_length,
	product_description_length,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
FROM dbo.products_staging;

--2) Order_payments table: column payment_value has 9 zero or negative values.
SELECT *
FROM dbo.order_payments_staging
WHERE payment_value <= 0;
--The problematic values will be deleted.
--If a payment is zero, it means no actual money was paid. Then, it makes no sense to keep these rows.

CREATE TABLE dbo.order_payments(
	order_id NCHAR(32),
	payment_sequential INT,
	payment_type NVARCHAR(11),
	payment_installments INT,
	payment_value DECIMAL (10,2)
	CONSTRAINT PK_order_payments PRIMARY KEY (order_id,payment_sequential));

INSERT INTO dbo.order_payments
SELECT
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value
FROM dbo.order_payments_staging
WHERE payment_value > 0;

--3) Order_payments table: column payment_installments has 2 zero or negative values.
SELECT *
FROM order_payments_staging
WHERE payment_installments <= 0;
--The 0 values will be updated to 1.
--Since the payment_values are bigger than 0, it is not correct to remove these values.
--Instead, a better approach is to consider them as a single payment.

UPDATE dbo.order_payments
SET payment_installments = 1
WHERE payment_installments <= 0;

--4) Orders table: the order_id bfbd0f9bdef84302105ad712db648a6c is on the orders table, but is not on the order_payments table.
SELECT
	os.order_id
FROM dbo.orders_staging os
LEFT JOIN dbo.order_payments_staging ops
	ON os.order_id = ops.order_id
WHERE ops.order_id IS NULL;

--After completing the correction of problem 2, there are a total of 4 problematic order_id values.
SELECT
	os.order_id
FROM dbo.orders_staging os
LEFT JOIN dbo.order_payments op
	ON os.order_id = op.order_id
WHERE op.order_id IS NULL;

--The problematic values will be deleted from all tables where they appear
--It will keep the dataset consistent, where every order having at least one payment.
--Since only 4 values will be deleted, the effect on the dataset is minimal.

CREATE TABLE dbo.orders(
	order_id NCHAR(32),
	customer_id NCHAR(32),
	order_status NVARCHAR(12),
	order_purchase_timestamp DATETIME2(0),
	order_approved_at DATETIME2(0),
	order_delivered_carrier_date DATETIME2(0),
	order_delivered_customer_date DATETIME2(0),
	order_estimated_delivery_date DATETIME2(0)
	CONSTRAINT PK_orders PRIMARY KEY (order_id));

INSERT INTO dbo.orders
SELECT
	o.order_id,
	o.customer_id,
	o.order_status,
	o.order_purchase_timestamp,
	o.order_approved_at,
	o.order_delivered_carrier_date,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date
FROM dbo.orders_staging o
WHERE EXISTS (
	SELECT 1
	FROM dbo.order_payments op
	WHERE op.order_id = o.order_id);

CREATE TABLE dbo.order_items(
	order_id NCHAR(32),
	order_item_id INT,
	product_id NCHAR(32),
	seller_id NCHAR(32),
	shipping_limit_date DATETIME2(0),
	price DECIMAL (10,2),
	freight_value DECIMAL (10,2)
	CONSTRAINT PK_order_items PRIMARY KEY (order_id, order_item_id));

INSERT INTO dbo.order_items
SELECT
	ois.order_id,
	ois.order_item_id,
	ois.product_id,
	ois.seller_id,
	ois.shipping_limit_date,
	ois.price,
	ois.freight_value
FROM dbo.order_items_staging ois
WHERE EXISTS (
	SELECT 1
	FROM dbo.order_payments op
	WHERE op.order_id = ois.order_id);

--All problems have been corrected.
--5) Creation of the new customers table for use during the analytical phase.

CREATE TABLE dbo.customers(
	customer_id NCHAR(32),
	customer_unique_id NCHAR(32),
	customer_zip_code_prefix NVARCHAR(5),
	customer_city NVARCHAR(32),
	customer_state NCHAR(2)
	CONSTRAINT PK_customers PRIMARY KEY (customer_id));

INSERT INTO dbo.customers
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
FROM dbo.customers_staging;

--After all tables are created, add foreign keys where applicable.

ALTER TABLE dbo.orders
ADD CONSTRAINT FK_orders_customers
	FOREIGN KEY (customer_id)
	REFERENCES dbo.customers(customer_id);

ALTER TABLE dbo.order_items
ADD
	CONSTRAINT FK_order_items_orders
		FOREIGN KEY (order_id)
		REFERENCES dbo.orders(order_id),
	CONSTRAINT FK_order_items_products
		FOREIGN KEY (product_id)
		REFERENCES dbo.products(product_id);

ALTER TABLE dbo.order_payments
ADD CONSTRAINT FK_orders_payments_orders
	FOREIGN KEY (order_id)
	REFERENCES dbo.orders(order_id);