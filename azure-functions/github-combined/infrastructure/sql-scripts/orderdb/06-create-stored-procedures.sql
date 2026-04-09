-- =============================================
-- Stored Procedures
-- =============================================

-- SP: Get order by order number
CREATE PROCEDURE sp_GetOrderByNumber
    @OrderNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get order header
    SELECT * FROM vw_OrdersComplete
    WHERE OrderNumber = @OrderNumber;
    
    -- Get order items
    SELECT * FROM vw_OrderItemsDetailed
    WHERE OrderNumber = @OrderNumber;
END;
GO

-- SP: Get customer orders
CREATE PROCEDURE sp_GetCustomerOrders
    @CustomerEmail NVARCHAR(255),
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM vw_OrdersComplete
    WHERE CustomerEmail = @CustomerEmail
    ORDER BY OrderDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- SP: Update order status
CREATE PROCEDURE sp_UpdateOrderStatus
    @OrderId INT,
    @NewStatusCode NVARCHAR(50),
    @ModifiedBy NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewStatusId INT;
    
    -- Get status ID
    SELECT @NewStatusId = OrderStatusId 
    FROM OrderStatuses 
    WHERE StatusCode = @NewStatusCode AND IsActive = 1;
    
    IF @NewStatusId IS NULL
    BEGIN
        RAISERROR('Invalid status code', 16, 1);
        RETURN;
    END
    
    -- Update order
    UPDATE Orders
    SET OrderStatusId = @NewStatusId,
        ModifiedDate = GETUTCDATE(),
        ModifiedBy = @ModifiedBy
    WHERE OrderId = @OrderId;
    
    -- Return updated order
    SELECT * FROM vw_OrdersComplete WHERE OrderId = @OrderId;
END;
GO

-- SP: Get order statistics
CREATE PROCEDURE sp_GetOrderStatistics
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default to last 30 days if not specified
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -30, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    SELECT 
        COUNT(*) AS TotalOrders,
        SUM(TotalAmount) AS TotalRevenue,
        AVG(TotalAmount) AS AverageOrderValue,
        MIN(TotalAmount) AS MinimumOrderValue,
        MAX(TotalAmount) AS MaximumOrderValue,
        COUNT(DISTINCT CustomerEmail) AS UniqueCustomers
    FROM Orders
    WHERE OrderDate BETWEEN @StartDate AND @EndDate
        AND IsDeleted = 0;
END;
GO