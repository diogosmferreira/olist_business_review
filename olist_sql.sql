-- .........................................................................................
-- ///1. TABLE CREATION AND DATA UPLOAD ///
-- .........................................................................................
-- ORDERS TABLE

CREATE TABLE orders
	(
	order_id	                    VARCHAR(40)  	 PRIMARY KEY,
    customer_id                     VARCHAR(40)	     NOT NULL,
    order_status                    VARCHAR(15) 	 NOT NULL,
    order_purchase_date             VARCHAR(20),
	order_approved_date             VARCHAR(20),
	order_delivered_carrier_date    VARCHAR(20),
	order_delivered_customer_date	VARCHAR(20),
	order_estimated_delivery_date	VARCHAR(20)
    );

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_orders_dataset.csv"
INTO TABLE orders	
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

-- Because there are empty values in the columns related to dates, and MySQL does not accept '' as dates, the values in these columns were initially loaded as strings. 
-- Later, the empty values were converted to null values, and then the data type of these columns was changed to datetime.

UPDATE orders
SET order_purchase_date = NULL
WHERE order_purchase_date = '';

UPDATE orders
SET order_approved_date = NULL
WHERE order_approved_date = '';

UPDATE orders
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

UPDATE orders
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

UPDATE orders
SET order_estimated_delivery_date = NULL
WHERE order_estimated_delivery_date = '';

ALTER TABLE orders 
MODIFY order_purchase_date DATETIME,
MODIFY order_approved_date DATETIME,
MODIFY order_delivered_carrier_date DATETIME,
MODIFY order_delivered_customer_date DATETIME,
MODIFY order_estimated_delivery_date DATETIME;

DESCRIBE orders;

select * from orders
-- .........................................................................................
-- CUSTOMERS TABLE

CREATE TABLE customers
	(
    customer_id                     VARCHAR(40)	     PRIMARY KEY,
    customer_unique_id              VARCHAR(40) 	 NOT NULL,
    customer_zip_code_prefix        INT				 NOT NULL,
	customer_city                   VARCHAR(40),	 
	customer_state                  VARCHAR(2)
    );
    
LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_customers_dataset.csv"
INTO TABLE customers	
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

DESCRIBE customers;

-- .........................................................................................
-- ORDER ITEMS TABLE

-- In this table, it is evident that no single column can uniquely identify all records in the table.
-- By analyzing the data in Excel, it is possible to observe that an order_id can have multiple order_item_id values, depending on the quantity of products ordered, regardless of the product_id.

-- For example: 

-- order_id: A1B2C3, order_item_id: 1, product_id: A
-- order_id: A1B2C3, order_item_id: 2, product_id: A
-- order_id: A1B2C3, order_item_id: 3, product_id: B

-- Therefore, it has been confirmed that it is possible to uniquely identify all records in the table by creating a composite key formed by the order_id and order_item_id.

CREATE TABLE order_items
	(
	order_id	                    VARCHAR(40)      NOT NULL,  
    order_item_id                   INT	             NOT NULL,
    product_id                      VARCHAR(40) 	 NOT NULL,
    seller_id            		    VARCHAR(40)      NOT NULL,
	shipping_limit_date             DATETIME,
	price                           DECIMAL(8,2)	 NOT NULL,
	freight_value	                DECIMAL(8,2)	 NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
    );

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_order_items_dataset.csv"
INTO TABLE order_items	
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

DESCRIBE order_items;
-- .........................................................................................
-- PRODUCTS TABLE

CREATE TABLE products
	(
	product_id	                    VARCHAR(40)      PRIMARY KEY,  
    product_category_name           VARCHAR(60),
    product_name_length             INT,
    product_description_length      INT,
	product_photos_qty              INT,
	product_weight_g                INT,
	product_length_cm	            INT,
    product_height_cm               INT,
    product_width_cm                INT
    );

-- All empty values in the product_category_name column have been replaced with "desconhecido" in Excel.
-- To load the data, all empty values in columns with the data type "integer" were replaced with 0 using Excel.

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_products_dataset.csv"
INTO TABLE products	
FIELDS TERMINATED BY ";"
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

UPDATE products
SET product_category_name = IF(product_category_name = '', 'desconhecido', product_category_name),
	product_name_length = IF(product_name_length = 0, NULL, product_name_length),
    product_description_length = IF(product_description_length = 0, NULL, product_description_length),
    product_photos_qty = IF(product_photos_qty = 0, NULL, product_photos_qty),
    product_weight_g = IF(product_weight_g = 0, NULL, product_weight_g),
    product_length_cm = IF(product_length_cm = 0, NULL, product_length_cm),
    product_height_cm= IF(product_height_cm = 0, NULL, product_height_cm),
    product_width_cm= IF(product_width_cm= 0, NULL, product_width_cm);

-- in order to be able to store the csv data, empty product_category_name fields were labeled as "desconhecido" and empty product dimensions fields were labeled as NULL

DESCRIBE products;
-- .........................................................................................
-- PAYMENTS TABLE

CREATE TABLE payments
	(
	order_id	                    VARCHAR(40),  
    payment_sequential          	INT,
    payment_type             		VARCHAR(20) NOT NULL,
    payment_installments      		INT NOT NULL,
	payment_value              		DECIMAL(8,2) NOT NULL,
    PRIMARY KEY(order_id, payment_sequential)
    );

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_order_payments_dataset.csv"
INTO TABLE payments	
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

-- In this table, it's evident that no single column can uniquely identify all records in the table.
-- By analyzing the data in Excel, it's possible to observe that if the same order_id have multiple payments, each payment will have a sequential number associated recorded in the payment_sequential column.
-- Therefore, it is possible to identify all records in the table by creating a composite key formed by the order_id and payment_sequential.

DESCRIBE payments;
-- .........................................................................................
-- SELLERS TABLE

CREATE TABLE sellers
	(
	seller_id	                    VARCHAR(40) PRIMARY KEY,  
    seller_zip_code_prefix          INT,
    seller_city             		VARCHAR(60),
    seller_state                    VARCHAR(2)
    );

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_sellers_dataset.csv"
INTO TABLE sellers
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

DESCRIBE payments;

-- .........................................................................................
-- GEOLOCATION TABLE

CREATE TABLE geolocation
	(
    geolocation_id                  INT AUTO_INCREMENT PRIMARY KEY,
	geolocation_zip_code_prefix	    INT NOT NULL,  
    geolocation_lat          		VARCHAR(40) NOT NULL,
    geolocation_lng             	VARCHAR(40) NOT NULL,
    geolocation_city                VARCHAR(40) NOT NULL,
    geolocation_state               VARCHAR(40) NOT NULL
    );

ALTER TABLE geolocation AUTO_INCREMENT = 1;

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_geolocation_dataset.csv"
INTO TABLE geolocation 
FIELDS TERMINATED BY "," 
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

DESCRIBE geolocation;
-- .........................................................................................
-- PRODUCT CATEGORY NAME TRANSLATION TABLE

CREATE TABLE product_category_name_translation
	(
    product_category_name               VARCHAR(50) PRIMARY KEY,
	product_category_name_english	    VARCHAR(50) NOT NULL
    );

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/product_category_name_translation.csv"
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY "," 
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS

INSERT INTO 
	product_category_name_translation
VALUES 
	('desconhecido','unknown');

SELECT *
FROM product_category_name_translation
WHERE product_category_name = 'desconhecido';

-- .........................................................................................
-- REVIEWS TABLE

CREATE TABLE reviews
	(
    review_id                  	VARCHAR(40)    NOT NULL,
	order_id	    			VARCHAR(40)    NOT NULL, 
    review_score          		INT            NOT NULL,
    review_creation_date        DATETIME       NOT NULL,
    review_answer_timestamp     DATETIME       NOT NULL,
    PRIMARY KEY(review_id, order_id)
    );

-- Columns 'review_comment_title' and 'review_comment_message' will not be needed for the analysis, so they were deleted through Excel before loading the data.
-- In order to be able to load date data, the date format was changed to yyyy-mm-dd hh:mm:ss using Excel.

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_order_reviews_dataset.csv"
INTO TABLE reviews
FIELDS TERMINATED BY ";" 
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
-- .........................................................................................
-- CLOSED DEALS TABLE

CREATE TABLE closed_deals
	(
    mql_id              VARCHAR(40)    NOT NULL,
	seller_id	    	VARCHAR(40)    NOT NULL,
    sdr_id          	VARCHAR(40)    NOT NULL,
    sr_id        		VARCHAR(40)    NOT NULL,
    won_date     		DATETIME       NOT NULL,
    business_segment	VARCHAR(40),
    lead_type			VARCHAR(20),
    business_type		VARCHAR(20)
    );

-- Columns 'lead_behaviour_profile', 'has_company', 'has_gtin', 'average_stock', 'declared_product_catalog_size' and 'declared_monthly_revenue' will not be needed for the analysis, so they were deleted through Excel before loading the data.
-- In order to be able to load date data, the date format of the column 'won_date' was changed to yyyy-mm-dd hh:mm:ss using Excel.

LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_closed_deals_dataset.csv"
INTO TABLE closed_deals
FIELDS TERMINATED BY ";" 
LINES TERMINATED BY "\n"
IGNORE 1 ROWS

-- .........................................................................................
-- MARKETING QUALIFIED LEADS TABLE

CREATE TABLE marketing_qualified_leads
	(
    mql_id              		VARCHAR(40)    PRIMARY KEY	NOT NULL,
	first_contact_date	    	DATETIME       NOT NULL,
    landing_page_id          	VARCHAR(40)    NOT NULL,
    origin        				VARCHAR(20)    NOT NULL
    );
    
LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_marketing_qualified_leads_dataset.csv"
INTO TABLE marketing_qualified_leads
FIELDS TERMINATED BY "," 
LINES TERMINATED BY "\n"
IGNORE 1 ROWS

-- .........................................................................................
-- ///2. ADDITION OF FOREIGN KEYS ///
-- .........................................................................................

ALTER TABLE order_items
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id),
ADD FOREIGN KEY (product_id) REFERENCES products(product_id),
ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

ALTER TABLE orders
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE payments
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE reviews
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE closed_deals
ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);
-- By trying to connect the sellers table with the closed_deals table through seller_id, the error code 1452 tells us that there is data in the closed_deals table that is unmatched in the sellers table.
-- We now need to find which values in the closed_deals table do not have matches and insert into the sellers table.

INSERT INTO sellers (seller_id)
SELECT cd.seller_id
FROM closed_deals cd
LEFT JOIN sellers s
	ON cd.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

ALTER TABLE closed_deals
ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
ADD FOREIGN KEY (mql_id) REFERENCES marketing_qualified_leads(mql_id);

ALTER TABLE products
ADD FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name);
-- By trying to connect the products table with the product_category_name_translation table, the error code 1452 tells us that there is data in the products table that is unmatched in the product_category_name_translation table.
-- We now need to find which values in the products table do not have matches.

SELECT p.product_category_name, pcnt.product_category_name
FROM products p
LEFT JOIN product_category_name_translation pcnt
	ON p.product_category_name = pcnt.product_category_name
WHERE pcnt.product_category_name IS NULL
GROUP BY p.product_category_name;

INSERT INTO product_category_name_translation
VALUES	("pc_gamer", "pc_gamer"),
		("portateis_cozinha_e_preparadores_de_alimentos", "kitchen_portables_food_processors");

ALTER TABLE products
ADD FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name);

-- .........................................................................................
-- ///3. TABLE DATA CLEANING ///
-- .........................................................................................
-- ORDERS TABLE
-- .........................................................................................

SELECT *
FROM orders;

-- First, we need to examine the various types of order_status that are present in the table.

SELECT 
	order_status,
	COUNT(order_status)
FROM orders
GROUP BY order_status;

-- There are 8 types of order_status: delivered, unavailable, shipped, canceled, invoiced, processing, approved e created.

-- ***********************************
-- ORDER_STATUS: delivered

-- All orders delivered must have a date of order_delivered_customer_date

SELECT *
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;

-- It has been confirmed that certain orders do not have a delivery date for the customer, and one of them also lacks a delivery date for the carrier.
-- As a result, orders that do not have a delivery date to the customer but have a delivery date to the carrier will be changed to shipped status. Additionally, orders that do not have a delivery date to the carrier will be changed to approved status.

UPDATE orders
SET order_status = 'approved'
WHERE order_id = '2d858f451373b04fb5c984a1cc2defaf';

UPDATE orders
SET order_status = 'shipped'
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;

-- ***********************************
-- ORDER_STATUS: shipped

-- All orders shipped must have a date of order_delivered_carrier_date. Order_delivered_customer_date must be null.

SELECT *
FROM orders
WHERE order_status = 'shipped' AND order_delivered_carrier_date IS NULL;

SELECT *
FROM orders
WHERE order_status = 'shipped' AND order_delivered_customer_date IS NOT NULL;

SELECT *
FROM orders
WHERE order_status = 'shipped' AND order_estimated_delivery_date IS NULL;

-- The data for the shipped order status is fine.

-- ***********************************
-- ORDER_STATUS: approved

SELECT *
FROM orders
WHERE order_status = 'approved';

-- We have only three records, and there is no need for any corrections.

-- ***********************************
-- ORDER_STATUS: created

SELECT *
FROM orders
WHERE order_status = 'created';

-- We have only five records, and there is no need for any corrections.

-- ***********************************
-- ORDER_STATUS: unavailable

-- orders unavailable should also have a order_purchase date and an order_approved date but no order_delivered_carrier_date and order_delivered_customer_date.

SELECT *
FROM orders
WHERE order_status = 'unavailable' AND order_delivered_carrier_date IS NOT NULL AND order_delivered_customer_date IS NOT NULL
	  OR order_status = 'unavailable' AND order_purchase_date IS NULL AND order_approved_date IS NULL;

-- No need to correct anything.

-- ***********************************
-- ORDER_STATUS: canceled

-- orders canceled should not have order_delivered_customer_date

SELECT * 
FROM orders
WHERE order_status = "canceled" AND order_delivered_customer_date IS NOT NULL;

-- there are a few canceled orders with delivery dates. The status need to be updated to delivered

UPDATE orders
SET order_status = "delivered" 
WHERE order_status = "canceled" AND order_delivered_customer_date IS NOT NULL;

-- ***********************************
-- ORDER_STATUS: invoiced

-- orders invoiced should not have order_delivered_carrier_date and order_delivered_customer_date

SELECT * 
FROM orders
WHERE order_status = "invoiced" AND order_delivered_carrier_date IS NOT NULL AND order_delivered_customer_date IS NOT NULL;

-- No need to correct anything.

-- ***********************************
-- ORDER_STATUS: processing

-- orders processing should not have order_delivered_carrier_date and order_delivered_customer_date

SELECT * 
FROM orders
WHERE order_status = "processing" AND order_delivered_carrier_date IS NOT NULL AND order_delivered_customer_date IS NOT NULL;

-- No need to correct anything.

-- .........................................................................................
-- CUSTOMERS TABLE
-- .........................................................................................

-- find null values
SELECT *
FROM customers
WHERE customer_city IS NULL OR customer_state IS NULL; 

-- the remaining columns are already checked because of the NOT NULL condition

-- find out if for every customer_id there is in fact a customer_unique_id
SELECT customer_id, COUNT(customer_unique_id)
FROM customers
GROUP BY customer_id
HAVING COUNT(customer_unique_id) > 1;

-- .........................................................................................
-- ORDER ITEMS TABLE
-- .........................................................................................

-- Check for null values:
SELECT *
FROM order_items
WHERE order_id IS NULL OR 
	  order_item_id IS NULL OR
      product_id IS NULL OR
      seller_id IS NULL OR
      shipping_limit_date IS NULL OR
      price  IS NULL OR
      freight_value IS NULL;
-- There aren't null values in the order_items table.

-- Check if for each order_id in the order_items table there is an order_id and customer_id in the orders table:
SELECT oi.order_id, oi.order_item_id, oi.product_id, o.customer_id
FROM order_items oi
LEFT JOIN orders o
	ON oi.order_id = o.order_id
HAVING o.customer_id IS NULL;
-- For every order_id in the order_items table there is an order_id and customer_id in the orders table.

-- Check if for each product_id in the order_items table there is an product_id and product_category_name in the products table:
SELECT oi.product_id, p.product_category_name
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id = p.product_id
HAVING p.product_category_name IS NULL;
-- For every product_id in the order_items table there is an product_id and product_category_name in the orders table.

-- Check if for each seller_id in the order_items table there is an seller_id and seller_zip_code_prefix in the sellers table:
SELECT oi.seller_id, s.seller_zip_code_prefix
FROM order_items oi
LEFT JOIN sellers s
	ON oi.seller_id = s.seller_id
HAVING s.seller_zip_code_prefix IS NULL;
-- For every seller_id in the order_items table there is an seller_id and eller_zip_code_prefix in the orders table.

-- .........................................................................................
-- PAYMENTS TABLE
-- .........................................................................................

-- Check for null values:
SELECT *
FROM payments
WHERE order_id IS NULL OR 
	  payment_sequential IS NULL OR
      payment_type IS NULL OR
      payment_installments IS NULL OR
      payment_value IS NULL;
-- There aren't null values in the payments table.

-- Check if for each order_id in the payments table there is an order_id and customer_id in the orders table:
SELECT pay.order_id, pay.payment_sequential, pay.payment_type, o.customer_id
FROM payments pay
LEFT JOIN orders o
	ON pay.order_id = o.order_id
HAVING o.customer_id IS NULL;
-- For every order_id in the payments table there is an order_id and customer_id in the orders table.

-- Check wich order_id in the orders table doesn't have a match the order_id in the payments table:
SELECT
	order_id,
    order_status
FROM orders
WHERE order_id NOT IN (SELECT order_id from payments);
-- order_id bfbd0f9bdef84302105ad712db648a6c has no payment record, but has been delivered.

SELECT * 
FROM order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c';

-- Based on the information taken from the query above, we can introduce the order_id record bfbd0f9bdef84302105ad712db648a6c into the payments table.

INSERT INTO payments
VALUES	("bfbd0f9bdef84302105ad712db648a6c", 1, "not_defined", 1, 143.46);

-- .........................................................................................
-- PRODUCTS TABLE
-- .........................................................................................

-- As seen earlier, the product_id column has no null values ​​and all existing null values ​​in the product_category_name column have been replaced with "desconhecido".
-- The remaining columns have null values, however, these values ​​do not interfere with the analysis to be performed.

-- .........................................................................................
-- REVIEWS TABLE
-- .........................................................................................
      
-- Check for null values:
SELECT *
FROM reviews
WHERE review_id IS NULL OR 
	  order_id IS NULL OR
      review_score IS NULL OR
      review_creation_date IS NULL OR
      review_answer_timestamp IS NULL;
-- There aren't null values in the reviews table.

-- Check if for each order_id in the reviews table there is an order_id and customer_id in the orders table:
SELECT r.review_id, r.review_score, o.customer_id
FROM reviews r
LEFT JOIN orders o 
ON r.order_id = o.order_id;
HAVING o.customer_id IS NULL;
-- For every order_id in the reviews table there is an order_id and customer_id in the orders table.

-- .........................................................................................
-- GEOLOCATION TABLE
-- .........................................................................................

-- Check for null values:
SELECT *
FROM geolocation
WHERE geolocation_id IS NULL OR 
	  geolocation_zip_code_prefix IS NULL OR
      geolocation_lat IS NULL OR
      geolocation_lng IS NULL OR
      geolocation_city IS NULL OR
      geolocation_state IS NULL;
-- There aren't null values in the geolocation table.

-- Verify city names A-B
SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^a|^b"
ORDER BY geolocation_city;

-- some geolocation_city names are miswritten, so they need to be corrected

UPDATE geolocation SET geolocation_city = "arraial do cabo" WHERE geolocation_city = "...arraial do cabo";
UPDATE geolocation SET geolocation_city = "teresopolis" WHERE geolocation_city = "´teresopolis";
UPDATE geolocation SET geolocation_city = "quarto centenario" WHERE geolocation_city = "4º centenario";


-- How to correct "* cidade" geolocation_city name
-- 1. find the corresponding geolocation_zip_code_prefix
SELECT * FROM geolocation
WHERE geolocation_city = "* cidade";

-- 2. find the corresponding geolocation_city
SELECT * FROM geolocation
WHERE geolocation_zip_code_prefix = 81470;

-- Since all geolocation_zip_code_prefix = 81470, have curitiba as their geolocation_city, we can conclude that * cidade = curitiba
UPDATE geolocation SET geolocation_city = "curitiba" WHERE geolocation_city = "* cidade";

UPDATE geolocation SET geolocation_city = "alta floresta d'oeste" WHERE geolocation_city = "alta floresta do oeste";
UPDATE geolocation SET geolocation_city = "alta floresta d'oeste" WHERE geolocation_city = "alta floresta doeste";
UPDATE geolocation SET geolocation_city = "alvorada d'oeste" WHERE geolocation_city = "alvorada do oeste";
UPDATE geolocation SET geolocation_city = "antunes" WHERE geolocation_city = "antunes (igaratinga)";
UPDATE geolocation SET geolocation_city = "aparecida d'oeste" WHERE geolocation_city = "";
UPDATE geolocation SET geolocation_city = "aparecida d'oeste" WHERE geolocation_city = "aparecida d oeste";
UPDATE geolocation SET geolocation_city = "aparecida d'oeste" WHERE geolocation_city = "aparecida doeste";
UPDATE geolocation SET geolocation_city = "armacao dos buzios" WHERE geolocation_city = "armacao de buzios";
UPDATE geolocation SET geolocation_city = "arraial d'ajuda" WHERE geolocation_city = "arraial d ajuda";
UPDATE geolocation SET geolocation_city = "bacaxa" WHERE geolocation_city = "bacaxa (saquarema) - distrito";
UPDATE geolocation SET geolocation_city = "belo horizonte" WHERE geolocation_city = "bh";
UPDATE geolocation SET geolocation_city = "biritiba-mirim" WHERE geolocation_city = "biritiba mirim";

-- Verify city names C-D
SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^c|^d"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "califórnia da barra" WHERE geolocation_city = "california da barra (barra do pirai)";
UPDATE geolocation SET geolocation_city = "ceará-mirim" WHERE geolocation_city = "ceara mirim";
UPDATE geolocation SET geolocation_city = "colonia z-3" WHERE geolocation_city = "colônia z-3";
UPDATE geolocation SET geolocation_city = "diamante d'oeste" WHERE geolocation_city = "diamante d  oeste";
UPDATE geolocation SET geolocation_city = "dias d'avila" WHERE geolocation_city = "dias d avila";
UPDATE geolocation SET geolocation_city = "dias d'avila" WHERE geolocation_city = "dias davila";


-- Verify city names E-F
SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^e|^f"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "embu-guacu" WHERE geolocation_city = "embu guaçu";
UPDATE geolocation SET geolocation_city = "embu-guacu" WHERE geolocation_city = "embuguacu";
UPDATE geolocation SET geolocation_city = "estrela d'oeste" WHERE geolocation_city = "estrela d oeste";
UPDATE geolocation SET geolocation_city = "figueiropolis d'oeste" WHERE geolocation_city = "figueiropolis d oeste";
UPDATE geolocation SET geolocation_city = "figueiropolis d'oeste" WHERE geolocation_city = "figueirópolis doeste";
UPDATE geolocation SET geolocation_city = "florianopolis" WHERE geolocation_city = "florian&oacute;polis";
UPDATE geolocation SET geolocation_city = "florinia" WHERE geolocation_city = "florínea";
UPDATE geolocation SET geolocation_city = "franca" WHERE geolocation_city = "franca sp";

-- Verify city names G-H
SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^g|^h"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "gouveia" WHERE geolocation_city = "gouvea";
UPDATE geolocation SET geolocation_city = "guajara-mirim" WHERE geolocation_city = "";
UPDATE geolocation SET geolocation_city = "" WHERE geolocation_city = "guajara mirim";
UPDATE geolocation SET geolocation_city = "guarulhos" WHERE geolocation_city = "guarulhos-sp";
UPDATE geolocation SET geolocation_city = "herval d'oeste" WHERE geolocation_city = "";
UPDATE geolocation SET geolocation_city = "herval d'oeste" WHERE geolocation_city = "";
UPDATE geolocation SET geolocation_city = "" WHERE geolocation_city = "herval d' oeste";
UPDATE geolocation SET geolocation_city = "" WHERE geolocation_city = "herval d oeste";
UPDATE geolocation SET geolocation_city = "herval d'oeste" WHERE geolocation_city = "herval doeste";
UPDATE geolocation SET geolocation_city = "paranapanema" WHERE geolocation_city = "holambra ii";

-- verify city names I-J

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^i|^j"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "itabatan" WHERE geolocation_city = "itabatan (mucuri)";

-- verify city names K-L

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^k|^l"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "lambari d'oeste" WHERE geolocation_city = "lambari d%26apos%3boeste";
UPDATE geolocation SET geolocation_city = "lambari d'oeste" WHERE geolocation_city = "lambari doeste";
UPDATE geolocation SET geolocation_city = "linhares" WHERE geolocation_city = "linharesl";

-- verify city names M-N

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^m|^n"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "maceio" WHERE geolocation_city = "maceia³";
UPDATE geolocation SET geolocation_city = "machadinho d'oeste" WHERE geolocation_city = "machadinho d oeste";
UPDATE geolocation SET geolocation_city = "machadinho d'oeste" WHERE geolocation_city = "machadinho doeste";
UPDATE geolocation SET geolocation_city = "mogi mirim" WHERE geolocation_city = "mogi-mirim";
UPDATE geolocation SET geolocation_city = "monte gordo" WHERE geolocation_city = "monte gordo (camacari) - distrito";
UPDATE geolocation SET geolocation_city = "nova brasilandia d'oeste" WHERE geolocation_city = "nova brasilandia d oeste";
UPDATE geolocation SET geolocation_city = "nova brasilandia d'oeste" WHERE geolocation_city = "nova brasilandia doeste";

-- verify city names O-P

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^o|^p"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "olho d'água das cunhãs" WHERE geolocation_city = "olho d agua das cunhas";
UPDATE geolocation SET geolocation_city = "olho d'água das flores" WHERE geolocation_city = "olho d agua das flores";
UPDATE geolocation SET geolocation_city = "olho d'água das cunhãs" WHERE geolocation_city = "olho dágua das cunhãs";
UPDATE geolocation SET geolocation_city = "olho d'água grande" WHERE geolocation_city = "olho d'agua grande";
UPDATE geolocation SET geolocation_city = "olho d'água grande" WHERE geolocation_city = "olho dágua grande";
UPDATE geolocation SET geolocation_city = "olho d'água das flores" WHERE geolocation_city = "olho d'agua das flores";
UPDATE geolocation SET geolocation_city = "olho-d'água do borges" WHERE geolocation_city = "olho-d agua do borges";
UPDATE geolocation SET geolocation_city = "olhos d'água" WHERE geolocation_city = "olhos-d agua";
UPDATE geolocation SET geolocation_city = "olhos d'água" WHERE geolocation_city = "olhos d'agua";
UPDATE geolocation SET geolocation_city = "palmeira d'oeste" WHERE geolocation_city = "palmeira d oeste";
UPDATE geolocation SET geolocation_city = "palmeira d'oeste" WHERE geolocation_city = "palmeira doeste";
UPDATE geolocation SET geolocation_city = "pau d'arco" WHERE geolocation_city = "pau d  arco";
UPDATE geolocation SET geolocation_city = "penedo" WHERE geolocation_city = "penedo (itatiaia)";
UPDATE geolocation SET geolocation_city = "pérola d'oeste" WHERE geolocation_city = "perola doeste";
UPDATE geolocation SET geolocation_city = "pingo-d'agua" WHERE geolocation_city = "pingo-d agua";
UPDATE geolocation SET geolocation_city = "porto alegre" WHERE geolocation_city = "porto aelgre";
UPDATE geolocation SET geolocation_city = "praia grande" WHERE geolocation_city = "praia grande (fundão) - distrito";
UPDATE geolocation SET geolocation_city = "presidente castello branco" WHERE geolocation_city = "presidente castelo branco";

-- verify city names Q-R

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^q|^r"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "rancho alegre d'oeste" WHERE geolocation_city = "rancho alegre d  oeste";
UPDATE geolocation SET geolocation_city = "realeza" WHERE geolocation_city = "realeza (manhuacu)";
UPDATE geolocation SET geolocation_city = "brasilia" WHERE geolocation_city = "riacho fundo";
UPDATE geolocation SET geolocation_city = "brasilia" WHERE geolocation_city = "riacho fundo 2";
UPDATE geolocation SET geolocation_city = "rio de janeiro" WHERE geolocation_city = "rio de janeiro, rio de janeiro, brasil";
UPDATE geolocation SET geolocation_city = "rio de janeiro" WHERE geolocation_city = "rj";

-- verify city names S-T

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^s|^t"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "sao paulo" WHERE geolocation_city = "sa£o paulo";
UPDATE geolocation SET geolocation_city = "santana do livramento" WHERE geolocation_city = "sant'ana do livramento";
UPDATE geolocation SET geolocation_city = "santa bárbara d'oeste" WHERE geolocation_city = "santa barbara d oeste";
UPDATE geolocation SET geolocation_city = "santa bárbara d'oeste" WHERE geolocation_city = "santa bárbara d`oeste";
UPDATE geolocation SET geolocation_city = "santa bárbara d'oeste" WHERE geolocation_city = "santa bárbara doeste";
UPDATE geolocation SET geolocation_city = "santa clara d'oeste" WHERE geolocation_city = "santa clara d oeste";
UPDATE geolocation SET geolocation_city = "santa rita d'oeste" WHERE geolocation_city = "santa rita d oeste";
UPDATE geolocation SET geolocation_city = "santa rita d'oeste" WHERE geolocation_city = "santa rita doeste";
UPDATE geolocation SET geolocation_city = "sao joao d'alianca" WHERE geolocation_city = "sao joao d alianca";
UPDATE geolocation SET geolocation_city = "sao joao d'alianca" WHERE geolocation_city = "sao joao dalianca";
UPDATE geolocation SET geolocation_city = "sao joao do pau d'alho" WHERE geolocation_city = "sao joao do pau d alho";
UPDATE geolocation SET geolocation_city = "sao joao do pau d'alho" WHERE geolocation_city = "são joão do pau d%26apos%3balho";
UPDATE geolocation SET geolocation_city = "sao joao do pau d'alho" WHERE geolocation_city = "sao joao do pau dalho";
UPDATE geolocation SET geolocation_city = "sao jorge d'oeste" WHERE geolocation_city = "sao jorge do oeste";
UPDATE geolocation SET geolocation_city = "sao jorge d'oeste" WHERE geolocation_city = "sao jorge doeste";
UPDATE geolocation SET geolocation_city = "sao roque do canaa" WHERE geolocation_city = "sao roque do cannaa";
UPDATE geolocation SET geolocation_city = "sao paulo" WHERE geolocation_city = "sãopaulo";
UPDATE geolocation SET geolocation_city = "sao paulo" WHERE geolocation_city = "sp";
UPDATE geolocation SET geolocation_city = "cabo frio" WHERE geolocation_city = "tamoios (cabo frio)";
UPDATE geolocation SET geolocation_city = "trajano de moraes" WHERE geolocation_city = "trajano de morais";

-- verify city names U-V

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^u|^v"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "venda nova do imigrante" WHERE geolocation_city = "venda nova do imigrante-es";
UPDATE geolocation SET geolocation_city = "vila bela da santissima trindade" WHERE geolocation_city = "vila bela da santssima trindade";

-- verify city names W-X

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^w|^x"
ORDER BY geolocation_city;

UPDATE geolocation SET geolocation_city = "xangri-la" WHERE geolocation_city = "xangrila";

-- verify city names Y-Z

SELECT geolocation_city, COUNT(geolocation_city), geolocation_zip_code_prefix AS zip_code, geolocation_state AS state
FROM geolocation
GROUP BY geolocation_city, zip_code, state
HAVING geolocation_city REGEXP "^y|^z"
ORDER BY geolocation_city;

-- In order to have visibility over the number of geolocation_zip_code_prefix that refer to have more than one geolocation_city

SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state, COUNT(geolocation_zip_code_prefix) -- returns the number of records associated with each geolocation_city, grouped by geolocation_zip_code_prefix
FROM geolocation 
	WHERE geolocation_zip_code_prefix IN (
	SELECT geolocation_zip_code_prefix			-- returns every geolocation_zip_code_prefix with more than 1 city 
	FROM geolocation
	GROUP BY geolocation_zip_code_prefix
	HAVING COUNT(DISTINCT(geolocation_city)) > 1
	)
GROUP BY geolocation_zip_code_prefix, geolocation_city, geolocation_state
ORDER BY geolocation_zip_code_prefix;

-- We now know which records have a different city assigned, and can thus correct them

UPDATE geolocation SET geolocation_city = "embu das artes" WHERE geolocation_city = "embu";
UPDATE geolocation SET geolocation_city = "jacare" WHERE geolocation_city = "jacaré (cabreúva)";
UPDATE geolocation SET geolocation_city = "mogi mirim" WHERE geolocation_city = "mogi-mirim";
UPDATE geolocation SET geolocation_city = "mogi-guacu" WHERE geolocation_city = "mogi guacu";
UPDATE geolocation SET geolocation_city = "estrela d'oeste" WHERE geolocation_city = "estrela doeste";
UPDATE geolocation SET geolocation_city = "rio de janeiro" WHERE geolocation_city = "rio janeiro";
UPDATE geolocation SET geolocation_city = "paraty" WHERE geolocation_city = "parati" AND geolocation_zip_code_prefix = 23970;
UPDATE geolocation SET geolocation_city = "campos dos goytacazes" WHERE geolocation_city = "campos dos goytacaze";
UPDATE geolocation SET geolocation_city = "campos dos goytacazes" WHERE geolocation_city = "goitacazes";
UPDATE geolocation SET geolocation_city = "belo horizonte" WHERE geolocation_city = "belo horizonta";
UPDATE geolocation SET geolocation_city = "vitorinos" WHERE geolocation_city = "vitorinos - alto rio doce";
UPDATE geolocation SET geolocation_city = "lavras" WHERE geolocation_city = "lavras mg";
UPDATE geolocation SET geolocation_city = "piumhi" WHERE geolocation_city = "piumhii";
UPDATE geolocation SET geolocation_city = "limeira do oeste" WHERE geolocation_city = "limeira do oeste mg";
UPDATE geolocation SET geolocation_city = "monte gordo" WHERE geolocation_city = "monte gordo (camacari) - distrito";
UPDATE geolocation SET geolocation_city = "jiquiriçá" WHERE geolocation_city = "jequirica";
UPDATE geolocation SET geolocation_city = "itabata" WHERE geolocation_city = "itabatan";
UPDATE geolocation SET geolocation_city = "nova redencao" WHERE geolocation_city = "nova redencao bahia";
UPDATE geolocation SET geolocation_city = "muquem do sao francisco" WHERE geolocation_city = "muquém de são francisco";
UPDATE geolocation SET geolocation_city = "campo alegre de lourdes" WHERE geolocation_city = "campo alegre de lourdes, bahia, brasil";
UPDATE geolocation SET geolocation_city = "cabo de santo agostinho" WHERE geolocation_city = "santo agostinho";
UPDATE geolocation SET geolocation_city = "maceió" WHERE geolocation_city = "maceia³";
UPDATE geolocation SET geolocation_city = "barra de santo antonio" WHERE geolocation_city = "barra de  santo antônio";
UPDATE geolocation SET geolocation_city = "santa cecilia" WHERE geolocation_city = "santa cecilia de umbuzeiro";
UPDATE geolocation SET geolocation_city = "itapajé" WHERE geolocation_city = "itapage";
UPDATE geolocation SET geolocation_city = "senador la rocque" WHERE geolocation_city = "senador la roque";
UPDATE geolocation SET geolocation_city = "mojui dos campos" WHERE geolocation_city = "mujui dos campos";
UPDATE geolocation SET geolocation_city = "cachoeira do piriá" WHERE geolocation_city = "cachoeira de piria";
UPDATE geolocation SET geolocation_city = "tailândia" WHERE geolocation_city = "taliandia";
UPDATE geolocation SET geolocation_city = "pedra branca do amapari" WHERE geolocation_city = "amapari";
UPDATE geolocation SET geolocation_city = "rio branco" WHERE geolocation_city = "rio bracnco";
UPDATE geolocation SET geolocation_city = "bom jesus" WHERE geolocation_city = "bom jesus de goias";
UPDATE geolocation SET geolocation_city = "machadinho d'oeste" WHERE geolocation_city = "machadinho d oeste";
UPDATE geolocation SET geolocation_city = "nova brasilandia d'oeste" WHERE geolocation_city = "nova brasilandia d oeste" OR geolocation_city = "nova brasilandia doeste";
UPDATE geolocation SET geolocation_city = "mirassol d'oeste" WHERE geolocation_city = "mirassol d oeste" OR geolocation_city = "mirassol doeste";
UPDATE geolocation SET geolocation_city = "bataypora" WHERE geolocation_city = "bataipora";
UPDATE geolocation SET geolocation_city = "itapejara d'oeste" WHERE geolocation_city = "itapejara d  oeste";
UPDATE geolocation SET geolocation_city = "balneário piçarras" WHERE geolocation_city = "picarras";
UPDATE geolocation SET geolocation_city = "herval d'oeste" WHERE geolocation_city = "" AND geolocation_zip_code_prefix = 89610;
UPDATE geolocation SET geolocation_city = "barra do quaraí" WHERE geolocation_city = "barrado quarai";

-- In order do verify if all geolocation_zip_code_prefix refer to a single geolocation_state

SELECT geolocation_id, geolocation_zip_code_prefix, geolocation_city, geolocation_state
FROM geolocation
WHERE geolocation_zip_code_prefix IN (
		SELECT geolocation_zip_code_prefix
        FROM geolocation
        GROUP BY geolocation_zip_code_prefix
        HAVING COUNT(DISTINCT geolocation_state) > 1);

-- We now have visibility over the records that have the wrong geolocation_state and are now able to correct them

UPDATE geolocation SET geolocation_state = "SP" WHERE geolocation_id = 22262;
UPDATE geolocation SET geolocation_state = "SP" WHERE geolocation_id = 72853;
UPDATE geolocation SET geolocation_state = "RJ" WHERE geolocation_id = 431000;
UPDATE geolocation SET geolocation_state = "RJ" WHERE geolocation_id = 460407;
UPDATE geolocation SET geolocation_zip_code_prefix = 77320 WHERE geolocation_id = 792395;
UPDATE geolocation SET geolocation_zip_code_prefix = 76958 WHERE geolocation_id = 825883;
UPDATE geolocation SET geolocation_state = "MS" WHERE geolocation_id = 840048;
UPDATE geolocation SET geolocation_zip_code_prefix = 88630 WHERE geolocation_id = 847701;

-- .........................................................................................
-- SELLERS TABLE
-- .........................................................................................

-- Check for null values:
SELECT *
FROM sellers
WHERE seller_id IS NULL OR 
	  seller_zip_code_prefix IS NULL OR
      seller_city IS NULL OR
      seller_state IS NULL;
-- There are 462 records of null values ​​in the seller_zip_code_prefix, seller_city and seller_state columns of the sellers table.

-- Let's analyze if the seller_id that have null values ​​in the columns mentioned above have any associated orders in the order_items table
SELECT s.seller_id, s.seller_zip_code_prefix, oi.order_id
FROM sellers s
LEFT JOIN order_items oi ON 
s.seller_id = oi.seller_id
HAVING seller_zip_code_prefix IS NULL;
-- The seller_id that don't have associated geographic data are the seller_id that have not yet made any sales. These values ​​do not interfere with the analysis to be performed.

-- The seller's zip_code/city/state combination need to match the geolocation's zip_code/city/state in order to be able to filter the correct location
-- let's try and find the seller_city values that do no match the geolocation_city values

SELECT s.seller_city, g.geolocation_city,  s.seller_zip_code_prefix 
FROM sellers s
LEFT JOIN geolocation g
	ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix -- tables are joined through the zip_code
GROUP BY s.seller_city, g.geolocation_city, s.seller_zip_code_prefix 
HAVING s.seller_city <> g.geolocation_city;						-- only show records that differ in the city name

-- We can update those values and match the geolocation table
UPDATE sellers s
	JOIN geolocation g
		ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
SET s.seller_city = g.geolocation_city
WHERE s.seller_city <> g.geolocation_city AND s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;

-- .........................................................................................
-- MARKETING QUALIFIED LEADS TABLE
-- .........................................................................................

-- Check for null values:
SELECT *
FROM marketing_qualified_leads
WHERE mql_id IS NULL OR 
	  first_contact_date IS NULL OR
      landing_page_id IS NULL OR
      origin IS NULL;
-- There aren't null values in the marketing qualified leads table.
-- Considering that the mql_id column was parameterized as the primary key when creating the table, all of its values are unique.

-- Let's have an overview of the different types of origins:
SELECT
	count(mql_id),
	origin
FROM marketing_qualified_leads
GROUP BY origin;

-- There are 60 records with an origin value of "". Since there is no information about the origin of these records, we will categorize them as 'unknown'.
UPDATE marketing_qualified_leads SET origin = "unknown" WHERE origin = "";

-- .........................................................................................
-- CLOSED DEALS TABLE
-- .........................................................................................

select * from closed_deals;

-- Check for null values:
SELECT *
FROM closed_deals
WHERE mql_id IS NULL OR 
	  seller_id IS NULL OR
      sdr_id IS NULL OR
      sr_id IS NULL OR
      won_date IS NULL OR
      business_segment IS NULL OR
	  lead_type IS NULL OR
      business_type IS NULL;
-- There aren't null values in the closed deals table.

-- Check if all values in the mql_id and seller_id columns are unique:
SELECT
	COUNT(mql_id) - COUNT(DISTINCT mql_id) AS mql_id_difference,
    COUNT(seller_id) - COUNT(DISTINCT seller_id) AS seller_id_difference
FROM closed_deals;

-- Let's check what the various typologies of business types are and if they are all written correctly.
SELECT
	count(mql_id),
    length(business_type) as len_business_type,
	business_type
FROM closed_deals
GROUP BY business_type
ORDER BY business_type;

-- It turns out that there are several records in which the business_type manufacturer has a carriage return at the end. The only record of the typology business_type = manufacturer that does not have is the one with mql_id = '8a6492305a5fbcdcdd1a7f5a90764c07'.
-- Therefore, we will correct the record so that it is written correctly.

UPDATE closed_deals SET business_type = 'manufacturer' WHERE business_type REGEXP "^m" AND mql_id <> '8a6492305a5fbcdcdd1a7f5a90764c07';

-- Considering that we also have 10 records with a business_type equal to a carriage return character, let's correct them and classify them as 'other'.

UPDATE closed_deals SET business_type = 'other' WHERE length(business_type) = 1;

-- It is also verified that there are records in which the business_type 'other' and 'reseller' have a carriage return character at the end.

UPDATE closed_deals SET business_type = 'other' WHERE length(business_type) = 6;
UPDATE closed_deals SET business_type = 'reseller' WHERE length(business_type) = 9;

-- Let's check what are the various types of business_segment and if they are all written correctly.
SELECT
	count(mql_id),
    length(business_segment) as len_business_segment,
	business_segment
FROM closed_deals
GROUP BY business_segment
ORDER BY business_segment;

-- It is verified that there is a record that does not have any associated business_segment. Let's try to identify what it might be.

SELECT * FROM closed_deals WHERE business_segment = '';
SELECT * FROM closed_deals WHERE lead_type = 'industry' and business_type = 'reseller';
SELECT * FROM order_items WHERE seller_id = 'ec5b3cd9d6bf0a880edfda73562a7cea';
SELECT * FROM sellers WHERE seller_id = 'ec5b3cd9d6bf0a880edfda73562a7cea';

-- We have no information about this seller's business_segment, as he has not yet made any sales.
-- Let's change the business segment of this record to 'unknown'.

UPDATE closed_deals SET business_segment = 'unknown' WHERE length(business_segment) = 0;

-- Let's check what are the various types of business_segment and if they are all written correctly.
SELECT
	count(mql_id),
    length(lead_type) as len_lead_type,
	lead_type
FROM closed_deals
GROUP BY lead_type
ORDER BY lead_type;

-- We have a record that has no value associated with lead_type, which we are going to change to 'other'.
UPDATE closed_deals SET lead_type = 'other' WHERE length(lead_type) = 0;

-- Check if for each seller_id in the closed deals table there is an seller_id in the sellers table:
SELECT cd.seller_id, s.seller_id
FROM closed_deals cd
LEFT JOIN sellers s 
ON cd.seller_id = s.seller_id
HAVING s.seller_id IS NULL;
-- For every seller_id in the closed_deals table there is an seller_id in the sellers table.

-- Check if for each mql_id in the closed deals table there is an mql_id in the marketing qualified leads table:
SELECT cd.mql_id, mql.mql_id
FROM closed_deals cd
LEFT JOIN marketing_qualified_leads mql 
ON cd.mql_id = mql.mql_id
HAVING mql.mql_id IS NULL;
-- For every mql_id in the closed_deals table there is an mql_id in the marketing_qualified_leads table.

-- .........................................................................................
-- ///4. EXPORTING DATA ///
-- .........................................................................................
-- CUSTOMERS TABLE

SELECT 'customer_id', 'customer_unique_id', 'customer_zip_code_prefix', 'customer_city', 'customer_state' -- Include the column names as literals
UNION ALL
SELECT * -- Select the actual data from the customers table
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_customers_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM customers;
-- .........................................................................................
-- CLOSED DEALS TABLE

SELECT 'mql_id', 'seller_id', 'sdr_id', 'sr_id', 'won_date', 'business_segment', 'lead_type', 'business_type'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_closed_deals_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM closed_deals;
-- .........................................................................................
-- GEOLOCATION TABLE

SELECT 'geolocation_id', 'geolocation_zip_code_prefix', 'geolocation_lat', 'geolocation_lng', 'geolocation_city', 'geolocation_state'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_geolocation_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM geolocation;
-- .........................................................................................
-- MARKETING QUALIFIED LEADS TABLE

SELECT 'mql_id', 'first_contact_date', 'landing_page_id', 'origin'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_marketing_qualified_leads_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM marketing_qualified_leads;
-- .........................................................................................
-- ORDER ITEMS TABLE

SELECT 'order_id', 'order_item_id', 'product_id', 'seller_id', 'shipping_limit_date', 'price', 'freight_value'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_order_items_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM order_items;
-- .........................................................................................
-- ORDERS TABLE

SELECT 'order_id', 'customer_id', 'order_status', 'order_purchase_date', 'order_approved_date', 'order_delivered_carrier_date', 'order_delivered_customer_date', 'order_estimated_delivery_date'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_orders_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM orders;
-- .........................................................................................
-- PAYMENTS TABLE

SELECT 'order_id', 'payment_sequential', 'payment_type', 'payment_installments', 'payment_value'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_payments_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM payments;
-- .........................................................................................
-- PRODUCTS TABLE

SELECT 'product_id', 'product_category_name', 'product_name_length', 'product_description_length', 'product_photos_qty', 'product_weight_g', 'product_length_cm', 'product_height_cm', 'product_width_cm'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_products_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM products;
-- .........................................................................................
-- REVIEWS TABLE

SELECT 'review_id', 'order_id', 'review_score', 'review_creation_date', 'review_answer_timestamp'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_reviews_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM reviews;
-- .........................................................................................
-- SELLERS TABLE

SELECT 'seller_id', 'seller_zip_code_prefix', 'seller_city', 'seller_state'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_sellers_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM sellers;
-- .........................................................................................
-- PRODUCT CATEGORY NAME TRANSLATION

SELECT 'product_category_name', 'product_category_name_english'
UNION ALL
SELECT *
INTO OUTFILE 'Projects/Olist/CSV Files/Clean Data/olist_clean_product_category_name_translation_dataset.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM product_category_name_translation;
