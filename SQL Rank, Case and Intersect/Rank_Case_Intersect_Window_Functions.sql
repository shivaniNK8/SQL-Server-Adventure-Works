

USE AdventureWorks2008R2;

/* 3.1 --------------------------------------------------------------------
 * Generate following
 * 'No Order' for count = 0
 * 'One Time' for count = 1
 * 'Regular' for count range of 2-5
 * 'Often' for count range of 6-10
 * 'Loyal' for count greater than 10
*/

 SELECT c.CustomerID, 
 		c.TerritoryID,
 		COUNT(o.SalesOrderid) [Total Orders],
 		CASE 
 			WHEN COUNT(o.SalesOrderid) = 0
 				THEN 'No Order'
 			WHEN COUNT(o.SalesOrderid) = 1
 				THEN 'One Time' 
 			WHEN COUNT(o.SalesOrderid) BETWEEN 2 AND 5
 				THEN 'Regular'
 			WHEN COUNT(o.SalesOrderid) BETWEEN 6 AND 10
 				THEN 'Often'
 			WHEN COUNT(o.SalesOrderid) > 10
 				THEN 'Loyal'
 		END AS CustomerFrequency
 FROM Sales.Customer c
 LEFT OUTER JOIN Sales.SalesOrderHeader o
 	ON c.CustomerID = o.CustomerID
 WHERE DATEPART(year, OrderDate) = 2007
 GROUP BY c.TerritoryID, c.CustomerID

 
/* 3.2 --------------------------------------------------------------------
 * Modify the following query to add a rank without gaps in the
 * ranking based on total orders in the descending order. Also
 * partition by territory
 */
 
 SELECT c.CustomerID, 
  		c.TerritoryID,
 		COUNT(o.SalesOrderid) [Total Orders],
 		DENSE_RANK() OVER (PARTITION BY c.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) [Rank]
 FROM Sales.Customer c
 LEFT OUTER JOIN Sales.SalesOrderHeader o
 ON c.CustomerID = o.CustomerID
 WHERE DATEPART(year, OrderDate) = 2007
 GROUP BY c.TerritoryID, c.CustomerID


/* 3.3 --------------------------------------------------------------------
 * Write a query that returns the salesperson(s) who received the
 * highest bonus amount and calculate the highest bonus amount’s
 * percentage of the total bonus amount for salespeople. Your
 * solution must be able to retrieve all salespersons who received
 * the highest bonus amount if there is a tie.
 * Include the salesperson’s last name and first name, highest
 * bonus amount, percentage in the report. 
 */
WITH [Temp] AS
(SELECT p.LastName, 
		p.FirstName,
	   	Bonus,
	   	ROUND(Bonus * 100 / (SELECT SUM(Bonus) FROM Sales.SalesPerson), 2) BonusPercentage, -- try cast as decimal
	   	RANK() OVER (ORDER BY Bonus DESC) [Rank]
FROM Sales.SalesPerson sp
JOIN Person.Person p 
ON sp.BusinessEntityID = p.BusinessEntityID )
SELECT LastName,
	   FirstName,
	   Bonus AS HighestBonus,
	   BonusPercentage AS HighestBonusPercentage
FROM [Temp]
WHERE [Rank] = 1


/* Write a query to retrieve the most valuable salesperson of each month
 * in 2007. The most valuable salesperson is the salesperson who has
 * made most sales for AdventureWorks in the month. Use the monthly sum
 * of the TotalDue column of SalesOrderHeader as the monthly total sales
 * for each salesperson. If there is a tie for the most valuable salesperson,
 * your solution should retrieve it. Exclude the orders which didn't have
 * a salesperson specified.
 * */

WITH Temp AS(
SELECT SalesPersonID, 
	   MONTH(OrderDate) [Month],
	   ROUND(SUM(TotalDue), 2) MonthlySum,
	   RANK() OVER (PARTITION BY MONTH(OrderDate) ORDER BY SUM(TotalDue) DESC) Ranking
FROM Sales.SalesOrderHeader soh 
WHERE SalesPersonID IS NOT NULL AND
	  YEAR(OrderDate) = 2007
GROUP BY SalesPersonID, MONTH(OrderDate) )
SELECT t.[Month],
	   t.SalesPersonID,
	   sp.Bonus ,
	   t.MonthlySum   
FROM Temp t
JOIN Sales.SalesPerson sp 
ON sp.BusinessEntityID = SalesPersonID 
WHERE t.Ranking = 1
ORDER BY Month

--Verify
SELECT SUM(TotalDue )
FROM Sales.SalesOrderHeader soh 
WHERE SalesPersonID  = 277
AND MONTH(OrderDate) = 1 AND YEAR(OrderDate) = 2007

SELECT SalesPersonID , ROUND(SUM(TotalDue), 2)
FROM Sales.SalesOrderHeader soh 
WHERE MONTH(OrderDate) = 3 AND YEAR(OrderDate) = 2007
GROUP BY SalesPersonID 
HAVING  ROUND(SUM(TotalDue), 2) > 366536.9400

 /* 3.5
  * Provide a unique list of customer id’s which have ordered
  * both the red and yellow products after May 1, 2008.
  * Sort the list by customer id. */

SELECT DISTINCT CustomerID 
FROM Sales.SalesOrderHeader soh 
JOIN Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID 
JOIN Production.Product p 
ON sod.ProductID = p.ProductID 
WHERE p.Color = 'Yellow' AND 
	  soh.OrderDate > '2008-05-01'
INTERSECT 
SELECT DISTINCT CustomerID 
FROM Sales.SalesOrderHeader soh 
JOIN Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID 
JOIN Production.Product p 
ON sod.ProductID = p.ProductID 
WHERE p.Color = 'Red' AND 
	  soh.OrderDate > '2008-05-01'
ORDER BY CustomerID 

 