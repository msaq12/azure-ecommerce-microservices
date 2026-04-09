-- =============================================
-- Views for Common Queries
-- =============================================

-- View: Complete order information with status
CREATE VIEW vw_OrdersComplete
AS
SELECT 
    o.OrderId,
    o.OrderNumber,
    o.OrderDate,
    o.CustomerEmail,
    o.CustomerName,
    
    -- Shipping Address (concatenated)
    CONCAT(o.ShippingAddressLine1, ', ', 
           ISNULL(o.ShippingAddressLine2 + ', ', ''),
           o.ShippingCity, ', ', o.ShippingState, ' ', o.ShippingZipCode) AS ShippingAddress,
    
    -- Financial
    o.SubtotalAmount,
    o.TaxAmount,
    o.ShippingAmount,
    o.DiscountAmount,
    o.TotalAmount,
    
    -- Status
    os.StatusName AS OrderStatus,
    o.PaymentStatus,
    o.FulfillmentStatus,
    
    -- Tracking
    o.TrackingNumber,
    o.ShippingCarrier,
    o.ShippedDate,
    o.DeliveredDate,
    
    -- Item count
    (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderId = o.OrderId AND oi.IsDeleted = 0) AS ItemCount,
    
    o.CreatedDate,
    o.ModifiedDate
FROM 
    Orders o
    INNER JOIN OrderStatuses os ON o.OrderStatusId = os.OrderStatusId
WHERE 
    o.IsDeleted = 0;
GO

-- View: Order items with details
CREATE VIEW vw_OrderItemsDetailed
AS
SELECT 
    oi.OrderItemId,
    oi.OrderId,
    o.OrderNumber,
    oi.ProductSku,
    oi.ProductName,
    oi.VariantSku,
    oi.VariantName,
    oi.Quantity,
    oi.UnitPrice,
    oi.LineTotal,
    oi.DiscountAmount,
    oi.FinalLineTotal,
    oi.FulfillmentStatus,
    o.CustomerEmail,
    o.OrderDate
FROM 
    OrderItems oi
    INNER JOIN Orders o ON oi.OrderId = o.OrderId
WHERE 
    oi.IsDeleted = 0 
    AND o.IsDeleted = 0;
GO

-- View: Order summary for reporting
CREATE VIEW vw_OrdersSummary
AS
SELECT 
    CAST(o.OrderDate AS DATE) AS OrderDate,
    COUNT(DISTINCT o.OrderId) AS OrderCount,
    SUM(o.TotalAmount) AS TotalRevenue,
    AVG(o.TotalAmount) AS AverageOrderValue,
    SUM(o.SubtotalAmount) AS TotalSubtotal,
    SUM(o.TaxAmount) AS TotalTax,
    SUM(o.ShippingAmount) AS TotalShipping,
    os.StatusName AS OrderStatus
FROM 
    Orders o
    INNER JOIN OrderStatuses os ON o.OrderStatusId = os.OrderStatusId
WHERE 
    o.IsDeleted = 0
GROUP BY 
    CAST(o.OrderDate AS DATE),
    os.StatusName;
GO