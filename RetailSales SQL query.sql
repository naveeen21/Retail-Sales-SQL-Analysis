Use [Retail Sales]
select * from Customer;
select * from prod_cat_info;
select * from Transactions;

--***************************** DATA PREPARATION AND UNDERSTANDING ***************************--

---Q1 BEGIN------------------------------------------------------------
-- What is the total number of rows in each of the 3 tables in the database? 

SELECT 'CUSTOMER' AS TABLE_NAME, COUNT(*) AS TOTAL_RECORD FROM Customer
UNION ALL
SELECT 'PROD_CAT_INFO' AS TABLE_NAME,COUNT(*) AS TOTAL_RECORD FROM  PROD_CAT_INFO
UNION ALL
SELECT 'TRANSACTIONS' AS TABLE_NAME,COUNT (*) AS TOTAL_RECORD FROM TRANSACTIONS
UNION ALL
SELECT 'GRAND TOTAL' AS TABLE_NAME, SUM(TOTAL_RECORD) FROM 
(SELECT 'CUSTOMER' AS TABLE_NAME, COUNT(*) AS TOTAL_RECORD FROM Customer
UNION ALL
SELECT 'PROD_CAT_INFO' AS TABLE_NAME,COUNT(*) AS TOTAL_RECORD FROM  PROD_CAT_INFO
UNION ALL
SELECT 'TRANSACTIONS' AS TABLE_NAME,COUNT (*) AS TOTAL_RECORD FROM TRANSACTIONS) AS T1;

---Q2 BEGIN------------------------------
-- What is the total number of transactions that have a return? 

SELECT 'RETURN' AS [TRANSACTION], COUNT(CAST(Qty AS FLOAT)) AS TOTAL_RETURN_TRANSACTION FROM( SELECT 
QTY
FROM TRANSACTIONS
WHERE QTY < 0) AS T1;

---Q3 BEGIN------------------------------------------------------------------------------------
-- As you would have noticed, the dates provided across the datasets are not in a correct format. 
-- As first steps, pls convert the date variables into valid date formats before proceeding ahead.

SELECT *,
CONVERT(DATE, DOB, 105) AS NEW_FORMAT_DOB
FROM Customer;

SELECT *,
CONVERT(DATE, tran_date, 105) AS NEW_FORMAT_TRAN_DATE
FROM TRANSACTIONS;

---Q4 BEGIN------------------------------------------------------------------------------------
-- What is the time range of the transaction data available for analysis? 
--Show the output in number of days, months and years simultaneously in different columns

SELECT 
MIN(CONVERT(DATE, tran_date, 105)) AS BEGIN_TRANSACTION_DATE,
MAX(CONVERT(DATE, tran_date, 105)) AS END_TRANSACTION_DATE,
DATEDIFF(DAY, MIN(CONVERT(DATE, tran_date, 105)), MAX(CONVERT(DATE, tran_date, 105))) AS NUMBER_OF_DAYS,
DATEDIFF(MONTH, MIN(CONVERT(DATE, tran_date, 105)), MAX(CONVERT(DATE, tran_date, 105))) AS NUMBER_OF_MONTHS,
DATEDIFF(YEAR, MIN(CONVERT(DATE, tran_date, 105)), MAX(CONVERT(DATE, tran_date, 105))) AS NUMBER_OF_YEAR
FROM TRANSACTIONS;

---Q5 BEGIN------------------------------------------------------------------------------------
-- Which product category does the sub-category “DIY” belong to?

SELECT PROD_CAT FROM 
PROD_CAT_INFO
WHERE PROD_SUBCAT = 'DIY';


--********************************** DATA ANALYSIS *******************************************--


---Q1 BEGIN------------------------------------------------------------------------------------
-- Which channel is most frequently used for transactions? 
 
SELECT Top 1 STORE_TYPE AS CHANNELS, COUNT(STORE_TYPE) AS TOTAL_TRANSACTIONS
FROM TRANSACTIONS
GROUP BY STORE_TYPE
ORDER BY TOTAL_TRANSACTIONS DESC;

---Q2 BEGIN------------------------------------------------------------------------------------
-- What is the count of Male and Female customers in the database? 
SELECT 'MALE' AS GENDER, COUNT(GENDER) AS TOTAL_COUNT
FROM Customer
WHERE Gender='M'
UNION ALL 
SELECT 'FEMALE' AS GENDER, COUNT(GENDER) AS TOTAL_COUNT
FROM Customer
WHERE Gender='F';

---Q3 BEGIN------------------------------------------------------------------------------------
-- From which city do we have the maximum number of customers and how many? 
SELECT TOP 1
city_code, COUNT(CITY_CODE) AS MAX_CUSTOMER
FROM Customer
GROUP BY city_code
ORDER BY MAX_CUSTOMER DESC;

---Q4 BEGIN------------------------------------------------------------------------------------
-- How many sub-categories are there under the Books category? 

SELECT 'BOOKS' AS CATEGORY, COUNT(PROD_SUBCAT) AS COUNT_OF_SUB_CAT_OF_BOOK
FROM 
PROD_CAT_INFO
WHERE PROD_CAT LIKE 'BOO%';

---Q5 BEGIN------------------------------------------------------------------------------------
-- What is the maximum quantity of products ever ordered? 
 
SELECT TOP 1
TA.prod_cat_code AS PRODUCT_CATEGORY_CODE, prod_cat AS PRODUCT_CATEGORY, 
COUNT(cast(Qty as float)) AS MAX_QUANTITY
FROM TRANSACTIONS AS TA 
LEFT JOIN PROD_CAT_INFO AS PCI ON TA.PROD_CAT_CODE=PCI.PROD_CAT_CODE AND 
TA.prod_subcat_code=PCI.prod_sub_cat_code
GROUP BY TA.prod_cat_code,prod_cat
ORDER BY MAX_QUANTITY DESC;


---Q6 BEGIN------------------------------------------------------------------------------------
-- What is the net total revenue generated in categories Electronics and Books? 

SELECT PCI.prod_cat AS PRODUCT_CATEGORY, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE FROM 
TRANSACTIONS AS TR
INNER JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
WHERE PCI.prod_cat = 'BOOKS' OR PCI.prod_cat= 'ELECTRONICS' 
GROUP BY PCI.prod_cat;


---Q7 BEGIN------------------------------------------------------------------------------------
-- How many customers have >10 transactions with us, excluding returns? 

SELECT CUST_ID AS CUSTOMER_ID, COUNT(total_amt) AS TOTAL_NUMBER_OF_TRANSACTIONS
FROM
Transactions
WHERE QTY>0
GROUP BY CUST_ID
HAVING COUNT(total_amt)>10;


---Q8 BEGIN-----------------------------------------------------------------------------------
-- What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”? 

SELECT 
prod_cat AS PRODUCT_CATEGORY, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_AMT
FROM
Transactions AS TR
LEFT JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
WHERE Store_type = 'FLAGSHIP STORE' AND PROD_CAT IN ('CLOTHING', 'ELECTRONICS')
GROUP BY prod_cat
UNION ALL
SELECT 'GRAND TOTAL', SUM (TOTAL_AMT) FROM (SELECT 
prod_cat, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_AMT
FROM
Transactions AS TR
LEFT JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
WHERE Store_type = 'FLAGSHIP STORE' AND PROD_CAT IN ('CLOTHING', 'ELECTRONICS')
GROUP BY prod_cat) AS T1 ;


---Q9 BEGIN-----------------------------------------------------------------------------------
-- What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat. 

SELECT GENDER, PROD_CAT, PROD_SUBCAT,SUM(CAST(TOTAL_AMT AS FLOAT)) 
AS TOTAL_REVENUE FROM Customer AS C
LEFT JOIN Transactions AS TR
ON C.customer_Id=TR.cust_id 
INNER JOIN prod_cat_info AS PCI 
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
WHERE GENDER = 'M' AND PROD_CAT='ELECTRONICS' 
GROUP BY GENDER, PROD_CAT, PROD_SUBCAT;


---Q10 BEGIN-----------------------------------------------------------------------------------
-- What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales? 

SELECT TOP 5 prod_subcat AS PRODUCT_SUB_CATEGORY, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALES,
SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) FROM Transactions)
AS TOTAL_SALES_PERCENTAGE,
SUM(CAST(CASE WHEN QTY<0 THEN Qty END AS FLOAT)) / (SELECT SUM(CAST(Qty AS FLOAT)) FROM Transactions WHERE Qty<0)
AS TOTAL_RETURNS_PERCENTAGE
FROM
Transactions AS TR
LEFT JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
GROUP BY  prod_subcat
ORDER BY TOTAL_SALES DESC;


---Q11 BEGIN---------------------------------------------------------------------------------
-- For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers 
-- in last 30 days of transactions from max transaction date available in the data?

SELECT CUSTOMER_ID, DATEDIFF(YEAR, CONVERT(DATE, DOB, 105), GETDATE()) AS CUST_AGE, 
CONVERT(DATE, TRAN_DATE, 105) AS TRANSACTION_DATE,
SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALES
FROM Customer AS C
LEFT JOIN Transactions AS TR
ON C.customer_Id=TR.cust_id 
WHERE DATEDIFF(YEAR, CONVERT(DATE, DOB, 105), GETDATE()) BETWEEN 25 AND 35
AND 
CONVERT(DATE, TRAN_DATE, 105) BETWEEN CONVERT(DATE, '1-11-2013', 105) AND 
CONVERT(DATE, '30-11-2013', 105)
GROUP BY CUSTOMER_ID, DATEDIFF(YEAR, CONVERT(DATE, DOB, 105), GETDATE()), 
CONVERT(DATE, TRAN_DATE, 105);


---Q12 BEGIN---------------------------------------------------------------------------------
-- Which product category has seen the max value of returns in the last 3 months of transactions? 

SELECT Top 1 PCI.prod_cat AS PRODUCT_CATEGORY, 
SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_VALUE_OF_RETURN
FROM
Transactions AS TR
INNER JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
WHERE Qty<0 AND CONVERT(DATE, TR.tran_date, 105) BETWEEN CONVERT(DATE, '1-09-2013', 105) AND 
CONVERT(DATE, '30-11-2013', 105)
GROUP BY PCI.prod_cat
ORDER BY TOTAL_VALUE_OF_RETURN;


---Q13 BEGIN---------------------------------------------------------------------------------
-- Which store-type sells the maximum products; by value of sales amount and by quantity sold? 

SELECT TOP 1 Store_type, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALE_AMT,
COUNT(prod_cat) AS QUANTITY_OF_SALE
FROM
Transactions AS TR
INNER JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
GROUP BY Store_type
ORDER BY TOTAL_SALE_AMT DESC, QUANTITY_OF_SALE DESC;


---Q14 BEGIN---------------------------------------------------------------------------------
-- What are the categories for which average revenue is above the overall average. 

SELECT 
prod_cat AS PRODUCT_CATEGORY, AVG(CAST(TOTAL_AMT AS FLOAT)) AS SALES_MORE_THAN_AVG
FROM
Transactions AS TR
INNER JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
GROUP BY prod_cat
HAVING AVG(CAST(TOTAL_AMT AS FLOAT)) > 
(SELECT AVG(CAST(TOTAL_AMT AS FLOAT)) FROM Transactions);


---Q15 BEGIN---------------------------------------------------------------------------------
-- Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY COUNT (prod_cat) DESC ) AS RNUM, prod_cat, 
prod_subcat,
AVG(CAST(TOTAL_AMT AS FLOAT)) AS AVG_SALE, 
SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALE,
COUNT (prod_cat) AS TOTAL_QUANTITY
FROM
Transactions AS TR
INNER JOIN prod_cat_info AS PCI
ON TR.prod_cat_code=PCI.prod_cat_code AND TR.prod_subcat_code=PCI.prod_sub_cat_code
GROUP BY prod_cat, prod_subcat) AS T1 WHERE RNUM BETWEEN 1 AND 5; 


-------------------------------------END---------------------------------------------------------------
