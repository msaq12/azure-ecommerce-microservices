-- =============================================
-- Indexes for Performance
-- =============================================

-- Orders Table Indexes
-- Index on OrderNumber (frequently searched)
CREATE NONCLUSTERED INDEX IX_Orders_OrderNumber 
ON Orders(OrderNumber);

-- Index on CustomerEmail (customer order lookup)
CREATE NONCLUSTERED INDEX IX_Orders_CustomerEmail 
ON Orders(CustomerEmail);

-- Index on OrderDate (date range queries)
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate 
ON Orders(OrderDate DESC);

-- Index on OrderStatusId (filtering by status)
CREATE NONCLUSTERED INDEX IX_Orders_OrderStatusId 
ON Orders(OrderStatusId);

-- Composite index for common query (email + date)
CREATE NONCLUSTERED INDEX IX_Orders_Email_Date 
ON Orders(CustomerEmail, OrderDate DESC);

-- Index on CreatedDate (reporting)
CREATE NONCLUSTERED INDEX IX_Orders_CreatedDate 
ON Orders(CreatedDate DESC);

-- OrderItems Table Indexes
-- Index on OrderId (joining with Orders)
CREATE NONCLUSTERED INDEX IX_OrderItems_OrderId 
ON OrderItems(OrderId);

-- Index on ProductSku (product sales analysis)
CREATE NONCLUSTERED INDEX IX_OrderItems_ProductSku 
ON OrderItems(ProductSku);

-- Index on FulfillmentStatus (tracking unfulfilled items)
CREATE NONCLUSTERED INDEX IX_OrderItems_FulfillmentStatus 
ON OrderItems(FulfillmentStatus);

-- Composite index for product + order
CREATE NONCLUSTERED INDEX IX_OrderItems_Product_Order 
ON OrderItems(ProductSku, OrderId);

GO