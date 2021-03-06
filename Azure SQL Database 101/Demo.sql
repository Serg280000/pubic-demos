-- 01: Queiries

-- CREATE DATABASE DIAGRAM

-- Generated SELECT
SELECT TOP 1000 [SalesOrderID]
      ,[SalesOrderDetailID]
      ,[OrderQty]
      ,[ProductID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal]
      ,[rowguid]
      ,[ModifiedDate]
FROM [SalesLT].[SalesOrderDetail]

-- Equal one
SELECT *
FROM [SalesLT].[SalesOrderDetail]

-- Real SELECT
SELECT sod.[SalesOrderId], sod.[ProductId], sod.[OrderQty] AS [OrderQuantity], sod.[UnitPriceDiscount], sod.[LineTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod

-- JOINS
SELECT sod.[SalesOrderId], pc.[Name] AS [CategoryName], sod.[OrderQty] AS [OrderQuantity], sod.[LineTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = pc.[ProductCategoryId]

-- WHERE
SELECT sod.[SalesOrderId], pc.[Name] AS [CategoryName], sod.[OrderQty] AS [OrderQuantity], sod.[LineTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = pc.[ProductCategoryId]
WHERE sod.[UnitPriceDiscount] = 0

-- GROUP BY
SELECT pc.[Name] AS [CategoryName], AVG(sod.[OrderQty]) AS [AvgOrderQuantity], SUM(sod.[LineTotal]) AS [SumTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = p.[ProductCategoryId]
WHERE sod.[UnitPriceDiscount] < 0.10
GROUP BY pc.[Name]

-- HAVING
SELECT pc.[Name] AS [CategoryName], AVG(sod.[OrderQty]) AS [AvgOrderQuantity], SUM(sod.[LineTotal]) AS [SumTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = p.[ProductCategoryId]
WHERE sod.[UnitPriceDiscount] < 0.10
GROUP BY pc.[Name]
HAVING SUM(sod.[LineTotal]) > 1000

-- ORDER BY
SELECT pc.[Name] AS [CategoryName], AVG(sod.[OrderQty]) AS [AvgOrderQuantity], SUM(sod.[LineTotal]) AS [SumTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = p.[ProductCategoryId]
WHERE sod.[UnitPriceDiscount] < 0.10
GROUP BY pc.[Name]
HAVING SUM(sod.[LineTotal]) > 1000
ORDER BY [SumTotal] DESC

-- VIEW
CREATE VIEW [SalesLT].[SumTotal] AS
SELECT pc.[Name] AS [CategoryName], AVG(sod.[OrderQty]) AS [AvgOrderQuantity], SUM(sod.[LineTotal]) AS [SumTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = p.[ProductCategoryId]
WHERE sod.[UnitPriceDiscount] < 0.10
GROUP BY pc.[Name]
HAVING SUM(sod.[LineTotal]) > 1000

-- CALL VIEW
SELECT *
FROM [SalesLT].[SumTotal]
WHERE [CategoryName] LIKE '%mount%'
ORDER BY [SumTotal] DESC

-- ALTER VIEW
ALTER VIEW [SalesLT].[SumTotal] AS
SELECT pc.[Name] AS [CategoryName], AVG(sod.[OrderQty]) AS [AvgOrderQuantity], SUM(sod.[LineTotal]) AS [SumTotal]
FROM [SalesLT].[SalesOrderDetail] AS sod
JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = p.[ProductCategoryId]
WHERE sod.[UnitPriceDiscount] < 0.10
GROUP BY pc.[Name]
HAVING SUM(sod.[LineTotal]) > 500

-- CREATE TABLE VALUED FUNCTION
CREATE FUNCTION [SalesLT].ParametrisedSumTotal
(	
	@minAmount FLOAT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT pc.[Name] AS [CategoryName], AVG(sod.[OrderQty]) AS [AvgOrderQuantity], SUM(sod.[LineTotal]) AS [SumTotal]
	FROM [SalesLT].[SalesOrderDetail] AS sod
	JOIN [SalesLT].[Product] AS p ON p.[ProductId] = sod.[ProductId]
	JOIN [SalesLT].[ProductCategory] AS pc ON pc.[ProductCategoryId] = p.[ProductCategoryId]
	WHERE sod.[UnitPriceDiscount] < 0.10
	GROUP BY pc.[Name]
	HAVING SUM(sod.[LineTotal]) > @minAmount
)
GO

-- USE TVF
SELECT *
FROM [SalesLT].ParametrisedSumTotal(100)
WHERE [AvgOrderQuantity] > 2

-- CREATE SINGLE VALUED FUNCTION
CREATE FUNCTION [SalesLT].GetCustomerTotal
(
	@customerId INT
)
RETURNS FLOAT -- NOT DOUBLE
AS
BEGIN
	DECLARE @result FLOAT;
	SET @result = 
	(
		SELECT SUM(soh.[TotalDue])
		FROM [SalesLT].[SalesOrderHeader] AS soh
		WHERE soh.[CustomerId] = @customerId
	);

	RETURN @result;
END
GO

-- USE SVF
SELECT c.*, [SalesLT]..GetCustomerTotal(c.[CustomerId])
FROM [SalesLT].[Customer] AS c

-- USE SVF WITHOUT NULLs
SELECT c.[CustomerId], CONCAT(c.[Title], ' ' +  c.[FirstName], ' ' + c.[MiddleName], ' ' + c.[LastName], + ' ' + c.[Suffix]) AS [FullName], c.[EmailAddress], c.[Phone], [dbo].GetCustomerTotal(c.[CustomerId]) AS [Total]
FROM [SalesLT].[Customer] AS c
WHERE [dbo].GetCustomerTotal(c.[CustomerId]) IS NOT NULL

-- CREATE STAT TABLE
CREATE TABLE [SalesLT].[DailyStats]
(
	[Date] DATE NOT NULL,
	[Total] FLOAT NOT NULL
)

-- QUERY DATA
SELECT [OrderDate] AS [Date], SUM([SubTotal]) AS [Sum]
FROM [SalesLT].[SalesOrderHeader]
GROUP BY [OrderDate]

-- INSERT INTO
INSERT INTO [SalesLT].[DailyStats]
SELECT [OrderDate] AS [Date], SUM([SubTotal]) AS [Sum]
FROM [SalesLT].[SalesOrderHeader]
GROUP BY [OrderDate]

SELECT *
FROM [SalesLT].[DailyStats]

-- DELETE FROM
DELETE FROM [SalesLT].[DailyStats]

SELECT *
FROM [SalesLT].[DailyStats]

-- CREATE PROCEDURE
CREATE PROCEDURE [SalesLT].[AggregateDailyStats]
AS
BEGIN
	DELETE FROM [SalesLT].[DailyStats]

	INSERT INTO [SalesLT].[DailyStats]
	SELECT [OrderDate] AS [Date], SUM([SubTotal]) AS [Sum]
	FROM [SalesLT].[SalesOrderHeader]
	GROUP BY [OrderDate]
END

-- EXECUTE PROCEDURE
EXEC [SalesLT].[AggregateDailyStats]

SELECT *
FROM [SalesLT].[DailyStats]

-- UPDATE MANUALY

-- UPDATE BY SCRIPT
UPDATE [SalesLT].[DailyStats]
	SET [OrderDate] = '2008-06-07'
WHERE [SalesOrderId] = 71917

EXEC [SalesLT].[AggregateDailyStats]

SELECT *
FROM [SalesLT].[DailyStats]