-- =============================================
-- OrderItems Table
-- Stores line items for each order
-- =============================================

CREATE TABLE OrderItems (
    -- Primary Key
    OrderItemId INT PRIMARY KEY IDENTITY(1,1),
    
    -- Foreign Key to Orders
    OrderId INT NOT NULL,
    
    -- Product Information
    -- For now, we store product details here
    -- Later we'll reference ProductsDB (Cosmos DB)
    ProductSku NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    ProductDescription NVARCHAR(MAX) NULL,
    
    -- Variant Information (if applicable)
    VariantSku NVARCHAR(50) NULL,
    VariantName NVARCHAR(255) NULL,  -- e.g., "Blue, Large"
    
    -- Pricing
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(18,2) NOT NULL,
    LineTotal DECIMAL(18,2) NOT NULL,  -- Quantity * UnitPrice
    
    -- Discount (if item-level discount applied)
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    FinalLineTotal DECIMAL(18,2) NOT NULL,  -- LineTotal - DiscountAmount
    
    -- Fulfillment tracking per item
    FulfillmentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    FulfilledQuantity INT NOT NULL DEFAULT 0,
    
    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0,
    
    -- Foreign Key Constraint
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) 
        REFERENCES Orders(OrderId) ON DELETE CASCADE,
    
    -- Check Constraints
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_OrderItems_LineTotal CHECK (LineTotal >= 0)
);
GO

-- Add description
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Stores individual items within an order', 
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'OrderItems';
GO