-- =============================================
-- Orders Table
-- Stores main order information
-- =============================================

CREATE TABLE Orders (
    -- Primary Key
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    
    -- Order Information
    OrderNumber NVARCHAR(50) NOT NULL UNIQUE,
    OrderDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    -- Customer Information (simplified for now)
    -- Later we'll reference CustomersDB
    CustomerEmail NVARCHAR(255) NOT NULL,
    CustomerName NVARCHAR(255) NOT NULL,
    
    -- Shipping Address
    ShippingAddressLine1 NVARCHAR(255) NOT NULL,
    ShippingAddressLine2 NVARCHAR(255) NULL,
    ShippingCity NVARCHAR(100) NOT NULL,
    ShippingState NVARCHAR(50) NOT NULL,
    ShippingZipCode NVARCHAR(20) NOT NULL,
    ShippingCountry NVARCHAR(100) NOT NULL DEFAULT 'USA',
    
    -- Billing Address (can be same as shipping)
    BillingAddressLine1 NVARCHAR(255) NOT NULL,
    BillingAddressLine2 NVARCHAR(255) NULL,
    BillingCity NVARCHAR(100) NOT NULL,
    BillingState NVARCHAR(50) NOT NULL,
    BillingZipCode NVARCHAR(20) NOT NULL,
    BillingCountry NVARCHAR(100) NOT NULL DEFAULT 'USA',
    
    -- Order Totals
    SubtotalAmount DECIMAL(18,2) NOT NULL,
    TaxAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    ShippingAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount DECIMAL(18,2) NOT NULL,
    
    -- Order Status
    OrderStatusId INT NOT NULL,
    
    -- Payment Information
    PaymentMethod NVARCHAR(50) NULL,  -- 'CreditCard', 'PayPal', etc.
    PaymentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',  -- 'Pending', 'Paid', 'Failed'
    PaymentTransactionId NVARCHAR(255) NULL,
    
    -- Fulfillment Information
    FulfillmentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',  -- 'Pending', 'Processing', 'Shipped', 'Delivered'
    ShippingCarrier NVARCHAR(100) NULL,  -- 'FedEx', 'UPS', etc.
    TrackingNumber NVARCHAR(255) NULL,
    ShippedDate DATETIME2 NULL,
    DeliveredDate DATETIME2 NULL,
    
    -- Notes
    CustomerNotes NVARCHAR(MAX) NULL,
    InternalNotes NVARCHAR(MAX) NULL,
    
    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CreatedBy NVARCHAR(255) NOT NULL DEFAULT 'System',
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedBy NVARCHAR(255) NOT NULL DEFAULT 'System',
    IsDeleted BIT NOT NULL DEFAULT 0,
    
    -- Indexes will be added later
);
GO

-- Add description
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Stores order header information', 
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'Orders';
GO