DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS lineitems;

CREATE EXTERNAL TABLE sales
       (OrderDate DATE,
        OrderID INT,
        CustomerID INT,
        CustomerName STRING,
        OrderLineID INT,
        StockItemID INT,
        StockItemName STRING,
        Quantity INT,
        UnitPrice FLOAT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE LOCATION '${hiveconf:sales_folder}/'
tblproperties ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE orders
  (OrderDate DATE,
   OrderID INT,
   CustomerID INT,
   CustomerName STRING,
   Total FLOAT)
PARTITIONED BY (year INT, month INT, day INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE LOCATION '${hiveconf:orders_folder}';

INSERT OVERWRITE TABLE orders PARTITION(year, month, day)
SELECT OrderDate,
       OrderID,
       CustomerID,
       CustomerName,
       SUM(Quantity * UnitPrice) AS Total,
       YEAR(OrderDate),
       MONTH(OrderDate),
       DAYOFMONTH(OrderDate)   
FROM sales
GROUP BY OrderDate, OrderID, CustomerID, CustomerName;

CREATE EXTERNAL TABLE lineitems
  (OrderID INT,
   OrderLineID INT,
   StockItemID INT,
   StockItemName STRING,
   Quantity INT,
   UnitPrice FLOAT,
   LineTotal FLOAT)
PARTITIONED BY (year INT, month INT, day INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE LOCATION '${hiveconf:lineitems_folder}';

INSERT OVERWRITE TABLE lineitems PARTITION(year, month, day)
SELECT OrderID,
       OrderLineID,
       StockItemID,
       StockItemName,
       Quantity,
       UnitPrice,
       Quantity * UnitPrice AS LineTotal,
       YEAR(OrderDate),
       MONTH(OrderDate),
       DAYOFMONTH(OrderDate)   
FROM sales;
