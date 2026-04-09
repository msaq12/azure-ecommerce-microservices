-- =============================================
-- OrderStatuses Lookup Table
-- Defines valid order statuses
-- =============================================

CREATE TABLE OrderStatuses (
    OrderStatusId INT PRIMARY KEY IDENTITY(1,1),
    StatusCode NVARCHAR(50) NOT NULL UNIQUE,
    StatusName NVARCHAR(100) NOT NULL,
    StatusDescription NVARCHAR(500) NULL,
    DisplayOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

-- Add Foreign Key to Orders table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_OrderStatuses FOREIGN KEY (OrderStatusId)
    REFERENCES OrderStatuses(OrderStatusId);
GO

-- Insert default statuses
INSERT INTO OrderStatuses (StatusCode, StatusName, StatusDescription, DisplayOrder) VALUES
('PENDING', 'Pending', 'Order has been created but not yet processed', 1),
('CONFIRMED', 'Confirmed', 'Order has been confirmed and payment received', 2),
('PROCESSING', 'Processing', 'Order is being prepared for shipment', 3),
('SHIPPED', 'Shipped', 'Order has been shipped to customer', 4),
('DELIVERED', 'Delivered', 'Order has been delivered to customer', 5),
('CANCELLED', 'Cancelled', 'Order has been cancelled', 6),
('REFUNDED', 'Refunded', 'Order has been refunded', 7),
('RETURNED', 'Returned', 'Order has been returned by customer', 8);
GO

-- Add description
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Lookup table for order status values', 
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'OrderStatuses';
GO