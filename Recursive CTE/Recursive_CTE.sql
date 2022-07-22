
USE AdventureWorks2008R2;

/* Bill of Materials - Recursive */
/* Retrieves the components required for manufacturing
the "Mountain-500 Black, 48" (Product 992). Retrieve the most expensive component(s) that cannot be manufactured internally.
Use the list price of a component to determine the most expensive
component.
If there is a tie, your solutions must retrieve it. */


/* 
* Use Rank to find most expensive components that cannot be assembled for product 992
*/
--Check components from any component level that cannot be assembled
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS 
(
	SELECT b.ProductAssemblyID , b.ComponentID, b.PerAssemblyQty ,
		   b.EndDate, 0 AS ComponentLevel 
	FROM Production.BillOfMaterials b
	WHERE b.ProductAssemblyID = 992 AND EndDate IS NULL
	
	UNION ALL
	
	SELECT bom.ProductAssemblyID , bom.ComponentID, bom.PerAssemblyQty ,
		   bom.EndDate, ComponentLevel + 1 
	FROM Production.BillOfMaterials bom
	INNER JOIN Parts p
	ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL
),
BOM AS 
(
	SELECT AssemblyID, ComponentID, Name, ListPrice, PerAssemblyQty, 
	   ListPrice * PerAssemblyQty AS SubTotal,
	   ComponentLevel,
	   RANK() OVER(ORDER BY ListPrice DESC) [Rank]
	FROM Parts p
	INNER JOIN Production.Product pr 
	ON p.ComponentID = pr.ProductID 
	WHERE ComponentID NOT IN 
		( SELECT DISTINCT AssemblyID FROM Parts
		)
)
SELECT ComponentID , Name, ListPrice, PerAssemblyQty, SubTotal
FROM BOM
WHERE [Rank] = 1
ORDER BY ComponentLevel, AssemblyID, ComponentID 

-- If we want to check for components from ComponentLevel 0 that cannot be assembled
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS 
(
	SELECT b.ProductAssemblyID , b.ComponentID, b.PerAssemblyQty ,
		   b.EndDate, 0 AS ComponentLevel 
	FROM Production.BillOfMaterials b
	WHERE b.ProductAssemblyID = 992 AND EndDate IS NULL
	
	UNION ALL
	
	SELECT bom.ProductAssemblyID , bom.ComponentID, bom.PerAssemblyQty ,
		   bom.EndDate, ComponentLevel + 1 
	FROM Production.BillOfMaterials bom
	INNER JOIN Parts p
	ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL
),
BOM AS 
(
	SELECT AssemblyID, ComponentID, Name, ListPrice, PerAssemblyQty, 
	   ListPrice * PerAssemblyQty AS SubTotal,
	   ComponentLevel,
	   RANK() OVER(ORDER BY ListPrice DESC) [Rank]
	FROM Parts p
	INNER JOIN Production.Product pr 
	ON p.ComponentID = pr.ProductID 
	WHERE ComponentLevel = 0 
	AND ComponentID NOT IN 
		( SELECT DISTINCT AssemblyID FROM Parts
		  WHERE ComponentLevel > 0
		)
)
SELECT ComponentID , Name, ListPrice, PerAssemblyQty, SubTotal
FROM BOM
WHERE [Rank] = 1
ORDER BY ComponentLevel, AssemblyID, ComponentID 
