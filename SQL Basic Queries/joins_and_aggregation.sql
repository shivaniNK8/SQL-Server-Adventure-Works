
USE AdventureWorks2008R2


/*  2-1 -----------------------------------------------------------------
 *	Retrieve all orders made after May 5, 2008
 *	and had an total due value greater than $55,000. Include
 *	the customer id, sales order id, order date and total due columns
 *	in the returned data, order by customerid and orderdate
 */
SELECT CustomerID , 
	   SalesOrderID ,
	   CAST(OrderDate as DATE) OrderDate,
	   ROUND(TotalDue, 2) TotalDue 
FROM Sales.SalesOrderHeader soh 
WHERE OrderDate > '2008-05-05' AND TotalDue >55000
ORDER BY CustomerID , OrderDate 



/*  2-2 -----------------------------------------------------------------
 *	Latest order date, average order value, and total number
 *	of orders for each customer. Include the customer ID, latest
 *	order date, average order value, and the total number of orders
 *	in the report. Order by total number of orders
 */


/* 
 We use left outer join because there are 701 customers in Customer table
 that do not have orders in SalesOrderHeader and we want data for each customer. 
 The values in report for these customers will be NULL
 */
SELECT c.CustomerID , 
	   MAX(CAST(OrderDate as DATE)) LatestOrderDate,
	   ROUND(AVG(TotalDue), 2) [AverageOrderValue],
	   COUNT(SalesOrderID) 'TotalNumberOfOrders'
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader soh 
ON c.CustomerID = soh .CustomerID 
GROUP BY c.CustomerID 
ORDER BY TotalNumberOfOrders DESC



/*  2-3 -----------------------------------------------------------------
 *	Select the product id, name, and list price
 *	of the product(s) that have a list price greater than the
 *	the average list price of the products 911 and 915
 */
SELECT ProductID,
	   Name,
	   ROUND(ListPrice, 2) ListPrice 
FROM Production.Product p2 
WHERE ListPrice >
		(SELECT AVG(ListPrice) AvgPrice
		FROM Production.Product p 
		WHERE p.ProductID IN (911, 915))
ORDER BY ListPrice DESC



/*  2-4 -----------------------------------------------------------------
 *	Retrieve the number of times a product has
 *	been sold and the total sold quantity for each product.
 *	Note it's the number of times a product has been contained
 *	in an order and the total sold quantity of the product. Order
 *	by Number of times sold descending and productid ascending
 */

SELECT p.ProductID,
	   p.Name,
	   COUNT(sod.SalesOrderID) 'NumTimesSold',    
	   SUM(sod.OrderQty) 'TotalSoldQuantity'
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p 
ON p.ProductID = sod.ProductID 
GROUP BY p.ProductID, p.Name 
HAVING COUNT(sod.SalesOrderID) > 255
ORDER BY 
	'NumTimesSold' DESC,
	p.ProductID ASC

	
	
/*  2-5 -----------------------------------------------------------------
 *	Generate a unique list of customers
 *	who have made an order before but have not placed an order
 *	after January 5, 2007.
 * 	Include the customer id, and the total purchase of the customer
 * 	in the returned data. Use TotalDue to calculate the total purchase.
 *	Use an alias and round numbers to two decimal places to make the
 *	report look better. Sort the data by CustomerID in the descending
 *	order. 
 */
	
SELECT DISTINCT CustomerID,
				ROUND(SUM(TotalDue), 2) [TotalPurchase]
FROM Sales.SalesOrderHeader soh2 
WHERE CustomerID NOT IN 
	(SELECT DISTINCT CustomerID 
	FROM Sales.SalesOrderHeader soh 
	WHERE OrderDate > '2007-01-05')
GROUP BY CustomerID 
ORDER BY CustomerID DESC



/*  2-6 -----------------------------------------------------------------
 *	Create a report containing customer id,
 *	first name, last name, and email address for all customers.
 *	Return only customers who have a customer id greater than 11000.
 */
 
SELECT CustomerID,
	   FirstName,
	   LastName,
	   ea.EmailAddress 
FROM Sales.Customer c 
LEFT OUTER JOIN Person.Person p 
ON  p.BusinessEntityID = c.PersonID 
LEFT OUTER JOIN Person.EmailAddress ea 
ON p.BusinessEntityID = ea.BusinessEntityID 
WHERE CustomerID > 11000
ORDER BY CustomerID ASC

