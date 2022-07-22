USE AdventureWorks2008R2;

-- Exercise 1 
/* Retrieve only the following columns from the
   Production.Product table:
                Product ID
                Name
                Selling start date
                Selling end date
                Size
                Weight */

SELECT ProductID , SellStartDate , SellEndDate , [Size] ,Weight 
FROM Production.Product p 

-- Exercise 2
/* Select all info for all orders with no credit card id. */
SELECT *
FROM Sales.SalesOrderHeader soh 
WHERE CreditCardID IS NULL

-- Exercise 3
/* Select all info for all products with size specified. */
SELECT *
FROM Production.Product p 
WHERE [Size] IS NOT NULL

-- Exercise 4
/* Select all information for products that started selling
   between January 1, 2007 and December 31, 2007. */

SELECT *
FROM Production.Product p 
WHERE SellStartDate BETWEEN '2007-01-01' AND '2007-12-31'

-- Exercise 5
/* Select all info for all orders placed in June 2007 using date
   functions, and include a column for an estimated delivery date
   that is 7 days after the order date. */

-- DATEADD adds interval specified to the date
SELECT *, 
		DATEADD(Day,7,OrderDate) Estimated_Delivery
FROM Sales.SalesOrderHeader soh 
WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) =2007

-- Exercise 6
/* Determine the date that is 30 days from today and display only
   the date in mm/dd/yyyy format (4-digit year). */

-- Convert can be used to convert datetime to a format from a list 
-- of formats

SELECT CONVERT(varchar, DATEADD(Day, 30, GETDATE()), 101)
SELECT CAST(DATEADD(Day, 30, GETDATE()) AS DATE)

-- Excercise 7
/* Determine the number of orders, overall total due,
   average of total due, amount of the smallest amount due, and
   amount of the largest amount due for all orders placed in May
   2008. Make sure all columns have a descriptive heading. */

SELECT COUNT(SalesOrderID) '# of orders',
	   SUM(TotalDue) 'Overall Total due',
	   AVG(TotalDue) 'Avergae Total due',
	   MIN(TotalDue) 'Smallest due',
	   MAX(TotalDue) 'Largest due'	
FROM Sales.SalesOrderHeader r
WHERE MONTH(OrderDate) = 5 AND YEAR(OrderDate) =2008

-- Excercise 8

/* Retrieve the Customer ID, total number of orders and overall total
   due for the customers who placed more than one order in 2007
   and sort the result by the overall total due in the descending
   order. */
SELECT CustomerID , 
	   COUNT(SalesOrderID) as '# of orders',
	   SUM(TotalDue) 'Overall Total due'
FROM Sales.SalesOrderHeader R
WHERE DATEPART(YEAR, OrderDate)=2007
GROUP BY CustomerID 
HAVING COUNT(SalesOrderID) > 1
ORDER BY 'Overall Total due' DESC

-- Exercise 9
/*
   Provide a unique list of the sales person ids who have sold
   the product id 777. Sort the list by the sales person id. */

SELECT DISTINCT soh.SalesPersonID 
FROM Sales.SalesOrderHeader soh JOIN
Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID 
WHERE sod.ProductID = 777
ORDER BY soh.SalesPersonID 

-- Exercise 10
/* List the product ID, name, list price, size of products Under the ‘Bikes’ category (ProductCategoryID = 1) and Subcategory ‘Mountain Bikes’. */


SELECT p.ProductID ,p.Name, ListPrice ,[Size] 
FROM Production.Product p JOIN 
Production.ProductSubcategory ps 
ON p.ProductSubcategoryID = ps.ProductSubcategoryID 
WHERE ps.ProductCategoryID = 1 AND 
ps.Name = 'Mountain Bikes'

-- Excercise 11
/* List the SalesOrderID and currency name for each order. */
SELECT soh.SalesOrderID , cr.ToCurrencyCode , c.Name
FROM Sales.SalesOrderHeader soh JOIN
Sales.CurrencyRate cr
ON soh.CurrencyRateID = cr.CurrencyRateID
JOIN Sales.Currency c 
ON cr.ToCurrencyCode = c.CurrencyCode 
