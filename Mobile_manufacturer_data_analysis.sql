--SQL Advance Case Study

--use db_SQLCaseStudies

--Q1--BEGIN 

---- List all the states in which we have customers who have bought cellphones from 2005 till today. 

		SELECT 
		L.State 
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_LOCATION AS L 
		ON T.IDLocation = L.IDLocation
		GROUP BY L.State 


--Q1--END

--Q2--BEGIN
	
--What state in the US is buying the most 'Samsung' cell phones?


SELECT STATE, Manufacturer_Name FROM
(
		SELECT 
		DENSE_RANK() OVER(ORDER BY SUM(T.Quantity) DESC) AS SERIAL_NO,
		L.State AS STATE, M.Manufacturer_Name AS Manufacturer_Name
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_MODEL AS MO 
		ON T.IDMODEL = MO.IDMODEL
		INNER JOIN DIM_MANUFACTURER AS M
		ON MO.IDManufacturer = M.IDManufacturer
		INNER JOIN DIM_LOCATION AS L
		ON T.IDLocation = L.IDLocation
		WHERE M.Manufacturer_Name = 'Samsung'  AND L.Country = 'US'
		GROUP BY L.State, M.Manufacturer_Name
) AS TAB_1
WHERE TAB_1.SERIAL_NO = 1


--Q2--END

--Q3--BEGIN      
	
-- Show the number of transactions for each model per zip code per state. 


		SELECT 
		MO.Model_Name, L.ZipCode, L.State, COUNT(T.IDCustomer) AS NO_OF_TRANS
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_LOCATION AS L
		ON T.IDLocation = L.IDLocation
		INNER JOIN DIM_MODEL AS MO
		ON T.IDModel = MO.IDModel
		GROUP BY MO.Model_Name, L.ZipCode, L.State


--Q3--END

--Q4--BEGIN

-- Show the cheapest cellphone (Output should contain the price also)

		SELECT 
		TOP 1 
		MO.Model_Name, MO.Unit_price 
		FROM DIM_MODEL AS MO
		ORDER BY MO.Unit_price


--Q4--END

--Q5--BEGIN

--Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.


-----HTC SHOULD NOT BE IN THE LIST AS LEAST PHONES SOLD

SELECT 
TAB_1.Manufacturer_Name, MO1.Model_Name, AVG(FT.TotalPrice) AS AVG_PRICE , SUM(FT.Quantity) AS TOTAL_QTY 
FROM
(
		SELECT 
		DENSE_RANK() OVER(ORDER BY SUM(T.Quantity) DESC) AS SERIES ,M.Manufacturer_Name
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_MODEL AS MO
		ON T.IDModel = MO.IDModel
		INNER JOIN DIM_MANUFACTURER AS M
		ON MO.IDManufacturer = M.IDManufacturer
		INNER JOIN FACT_TRANSACTIONS AS FT
		ON T.IDModel = FT.IDModel
		GROUP BY M.Manufacturer_Name
) AS TAB_1
INNER JOIN DIM_MANUFACTURER AS M1
ON TAB_1.Manufacturer_Name = M1.Manufacturer_Name
INNER JOIN DIM_MODEL AS MO1
ON M1.IDManufacturer = MO1.IDManufacturer
INNER JOIN FACT_TRANSACTIONS AS FT
ON MO1.IDModel = FT.IDModel
WHERE SERIES <=5
GROUP BY TAB_1.Manufacturer_Name, MO1.Model_Name
ORDER BY AVG_PRICE DESC

--Q5--END

--Q6--BEGIN

-- List the names of the customers and the average amount spent in 2009, where the average is higher than 500


		SELECT 
		C.Customer_Name, AVG(T.TotalPrice) AS AVG_AMT_SPEND
		FROM FACT_TRANSACTIONS AS T
		LEFT JOIN DIM_CUSTOMER AS C
		ON T.IDCustomer = C.IDCustomer 
		WHERE YEAR(T.Date) = 2009
		GROUP BY C.Customer_Name
		HAVING AVG(T.TotalPrice) > 500


--Q6--END
	
--Q7--BEGIN  
	
--List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010 


SELECT Model_Name FROM DIM_MODEL 
WHERE IDMODEL IN (

			SELECT TBL_1.IDModel FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY SUM(T.QUANTITY) DESC) AS SERIES, T.IDModel FROM FACT_TRANSACTIONS AS T
			WHERE YEAR(T.DATE) = 2008
			GROUP BY T.IDModel ) AS TBL_1
			WHERE SERIES <=5

			INTERSECT

			SELECT TBL_1.IDModel FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY SUM(T.QUANTITY) DESC) AS SERIES, T.IDModel FROM FACT_TRANSACTIONS AS T
			WHERE YEAR(T.DATE) = 2009
			GROUP BY T.IDModel ) AS TBL_1
			WHERE SERIES <=5

			INTERSECT

			SELECT TBL_1.IDModel FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY SUM(T.QUANTITY) DESC) AS SERIES, T.IDModel FROM FACT_TRANSACTIONS AS T
			WHERE YEAR(T.DATE) = 2010
			GROUP BY T.IDModel ) AS TBL_1
			WHERE SERIES <=5
)	


--Q7--END	
--Q8--BEGIN

--Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.


SELECT TAB_1.YEAR ,TAB_1.Manufacturer_Name  FROM 
(
		SELECT 
		DENSE_RANK() OVER(ORDER BY SUM(T.TotalPrice) DESC) AS SERIES,YEAR(T.DATE) AS YEAR,
		M.Manufacturer_Name, SUM(T.TotalPrice) AS SALES 
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_MODEL AS MO
		ON T.IDModel = MO.IDModel
		INNER JOIN DIM_MANUFACTURER AS M
		ON MO.IDManufacturer = M.IDManufacturer
		WHERE YEAR(T.Date) = 2009
		GROUP BY M.Manufacturer_Name, YEAR(T.DATE)
) AS TAB_1
WHERE SERIES = 2

UNION ALL

SELECT TAB_1.YEAR ,TAB_1.Manufacturer_Name  FROM 
(
		SELECT 
		DENSE_RANK() OVER(ORDER BY SUM(T.TotalPrice) DESC) AS SERIES,YEAR(T.DATE) AS YEAR,
		M.Manufacturer_Name, SUM(T.TotalPrice) AS SALES 
		FROM FACT_TRANSACTIONS AS T
		INNER JOIN DIM_MODEL AS MO
		ON T.IDModel = MO.IDModel
		INNER JOIN DIM_MANUFACTURER AS M
		ON MO.IDManufacturer = M.IDManufacturer
		WHERE YEAR(T.Date) = 2010
		GROUP BY M.Manufacturer_Name, YEAR(T.DATE)
) AS TAB_1
WHERE SERIES = 2



--Q8--END
--Q9--BEGIN
	

-- Show the manufacturers that sold cellphones in 2010 but did not in 2009.


SELECT MANUFACTURER_NAME FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(Date) = 2010 
EXCEPT 
SELECT MANUFACTURER_NAME FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(Date) = 2009


--Q9--END

--Q10--BEGIN
	
--Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.


SELECT TOP 100
TAB_3.Customer_Name, TAB_3.YEAR, TAB_3.AVG_SPEND, TAB_3.T2_YEAR, TAB_3.T2_AVG_SPEND, TAB_3.AVG_QTY AS AVG_QTY,
CASE
		WHEN TAB_3.T2_YEAR > TAB_3.YEAR THEN ((TAB_3.T2_AVG_SPEND-TAB_3.AVG_SPEND)/TAB_3.AVG_SPEND*100) ELSE 0 END AS percentage_of_change_in_their_spend
FROM 
(
SELECT *
FROM 
(
select 
ROW_NUMBER () OVER (PARTITION BY C.Customer_Name ORDER BY YEAR(T.DATE)) AS RANK_,C.Customer_Name, YEAR(T.DATE) AS [YEAR], AVG(T.TotalPrice) AS AVG_SPEND, AVG(T.Quantity) AS AVG_QTY
from DIM_CUSTOMER as C
INNER JOIN FACT_TRANSACTIONS AS T
ON T.IDCustomer = C.IDCustomer
GROUP BY C.Customer_Name, YEAR(T.DATE)
) AS TAB_1
INNER JOIN 
(
select 
ROW_NUMBER () OVER (PARTITION BY C.Customer_Name ORDER BY YEAR(T.DATE)) AS RANK_2, C.Customer_Name AS T2_Customer_Name, YEAR(T.DATE) AS T2_YEAR, AVG(T.TotalPrice) AS T2_AVG_SPEND, AVG(T.Quantity) AS AVG_QTY_1
from DIM_CUSTOMER as C
INNER JOIN FACT_TRANSACTIONS AS T
ON T.IDCustomer = C.IDCustomer
GROUP BY C.Customer_Name, YEAR(T.DATE)
) AS TAB_2
ON TAB_1.CUSTOMER_NAME = TAB_2.T2_Customer_Name
) AS TAB_3
GROUP BY TAB_3.RANK_, TAB_3.RANK_2,TAB_3.Customer_Name, TAB_3.YEAR, TAB_3.AVG_SPEND, TAB_3.T2_YEAR, TAB_3.T2_AVG_SPEND, TAB_3.AVG_QTY
HAVING 
(TAB_3.RANK_2 - TAB_3.RANK_) = 1



--Q10--END
	
	
