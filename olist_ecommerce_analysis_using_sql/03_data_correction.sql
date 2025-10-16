/*Problems found during the data cleaning phase:
- products table: column product_category_name has 610 null values.
- order_payments table: column payment_value has 9 zero or negtive values.
- order_payments table: column payment_installments has 2 zero or negative values.
- orders table: the order_id bfbd0f9bdef84302105ad712db648a6c is on the orders table, but is not on the order_payments table.*/

--Open the database
USE OlistDB;
GO

--1) products table: column product_category_name has 610 null values.
SELECT *
FROM products
WHERE product_category_name IS NULL;
--No change. The rows will be kept as they are.
--The fact the columns product_name_lenght, product_description_lenght, and product_photos_qty are also NULL indicates incomplete product registration.
--Therefore, the option for keeping the values as NULL preserve the semantic meaning of the missing data.

--2) order_payments table: column payment_value has 9 zero or negtive values.
SELECT *
FROM order_payments
WHERE payment_value <= 0;
--the problematic values will be deleted
DELETE FROM order_payments
WHERE payment_value <= 0;
--If a payment is zero, it means no actual money was paid. Then, it makes no sense to keep these rows.

--3) order_payments table: column payment_installments has 2 zero or negative values.
SELECT *
FROM order_payments
WHERE payment_installments <= 0;
--The 0 values will be updated to 1.
UPDATE order_payments
SET payment_installments = 1
WHERE payment_installments <= 0;
--Since the payment_values are bigger than 0, it is not correct to remove this values.
--Instead, a better approach is to consider them as a single payment.

--4) orders table: the order_id bfbd0f9bdef84302105ad712db648a6c is on the orders table, but is not on the order_payments table.
SELECT
	orders.order_id
FROM orders
LEFT JOIN order_payments
	ON orders.order_id = order_payments.order_id
WHERE order_payments.order_id IS NULL;
--After completing correction steps 2, there are a total of 4 problematic order_id values.
SELECT *
FROM orders
WHERE
	order_id = 'c8c528189310eaa44a745b8d9d26908b'
	OR order_id = '4637ca194b6387e2d538dc89b124b0ee'
	OR order_id = 'bfbd0f9bdef84302105ad712db648a6c'
	OR order_id = '00b1cb0320190ca0daa2c88b35206009';

SELECT *
FROM order_items
WHERE
	order_id = 'c8c528189310eaa44a745b8d9d26908b'
	OR order_id = '4637ca194b6387e2d538dc89b124b0ee'
	OR order_id = 'bfbd0f9bdef84302105ad712db648a6c'
	OR order_id = '00b1cb0320190ca0daa2c88b35206009';

SELECT *
FROM order_payments
WHERE
	order_id = 'c8c528189310eaa44a745b8d9d26908b'
	OR order_id = '4637ca194b6387e2d538dc89b124b0ee'
	OR order_id = 'bfbd0f9bdef84302105ad712db648a6c'
	OR order_id = '00b1cb0320190ca0daa2c88b35206009';
--the problematic values will be deleted from all tables where they appear
DELETE FROM orders
WHERE
	order_id = 'c8c528189310eaa44a745b8d9d26908b'
	OR order_id = '4637ca194b6387e2d538dc89b124b0ee'
	OR order_id = 'bfbd0f9bdef84302105ad712db648a6c'
	OR order_id = '00b1cb0320190ca0daa2c88b35206009';

DELETE FROM order_items
WHERE
	order_id = 'c8c528189310eaa44a745b8d9d26908b'
	OR order_id = '4637ca194b6387e2d538dc89b124b0ee'
	OR order_id = 'bfbd0f9bdef84302105ad712db648a6c'
	OR order_id = '00b1cb0320190ca0daa2c88b35206009';
--It will keep the dataset consistent, where every order having at least one payment.
--Since only 4 values were deleted, the effect on the dataset will be minimal.