CREATE TABLE Orders
(OrderDate datetime,
 OrderID int,
 CustomerID int,
 CustomerName nvarchar(100),
 Total money);


 CREATE TABLE LineItems
 (OrderID int,
  OrderLineID int,
  StockItemID int,
  StockItemName nvarchar(100),
  Quantity int,
  UnitPrice money,
  LineTotal money);