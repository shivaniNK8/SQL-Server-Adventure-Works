USE db;

/* 5-1
 * 
 *  Create a function in your own database that takes three
 *	parameters:
 *		1) A year parameter
 *		2) A month parameter
 *		3) A color parameter
 *	The function then calculates and returns the total sales
 *	for products in the requested color during the requested
 *	year and month. If there was no sale for the requested period,
 *
 */

CREATE FUNCTION ColorSales(
	@year INT,
	@month INT,
	@color NVARCHAR(15)
)
RETURNS NUMERIC(38,6)
AS
BEGIN
	DECLARE @sales NUMERIC(38,6);
		SELECT @sales = ROUND(SUM(sod.UnitPrice * sod.OrderQty), 2)
		FROM AdventureWorks2008R2.Sales.SalesOrderHeader soh 
		JOIN AdventureWorks2008R2.Sales.SalesOrderDetail sod 
			ON soh.SalesOrderID = sod.SalesOrderID 
		JOIN AdventureWorks2008R2.Production.Product p 
			ON sod.ProductID = p.ProductID 
		WHERE p.Color = @color AND
			DATEPART(mm, CAST(OrderDate AS DATE)) = @month AND	
			DATEPART(yy, CAST(OrderDate AS DATE)) = @year
	IF @sales IS NULL 
		SET @sales = 0.0
	RETURN @sales
END

SELECT dbo.ColorSales(2005,8,'Red') AS TotalSales;


/*
 * 5-2
 *  Write a stored procedure in your own database that accepts two parameters:
 *		1) A starting date
 *		2) The number of the consecutive dates beginning with the starting date
 *	The stored procedure then populates all columns of the
 *	DateRange table according to the two provided parameters.
 * */

DROP TABLE DateRange;

CREATE TABLE DateRange
(DateID INT IDENTITY,
DateValue DATE,
Year INT,
Quarter INT,
Month INT,
DayOfWeek INT);


DROP PROCEDURE PopulateDateRange;


CREATE PROCEDURE PopulateDateRange
	@StartDate DATE,
	@NumberOfDates INT
AS
BEGIN
	DECLARE @counter INT;
	SET @counter = 0;
	WHILE @counter <> @NumberOfDates
	BEGIN 
		DECLARE @InsertDate DATE;
		SET @InsertDate = DATEADD(day, @counter, @StartDate)
		INSERT dbo.DateRange
			VALUES(@InsertDate, 
					DATEPART(year, @InsertDate),
					DATEPART(quarter, @InsertDate),
					DATEPART(month, @InsertDate),
					DATEPART(dw, @InsertDate)
				  );
		SET @counter = @counter + 1;
	END
END

--DateRange Data before executing procedure
SELECT * 
FROM dbo.DateRange;

EXEC dbo.PopulateDateRange '2008-3-13', 10;

--DateRange Data before executing procedure
SELECT * 
FROM dbo.DateRange;


/* 5-3
 * Using an AdventureWorks database, create a function that accepts
 * a customer id and returns the full name (last name + first name)
 * of the customer.
 * */

DROP FUNCTION GetFullName;

CREATE FUNCTION GetFullName
(
	@CustomerID INT
)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @FullName NVARCHAR(100);
	SELECT @FullName = p.LastName + ' ' +p.FirstName
	FROM AdventureWorks2008R2.Sales.Customer c
	JOIN AdventureWorks2008R2.Person.Person p
		ON c.PersonID = p.BusinessEntityID 
	WHERE c.CustomerID = @CustomerID
	
	RETURN @FullName
END

SELECT dbo.GetFullName(29487) AS FullName;

/*
 * 5-4
 * Write a trigger to put the change date and time in the LastModified column
 * of the Order table whenever an order item in SaleOrderDetail is changed.
 */

 -- Create the required tables in database

 CREATE TABLE Customer
 (CustomerID INT PRIMARY KEY,
 CustomerLName VARCHAR(30),
 CustomerFName VARCHAR(30));

 CREATE TABLE SaleOrder
 (OrderID INT IDENTITY PRIMARY KEY,
 CustomerID INT REFERENCES Customer(CustomerID),
 OrderDate DATE,
 LastModified datetime);

 CREATE TABLE SaleOrderDetail
 (OrderID INT REFERENCES SaleOrder(OrderID),
 ProductID INT,
 Quantity INT,
 UnitPrice INT,
 PRIMARY KEY (OrderID, ProductID));

	
/*Trigger if LastModified of SaleOrder table has to be updated when
 * an item is added, deleted or updated in the SaleOrderDetail table.
 * ie. All update, delete, insert commands are issued on
 * SaleOrderDetail Table
 */

DROP TRIGGER dbo.ItemChangeTimestampAll

CREATE TRIGGER dbo.ItemChangeTimestampAll
	ON dbo.SaleOrderDetail 
	AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @ChangedOrderID INT;

	SELECT @ChangedOrderID = COALESCE (i.OrderID, d.OrderID)
	FROM inserted i
	FULL JOIN deleted d 
		ON i.OrderID = d.OrderID;
		
	UPDATE dbo.SaleOrder 
	SET LastModified = CURRENT_TIMESTAMP
	WHERE dbo.SaleOrder.OrderID = @ChangedOrderID;
END

/*Trigger if LastModified of SaleOrder table has to be updated only when
 * an item is updated in the SaleOrderDetail table.
 * ie. if Update command is issued on
 * SaleOrderDetail Table
 */

DROP TRIGGER dbo.ItemChangeTimestamp;

CREATE TRIGGER dbo.ItemChangeTimestamp
	ON dbo.SaleOrderDetail 
	AFTER UPDATE
AS
BEGIN
	UPDATE dbo.SaleOrder 
	SET LastModified = CURRENT_TIMESTAMP
	WHERE dbo.SaleOrder.OrderID = (SELECT OrderID
								   FROM inserted i)
END

/*
 * Checking trigger functionality with scenarios --------------------------------
 */

--Create dummy data to check trigger working
INSERT INTO dbo.Customer
	VALUES(1, 'Naik', 'Shivani');
INSERT INTO dbo.SaleOrder
	VALUES( 1, GETDATE(), CURRENT_TIMESTAMP);
INSERT INTO dbo.SaleOrderDetail
	VALUES(3, 2, 20, 30);
INSERT INTO dbo.SaleOrderDetail
	VALUES(3, 5, 7, 50);

-- Check initial data in SaleOrder and SaleOrderDetail tables
SELECT *
FROM dbo.SaleOrder so ;

SELECT *
FROM dbo.SaleOrderDetail sod ;

-- Check if trigger works on update of an item for SalerOrderDetail with OrderID = 3 and ProductID = 2
UPDATE dbo.SaleOrderDetail 
SET UnitPrice = 40 
WHERE OrderID = 3 AND ProductID = 2;

SELECT *
FROM dbo.SaleOrder so 

-- Check if trigger works on insert a new item for a saleorderdetail with OrderID = 4 and ProductID = 2
INSERT INTO dbo.SaleOrderDetail
	VALUES(4, 2, 20, 30);

SELECT *
FROM dbo.SaleOrder so 

-- Check if trigger works on deleting an item for a saleorderdetail with OrderID = 4 and ProductID = 2
DELETE 
FROM dbo.SaleOrderDetail
WHERE OrderID = 4 AND ProductID = 2;

SELECT *
FROM dbo.SaleOrder so 
