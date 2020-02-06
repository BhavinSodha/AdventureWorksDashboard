IF OBJECT_ID('BhavinTable', 'U') IS NOT NULL
   DROP TABLE BhavinTable

SELECT 
    s.SalesOrderNumber 
    ,s.SalesOrderLineNumber
    ,p1.EnglishProductName AS product
    ,p2.EnglishProductSubcategoryName AS Subcategory
    ,p3.EnglishProductCategoryName AS Category
    ,s.seller
    ,r.ResellerName AS reseller
    ,e.FirstName+' '+e.LastName AS employee
    ,s.sale_ammount AS ammount
    ,q.SalesAmountQuota AS salesQuota
    ,CONVERT(date, s.OrderDate, 103) AS OrderDate
    ,s.OrderDateKey
    ,'Y'+CONVERT(varchar, YEAR(s.OrderDate))+'Q'+cONvert(varchar, DATEPART(QUARTER, s.OrderDate)) AS YearQuarter
    ,s2.SalesTerritoryCountry AS country
    ,s2.SalesTerritoryGroup AS Region
    ,f.Manufacturer AS 'Reason Manufacturing'
    ,f.Marketing AS 'Reason Marketing'
    ,f.Other AS 'Reason Other'
    ,f.PromotiON AS 'Reason PromotiON'
    ,f.Quality AS 'Reason Quality'
    ,f.Review AS 'Reason Review'
    ,f.price AS 'Reason Price'
    
    INTO BhavinTable

FROM (SELECT
    'Reseller' AS seller
    ,r1.SalesAmount AS sale_ammount
    ,r1.OrderDate 
    ,r1.ProductKey
    ,r1.OrderDateKey
    ,r1.SalesOrderLineNumber
    ,r1.SalesOrderNumber
    ,r1.EmployeeKey
    ,r1.ResellerKey
    ,r1.SalesTerritoryKey
FROM AdventureWorks.dbo.FactResellerSales AS r1
UNION ALL 
SELECT 
    'Internet'
    ,i.SalesAmount
    ,i.OrderDate
    ,i.ProductKey
    ,i.OrderDateKey
    ,i.SalesOrderLineNumber
    ,i.SalesOrderNumber
    ,null
    ,null
    ,null

FROM AdventureWorks.dbo.FactInternetSales AS i) AS s

LEFT JOIN AdventureWorks.dbo.DimProduct AS p1
ON 
p1.ProductKey = s.ProductKey

LEFT JOIN AdventureWorks.dbo.DimProductsubCategory AS p2
ON p2.ProductsubCategoryKey = p1.ProductSubcategoryKey

LEFT JOIN AdventureWorks.dbo.DimProductCategory AS p3
ON p3.ProductCategoryKey = p2.ProductCategoryKey

LEFT JOIN AdventureWorks.dbo.DimReseller AS r 
ON r.ResellerKey = s.ResellerKey

LEFT JOIN AdventureWorks.dbo.DimEmployee AS e 
ON e.EmployeeKey = s.EmployeeKey

LEFT JOIN AdventureWorks.dbo.DimSalesTerritory AS s2
ON s2.SalesTerritoryKey = s.SalesTerritoryKey

LEFT JOIN (SELECT  
    f.SalesOrderNumber
    ,f.SalesOrderLineNumber 
    ,sum(CASE WHEN f.SalesReASONKey = 1 THEN 1 ELSE 0 END)  AS price
    ,sum(CASE WHEN f.SalesReASONKey = 2 THEN 1 ELSE 0 END)  AS PromotiON
    ,sum(CASE WHEN f.SalesReASONKey = 4 THEN 1 ELSE 0 END ) AS Marketing
    ,sum(CASE WHEN f.SalesReASONKey = 5 THEN 1 ELSE 0 END ) AS Manufacturer
    ,sum(CASE WHEN f.SalesReASONKey = 6 THEN 1 ELSE 0 END ) AS Review
    ,sum(CASE WHEN f.SalesReASONKey = 9 THEN 1 ELSE 0 END ) AS Quality
    ,sum(CASE WHEN f.SalesReASONKey = 10 THEN 1 ELSE 0 END ) AS Other
    
   FROM [AdventureWorks].[dbo].[FactInternetSalesReASON] AS f
GROUP BY f.SalesOrderNumber, f.SalesOrderLineNumber) AS f ON 

   f.SalesOrderNumber = s.SalesOrderNumber AND f.SalesOrderLineNumber = s.SalesOrderLineNumber
   
LEFT JOIN (SELECT  [SalesQuotaKey]
      ,[EmployeeKey]
      ,[DateKey] AS 'StartDate'
      ,CASE WHEN lag(DateKey, 1, 0) OVER(PARTITION by EmployeeKey order by DateKey desc) = 0 THEN 20190000 ELSE lag(DateKey, 1, 0) OVER(PARTITION by EmployeeKey order by DateKey desc)-1 END AS 'ENDDate'
      ,[CalENDarYear]
      ,[CalENDarQuarter]
      ,[SalesAmountQuota]
      ,[Date]
  FROM [AdventureWorks].[dbo].[FactSalesQuota]) AS Q
  ON q.EmployeeKey = s.EmployeeKey AND s.OrderDateKey between q.StartDate AND q.ENDDate
  WHERE s.OrderDateKey > 20101231 AND s.OrderDateKey < 20140000
  ;
