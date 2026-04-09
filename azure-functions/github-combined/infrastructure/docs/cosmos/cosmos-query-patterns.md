# Cosmos DB Query Patterns - Products

## Best Practices

1. **Always include partition key when possible**

   - Lower RU cost
   - Faster query performance
   - Example: `WHERE c.categoryId = "sofas"`

2. **Use indexes effectively**

   - All properties indexed by default
   - We excluded `/description/*` to save RUs

3. **Minimize cross-partition queries**
   - Queries without partition key = expensive
   - Example: Searching all products by tag

## Common Query Patterns

### 1. Get Products in Category (Efficient)

```sql
SELECT * FROM c WHERE c.categoryId = "sofas"
```

Cost: ~2.8 RU per product

### 2. Get Single Product (Most Efficient)

```sql
SELECT * FROM c
WHERE c.id = "prod-sofa-001"
AND c.categoryId = "sofas"
```

Cost: ~2.8 RU

### 3. Search by Price Range (Cross-partition)

```sql
SELECT * FROM c
WHERE c.price >= 200 AND c.price <= 500
```

Cost: ~5-10 RU (more expensive)

### 4. Filter by Tag (Cross-partition)

```sql
SELECT * FROM c
WHERE ARRAY_CONTAINS(c.tags, "modern")
```

Cost: ~5-10 RU

### 5. Search by Name (Cross-partition, text search)

```sql
SELECT * FROM c
WHERE CONTAINS(c.name, "sofa", true)
```

Cost: ~8-15 RU (case-insensitive search)

### 6. Get Active Products in Category (Efficient)

```sql
SELECT * FROM c
WHERE c.categoryId = "sofas"
AND c.isActive = true
AND c.isDeleted = false
```

Cost: ~3-4 RU per product

### 7. Paginated Results

```sql
SELECT * FROM c
WHERE c.categoryId = "sofas"
ORDER BY c.createdAt DESC
OFFSET 0 LIMIT 20
```

Cost: ~3-5 RU per page

## Performance Tips

- **Partition key queries**: Always fastest and cheapest
- **Indexing**: Keep default indexing, only exclude large text
- **Pagination**: Use OFFSET/LIMIT for large result sets
- **Projections**: Select only needed fields to reduce RU cost

```sql
  SELECT c.id, c.name, c.price FROM c
```

## Product API Query Mapping

| API Endpoint                 | Cosmos Query                              | Partition Key? |
| ---------------------------- | ----------------------------------------- | -------------- |
| GET /products?category=sofas | WHERE c.categoryId = "sofas"              | ✅ Yes         |
| GET /products/:id            | WHERE c.id = ":id" AND c.categoryId = ... | ✅ Yes         |
| GET /products?search=modern  | WHERE CONTAINS(c.name, "modern")          | ❌ No          |
| GET /products?minPrice=200   | WHERE c.price >= 200                      | ❌ No          |
| GET /products?tag=leather    | WHERE ARRAY_CONTAINS(c.tags, "leather")   | ❌ No          |

**Recommendation**: Cache cross-partition queries in Redis (Part D)
