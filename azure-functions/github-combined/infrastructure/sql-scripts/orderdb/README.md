# OrdersDB Schema Documentation

## Overview

OrdersDB stores all order-related information for the Furniture Dropshipping Platform.

## Tables

### Orders

Main order information including customer details, addresses, totals, and status.

**Key Fields**:

- `OrderId` (PK): Unique identifier
- `OrderNumber`: Human-readable order reference
- `CustomerEmail`: Customer identifier
- `TotalAmount`: Final order total
- `OrderStatusId` (FK): Current order status

### OrderItems

Line items for each order.

**Key Fields**:

- `OrderItemId` (PK): Unique identifier
- `OrderId` (FK): Parent order
- `ProductSku`: Product identifier
- `Quantity`: Number of items
- `FinalLineTotal`: Item total after discounts

### OrderStatuses

Lookup table for valid order statuses.

**Statuses**:

1. PENDING - Order created
2. CONFIRMED - Payment received
3. PROCESSING - Being prepared
4. SHIPPED - Sent to customer
5. DELIVERED - Received by customer
6. CANCELLED - Order cancelled
7. REFUNDED - Money refunded
8. RETURNED - Product returned

## Relationships

## Indexes

- OrderNumber (unique, searchable)
- CustomerEmail (for customer order history)
- OrderDate (for date range queries)
- ProductSku (for product analytics)

## Views

- `vw_OrdersComplete`: Full order details with status names
- `vw_OrderItemsDetailed`: Order items with order info
- `vw_OrdersSummary`: Daily order statistics

## Stored Procedures

- `sp_GetOrderByNumber`: Retrieve complete order
- `sp_GetCustomerOrders`: Get customer order history (paginated)
- `sp_UpdateOrderStatus`: Change order status
- `sp_GetOrderStatistics`: Get order metrics for date range

## Deployment Order

1. `01-create-orders-table.sql`
2. `02-create-orderitems-table.sql`
3. `03-create-orderstatuses-table.sql`
4. `04-create-indexes.sql`
5. `05-create-views.sql`
6. `06-create-stored-procedures.sql`

## Example Queries

### Get all pending orders

```sql
SELECT * FROM vw_OrdersComplete
WHERE OrderStatus = 'Pending'
ORDER BY OrderDate DESC;
```

### Get top selling products

```sql
SELECT ProductSku, ProductName, SUM(Quantity) AS TotalSold
FROM vw_OrderItemsDetailed
GROUP BY ProductSku, ProductName
ORDER BY TotalSold DESC;
```

### Customer order history

```sql
EXEC sp_GetCustomerOrders @CustomerEmail = 'customer@example.com';
```
