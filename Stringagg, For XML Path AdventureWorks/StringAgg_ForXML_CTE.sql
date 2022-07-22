
USE AdventureWorks2008R2;
/* 
 * Write a query to retrieve the top 3 customers, based on the total purchase, for each year. 
 * The top 3 customers have the 3 highest total purchase amounts.
 * Use TotalDue of SalesOrderHeader to calculate the total purchase.
 * Also calculate the top 3 customers' total purchase amount for the year.
*/


--Using String_agg function
WITH Temp AS
(
	SELECT YEAR(OrderDate) as [Year],
	   SUM(TotalDue) [Total Sale],
	   CustomerID ,
	   RANK() OVER (PARTITION BY YEAR(OrderDate) ORDER BY SUM(TotalDue) DESC) [Rank]
	FROM Sales.SalesOrderHeader soh 
	GROUP BY YEAR(OrderDate), CustomerID 
)
SELECT Temp.[Year],
	   ROUND(SUM([Total Sale]),0) AS [Total Sale],
	   STRING_AGG(CAST(Temp.CustomerID AS VARCHAR),
	   ', ') AS Top3Customers
FROM Temp
WHERE [Rank] <=3
GROUP BY Temp.[Year]
ORDER BY Temp.[Year]

-- Solution using For XML Path
WITH Temp AS (
SELECT YEAR(OrderDate) as [Year],
	   SUM(TotalDue) [Total Sale],
	   CustomerID ,
	   RANK() OVER (PARTITION BY YEAR(OrderDate) ORDER BY SUM(TotalDue) DESC) [Rank]
FROM Sales.SalesOrderHeader soh 
GROUP BY YEAR(OrderDate), CustomerID ),
Y AS (
SELECT DISTINCT YEAR(OrderDate) [Year]
FROM Sales.SalesOrderHeader soh2 ),
Z AS (
SELECT Y.[Year],
	   SUM(Temp.[Total Sale]) [Total Sale]
FROM Temp
JOIN Y
  ON Y.[Year] = Temp.[Year]
WHERE Temp.[Rank] <= 3
GROUP BY Y.[Year]
)
SELECT Y.[Year] [Year],	
	   ROUND(Z.[Total Sale], 0) [Total Sale],
	   STUFF((SELECT ', '+CAST(CustomerID AS VARCHAR)
	    FROM Temp
		WHERE Rank <=3
 		AND Temp.[Year] = Y.[Year]
 		ORDER BY Temp.[Total Sale] DESC
		FOR XML PATH('')),1,2,'') AS Top3Customers 	
FROM Y
JOIN Z
	ON Y.[Year] = Z.[Year]
ORDER BY Y.[Year] 
