# Olist Business Review

## Goal

The objective of this project is to demonstrate the necessary data manipulation skills needed for roles in business intelligence and data analysis. This includes tasks such as planning, cleaning and modeling data, analyzing it and visualizing it.

## Technologies

* MS Excel
* MS Power BI 2.117.984.0
* MySQL 8.0.34

## Olist Overview

Olist is a Brazilian marketplace that connects small and medium-sized businesses with customers across the country. Founded in 2015, it offers an e-commerce platform where sellers can list and sell their products to a large customer base.

The company focuses on providing a seamless buying experience for customers, offering a wide variety of products across multiple categories such as electronics, fashion, home goods, and more.

One of the key advantages is its ability to aggregate small sellers, allowing them to compete with larger retailers by leveraging the marketplace's brand and infrastructure. Olist handles all the logistics and operational aspects, enabling sellers to focus on product development and customer service.

## Summary

 1.	Business Task
 2.	About the Data
 3.	Data Loading, Modelling and Cleaning using MySQL
 4.	Data Modelling using Power BI
 5.	Power BI Dashboards and Insights

## 1. Business Task

The analytics team at Olist was tasked with creating business intelligence reports on various company activities. The objective was to provide department heads access to useful information in a summarized format, with the aim of improving control and decision-making.

**Executive Dashboard**

_Information about our **monthly revenue**, the **number of orders delivered**, and the **undelivered rate**. It would be helpful to compare these metrics to the previous month to better understand the trend. Additionally, it is important to include data on the **product categories with the highest sales** and the **states in the country that are generating the most revenue**._

**State Sales Dashboard**

_Detailed information about the different states. This includes **monthly revenue trends**, the **most popular product categories**, and **customer ratings** for orders. The goal is to gain insights into customer preferences. Additionally, it is important to include information about the **location of sellers** to improve delivery channels between different states._

**Marketing Dashboard**

_Data on the **channels that are generating the most qualified leads**, the **conversion rate** of those leads, the **average time it takes to close a deal with a seller**, and the **number of deals closed over time**. This information will help us measure the performance of the marketing team and determine which lead channels need to be strengthened._

_Furthermore, we also need information on the **distribution of sellers** based on **business segment** and **type of business** on the platform. This will help us, in collaboration with the sales team, identify areas where there is a greater urgency to increase supply._

**Payments Dashboard**

_Information about the **total number of payments made over time**, both **overall** and by **state**, **segmented by the method of payment** made, in order to learn about customer preferences and strengthen less used payment methods._

**Delivery Operations – Deliveries Dashboard**

_Information on the **average delivery time** in each state over the months to evaluate the level of service in different states over time. To support this information, it is important to have the percentage distribution and total number of orders with their estimated delivery time. This will help confirm if the most critical values in the level of service meet the estimated delivery times in each state._

_Additionally, we should compare the average delivery time with the total number of orders over time to determine if there is a correlation between these two factors._

**Delivery Operations – Delays Dashboard**

_Data about the **number of delays** in different states each month to assess the level of service. It is also important to evaluate the average delay time over time and compare it with the total number of delays to understand the relationship between these two variables._

## 2. About the Data

The datasets used in this project were provided by Olist on Kaggle.

[Brazilian E-Commerce Public Dataset by Olist (9 csv files)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) - The dataset has information of 100k orders from 2016 to 2018 made at multiple marketplaces in Brazil. Its features allows viewing an order from multiple dimensions: from order status, price, payment and freight performance to customer location, product attributes and finally reviews written by customers.

[Marketing Funnel by Olist (2 csv files)](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist) - The dataset has information of 8k Marketing Qualified Leads (MQLs) that requested contact between Jun. 1st 2017 and Jun 1st 2018. 


In addition to the files available in the links above, context is also provided about the data included in the various datasets, as well as the data schema, which will be used to create relationships between the datasets.

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/4242ad11-ebc8-443f-83f2-75ac4bbff3eb)

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/1c90aa51-c922-4919-94d8-0eac1e4eb0be)

After downloading the .csv files, they were opened using MS Excel. This allowed us to learn more about the information contained in each column and plan how the various tables would relate to each other.

Once we have mapped the entire dataset, we can proceed with storing the data in MySQL using MySQL Workbench.

## 3. Data Loading, Modelling and Cleaning using MySQL

Loading, modeling, and cleaning data in MySQL involves several important tasks to ensure that the data is organized, accurately represented, and free of errors. Let's delve into each of these tasks.

The first step in this process was creating a dedicated SQL schema, which serves as a blueprint for the entire database. Next, the different tables were analyzed in order to define the appropriate data type for each column to ensure data integrity and efficient storage.

The unique identifiers of each record included in a table were verified, taking into account the context of each table in the data schema. These unique identifiers were defined as primary keys. In cases where there was no column serving as a primary key, composite keys (formed by two columns) were defined.

With this information defined, the tables were created and the raw data was uploaded from the .csv files, as shown in the example code below.

```sql
-- .........................................................................................
-- CUSTOMERS TABLE
-- .........................................................................................

CREATE TABLE customers
   (
    customer_id                     VARCHAR(40)	     PRIMARY KEY,
    customer_unique_id              VARCHAR(40)      NOT NULL,
    customer_zip_code_prefix        INT	             NOT NULL,
    customer_city                   VARCHAR(40),
    customer_state                  VARCHAR(2)
   );
    
LOAD DATA INFILE "Projects/Olist/CSV Files/Raw Data/olist_customers_dataset.csv"
INTO TABLE customers	
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS; 
```

The next step consisted of defining the foreign keys in order to establish the relationships between the different tables of the database. See the example code below.

```sql
-- .........................................................................................
-- ORDER ITEMS TABLE
-- .........................................................................................

ALTER TABLE order_items
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id),
ADD FOREIGN KEY (product_id) REFERENCES products(product_id),
ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);
```

After that, we proceeded to the data cleaning phase. During this process, we identified errors and inconsistencies in the data and made corrections. We considered the business context of each table and the logical relationships between the data in the different columns.

Here is a code snippet to exemplifies this process:

```sql

-- .........................................................................................
-- CLOSED DEALS TABLE
-- .........................................................................................

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
SELECT count(mql_id), length(business_type) as len_business_type, business_type
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
SELECT count(mql_id), length(business_segment) as len_business_segment, business_segment
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
SELECT count(mql_id), length(lead_type) as len_lead_type, lead_type
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
```

## 4. Data Modelling using Power BI

The process of data modeling in Power BI consisted of the following steps:

_a) Import the necessary tables from MySQL to Power BI._
* orders
* order_items
* customers
* payments
* reviews
* sellers
* product_category_name_translation
* marketing_qualified_leads
* closed_deals

_b)	Using PowerQuery, you can rename table names, check the data type associated with each column, perform transformations on some columns to make the data more readable (such as replacing underscores with spaces and capitalizing each word), rename useful columns, and delete unnecessary ones._

_c)	In order to be able to filter data using the full names of all the Brazilian States, connect Power BI to the following [link](https://en.wikipedia.org/wiki/Federative_units_of_Brazil) and select the "states list" table;_

_d)	Create a calendar table so that we can use Time Intelligence DAX functions;_

_e)	Using the Model view, create the data model by establishing relationships between columns from different tables;_

_f)	Create the necessary calculated columns and DAX measures (Subtotals, Averages, Percentage Rates, etc.);_

_g)	Set up the dashboards with the appropriate visualization graphics that will transmit the required information to stakeholders in a well-structured and easy-to-understand manner._

## 5. Power BI Dashboards and Insights

**Executive Dashboard**

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/b1e362e1-95d4-4a3b-9e14-9b0b0aeebacb)

**Monthly Revenue –** In general, there is an upward trend with oscillations around the trend line. The month with the highest monthly revenue was November 2017, worth R$ 1.15 M. Since then there has been a slowdown, new peaks in monthly revenue have not been reached, and growth in the two months has been stagnant.

**Product Categories –** So far the product categories that have achieved over R$ 1M in revenue have been Health & Beauty, Watches & Gifts, Bed, Bath & Table, Sports & Leisure and Computer Accessories. The category of product with the highest number of orders is Bed, Bad & Table, with a total of 9267 orders.

**Purchases by State –** São Paulo is ranked first as the state with the highest revenue generated, with a value of R$ 5.8M. Rio de Janeiro is second with a revenue of R$ 2M, and Minas Gerais is third with R$ 1.8M. All other states have not yet been able to reach the revenue goal of R$ 1M.

**State Sales Dashboard**

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/c2be6322-5016-4dbb-8984-4d2c6a59a062)

**Monthly Revenue -** The overall trend has been upward, reaching its highest revenue in November 2017 with a total value of $172.2K. However, in the following month, there was a correction of -32.44%, causing the revenue to decrease to 130K. The revenue remained relatively stable (with variations below 5%) until May 2018. Since June 2018, the trend has been negative.

**Product Categories –** So far the product categories that have achieved over R$ 100K in revenue have been Watches & Gifts, Bed, Bath & Table, Health & Beauty, Sports & Leisure, Computer Accessories and Furniture & Decor. The category of product with the highest number of orders is Bed, Bad & Table, with a total of 1356 orders.

**Sellers –** The state that sells the most to Rio de Janeiro, with a significant difference compared to the others, is São Paulo (R$ 1.25M). It is followed by Rio de Janeiro itself (R$ 0.19M) in second place, and Minas Gerais (R$ 0.18M) in third place. Since most orders come from a neighboring state or from within the state itself, it will be interesting to see how this positively affects the average order delivery time.

**Customers Reviews –** There were a total of 12242 reviews conducted for orders delivered in the state of Rio de Janeiro, with an average order rating of 4.0, slightly below the overall average of 4.2.

**Marketing Dashboard**

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/afdacf2e-4f6e-48e6-a8f0-a5d15d2f0a11)

The conversion rate for qualified marketing leads into sellers is 10.5%, and it takes an average of 48.4 days to close a deal.

When it comes to the channels that qualified leads come from, 'organic search' brings in the most leads at 28.7%, followed by paid search at 19.83%. The channels that generate the fewest leads (less than 5%) are Referral (3.55%), Other (1.88%), Display (1.48%), and Other Publicities (0.81%).

In terms of the number of deals closed over time, there was an increasing trend that peaked on April 30, 2018, with 22 deals closed that day. Since then, the trend has been decreasing.

The majority of closed deals are with resellers (69.71%), followed by manufacturers (28.74%).

The business segment in which the most deals were closed was Home & Decor, Health & Beauty and Car Accessories, which, with the exception of the Health & Beauty category, contrasts with the most ordered product categories on the platform.

**Payments Dashboard**

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/709ea8be-f967-413a-b352-220397d8522a)

In terms of payment methods popularity, credit card takes the lead, followed by check (boleto), voucher, and debit card. Nevertheless, there has been a noticeable rise in debit card payments in the last month, surpassing voucher payments by a margin of 28.

**Delivery Operations – Deliveries Dashboard**

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/8efd2545-ab53-4e12-85c2-481f686b3016)

Roraima, Pará, Alagoas, Amapá, and Amazonas (states mostly located in the Norte region) all have an concerning average delivery time. From November 2017 to March 2018, delivery times exceeded 2 weeks, which coincided with an increase in orders during the same period.

**Delivery Operations – Delays Dashboard**

![image](https://github.com/diogosmferreira/olist_business_review/assets/129385224/a180e806-f271-4a13-9d52-11dea23f8ffd)

São Paulo and Rio de Janeiro have the highest revenue but also the highest number of delays, with the majority occurring between November 2017 and March 2018. Most states experienced an increase in the number of delays during the same period, except for states with a low number of purchases, such as Tocantins, Acre, Alagoas, and Sergipe.

Although there was an increase in the number of delays between November 2017 and March 2018, the average delay time remained constant.

